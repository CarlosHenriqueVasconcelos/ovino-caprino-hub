import 'package:drift/drift.dart' show Variable;

import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

/// Repository para gerenciar medicações
class MedicationRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  MedicationRepository(
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

  String _isoDate(DateTime value) => value.toIso8601String().split('T').first;

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
        m.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender,
        a.species AS animal_species,
        a.category AS animal_category
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id${driftMode ? ' AND a.farm_id = m.farm_id' : ''}
      WHERE ${where.toString()}
      ORDER BY $orderBy$pagination
    ''';

    if (driftMode) {
      return _driftSelect(sql, args);
    }
    final rows = await _db.db.rawQuery(sql, args);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Retorna todas as medicações
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
        'SELECT * FROM medications WHERE farm_id = ? ORDER BY date DESC$pagination',
        args,
      );
    }

    return _db.db.query(
      'medications',
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Retorna uma medicação por ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        'SELECT * FROM medications WHERE farm_id = ? AND id = ? LIMIT 1',
        [farmId, id],
      );
      if (rows.isEmpty) return null;
      return rows.first;
    }

    final maps = await _db.db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Retorna medicações de um animal específico
  Future<List<Map<String, dynamic>>> getByAnimalId(String animalId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT * FROM medications
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY date DESC
        ''',
        [farmId, animalId],
      );
    }

    return _db.db.query(
      'medications',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'date DESC',
    );
  }

  /// Retorna medicações agendadas (status = 'Agendado')
  Future<List<Map<String, dynamic>>> getScheduled({
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final args = <Object?>[farmId, 'Agendado'];
      final pagination = _buildPaginationClause(
        limit: limit,
        offset: offset,
        args: args,
      );
      return _driftSelect(
        '''
        SELECT * FROM medications
        WHERE farm_id = ? AND status = ?
        ORDER BY date ASC$pagination
        ''',
        args,
      );
    }

    return _db.db.query(
      'medications',
      where: 'status = ?',
      whereArgs: ['Agendado'],
      orderBy: 'date ASC',
      limit: limit,
      offset: offset,
    );
  }

  /// Retorna medicações por status
  Future<List<Map<String, dynamic>>> getByStatus(
    String status, {
    int? limit,
    int? offset,
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final args = <Object?>[farmId, status];
      final pagination = _buildPaginationClause(
        limit: limit,
        offset: offset,
        args: args,
      );
      return _driftSelect(
        '''
        SELECT * FROM medications
        WHERE farm_id = ? AND status = ?
        ORDER BY date DESC$pagination
        ''',
        args,
      );
    }

    return _db.db.query(
      'medications',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Retorna medicações vencidas (agendadas com data passada)
  Future<List<Map<String, dynamic>>> getOverdue({
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
        '''
        SELECT * FROM medications
        WHERE farm_id = ?
          AND status = 'Agendado'
          AND COALESCE(date, next_date) < date('now')
        ORDER BY COALESCE(date, next_date) ASC$pagination
        ''',
        args,
      );
    }

    final args = <Object?>[];
    final pagination = _buildPaginationClause(
      limit: limit,
      offset: offset,
      args: args,
    );
    final rows = await _db.db.rawQuery('''
      SELECT * FROM medications
      WHERE status = 'Agendado'
      AND COALESCE(date, next_date) < date('now')
      ORDER BY COALESCE(date, next_date) ASC$pagination
    ''', args);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  /// Retorna medicações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcoming(
    int daysThreshold, {
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
        '''
        SELECT * FROM medications
        WHERE farm_id = ?
          AND status = 'Agendado'
          AND COALESCE(date, next_date) >= date('now')
          AND COALESCE(date, next_date) <= date('now', '+$daysThreshold days')
        ORDER BY COALESCE(date, next_date) ASC$pagination
        ''',
        args,
      );
    }

    final args = <Object?>[];
    final pagination = _buildPaginationClause(
      limit: limit,
      offset: offset,
      args: args,
    );
    final rows = await _db.db.rawQuery('''
      SELECT * FROM medications
      WHERE status = 'Agendado'
      AND COALESCE(date, next_date) >= date('now')
      AND COALESCE(date, next_date) <= date('now', '+$daysThreshold days')
      ORDER BY COALESCE(date, next_date) ASC$pagination
    ''', args);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  /// Insere uma nova medicação
  Future<void> insert(Map<String, dynamic> medication) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final row = Map<String, dynamic>.from(medication);
      row['farm_id'] = farmId;
      final cols = row.keys.toList(growable: false);
      final placeholders = List.filled(cols.length, '?').join(',');
      final args = cols.map((col) => row[col]).toList(growable: false);
      await _driftDb!.customStatement(
        'INSERT INTO medications (${cols.join(',')}) VALUES ($placeholders)',
        args,
      );
      return;
    }

    await _db.db.insert('medications', medication);
  }

  /// Atualiza uma medicação
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
        UPDATE medications
        SET $setClause
        WHERE farm_id = ? AND id = ?
        ''',
        args,
      );
      return;
    }

    await _db.db.update(
      'medications',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deleta uma medicação
  Future<void> delete(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM medications WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna medicações com informações do animal (join)
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
      baseWhere: farmId != null ? 'm.farm_id = ?' : '1 = 1',
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'm.date DESC',
      dateColumn: 'COALESCE(m.date, m.next_date)',
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
          ? "m.farm_id = ? AND m.status = 'Agendado' AND COALESCE(m.date, m.next_date) < date('now')"
          : "m.status = 'Agendado' AND COALESCE(m.date, m.next_date) < date('now')",
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'COALESCE(m.date, m.next_date) ASC',
      dateColumn: 'COALESCE(m.date, m.next_date)',
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
          ? "m.farm_id = ? AND m.status = 'Agendado' AND COALESCE(m.date, m.next_date) >= date('now')"
          : "m.status = 'Agendado' AND COALESCE(m.date, m.next_date) >= date('now')",
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'COALESCE(m.date, m.next_date) ASC',
      dateColumn: 'COALESCE(m.date, m.next_date)',
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
          ? "m.farm_id = ? AND m.status = 'Aplicado'"
          : "m.status = 'Aplicado'",
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'COALESCE(m.applied_date, m.date) DESC',
      dateColumn: 'COALESCE(m.applied_date, m.date)',
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
          ? "m.farm_id = ? AND m.status = 'Cancelado'"
          : "m.status = 'Cancelado'",
      baseArgs: farmId != null ? [farmId] : const [],
      orderBy: 'COALESCE(m.date, m.next_date) DESC',
      dateColumn: 'COALESCE(m.date, m.next_date)',
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

  Future<List<Map<String, dynamic>>> getMedicationsOverdueWithAnimalInfo({
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
      getMedicationsScheduledFutureWithAnimalInfo({
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

  Future<List<Map<String, dynamic>>> getMedicationsAppliedWithAnimalInfo({
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
          SUM(CASE WHEN status = 'Agendado' AND COALESCE(date, next_date) < date('now') AND applied_date IS NULL THEN 1 ELSE 0 END) AS overdue,
          SUM(CASE WHEN status = 'Agendado' AND COALESCE(date, next_date) >= date('now') THEN 1 ELSE 0 END) AS scheduled,
          SUM(CASE WHEN status = 'Aplicado' OR applied_date IS NOT NULL THEN 1 ELSE 0 END) AS applied
        FROM medications
        WHERE farm_id = ?
        ''',
        [farmId],
      );
      row = rows.first;
    } else {
      final rows = await _db.db.rawQuery('''
        SELECT
          SUM(CASE WHEN status = 'Agendado' AND COALESCE(date, next_date) < date('now') AND applied_date IS NULL THEN 1 ELSE 0 END) AS overdue,
          SUM(CASE WHEN status = 'Agendado' AND COALESCE(date, next_date) >= date('now') THEN 1 ELSE 0 END) AS scheduled,
          SUM(CASE WHEN status = 'Aplicado' OR applied_date IS NOT NULL THEN 1 ELSE 0 END) AS applied
        FROM medications
      ''');
      row = Map<String, dynamic>.from(rows.first);
    }

    return (
      overdue: _toCount(row['overdue']),
      scheduled: _toCount(row['scheduled']),
      applied: _toCount(row['applied']),
    );
  }

  Future<List<Map<String, dynamic>>> getMedicationsCanceledWithAnimalInfo({
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

  /// Retorna medicações relacionadas a um item do estoque
  Future<List<Map<String, dynamic>>> getByPharmacyStockId(String stockId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT * FROM medications
        WHERE farm_id = ? AND pharmacy_stock_id = ?
        ORDER BY date DESC
        ''',
        [farmId, stockId],
      );
    }

    return _db.db.query(
      'medications',
      where: 'pharmacy_stock_id = ?',
      whereArgs: [stockId],
      orderBy: 'date DESC',
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
          m.*,
          a.name AS animal_name,
          a.code AS animal_code,
          a.name_color AS animal_color,
          a.gender AS animal_gender,
          COALESCE(m.next_date, m.date) AS due_date
        FROM medications m
        LEFT JOIN animals a ON a.id = m.animal_id AND a.farm_id = m.farm_id
        WHERE m.farm_id = ?
          AND m.status NOT IN ('Aplicado', 'Cancelado')
          AND COALESCE(m.next_date, m.date) <= ?
        ORDER BY COALESCE(m.next_date, m.date) ASC
        ''',
        [farmId, limit],
      );
    }

    final rows = await _db.db.rawQuery('''
      SELECT
        m.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender,
        COALESCE(m.next_date, m.date) AS due_date
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE m.status NOT IN ('Aplicado', 'Cancelado')
        AND COALESCE(m.next_date, m.date) <= ?
      ORDER BY COALESCE(m.next_date, m.date) ASC
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
        "LOWER(COALESCE(m.medication_name, '')) LIKE ? OR "
        "LOWER(COALESCE(m.notes, '')) LIKE ?"
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
