import 'package:drift/drift.dart' show Variable;

import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

/// Repository para gerenciar vacinações
class VaccinationRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  VaccinationRepository(
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
              );

  String? get _currentFarmId => _farmIdProvider?.call();

  String _isoDate(DateTime value) => value.toIso8601String().split('T').first;

  List<Variable<Object>> _asVariables(List<Object?> args) {
    return args
        .map((arg) => Variable<Object>(arg as Object))
        .toList(growable: false);
  }

  Future<String?> _prepareFarmContext() async {
    final farmId = _currentFarmId;
    if (farmId == null || _driftDb == null) return null;
    await _legacyBridge?.migrateForFarm(farmId);
    return farmId;
  }

  String _buildPaginationClause({
    required int? limit,
    required int? offset,
    required List<Object?> args,
  }) {
    final buffer = StringBuffer();
    if (limit != null) {
      buffer.write(' LIMIT ?');
      args.add(limit);
    } else if (offset != null) {
      buffer.write(' LIMIT -1');
    }
    if (offset != null) {
      buffer.write(' OFFSET ?');
      args.add(offset);
    }
    return buffer.toString();
  }

  int _toCount(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<List<Map<String, dynamic>>> _driftSelect(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _driftDb!.customSelect(
      sql,
      variables: _asVariables(args),
    ).get();
    return rows.map((row) => Map<String, dynamic>.from(row.data)).toList();
  }

  Future<List<Map<String, dynamic>>> _queryWithAnimalInfo({
    required String baseWhere,
    required List<Object?> baseArgs,
    required String orderBy,
    required String dateColumn,
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    required bool driftMode,
  }) async {
    final args = <Object?>[...baseArgs];
    final filters = _buildFilters(
      args,
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      dateColumn: dateColumn,
    );
    final where = StringBuffer(baseWhere);
    if (filters.isNotEmpty) {
      where.write(' AND ${filters.join(' AND ')}');
    }
    final pagination = _buildPaginationClause(
      limit: limit,
      offset: offset,
      args: args,
    );

    final sql = '''
      SELECT
        v.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender,
        a.species AS animal_species,
        a.category AS animal_category
      FROM vaccinations v
      LEFT JOIN animals a ON a.id = v.animal_id${driftMode ? ' AND a.farm_id = v.farm_id' : ''}
      WHERE ${where.toString()}
      ORDER BY $orderBy$pagination
    ''';

    if (driftMode) {
      return _driftSelect(sql, args);
    }
    final rows = await _db.db.rawQuery(sql, args);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Retorna todas as vacinações
  Future<List<Map<String, dynamic>>> getAll({
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final args = <Object?>[farmId];
      final pagination = _buildPaginationClause(
        limit: limit,
        offset: offset,
        args: args,
      );
      return _driftSelect(
        'SELECT * FROM vaccinations WHERE farm_id = ? ORDER BY scheduled_date DESC$pagination',
        args,
      );
    }

    return _db.db.query(
      'vaccinations',
      orderBy: 'scheduled_date DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Retorna uma vacinação por ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        'SELECT * FROM vaccinations WHERE farm_id = ? AND id = ? LIMIT 1',
        [farmId, id],
      );
      if (rows.isEmpty) return null;
      return rows.first;
    }

    final maps = await _db.db.query(
      'vaccinations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Retorna vacinações de um animal específico
  Future<List<Map<String, dynamic>>> getByAnimalId(String animalId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT * FROM vaccinations
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY scheduled_date DESC
        ''',
        [farmId, animalId],
      );
    }

    return _db.db.query(
      'vaccinations',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'scheduled_date DESC',
    );
  }

  /// Retorna vacinações agendadas (status = 'Agendada')
  Future<List<Map<String, dynamic>>> getScheduled({
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final args = <Object?>[farmId, 'Agendada'];
      final pagination = _buildPaginationClause(
        limit: limit,
        offset: offset,
        args: args,
      );
      return _driftSelect(
        '''
        SELECT * FROM vaccinations
        WHERE farm_id = ? AND status = ?
        ORDER BY scheduled_date ASC$pagination
        ''',
        args,
      );
    }

    return _db.db.query(
      'vaccinations',
      where: 'status = ?',
      whereArgs: ['Agendada'],
      orderBy: 'scheduled_date ASC',
      limit: limit,
      offset: offset,
    );
  }

  /// Retorna vacinações por status
  Future<List<Map<String, dynamic>>> getByStatus(String status) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT * FROM vaccinations
        WHERE farm_id = ? AND status = ?
        ORDER BY scheduled_date DESC
        ''',
        [farmId, status],
      );
    }

    return _db.db.query(
      'vaccinations',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'scheduled_date DESC',
    );
  }

  /// Retorna vacinações vencidas (agendadas com data passada)
  Future<List<Map<String, dynamic>>> getOverdue() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT * FROM vaccinations
        WHERE farm_id = ?
          AND status = 'Agendada'
          AND scheduled_date < date('now')
        ORDER BY scheduled_date ASC
        ''',
        [farmId],
      );
    }

    final rows = await _db.db.rawQuery('''
      SELECT * FROM vaccinations
      WHERE status = 'Agendada'
      AND scheduled_date < date('now')
      ORDER BY scheduled_date ASC
    ''');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  /// Retorna vacinações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcoming(int daysThreshold) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT * FROM vaccinations
        WHERE farm_id = ?
          AND status = 'Agendada'
          AND scheduled_date >= date('now')
          AND scheduled_date <= date('now', '+$daysThreshold days')
        ORDER BY scheduled_date ASC
        ''',
        [farmId],
      );
    }

    final rows = await _db.db.rawQuery('''
      SELECT * FROM vaccinations
      WHERE status = 'Agendada'
      AND scheduled_date >= date('now')
      AND scheduled_date <= date('now', '+$daysThreshold days')
      ORDER BY scheduled_date ASC
    ''');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  /// Insere uma nova vacinação
  Future<void> insert(Map<String, dynamic> vaccination) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final row = Map<String, dynamic>.from(vaccination);
      row['farm_id'] = farmId;
      final cols = row.keys.toList(growable: false);
      final placeholders = List.filled(cols.length, '?').join(',');
      final args = cols.map((col) => row[col]).toList(growable: false);
      await _driftDb!.customStatement(
        'INSERT INTO vaccinations (${cols.join(',')}) VALUES ($placeholders)',
        args,
      );
      return;
    }

    await _db.db.insert('vaccinations', vaccination);
  }

  /// Atualiza uma vacinação
  Future<void> update(String id, Map<String, dynamic> updates) async {
    if (updates.isEmpty) return;

    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final setKeys = updates.keys.toList(growable: false);
      final setClause = setKeys.map((key) => '$key = ?').join(', ');
      final args = <Object?>[
        ...setKeys.map((key) => updates[key]),
        farmId,
        id,
      ];
      await _driftDb!.customStatement(
        '''
        UPDATE vaccinations
        SET $setClause
        WHERE farm_id = ? AND id = ?
        ''',
        args,
      );
      return;
    }

    await _db.db.update(
      'vaccinations',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deleta uma vacinação
  Future<void> delete(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM vaccinations WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.delete(
      'vaccinations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna vacinações com informações do animal (join)
  Future<List<Map<String, dynamic>>> getAllWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    return _queryWithAnimalInfo(
      baseWhere: farmId != null ? 'v.farm_id = ?' : '1 = 1',
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'v.scheduled_date DESC',
      dateColumn: 'v.scheduled_date',
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
      driftMode: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getOverdueWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    return _queryWithAnimalInfo(
      baseWhere: farmId != null
          ? "v.farm_id = ? AND v.status = 'Agendada' AND v.scheduled_date < date('now')"
          : "v.status = 'Agendada' AND v.scheduled_date < date('now')",
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'v.scheduled_date ASC',
      dateColumn: 'v.scheduled_date',
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
      driftMode: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getScheduledWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    return _queryWithAnimalInfo(
      baseWhere: farmId != null
          ? "v.farm_id = ? AND v.status = 'Agendada' AND v.scheduled_date >= date('now')"
          : "v.status = 'Agendada' AND v.scheduled_date >= date('now')",
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'v.scheduled_date ASC',
      dateColumn: 'v.scheduled_date',
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
      driftMode: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getAppliedWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    return _queryWithAnimalInfo(
      baseWhere: farmId != null
          ? "v.farm_id = ? AND v.status = 'Aplicada'"
          : "v.status = 'Aplicada'",
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'COALESCE(v.applied_date, v.scheduled_date) DESC',
      dateColumn: 'COALESCE(v.applied_date, v.scheduled_date)',
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
      driftMode: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getCancelledWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    return _queryWithAnimalInfo(
      baseWhere: farmId != null
          ? "v.farm_id = ? AND v.status = 'Cancelada'"
          : "v.status = 'Cancelada'",
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'v.scheduled_date DESC',
      dateColumn: 'v.scheduled_date',
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
      driftMode: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getVaccinationsOverdueWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return getOverdueWithAnimalInfo(
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>>
      getVaccinationsScheduledFutureWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return getScheduledWithAnimalInfo(
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getVaccinationsAppliedWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return getAppliedWithAnimalInfo(
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Contagens por status em uma única query — substitui 3 queries de limit:999
  /// Retorna {overdue, scheduled, applied}
  Future<({int overdue, int scheduled, int applied})> getKpiCounts() async {
    final farmId = await _prepareFarmContext();
    late final Map<String, dynamic> row;

    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT
          SUM(CASE WHEN status = 'Agendada' AND scheduled_date < date('now') THEN 1 ELSE 0 END) AS overdue,
          SUM(CASE WHEN status = 'Agendada' AND scheduled_date >= date('now') THEN 1 ELSE 0 END) AS scheduled,
          SUM(CASE WHEN status = 'Aplicada' THEN 1 ELSE 0 END) AS applied
        FROM vaccinations
        WHERE farm_id = ?
        ''',
        [farmId],
      );
      row = rows.first;
    } else {
      final rows = await _db.db.rawQuery('''
        SELECT
          SUM(CASE WHEN status = 'Agendada' AND scheduled_date < date('now') THEN 1 ELSE 0 END) AS overdue,
          SUM(CASE WHEN status = 'Agendada' AND scheduled_date >= date('now') THEN 1 ELSE 0 END) AS scheduled,
          SUM(CASE WHEN status = 'Aplicada' THEN 1 ELSE 0 END) AS applied
        FROM vaccinations
      ''');
      row = Map<String, dynamic>.from(rows.first);
    }

    return (
      overdue: _toCount(row['overdue']),
      scheduled: _toCount(row['scheduled']),
      applied: _toCount(row['applied']),
    );
  }

  Future<List<Map<String, dynamic>>> getVaccinationsCanceledWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    return getCancelledWithAnimalInfo(
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingAlertsWithin(
    DateTime horizon,
  ) async {
    final limit = _isoDate(horizon);
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT
          v.*,
          a.name AS animal_name,
          a.code AS animal_code,
          a.name_color AS animal_color,
          a.gender AS animal_gender
        FROM vaccinations v
        LEFT JOIN animals a ON a.id = v.animal_id AND a.farm_id = v.farm_id
        WHERE v.farm_id = ?
          AND v.status NOT IN ('Aplicada', 'Cancelada')
          AND v.scheduled_date <= ?
        ORDER BY v.scheduled_date ASC
        ''',
        [farmId, limit],
      );
    }

    final rows = await _db.db.rawQuery('''
      SELECT
        v.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender
      FROM vaccinations v
      LEFT JOIN animals a ON a.id = v.animal_id
      WHERE v.status NOT IN ('Aplicada', 'Cancelada')
        AND v.scheduled_date <= ?
      ORDER BY v.scheduled_date ASC
    ''', [limit]);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  List<String> _buildFilters(
    List<Object?> args, {
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    required String dateColumn,
  }) {
    final filters = <String>[];

    if (species != null && species.isNotEmpty) {
      filters.add("LOWER(COALESCE(a.species, '')) = ?");
      args.add(species.toLowerCase());
    }

    if (category != null && category.isNotEmpty) {
      filters.add("LOWER(COALESCE(a.category, '')) = ?");
      args.add(category.toLowerCase());
    }

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final like = '%${searchTerm.trim().toLowerCase()}%';
      filters.add(
        '('
        "LOWER(COALESCE(a.name, '')) LIKE ? OR "
        "LOWER(COALESCE(a.code, '')) LIKE ? OR "
        "LOWER(COALESCE(v.vaccine_name, '')) LIKE ? OR "
        "LOWER(COALESCE(v.notes, '')) LIKE ?"
        ')',
      );
      args.addAll([like, like, like, like]);
    }

    if (startDate != null) {
      filters.add('$dateColumn >= ?');
      args.add(_isoDate(startDate));
    }

    if (endDate != null) {
      filters.add('$dateColumn <= ?');
      args.add(_isoDate(endDate));
    }

    return filters;
  }
}
