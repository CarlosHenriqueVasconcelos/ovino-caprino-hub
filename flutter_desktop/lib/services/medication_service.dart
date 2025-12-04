import 'package:flutter/foundation.dart';
import '../data/medication_repository.dart';
import 'events/event_bus.dart';
import 'events/app_events.dart';

/// Service para gerenciar medicações
class MedicationService extends ChangeNotifier {
  final MedicationRepository _repository;

  MedicationService(this._repository);

  /// Retorna todas as medicações
  Future<List<Map<String, dynamic>>> getMedications({
    int? limit,
    int? offset,
  }) async {
    try {
      return await _repository.getAll(limit: limit, offset: offset);
    } catch (e) {
      debugPrint('Erro ao buscar medicações: $e');
      return [];
    }
  }

  /// Retorna uma medicação por ID
  Future<Map<String, dynamic>?> getMedicationById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e) {
      debugPrint('Erro ao buscar medicação: $e');
      return null;
    }
  }

  /// Retorna medicações de um animal específico
  Future<List<Map<String, dynamic>>> getMedicationsByAnimalId(
      String animalId) async {
    try {
      return await _repository.getByAnimalId(animalId);
    } catch (e) {
      debugPrint('Erro ao buscar medicações do animal: $e');
      return [];
    }
  }

  /// Retorna medicações agendadas
  Future<List<Map<String, dynamic>>> getScheduledMedications() async {
    try {
      return await _repository.getScheduled();
    } catch (e) {
      debugPrint('Erro ao buscar medicações agendadas: $e');
      return [];
    }
  }

  /// Retorna medicações por status
  Future<List<Map<String, dynamic>>> getMedicationsByStatus(
      String status) async {
    try {
      return await _repository.getByStatus(status);
    } catch (e) {
      debugPrint('Erro ao buscar medicações por status: $e');
      return [];
    }
  }

  /// Retorna medicações vencidas (atrasadas)
  Future<List<Map<String, dynamic>>> getOverdueMedications() async {
    try {
      return await _repository.getOverdue();
    } catch (e) {
      debugPrint('Erro ao buscar medicações vencidas: $e');
      return [];
    }
  }

  /// Retorna medicações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcomingMedications(
      int daysThreshold) async {
    try {
      return await _repository.getUpcoming(daysThreshold);
    } catch (e) {
      debugPrint('Erro ao buscar medicações próximas: $e');
      return [];
    }
  }

  /// Retorna medicações com informações do animal
  Future<List<Map<String, dynamic>>> getMedicationsWithAnimalInfo({
    MedicationQueryOptions options = const MedicationQueryOptions(),
  }) async {
    try {
      return await _repository.getAllWithAnimalInfo(
        species: options.species,
        category: options.category,
        searchTerm: options.searchTerm,
        startDate: options.startDate,
        endDate: options.endDate,
        limit: options.limit,
        offset: options.offset,
      );
    } catch (e) {
      debugPrint('Erro ao buscar medicações com info do animal: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOverdueMedicationsWithAnimalInfo({
    MedicationQueryOptions options = const MedicationQueryOptions(),
  }) async {
    try {
      return await _repository.getOverdueWithAnimalInfo(
        species: options.species,
        category: options.category,
        searchTerm: options.searchTerm,
        startDate: options.startDate,
        endDate: options.endDate,
        limit: options.limit,
        offset: options.offset,
      );
    } catch (e) {
      debugPrint('Erro ao buscar medicações atrasadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getScheduledMedicationsWithAnimalInfo({
    MedicationQueryOptions options = const MedicationQueryOptions(),
  }) async {
    try {
      return await _repository.getScheduledWithAnimalInfo(
        species: options.species,
        category: options.category,
        searchTerm: options.searchTerm,
        startDate: options.startDate,
        endDate: options.endDate,
        limit: options.limit,
        offset: options.offset,
      );
    } catch (e) {
      debugPrint('Erro ao buscar medicações agendadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAppliedMedicationsWithAnimalInfo({
    MedicationQueryOptions options = const MedicationQueryOptions(),
  }) async {
    try {
      return await _repository.getAppliedWithAnimalInfo(
        species: options.species,
        category: options.category,
        searchTerm: options.searchTerm,
        startDate: options.startDate,
        endDate: options.endDate,
        limit: options.limit,
        offset: options.offset,
      );
    } catch (e) {
      debugPrint('Erro ao buscar medicações aplicadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCancelledMedicationsWithAnimalInfo({
    MedicationQueryOptions options = const MedicationQueryOptions(),
  }) async {
    try {
      return await _repository.getCancelledWithAnimalInfo(
        species: options.species,
        category: options.category,
        searchTerm: options.searchTerm,
        startDate: options.startDate,
        endDate: options.endDate,
        limit: options.limit,
        offset: options.offset,
      );
    } catch (e) {
      debugPrint('Erro ao buscar medicações canceladas com info: $e');
      return [];
    }
  }

  /// Usado pelo AnimalService para montar o painel de alertas:
  /// retorna todas as medicações pendentes (não aplicadas/canceladas)
  /// com `next_date` até o [horizon] (inclui vencidas + próximas).
  Future<List<Map<String, dynamic>>> getPendingMedications(
    DateTime horizon,
  ) async {
    try {
      final now = DateTime.now();

      // Se o horizonte já passou, só faz sentido olhar atrasados
      if (!horizon.isAfter(now)) {
        return await _repository.getOverdue();
      }

      // Quantos dias pra frente vamos considerar "próximas"
      final daysThreshold = horizon.difference(now).inDays;

      // Vencidas
      final overdue = await _repository.getOverdue();

      // Próximas até o horizonte
      final upcoming = await _repository.getUpcoming(daysThreshold);

      // Em teoria, overdue e upcoming não se sobrepõem
      // (overdue < hoje, upcoming >= hoje), então podemos só concatenar.
      // Se quiser garantir, daria pra remover duplicados por 'id'.
      return [...overdue, ...upcoming];
    } catch (e) {
      debugPrint('Erro ao buscar medicações pendentes: $e');
      return [];
    }
  }

  /// Cria uma nova medicação
  Future<void> createMedication(Map<String, dynamic> medication) async {
    try {
      final m = Map<String, dynamic>.from(medication);

      // Normalizar datas
      m['date'] = _toIsoDate(m['date']);
      m['next_date'] = _toIsoDate(m['next_date']);
      m['applied_date'] = _toIsoDate(m['applied_date']);
      m['created_at'] ??= DateTime.now().toIso8601String();
      m['updated_at'] = DateTime.now().toIso8601String();

      // Inserir no banco local
      await _repository.insert(m);

      EventBus().emit(MedicationCreatedEvent(
        medicationId: m['id']?.toString() ?? '',
        animalId: m['animal_id']?.toString() ?? '',
        medicationName: m['medication_name']?.toString() ?? '',
      ));

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao criar medicação: $e');
      rethrow;
    }
  }

  /// Atualiza uma medicação
  Future<void> updateMedication(String id, Map<String, dynamic> updates) async {
    try {
      final m = Map<String, dynamic>.from(updates);

      // Normalizar datas
      if (m.containsKey('date')) {
        m['date'] = _toIsoDate(m['date']);
      }
      if (m.containsKey('next_date')) {
        m['next_date'] = _toIsoDate(m['next_date']);
      }
      if (m.containsKey('applied_date')) {
        m['applied_date'] = _toIsoDate(m['applied_date']);
      }
      m['updated_at'] = DateTime.now().toIso8601String();

      // Atualizar no banco local
      await _repository.update(id, m);

      EventBus().emit(MedicationUpdatedEvent(
        medicationId: id,
        animalId: m['animal_id']?.toString() ?? '',
        status: m['status']?.toString() ?? '',
      ));

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar medicação: $e');
      rethrow;
    }
  }

  /// Deleta uma medicação
  Future<void> deleteMedication(String id) async {
    try {
      // Buscar dados antes de deletar
      final existing = await _repository.getById(id);
      final animalId = existing?['animal_id']?.toString() ?? '';
      
      await _repository.delete(id);

      EventBus().emit(MedicationDeletedEvent(
        medicationId: id,
        animalId: animalId,
      ));

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar medicação: $e');
      rethrow;
    }
  }

  /// Retorna medicações relacionadas a um item do estoque
  Future<List<Map<String, dynamic>>> getMedicationsByPharmacyStockId(
      String stockId) async {
    try {
      return await _repository.getByPharmacyStockId(stockId);
    } catch (e) {
      debugPrint('Erro ao buscar medicações por estoque: $e');
      return [];
    }
  }

  // Métodos auxiliares para normalização de datas
  String? _toIsoDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isEmpty) return null;
    if (value is DateTime) return value.toIso8601String();
    if (value is String) {
      try {
        return DateTime.parse(value).toIso8601String();
      } catch (_) {
        return value;
      }
    }
    return null;
  }
}

class MedicationQueryOptions {
  final String? species;
  final String? category;
  final String? searchTerm;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final int? offset;

  const MedicationQueryOptions({
    this.species,
    this.category,
    this.searchTerm,
    this.startDate,
    this.endDate,
    this.limit,
    this.offset,
  });
}
