import 'package:flutter/foundation.dart';
import '../models/animal.dart';
import 'supabase_service.dart';

class AnimalService extends ChangeNotifier {
  List<Animal> _animals = [];
  AnimalStats? _stats;
  bool _isLoading = false;
  String? _error;

  List<Animal> get animals => _animals;
  AnimalStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AnimalService() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _animals = await SupabaseService.getAnimals();
      final statsData = await SupabaseService.getStats();
      _stats = AnimalStats.fromMap(statsData);
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar dados: $e';
      _loadMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadMockData() {
    _animals = [
      Animal(
        id: "OV001",
        code: "OV001",
        name: "Benedita",
        species: "Ovino",
        breed: "Santa Inês",
        gender: "Fêmea",
        birthDate: DateTime(2022, 3, 15),
        weight: 45.5,
        status: "Saudável",
        location: "Pasto A1",
        lastVaccination: DateTime(2024, 8, 15),
        pregnant: true,
        expectedDelivery: DateTime(2024, 12, 20),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Animal(
        id: "CP002",
        code: "CP002",
        name: "Joaquim",
        species: "Caprino",
        breed: "Boer",
        gender: "Macho",
        birthDate: DateTime(2021, 7, 22),
        weight: 65.2,
        status: "Reprodutor",
        location: "Pasto B2",
        lastVaccination: DateTime(2024, 9, 1),
        pregnant: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Animal(
        id: "OV003",
        code: "OV003",
        name: "Esperança",
        species: "Ovino",
        breed: "Morada Nova",
        gender: "Fêmea",
        birthDate: DateTime(2023, 1, 10),
        weight: 38.0,
        status: "Em tratamento",
        location: "Enfermaria",
        lastVaccination: DateTime(2024, 7, 20),
        pregnant: false,
        healthIssue: "Verminose",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _stats = AnimalStats(
      totalAnimals: 45,
      healthy: 42,
      pregnant: 8,
      underTreatment: 3,
      vaccinesThisMonth: 12,
      birthsThisMonth: 3,
      avgWeight: 51.2,
      revenue: 15450.00,
    );
  }

  Future<void> addAnimal(Animal animal) async {
    try {
      final newAnimal =
          await SupabaseService.createAnimal(animal.toJson());
      if (newAnimal != null) {
        _animals.insert(0, newAnimal);
        await _refreshStats();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao adicionar animal: $e';
      notifyListeners();
    }
  }

  Future<void> updateAnimal(Animal animal) async {
    try {
      final updatedAnimal =
          await SupabaseService.updateAnimal(animal.id, animal.toJson());
      if (updatedAnimal != null) {
        final index = _animals.indexWhere((a) => a.id == animal.id);
        if (index >= 0) {
          _animals[index] = updatedAnimal;
          await _refreshStats();
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Erro ao atualizar animal: $e';
      notifyListeners();
    }
  }

  Future<void> removeAnimal(String id) async {
    try {
      final success = await SupabaseService.deleteAnimal(id);
      if (success) {
        _animals.removeWhere((animal) => animal.id == id);
        await _refreshStats();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erro ao remover animal: $e';
      notifyListeners();
    }
  }

  Future<void> _refreshStats() async {
    try {
      final statsData = await SupabaseService.getStats();
      _stats = AnimalStats.fromMap(statsData);
    } catch (e) {
      print('Error refreshing stats: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
