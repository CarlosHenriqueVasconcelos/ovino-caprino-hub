class MatrixEvaluation {
  final String id;
  final String animalId;
  final DateTime evaluationDate;
  final double fertilityScore;
  final double maternalScore;
  final double healthScore;
  final double temperamentScore;
  final double growthScore;
  final String hoofCondition;
  final String verminosisLevel;
  final String twinningHistory;
  final double? lambingWeight;
  final double? weaningWeight;
  final double lactationScore;
  final double bodyConditionScore;
  final double dentitionScore;
  final int? ageMonths;
  final double finalScore;
  final String recommendation;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MatrixEvaluation({
    required this.id,
    required this.animalId,
    required this.evaluationDate,
    required this.fertilityScore,
    required this.maternalScore,
    required this.healthScore,
    required this.temperamentScore,
    required this.growthScore,
    this.hoofCondition = 'Sem problema',
    this.verminosisLevel = 'Nenhuma',
    this.twinningHistory = 'Sem histórico',
    this.lambingWeight,
    this.weaningWeight,
    this.lactationScore = 7.0,
    this.bodyConditionScore = 3.0,
    this.dentitionScore = 7.0,
    this.ageMonths,
    required this.finalScore,
    required this.recommendation,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatrixEvaluation.fromMap(Map<String, dynamic> map) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is DateTime) return value;
      final parsed = DateTime.tryParse(value.toString());
      return parsed ?? fallback;
    }

    final now = DateTime.now();
    return MatrixEvaluation(
      id: map['id']?.toString() ?? '',
      animalId: map['animal_id']?.toString() ?? '',
      evaluationDate: parseDate(map['evaluation_date'], now),
      fertilityScore: toDouble(map['fertility_score']),
      maternalScore: toDouble(map['maternal_score']),
      healthScore: toDouble(map['health_score']),
      temperamentScore: toDouble(map['temperament_score']),
      growthScore: toDouble(map['growth_score']),
      hoofCondition: map['hoof_condition']?.toString() ?? 'Sem problema',
      verminosisLevel: map['verminosis_level']?.toString() ?? 'Nenhuma',
      twinningHistory: map['twinning_history']?.toString() ?? 'Sem histórico',
      lambingWeight: map['lambing_weight'] == null
          ? null
          : toDouble(map['lambing_weight']),
      weaningWeight: map['weaning_weight'] == null
          ? null
          : toDouble(map['weaning_weight']),
      lactationScore: map['lactation_score'] == null
          ? 7.0
          : toDouble(map['lactation_score']),
      bodyConditionScore: map['body_condition_score'] == null
          ? 3.0
          : toDouble(map['body_condition_score']),
      dentitionScore: map['dentition_score'] == null
          ? 7.0
          : toDouble(map['dentition_score']),
      ageMonths: map['age_months'] is int
          ? map['age_months'] as int
          : int.tryParse(map['age_months']?.toString() ?? ''),
      finalScore: toDouble(map['final_score']),
      recommendation: map['recommendation']?.toString() ?? 'Observar',
      notes: map['notes']?.toString(),
      createdAt: parseDate(map['created_at'], now),
      updatedAt: parseDate(map['updated_at'], now),
    );
  }

  Map<String, dynamic> toMap() {
    String dateOnly(DateTime value) => value.toIso8601String().split('T').first;
    return {
      'id': id,
      'animal_id': animalId,
      'evaluation_date': dateOnly(evaluationDate),
      'fertility_score': fertilityScore,
      'maternal_score': maternalScore,
      'health_score': healthScore,
      'temperament_score': temperamentScore,
      'growth_score': growthScore,
      'hoof_condition': hoofCondition,
      'verminosis_level': verminosisLevel,
      'twinning_history': twinningHistory,
      'lambing_weight': lambingWeight,
      'weaning_weight': weaningWeight,
      'lactation_score': lactationScore,
      'body_condition_score': bodyConditionScore,
      'dentition_score': dentitionScore,
      'age_months': ageMonths,
      'final_score': finalScore,
      'recommendation': recommendation,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MatrixEvaluation copyWith({
    String? id,
    String? animalId,
    DateTime? evaluationDate,
    double? fertilityScore,
    double? maternalScore,
    double? healthScore,
    double? temperamentScore,
    double? growthScore,
    String? hoofCondition,
    String? verminosisLevel,
    String? twinningHistory,
    double? lambingWeight,
    double? weaningWeight,
    double? lactationScore,
    double? bodyConditionScore,
    double? dentitionScore,
    int? ageMonths,
    double? finalScore,
    String? recommendation,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MatrixEvaluation(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      fertilityScore: fertilityScore ?? this.fertilityScore,
      maternalScore: maternalScore ?? this.maternalScore,
      healthScore: healthScore ?? this.healthScore,
      temperamentScore: temperamentScore ?? this.temperamentScore,
      growthScore: growthScore ?? this.growthScore,
      hoofCondition: hoofCondition ?? this.hoofCondition,
      verminosisLevel: verminosisLevel ?? this.verminosisLevel,
      twinningHistory: twinningHistory ?? this.twinningHistory,
      lambingWeight: lambingWeight ?? this.lambingWeight,
      weaningWeight: weaningWeight ?? this.weaningWeight,
      lactationScore: lactationScore ?? this.lactationScore,
      bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
      dentitionScore: dentitionScore ?? this.dentitionScore,
      ageMonths: ageMonths ?? this.ageMonths,
      finalScore: finalScore ?? this.finalScore,
      recommendation: recommendation ?? this.recommendation,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
