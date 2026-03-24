class MatrixCandidateRanking {
  final String animalId;
  final String name;
  final String code;
  final String species;
  final String category;
  final String reproductiveStatus;
  final String gender;
  final String? lote;
  final String? nameColor;
  final DateTime evaluationDate;
  final double finalScore;
  final String recommendation;
  final String? notes;
  final String hoofCondition;
  final String verminosisLevel;
  final String twinningHistory;
  final double? lambingWeight;
  final double? weaningWeight;
  final double lactationScore;
  final double bodyConditionScore;
  final double dentitionScore;
  final int? ageMonths;

  const MatrixCandidateRanking({
    required this.animalId,
    required this.name,
    required this.code,
    required this.species,
    required this.category,
    required this.reproductiveStatus,
    required this.gender,
    this.lote,
    this.nameColor,
    required this.evaluationDate,
    required this.finalScore,
    required this.recommendation,
    this.notes,
    this.hoofCondition = 'Sem problema',
    this.verminosisLevel = 'Nenhuma',
    this.twinningHistory = 'Sem histórico',
    this.lambingWeight,
    this.weaningWeight,
    this.lactationScore = 7,
    this.bodyConditionScore = 3,
    this.dentitionScore = 7,
    this.ageMonths,
  });

  factory MatrixCandidateRanking.fromMap(Map<String, dynamic> map) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    DateTime toDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return MatrixCandidateRanking(
      animalId: map['animal_id']?.toString() ?? '',
      name: map['animal_name']?.toString() ?? '',
      code: map['animal_code']?.toString() ?? '',
      species: map['animal_species']?.toString() ?? '',
      category: map['animal_category']?.toString() ?? '',
      reproductiveStatus: map['reproductive_status']?.toString() ?? 'Não aplicável',
      gender: map['animal_gender']?.toString() ?? '',
      lote: map['animal_lote']?.toString(),
      nameColor: map['animal_name_color']?.toString(),
      evaluationDate: toDate(map['evaluation_date']),
      finalScore: toDouble(map['final_score']),
      recommendation: map['recommendation']?.toString() ?? 'Observação',
      notes: map['notes']?.toString(),
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
          ? 7
          : toDouble(map['lactation_score']),
      bodyConditionScore: map['body_condition_score'] == null
          ? 3
          : toDouble(map['body_condition_score']),
      dentitionScore: map['dentition_score'] == null
          ? 7
          : toDouble(map['dentition_score']),
      ageMonths: map['age_months'] is int
          ? map['age_months'] as int
          : int.tryParse(map['age_months']?.toString() ?? ''),
    );
  }
}
