// lib/data/animal_repository.dart
import 'package:drift/drift.dart' show Variable;

import '../models/animal.dart';
import 'drift/app_database.dart';

class AnimalRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  AnimalRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Set<String> _genderVariants(String gender) {
    final value = gender.trim().toLowerCase();
    if (value == 'fêmea' || value == 'femea') return const {'fêmea', 'femea'};
    if (value == 'macho') return const {'macho'};
    return {value};
  }

  Set<String> _categoryVariants(String category) {
    final value = category.trim().toLowerCase();
    if (value == 'borrego' || value == 'borrega') return const {'borrego', 'borrega'};
    return {value};
  }

  // ----------------- CRUD básico de animals -----------------

  /// Retorna animais do rebanho.
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
    final farmId = _farmId;

    final sql = StringBuffer('SELECT * FROM animals');
    final args = <Object?>[];
    if (farmId != null) {
      sql.write(' WHERE farm_id = ?');
      args.add(farmId);
    }
    sql.write(' ORDER BY $orderBy LIMIT ?');
    args.add(effectiveLimit);
    if (offset != null) {
      sql.write(' OFFSET ?');
      args.add(offset);
    }

    final rows = (await _db
            .customSelect(sql.toString(), variables: _vars(args))
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

  Future<Animal?> getAnimalById(String id) async {
    final farmId = _farmId;
    final rows = await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1'
          : 'SELECT * FROM animals WHERE id = ? LIMIT 1',
      variables: farmId != null ? _vars([farmId, id]) : _vars([id]),
    ).get();
    if (rows.isEmpty) return null;
    return Animal.fromMap(rows.first.data);
  }

  Future<List<Animal>> getAnimalsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final farmId = _farmId;
    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = (await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM animals WHERE farm_id = ? AND id IN ($placeholders)'
          : 'SELECT * FROM animals WHERE id IN ($placeholders)',
      variables: farmId != null ? _vars([farmId, ...ids]) : _vars(ids),
    ).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<List<Animal>> getOffspring(String parentId) async {
    final farmId = _farmId;
    final rows = (await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM animals WHERE farm_id = ? AND (mother_id = ? OR father_id = ?)'
          : 'SELECT * FROM animals WHERE mother_id = ? OR father_id = ?',
      variables: farmId != null
          ? _vars([farmId, parentId, parentId])
          : _vars([parentId, parentId]),
    ).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
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
    final farmId = _farmId;

    bool isMale(String gender) => gender.startsWith('m');
    bool isFemale(String gender) => gender.startsWith('f');

    for (final table in tables) {
      final rows = (await _db.customSelect(
        farmId != null
            ? '''
            SELECT mother_id AS parent_id, gender FROM $table
            WHERE farm_id = ? AND mother_id IN ($placeholders)
            UNION ALL
            SELECT father_id AS parent_id, gender FROM $table
            WHERE farm_id = ? AND father_id IN ($placeholders)
            '''
            : '''
            SELECT mother_id AS parent_id, gender FROM $table
            WHERE mother_id IN ($placeholders)
            UNION ALL
            SELECT father_id AS parent_id, gender FROM $table
            WHERE father_id IN ($placeholders)
            ''',
        variables: farmId != null
            ? _vars([farmId, ...normalizedIds, farmId, ...normalizedIds])
            : _vars([...normalizedIds, ...normalizedIds]),
      ).get())
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
    final farmId = _farmId;
    final now = DateTime.now();
    final where = <String>[];
    final args = <Object?>[];

    if (farmId != null) {
      where.add('farm_id = ?');
      args.add(farmId);
    }

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

    if (excludeReproducers == true) where.add("LOWER(category) NOT LIKE '%reprodutor%'");
    if (onlyReproducers == true) where.add("LOWER(category) LIKE '%reprodutor%'");

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
      final likes = categoryLikeAny.map((_) => 'LOWER(category) LIKE ?').join(' OR ');
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
      'SELECT * FROM animals${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'} ORDER BY name COLLATE NOCASE ',
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

    final rows = (await _db.customSelect(sql.toString(), variables: _vars(args)).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

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
    final farmId = _farmId;
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
      final placeholders = List.filled(excludeCategories.length, '?').join(',');
      where.add('(category IS NULL OR LOWER(category) NOT IN ($placeholders))');
      args.addAll(excludeCategories.map((c) => c.toLowerCase()));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ? OR LOWER(name_color) LIKE ?)');
      args.addAll([q, q, q]);
    }

    if (includeArchived) {
      final farmFilter = farmId != null ? 'WHERE farm_id = ?' : '';
      final farmArgs = farmId != null ? [farmId] : <Object?>[];
      final sql = '''
        SELECT *
        FROM (
          SELECT
            id, code, name, species, breed, gender, birth_date, weight, status,
            reproductive_status, location, last_vaccination, pregnant, expected_delivery,
            health_issue, registration_note, created_at, updated_at, name_color, category,
            birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
            year, lote, mother_id, father_id
          FROM animals $farmFilter
          UNION ALL
          SELECT
            id, code, name, species, breed, gender, birth_date, weight, 'Vendido' AS status,
            reproductive_status, location, NULL AS last_vaccination, 0 AS pregnant,
            NULL AS expected_delivery, NULL AS health_issue, registration_note, created_at,
            updated_at, name_color, category, birth_weight, weight_30_days, weight_60_days,
            weight_90_days, weight_120_days, year, lote, mother_id, father_id
          FROM sold_animals $farmFilter
          UNION ALL
          SELECT
            id, code, name, species, breed, gender, birth_date, weight, 'Óbito' AS status,
            reproductive_status, location, NULL AS last_vaccination, 0 AS pregnant,
            NULL AS expected_delivery, cause_of_death AS health_issue, registration_note,
            created_at, updated_at, name_color, category, birth_weight, weight_30_days,
            weight_60_days, weight_90_days, weight_120_days, year, lote, mother_id, father_id
          FROM deceased_animals $farmFilter
        ) src
        ${where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : ''}
        ORDER BY name COLLATE NOCASE
        LIMIT ? OFFSET ?
      ''';
      final rows = (await _db.customSelect(
        sql,
        variables: _vars([
          ...farmArgs, ...farmArgs, ...farmArgs, ...args, limit, offset,
        ]),
      ).get())
          .map((r) => r.data)
          .toList();
      return rows.map((m) => Animal.fromMap(m)).toList();
    }

    final whereClauses = <String>[
      if (farmId != null) 'farm_id = ?',
      ...where,
    ];
    final fullArgs = <Object?>[
      if (farmId != null) farmId,
      ...args,
    ];
    final rows = (await _db.customSelect(
      '''
      SELECT * FROM animals
      ${whereClauses.isEmpty ? '' : 'WHERE ${whereClauses.join(' AND ')}'}
      ORDER BY $orderBy
      LIMIT ? OFFSET ?
      ''',
      variables: _vars([...fullArgs, limit, offset]),
    ).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

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
    final farmId = _farmId;
    final now = DateTime.now();
    final where = <String>[];
    final args = <Object?>[];

    if (farmId != null) {
      where.add('farm_id = ?');
      args.add(farmId);
    }

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
    if (excludeReproducers == true) where.add("LOWER(category) NOT LIKE '%reprodutor%'");
    if (onlyReproducers == true) where.add("LOWER(category) LIKE '%reprodutor%'");
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
      final likes = categoryLikeAny.map((_) => 'LOWER(category) LIKE ?').join(' OR ');
      where.add('($likes)');
      args.addAll(categoryLikeAny.map((c) => '%${c.toLowerCase()}%'));
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.add(query);
      args.add(query);
    }

    final result = await _db.customSelect(
      'SELECT COUNT(*) AS count FROM animals'
      '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}',
      variables: _vars(args),
    ).getSingle();
    final value = result.data['count'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<List<String>> getDistinctColors() async {
    final farmId = _farmId;
    final where = farmId != null
        ? "WHERE farm_id = ? AND name_color IS NOT NULL AND name_color != ''"
        : "WHERE name_color IS NOT NULL AND name_color != ''";
    final rows = await _db.customSelect(
      'SELECT DISTINCT name_color FROM animals $where ORDER BY name_color COLLATE NOCASE',
      variables: farmId != null ? _vars([farmId]) : [],
    ).get();
    return rows.map((r) => r.data['name_color']?.toString()).whereType<String>().toList();
  }

  Future<List<String>> getDistinctCategories() async {
    final farmId = _farmId;
    final where = farmId != null
        ? "WHERE farm_id = ? AND category IS NOT NULL AND category != ''"
        : "WHERE category IS NOT NULL AND category != ''";
    final rows = await _db.customSelect(
      'SELECT DISTINCT category FROM animals $where ORDER BY category COLLATE NOCASE',
      variables: farmId != null ? _vars([farmId]) : [],
    ).get();
    return rows.map((r) => r.data['category']?.toString()).whereType<String>().toList();
  }

  Future<void> upsert(Animal a) async {
    final farmId = _farmId;
    final row = Map<String, dynamic>.from(a.toMap());
    if (farmId != null) row['farm_id'] = farmId;
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    final values = cols.map((c) => row[c]).toList(growable: false);
    await _db.customStatement(
      'INSERT OR REPLACE INTO animals (${cols.join(',')}) VALUES ($placeholders)',
      values,
    );
  }

  Future<void> delete(String id) async {
    final farmId = _farmId;
    await _db.customStatement(
      farmId != null
          ? 'DELETE FROM animals WHERE farm_id = ? AND id = ?'
          : 'DELETE FROM animals WHERE id = ?',
      farmId != null ? [farmId, id] : [id],
    );
  }

  // ----------------- Pesos / histórico de peso -----------------

  Future<void> addWeight(
    String animalId,
    DateTime date,
    double weight, {
    String? milestone,
  }) async {
    final farmId = _farmId;
    final nowIso = DateTime.now().toIso8601String();
    final id = 'wt_${DateTime.now().microsecondsSinceEpoch}';

    await _db.customStatement(
      farmId != null
          ? '''
          INSERT OR REPLACE INTO animal_weights
          (id, farm_id, animal_id, date, weight, milestone, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          '''
          : '''
          INSERT OR REPLACE INTO animal_weights
          (id, animal_id, date, weight, milestone, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
      farmId != null
          ? [id, farmId, animalId, date.toIso8601String().split('T').first, weight, milestone, nowIso, nowIso]
          : [id, animalId, date.toIso8601String().split('T').first, weight, milestone, nowIso, nowIso],
    );

    final latestRow = await _db.customSelect(
      farmId != null
          ? 'SELECT weight FROM animal_weights WHERE farm_id = ? AND animal_id = ? ORDER BY date DESC LIMIT 1'
          : 'SELECT weight FROM animal_weights WHERE animal_id = ? ORDER BY date DESC LIMIT 1',
      variables: farmId != null ? _vars([farmId, animalId]) : _vars([animalId]),
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
    await _db.customStatement(
      farmId != null
          ? 'UPDATE animals SET $setClause WHERE farm_id = ? AND id = ?'
          : 'UPDATE animals SET $setClause WHERE id = ?',
      farmId != null ? [...values, farmId, animalId] : [...values, animalId],
    );
  }

  Future<void> ensureMilestoneWeightsInHistory({String? animalId}) async {
    final farmId = _farmId;
    final nowIso = DateTime.now().toIso8601String();
    final animalFilter = animalId == null ? '' : ' AND a.id = ?';
    final scopedArgs = <Object?>[nowIso, nowIso];
    if (farmId != null) scopedArgs.add(farmId);
    if (animalId != null) scopedArgs.add(animalId);

    final farmWhere = farmId != null ? 'a.farm_id = ?' : '1=1';
    final farmIdVal = farmId != null ? "a.farm_id," : '';

    Future<void> insertMilestone(String milestoneId, String colName, String milestone, String dateExpr) async {
      await _db.customStatement(
        '''
        INSERT OR IGNORE INTO animal_weights(id, ${farmId != null ? 'farm_id, ' : ''}animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          '$milestoneId' || a.id || '_$milestone',
          $farmIdVal
          a.id,
          date($dateExpr),
          a.$colName,
          '$milestone',
          ?,
          ?
        FROM animals a
        WHERE $farmWhere
          AND a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.$colName IS NOT NULL
          AND a.$colName > 0
          $animalFilter
          AND NOT EXISTS (
            SELECT 1 FROM animal_weights w
            WHERE ${farmId != null ? 'w.farm_id = a.farm_id AND ' : ''}w.animal_id = a.id
              AND w.milestone = '$milestone'
          );
        ''',
        scopedArgs,
      );
    }

    await _db.transaction(() async {
      await insertMilestone('wtm_', 'birth_weight', 'birth', 'a.birth_date');
      await insertMilestone('wtm_', 'weight_30_days', '30d', "a.birth_date, '+30 day'");
      await insertMilestone('wtm_', 'weight_60_days', '60d', "a.birth_date, '+60 day'");
      await insertMilestone('wtm_', 'weight_90_days', '90d', "a.birth_date, '+90 day'");
      await insertMilestone('wtm_', 'weight_120_days', '120d', "a.birth_date, '+120 day'");
    });
  }

  Future<double?> latestWeight(String animalId) async {
    final farmId = _farmId;
    final rows = await _db.customSelect(
      farmId != null
          ? 'SELECT weight FROM animal_weights WHERE farm_id = ? AND animal_id = ? ORDER BY date DESC LIMIT 1'
          : 'SELECT weight FROM animal_weights WHERE animal_id = ? ORDER BY date DESC LIMIT 1',
      variables: farmId != null ? _vars([farmId, animalId]) : _vars([animalId]),
    ).get();
    if (rows.isEmpty) return null;
    final v = rows.first.data['weight'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  Future<List<Map<String, dynamic>>> getWeightHistory(String animalId) async {
    final farmId = _farmId;
    final rows = await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM animal_weights WHERE farm_id = ? AND animal_id = ? ORDER BY date DESC'
          : 'SELECT * FROM animal_weights WHERE animal_id = ? ORDER BY date DESC',
      variables: farmId != null ? _vars([farmId, animalId]) : _vars([animalId]),
    ).get();
    return rows.map((r) => r.data).toList();
  }

  Future<List<Map<String, dynamic>>> getMonthlyWeights(String animalId) async {
    final farmId = _farmId;
    final rows = await _db.customSelect(
      farmId != null
          ? "SELECT * FROM animal_weights WHERE farm_id = ? AND animal_id = ? AND (milestone LIKE 'monthly_%' OR milestone IS NULL) ORDER BY date DESC LIMIT 24"
          : "SELECT * FROM animal_weights WHERE animal_id = ? AND (milestone LIKE 'monthly_%' OR milestone IS NULL) ORDER BY date DESC LIMIT 24",
      variables: farmId != null ? _vars([farmId, animalId]) : _vars([animalId]),
    ).get();
    return rows.map((r) => r.data).toList();
  }

  Future<void> clearMonthlyWeights(String animalId) async {
    final farmId = _farmId;
    await _db.customStatement(
      farmId != null
          ? "DELETE FROM animal_weights WHERE farm_id = ? AND animal_id = ? AND milestone LIKE 'monthly_%'"
          : "DELETE FROM animal_weights WHERE animal_id = ? AND milestone LIKE 'monthly_%'",
      farmId != null ? [farmId, animalId] : [animalId],
    );
  }

  Future<List<Map<String, dynamic>>> getWeightRecord(
    String animalId,
    String milestone,
  ) async {
    final farmId = _farmId;
    final rows = await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM animal_weights WHERE farm_id = ? AND animal_id = ? AND milestone = ? ORDER BY date DESC LIMIT 1'
          : 'SELECT * FROM animal_weights WHERE animal_id = ? AND milestone = ? ORDER BY date DESC LIMIT 1',
      variables: farmId != null ? _vars([farmId, animalId, milestone]) : _vars([animalId, milestone]),
    ).get();
    return rows.map((r) => r.data).toList();
  }

  // ----------------- Estatísticas (AnimalStats) -----------------

  Future<AnimalStats> stats() async {
    final farmId = _farmId;

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
      final row = await _db.customSelect(sql, variables: _vars(args)).getSingle();
      return row.data.values.first;
    }

    final fPrefix = farmId != null ? 'WHERE farm_id = ? AND ' : 'WHERE ';
    final fWhere = farmId != null ? 'WHERE farm_id = ?' : '';
    final f = farmId != null ? [farmId] : <Object?>[];

    final totalAnimals = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals $fWhere', f),
    );
    final healthy = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}status = ?', [...f, 'Saudável']),
    );
    final pregnant = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}pregnant = 1', f),
    );
    final underTreatment = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}status = ?', [...f, 'Em tratamento']),
    );
    final maleReproducers = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}category = ? AND gender = ?', [...f, 'Reprodutor', 'Macho']),
    );
    final maleLambs = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}category = ? AND gender = ?', [...f, 'Borrego', 'Macho']),
    );
    final femaleLambs = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}category = ? AND gender = ?', [...f, 'Borrego', 'Fêmea']),
    );
    final femaleReproducers = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}category = ? AND gender = ?', [...f, 'Reprodutor', 'Fêmea']),
    );
    final injured = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}status = ?', [...f, 'Ferido']),
    );
    final matrices = firstInt(
      await scalar("SELECT COUNT(*) AS c FROM animals ${fPrefix}LOWER(category) LIKE '%matriz%'", f),
    );
    final sold = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM sold_animals $fWhere', f),
    );
    final deceased = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM deceased_animals $fWhere', f),
    );
    final revenue = firstDouble(
      await scalar('SELECT SUM(amount) AS s FROM financial_records ${fPrefix}type = ?', [...f, 'receita']),
    );
    final avgWeight = firstDouble(
      await scalar('SELECT AVG(weight) AS w FROM animals $fWhere', f),
    );
    final ovinoCount = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}species = ?', [...f, 'Ovino']),
    );
    final caprinoCount = firstInt(
      await scalar('SELECT COUNT(*) AS c FROM animals ${fPrefix}species = ?', [...f, 'Caprino']),
    );
    final avgWeightOvino = firstDouble(
      await scalar('SELECT AVG(weight) AS w FROM animals ${fPrefix}species = ?', [...f, 'Ovino']),
    );
    final avgWeightCaprino = firstDouble(
      await scalar('SELECT AVG(weight) AS w FROM animals ${fPrefix}species = ?', [...f, 'Caprino']),
    );

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    String isoDate(DateTime value) => value.toIso8601String().split('T').first;

    final vaccinesThisMonth = firstInt(
      await scalar(
        'SELECT COUNT(*) AS c FROM vaccinations '
        '${fPrefix}COALESCE(applied_date, scheduled_date) >= ? '
        'AND COALESCE(applied_date, scheduled_date) <= ?',
        [...f, isoDate(monthStart), isoDate(monthEnd)],
      ),
    );
    final birthsThisMonth = firstInt(
      await scalar(
        'SELECT COUNT(*) AS c FROM animals '
        '${fPrefix}expected_delivery IS NOT NULL '
        'AND expected_delivery >= ? AND expected_delivery <= ?',
        [...f, isoDate(monthStart), isoDate(monthEnd)],
      ),
    );

    return AnimalStats(
      totalAnimals: totalAnimals,
      healthy: healthy,
      pregnant: pregnant,
      underTreatment: underTreatment,
      injured: injured,
      matrices: matrices,
      sold: sold,
      deceased: deceased,
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

  Future<void> markAsSold({
    required String animalId,
    required DateTime saleDate,
    double? salePrice,
    String? buyer,
    String? notes,
  }) async {
    final farmId = _farmId;
    final rows = await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1'
          : 'SELECT * FROM animals WHERE id = ? LIMIT 1',
      variables: farmId != null ? _vars([farmId, animalId]) : _vars([animalId]),
    ).get();
    if (rows.isEmpty) throw Exception('Animal não encontrado');

    final d = rows.first.data;
    await _db.customStatement(
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
        d['id'], farmId, d['id'], d['code'], d['name'], d['species'], d['breed'], d['gender'],
        d['birth_date'], d['weight'], d['location'], d['reproductive_status'], d['name_color'],
        d['category'], d['birth_weight'], d['weight_30_days'], d['weight_60_days'],
        d['weight_90_days'], d['weight_120_days'], d['year'], d['lote'], d['mother_id'],
        d['father_id'], d['registration_note'],
        saleDate.toIso8601String().split('T').first, salePrice, buyer, notes,
      ],
    );
    await _db.customStatement(
      farmId != null
          ? 'DELETE FROM animals WHERE farm_id = ? AND id = ?'
          : 'DELETE FROM animals WHERE id = ?',
      farmId != null ? [farmId, animalId] : [animalId],
    );
  }

  Future<void> markAsDeceased({
    required String animalId,
    required DateTime deathDate,
    String? causeOfDeath,
    String? notes,
  }) async {
    final farmId = _farmId;
    await _db.transaction(() async {
      final rows = await _db.customSelect(
        farmId != null
            ? 'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1'
            : 'SELECT * FROM animals WHERE id = ? LIMIT 1',
        variables: farmId != null ? _vars([farmId, animalId]) : _vars([animalId]),
      ).get();
      if (rows.isEmpty) throw Exception('Animal não encontrado');

      final d = rows.first.data;
      await _db.customStatement(
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
          d['id'], farmId, d['id'], d['code'], d['name'], d['species'], d['breed'], d['gender'],
          d['birth_date'], d['weight'], d['location'], d['reproductive_status'], d['name_color'],
          d['category'], d['birth_weight'], d['weight_30_days'], d['weight_60_days'],
          d['weight_90_days'], d['weight_120_days'], d['year'], d['lote'], d['mother_id'],
          d['father_id'], d['registration_note'],
          deathDate.toIso8601String().split('T').first, causeOfDeath, notes,
        ],
      );

      Future<void> stmt(String withFarm, String without, [List<Object?> extra = const []]) async {
        if (farmId != null) {
          await _db.customStatement(withFarm, [farmId, animalId, ...extra]);
        } else {
          await _db.customStatement(without, [animalId, ...extra]);
        }
      }

      await stmt(
        'DELETE FROM animal_weights WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM animal_weights WHERE animal_id = ?',
      );
      await stmt(
        'DELETE FROM vaccinations WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM vaccinations WHERE animal_id = ?',
      );

      final meds = await _db.customSelect(
        farmId != null
            ? 'SELECT id FROM medications WHERE farm_id = ? AND animal_id = ?'
            : 'SELECT id FROM medications WHERE animal_id = ?',
        variables: farmId != null ? _vars([farmId, animalId]) : _vars([animalId]),
      ).get();
      for (final med in meds) {
        final medId = med.data['id']?.toString();
        if (medId == null || medId.isEmpty) continue;
        if (farmId != null) {
          await _db.customStatement(
            'DELETE FROM pharmacy_stock_movements WHERE farm_id = ? AND medication_id = ?',
            [farmId, medId],
          );
        } else {
          await _db.customStatement(
            'DELETE FROM pharmacy_stock_movements WHERE medication_id = ?',
            [medId],
          );
        }
      }

      await stmt(
        'DELETE FROM medications WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM medications WHERE animal_id = ?',
      );
      await stmt(
        'DELETE FROM notes WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM notes WHERE animal_id = ?',
      );
      await stmt(
        'DELETE FROM financial_records WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM financial_records WHERE animal_id = ?',
      );
      await stmt(
        'DELETE FROM financial_accounts WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM financial_accounts WHERE animal_id = ?',
      );

      if (farmId != null) {
        await _db.customStatement(
          'DELETE FROM breeding_records WHERE farm_id = ? AND (female_animal_id = ? OR male_animal_id = ?)',
          [farmId, animalId, animalId],
        );
      } else {
        await _db.customStatement(
          'DELETE FROM breeding_records WHERE female_animal_id = ? OR male_animal_id = ?',
          [animalId, animalId],
        );
      }

      await stmt(
        'DELETE FROM animals WHERE farm_id = ? AND id = ?',
        'DELETE FROM animals WHERE id = ?',
      );
    });
  }

  Future<List<Map<String, dynamic>>> getSoldAnimals({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    final farmId = _farmId;
    final where = <String>[];
    final args = <Object?>[];

    if (farmId != null) {
      where.add('farm_id = ?');
      args.add(farmId);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final sql = StringBuffer(
      'SELECT * FROM sold_animals${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'} ORDER BY sale_date DESC ',
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
    final rows = await _db.customSelect(sql.toString(), variables: _vars(args)).get();
    return rows.map((r) => r.data).toList();
  }

  Future<List<Map<String, dynamic>>> getDeceasedAnimals({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    final farmId = _farmId;
    final where = <String>[];
    final args = <Object?>[];

    if (farmId != null) {
      where.add('farm_id = ?');
      args.add(farmId);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final sql = StringBuffer(
      'SELECT * FROM deceased_animals${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'} ORDER BY death_date DESC ',
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
    final rows = await _db.customSelect(sql.toString(), variables: _vars(args)).get();
    return rows.map((r) => r.data).toList();
  }

  Future<List<Map<String, dynamic>>> findIdentityConflicts({
    required List<String> candidateNamesLower,
    required String colorLower,
    String? excludeId,
  }) async {
    if (candidateNamesLower.isEmpty) return [];
    final farmId = _farmId;
    final placeholders = List.filled(candidateNamesLower.length, '?').join(', ');
    final where = StringBuffer();
    final args = <Object?>[];

    if (farmId != null) {
      where.write('farm_id = ? AND ');
      args.add(farmId);
    }
    where.write('LOWER(name_color) = ? AND LOWER(name) IN ($placeholders)');
    args.add(colorLower);
    args.addAll(candidateNamesLower);

    if (excludeId != null) {
      where.write(' AND id <> ?');
      args.add(excludeId);
    }

    final rows = await _db.customSelect(
      'SELECT id, name, name_color, category, lote FROM animals WHERE $where',
      variables: _vars(args),
    ).get();
    return rows.map((r) => r.data).toList();
  }

  Future<List<Animal>> getAnimalsByGender({
    required String gender,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final farmId = _farmId;
    final variants = _genderVariants(gender).toList(growable: false);
    final placeholders = List.filled(variants.length, '?').join(',');
    final where = <String>[
      if (farmId != null) 'farm_id = ?',
      'LOWER(gender) IN ($placeholders)',
    ];
    final args = <Object?>[
      if (farmId != null) farmId,
      ...variants,
    ];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = (await _db.customSelect(
      'SELECT * FROM animals WHERE ${where.join(' AND ')} ORDER BY name COLLATE NOCASE LIMIT ? OFFSET ?',
      variables: _vars([...args, limit, offset]),
    ).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<List<Animal>> getAnimalsBySpecies({
    required String species,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final farmId = _farmId;
    final where = <String>[
      if (farmId != null) 'farm_id = ?',
      'LOWER(species) = ?',
    ];
    final args = <Object?>[
      if (farmId != null) farmId,
      species.toLowerCase(),
    ];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = (await _db.customSelect(
      'SELECT * FROM animals WHERE ${where.join(' AND ')} ORDER BY name COLLATE NOCASE LIMIT ? OFFSET ?',
      variables: _vars([...args, limit, offset]),
    ).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<List<Animal>> getAnimalsByCategory({
    required String category,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final farmId = _farmId;
    final where = <String>[
      if (farmId != null) 'farm_id = ?',
      'LOWER(category) = ?',
    ];
    final args = <Object?>[
      if (farmId != null) farmId,
      category.toLowerCase(),
    ];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = (await _db.customSelect(
      'SELECT * FROM animals WHERE ${where.join(' AND ')} ORDER BY name COLLATE NOCASE LIMIT ? OFFSET ?',
      variables: _vars([...args, limit, offset]),
    ).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<List<Animal>> getPregnantAnimals({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final farmId = _farmId;
    final where = <String>[
      if (farmId != null) 'farm_id = ?',
      'pregnant = 1',
    ];
    final args = <Object?>[
      if (farmId != null) farmId,
    ];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add('(LOWER(name) LIKE ? OR LOWER(code) LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = (await _db.customSelect(
      'SELECT * FROM animals WHERE ${where.join(' AND ')} ORDER BY expected_delivery ASC, name COLLATE NOCASE LIMIT ? OFFSET ?',
      variables: _vars([...args, limit, offset]),
    ).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  Future<List<Animal>> getReproducers({
    String? gender,
    int limit = 50,
    int offset = 0,
    String? searchQuery,
  }) async {
    final farmId = _farmId;
    final where = <String>[
      if (farmId != null) 'farm_id = ?',
      "LOWER(category) LIKE '%reprodutor%'",
    ];
    final args = <Object?>[
      if (farmId != null) farmId,
    ];

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

    final rows = (await _db.customSelect(
      'SELECT * FROM animals WHERE ${where.join(' AND ')} ORDER BY name COLLATE NOCASE LIMIT ? OFFSET ?',
      variables: _vars([...args, limit, offset]),
    ).get())
        .map((r) => r.data)
        .toList();
    return rows.map((m) => Animal.fromMap(m)).toList();
  }
}
