import 'package:flutter/foundation.dart';

import '../../../models/animal.dart';
import '../../../models/pharmacy_stock.dart';
import '../../../services/animal_service.dart';
import '../../../services/medication_service.dart';
import '../../../services/pharmacy_service.dart';

class DashboardRepository {
  DashboardRepository({
    required AnimalService animalService,
    required PharmacyService pharmacyService,
    required MedicationService medicationService,
  })  : _animalService = animalService,
        _pharmacyService = pharmacyService,
        _medicationService = medicationService;

  final AnimalService _animalService;
  final PharmacyService _pharmacyService;
  final MedicationService _medicationService;

  bool get isLoading => _animalService.isLoading;
  AnimalStats? get stats => _animalService.stats;

  void addListener(VoidCallback listener) {
    _animalService.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _animalService.removeListener(listener);
  }

  Future<void> refreshDashboardData() {
    return _animalService.loadData();
  }

  Future<List<Animal>> searchAnimals({
    String? gender,
    bool excludePregnant = false,
    List<String> excludeCategories = const [],
    String? searchQuery,
    bool includeArchived = false,
    int limit = 50,
    int offset = 0,
  }) {
    return _animalService.searchAnimals(
      gender: gender,
      excludePregnant: excludePregnant,
      excludeCategories: excludeCategories,
      searchQuery: searchQuery,
      includeArchived: includeArchived,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<PharmacyStock>> getPharmacyStock({
    int? limit,
    int? offset,
  }) {
    return _pharmacyService.getPharmacyStock(limit: limit, offset: offset);
  }

  Future<void> createMedication(Map<String, dynamic> medication) {
    return _medicationService.createMedication(medication);
  }
}
