import 'package:drift/drift.dart' show Variable;

import '../models/animal.dart';
import 'drift/app_database.dart';

class AnimalRepositoryReadQueries {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  AnimalRepositoryReadQueries(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _currentFarmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

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
      final variants = _genderVariants(genderEquals);
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
      final variants = _categoryVariants(categoryEquals);
      if (variants.isNotEmpty) {
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

    final sql = StringBuffer('SELECT * FROM animals');
    if (where.isNotEmpty) sql.write(' WHERE ${where.join(' AND ')}');
    sql.write(' ORDER BY name COLLATE NOCASE');
    if (limit != null) {
      sql.write(' LIMIT ?');
      args.add(limit);
    } else if (offset != null) {
      sql.write(' LIMIT -1');
    }
    if (offset != null) {
      sql.write(' OFFSET ?');
      args.add(offset);
    }

    final rows = await _db.customSelect(sql.toString(), variables: _vars(args)).get();
    return rows.map((r) => Animal.fromMap(r.data)).toList();
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
    final args = <Object?>[];

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
      final outerWhere = where
          .where((c) => !c.startsWith('farm_id'))
          .toList(growable: false);
      final outerArgs = args.skip(farmId != null ? 1 : 0).toList(growable: false);

      final sql = '''
        SELECT *
        FROM (
          SELECT id, code, name, species, breed, gender, birth_date, weight, status,
            reproductive_status, location, last_vaccination, pregnant, expected_delivery,
            health_issue, registration_note, created_at, updated_at, name_color, category,
            birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
            year, lote, mother_id, father_id
          FROM animals $farmFilter
          UNION ALL
          SELECT id, code, name, species, breed, gender, birth_date, weight,
            'Vendido' AS status, reproductive_status, location,
            NULL AS last_vaccination, 0 AS pregnant, NULL AS expected_delivery,
            NULL AS health_issue, registration_note, created_at, updated_at,
            name_color, category, birth_weight, weight_30_days, weight_60_days,
            weight_90_days, weight_120_days, year, lote, mother_id, father_id
          FROM sold_animals $farmFilter
          UNION ALL
          SELECT id, code, name, species, breed, gender, birth_date, weight,
            'Óbito' AS status, reproductive_status, location,
            NULL AS last_vaccination, 0 AS pregnant, NULL AS expected_delivery,
            cause_of_death AS health_issue, registration_note, created_at, updated_at,
            name_color, category, birth_weight, weight_30_days, weight_60_days,
            weight_90_days, weight_120_days, year, lote, mother_id, father_id
          FROM deceased_animals $farmFilter
        ) src
        ${outerWhere.isNotEmpty ? 'WHERE ${outerWhere.join(' AND ')}' : ''}
        ORDER BY name COLLATE NOCASE
        LIMIT ? OFFSET ?
      ''';
      final rows = await _db.customSelect(
        sql,
        variables: _vars([
          ...farmArgs, ...farmArgs, ...farmArgs,
          ...outerArgs,
          limit, offset,
        ]),
      ).get();
      return rows.map((r) => Animal.fromMap(r.data)).toList();
    }

    final sql = StringBuffer('SELECT * FROM animals');
    if (where.isNotEmpty) sql.write(' WHERE ${where.join(' AND ')}');
    sql.write(' ORDER BY $orderBy LIMIT ? OFFSET ?');
    args.addAll([limit, offset]);

    final rows = await _db.customSelect(sql.toString(), variables: _vars(args)).get();
    return rows.map((r) => Animal.fromMap(r.data)).toList();
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
      final variants = _categoryVariants(categoryEquals);
      if (variants.isNotEmpty) {
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

    final sql = 'SELECT COUNT(*) AS count FROM animals'
        '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}';
    final row = await _db.customSelect(sql, variables: _vars(args)).getSingle();
    final value = row.data['count'];
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
    final rows = await _db.customSelect(
      'SELECT DISTINCT name_color FROM animals $where ORDER BY name_color COLLATE NOCASE',
      variables: farmId != null ? _vars([farmId]) : [],
    ).get();
    return rows.map((r) => r.data['name_color']).whereType<String>().toList();
  }

  Future<List<String>> getDistinctCategories() async {
    final farmId = _currentFarmId;
    final where = farmId != null
        ? "WHERE farm_id = ? AND category IS NOT NULL AND category != ''"
        : "WHERE category IS NOT NULL AND category != ''";
    final rows = await _db.customSelect(
      'SELECT DISTINCT category FROM animals $where ORDER BY category COLLATE NOCASE',
      variables: farmId != null ? _vars([farmId]) : [],
    ).get();
    return rows.map((r) => r.data['category']).whereType<String>().toList();
  }

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
}
