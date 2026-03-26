import '../data/matrix_evaluation_repository.dart';
import '../../../models/matrix_candidate_ranking.dart';
import '../../../models/matrix_evaluation.dart';

class MatrixRankingFilters {
  final String? species;
  final String? category;
  final String? reproductiveStatus;
  final String? lote;
  final double? minScore;
  final bool onlyFemales;
  final int limit;
  final int offset;

  const MatrixRankingFilters({
    this.species,
    this.category,
    this.reproductiveStatus,
    this.lote,
    this.minScore,
    this.onlyFemales = true,
    this.limit = 100,
    this.offset = 0,
  });
}

class MatrixSelectionService {
  final MatrixEvaluationRepository _repository;

  const MatrixSelectionService(this._repository);

  String _normalizeManualRecommendation(String recommendation) {
    final normalized = recommendation.trim().toLowerCase();
    if (normalized == 'aprovada' || normalized == 'aprovar') return 'Aprovar';
    if (normalized == 'observação' ||
        normalized == 'observacao' ||
        normalized == 'observar') {
      return 'Observar';
    }
    if (normalized == 'descartar') return 'Descartar';
    return recommendation.trim();
  }

  double _clamp10(double value) => value.clamp(0, 10).toDouble();

  double _hoofConditionScore(String value) {
    switch (value.trim().toLowerCase()) {
      case 'sem problema':
        return 10;
      case 'leve':
        return 7;
      case 'moderado':
        return 4;
      case 'severo':
        return 1;
      default:
        return 6;
    }
  }

  double _verminosisScore(String value) {
    switch (value.trim().toLowerCase()) {
      case 'nenhuma':
        return 10;
      case 'leve':
        return 7;
      case 'moderada':
        return 4;
      case 'severa':
        return 1;
      default:
        return 6;
    }
  }

  double _twinningScore(String value) {
    switch (value.trim().toLowerCase()) {
      case 'parto múltiplo':
      case 'parto multiplo':
        return 10;
      case 'parto gemelar':
        return 8;
      case 'parto simples':
        return 6;
      case 'sem histórico':
        return 5;
      default:
        return 5;
    }
  }

  double _weightPerformanceScore(double? lambingWeight, double? weaningWeight) {
    if (lambingWeight == null ||
        weaningWeight == null ||
        lambingWeight <= 0 ||
        weaningWeight <= 0) {
      return 6;
    }
    final ratio = weaningWeight / lambingWeight;
    if (ratio >= 3.0) return 10;
    if (ratio >= 2.5) return 8;
    if (ratio >= 2.0) return 6;
    if (ratio >= 1.5) return 4;
    return 2;
  }

  double deriveHealthScore({
    required String hoofCondition,
    required String verminosisLevel,
    required double bodyConditionScore,
    required double dentitionScore,
  }) {
    final hoof = _hoofConditionScore(hoofCondition);
    final verminosis = _verminosisScore(verminosisLevel);
    final bodyCondition = _clamp10(bodyConditionScore * 2);
    final dentition = _clamp10(dentitionScore);
    return _clamp10((hoof + verminosis + bodyCondition + dentition) / 4);
  }

  double deriveGrowthScore({
    required String twinningHistory,
    required double lactationScore,
    double? lambingWeight,
    double? weaningWeight,
  }) {
    final twinning = _twinningScore(twinningHistory);
    final lactation = _clamp10(lactationScore);
    final weights = _weightPerformanceScore(lambingWeight, weaningWeight);
    return _clamp10((twinning + lactation + weights) / 3);
  }

  double calculateFinalScore({
    required double fertilityScore,
    required double maternalScore,
    required double healthScore,
    required double temperamentScore,
    required double growthScore,
  }) {
    const fertilityWeight = 0.25;
    const maternalWeight = 0.25;
    const healthWeight = 0.20;
    const temperamentWeight = 0.15;
    const growthWeight = 0.15;

    final value = (fertilityScore * fertilityWeight) +
        (maternalScore * maternalWeight) +
        (healthScore * healthWeight) +
        (temperamentScore * temperamentWeight) +
        (growthScore * growthWeight);
    return value.clamp(0, 10).toDouble();
  }

  String suggestRecommendation({
    required double finalScore,
    required String hoofCondition,
    required String verminosisLevel,
    required double fertilityScore,
    required double maternalScore,
    required double bodyConditionScore,
    required double dentitionScore,
  }) {
    final hoof = hoofCondition.trim().toLowerCase();
    final verminosis = verminosisLevel.trim().toLowerCase();

    // Regras duras de descarte (sanidade e fertilidade críticas)
    if (hoof == 'severo' ||
        verminosis == 'severa' ||
        fertilityScore < 4.0 ||
        maternalScore < 4.0) {
      return 'Descartar';
    }

    final hasModerateRisk = hoof == 'moderado' ||
        verminosis == 'moderada' ||
        bodyConditionScore < 2.5 ||
        dentitionScore < 5.0;

    if (finalScore >= 8.0 && !hasModerateRisk) return 'Aprovar';
    if (finalScore >= 6.0 || hasModerateRisk) return 'Observar';
    return 'Descartar';
  }

  Future<MatrixEvaluation> saveEvaluation({
    String? id,
    required String animalId,
    DateTime? evaluationDate,
    required double fertilityScore,
    required double maternalScore,
    required String hoofCondition,
    required String verminosisLevel,
    required String twinningHistory,
    required double lactationScore,
    required double bodyConditionScore,
    required double dentitionScore,
    double? lambingWeight,
    double? weaningWeight,
    int? ageMonths,
    double temperamentScore = 7.0,
    String? recommendation,
    String? notes,
  }) async {
    final now = DateTime.now();
    final healthScore = deriveHealthScore(
      hoofCondition: hoofCondition,
      verminosisLevel: verminosisLevel,
      bodyConditionScore: bodyConditionScore,
      dentitionScore: dentitionScore,
    );
    final growthScore = deriveGrowthScore(
      twinningHistory: twinningHistory,
      lactationScore: lactationScore,
      lambingWeight: lambingWeight,
      weaningWeight: weaningWeight,
    );
    final score = calculateFinalScore(
      fertilityScore: fertilityScore,
      maternalScore: maternalScore,
      healthScore: healthScore,
      temperamentScore: temperamentScore,
      growthScore: growthScore,
    );
    final rec = (recommendation == null || recommendation.trim().isEmpty)
        ? suggestRecommendation(
            finalScore: score,
            hoofCondition: hoofCondition,
            verminosisLevel: verminosisLevel,
            fertilityScore: fertilityScore,
            maternalScore: maternalScore,
            bodyConditionScore: bodyConditionScore,
            dentitionScore: dentitionScore,
          )
        : _normalizeManualRecommendation(recommendation);

    final evaluation = MatrixEvaluation(
      id: (id == null || id.trim().isEmpty)
          ? _newId()
          : id.trim(),
      animalId: animalId,
      evaluationDate: evaluationDate ?? now,
      fertilityScore: fertilityScore,
      maternalScore: maternalScore,
      healthScore: healthScore,
      temperamentScore: temperamentScore,
      growthScore: growthScore,
      hoofCondition: hoofCondition,
      verminosisLevel: verminosisLevel,
      twinningHistory: twinningHistory,
      lambingWeight: lambingWeight,
      weaningWeight: weaningWeight,
      lactationScore: lactationScore,
      bodyConditionScore: bodyConditionScore,
      dentitionScore: dentitionScore,
      ageMonths: ageMonths,
      finalScore: score,
      recommendation: rec,
      notes: (notes == null || notes.trim().isEmpty) ? null : notes.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _repository.upsertEvaluation(evaluation);
    return evaluation;
  }

  Future<MatrixEvaluation?> getLatestEvaluationByAnimal(String animalId) {
    return _repository.getLatestEvaluationByAnimal(animalId);
  }

  Future<List<MatrixEvaluation>> getEvaluationsByAnimal(
    String animalId, {
    int limit = 30,
    int offset = 0,
  }) {
    return _repository.getEvaluationsByAnimal(
      animalId,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<MatrixCandidateRanking>> getRanking({
    MatrixRankingFilters filters = const MatrixRankingFilters(),
  }) {
    return _repository.getLatestRanking(
      species: filters.species,
      category: filters.category,
      reproductiveStatus: filters.reproductiveStatus,
      lote: filters.lote,
      minScore: filters.minScore,
      onlyFemales: filters.onlyFemales,
      limit: filters.limit,
      offset: filters.offset,
    );
  }

  Future<void> deleteEvaluation(String id) {
    return _repository.deleteEvaluation(id);
  }

  String _newId() => 'me_${DateTime.now().microsecondsSinceEpoch}';
}
