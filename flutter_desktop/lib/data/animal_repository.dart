import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;

import '../models/animal.dart';
import 'local_db.dart';

class AnimalRepository {
  final AppDatabase _db;
  AnimalRepository(this._db);

  Future<List<Animal>> all() async {
    final rows = await _db.db.query('animals', orderBy: 'created_at DESC');
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<void> upsert(Animal a) async {
    await _db.db.insert(
      'animals',
      a.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    await _db.db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addWeight(String animalId, DateTime date, double weight) async {
    await _db.db.insert('animal_weights', {
      'animal_id': animalId,
      'date': date.toIso8601String(),
      'weight': weight,
    });
  }

  Future<double?> latestWeight(String animalId) async {
    final r = await _db.db.query(
      'animal_weights',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (r.isEmpty) return null;
    final v = r.first['weight'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  int _firstInt(List<Map<String, Object?>> result) {
    if (result.isEmpty) return 0;
    final v = result.first.values.first;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Future<AnimalStats> stats() async {
    final total = _firstInt(await _db.db.rawQuery('SELECT COUNT(*) AS c FROM animals'));
    final healthy = _firstInt(await _db.db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE status='Saudável' OR status='Ativo'"));
    final pregnant = _firstInt(await _db.db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE pregnant=1"));
    final underTreatment = _firstInt(await _db.db.rawQuery(
       "SELECT COUNT(*) AS c FROM animals WHERE status='Em tratamento'"));

    final avgRow = await _db.db.rawQuery('SELECT AVG(weight) AS w FROM animals');
    final avg = avgRow.isNotEmpty ? avgRow.first['w'] : null;
    final avgWeight = (avg is num) ? avg.toDouble() : 0.0;

    return AnimalStats(
      totalAnimals: total,
      healthy: healthy,
      pregnant: pregnant,
      underTreatment: underTreatment,
      vaccinesThisMonth: 0,
      birthsThisMonth: 0,
      avgWeight: avgWeight,
      revenue: 0.0,
    );
  }
}
