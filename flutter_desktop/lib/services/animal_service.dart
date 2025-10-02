import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/animal.dart';
import '../data/local_db.dart';
import '../data/animal_repository.dart';

class AnimalService extends ChangeNotifier {
  final AnimalRepository _repo;

  List<Animal> animals = [];
  AnimalStats? stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AnimalService({required AppDatabase db}) : _repo = AnimalRepository(db) {
    // carrega dados iniciais mantendo compatibilidade com a UI
    loadData();
  }

  // ===== Compat: telas chamam loadData() =====
  Future<void> loadData() async => _refresh(inBackground: false);

  // ===== API nova interna =====
  Future<void> refresh() async => _refresh(inBackground: true);

  Future<void> _refresh({required bool inBackground}) async {
    if (!inBackground) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      animals = await _repo.all();
      stats = await _repo.stats();
    } finally {
      if (!inBackground) {
        _isLoading = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  // ===== Compat: telas chamam addAnimal/updateAnimal =====

  /// Adiciona novo animal. Se `id` vier vazio, gera um id único.
  Future<void> addAnimal(Animal a) async {
    final now = DateTime.now();
    final ensured = (a.id.isEmpty)
        ? a.copyWith(
            id: _genId(),
            createdAt: a.createdAt != null ? a.createdAt : now,
            updatedAt: now,
          )
        : a.copyWith(
            createdAt: a.createdAt, // preserva se vier preenchido
            updatedAt: now,
          );

    await _repo.upsert(ensured);
    await refresh();
  }

  /// Atualiza animal existente. (na prática é um upsert)
  Future<void> updateAnimal(Animal a) async {
    final updated = a.copyWith(updatedAt: DateTime.now());
    await _repo.upsert(updated);
    await refresh();
  }

  /// Remove por id
  Future<void> remove(String id) async {
    await _repo.delete(id);
    await refresh();
  }

  /// Série histórica de peso
  Future<void> addWeight(String id, DateTime date, double weight) async {
    await _repo.addWeight(id, date, weight);
    // opcional: refletir peso atual no registro do animal no dashboard
    final idx = animals.indexWhere((x) => x.id == id);
    if (idx != -1) {
      final a = animals[idx].copyWith(weight: weight, updatedAt: DateTime.now());
      await _repo.upsert(a);
    }
    await refresh();
  }

  // ===== util =====
  String _genId() {
    // simples ID único sem dependência de pacote uuid
    final r = Random();
    return '${DateTime.now().microsecondsSinceEpoch}-${r.nextInt(1 << 32)}';
    // se preferir uuid, adicione o pacote uuid e troque por Uuid().v4()
  }
}
