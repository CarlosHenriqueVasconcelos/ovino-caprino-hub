// lib/services/breeding_service.dart
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/animal_repository.dart';
import '../data/breeding_repository.dart';
import '../models/animal.dart';
import '../models/breeding_record.dart';

class BreedingEvent {
  final String label; // ex: "Ultrassom", "Parto previsto"
  final DateTime date;
  final String stage; // estágio salvo no DB (snake_case)
  final String femaleCode;
  final String femaleName;
  final bool overdue;

  BreedingEvent({
    required this.label,
    required this.date,
    required this.stage,
    required this.femaleCode,
    required this.femaleName,
    required this.overdue,
  });
}

// Opcional (para quadro de avisos por categoria). Não quebra nada se você não usar.
class ReproBoardData {
  final List<BreedingEvent> separacoes;
  final List<BreedingEvent> ultrassons;
  final List<BreedingEvent> partos;
  final int overdueTotal;

  ReproBoardData({
    required this.separacoes,
    required this.ultrassons,
    required this.partos,
  }) : overdueTotal = [
          ...separacoes,
          ...ultrassons,
          ...partos,
        ].where((e) => e.overdue).length;
}

class BreedingService extends ChangeNotifier {
  final BreedingRepository _repository;
  final AnimalRepository _animalRepository;

  BreedingService(this._repository, this._animalRepository);

  // ========================
  // Helpers internos
  // ========================

  static String _yyyyMmDd(DateTime d) => d.toIso8601String().substring(0, 10);

  static String _uuidV4() {
    final rnd = Random.secure();
    final b = List<int>.generate(16, (_) => rnd.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // v4
    b[8] = (b[8] & 0x3f) | 0x80; // RFC 4122
    String h(int x) => x.toRadixString(16).padLeft(2, '0');
    return '${h(b[0])}${h(b[1])}${h(b[2])}${h(b[3])}-'
        '${h(b[4])}${h(b[5])}-'
        '${h(b[6])}${h(b[7])}-'
        '${h(b[8])}${h(b[9])}-'
        '${h(b[10])}${h(b[11])}${h(b[12])}${h(b[13])}${h(b[14])}${h(b[15])}';
  }

  /// Normaliza o estágio usando o enum como fonte da verdade.
  static String _canonStage(String? raw) => BreedingStage.fromString(raw).value;

  // ===================================
  // API de instância (via Provider)
  // ===================================

  /// Usado na aba de Reprodução da ManagementScreen.
  ///
  /// Mantém o formato esperado pela UI:
  /// - datas como String (yyyy-MM-dd)
  /// - campos `female_animal_id`, `male_animal_id`, `status`, `stage`, `expected_birth`
  Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    final records = await _repository.getAll();

    return records.map((r) {
      return <String, dynamic>{
        'id': r.id,
        'female_animal_id': r.femaleAnimalId,
        'male_animal_id': r.maleAnimalId,
        'breeding_date': _yyyyMmDd(r.breedingDate),
        'mating_start_date':
            r.matingStartDate != null ? _yyyyMmDd(r.matingStartDate!) : null,
        'mating_end_date':
            r.matingEndDate != null ? _yyyyMmDd(r.matingEndDate!) : null,
        'separation_date':
            r.separationDate != null ? _yyyyMmDd(r.separationDate!) : null,
        'ultrasound_date':
            r.ultrasoundDate != null ? _yyyyMmDd(r.ultrasoundDate!) : null,
        'ultrasound_result': r.ultrasoundResult,
        'expected_birth':
            r.expectedBirth != null ? _yyyyMmDd(r.expectedBirth!) : null,
        'birth_date': r.birthDate != null ? _yyyyMmDd(r.birthDate!) : null,
        'stage': r.stage.value,
        'status': r.status,
        'notes': r.notes,
      };
    }).toList();
  }

  // ===================================
  // CRIAÇÃO / ATUALIZAÇÃO
  // ===================================

  /// Cria um registro de reprodução em qualquer estágio.
  ///
  /// 🔒 Salvaguarda importante:
  /// - se o estágio NÃO for `gestacao_confirmada`, **não** persistimos
  ///   `expected_birth` nem `ultrasound_result`.
  Future<void> createRecord({
    required String femaleId,
    String? maleId,
    String stage = 'encabritamento', // padrão botão "Nova cobertura"
    DateTime? breedingDate,
    DateTime? expectedBirth,
    DateTime? matingStartDate,
    DateTime? matingEndDate,
    DateTime? separationDate,
    DateTime? ultrasoundDate,
    String? ultrasoundResult,
    String? notes,
  }) async {
    final now = DateTime.now();
    final stageCanon = _canonStage(stage);
    final stageEnum = BreedingStage.fromString(stageCanon);

    // Somente em gestação confirmada persistimos expected_birth/ultrasound_result
    DateTime? safeExpectedBirth;
    String? safeUltrasoundResult;
    if (stageEnum == BreedingStage.gestacaoConfirmada) {
      safeExpectedBirth = expectedBirth;
      if (ultrasoundResult != null && ultrasoundResult.isNotEmpty) {
        safeUltrasoundResult = ultrasoundResult;
      }
    }

    final record = BreedingRecord(
      id: _uuidV4(),
      femaleAnimalId: femaleId,
      maleAnimalId: maleId,
      breedingDate: breedingDate ?? now,
      matingStartDate: matingStartDate,
      matingEndDate: matingEndDate,
      separationDate: separationDate,
      ultrasoundDate: ultrasoundDate,
      ultrasoundResult: safeUltrasoundResult,
      expectedBirth: safeExpectedBirth,
      birthDate: null,
      stage: stageEnum,
      status: stageEnum.statusLabel,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.insert(record);
    notifyListeners();
  }

  /// Botão "Nova cobertura" → começa em encabritamento.
  Future<void> novaCobertura({
    required String femaleId,
    String? maleId,
    DateTime? breedingDate,
    DateTime? matingStartDate, // se quiser já marcar início do encabritamento
    DateTime? matingEndDate, // se já souber o término
    String? notes,
  }) {
    return createRecord(
      femaleId: femaleId,
      maleId: maleId,
      stage: 'encabritamento',
      breedingDate: breedingDate,
      matingStartDate: matingStartDate ?? DateTime.now(),
      matingEndDate: matingEndDate,
      notes: notes,
    );
  }

  /// Criar diretamente na etapa "Separação".
  Future<void> criarEmSeparacao({
    required String femaleId,
    String? maleId,
    DateTime? breedingDate,
    DateTime? separationDate,
    String? notes,
  }) {
    return createRecord(
      femaleId: femaleId,
      maleId: maleId,
      stage: 'separacao',
      breedingDate: breedingDate,
      separationDate: separationDate ?? DateTime.now(),
      notes: notes,
    );
  }

  /// Criar diretamente na etapa "Aguardando Ultrassom".
  Future<void> criarAguardandoUltrassom({
    required String femaleId,
    String? maleId,
    DateTime? breedingDate,
    DateTime? separationDate,
    DateTime? ultrasoundDate,
    String? notes,
  }) {
    return createRecord(
      femaleId: femaleId,
      maleId: maleId,
      stage: 'aguardando_ultrassom',
      breedingDate: breedingDate,
      separationDate: separationDate,
      ultrasoundDate: ultrasoundDate,
      notes: notes,
    );
  }

  /// Atualiza para "Gestação Confirmada".
  /// Se `expectedBirth` for informado, já preenche a previsão de parto.
  Future<void> confirmarGestacao({
    required String breedingId,
    DateTime? expectedBirth,
    String? ultrasoundResult, // opcional (ex.: "Confirmada")
  }) async {
    final existing = await _repository.getById(breedingId);
    if (existing == null) return;

    final now = DateTime.now();
    final updated = existing.copyWith(
      stage: BreedingStage.gestacaoConfirmada,
      expectedBirth: expectedBirth ?? existing.expectedBirth,
      ultrasoundResult:
          (ultrasoundResult != null && ultrasoundResult.isNotEmpty)
              ? ultrasoundResult
              : existing.ultrasoundResult,
      status: BreedingStage.gestacaoConfirmada.statusLabel,
      updatedAt: now,
    );

    await _repository.update(updated);
    notifyListeners();
  }

  /// Atualiza para "Parto Realizado".
  Future<void> registrarParto({
    required String breedingId,
    DateTime? birthDate,
  }) async {
    final existing = await _repository.getById(breedingId);
    if (existing == null) return;

    final now = DateTime.now();
    final updated = existing.copyWith(
      stage: BreedingStage.partoRealizado,
      birthDate: birthDate ?? existing.birthDate ?? now,
      status: BreedingStage.partoRealizado.statusLabel,
      updatedAt: now,
    );

    await _repository.update(updated);
    notifyListeners();
  }

  /// Atualiza para "Falhou".
  Future<void> marcarFalha({
    required String breedingId,
  }) async {
    final existing = await _repository.getById(breedingId);
    if (existing == null) return;

    final now = DateTime.now();
    final updated = existing.copyWith(
      stage: BreedingStage.falhou,
      status: BreedingStage.falhou.statusLabel,
      updatedAt: now,
    );

    await _repository.update(updated);
    notifyListeners();
  }

  // ======================================
  // Consultas para Dashboard (widgets)
  // ======================================

  /// Eventos dos próximos [days] dias (e atrasados).
  ///
  /// Mantém a mesma semântica do método original, agora usando
  /// BreedingRepository + AnimalRepository injetados.
  Future<List<BreedingEvent>> getUpcomingEvents(int days) async {
    final records = await _repository.getAll();
    final animals = await _animalRepository.all();
    final animalMap = {for (final a in animals) a.id: a};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final limit = now.add(Duration(days: days));
    final events = <BreedingEvent>[];

    for (final r in records) {
      final st = r.stage;
      final stage = r.stage.value;

      DateTime? eventDate;
      String? label;

      switch (st) {
        case BreedingStage.encabritamento:
          eventDate = r.matingEndDate;
          label = 'Fim do encabritamento';
          break;

        case BreedingStage.separacao:
        case BreedingStage.aguardandoUltrassom:
          final sep = r.separationDate;
          final ult = r.ultrasoundDate ??
              (sep != null ? sep.add(const Duration(days: 30)) : null);
          eventDate = ult;
          label = 'Ultrassom';
          break;

        case BreedingStage.gestacaoConfirmada:
          eventDate = r.expectedBirth;
          label = 'Parto previsto';
          break;

        case BreedingStage.partoRealizado:
        case BreedingStage.falhou:
          break;
      }

      if (eventDate == null) continue;

      final baseEventDate =
          DateTime(eventDate.year, eventDate.month, eventDate.day);
      final isOverdue = baseEventDate.isBefore(today);
      final isSoon = !baseEventDate.isAfter(limit);

      if (isOverdue || isSoon) {
        final Animal? female =
            r.femaleAnimalId != null ? animalMap[r.femaleAnimalId] : null;
        events.add(
          BreedingEvent(
            label: label ?? 'Evento',
            date: baseEventDate,
            stage: stage,
            femaleCode: female?.code ?? 'N/A',
            femaleName: female?.name ?? 'N/A',
            overdue: isOverdue,
          ),
        );
      }
    }

    events.sort((a, b) {
      if (a.overdue != b.overdue) return a.overdue ? -1 : 1;
      return a.date.compareTo(b.date);
    });
    return events;
  }

  /// Contadores para o dashboard.
  Future<Map<String, int>> getCounters(int days) async {
    final list = await getUpcomingEvents(days);
    final overdue = list.where((e) => e.overdue).length;
    final upcoming = list.length - overdue;
    return {'upcoming': upcoming, 'overdue': overdue};
  }

  // ======================================
  // (Opcional) Quadro de avisos por grupo
  // ======================================
  Future<ReproBoardData> getBoard({int daysAhead = 30}) async {
    final records = await _repository.getAll();
    final animals = await _animalRepository.all();
    final animalMap = {for (final a in animals) a.id: a};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final limit = today.add(Duration(days: daysAhead));

    final separacoes = <BreedingEvent>[];
    final ultrassons = <BreedingEvent>[];
    final partos = <BreedingEvent>[];

    for (final r in records) {
      final st = r.stage;

      final matingEnd = r.matingEndDate;
      final separation = r.separationDate;
      final ultrasound = r.ultrasoundDate;
      final expected = r.expectedBirth;

      // SEPARAÇÃO (encabritamento)
      if (st == BreedingStage.encabritamento) {
        final target = separation ?? matingEnd;
        if (target != null) {
          final d = DateTime(target.year, target.month, target.day);
          final inWindow = !d.isAfter(limit);
          final overdue = d.isBefore(today);
          if (overdue || inWindow) {
            final female =
                r.femaleAnimalId != null ? animalMap[r.femaleAnimalId] : null;
            separacoes.add(BreedingEvent(
              label: 'Separação',
              date: d,
              stage: st.value,
              femaleCode: female?.code ?? 'N/A',
              femaleName: female?.name ?? 'N/A',
              overdue: overdue,
            ));
          }
        }
      }

      // ULTRASSOM (separacao/aguardando_ultrassom)
      if (st == BreedingStage.separacao ||
          st == BreedingStage.aguardandoUltrassom) {
        final base = separation ?? matingEnd;
        final target = ultrasound ??
            (base != null ? base.add(const Duration(days: 30)) : null);
        if (target != null) {
          final d = DateTime(target.year, target.month, target.day);
          final inWindow = !d.isAfter(limit);
          final overdue = d.isBefore(today);
          if (overdue || inWindow) {
            final female =
                r.femaleAnimalId != null ? animalMap[r.femaleAnimalId] : null;
            ultrassons.add(BreedingEvent(
              label: 'Ultrassom',
              date: d,
              stage: st.value,
              femaleCode: female?.code ?? 'N/A',
              femaleName: female?.name ?? 'N/A',
              overdue: overdue,
            ));
          }
        }
      }

      // PARTO (gestacao_confirmada)
      if (st == BreedingStage.gestacaoConfirmada && expected != null) {
        final d = DateTime(expected.year, expected.month, expected.day);
        final inWindow = !d.isAfter(limit);
        final overdue = d.isBefore(today);
        if (overdue || inWindow) {
          final female =
              r.femaleAnimalId != null ? animalMap[r.femaleAnimalId] : null;
          partos.add(BreedingEvent(
            label: 'Parto previsto',
            date: d,
            stage: st.value,
            femaleCode: female?.code ?? 'N/A',
            femaleName: female?.name ?? 'N/A',
            overdue: overdue,
          ));
        }
      }
    }

    int _cmp(BreedingEvent a, BreedingEvent b) {
      if (a.overdue != b.overdue) return a.overdue ? -1 : 1;
      return a.date.compareTo(b.date);
    }

    separacoes.sort(_cmp);
    ultrassons.sort(_cmp);
    partos.sort(_cmp);

    return ReproBoardData(
      separacoes: separacoes,
      ultrassons: ultrassons,
      partos: partos,
    );
  }

  /// Transição de Encabritamento → Aguardando Ultrassom.
  /// Define a data de separação como agora e agenda o ultrassom para +30 dias.
  Future<void> separarAnimais(String breedingId) async {
    final existing = await _repository.getById(breedingId);
    if (existing == null) return;

    final now = DateTime.now();
    final ultrasoundEta = now.add(const Duration(days: 30));

    final updated = existing.copyWith(
      separationDate: now,
      ultrasoundDate: ultrasoundEta,
      stage: BreedingStage.aguardandoUltrassom,
      status: BreedingStage.aguardandoUltrassom.statusLabel,
      updatedAt: now,
    );

    await _repository.update(updated);
    notifyListeners();
  }

  /// Registra o resultado do ultrassom, atualizando estágio e previsão de parto.
  Future<void> registrarUltrassom({
    required String breedingId,
    required bool isConfirmada,
    String? ultrasoundResult,
    DateTime? nowOverride,
    DateTime? expectedBirthOverride,
  }) async {
    final existing = await _repository.getById(breedingId);
    if (existing == null) return;

    final now = nowOverride ?? DateTime.now();
    final ultrasoundDate = existing.ultrasoundDate ?? now;

    DateTime? expectedBirth = expectedBirthOverride;
    if (isConfirmada) {
      expectedBirth ??=
          existing.expectedBirth ?? now.add(const Duration(days: 150));
    } else {
      expectedBirth = null;
    }

    final stage =
        isConfirmada ? BreedingStage.gestacaoConfirmada : BreedingStage.falhou;

    final updated = existing.copyWith(
      ultrasoundDate: ultrasoundDate,
      ultrasoundResult:
          (ultrasoundResult != null && ultrasoundResult.isNotEmpty)
              ? ultrasoundResult
              : existing.ultrasoundResult,
      expectedBirth: expectedBirth,
      stage: stage,
      status: stage.statusLabel,
      updatedAt: now,
    );

    await _repository.update(updated);
    notifyListeners();
  }

  /// Remove completamente o registro de reprodução.
  Future<void> cancelarRegistro(String breedingId) async {
    await _repository.delete(breedingId);
    notifyListeners();
  }
}

/// Label amigável de estágio (se você usa em algum lugar da UI).
String _toUiStageLabel(String? raw) => BreedingStage.fromString(raw).uiTabLabel;
