import 'package:drift/drift.dart' show Variable;

import '../models/feeding_pen.dart';
import '../models/feeding_schedule.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

/// Repository para gerenciar baias e tratos de alimentação
class FeedingRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  FeedingRepository(
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

  Future<void> _driftInsert(String table, Map<String, dynamic> row) async {
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    final args = cols.map((col) => row[col]).toList(growable: false);
    await _driftDb!.customStatement(
      'INSERT INTO $table (${cols.join(',')}) VALUES ($placeholders)',
      args,
    );
  }

  Future<void> _driftUpdateById({
    required String table,
    required String id,
    required String farmId,
    required Map<String, dynamic> data,
  }) async {
    if (data.isEmpty) return;
    final keys = data.keys.toList(growable: false);
    final setClause = keys.map((key) => '$key = ?').join(', ');
    final args = <Object?>[...keys.map((k) => data[k]), farmId, id];
    await _driftDb!.customStatement(
      '''
      UPDATE $table
      SET $setClause
      WHERE farm_id = ? AND id = ?
      ''',
      args,
    );
  }

  // ==================== FEEDING PENS ====================

  /// Retorna todas as baias
  Future<List<FeedingPen>> getAllPens() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM feeding_pens
        WHERE farm_id = ?
        ORDER BY name ASC
        ''',
        [farmId],
      );
      return rows.map(FeedingPen.fromMap).toList();
    }

    final maps = await _db.db.query(
      'feeding_pens',
      orderBy: 'name ASC',
    );
    return maps.map((m) => FeedingPen.fromMap(m)).toList();
  }

  /// Retorna uma baia por ID
  Future<FeedingPen?> getPenById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        'SELECT * FROM feeding_pens WHERE farm_id = ? AND id = ? LIMIT 1',
        [farmId, id],
      );
      if (rows.isEmpty) return null;
      return FeedingPen.fromMap(rows.first);
    }

    final maps = await _db.db.query(
      'feeding_pens',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FeedingPen.fromMap(maps.first);
  }

  /// Insere uma nova baia
  Future<void> insertPen(FeedingPen pen) async {
    final farmId = await _prepareFarmContext();
    final row = pen.toMap();
    if (farmId != null) {
      row['farm_id'] = farmId;
      await _driftInsert('feeding_pens', row);
      return;
    }

    await _db.db.insert('feeding_pens', row);
  }

  /// Atualiza uma baia
  Future<void> updatePen(FeedingPen pen) async {
    final farmId = await _prepareFarmContext();
    final data = pen.toMap()..remove('id');
    if (farmId != null) {
      await _driftUpdateById(
        table: 'feeding_pens',
        id: pen.id,
        farmId: farmId,
        data: data,
      );
      return;
    }

    await _db.db.update(
      'feeding_pens',
      data,
      where: 'id = ?',
      whereArgs: [pen.id],
    );
  }

  /// Deleta uma baia
  Future<void> deletePen(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        '''
        DELETE FROM feeding_schedules
        WHERE farm_id = ? AND pen_id = ?
        ''',
        [farmId, id],
      );
      await _driftDb.customStatement(
        'DELETE FROM feeding_pens WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.delete(
      'feeding_schedules',
      where: 'pen_id = ?',
      whereArgs: [id],
    );
    await _db.db.delete(
      'feeding_pens',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== FEEDING SCHEDULES ====================

  /// Retorna todos os tratos de alimentação
  Future<List<FeedingSchedule>> getAllSchedules() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM feeding_schedules
        WHERE farm_id = ?
        ORDER BY created_at DESC
        ''',
        [farmId],
      );
      return rows.map(FeedingSchedule.fromMap).toList();
    }

    final maps = await _db.db.query(
      'feeding_schedules',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => FeedingSchedule.fromMap(m)).toList();
  }

  /// Retorna tratos de uma baia específica
  Future<List<FeedingSchedule>> getSchedulesByPenId(String penId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM feeding_schedules
        WHERE farm_id = ? AND pen_id = ?
        ORDER BY created_at DESC
        ''',
        [farmId, penId],
      );
      return rows.map(FeedingSchedule.fromMap).toList();
    }

    final maps = await _db.db.query(
      'feeding_schedules',
      where: 'pen_id = ?',
      whereArgs: [penId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => FeedingSchedule.fromMap(m)).toList();
  }

  /// Retorna todos os tratos das baias informadas
  Future<Map<String, List<FeedingSchedule>>> getSchedulesByPenIds(
    List<String> penIds,
  ) async {
    if (penIds.isEmpty) return {};

    final farmId = await _prepareFarmContext();
    final grouped = <String, List<FeedingSchedule>>{};

    if (farmId != null) {
      final placeholders = List.filled(penIds.length, '?').join(',');
      final rows = await _driftSelect(
        '''
        SELECT * FROM feeding_schedules
        WHERE farm_id = ? AND pen_id IN ($placeholders)
        ORDER BY pen_id ASC, created_at DESC
        ''',
        [farmId, ...penIds],
      );
      for (final row in rows) {
        final schedule = FeedingSchedule.fromMap(row);
        grouped.putIfAbsent(schedule.penId, () => []).add(schedule);
      }
      return grouped;
    }

    final placeholders = List.filled(penIds.length, '?').join(',');
    final rows = await _db.db.query(
      'feeding_schedules',
      where: 'pen_id IN ($placeholders)',
      whereArgs: penIds,
      orderBy: 'pen_id ASC, created_at DESC',
    );
    for (final row in rows) {
      final schedule = FeedingSchedule.fromMap(row);
      grouped.putIfAbsent(schedule.penId, () => []).add(schedule);
    }
    return grouped;
  }

  /// Retorna um trato por ID
  Future<FeedingSchedule?> getScheduleById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        'SELECT * FROM feeding_schedules WHERE farm_id = ? AND id = ? LIMIT 1',
        [farmId, id],
      );
      if (rows.isEmpty) return null;
      return FeedingSchedule.fromMap(rows.first);
    }

    final maps = await _db.db.query(
      'feeding_schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FeedingSchedule.fromMap(maps.first);
  }

  /// Insere um novo trato
  Future<void> insertSchedule(FeedingSchedule schedule) async {
    final farmId = await _prepareFarmContext();
    final row = schedule.toMap();
    if (farmId != null) {
      row['farm_id'] = farmId;
      await _driftInsert('feeding_schedules', row);
      return;
    }

    await _db.db.insert('feeding_schedules', row);
  }

  /// Atualiza um trato
  Future<void> updateSchedule(FeedingSchedule schedule) async {
    final farmId = await _prepareFarmContext();
    final data = schedule.toMap()..remove('id');
    if (farmId != null) {
      await _driftUpdateById(
        table: 'feeding_schedules',
        id: schedule.id,
        farmId: farmId,
        data: data,
      );
      return;
    }

    await _db.db.update(
      'feeding_schedules',
      data,
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  /// Deleta um trato
  Future<void> deleteSchedule(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM feeding_schedules WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.delete(
      'feeding_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna baias com seus tratos (join)
  Future<List<Map<String, dynamic>>> getPensWithSchedules() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT
          p.*,
          COUNT(s.id) AS schedule_count
        FROM feeding_pens p
        LEFT JOIN feeding_schedules s ON s.pen_id = p.id AND s.farm_id = p.farm_id
        WHERE p.farm_id = ?
        GROUP BY p.id
        ORDER BY p.name ASC
        ''',
        [farmId],
      );
    }

    final rows = await _db.db.rawQuery('''
      SELECT
        p.*,
        COUNT(s.id) as schedule_count
      FROM feeding_pens p
      LEFT JOIN feeding_schedules s ON s.pen_id = p.id
      GROUP BY p.id
      ORDER BY p.name ASC
    ''');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }
}
