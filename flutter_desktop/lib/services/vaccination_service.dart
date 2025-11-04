import 'package:flutter/foundation.dart';
import '../data/vaccination_repository.dart';
import '../services/supabase_service.dart';

/// Service para gerenciar vacinações
class VaccinationService extends ChangeNotifier {
  final VaccinationRepository _repository;

  VaccinationService(this._repository);

  /// Retorna todas as vacinações
  Future<List<Map<String, dynamic>>> getVaccinations() async {
    try {
      return await _repository.getAll();
    } catch (e) {
      print('Erro ao buscar vacinações: $e');
      return [];
    }
  }

  /// Retorna uma vacinação por ID
  Future<Map<String, dynamic>?> getVaccinationById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e) {
      print('Erro ao buscar vacinação: $e');
      return null;
    }
  }

  /// Retorna vacinações de um animal específico
  Future<List<Map<String, dynamic>>> getVaccinationsByAnimalId(String animalId) async {
    try {
      return await _repository.getByAnimalId(animalId);
    } catch (e) {
      print('Erro ao buscar vacinações do animal: $e');
      return [];
    }
  }

  /// Retorna vacinações agendadas
  Future<List<Map<String, dynamic>>> getScheduledVaccinations() async {
    try {
      return await _repository.getScheduled();
    } catch (e) {
      print('Erro ao buscar vacinações agendadas: $e');
      return [];
    }
  }

  /// Retorna vacinações por status
  Future<List<Map<String, dynamic>>> getVaccinationsByStatus(String status) async {
    try {
      return await _repository.getByStatus(status);
    } catch (e) {
      print('Erro ao buscar vacinações por status: $e');
      return [];
    }
  }

  /// Retorna vacinações vencidas (atrasadas)
  Future<List<Map<String, dynamic>>> getOverdueVaccinations() async {
    try {
      return await _repository.getOverdue();
    } catch (e) {
      print('Erro ao buscar vacinações vencidas: $e');
      return [];
    }
  }

  /// Retorna vacinações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcomingVaccinations(int daysThreshold) async {
    try {
      return await _repository.getUpcoming(daysThreshold);
    } catch (e) {
      print('Erro ao buscar vacinações próximas: $e');
      return [];
    }
  }

  /// Retorna vacinações com informações do animal
  Future<List<Map<String, dynamic>>> getVaccinationsWithAnimalInfo() async {
    try {
      return await _repository.getAllWithAnimalInfo();
    } catch (e) {
      print('Erro ao buscar vacinações com info do animal: $e');
      return [];
    }
  }

  /// Cria uma nova vacinação
  Future<void> createVaccination(Map<String, dynamic> vaccination) async {
    try {
      final v = Map<String, dynamic>.from(vaccination);
      
      // Normalizar datas
      v['scheduled_date'] = _toIsoDate(v['scheduled_date']);
      v['applied_date'] = _toIsoDate(v['applied_date']);
      v['created_at'] ??= DateTime.now().toIso8601String();
      v['updated_at'] = DateTime.now().toIso8601String();

      // Inserir no banco local
      await _repository.insert(v);

      // Sincronizar com Supabase
      if (SupabaseService.isConfigured) {
        await SupabaseService.supabase.from('vaccinations').insert(v);
      }

      notifyListeners();
    } catch (e) {
      print('Erro ao criar vacinação: $e');
      rethrow;
    }
  }

  /// Atualiza uma vacinação
  Future<void> updateVaccination(String id, Map<String, dynamic> updates) async {
    try {
      final v = Map<String, dynamic>.from(updates);

      // Normalizar datas
      if (v.containsKey('scheduled_date')) v['scheduled_date'] = _toIsoDate(v['scheduled_date']);
      if (v.containsKey('applied_date')) v['applied_date'] = _toIsoDate(v['applied_date']);
      v['updated_at'] = DateTime.now().toIso8601String();

      // Atualizar no banco local
      await _repository.update(id, v);

      // Sincronizar com Supabase
      if (SupabaseService.isConfigured) {
        await SupabaseService.supabase
            .from('vaccinations')
            .update(v)
            .eq('id', id);
      }

      notifyListeners();
    } catch (e) {
      print('Erro ao atualizar vacinação: $e');
      rethrow;
    }
  }

  /// Deleta uma vacinação
  Future<void> deleteVaccination(String id) async {
    try {
      // Deletar no banco local
      await _repository.delete(id);

      // Sincronizar com Supabase
      if (SupabaseService.isConfigured) {
        await SupabaseService.supabase
            .from('vaccinations')
            .delete()
            .eq('id', id);
      }

      notifyListeners();
    } catch (e) {
      print('Erro ao deletar vacinação: $e');
      rethrow;
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
