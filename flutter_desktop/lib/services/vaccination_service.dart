import 'package:flutter/foundation.dart';

import '../data/medication_repository.dart';
import '../data/vaccination_repository.dart';

class VaccinationAlertsData {
  final List<Map<String, dynamic>> vaccines;
  final List<Map<String, dynamic>> meds;

  const VaccinationAlertsData({
    required this.vaccines,
    required this.meds,
  });
}

/// Service para gerenciar vacinações
class VaccinationService extends ChangeNotifier {
  final VaccinationRepository _repository;
  final MedicationRepository _medicationRepository;

  VaccinationService(this._repository, this._medicationRepository);

  /// ---------- BLOCO NOVO: ALERTAS (Vacinas + Medicações) ----------

  Future<VaccinationAlertsData> getVaccinationAlerts() async {
    final vacs = await _repository.getScheduledWithAnimalInfo();
    final medsRaw = await _medicationRepository.getScheduledWithAnimalInfo(
      limit: 200,
      offset: 0,
    );

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    bool isNotApplied(Map<String, dynamic> m) {
      final ad = parseDate(m['applied_date']);
      return ad == null; // só consideramos agendadas e não aplicadas
    }

    final today = DateTime.now();
    final baseToday = DateTime(today.year, today.month, today.day);
    final cut = baseToday.add(const Duration(days: 30));

    final onlyUpcomingMeds = medsRaw.where((m) {
      final when = parseDate(m['date']) ?? parseDate(m['next_date']);
      if (when == null) return false;
      final day = DateTime(when.year, when.month, when.day);
      if (day.isAfter(cut)) return false;
      if (!isNotApplied(m)) return false;
      return true;
    }).toList();

    return VaccinationAlertsData(
      vaccines: vacs.map((e) => Map<String, dynamic>.from(e)).toList(),
      meds: onlyUpcomingMeds.map((e) => Map<String, dynamic>.from(e)).toList(),
    );
  }

  // ---------- RESTO DO SEU SERVICE (igual estava) ----------

  /// Retorna todas as vacinações
  Future<List<Map<String, dynamic>>> getVaccinations({
    int? limit,
    int? offset,
  }) async {
    try {
      return await _repository.getAll(limit: limit, offset: offset);
    } catch (e) {
      debugPrint('Erro ao buscar vacinações: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOverdueVaccinationsWithAnimalInfo({
    VaccinationQueryOptions options = const VaccinationQueryOptions(),
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
      debugPrint('Erro ao buscar vacinações atrasadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getScheduledVaccinationsWithAnimalInfo({
    VaccinationQueryOptions options = const VaccinationQueryOptions(),
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
      debugPrint('Erro ao buscar vacinações agendadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAppliedVaccinationsWithAnimalInfo({
    VaccinationQueryOptions options = const VaccinationQueryOptions(),
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
      debugPrint('Erro ao buscar vacinações aplicadas com info: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCancelledVaccinationsWithAnimalInfo({
    VaccinationQueryOptions options = const VaccinationQueryOptions(),
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
      debugPrint('Erro ao buscar vacinações canceladas com info: $e');
      return [];
    }
  }

  /// Retorna uma vacinação por ID
  Future<Map<String, dynamic>?> getVaccinationById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e) {
      debugPrint('Erro ao buscar vacinação: $e');
      return null;
    }
  }

  /// Retorna vacinações de um animal específico
  Future<List<Map<String, dynamic>>> getVaccinationsByAnimalId(
      String animalId) async {
    try {
      return await _repository.getByAnimalId(animalId);
    } catch (e) {
      debugPrint('Erro ao buscar vacinações do animal: $e');
      return [];
    }
  }

  /// Retorna vacinações agendadas
  Future<List<Map<String, dynamic>>> getScheduledVaccinations() async {
    try {
      return await _repository.getScheduled();
    } catch (e) {
      debugPrint('Erro ao buscar vacinações agendadas: $e');
      return [];
    }
  }

  /// Retorna vacinações por status
  Future<List<Map<String, dynamic>>> getVaccinationsByStatus(
      String status) async {
    try {
      return await _repository.getByStatus(status);
    } catch (e) {
      debugPrint('Erro ao buscar vacinações por status: $e');
      return [];
    }
  }

  /// Retorna vacinações vencidas (atrasadas)
  Future<List<Map<String, dynamic>>> getOverdueVaccinations() async {
    try {
      return await _repository.getOverdue();
    } catch (e) {
      debugPrint('Erro ao buscar vacinações vencidas: $e');
      return [];
    }
  }

  /// Retorna vacinações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcomingVaccinations(
      int daysThreshold) async {
    try {
      return await _repository.getUpcoming(daysThreshold);
    } catch (e) {
      debugPrint('Erro ao buscar vacinações próximas: $e');
      return [];
    }
  }

  /// Retorna vacinações com informações do animal
  Future<List<Map<String, dynamic>>> getVaccinationsWithAnimalInfo() async {
    try {
      return await _repository.getAllWithAnimalInfo();
    } catch (e) {
      debugPrint('Erro ao buscar vacinações com info do animal: $e');
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

      // Nota: Sincronização com Supabase é feita apenas via backup manual
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao criar vacinação: $e');
      rethrow;
    }
  }

  /// Atualiza uma vacinação
  Future<void> updateVaccination(
      String id, Map<String, dynamic> updates) async {
    try {
      final v = Map<String, dynamic>.from(updates);

      // Normalizar datas
      if (v.containsKey('scheduled_date')) {
        v['scheduled_date'] = _toIsoDate(v['scheduled_date']);
      }
      if (v.containsKey('applied_date')) {
        v['applied_date'] = _toIsoDate(v['applied_date']);
      }
      v['updated_at'] = DateTime.now().toIso8601String();

      // Atualizar no banco local
      await _repository.update(id, v);

      // Nota: Sincronização com Supabase é feita apenas via backup manual
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar vacinação: $e');
      rethrow;
    }
  }

  /// Deleta uma vacinação
  Future<void> deleteVaccination(String id) async {
    try {
      // Deletar no banco local
      await _repository.delete(id);

      // Nota: Sincronização com Supabase é feita apenas via backup manual
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar vacinação: $e');
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

class VaccinationQueryOptions {
  final String? species;
  final String? category;
  final String? searchTerm;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final int? offset;

  const VaccinationQueryOptions({
    this.species,
    this.category,
    this.searchTerm,
    this.startDate,
    this.endDate,
    this.limit,
    this.offset,
  });
}
