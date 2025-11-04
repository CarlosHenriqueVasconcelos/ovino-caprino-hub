import 'package:flutter/foundation.dart';
import '../data/feeding_repository.dart';
import '../models/feeding_pen.dart';
import '../models/feeding_schedule.dart';

/// Service para gerenciar lógica de alimentação (baias e tratos)
class FeedingService extends ChangeNotifier {
  final FeedingRepository _repository;

  List<FeedingPen> _pens = [];
  Map<String, List<FeedingSchedule>> _schedulesByPen = {};
  bool _isLoading = false;
  String? _error;

  FeedingService(this._repository);

  // Getters
  List<FeedingPen> get pens => List.unmodifiable(_pens);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Retorna tratos de uma baia específica
  List<FeedingSchedule> getSchedulesForPen(String penId) {
    return _schedulesByPen[penId] ?? [];
  }

  /// Carrega todas as baias
  Future<void> loadPens() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pens = await _repository.getAllPens();
      
      // Carregar schedules para cada baia
      for (final pen in _pens) {
        _schedulesByPen[pen.id] = await _repository.getSchedulesByPenId(pen.id);
      }
    } catch (e) {
      _error = 'Erro ao carregar baias: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona uma nova baia
  Future<void> addPen(FeedingPen pen) async {
    try {
      await _repository.insertPen(pen);
      await loadPens();
    } catch (e) {
      _error = 'Erro ao adicionar baia: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  /// Atualiza uma baia existente
  Future<void> updatePen(FeedingPen pen) async {
    try {
      await _repository.updatePen(pen);
      await loadPens();
    } catch (e) {
      _error = 'Erro ao atualizar baia: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  /// Deleta uma baia
  Future<void> deletePen(String penId) async {
    try {
      await _repository.deletePen(penId);
      await loadPens();
    } catch (e) {
      _error = 'Erro ao deletar baia: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  /// Adiciona um novo trato a uma baia
  Future<void> addSchedule(FeedingSchedule schedule) async {
    try {
      await _repository.insertSchedule(schedule);
      
      // Recarregar schedules da baia específica
      _schedulesByPen[schedule.penId] = 
          await _repository.getSchedulesByPenId(schedule.penId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao adicionar trato: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  /// Atualiza um trato existente
  Future<void> updateSchedule(FeedingSchedule schedule) async {
    try {
      await _repository.updateSchedule(schedule);
      
      // Recarregar schedules da baia específica
      _schedulesByPen[schedule.penId] = 
          await _repository.getSchedulesByPenId(schedule.penId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao atualizar trato: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  /// Deleta um trato
  Future<void> deleteSchedule(String scheduleId, String penId) async {
    try {
      await _repository.deleteSchedule(scheduleId);
      
      // Recarregar schedules da baia específica
      _schedulesByPen[penId] = 
          await _repository.getSchedulesByPenId(penId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao deletar trato: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  /// Retorna uma baia por ID
  FeedingPen? getPenById(String id) {
    try {
      return _pens.firstWhere((pen) => pen.id == id);
    } catch (e) {
      return null;
    }
  }
}
