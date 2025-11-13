import 'package:flutter/foundation.dart';
import '../data/medication_repository.dart';

/// Service para gerenciar medicações
class MedicationService extends ChangeNotifier {
  final MedicationRepository _repository;

  MedicationService(this._repository);

  /// Retorna todas as medicações
  Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      return await _repository.getAll();
    } catch (e) {
      print('Erro ao buscar medicações: $e');
      return [];
    }
  }

  /// Retorna uma medicação por ID
  Future<Map<String, dynamic>?> getMedicationById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e) {
      print('Erro ao buscar medicação: $e');
      return null;
    }
  }

  /// Retorna medicações de um animal específico
  Future<List<Map<String, dynamic>>> getMedicationsByAnimalId(
      String animalId) async {
    try {
      return await _repository.getByAnimalId(animalId);
    } catch (e) {
      print('Erro ao buscar medicações do animal: $e');
      return [];
    }
  }

  /// Retorna medicações agendadas
  Future<List<Map<String, dynamic>>> getScheduledMedications() async {
    try {
      return await _repository.getScheduled();
    } catch (e) {
      print('Erro ao buscar medicações agendadas: $e');
      return [];
    }
  }

  /// Retorna medicações por status
  Future<List<Map<String, dynamic>>> getMedicationsByStatus(
      String status) async {
    try {
      return await _repository.getByStatus(status);
    } catch (e) {
      print('Erro ao buscar medicações por status: $e');
      return [];
    }
  }

  /// Retorna medicações vencidas (atrasadas)
  Future<List<Map<String, dynamic>>> getOverdueMedications() async {
    try {
      return await _repository.getOverdue();
    } catch (e) {
      print('Erro ao buscar medicações vencidas: $e');
      return [];
    }
  }

  /// Retorna medicações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcomingMedications(
      int daysThreshold) async {
    try {
      return await _repository.getUpcoming(daysThreshold);
    } catch (e) {
      print('Erro ao buscar medicações próximas: $e');
      return [];
    }
  }

  /// Retorna medicações com informações do animal
  Future<List<Map<String, dynamic>>> getMedicationsWithAnimalInfo() async {
    try {
      return await _repository.getAllWithAnimalInfo();
    } catch (e) {
      print('Erro ao buscar medicações com info do animal: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>>
      getOverdueMedicationsWithAnimalInfo() async {
    try {
      return await _repository.getOverdueWithAnimalInfo();
    } catch (e) {
      print('Erro ao buscar medicações atrasadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>>
      getScheduledMedicationsWithAnimalInfo() async {
    try {
      return await _repository.getScheduledWithAnimalInfo();
    } catch (e) {
      print('Erro ao buscar medicações agendadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>>
      getAppliedMedicationsWithAnimalInfo() async {
    try {
      return await _repository.getAppliedWithAnimalInfo();
    } catch (e) {
      print('Erro ao buscar medicações aplicadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>>
      getCancelledMedicationsWithAnimalInfo() async {
    try {
      return await _repository.getCancelledWithAnimalInfo();
    } catch (e) {
      print('Erro ao buscar medicações canceladas com info: $e');
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
      print('Erro ao buscar medicações pendentes: $e');
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

      // Nota: Sincronização com Supabase é feita apenas via backup manual
      notifyListeners();
    } catch (e) {
      print('Erro ao criar medicação: $e');
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

      // Nota: Sincronização com Supabase é feita apenas via backup manual
      notifyListeners();
    } catch (e) {
      print('Erro ao atualizar medicação: $e');
      rethrow;
    }
  }

  /// Deleta uma medicação
  Future<void> deleteMedication(String id) async {
    try {
      // Deletar no banco local
      await _repository.delete(id);

      // Nota: Sincronização com Supabase é feita apenas via backup manual
      notifyListeners();
    } catch (e) {
      print('Erro ao deletar medicação: $e');
      rethrow;
    }
  }

  /// Retorna medicações relacionadas a um item do estoque
  Future<List<Map<String, dynamic>>> getMedicationsByPharmacyStockId(
      String stockId) async {
    try {
      return await _repository.getByPharmacyStockId(stockId);
    } catch (e) {
      print('Erro ao buscar medicações por estoque: $e');
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
