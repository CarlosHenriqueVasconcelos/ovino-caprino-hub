import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/animal.dart';
import '../services/database_service.dart';

class AnimalService extends ChangeNotifier {
  final List<Animal> _animals = [];
  AnimalStats? _stats;
  bool _isLoading = false;

  List<Animal> get animals => List.unmodifiable(_animals);
  AnimalStats? get stats => _stats;
  bool get isLoading => _isLoading;

  AnimalService() {
    // carrega de forma assíncrona sem travar a árvore de widgets
    Future.microtask(loadData);
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await DatabaseService.getAnimals();
      final statsMap = await DatabaseService.getStats();

      _animals
        ..clear()
        ..addAll(rows);
      _stats = AnimalStats.fromMap(statsMap);
    } catch (e) {
      debugPrint('Erro em loadData(): $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _genId() => 'AN_${DateTime.now().microsecondsSinceEpoch}';

  /// Garante ID único se vier vazio, e timestamps mínimos
  Animal _ensureIdAndTimestamps(Animal a, {bool isNew = false}) {
    final map = a.toMap();
    if ((a.id).trim().isEmpty) {
      map['id'] = _genId();
    }
    final nowDate = DateTime.now().toIso8601String();
    if (isNew) {
      map['created_at'] = nowDate;
    }
    map['updated_at'] = nowDate;
    return Animal.fromMap(map);
  }

  Future<void> addAnimal(Animal animal) async {
    final a = _ensureIdAndTimestamps(animal, isNew: true);

    await DatabaseService.createAnimal(a.toMap());

    // Acrescenta sem substituir
    _animals.add(a);
    await _refreshStats();
    notifyListeners();
  }

  Future<void> updateAnimal(Animal animal) async {
    final a = _ensureIdAndTimestamps(animal, isNew: false);

    await DatabaseService.updateAnimal(a.id, a.toMap());

    final idx = _animals.indexWhere((x) => x.id == a.id);
    if (idx >= 0) {
      _animals[idx] = a;
    } else {
      _animals.add(a);
    }
    await _refreshStats();
    notifyListeners();
  }

  Future<void> deleteAnimal(String id) async {
    await DatabaseService.deleteAnimal(id);
    _animals.removeWhere((x) => x.id == id);
    await _refreshStats();
    notifyListeners();
  }

  Future<void> _refreshStats() async {
    try {
      final statsMap = await DatabaseService.getStats();
      _stats = AnimalStats.fromMap(statsMap);
    } catch (e) {
      debugPrint('Erro recalculando stats: $e');
    }
  }

  // ===================== ALERTAS PARA DASHBOARD =====================

  /// Próximas vacinações (Agendada até N dias)
  Future<List<Map<String, dynamic>>> getUpcomingVaccinations({int daysAhead = 14}) async {
    final db = await DatabaseService.database;
    final limitDate = DateTime.now().add(Duration(days: daysAhead));
    final rows = await db.rawQuery('''
      SELECT v.*, a.name AS animal_name, a.code AS animal_code
      FROM vaccinations v
      JOIN animals a ON a.id = v.animal_id
      WHERE v.status = 'Agendada'
        AND date(v.scheduled_date) <= date(?)
      ORDER BY v.scheduled_date ASC
    ''', [limitDate.toIso8601String().split('T').first]);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Próximas medicações (next_date até N dias)
  Future<List<Map<String, dynamic>>> getUpcomingMedications({int daysAhead = 14}) async {
    final db = await DatabaseService.database;
    final limitDate = DateTime.now().add(Duration(days: daysAhead));
    final rows = await db.rawQuery('''
      SELECT m.*, a.name AS animal_name, a.code AS animal_code
      FROM medications m
      JOIN animals a ON a.id = m.animal_id
      WHERE m.next_date IS NOT NULL
        AND date(m.next_date) <= date(?)
      ORDER BY m.next_date ASC
    ''', [limitDate.toIso8601String().split('T').first]);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Resumo para a "box" de alertas
  Future<DashboardAlerts> getDashboardAlerts() async {
    final vacs = await getUpcomingVaccinations(daysAhead: 14);
    final meds = await getUpcomingMedications(daysAhead: 14);
    return DashboardAlerts(
      totalVaccinations: vacs.length,
      totalMedications: meds.length,
      vaccinations: vacs,
      medications: meds,
    );
  }
}

class DashboardAlerts {
  final int totalVaccinations;
  final int totalMedications;
  final List<Map<String, dynamic>> vaccinations;
  final List<Map<String, dynamic>> medications;

  DashboardAlerts({
    required this.totalVaccinations,
    required this.totalMedications,
    required this.vaccinations,
    required this.medications,
  });

  bool get hasAny => totalVaccinations > 0 || totalMedications > 0;
}
