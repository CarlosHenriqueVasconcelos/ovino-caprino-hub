// lib/data/animal_repository.dart
import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;

import '../models/animal.dart';
import 'local_db.dart';

class AnimalRepository {
  final AppDatabase _db;
  AnimalRepository(this._db);

  // ----------------- CRUD básico de animals -----------------

  Future<List<Animal>> all({
    int? limit,
    int? offset,
    String orderBy = 'name COLLATE NOCASE',
  }) async {
    final rows = await _db.db.query(
      'animals',
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<Animal?> getAnimalById(String id) async {
    final maps = await _db.db.query(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Animal.fromMap(maps.first);
  }

  Future<List<Animal>> getOffspring(String parentId) async {
    final maps = await _db.db.query(
      'animals',
      where: 'mother_id = ? OR father_id = ?',
      whereArgs: [parentId, parentId],
    );
    return maps.map((m) => Animal.fromMap(m)).toList();
  }

  /// Query filtrada para weight tracking (com paginação)
  Future<List<Animal>> getFilteredAnimals({
    int? ageMinMonths,
    int? ageMaxMonths,
    bool? excludeReproducers,
    bool? onlyReproducers,
    bool includeSold = true,
    String? statusEquals,
    String? nameColor,
    String? categoryEquals,
    List<String>? categoryLikeAny,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    final now = DateTime.now();
    final buffer = StringBuffer();
    final args = <dynamic>[];

    // Filtro de idade por meses
    if (ageMinMonths != null) {
      final maxBirthDate = DateTime(
        now.year,
        now.month - ageMinMonths,
        now.day,
      );
      buffer.write('birth_date <= ?');
      args.add(maxBirthDate.toIso8601String().split('T').first);
    }

    if (ageMaxMonths != null) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      final minBirthDate = DateTime(
        now.year,
        now.month - ageMaxMonths,
        now.day,
      );
      buffer.write('birth_date > ?');
      args.add(minBirthDate.toIso8601String().split('T').first);
    }

    // Excluir reprodutores
    if (excludeReproducers == true) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write("LOWER(category) NOT LIKE '%reprodutor%'");
    }

    // Apenas reprodutores
    if (onlyReproducers == true) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write("LOWER(category) LIKE '%reprodutor%'");
    }

    if (!includeSold) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write("status != 'Vendido'");
    }

    if (statusEquals != null && statusEquals.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('status = ?');
      args.add(statusEquals);
    }

    // Filtro de cor
    if (nameColor != null && nameColor.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('name_color = ?');
      args.add(nameColor);
    }

    if (categoryEquals != null && categoryEquals.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('category = ?');
      args.add(categoryEquals);
    }

    if (categoryLikeAny != null && categoryLikeAny.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      final likes = categoryLikeAny
          .map((c) => "LOWER(category) LIKE ?")
          .join(' OR ');
      buffer.write('($likes)');
      args.addAll(categoryLikeAny.map((c) => '%${c.toLowerCase()}%'));
    }

    // Busca por nome ou código
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      final query = '%${searchQuery.toLowerCase()}%';
      args.add(query);
      args.add(query);
    }

    final rows = await _db.db.query(
      'animals',
      where: buffer.isEmpty ? null : buffer.toString(),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name COLLATE NOCASE',
      limit: limit,
      offset: offset,
    );

    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca paginada para autocompletes/listas rápidas com filtros simples.
  Future<List<Animal>> searchAnimals({
    String? gender,
    bool excludePregnant = false,
    List<String> excludeCategories = const [],
    String? searchQuery,
    int limit = 50,
    int offset = 0,
    String orderBy = 'name COLLATE NOCASE',
  }) async {
    final where = <String>[];
    final args = <dynamic>[];

    if (gender != null && gender.isNotEmpty) {
      where.add('LOWER(gender) = ?');
      args.add(gender.toLowerCase());
    }

    if (excludePregnant) {
      where.add("(pregnant IS NULL OR pregnant = 0)");
    }

    if (excludeCategories.isNotEmpty) {
      final placeholders = List.filled(excludeCategories.length, '?').join(',');
      where.add('LOWER(category) NOT IN ($placeholders)');
      args.addAll(excludeCategories.map((c) => c.toLowerCase()));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add(
        '(LOWER(name) LIKE ? OR LOWER(code) LIKE ? OR LOWER(name_color) LIKE ?)',
      );
      args.addAll([q, q, q]);
    }

    final rows = await _db.db.query(
      'animals',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Conta resultados para mesma query filtrada (evita carregar tudo)
  Future<int> countFilteredAnimals({
    int? ageMinMonths,
    int? ageMaxMonths,
    bool? excludeReproducers,
    bool? onlyReproducers,
    bool includeSold = true,
    String? statusEquals,
    String? nameColor,
    String? categoryEquals,
    List<String>? categoryLikeAny,
    String? searchQuery,
  }) async {
    final now = DateTime.now();
    final buffer = StringBuffer();
    final args = <dynamic>[];

    if (ageMinMonths != null) {
      final maxBirthDate = DateTime(
        now.year,
        now.month - ageMinMonths,
        now.day,
      );
      buffer.write('birth_date <= ?');
      args.add(maxBirthDate.toIso8601String().split('T').first);
    }

    if (ageMaxMonths != null) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      final minBirthDate = DateTime(
        now.year,
        now.month - ageMaxMonths,
        now.day,
      );
      buffer.write('birth_date > ?');
      args.add(minBirthDate.toIso8601String().split('T').first);
    }

    if (excludeReproducers == true) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write("LOWER(category) NOT LIKE '%reprodutor%'");
    }

    if (onlyReproducers == true) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write("LOWER(category) LIKE '%reprodutor%'");
    }

    if (!includeSold) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write("status != 'Vendido'");
    }

    if (statusEquals != null && statusEquals.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('status = ?');
      args.add(statusEquals);
    }

    if (nameColor != null && nameColor.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('name_color = ?');
      args.add(nameColor);
    }

    if (categoryEquals != null && categoryEquals.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('category = ?');
      args.add(categoryEquals);
    }

    if (categoryLikeAny != null && categoryLikeAny.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      final likes = categoryLikeAny
          .map((c) => "LOWER(category) LIKE ?")
          .join(' OR ');
      buffer.write('($likes)');
      args.addAll(categoryLikeAny.map((c) => '%${c.toLowerCase()}%'));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      final query = '%${searchQuery.toLowerCase()}%';
      args.add(query);
      args.add(query);
    }

    final result = await _db.db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM animals
      ${buffer.isEmpty ? '' : 'WHERE ${buffer.toString()}'}
      ''',
      args.isEmpty ? null : args,
    );

    if (result.isEmpty) return 0;
    final value = result.first['count'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Lista de cores distintas para filtros (evita carregar todos os animais)
  Future<List<String>> getDistinctColors() async {
    final rows = await _db.db.rawQuery(
      '''
      SELECT DISTINCT name_color
      FROM animals
      WHERE name_color IS NOT NULL AND name_color != ''
      ORDER BY name_color COLLATE NOCASE
      ''',
    );
    return rows
        .map((row) => row['name_color'])
        .whereType<String>()
        .toList();
  }

  Future<List<String>> getDistinctCategories() async {
    final rows = await _db.db.rawQuery(
      '''
      SELECT DISTINCT category
      FROM animals
      WHERE category IS NOT NULL AND category != ''
      ORDER BY category COLLATE NOCASE
      ''',
    );
    return rows
        .map((row) => row['category'])
        .whereType<String>()
        .toList();
  }

  Future<void> upsert(Animal a) async {
    await _db.db.insert(
      'animals',
      a.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    await _db.db.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ----------------- Pesos / histórico de peso -----------------

  Future<void> addWeight(
    String animalId,
    DateTime date,
    double weight, {
    String? milestone,
  }) async {
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
      where:
          "animal_id = ? AND (milestone LIKE 'monthly_%' OR milestone IS NULL)",
      whereArgs: [animalId],
      orderBy: 'date DESC',
      // Últimos 24 meses
      limit: 24,
    );
  }

  /// Busca peso específico por milestone (ex: '120d')
  Future<List<Map<String, dynamic>>> getWeightRecord(
    String animalId,
    String milestone,
  ) async {
    return await _db.db.query(
      'animal_weights',
      where: 'animal_id = ? AND milestone = ?',
      whereArgs: [animalId, milestone],
      orderBy: 'date DESC',
      limit: 1,
    );
  }

  // ----------------- Estatísticas (AnimalStats) -----------------

  int _firstInt(List<Map<String, Object?>> result) {
    if (result.isEmpty) return 0;
    final v = result.first.values.first;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  double _firstDouble(List<Map<String, Object?>> result) {
    if (result.isEmpty) return 0.0;
    final v = result.first.values.first;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  Future<AnimalStats> stats() async {
    // Contagens básicas
    final totalAnimals =
        _firstInt(await _db.db.rawQuery('SELECT COUNT(*) AS c FROM animals'));

    final healthy = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM animals WHERE status = ?",
      ['Saudável'],
    ));

    final pregnant = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM animals WHERE pregnant = 1",
    ));

    final underTreatment = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM animals WHERE status = ?",
      ['Em tratamento'],
    ));

    // Distribuição por categoria/gênero
    final maleReproducers = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM animals WHERE category = ? AND gender = ?",
      ['Reprodutor', 'Macho'],
    ));

    final maleLambs = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM animals WHERE category = ? AND gender = ?",
      ['Borrego', 'Macho'],
    ));

    final femaleLambs = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM animals WHERE category = ? AND gender = ?",
      ['Borrego', 'Fêmea'],
    ));

    final femaleReproducers = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM animals WHERE category = ? AND gender = ?",
      ['Reprodutor', 'Fêmea'],
    ));

    // Receita total (financeiro)
    final revenue = _firstDouble(await _db.db.rawQuery(
      "SELECT SUM(amount) AS s FROM financial_records WHERE type = ?",
      ['receita'],
    ));

    // Peso médio do rebanho
    final avgWeight = _firstDouble(
      await _db.db.rawQuery('SELECT AVG(weight) AS w FROM animals'),
    );

    // Mês atual YYYY-MM
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    String isoDate(DateTime value) => value.toIso8601String().split('T').first;

    // Vacinas aplicadas / agendadas neste mês
    final vaccinesThisMonth = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM vaccinations "
      "WHERE COALESCE(applied_date, scheduled_date) >= ? "
      "AND COALESCE(applied_date, scheduled_date) <= ?",
      [isoDate(monthStart), isoDate(monthEnd)],
    ));

    // Partos previstos neste mês
    final birthsThisMonth = _firstInt(await _db.db.rawQuery(
      "SELECT COUNT(*) AS c FROM animals "
      "WHERE expected_delivery IS NOT NULL "
      "AND expected_delivery >= ? "
      "AND expected_delivery <= ?",
      [isoDate(monthStart), isoDate(monthEnd)],
    ));

    return AnimalStats(
      totalAnimals: totalAnimals,
      healthy: healthy,
      pregnant: pregnant,
      underTreatment: underTreatment,
      maleReproducers: maleReproducers,
      maleLambs: maleLambs,
      femaleLambs: femaleLambs,
      femaleReproducers: femaleReproducers,
      revenue: revenue,
      avgWeight: avgWeight,
      vaccinesThisMonth: vaccinesThisMonth,
      birthsThisMonth: birthsThisMonth,
    );
  }

  // ----------------- Vendidos / Falecidos -----------------

  /// Move animal para a tabela de vendidos e remove da tabela principal
  Future<void> markAsSold({
    required String animalId,
    required DateTime saleDate,
    double? salePrice,
    String? buyer,
    String? notes,
  }) async {
    final animal = await _db.db.query(
      'animals',
      where: 'id = ?',
      whereArgs: [animalId],
    );
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
    await _db.db.transaction((txn) async {
      final animal = await txn.query(
        'animals',
        where: 'id = ?',
        whereArgs: [animalId],
      );
      if (animal.isEmpty) throw Exception('Animal não encontrado');

      final animalData = animal.first;
      await txn.insert(
        'deceased_animals',
        {
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
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'animal_weights',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );

      await txn.delete(
        'vaccinations',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );

      final meds = await txn.query(
        'medications',
        columns: ['id'],
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      for (final med in meds) {
        final medId = med['id']?.toString();
        if (medId == null || medId.isEmpty) continue;
        await txn.delete(
          'pharmacy_stock_movements',
          where: 'medication_id = ?',
          whereArgs: [medId],
        );
      }
      await txn.delete(
        'medications',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );

      await txn.delete(
        'notes',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );

      await txn.delete(
        'financial_records',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );

      await txn.delete(
        'financial_accounts',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );

      await txn.delete(
        'breeding_records',
        where: 'female_animal_id = ? OR male_animal_id = ?',
        whereArgs: [animalId, animalId],
      );

      await txn.delete('animals', where: 'id = ?', whereArgs: [animalId]);
    });
  }

  /// Busca animais vendidos
  /// Busca animais vendidos com paginação
  Future<List<Map<String, dynamic>>> getSoldAnimals({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    return await _db.db.query(
      'sold_animals',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'sale_date DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Busca animais falecidos com paginação
  Future<List<Map<String, dynamic>>> getDeceasedAnimals({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    return await _db.db.query(
      'deceased_animals',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'death_date DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> findIdentityConflicts({
    required List<String> candidateNamesLower,
    required String colorLower,
    String? excludeId,
  }) async {
    if (candidateNamesLower.isEmpty) return [];

    final placeholders =
        List.filled(candidateNamesLower.length, '?').join(', ');
    final whereBuffer = StringBuffer()
      ..write('LOWER(name_color) = ? AND LOWER(name) IN (')
      ..write(placeholders)
      ..write(')');
    final args = <dynamic>[colorLower, ...candidateNamesLower];

    if (excludeId != null) {
      whereBuffer.write(' AND id <> ?');
      args.add(excludeId);
    }

    return await _db.db.query(
      'animals',
      columns: ['id', 'name', 'name_color', 'category', 'lote'],
      where: whereBuffer.toString(),
      whereArgs: args,
    );
  }

  // ----------------- FASE 2: Queries otimizadas e paginadas -----------------

  /// Busca animais por gênero com paginação (otimizado para performance)
  Future<List<Animal>> getAnimalsByGender({
    required String gender,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final where = <String>['LOWER(gender) = ?'];
    final args = <dynamic>[gender.toLowerCase()];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await _db.db.query(
      'animals',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE',
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca animais por espécie com paginação
  Future<List<Animal>> getAnimalsBySpecies({
    required String species,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final where = <String>['LOWER(species) = ?'];
    final args = <dynamic>[species.toLowerCase()];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await _db.db.query(
      'animals',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE',
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca animais por categoria com paginação
  Future<List<Animal>> getAnimalsByCategory({
    required String category,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final where = <String>['LOWER(category) = ?'];
    final args = <dynamic>[category.toLowerCase()];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await _db.db.query(
      'animals',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE',
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca animais grávidas com paginação
  Future<List<Animal>> getPregnantAnimals({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final where = <String>['pregnant = 1'];
    final args = <dynamic>[];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await _db.db.query(
      'animals',
      where: where.join(' AND '),
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'expected_delivery ASC, name COLLATE NOCASE',
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca reprodutores (machos e fêmeas) com paginação
  Future<List<Animal>> getReproducers({
    String? gender,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final where = <String>["LOWER(category) LIKE '%reprodutor%'"];
    final args = <dynamic>[];

    if (gender != null && gender.isNotEmpty) {
      where.add('LOWER(gender) = ?');
      args.add(gender.toLowerCase());
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await _db.db.query(
      'animals',
      where: where.join(' AND '),
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'name COLLATE NOCASE',
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca borregos (filhotes) com paginação
  Future<List<Animal>> getLambs({
    String? gender,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final where = <String>["LOWER(category) = 'borrego'"];
    final args = <dynamic>[];

    if (gender != null && gender.isNotEmpty) {
      where.add('LOWER(gender) = ?');
      args.add(gender.toLowerCase());
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await _db.db.query(
      'animals',
      where: where.join(' AND '),
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'birth_date DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca animais em tratamento com paginação
  Future<List<Animal>> getAnimalsInTreatment({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final where = <String>["status = 'Em tratamento'"];
    final args = <dynamic>[];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await _db.db.query(
      'animals',
      where: where.join(' AND '),
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'name COLLATE NOCASE',
      limit: limit,
      offset: offset,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Conta animais por filtros simples (sem carregar dados)
  Future<int> countAnimals({
    String? gender,
    String? species,
    String? category,
    bool? pregnant,
    String? status,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];

    if (gender != null && gender.isNotEmpty) {
      where.add('LOWER(gender) = ?');
      args.add(gender.toLowerCase());
    }

    if (species != null && species.isNotEmpty) {
      where.add('LOWER(species) = ?');
      args.add(species.toLowerCase());
    }

    if (category != null && category.isNotEmpty) {
      where.add('LOWER(category) = ?');
      args.add(category.toLowerCase());
    }

    if (pregnant != null) {
      where.add('pregnant = ?');
      args.add(pregnant ? 1 : 0);
    }

    if (status != null && status.isNotEmpty) {
      where.add('status = ?');
      args.add(status);
    }

    final result = await _db.db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM animals
      ${where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : ''}
      ''',
      args.isNotEmpty ? args : null,
    );

    if (result.isEmpty) return 0;
    final value = result.first['count'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Busca animais próximos do parto (próximos 30 dias) - otimizado para alertas
  Future<List<Animal>> getAnimalsNearDelivery({int daysAhead = 30}) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));
    
    final rows = await _db.db.query(
      'animals',
      where: 'pregnant = 1 AND expected_delivery IS NOT NULL AND expected_delivery <= ?',
      whereArgs: [futureDate.toIso8601String().split('T').first],
      orderBy: 'expected_delivery ASC',
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca borregos que completaram 120 dias e precisam de promoção para adulto
  Future<List<Animal>> getLambsReadyForPromotion() async {
    final now = DateTime.now();
    final date120DaysAgo = now.subtract(const Duration(days: 120));
    
    final rows = await _db.db.query(
      'animals',
      where: "LOWER(category) = 'borrego' AND birth_date <= ? AND weight_120_days > 0",
      whereArgs: [date120DaysAgo.toIso8601String().split('T').first],
      orderBy: 'birth_date ASC',
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca animais que precisam de pesagem em marco específico
  Future<List<Animal>> getAnimalsNeedingWeightCheck({
    required String milestone,
    required int daysOld,
    int toleranceDays = 3,
  }) async {
    final now = DateTime.now();
    final minDate = now.subtract(Duration(days: daysOld + toleranceDays));
    final maxDate = now.subtract(Duration(days: daysOld - toleranceDays));
    
    String? weightField;
    if (milestone == '30d') weightField = 'weight_30_days';
    if (milestone == '60d') weightField = 'weight_60_days';
    if (milestone == '90d') weightField = 'weight_90_days';
    if (milestone == '120d') weightField = 'weight_120_days';
    
    if (weightField == null) return [];
    
    final rows = await _db.db.query(
      'animals',
      where: 'birth_date >= ? AND birth_date <= ? AND ($weightField IS NULL OR $weightField = 0)',
      whereArgs: [
        minDate.toIso8601String().split('T').first,
        maxDate.toIso8601String().split('T').first,
      ],
      orderBy: 'birth_date ASC',
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }
}
