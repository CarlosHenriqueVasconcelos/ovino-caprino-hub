import '../models/animal.dart';
import 'local_db.dart';

class AnimalRepositoryReadQueries {
  AnimalRepositoryReadQueries(this._db, {String? Function()? farmIdProvider})
      : _farmIdProvider = farmIdProvider;

  final AppDatabase _db;
  final String? Function()? _farmIdProvider;

  String? get _currentFarmId => _farmIdProvider?.call();

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
    final farmId = _currentFarmId;
    final now = DateTime.now();
    final buffer = StringBuffer();
    final args = <dynamic>[];

    if (farmId != null) {
      buffer.write('farm_id = ?');
      args.add(farmId);
    }

    if (ageMinMonths != null) {
      final maxBirthDate = DateTime(
        now.year,
        now.month - ageMinMonths,
        now.day,
      );
      if (buffer.isNotEmpty) buffer.write(' AND ');
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

    if (excludeLambs) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write(
        "(category IS NULL OR (LOWER(category) NOT LIKE '%borrego%' AND LOWER(category) NOT LIKE '%borrega%'))",
      );
    }

    if (includeSold) {
      // no-op: vendidos vivem em sold_animals (compat legado)
    }

    if (statusEquals != null && statusEquals.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('status = ?');
      args.add(statusEquals);
    }

    if (genderEquals != null && genderEquals.isNotEmpty) {
      final variants = _genderVariants(genderEquals);
      if (variants.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write(' AND ');
        final placeholders = List.filled(variants.length, '?').join(',');
        buffer.write('LOWER(gender) IN ($placeholders)');
        args.addAll(variants);
      }
    }

    if (nameColor != null && nameColor.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write('name_color = ?');
      args.add(nameColor);
    }

    if (categoryEquals != null && categoryEquals.isNotEmpty) {
      final variants = _categoryVariants(categoryEquals);
      if (variants.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write(' AND ');
        final placeholders = List.filled(variants.length, '?').join(',');
        buffer.write('LOWER(category) IN ($placeholders)');
        args.addAll(variants);
      }
    }

    if (categoryLikeAny != null && categoryLikeAny.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      final likes = categoryLikeAny.map((c) => "LOWER(category) LIKE ?").join(' OR ');
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
    final farmId = _currentFarmId;
    final where = <String>[];
    final args = <dynamic>[];

    if (farmId != null) {
      where.add('farm_id = ?');
      args.add(farmId);
    }

    if (gender != null && gender.isNotEmpty) {
      final variants = _genderVariants(gender);
      final placeholders = List.filled(variants.length, '?').join(',');
      where.add('LOWER(gender) IN ($placeholders)');
      args.addAll(variants);
    }

    if (excludePregnant) {
      where.add("(pregnant IS NULL OR pregnant = 0)");
    }

    if (excludeCategories.isNotEmpty) {
      final placeholders = List.filled(excludeCategories.length, '?').join(',');
      where.add(
          '(category IS NULL OR LOWER(category) NOT IN ($placeholders))');
      args.addAll(excludeCategories.map((c) => c.toLowerCase()));
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim().toLowerCase()}%';
      where.add(
        '(LOWER(name) LIKE ? OR LOWER(code) LIKE ? OR LOWER(name_color) LIKE ?)',
      );
      args.addAll([q, q, q]);
    }

    if (includeArchived) {
      // Farm filter must be applied inside each UNION sub-SELECT because
      // farm_id is not projected in the outer SELECT columns.
      final farmFilter = farmId != null ? 'WHERE farm_id = ?' : '';
      final farmArgs = farmId != null ? [farmId] : <dynamic>[];

      final rows = await _db.db.rawQuery(
          '''
          SELECT *
          FROM (
            SELECT
              id,
              code,
              name,
              species,
              breed,
              gender,
              birth_date,
              weight,
              status,
              reproductive_status,
              location,
              last_vaccination,
              pregnant,
              expected_delivery,
              health_issue,
              registration_note,
              created_at,
              updated_at,
              name_color,
              category,
              birth_weight,
              weight_30_days,
              weight_60_days,
              weight_90_days,
              weight_120_days,
              year,
              lote,
              mother_id,
              father_id
            FROM animals $farmFilter
            UNION ALL
            SELECT
              id,
              code,
              name,
              species,
              breed,
              gender,
              birth_date,
              weight,
              'Vendido' AS status,
              reproductive_status,
              location,
              NULL AS last_vaccination,
              0 AS pregnant,
              NULL AS expected_delivery,
              NULL AS health_issue,
              registration_note,
              created_at,
              updated_at,
              name_color,
              category,
              birth_weight,
              weight_30_days,
              weight_60_days,
              weight_90_days,
              weight_120_days,
              year,
              lote,
              mother_id,
              father_id
            FROM sold_animals $farmFilter
            UNION ALL
            SELECT
              id,
              code,
              name,
              species,
              breed,
              gender,
              birth_date,
              weight,
              'Óbito' AS status,
              reproductive_status,
              location,
              NULL AS last_vaccination,
              0 AS pregnant,
              NULL AS expected_delivery,
              cause_of_death AS health_issue,
              registration_note,
              created_at,
              updated_at,
              name_color,
              category,
              birth_weight,
              weight_30_days,
              weight_60_days,
              weight_90_days,
              weight_120_days,
              year,
              lote,
              mother_id,
              father_id
            FROM deceased_animals $farmFilter
          ) src
          ${where.isNotEmpty ? 'WHERE ${where.join(' AND ')}' : ''}
          ORDER BY name COLLATE NOCASE
          LIMIT ? OFFSET ?
          ''',
          [
            ...farmArgs, // animals farm filter
            ...farmArgs, // sold_animals farm filter
            ...farmArgs, // deceased_animals farm filter
            ...args,     // outer where args
            limit,
            offset,
          ],
        );
      return rows.map((m) => Animal.fromMap(m)).toList();
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
    final farmId = _currentFarmId;
    final now = DateTime.now();
    final buffer = StringBuffer();
    final args = <dynamic>[];

    if (farmId != null) {
      buffer.write('farm_id = ?');
      args.add(farmId);
    }

    if (ageMinMonths != null) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
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

    if (excludeLambs) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      buffer.write(
        "(category IS NULL OR (LOWER(category) NOT LIKE '%borrego%' AND LOWER(category) NOT LIKE '%borrega%'))",
      );
    }

    if (includeSold) {
      // no-op: vendidos vivem em sold_animals (compat legado)
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
      final variants = _categoryVariants(categoryEquals);
      if (variants.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write(' AND ');
        final placeholders = List.filled(variants.length, '?').join(',');
        buffer.write('LOWER(category) IN ($placeholders)');
        args.addAll(variants);
      }
    }

    if (categoryLikeAny != null && categoryLikeAny.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' AND ');
      final likes = categoryLikeAny.map((c) => "LOWER(category) LIKE ?").join(' OR ');
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

  Future<List<String>> getDistinctColors() async {
    final farmId = _currentFarmId;
    final where = farmId != null
        ? "WHERE farm_id = ? AND name_color IS NOT NULL AND name_color != ''"
        : "WHERE name_color IS NOT NULL AND name_color != ''";
    final args = farmId != null ? [farmId] : null;

    final rows = await _db.db.rawQuery(
      '''
      SELECT DISTINCT name_color
      FROM animals
      $where
      ORDER BY name_color COLLATE NOCASE
      ''',
      args,
    );
    return rows.map((row) => row['name_color']).whereType<String>().toList();
  }

  Future<List<String>> getDistinctCategories() async {
    final farmId = _currentFarmId;
    final where = farmId != null
        ? "WHERE farm_id = ? AND category IS NOT NULL AND category != ''"
        : "WHERE category IS NOT NULL AND category != ''";
    final args = farmId != null ? [farmId] : null;

    final rows = await _db.db.rawQuery(
      '''
      SELECT DISTINCT category
      FROM animals
      $where
      ORDER BY category COLLATE NOCASE
      ''',
      args,
    );
    return rows.map((row) => row['category']).whereType<String>().toList();
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
}
