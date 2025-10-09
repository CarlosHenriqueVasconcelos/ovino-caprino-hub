enum BreedingStage {
  encabritamento('Encabritamento'),
  separacao('Separacao'),
  aguardandoUltrassom('Aguardando_Ultrassom'),
  gestacaoConfirmada('Gestacao_Confirmada'),
  partoRealizado('Parto_Realizado'),
  falhou('Falhou');

  final String value;
  const BreedingStage(this.value);

  static BreedingStage fromString(String value) {
    return BreedingStage.values.firstWhere(
      (stage) => stage.value == value,
      orElse: () => BreedingStage.encabritamento,
    );
  }

  String get displayName {
    switch (this) {
      case BreedingStage.encabritamento:
        return 'Encabritamento';
      case BreedingStage.separacao:
        return 'Separação';
      case BreedingStage.aguardandoUltrassom:
        return 'Aguardando Ultrassom';
      case BreedingStage.gestacaoConfirmada:
        return 'Gestação Confirmada';
      case BreedingStage.partoRealizado:
        return 'Parto Realizado';
      case BreedingStage.falhou:
        return 'Falhou';
    }
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
  final String status;
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
    return BreedingRecord(
      id: map['id'] as String,
      femaleAnimalId: map['female_animal_id'] as String?,
      maleAnimalId: map['male_animal_id'] as String?,
      breedingDate: DateTime.parse(map['breeding_date'] as String),
      matingStartDate: map['mating_start_date'] != null
          ? DateTime.parse(map['mating_start_date'] as String)
          : null,
      matingEndDate: map['mating_end_date'] != null
          ? DateTime.parse(map['mating_end_date'] as String)
          : null,
      separationDate: map['separation_date'] != null
          ? DateTime.parse(map['separation_date'] as String)
          : null,
      ultrasoundDate: map['ultrasound_date'] != null
          ? DateTime.parse(map['ultrasound_date'] as String)
          : null,
      ultrasoundResult: map['ultrasound_result'] as String?,
      expectedBirth: map['expected_birth'] != null
          ? DateTime.parse(map['expected_birth'] as String)
          : null,
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'] as String)
          : null,
      stage: BreedingStage.fromString(map['stage'] as String? ?? 'Encabritamento'),
      status: map['status'] as String? ?? 'Cobertura',
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
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

  // Calculate days remaining in current stage
  int? daysRemaining() {
    final now = DateTime.now();
    switch (stage) {
      case BreedingStage.encabritamento:
        if (matingEndDate != null) {
          return matingEndDate!.difference(now).inDays;
        }
        return null;
      case BreedingStage.aguardandoUltrassom:
        if (separationDate != null) {
          final ultrasoundDue = separationDate!.add(const Duration(days: 30));
          return ultrasoundDue.difference(now).inDays;
        }
        return null;
      case BreedingStage.gestacaoConfirmada:
        if (expectedBirth != null) {
          return expectedBirth!.difference(now).inDays;
        }
        return null;
      default:
        return null;
    }
  }

  // Calculate progress percentage for current stage
  double? progressPercentage() {
    final now = DateTime.now();
    switch (stage) {
      case BreedingStage.encabritamento:
        if (matingStartDate != null && matingEndDate != null) {
          final total = matingEndDate!.difference(matingStartDate!).inDays;
          final elapsed = now.difference(matingStartDate!).inDays;
          return (elapsed / total).clamp(0.0, 1.0);
        }
        return null;
      case BreedingStage.aguardandoUltrassom:
        if (separationDate != null) {
          final ultrasoundDue = separationDate!.add(const Duration(days: 30));
          final total = ultrasoundDue.difference(separationDate!).inDays;
          final elapsed = now.difference(separationDate!).inDays;
          return (elapsed / total).clamp(0.0, 1.0);
        }
        return null;
      case BreedingStage.gestacaoConfirmada:
        if (ultrasoundDate != null && expectedBirth != null) {
          final total = expectedBirth!.difference(ultrasoundDate!).inDays;
          final elapsed = now.difference(ultrasoundDate!).inDays;
          return (elapsed / total).clamp(0.0, 1.0);
        }
        return null;
      default:
        return null;
    }
  }

  // Check if action is needed
  bool needsAction() {
    final daysLeft = daysRemaining();
    if (daysLeft == null) return false;
    return daysLeft <= 0;
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
