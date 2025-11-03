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

  Future<Animal?> getAnimalById(String id) async {
    final maps = await _db.db.query('animals', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Animal.fromMap(maps.first);
  }

  Future<List<Animal>> getOffspring(String parentId) async {
    final maps = await _db.db.query(
      'animals', 
      where: 'mother_id = ? OR father_id = ?', 
      whereArgs: [parentId, parentId]
    );
    return maps.map((m) => Animal.fromMap(m)).toList();
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

  Future<void> addWeight(String animalId, DateTime date, double weight, {String? milestone}) async {
    final id = 'wt_${DateTime.now().microsecondsSinceEpoch}';
    await _db.db.insert('animal_weights', {
      'id': id,
      'animal_id': animalId,
      'date': date.toIso8601String().split('T').first,
      'weight': weight,
      'milestone': milestone,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Busca o peso mais recente após inserção
    final latestWeightResult = await _db.db.query(
      'animal_weights',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'date DESC',
      limit: 1,
    );
    
    final latestWeight = latestWeightResult.isNotEmpty 
        ? (latestWeightResult.first['weight'] as num).toDouble()
        : weight;

    // Sincroniza com os campos cache em animals
    final Map<String, dynamic> updateData = {'weight': latestWeight};
    
    if (milestone == 'birth') {
      updateData['birth_weight'] = weight;
    } else if (milestone == '30d') {
      updateData['weight_30_days'] = weight;
    } else if (milestone == '60d') {
      updateData['weight_60_days'] = weight;
    } else if (milestone == '90d') {
      updateData['weight_90_days'] = weight;
    } else if (milestone == '120d') {
      updateData['weight_120_days'] = weight;
    }

    await _db.db.update(
      'animals',
      updateData,
      where: 'id = ?',
      whereArgs: [animalId],
    );
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

  /// Busca histórico de pesos de um animal
  Future<List<Map<String, dynamic>>> getWeightHistory(String animalId) async {
    return await _db.db.query(
      'animal_weights',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'date DESC',
    );
  }

  /// Busca pesos mensais (para adultos)
  Future<List<Map<String, dynamic>>> getMonthlyWeights(String animalId) async {
    return await _db.db.query(
      'animal_weights',
      where: "animal_id = ? AND (milestone LIKE 'monthly_%' OR milestone IS NULL)",
      whereArgs: [animalId],
      orderBy: 'date DESC',
      limit: 24, // Mudado de 5 para 24 meses
    );
  }

  /// Busca peso específico por milestone (ex: '120d')
  Future<List<Map<String, dynamic>>> getWeightRecord(String animalId, String milestone) async {
    return await _db.db.query(
      'animal_weights',
      where: 'animal_id = ? AND milestone = ?',
      whereArgs: [animalId, milestone],
      orderBy: 'date DESC',
      limit: 1,
    );
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

  /// Move animal para a tabela de vendidos e remove da tabela principal
  Future<void> markAsSold({
    required String animalId,
    required DateTime saleDate,
    double? salePrice,
    String? buyer,
    String? notes,
  }) async {
    final animal = await _db.db.query('animals', where: 'id = ?', whereArgs: [animalId]);
    if (animal.isEmpty) throw Exception('Animal não encontrado');

    final animalData = animal.first;
    await _db.db.insert('sold_animals', {
      'id': animalData['id'],
      'original_animal_id': animalData['id'],
      'code': animalData['code'],
      'name': animalData['name'],
      'species': animalData['species'],
      'breed': animalData['breed'],
      'gender': animalData['gender'],
      'birth_date': animalData['birth_date'],
      'weight': animalData['weight'],
      'location': animalData['location'],
      'name_color': animalData['name_color'],
      'category': animalData['category'],
      'birth_weight': animalData['birth_weight'],
      'weight_30_days': animalData['weight_30_days'],
      'weight_60_days': animalData['weight_60_days'],
      'weight_90_days': animalData['weight_90_days'],
      'weight_120_days': animalData['weight_120_days'],
      'year': animalData['year'],
      'lote': animalData['lote'],
      'mother_id': animalData['mother_id'],
      'father_id': animalData['father_id'],
      'sale_date': saleDate.toIso8601String().split('T').first,
      'sale_price': salePrice,
      'buyer': buyer,
      'sale_notes': notes,
    });

    await _db.db.delete('animals', where: 'id = ?', whereArgs: [animalId]);
  }

  /// Move animal para a tabela de falecidos e remove da tabela principal
  Future<void> markAsDeceased({
    required String animalId,
    required DateTime deathDate,
    String? causeOfDeath,
    String? notes,
  }) async {
    final animal = await _db.db.query('animals', where: 'id = ?', whereArgs: [animalId]);
    if (animal.isEmpty) throw Exception('Animal não encontrado');

    final animalData = animal.first;
    await _db.db.insert('deceased_animals', {
      'id': animalData['id'],
      'original_animal_id': animalData['id'],
      'code': animalData['code'],
      'name': animalData['name'],
      'species': animalData['species'],
      'breed': animalData['breed'],
      'gender': animalData['gender'],
      'birth_date': animalData['birth_date'],
      'weight': animalData['weight'],
      'location': animalData['location'],
      'name_color': animalData['name_color'],
      'category': animalData['category'],
      'birth_weight': animalData['birth_weight'],
      'weight_30_days': animalData['weight_30_days'],
      'weight_60_days': animalData['weight_60_days'],
      'weight_90_days': animalData['weight_90_days'],
      'weight_120_days': animalData['weight_120_days'],
      'year': animalData['year'],
      'lote': animalData['lote'],
      'mother_id': animalData['mother_id'],
      'father_id': animalData['father_id'],
      'death_date': deathDate.toIso8601String().split('T').first,
      'cause_of_death': causeOfDeath,
      'death_notes': notes,
    });

    await _db.db.delete('animals', where: 'id = ?', whereArgs: [animalId]);
  }

  /// Busca animais vendidos
  Future<List<Map<String, dynamic>>> getSoldAnimals() async {
    return await _db.db.query('sold_animals', orderBy: 'sale_date DESC');
  }

  /// Busca animais falecidos
  Future<List<Map<String, dynamic>>> getDeceasedAnimals() async {
    return await _db.db.query('deceased_animals', orderBy: 'death_date DESC');
  }
}
