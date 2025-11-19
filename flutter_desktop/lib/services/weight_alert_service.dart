import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/weight_alert_repository.dart';
import '../models/animal.dart';
import '../models/weight_alert.dart';

class WeightAlertService extends ChangeNotifier {
  final WeightAlertRepository _repository;

  final List<WeightAlert> _pendingAlerts = [];
  bool _isLoadingPending = false;
  bool _hasLoadedPending = false;
  int _lastHorizonDays = 30;
  bool _pendingReloadQueued = false;

  WeightAlertService(this._repository);

  UnmodifiableListView<WeightAlert> get pendingAlerts =>
      UnmodifiableListView(_pendingAlerts);
  bool get isLoadingPending => _isLoadingPending;
  bool get hasLoadedPending => _hasLoadedPending;

  /// Cria alertas de pesagem para borregos (30, 60, 90, 120 dias após nascimento)
  Future<void> createLambWeightAlerts(Animal animal) async {
    if (!animal.category.toLowerCase().contains('borrego')) return;

    final birthDate = animal.birthDate;
    final animalId = animal.id;

    final now = DateTime.now();

    // Cria alertas para 30, 60, 90 e 120 dias
    final alerts = [
      WeightAlert(
        id: 'wa_${animalId}_30d',
        animalId: animalId,
        alertType: '30d',
        dueDate: birthDate.add(const Duration(days: 30)),
        completed: false,
        createdAt: now,
      ),
      WeightAlert(
        id: 'wa_${animalId}_60d',
        animalId: animalId,
        alertType: '60d',
        dueDate: birthDate.add(const Duration(days: 60)),
        completed: false,
        createdAt: now,
      ),
      WeightAlert(
        id: 'wa_${animalId}_90d',
        animalId: animalId,
        alertType: '90d',
        dueDate: birthDate.add(const Duration(days: 90)),
        completed: false,
        createdAt: now,
      ),
      WeightAlert(
        id: 'wa_${animalId}_120d',
        animalId: animalId,
        alertType: '120d',
        dueDate: birthDate.add(const Duration(days: 120)),
        completed: false,
        createdAt: now,
      ),
    ];

    await _repository.replaceAlerts(animalId, alerts);

    debugPrint('Criados alertas de pesagem para borrego ${animal.name}');
    await _refreshPendingCache();
    notifyListeners();
  }

  /// Cria próximo alerta mensal para animais adultos
  Future<void> createNextMonthlyAlert(String animalId) async {
    // Verifica quantos alertas mensais já existem
    final existingCount = await _repository.countMonthlyAlerts(animalId);

    if (existingCount >= 5) {
      debugPrint('Limite de 5 alertas mensais atingido para $animalId');
      return;
    }

    // Cria próximo alerta mensal (30 dias a partir de hoje)
    final nextAlert = WeightAlert(
      id: 'wa_${animalId}_monthly_${existingCount + 1}',
      animalId: animalId,
      alertType: 'monthly',
      dueDate: DateTime.now().add(const Duration(days: 30)),
      completed: false,
      createdAt: DateTime.now(),
    );

    await _repository.insertAlert(nextAlert);
    debugPrint('Criado alerta mensal para $animalId');
    await _refreshPendingCache();
    notifyListeners();
  }

  /// NOVO: usado pelo AnimalService para montar o painel de alertas:
  /// retorna as linhas cruas da tabela `weight_alerts` (Map),
  /// não só os modelos [WeightAlert].
  Future<List<Map<String, dynamic>>> getPendingWeightAlerts(
    DateTime horizon,
  ) async {
    try {
      return await _repository.getPendingRaw(horizon);
    } catch (e) {
      debugPrint('Erro ao buscar weight alerts pendentes: $e');
      return [];
    }
  }

  /// Marca alerta como completo
  Future<void> completeAlert(String alertId) async {
    await _repository.markCompleted(alertId);
    await _refreshPendingCache();
    notifyListeners();
  }

  /// Busca alertas pendentes (não completados e dentro do horizonte)
  Future<List<WeightAlert>> getPendingAlerts({int horizonDays = 30}) async {
    await loadPending(horizonDays: horizonDays);
    return List<WeightAlert>.unmodifiable(_pendingAlerts);
  }

  /// Busca alertas de um animal específico
  Future<List<WeightAlert>> getAnimalAlerts(String animalId) async {
    return _repository.getAnimalAlerts(animalId);
  }

  /// Remove todos os alertas de um animal
  Future<void> deleteAnimalAlerts(String animalId) async {
    await _repository.deleteAnimalAlerts(animalId);
    await _refreshPendingCache();
    notifyListeners();
  }

  Future<void> loadPending({int? horizonDays}) async {
    final target = horizonDays ?? _lastHorizonDays;
    _lastHorizonDays = target;
    if (_isLoadingPending) {
      _pendingReloadQueued = true;
      return;
    }
    _isLoadingPending = true;
    notifyListeners();
    try {
      final data = await _repository.getPendingAlerts(target);
      _pendingAlerts
        ..clear()
        ..addAll(data);
      _hasLoadedPending = true;
    } catch (e) {
      debugPrint('Erro ao carregar alertas de pesagem: $e');
    } finally {
      _isLoadingPending = false;
      notifyListeners();
      if (_pendingReloadQueued) {
        _pendingReloadQueued = false;
        await loadPending(horizonDays: _lastHorizonDays);
      }
    }
  }

  Future<void> _refreshPendingCache() async {
    if (!_hasLoadedPending) return;
    await loadPending(horizonDays: _lastHorizonDays);
  }
}
