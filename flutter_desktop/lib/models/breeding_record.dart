// lib/models/breeding_record.dart
// Padronização: valores persistidos no SQLite são SEMPRE snake_case minúsculos.
// UI usa getters para rótulos. Evita divergência entre DB e apresentação.

enum BreedingStage {
  encabritamento('encabritamento'),
  separacao('separacao'),
  aguardandoUltrassom('aguardando_ultrassom'),
  gestacaoConfirmada('gestacao_confirmada'),
  partoRealizado('parto_realizado'),
  falhou('falhou');

  final String value; // valor que vai para o DB
  const BreedingStage(this.value);

  // Rótulo para abas/contadores
  String get uiTabLabel {
    switch (this) {
      case BreedingStage.encabritamento:     return 'Encabritamento';
      case BreedingStage.separacao:          return 'Separação';
      case BreedingStage.aguardandoUltrassom:return 'Aguardando Ultrassom';
      case BreedingStage.gestacaoConfirmada: return 'Gestantes';
      case BreedingStage.partoRealizado:     return 'Concluídos';
      case BreedingStage.falhou:             return 'Falhados';
    }
  }

  // Compatibilidade com telas antigas
  String get displayName => uiTabLabel;

  // Status legível (se optar por manter status na tabela)
  String get statusLabel {
    switch (this) {
      case BreedingStage.encabritamento:     return 'Cobertura';
      case BreedingStage.separacao:          return 'Separação';
      case BreedingStage.aguardandoUltrassom:return 'Aguardando Ultrassom';
      case BreedingStage.gestacaoConfirmada: return 'Gestação Confirmada';
      case BreedingStage.partoRealizado:     return 'Parto Realizado';
      case BreedingStage.falhou:             return 'Falhou';
    }
  }

  static BreedingStage fromString(String? raw) {
    if (raw == null || raw.isEmpty) return BreedingStage.encabritamento;

    String deaccent(String s) {
      const map = {
        'á':'a','à':'a','ã':'a','â':'a','ä':'a',
        'é':'e','ê':'e','è':'e','ë':'e',
        'í':'i','ì':'i','ï':'i',
        'ó':'o','ô':'o','õ':'o','ò':'o','ö':'o',
        'ú':'u','ù':'u','ü':'u',
        'ç':'c',
        'Á':'A','À':'A','Ã':'A','Â':'A','Ä':'A',
        'É':'E','Ê':'E','È':'E','Ë':'E',
        'Í':'I','Ì':'I','Ï':'I',
        'Ó':'O','Ô':'O','Õ':'O','Ò':'O','Ö':'O',
        'Ú':'U','Ù':'U','Ü':'U',
        'Ç':'C',
      };
      final sb = StringBuffer();
      for (final r in s.runes) {
        final ch = String.fromCharCode(r);
        sb.write(map[ch] ?? ch);
      }
      return sb.toString();
    }

    final v = deaccent(raw).toLowerCase().trim().replaceAll('_', ' ');

    if (v == 'encabritamento') return BreedingStage.encabritamento;
    if (v == 'separacao')      return BreedingStage.separacao;
    if (v == 'aguardando ultrassom') return BreedingStage.aguardandoUltrassom;
    if (v == 'gestacao confirmada' || v == 'gestantes' || v == 'gestante') {
      return BreedingStage.gestacaoConfirmada;
    }
    if (v == 'parto realizado' || v == 'concluido' || v == 'concluidos') {
      return BreedingStage.partoRealizado;
    }
    if (v == 'falhou' || v == 'falhado' || v == 'falhados') {
      return BreedingStage.falhou;
    }

    // tentativa de correspondência direta com valores do enum
    for (final s in BreedingStage.values) {
      if (s.value == raw) return s;
    }
    return BreedingStage.encabritamento;
  }
}

class BreedingRecord {
  final String id;
  final String? femaleAnimalId;
  final String? maleAnimalId;
  final DateTime breedingDate;
  final DateTime? matingStartDate;
  final DateTime? matingEndDate;
  final DateTime? separationDate;
  final DateTime? ultrasoundDate;
  final String? ultrasoundResult;
  final DateTime? expectedBirth;
  final DateTime? birthDate;
  final BreedingStage stage;
  final String status; // pode ser derivado por stage.statusLabel
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BreedingRecord({
    required this.id,
    this.femaleAnimalId,
    this.maleAnimalId,
    required this.breedingDate,
    this.matingStartDate,
    this.matingEndDate,
    this.separationDate,
    this.ultrasoundDate,
    this.ultrasoundResult,
    this.expectedBirth,
    this.birthDate,
    required this.stage,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BreedingRecord.fromMap(Map<String, dynamic> map) {
    DateTime? _parse(dynamic v) {
      if (v == null) return null;
      if (v is String && v.isNotEmpty) {
        try { return DateTime.parse(v); } catch (_) {}
      }
      return null;
    }

    final st = BreedingStage.fromString(map['stage'] as String?);
    final status = (map['status'] as String?) ?? st.statusLabel;

    return BreedingRecord(
      id: (map['id'] as String?) ?? '',
      femaleAnimalId: map['female_animal_id'] as String?,
      maleAnimalId: map['male_animal_id'] as String?,
      breedingDate: _parse(map['breeding_date']) ?? DateTime.now(),
      matingStartDate: _parse(map['mating_start_date']),
      matingEndDate: _parse(map['mating_end_date']),
      separationDate: _parse(map['separation_date']),
      ultrasoundDate: _parse(map['ultrasound_date']),
      ultrasoundResult: map['ultrasound_result'] as String?,
      expectedBirth: _parse(map['expected_birth']),
      birthDate: _parse(map['birth_date']),
      stage: st,
      status: status,
      notes: map['notes'] as String?,
      createdAt: _parse(map['created_at']) ?? DateTime.now(),
      updatedAt: _parse(map['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'female_animal_id': femaleAnimalId,
      'male_animal_id': maleAnimalId,
      'breeding_date': breedingDate.toIso8601String(),
      'mating_start_date': matingStartDate?.toIso8601String(),
      'mating_end_date': matingEndDate?.toIso8601String(),
      'separation_date': separationDate?.toIso8601String(),
      'ultrasound_date': ultrasoundDate?.toIso8601String(),
      'ultrasound_result': ultrasoundResult,
      'expected_birth': expectedBirth?.toIso8601String(),
      'birth_date': birthDate?.toIso8601String(),
      'stage': stage.value,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Dias restantes até o próximo marco, dependendo do estágio atual.
  /// Retorna negativo se já venceu; null quando não aplicável.
  int? daysRemaining() {
    final now = DateTime.now();
    switch (stage) {
      case BreedingStage.encabritamento:
        if (matingEndDate != null) return matingEndDate!.difference(now).inDays;
        return null;
      case BreedingStage.separacao:
      case BreedingStage.aguardandoUltrassom:
        if (ultrasoundDate != null) return ultrasoundDate!.difference(now).inDays;
        return null;
      case BreedingStage.gestacaoConfirmada:
        if (expectedBirth != null) return expectedBirth!.difference(now).inDays;
        return null;
      case BreedingStage.partoRealizado:
      case BreedingStage.falhou:
        return null;
    }
  }

  /// Percentual de progresso no estágio atual (0.0 a 1.0). Se não puder calcular, retorna 0.0.
  double progressPercentage() {
    final now = DateTime.now();

    double clamp01(double v) {
      if (v.isNaN) return 0.0;
      if (v < 0) return 0.0;
      if (v > 1) return 1.0;
      return v;
    }

    double spanProgress(DateTime? start, DateTime? end) {
      if (start == null || end == null) return 0.0;
      final total = end.difference(start).inSeconds;
      if (total <= 0) return 1.0;
      final passed = now.difference(start).inSeconds;
      return clamp01(passed / total);
    }

    switch (stage) {
      case BreedingStage.encabritamento:
        // progresso entre início e fim do acasalamento
        return spanProgress(matingStartDate ?? breedingDate, matingEndDate);
      case BreedingStage.separacao:
        // separação é uma etapa curta; considere como 0 até ultrassom
        return 0.0;
      case BreedingStage.aguardandoUltrassom:
        // entre separação e data de ultrassom
        return spanProgress(separationDate ?? matingEndDate ?? breedingDate, ultrasoundDate);
      case BreedingStage.gestacaoConfirmada:
        // entre ultrassom e parto previsto
        return spanProgress(ultrasoundDate, expectedBirth);
      case BreedingStage.partoRealizado:
      case BreedingStage.falhou:
        return 1.0;
    }
  }

  /// Indica se há ação pendente para o estágio atual (habilita botões).
  bool needsAction() {
    final now = DateTime.now();
    switch (stage) {
      case BreedingStage.encabritamento:
        // habilita "Separar" quando já passou (ou chegou) o fim do acasalamento;
        // se não há fim definido, permita ação (evita travar)
        if (matingEndDate == null) return true;
        return !now.isBefore(matingEndDate!);
      case BreedingStage.aguardandoUltrassom:
      case BreedingStage.separacao:
        // em geral a ação é registrar ultrassom; permita se existe data e já chegou
        if (ultrasoundDate == null) return true;
        return !now.isBefore(ultrasoundDate!);
      case BreedingStage.gestacaoConfirmada:
        // ✅ liberar "Registrar Nascimento" a qualquer momento (pode adiantar)
        return true;
      case BreedingStage.partoRealizado:
      case BreedingStage.falhou:
        return false;
    }
  }

  BreedingRecord copyWith({
    String? id,
    String? femaleAnimalId,
    String? maleAnimalId,
    DateTime? breedingDate,
    DateTime? matingStartDate,
    DateTime? matingEndDate,
    DateTime? separationDate,
    DateTime? ultrasoundDate,
    String? ultrasoundResult,
    DateTime? expectedBirth,
    DateTime? birthDate,
    BreedingStage? stage,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BreedingRecord(
      id: id ?? this.id,
      femaleAnimalId: femaleAnimalId ?? this.femaleAnimalId,
      maleAnimalId: maleAnimalId ?? this.maleAnimalId,
      breedingDate: breedingDate ?? this.breedingDate,
      matingStartDate: matingStartDate ?? this.matingStartDate,
      matingEndDate: matingEndDate ?? this.matingEndDate,
      separationDate: separationDate ?? this.separationDate,
      ultrasoundDate: ultrasoundDate ?? this.ultrasoundDate,
      ultrasoundResult: ultrasoundResult ?? this.ultrasoundResult,
      expectedBirth: expectedBirth ?? this.expectedBirth,
      birthDate: birthDate ?? this.birthDate,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
