import 'package:flutter/foundation.dart';
import '../data/animal_repository.dart';
import 'events/event_bus.dart';
import 'events/app_events.dart';

/// Service para gerenciar registros de peso dos animais
class WeightService extends ChangeNotifier {
  final AnimalRepository _repository;

  WeightService(this._repository);

  /// Busca peso de 120 dias de um borrego
  Future<double?> getWeight120Days(String animalId) async {
    final weights = await _repository.getWeightRecord(animalId, '120d');
    return weights.isNotEmpty ? weights.first['weight'] as double : null;
  }

  /// Busca todos os pesos mensais de um animal adulto
  Future<List<Map<String, dynamic>>> getMonthlyWeights(String animalId) async {
    return await _repository.getMonthlyWeights(animalId);
  }

  /// Adiciona um novo registro de peso
  Future<void> addWeight(
    String animalId,
    DateTime date,
    double weight, {
    String? milestone,
  }) async {
    await _repository.addWeight(animalId, date, weight, milestone: milestone);
    
    EventBus().emit(WeightAddedEvent(
      animalId: animalId,
      weight: weight,
      date: date,
      milestone: milestone,
    ));
    
    notifyListeners();
  }

  /// Busca histórico completo de pesos de um animal
  Future<List<Map<String, dynamic>>> getWeightHistory(String animalId) async {
    return await _repository.getWeightHistory(animalId);
  }

  /// Busca registros de peso por milestone específico
  Future<List<Map<String, dynamic>>> getWeightRecord(
    String animalId,
    String milestone,
  ) async {
    return await _repository.getWeightRecord(animalId, milestone);
  }
}
