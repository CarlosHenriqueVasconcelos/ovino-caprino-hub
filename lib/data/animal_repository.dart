// lib/data/animal_repository.dart
import 'package:drift/drift.dart' show Variable;
import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;

import '../models/animal.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'animal_repository_read_queries.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

class AnimalRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;
  final AnimalRepositoryReadQueries _readQueries;
  AnimalRepository(
    AppDatabase db, {
    AppDriftDatabase? driftDb,
    String? Function()? farmIdProvider,
  })  : _db = db,
        _driftDb = driftDb,
        _farmIdProvider = farmIdProvider,
        _legacyBridge = driftDb == null
            ? null
            : LegacySqfliteToDriftBridge(
                legacyDb: db,
                driftDb: driftDb,
              ),
        _readQueries = AnimalRepositoryReadQueries(db, farmIdProvider: farmIdProvider);

  String? get _currentFarmId => _farmIdProvider?.call();

  List<Variable<Object>> _asVariables(List<Object?> args) {
    return args
        .map((arg) => Variable<Object>(arg as Object))
        .toList(growable: false);
  }

  Set<String> _genderVariants(String gender) {
    final value = gender.trim().toLowerCase();
    if (value == 'fêmea' || value == 'femea') {
      return const {'fêmea', 'femea'};
    }
    if (value == 'macho') {
      return const {'macho'};
    }
    return {value};
  }

  Set<String> _categoryVariants(String category) {
    final value = category.trim().toLowerCase();
    if (value == 'borrego' || value == 'borrega') {
      return const {'borrego', 'borrega'};
    }
    return {value};
  }

  Future<String?> _prepareFarmContext() async {
    final farmId = _currentFarmId;
    if (farmId == null || _driftDb == null) return null;
    await _legacyBridge?.migrateForFarm(farmId);
    return farmId;
  }

  // ----------------- CRUD básico de animals -----------------

  /// Retorna animais do rebanho.
  ///
  /// **Atenção:** sem [limit] retorna todos os registros — use somente para
  /// operações internas (breeding, kinship, sync). Para UI prefira os métodos
  /// paginados de [AnimalService] (herdQuery / weightTrackingQuery).
  ///
  /// Cap de segurança: [_kMaxSafeRows] linhas. Em debug emite aviso se
  /// excedido para facilitar detecção de uso inadvertido sem paginação.
  static const int _kMaxSafeRows = 3000;

  Future<List<Animal>> all({
    int? limit,
    int? offset,
    String orderBy = 'name COLLATE NOCASE',
  }) async {
    final effectiveLimit = limit ?? _kMaxSafeRows;

    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final sql = StringBuffer('SELECT * FROM animals WHERE farm_id = ? ')
        ..write('ORDER BY $orderBy ')
        ..write('LIMIT ? ');
      final args = <Object?>[farmId, effectiveLimit];
      if (offset != null) {
        sql.write('OFFSET ?');
        args.add(offset);
      }
      final rows = (await _driftDb!
              .customSelect(
                sql.toString(),
                variables: _asVariables(args),
              )
              .get())
          .map((r) => r.data)
          .toList();
      assert(
        rows.length < _kMaxSafeRows,
        'AnimalRepository.all() retornou ${rows.length} animais (≥ cap de '
        '$_kMaxSafeRows). Considere paginação ou aumentar _kMaxSafeRows.',
      );
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

    final rows = await _db.db.query(
      'animals',
      orderBy: orderBy,
      limit: effectiveLimit,
      offset: offset,
    );
    assert(
      rows.length < _kMaxSafeRows,
      'AnimalRepository.all() retornou ${rows.length} animais (≥ cap de '
      '$_kMaxSafeRows). Considere paginação ou aumentar _kMaxSafeRows.',
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<Animal?> getAnimalById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1',
        variables: _asVariables([farmId, id]),
      ).get();
      if (rows.isEmpty) return null;
      return Animal.fromMap(rows.first.data);
    }

    final maps = await _db.db.query(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Animal.fromMap(maps.first);
  }

  /// Busca múltiplos animais em uma única query WHERE id IN (...).
  /// Substitui o padrão N+1 de chamar getAnimalById N vezes.
  Future<List<Animal>> getAnimalsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final placeholders = List.filled(ids.length, '?').join(', ');
      final rows = (await _driftDb!
              .customSelect(
                'SELECT * FROM animals WHERE farm_id = ? AND id IN ($placeholders)',
                variables: _asVariables([farmId, ...ids]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await _db.db.rawQuery(
      'SELECT * FROM animals WHERE id IN ($placeholders)',
      ids,
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<List<Animal>> getOffspring(String parentId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE farm_id = ?
                  AND (mother_id = ? OR father_id = ?)
                ''',
                variables: _asVariables([farmId, parentId, parentId]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

    final maps = await _db.db.query(
      'animals',
      where: 'mother_id = ? OR father_id = ?',
      whereArgs: [parentId, parentId],
    );
    return maps.map((m) => Animal.fromMap(m)).toList();
  }

  Future<Map<String, ({int male, int female, int total})>>
      getOffspringGenderStatsByParentIds(List<String> parentIds) async {
    final normalizedIds = parentIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedIds.isEmpty) {
      return const <String, ({int male, int female, int total})>{};
    }

    final placeholders = List.filled(normalizedIds.length, '?').join(', ');
    final tables = <String>['animals', 'sold_animals', 'deceased_animals'];
    final stats = <String, ({int male, int female, int total})>{};

    bool isMale(String gender) => gender.startsWith('m');
    bool isFemale(String gender) => gender.startsWith('f');

    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      for (final table in tables) {
        final rows = (await _driftDb!
                .customSelect(
                  '''
                  SELECT mother_id AS parent_id, gender
                  FROM $table
                  WHERE farm_id = ? AND mother_id IN ($placeholders)
                  UNION ALL
                  SELECT father_id AS parent_id, gender
                  FROM $table
                  WHERE farm_id = ? AND father_id IN ($placeholders)
                  ''',
                  variables: _asVariables([
                    farmId,
                    ...normalizedIds,
                    farmId,
                    ...normalizedIds,
                  ]),
                )
                .get())
            .map((r) => r.data)
            .toList();

        for (final row in rows) {
          final parentId = row['parent_id']?.toString().trim() ?? '';
          if (parentId.isEmpty) continue;
          final gender = row['gender']?.toString().toLowerCase().trim() ?? '';
          final current = stats[parentId] ?? (male: 0, female: 0, total: 0);

          stats[parentId] = (
            male: current.male + (isMale(gender) ? 1 : 0),
            female: current.female + (isFemale(gender) ? 1 : 0),
            total: current.total + 1,
          );
        }
      }
      return Map.unmodifiable(stats);
    }

    for (final table in tables) {
      final rows = await _db.db.rawQuery(
        '''
        SELECT mother_id AS parent_id, gender
        FROM $table
        WHERE mother_id IN ($placeholders)
        UNION ALL
        SELECT father_id AS parent_id, gender
        FROM $table
        WHERE father_id IN ($placeholders)
        ''',
        <Object?>[...normalizedIds, ...normalizedIds],
      );

      for (final row in rows) {
        final parentId = row['parent_id']?.toString().trim() ?? '';
        if (parentId.isEmpty) continue;
        final gender = row['gender']?.toString().toLowerCase().trim() ?? '';
        final current = stats[parentId] ?? (male: 0, female: 0, total: 0);

        stats[parentId] = (
          male: current.male + (isMale(gender) ? 1 : 0),
          female: current.female + (isFemale(gender) ? 1 : 0),
          total: current.total + 1,
        );
      }
    }

    return Map.unmodifiable(stats);
  }

  /// Query filtrada para weight tracking (com paginação)
  Future<List<Animal>> getFilteredAnimals({
    int? ageMinMonths,
    int? ageMaxMonths,
    bool? excludeReproducers,
    bool? onlyReproducers,
    bool excludeLambs = false,
    bool includeSold = true,
    String? statusEquals,
    String? genderEquals,
    String? nameColor,
    String? categoryEquals,
    List<String>? categoryLikeAny,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId == null) {
      return _readQueries.getFilteredAnimals(
        ageMinMonths: ageMinMonths,
        ageMaxMonths: ageMaxMonths,
        excludeReproducers: excludeReproducers,
        onlyReproducers: onlyReproducers,
        excludeLambs: excludeLambs,
        includeSold: includeSold,
        statusEquals: statusEquals,
        genderEquals: genderEquals,
        nameColor: nameColor,
        categoryEquals: categoryEquals,
        categoryLikeAny: categoryLikeAny,
        searchQuery: searchQuery,
        limit: limit,
        offset: offset,
      );
    }

    final now = DateTime.now();
    final where = <String>['farm_id = ?'];
    final args = <Object?>[farmId];

    if (ageMinMonths != null) {
      final maxBirthDate = DateTime(now.year, now.month - ageMinMonths, now.day);
      where.add('birth_date <= ?');
      args.add(maxBirthDate.toIso8601String().split('T').first);
    }

    if (ageMaxMonths != null) {
      final minBirthDate = DateTime(now.year, now.month - ageMaxMonths, now.day);
      where.add('birth_date > ?');
      args.add(minBirthDate.toIso8601String().split('T').first);
    }

    if (excludeReproducers == true) {
      where.add("LOWER(category) NOT LIKE '%reprodutor%'");
    }

    if (onlyReproducers == true) {
      where.add("LOWER(category) LIKE '%reprodutor%'");
    }

    if (excludeLambs) {
      where.add(
        "(category IS NULL OR (LOWER(category) NOT LIKE '%borrego%' AND LOWER(category) NOT LIKE '%borrega%'))",
      );
    }

    if (statusEquals != null && statusEquals.isNotEmpty) {
      where.add('status = ?');
      args.add(statusEquals);
    }

    if (genderEquals != null && genderEquals.isNotEmpty) {
      final variants = _genderVariants(genderEquals).toList(growable: false);
      if (variants.isNotEmpty) {
        final placeholders = List.filled(variants.length, '?').join(',');
        where.add('LOWER(gender) IN ($placeholders)');
        args.addAll(variants);
      }
    }

    if (nameColor != null && nameColor.isNotEmpty) {
      where.add('name_color = ?');
      args.add(nameColor);
    }

    if (categoryEquals != null && categoryEquals.isNotEmpty) {
      final variants = _categoryVariants(categoryEquals).toList(growable: false);
      if (variants.length == 1) {
        where.add('LOWER(category) = ?');
        args.add(variants.first);
      } else {
        final placeholders = List.filled(variants.length, '?').join(',');
        where.add('LOWER(category) IN ($placeholders)');
        args.addAll(variants);
      }
    }

    if (categoryLikeAny != null && categoryLikeAny.isNotEmpty) {
      final likes = categoryLikeAny.map((_) => "LOWER(category) LIKE ?").join(' OR ');
      where.add('($likes)');
      args.addAll(categoryLikeAny.map((c) => '%${c.toLowerCase()}%'));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.add(query);
      args.add(query);
    }

    final sql = StringBuffer(
      'SELECT * FROM animals WHERE ${where.join(' AND ')} ORDER BY name COLLATE NOCASE ',
    );
    if (limit != null) {
      sql.write('LIMIT ? ');
      args.add(limit);
    } else if (offset != null) {
      sql.write('LIMIT -1 ');
    }
    if (offset != null) {
      sql.write('OFFSET ?');
      args.add(offset);
    }

    final rows = (await _driftDb!
            .customSelect(
              sql.toString(),
              variables: _asVariables(args),
            )
            .get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Busca paginada para autocompletes/listas rápidas com filtros simples.
  Future<List<Animal>> searchAnimals({
    String? gender,
    bool excludePregnant = false,
    List<String> excludeCategories = const [],
    String? searchQuery,
    bool includeArchived = false,
    int limit = 50,
    int offset = 0,
    String orderBy = 'name COLLATE NOCASE',
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId == null) {
      return _readQueries.searchAnimals(
        gender: gender,
        excludePregnant: excludePregnant,
        excludeCategories: excludeCategories,
        searchQuery: searchQuery,
        includeArchived: includeArchived,
        limit: limit,
        offset: offset,
        orderBy: orderBy,
      );
    }

    final where = <String>[];
    final args = <Object?>[];

    if (gender != null && gender.isNotEmpty) {
      final variants = _genderVariants(gender).toList(growable: false);
      final placeholders = List.filled(variants.length, '?').join(',');
      where.add('LOWER(gender) IN ($placeholders)');
      args.addAll(variants);
    }

    if (excludePregnant) {
      where.add('(pregnant IS NULL OR pregnant = 0)');
    }

    if (excludeCategories.isNotEmpty) {
      // NULL NOT IN (...) = NULL em SQL → exclui animais sem categoria.
      // Usar (category IS NULL OR ...) para mantê-los.
      final placeholders = List.filled(excludeCategories.length, '?').join(',');
      where.add(
          '(category IS NULL OR LOWER(category) NOT IN ($placeholders))');
      args.addAll(excludeCategories.map((c) => c.toLowerCase()));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ? OR LOWER(name_color) LIKE ?)');
      args.addAll([q, q, q]);
    }

    if (includeArchived) {
      final sql = '''
        SELECT *
        FROM (
          SELECT
            id, code, name, species, breed, gender, birth_date, weight, status,
            reproductive_status, location, last_vaccination, pregnant, expected_delivery,
            health_issue, registration_note, created_at, updated_at, name_color, category,
            birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
            year, lote, mother_id, father_id
          FROM animals WHERE farm_id = ?
          UNION ALL
          SELECT
            id, code, name, species, breed, gender, birth_date, weight, 'Vendido' AS status,
            reproductive_status, location, NULL AS last_vaccination, 0 AS pregnant,
            NULL AS expected_delivery, NULL AS health_issue, registration_note, created_at,
            updated_at, name_color, category, birth_weight, weight_30_days, weight_60_days,
            weight_90_days, weight_120_days, year, lote, mother_id, father_id
          FROM sold_animals WHERE farm_id = ?
          UNION ALL
          SELECT
            id, code, name, species, breed, gender, birth_date, weight, 'Óbito' AS status,
            reproductive_status, location, NULL AS last_vaccination, 0 AS pregnant,
            NULL AS expected_delivery, cause_of_death AS health_issue, registration_note,
            created_at, updated_at, name_color, category, birth_weight, weight_30_days,
            weight_60_days, weight_90_days, weight_120_days, year, lote, mother_id, father_id
          FROM deceased_animals WHERE farm_id = ?
        ) src
        ${where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : ''}
        ORDER BY name COLLATE NOCASE
        LIMIT ? OFFSET ?
      ''';
      final rows = (await _driftDb!
              .customSelect(
                sql,
                variables:
                    _asVariables([farmId, farmId, farmId, ...args, limit, offset]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

    final whereClauses = <String>['farm_id = ?', ...where];
    final rows = (await _driftDb!
            .customSelect(
              '''
              SELECT * FROM animals
              WHERE ${whereClauses.join(' AND ')}
              ORDER BY $orderBy
              LIMIT ? OFFSET ?
              ''',
              variables: _asVariables([farmId, ...args, limit, offset]),
            )
            .get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  /// Conta resultados para mesma query filtrada (evita carregar tudo)
  Future<int> countFilteredAnimals({
    int? ageMinMonths,
    int? ageMaxMonths,
    bool? excludeReproducers,
    bool? onlyReproducers,
    bool excludeLambs = false,
    bool includeSold = true,
    String? statusEquals,
    String? nameColor,
    String? categoryEquals,
    List<String>? categoryLikeAny,
    String? searchQuery,
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId == null) {
      return _readQueries.countFilteredAnimals(
        ageMinMonths: ageMinMonths,
        ageMaxMonths: ageMaxMonths,
        excludeReproducers: excludeReproducers,
        onlyReproducers: onlyReproducers,
        excludeLambs: excludeLambs,
        includeSold: includeSold,
        statusEquals: statusEquals,
        nameColor: nameColor,
        categoryEquals: categoryEquals,
        categoryLikeAny: categoryLikeAny,
        searchQuery: searchQuery,
      );
    }

    final now = DateTime.now();
    final where = <String>['farm_id = ?'];
    final args = <Object?>[farmId];

    if (ageMinMonths != null) {
      final maxBirthDate = DateTime(now.year, now.month - ageMinMonths, now.day);
      where.add('birth_date <= ?');
      args.add(maxBirthDate.toIso8601String().split('T').first);
    }
    if (ageMaxMonths != null) {
      final minBirthDate = DateTime(now.year, now.month - ageMaxMonths, now.day);
      where.add('birth_date > ?');
      args.add(minBirthDate.toIso8601String().split('T').first);
    }
    if (excludeReproducers == true) {
      where.add("LOWER(category) NOT LIKE '%reprodutor%'");
    }
    if (onlyReproducers == true) {
      where.add("LOWER(category) LIKE '%reprodutor%'");
    }
    if (excludeLambs) {
      where.add(
        "(category IS NULL OR (LOWER(category) NOT LIKE '%borrego%' AND LOWER(category) NOT LIKE '%borrega%'))",
      );
    }
    if (statusEquals != null && statusEquals.isNotEmpty) {
      where.add('status = ?');
      args.add(statusEquals);
    }
    if (nameColor != null && nameColor.isNotEmpty) {
      where.add('name_color = ?');
      args.add(nameColor);
    }
    if (categoryEquals != null && categoryEquals.isNotEmpty) {
      final variants = _categoryVariants(categoryEquals).toList(growable: false);
      if (variants.length == 1) {
        where.add('LOWER(category) = ?');
        args.add(variants.first);
      } else {
        final placeholders = List.filled(variants.length, '?').join(',');
        where.add('LOWER(category) IN ($placeholders)');
        args.addAll(variants);
      }
    }
    if (categoryLikeAny != null && categoryLikeAny.isNotEmpty) {
      final likes = categoryLikeAny.map((_) => "LOWER(category) LIKE ?").join(' OR ');
      where.add('($likes)');
      args.addAll(categoryLikeAny.map((c) => '%${c.toLowerCase()}%'));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.add(query);
      args.add(query);
    }

    final result = await _driftDb!.customSelect(
      'SELECT COUNT(*) AS count FROM animals WHERE ${where.join(' AND ')}',
      variables: _asVariables(args),
    ).getSingle();
    final value = result.data['count'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Lista de cores distintas para filtros (evita carregar todos os animais)
  Future<List<String>> getDistinctColors() async {
    final farmId = await _prepareFarmContext();
    if (farmId == null) return _readQueries.getDistinctColors();

    final rows = await _driftDb!.customSelect(
      '''
      SELECT DISTINCT name_color
      FROM animals
      WHERE farm_id = ? AND name_color IS NOT NULL AND name_color != ''
      ORDER BY name_color COLLATE NOCASE
      ''',
      variables: _asVariables([farmId]),
    ).get();
    return rows
        .map((row) => row.data['name_color']?.toString())
        .whereType<String>()
        .toList();
  }

  Future<List<String>> getDistinctCategories() async {
    final farmId = await _prepareFarmContext();
    if (farmId == null) return _readQueries.getDistinctCategories();

    final rows = await _driftDb!.customSelect(
      '''
      SELECT DISTINCT category
      FROM animals
      WHERE farm_id = ? AND category IS NOT NULL AND category != ''
      ORDER BY category COLLATE NOCASE
      ''',
      variables: _asVariables([farmId]),
    ).get();
    return rows
        .map((row) => row.data['category']?.toString())
        .whereType<String>()
        .toList();
  }

  Future<void> upsert(Animal a) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final row = Map<String, dynamic>.from(a.toMap())..['farm_id'] = farmId;
      final cols = row.keys.toList(growable: false);
      final placeholders = List.filled(cols.length, '?').join(',');
      final values = cols.map((c) => row[c]).toList(growable: false);
      await _driftDb!.customStatement(
        'INSERT OR REPLACE INTO animals (${cols.join(',')}) VALUES ($placeholders)',
        values,
      );
      return;
    }

    await _db.db.insert(
      'animals',
      a.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM animals WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

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
    final farmId = await _prepareFarmContext();
    final nowIso = DateTime.now().toIso8601String();

    if (farmId != null) {
      final id = 'wt_${DateTime.now().microsecondsSinceEpoch}';
      await _driftDb!.customStatement(
        '''
        INSERT OR REPLACE INTO animal_weights
        (id, farm_id, animal_id, date, weight, milestone, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          id,
          farmId,
          animalId,
          date.toIso8601String().split('T').first,
          weight,
          milestone,
          nowIso,
          nowIso,
        ],
      );

      final latestRow = await _driftDb.customSelect(
        '''
        SELECT weight FROM animal_weights
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY date DESC
        LIMIT 1
        ''',
        variables: _asVariables([farmId, animalId]),
      ).getSingleOrNull();
      final latestWeight = latestRow == null
          ? weight
          : ((latestRow.data['weight'] as num?)?.toDouble() ?? weight);

      final updateData = <String, dynamic>{'weight': latestWeight};
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

      final cols = updateData.keys.toList(growable: false);
      final setClause = cols.map((c) => '$c = ?').join(', ');
      final values = cols.map((c) => updateData[c]).toList(growable: false);
      await _driftDb.customStatement(
        'UPDATE animals SET $setClause WHERE farm_id = ? AND id = ?',
        [...values, farmId, animalId],
      );
      return;
    }

    final id = 'wt_${DateTime.now().microsecondsSinceEpoch}';
    await _db.db.insert('animal_weights', {
      'id': id,
      'animal_id': animalId,
      'date': date.toIso8601String().split('T').first,
      'weight': weight,
      'milestone': milestone,
      'created_at': nowIso,
      'updated_at': nowIso,
    });

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

  /// Garante que os marcos de peso cacheados em `animals`
  /// existam no histórico `animal_weights`.
  ///
  /// É idempotente: só insere quando não existe registro do marco.
  Future<void> ensureMilestoneWeightsInHistory({String? animalId}) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final nowIso = DateTime.now().toIso8601String();
      final animalFilter = animalId == null ? '' : ' AND a.id = ?';
      final scopedArgs = <Object?>[farmId, if (animalId != null) animalId];

      await _driftDb!.transaction(() async {
        await _driftDb.customStatement(
          '''
          INSERT OR IGNORE INTO animal_weights(id, farm_id, animal_id, date, weight, milestone, created_at, updated_at)
          SELECT
            'wtm_' || a.id || '_birth',
            a.farm_id,
            a.id,
            date(a.birth_date),
            a.birth_weight,
            'birth',
            ?,
            ?
          FROM animals a
          WHERE a.farm_id = ?
            AND a.birth_date IS NOT NULL
            AND trim(a.birth_date) != ''
            AND a.birth_weight IS NOT NULL
            AND a.birth_weight > 0
            $animalFilter
            AND NOT EXISTS (
              SELECT 1 FROM animal_weights w
              WHERE w.farm_id = a.farm_id
                AND w.animal_id = a.id
                AND w.milestone = 'birth'
            );
          ''',
          [nowIso, nowIso, ...scopedArgs],
        );

        await _driftDb.customStatement(
          '''
          INSERT OR IGNORE INTO animal_weights(id, farm_id, animal_id, date, weight, milestone, created_at, updated_at)
          SELECT
            'wtm_' || a.id || '_30d',
            a.farm_id,
            a.id,
            date(a.birth_date, '+30 day'),
            a.weight_30_days,
            '30d',
            ?,
            ?
          FROM animals a
          WHERE a.farm_id = ?
            AND a.birth_date IS NOT NULL
            AND trim(a.birth_date) != ''
            AND a.weight_30_days IS NOT NULL
            AND a.weight_30_days > 0
            $animalFilter
            AND NOT EXISTS (
              SELECT 1 FROM animal_weights w
              WHERE w.farm_id = a.farm_id
                AND w.animal_id = a.id
                AND w.milestone = '30d'
            );
          ''',
          [nowIso, nowIso, ...scopedArgs],
        );

        await _driftDb.customStatement(
          '''
          INSERT OR IGNORE INTO animal_weights(id, farm_id, animal_id, date, weight, milestone, created_at, updated_at)
          SELECT
            'wtm_' || a.id || '_60d',
            a.farm_id,
            a.id,
            date(a.birth_date, '+60 day'),
            a.weight_60_days,
            '60d',
            ?,
            ?
          FROM animals a
          WHERE a.farm_id = ?
            AND a.birth_date IS NOT NULL
            AND trim(a.birth_date) != ''
            AND a.weight_60_days IS NOT NULL
            AND a.weight_60_days > 0
            $animalFilter
            AND NOT EXISTS (
              SELECT 1 FROM animal_weights w
              WHERE w.farm_id = a.farm_id
                AND w.animal_id = a.id
                AND w.milestone = '60d'
            );
          ''',
          [nowIso, nowIso, ...scopedArgs],
        );

        await _driftDb.customStatement(
          '''
          INSERT OR IGNORE INTO animal_weights(id, farm_id, animal_id, date, weight, milestone, created_at, updated_at)
          SELECT
            'wtm_' || a.id || '_90d',
            a.farm_id,
            a.id,
            date(a.birth_date, '+90 day'),
            a.weight_90_days,
            '90d',
            ?,
            ?
          FROM animals a
          WHERE a.farm_id = ?
            AND a.birth_date IS NOT NULL
            AND trim(a.birth_date) != ''
            AND a.weight_90_days IS NOT NULL
            AND a.weight_90_days > 0
            $animalFilter
            AND NOT EXISTS (
              SELECT 1 FROM animal_weights w
              WHERE w.farm_id = a.farm_id
                AND w.animal_id = a.id
                AND w.milestone = '90d'
            );
          ''',
          [nowIso, nowIso, ...scopedArgs],
        );

        await _driftDb.customStatement(
          '''
          INSERT OR IGNORE INTO animal_weights(id, farm_id, animal_id, date, weight, milestone, created_at, updated_at)
          SELECT
            'wtm_' || a.id || '_120d',
            a.farm_id,
            a.id,
            date(a.birth_date, '+120 day'),
            a.weight_120_days,
            '120d',
            ?,
            ?
          FROM animals a
          WHERE a.farm_id = ?
            AND a.birth_date IS NOT NULL
            AND trim(a.birth_date) != ''
            AND a.weight_120_days IS NOT NULL
            AND a.weight_120_days > 0
            $animalFilter
            AND NOT EXISTS (
              SELECT 1 FROM animal_weights w
              WHERE w.farm_id = a.farm_id
                AND w.animal_id = a.id
                AND w.milestone = '120d'
            );
          ''',
          [nowIso, nowIso, ...scopedArgs],
        );
      });
      return;
    }

    final nowIso = DateTime.now().toIso8601String();
    final animalFilter = animalId == null ? '' : ' AND a.id = ?';
    final args = animalId == null ? const <Object?>[] : <Object?>[animalId];

    await _db.db.transaction((txn) async {
      await txn.rawInsert('''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_birth',
          a.id,
          date(a.birth_date),
          a.birth_weight,
          'birth',
          ?,
          ?
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.birth_weight IS NOT NULL
          AND a.birth_weight > 0
          $animalFilter
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = 'birth'
          );
      ''', [nowIso, nowIso, ...args]);

      await txn.rawInsert('''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_30d',
          a.id,
          date(a.birth_date, '+30 day'),
          a.weight_30_days,
          '30d',
          ?,
          ?
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.weight_30_days IS NOT NULL
          AND a.weight_30_days > 0
          $animalFilter
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = '30d'
          );
      ''', [nowIso, nowIso, ...args]);

      await txn.rawInsert('''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_60d',
          a.id,
          date(a.birth_date, '+60 day'),
          a.weight_60_days,
          '60d',
          ?,
          ?
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.weight_60_days IS NOT NULL
          AND a.weight_60_days > 0
          $animalFilter
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = '60d'
          );
      ''', [nowIso, nowIso, ...args]);

      await txn.rawInsert('''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_90d',
          a.id,
          date(a.birth_date, '+90 day'),
          a.weight_90_days,
          '90d',
          ?,
          ?
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.weight_90_days IS NOT NULL
          AND a.weight_90_days > 0
          $animalFilter
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = '90d'
          );
      ''', [nowIso, nowIso, ...args]);

      await txn.rawInsert('''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_120d',
          a.id,
          date(a.birth_date, '+120 day'),
          a.weight_120_days,
          '120d',
          ?,
          ?
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.weight_120_days IS NOT NULL
          AND a.weight_120_days > 0
          $animalFilter
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = '120d'
          );
      ''', [nowIso, nowIso, ...args]);
    });
  }

  Future<double?> latestWeight(String animalId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        '''
        SELECT weight FROM animal_weights
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY date DESC
        LIMIT 1
        ''',
        variables: _asVariables([farmId, animalId]),
      ).get();
      if (rows.isEmpty) return null;
      final v = rows.first.data['weight'];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        '''
        SELECT * FROM animal_weights
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY date DESC
        ''',
        variables: _asVariables([farmId, animalId]),
      ).get();
      return rows.map((r) => r.data).toList();
    }

    return await _db.db.query(
      'animal_weights',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'date DESC',
    );
  }

  /// Busca pesos mensais (para adultos)
  Future<List<Map<String, dynamic>>> getMonthlyWeights(String animalId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        '''
        SELECT * FROM animal_weights
        WHERE farm_id = ?
          AND animal_id = ?
          AND (milestone LIKE 'monthly_%' OR milestone IS NULL)
        ORDER BY date DESC
        LIMIT 24
        ''',
        variables: _asVariables([farmId, animalId]),
      ).get();
      return rows.map((r) => r.data).toList();
    }

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

  Future<void> clearMonthlyWeights(String animalId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        '''
        DELETE FROM animal_weights
        WHERE farm_id = ? AND animal_id = ? AND milestone LIKE 'monthly_%'
        ''',
        [farmId, animalId],
      );
      return;
    }

    await _db.db.delete(
      'animal_weights',
      where: "animal_id = ? AND milestone LIKE 'monthly_%'",
      whereArgs: [animalId],
    );
  }

  /// Busca peso específico por milestone (ex: '120d')
  Future<List<Map<String, dynamic>>> getWeightRecord(
    String animalId,
    String milestone,
  ) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        '''
        SELECT * FROM animal_weights
        WHERE farm_id = ? AND animal_id = ? AND milestone = ?
        ORDER BY date DESC
        LIMIT 1
        ''',
        variables: _asVariables([farmId, animalId, milestone]),
      ).get();
      return rows.map((r) => r.data).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      int firstInt(Object? v) {
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is String) return int.tryParse(v) ?? 0;
        return 0;
      }

      double firstDouble(Object? v) {
        if (v is double) return v;
        if (v is num) return v.toDouble();
        if (v is String) return double.tryParse(v) ?? 0.0;
        return 0.0;
      }

      Future<Object?> scalar(String sql, List<Object?> args) async {
        final row = await _driftDb!
            .customSelect(sql, variables: _asVariables(args))
            .getSingle();
        return row.data.values.first;
      }

      final totalAnimals = firstInt(
        await scalar('SELECT COUNT(*) AS c FROM animals WHERE farm_id = ?', [farmId]),
      );
      final healthy = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND status = ?',
          [farmId, 'Saudável'],
        ),
      );
      final pregnant = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND pregnant = 1',
          [farmId],
        ),
      );
      final underTreatment = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND status = ?',
          [farmId, 'Em tratamento'],
        ),
      );
      final maleReproducers = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND category = ? AND gender = ?',
          [farmId, 'Reprodutor', 'Macho'],
        ),
      );
      final maleLambs = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND category = ? AND gender = ?',
          [farmId, 'Borrego', 'Macho'],
        ),
      );
      final femaleLambs = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND category = ? AND gender = ?',
          [farmId, 'Borrego', 'Fêmea'],
        ),
      );
      final femaleReproducers = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND category = ? AND gender = ?',
          [farmId, 'Reprodutor', 'Fêmea'],
        ),
      );
      final revenue = firstDouble(
        await scalar(
          'SELECT SUM(amount) AS s FROM financial_records WHERE farm_id = ? AND type = ?',
          [farmId, 'receita'],
        ),
      );
      final avgWeight = firstDouble(
        await scalar('SELECT AVG(weight) AS w FROM animals WHERE farm_id = ?', [farmId]),
      );
      final ovinoCount = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND species = ?',
          [farmId, 'Ovino'],
        ),
      );
      final caprinoCount = firstInt(
        await scalar(
          'SELECT COUNT(*) AS c FROM animals WHERE farm_id = ? AND species = ?',
          [farmId, 'Caprino'],
        ),
      );
      final avgWeightOvino = firstDouble(
        await scalar(
          'SELECT AVG(weight) AS w FROM animals WHERE farm_id = ? AND species = ?',
          [farmId, 'Ovino'],
        ),
      );
      final avgWeightCaprino = firstDouble(
        await scalar(
          'SELECT AVG(weight) AS w FROM animals WHERE farm_id = ? AND species = ?',
          [farmId, 'Caprino'],
        ),
      );

      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      String isoDate(DateTime value) => value.toIso8601String().split('T').first;

      final vaccinesThisMonth = firstInt(
        await scalar(
          '''
          SELECT COUNT(*) AS c FROM vaccinations
          WHERE farm_id = ?
            AND COALESCE(applied_date, scheduled_date) >= ?
            AND COALESCE(applied_date, scheduled_date) <= ?
          ''',
          [farmId, isoDate(monthStart), isoDate(monthEnd)],
        ),
      );
      final birthsThisMonth = firstInt(
        await scalar(
          '''
          SELECT COUNT(*) AS c FROM animals
          WHERE farm_id = ?
            AND expected_delivery IS NOT NULL
            AND expected_delivery >= ?
            AND expected_delivery <= ?
          ''',
          [farmId, isoDate(monthStart), isoDate(monthEnd)],
        ),
      );

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
        ovinoCount: ovinoCount,
        caprinoCount: caprinoCount,
        avgWeightOvino: avgWeightOvino,
        avgWeightCaprino: avgWeightCaprino,
      );
    }

    // Legacy path: tenta usar farmId mesmo sem driftDb para preservar isolamento.
    final legacyFarmId = _currentFarmId;
    final fPrefix = legacyFarmId != null ? 'farm_id = ? AND ' : '';
    final fArg = legacyFarmId != null ? [legacyFarmId] : <Object?>[];
    final fWhere = legacyFarmId != null ? 'WHERE farm_id = ?' : '';

    Future<List<Map<String, Object?>>> q(String sql, [List<Object?> extra = const []]) =>
        _db.db.rawQuery(sql, [...fArg, ...extra]);

    // Contagens básicas
    final totalAnimals =
        _firstInt(await q('SELECT COUNT(*) AS c FROM animals $fWhere'));

    final healthy = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}status = ?",
      ['Saudável'],
    ));

    final pregnant = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}pregnant = 1",
    ));

    final underTreatment = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}status = ?",
      ['Em tratamento'],
    ));

    // Distribuição por categoria/gênero
    final maleReproducers = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}category = ? AND gender = ?",
      ['Reprodutor', 'Macho'],
    ));

    final maleLambs = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}category = ? AND gender = ?",
      ['Borrego', 'Macho'],
    ));

    final femaleLambs = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}category = ? AND gender = ?",
      ['Borrego', 'Fêmea'],
    ));

    final femaleReproducers = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}category = ? AND gender = ?",
      ['Reprodutor', 'Fêmea'],
    ));

    // Receita total (financeiro)
    final revenue = _firstDouble(await q(
      "SELECT SUM(amount) AS s FROM financial_records WHERE ${fPrefix}type = ?",
      ['receita'],
    ));

    // Peso médio do rebanho
    final avgWeight = _firstDouble(
      await q('SELECT AVG(weight) AS w FROM animals $fWhere'),
    );

    // Contagem e peso médio por espécie
    final ovinoCount = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}species = ?",
      ['Ovino'],
    ));
    final caprinoCount = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals WHERE ${fPrefix}species = ?",
      ['Caprino'],
    ));
    final avgWeightOvino = _firstDouble(await q(
      "SELECT AVG(weight) AS w FROM animals WHERE ${fPrefix}species = ?",
      ['Ovino'],
    ));
    final avgWeightCaprino = _firstDouble(await q(
      "SELECT AVG(weight) AS w FROM animals WHERE ${fPrefix}species = ?",
      ['Caprino'],
    ));

    // Mês atual YYYY-MM
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    String isoDate(DateTime value) => value.toIso8601String().split('T').first;

    // Vacinas aplicadas / agendadas neste mês
    final vaccinesThisMonth = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM vaccinations "
      "WHERE ${fPrefix}COALESCE(applied_date, scheduled_date) >= ? "
      "AND COALESCE(applied_date, scheduled_date) <= ?",
      [isoDate(monthStart), isoDate(monthEnd)],
    ));

    // Partos previstos neste mês
    final birthsThisMonth = _firstInt(await q(
      "SELECT COUNT(*) AS c FROM animals "
      "WHERE ${fPrefix}expected_delivery IS NOT NULL "
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
      ovinoCount: ovinoCount,
      caprinoCount: caprinoCount,
      avgWeightOvino: avgWeightOvino,
      avgWeightCaprino: avgWeightCaprino,
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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1',
        variables: _asVariables([farmId, animalId]),
      ).get();
      if (rows.isEmpty) throw Exception('Animal não encontrado');

      final animalData = rows.first.data;
      await _driftDb.customStatement(
        '''
        INSERT OR REPLACE INTO sold_animals(
          id, farm_id, original_animal_id, code, name, species, breed, gender,
          birth_date, weight, location, reproductive_status, name_color, category,
          birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
          year, lote, mother_id, father_id, registration_note,
          sale_date, sale_price, buyer, sale_notes, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ''',
        [
          animalData['id'],
          farmId,
          animalData['id'],
          animalData['code'],
          animalData['name'],
          animalData['species'],
          animalData['breed'],
          animalData['gender'],
          animalData['birth_date'],
          animalData['weight'],
          animalData['location'],
          animalData['reproductive_status'],
          animalData['name_color'],
          animalData['category'],
          animalData['birth_weight'],
          animalData['weight_30_days'],
          animalData['weight_60_days'],
          animalData['weight_90_days'],
          animalData['weight_120_days'],
          animalData['year'],
          animalData['lote'],
          animalData['mother_id'],
          animalData['father_id'],
          animalData['registration_note'],
          saleDate.toIso8601String().split('T').first,
          salePrice,
          buyer,
          notes,
        ],
      );

      await _driftDb.customStatement(
        'DELETE FROM animals WHERE farm_id = ? AND id = ?',
        [farmId, animalId],
      );
      return;
    }

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
      'reproductive_status': animalData['reproductive_status'],
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
      'registration_note': animalData['registration_note'],
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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.transaction(() async {
        final rows = await _driftDb.customSelect(
          'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1',
          variables: _asVariables([farmId, animalId]),
        ).get();
        if (rows.isEmpty) throw Exception('Animal não encontrado');

        final animalData = rows.first.data;
        await _driftDb.customStatement(
          '''
          INSERT OR REPLACE INTO deceased_animals(
            id, farm_id, original_animal_id, code, name, species, breed, gender,
            birth_date, weight, location, reproductive_status, name_color, category,
            birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
            year, lote, mother_id, father_id, registration_note,
            death_date, cause_of_death, death_notes, created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
          ''',
          [
            animalData['id'],
            farmId,
            animalData['id'],
            animalData['code'],
            animalData['name'],
            animalData['species'],
            animalData['breed'],
            animalData['gender'],
            animalData['birth_date'],
            animalData['weight'],
            animalData['location'],
            animalData['reproductive_status'],
            animalData['name_color'],
            animalData['category'],
            animalData['birth_weight'],
            animalData['weight_30_days'],
            animalData['weight_60_days'],
            animalData['weight_90_days'],
            animalData['weight_120_days'],
            animalData['year'],
            animalData['lote'],
            animalData['mother_id'],
            animalData['father_id'],
            animalData['registration_note'],
            deathDate.toIso8601String().split('T').first,
            causeOfDeath,
            notes,
          ],
        );

        await _driftDb.customStatement(
          'DELETE FROM animal_weights WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await _driftDb.customStatement(
          'DELETE FROM vaccinations WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );

        final meds = (await _driftDb
                .customSelect(
                  'SELECT id FROM medications WHERE farm_id = ? AND animal_id = ?',
                  variables: _asVariables([farmId, animalId]),
                )
                .get())
            .map((r) => r.data)
            .toList();
        for (final med in meds) {
          final medId = med['id']?.toString();
          if (medId == null || medId.isEmpty) continue;
          await _driftDb.customStatement(
            'DELETE FROM pharmacy_stock_movements WHERE farm_id = ? AND medication_id = ?',
            [farmId, medId],
          );
        }

        await _driftDb.customStatement(
          'DELETE FROM medications WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await _driftDb.customStatement(
          'DELETE FROM notes WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await _driftDb.customStatement(
          'DELETE FROM financial_records WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await _driftDb.customStatement(
          'DELETE FROM financial_accounts WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await _driftDb.customStatement(
          '''
          DELETE FROM breeding_records
          WHERE farm_id = ? AND (female_animal_id = ? OR male_animal_id = ?)
          ''',
          [farmId, animalId, animalId],
        );
        await _driftDb.customStatement(
          'DELETE FROM animals WHERE farm_id = ? AND id = ?',
          [farmId, animalId],
        );
      });
      return;
    }

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
          'reproductive_status': animalData['reproductive_status'],
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
          'registration_note': animalData['registration_note'],
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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>['farm_id = ?'];
      final args = <Object?>[farmId];
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final sql = StringBuffer(
        'SELECT * FROM sold_animals WHERE ${where.join(' AND ')} ORDER BY sale_date DESC ',
      );
      if (limit != null) {
        sql.write('LIMIT ? ');
        args.add(limit);
      } else if (offset != null) {
        sql.write('LIMIT -1 ');
      }
      if (offset != null) {
        sql.write('OFFSET ?');
        args.add(offset);
      }
      final rows = await _driftDb!
          .customSelect(sql.toString(), variables: _asVariables(args))
          .get();
      return rows.map((r) => r.data).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>['farm_id = ?'];
      final args = <Object?>[farmId];
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final sql = StringBuffer(
        'SELECT * FROM deceased_animals WHERE ${where.join(' AND ')} ORDER BY death_date DESC ',
      );
      if (limit != null) {
        sql.write('LIMIT ? ');
        args.add(limit);
      } else if (offset != null) {
        sql.write('LIMIT -1 ');
      }
      if (offset != null) {
        sql.write('OFFSET ?');
        args.add(offset);
      }
      final rows = await _driftDb!
          .customSelect(sql.toString(), variables: _asVariables(args))
          .get();
      return rows.map((r) => r.data).toList();
    }

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

    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final placeholders = List.filled(candidateNamesLower.length, '?').join(', ');
      final whereBuffer = StringBuffer()
        ..write('farm_id = ? AND LOWER(name_color) = ? AND LOWER(name) IN (')
        ..write(placeholders)
        ..write(')');
      final args = <Object?>[farmId, colorLower, ...candidateNamesLower];
      if (excludeId != null) {
        whereBuffer.write(' AND id <> ?');
        args.add(excludeId);
      }
      final rows = await _driftDb!.customSelect(
        '''
        SELECT id, name, name_color, category, lote
        FROM animals
        WHERE ${whereBuffer.toString()}
        ''',
        variables: _asVariables(args),
      ).get();
      return rows.map((r) => r.data).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final variants = _genderVariants(gender).toList(growable: false);
      final placeholders = List.filled(variants.length, '?').join(',');
      final where = <String>[
        'farm_id = ?',
        'LOWER(gender) IN ($placeholders)',
      ];
      final args = <Object?>[farmId, ...variants];

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE ${where.join(' AND ')}
                ORDER BY name COLLATE NOCASE
                LIMIT ? OFFSET ?
                ''',
                variables: _asVariables([...args, limit, offset]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>['farm_id = ?', 'LOWER(species) = ?'];
      final args = <Object?>[farmId, species.toLowerCase()];

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE ${where.join(' AND ')}
                ORDER BY name COLLATE NOCASE
                LIMIT ? OFFSET ?
                ''',
                variables: _asVariables([...args, limit, offset]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>['farm_id = ?', 'LOWER(category) = ?'];
      final args = <Object?>[farmId, category.toLowerCase()];

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE ${where.join(' AND ')}
                ORDER BY name COLLATE NOCASE
                LIMIT ? OFFSET ?
                ''',
                variables: _asVariables([...args, limit, offset]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>['farm_id = ?', 'pregnant = 1'];
      final args = <Object?>[farmId];

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE ${where.join(' AND ')}
                ORDER BY expected_delivery ASC, name COLLATE NOCASE
                LIMIT ? OFFSET ?
                ''',
                variables: _asVariables([...args, limit, offset]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>['farm_id = ?', "LOWER(category) LIKE '%reprodutor%'"];
      final args = <Object?>[farmId];

      if (gender != null && gender.isNotEmpty) {
        final variants = _genderVariants(gender).toList(growable: false);
        final placeholders = List.filled(variants.length, '?').join(',');
        where.add('LOWER(gender) IN ($placeholders)');
        args.addAll(variants);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE ${where.join(' AND ')}
                ORDER BY name COLLATE NOCASE
                LIMIT ? OFFSET ?
                ''',
                variables: _asVariables([...args, limit, offset]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>[
        'farm_id = ?',
        "(LOWER(category) = 'borrego' OR LOWER(category) = 'borrega')",
      ];
      final args = <Object?>[farmId];

      if (gender != null && gender.isNotEmpty) {
        final variants = _genderVariants(gender).toList(growable: false);
        final placeholders = List.filled(variants.length, '?').join(',');
        where.add('LOWER(gender) IN ($placeholders)');
        args.addAll(variants);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE ${where.join(' AND ')}
                ORDER BY birth_date DESC
                LIMIT ? OFFSET ?
                ''',
                variables: _asVariables([...args, limit, offset]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

    final where = <String>[
      "(LOWER(category) = 'borrego' OR LOWER(category) = 'borrega')",
    ];
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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>['farm_id = ?', "status = 'Em tratamento'"];
      final args = <Object?>[farmId];

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim().toLowerCase()}%';
        where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
        args.addAll([q, q]);
      }

      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE ${where.join(' AND ')}
                ORDER BY name COLLATE NOCASE
                LIMIT ? OFFSET ?
                ''',
                variables: _asVariables([...args, limit, offset]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final where = <String>['farm_id = ?'];
      final args = <Object?>[farmId];

      if (gender != null && gender.isNotEmpty) {
        final variants = _genderVariants(gender).toList(growable: false);
        final placeholders = List.filled(variants.length, '?').join(',');
        where.add('LOWER(gender) IN ($placeholders)');
        args.addAll(variants);
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

      final row = await _driftDb!
          .customSelect(
            'SELECT COUNT(*) AS count FROM animals WHERE ${where.join(' AND ')}',
            variables: _asVariables(args),
          )
          .getSingle();
      final value = row.data['count'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

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

    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE farm_id = ?
                  AND pregnant = 1
                  AND expected_delivery IS NOT NULL
                  AND expected_delivery <= ?
                ORDER BY expected_delivery ASC
                ''',
                variables: _asVariables([
                  farmId,
                  futureDate.toIso8601String().split('T').first,
                ]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

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

    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE farm_id = ?
                  AND (LOWER(category) = 'borrego' OR LOWER(category) = 'borrega')
                  AND birth_date <= ?
                  AND weight_120_days > 0
                ORDER BY birth_date ASC
                ''',
                variables: _asVariables([
                  farmId,
                  date120DaysAgo.toIso8601String().split('T').first,
                ]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

    final rows = await _db.db.query(
      'animals',
      where: "(LOWER(category) = 'borrego' OR LOWER(category) = 'borrega') AND birth_date <= ? AND weight_120_days > 0",
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

    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM animals
                WHERE farm_id = ?
                  AND birth_date >= ?
                  AND birth_date <= ?
                  AND ($weightField IS NULL OR $weightField = 0)
                ORDER BY birth_date ASC
                ''',
                variables: _asVariables([
                  farmId,
                  minDate.toIso8601String().split('T').first,
                  maxDate.toIso8601String().split('T').first,
                ]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

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
