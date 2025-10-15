// lib/services/breeding_service.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/breeding_record.dart';
import '../models/animal.dart';

class BreedingEvent {
  final String label;     // ex: "Ultrassom", "Parto previsto"
  final DateTime date;
  final String stage;     // estágio salvo no DB (snake_case)
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

class BreedingService {
  // ========================
  // Helpers internos (NOVOS)
  // ========================

  static String _yyyyMmDd(DateTime d) => d.toIso8601String().substring(0, 10);

  static String _uuidV4() {
    final rnd = Random.secure();
    final b = List<int>.generate(16, (_) => rnd.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // v4
    b[8] = (b[8] & 0x3f) | 0x80; // RFC 4122
    String h(int x) => x.toRadixString(16).padLeft(2, '0');
    return '${h(b[0])}${h(b[1])}${h(b[2])}${h(b[3])}-${h(b[4])}${h(b[5])}-${h(b[6])}${h(b[7])}-${h(b[8])}${h(b[9])}-${h(b[10])}${h(b[11])}${h(b[12])}${h(b[13])}${h(b[14])}${h(b[15])}';
  }

  /// Normaliza os estágios aceitando variações e acentos → snake_case usado no DB local.
  static String _canonStage(String? raw) {
    final t = (raw ?? '').trim().toLowerCase().replaceAll(' ', '_');
    switch (t) {
      case 'encabritamento':               return 'encabritamento';
      case 'separacao':
      case 'separação':                    return 'separacao';
      case 'aguardando_ultrassom':
      case 'aguardando-ultrassom':
      case 'aguardando_ultra':
      case 'aguardando ultrassom':         return 'aguardando_ultrassom';
      case 'gestacao_confirmada':
      case 'gestação_confirmada':          return 'gestacao_confirmada';
      case 'parto_realizado':
      case 'parto realizado':              return 'parto_realizado';
      case 'falhou':                       return 'falhou';
      default:                             return 'encabritamento';
    }
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString();
    // dd/MM/yyyy
    if (s.contains('/')) {
      final p = s.split('/');
      if (p.length == 3) {
        final d = int.tryParse(p[0]);
        final m = int.tryParse(p[1]);
        final y = int.tryParse(p[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
    }
    return DateTime.tryParse(s);
  }

  // ===================================
  // CRIAÇÃO / ATUALIZAÇÃO (NOVO BLOCO)
  // ===================================

  /// Cria um registro de reprodução em qualquer estágio.
  /// Os triggers do SQLite cuidam de:
  ///  - `status` (derivado de `stage`)
  ///  - atualizar `animals.pregnant` / `animals.expected_delivery` quando apropriado
  static Future<void> createRecord({
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
    final db = await DatabaseService.database;
    final nowIso = DateTime.now().toIso8601String();

    final data = <String, dynamic>{
      'id': _uuidV4(),
      'female_animal_id': femaleId,
      'male_animal_id': maleId,
      'breeding_date': _yyyyMmDd(breedingDate ?? DateTime.now()),
      'expected_birth': expectedBirth != null ? _yyyyMmDd(expectedBirth) : null,
      'mating_start_date': matingStartDate != null ? _yyyyMmDd(matingStartDate) : null,
      'mating_end_date': matingEndDate != null ? _yyyyMmDd(matingEndDate) : null,
      'separation_date': separationDate != null ? _yyyyMmDd(separationDate) : null,
      'ultrasound_date': ultrasoundDate != null ? _yyyyMmDd(ultrasoundDate) : null,
      'ultrasound_result': ultrasoundResult,
      'stage': _canonStage(stage),
      'notes': notes,
      'created_at': nowIso,
      'updated_at': nowIso,
      // NÃO setamos 'status' manualmente; o trigger traduz a partir do stage
    };

    await db.insert('breeding_records', data);
  }

  /// Botão "Nova cobertura" → começa em encabritamento.
  static Future<void> novaCobertura({
    required String femaleId,
    String? maleId,
    DateTime? breedingDate,
    DateTime? matingStartDate, // se quiser já marcar início do encabritamento
    String? notes,
  }) =>
      createRecord(
        femaleId: femaleId,
        maleId: maleId,
        stage: 'encabritamento',
        breedingDate: breedingDate,
        matingStartDate: matingStartDate ?? DateTime.now(),
        notes: notes,
      );

  /// Botão para registrar quando já está na separação.
  static Future<void> criarEmSeparacao({
    required String femaleId,
    String? maleId,
    DateTime? breedingDate,
    DateTime? separationDate,
    String? notes,
  }) =>
      createRecord(
        femaleId: femaleId,
        maleId: maleId,
        stage: 'separacao',
        breedingDate: breedingDate,
        separationDate: separationDate ?? DateTime.now(),
        notes: notes,
      );

  /// Botão para registrar quando já está aguardando ultrassom.
  static Future<void> criarAguardandoUltrassom({
    required String femaleId,
    String? maleId,
    DateTime? breedingDate,
    DateTime? separationDate,
    DateTime? ultrasoundDate,
    String? notes,
  }) =>
      createRecord(
        femaleId: femaleId,
        maleId: maleId,
        stage: 'aguardando_ultrassom',
        breedingDate: breedingDate,
        separationDate: separationDate,
        ultrasoundDate: ultrasoundDate,
        notes: notes,
      );

  /// Atualiza um registro existente para "Gestação Confirmada".
  /// Se você passar `expectedBirth`, também já preenche a data prevista (gatilho atualiza o animal).
  static Future<void> confirmarGestacao({
    required String breedingId,
    DateTime? expectedBirth,
  }) async {
    final db = await DatabaseService.database;
    await db.update(
      'breeding_records',
      {
        'stage': 'gestacao_confirmada',
        if (expectedBirth != null) 'expected_birth': _yyyyMmDd(expectedBirth),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [breedingId],
    );
  }

  /// Atualiza para "Parto Realizado".
  static Future<void> registrarParto({
    required String breedingId,
    DateTime? birthDate,
  }) async {
    final db = await DatabaseService.database;
    await db.update(
      'breeding_records',
      {
        'stage': 'parto_realizado',
        if (birthDate != null) 'birth_date': _yyyyMmDd(birthDate),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [breedingId],
    );
  }

  /// Atualiza para "Falhou".
  static Future<void> marcarFalha({
    required String breedingId,
  }) async {
    final db = await DatabaseService.database;
    await db.update(
      'breeding_records',
      {
        'stage': 'falhou',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [breedingId],
    );
  }

  // ======================================
  // Consultas para Dashboard (SEU CÓDIGO)
  // ======================================

  /// Eventos dos próximos [days] dias (e atrasados).
  static Future<List<BreedingEvent>> getUpcomingEvents(int days) async {
    final records = await DatabaseService.getBreedingRecords();
    final animals = await DatabaseService.getAnimals();
    final animalMap = {for (var a in animals) a.id: a};

    final now = DateTime.now();
    final limit = now.add(Duration(days: days));
    final events = <BreedingEvent>[];

    for (final r in records) {
      final st = BreedingStage.fromString(r['stage'] as String?);
      final stage = (r['stage'] ?? '').toString();

      DateTime? eventDate;
      String? label;

      switch (st) {
        case BreedingStage.encabritamento:
          eventDate = _toDate(r['mating_end_date']);
          label = 'Fim do encabritamento';
          break;

        case BreedingStage.separacao:
          {
            final sep = _toDate(r['separation_date']);
            final ult = _toDate(r['ultrasound_date']) ??
                (sep != null ? sep.add(const Duration(days: 30)) : null);
            eventDate = ult;
            label = 'Ultrassom';
          }
          break;

        case BreedingStage.aguardandoUltrassom:
          {
            final sep = _toDate(r['separation_date']);
            final ult = _toDate(r['ultrasound_date']) ??
                (sep != null ? sep.add(const Duration(days: 30)) : null);
            eventDate = ult;
            label = 'Ultrassom';
          }
          break;

        case BreedingStage.gestacaoConfirmada:
          eventDate = _toDate(r['expected_birth']);
          label = 'Parto previsto';
          break;

        case BreedingStage.partoRealizado:
        case BreedingStage.falhou:
          break;
      }

      if (eventDate == null) continue;

      final isOverdue = eventDate.isBefore(DateTime(now.year, now.month, now.day));
      final isSoon = !eventDate.isAfter(limit);

      if (isOverdue || isSoon) {
        final female = animalMap[r['female_animal_id']];
        events.add(
          BreedingEvent(
            label: label ?? 'Evento',
            date: eventDate,
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
  static Future<Map<String, int>> getCounters(int days) async {
    final list = await getUpcomingEvents(days);
    final overdue = list.where((e) => e.overdue).length;
    final upcoming = list.length - overdue;
    return {'upcoming': upcoming, 'overdue': overdue};
  }
}

/// Label amigável de estágio (se você usa em algum lugar da UI).
String _toUiStageLabel(String? raw) => BreedingStage.fromString(raw).uiTabLabel;
