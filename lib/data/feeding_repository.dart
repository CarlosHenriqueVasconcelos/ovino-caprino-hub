import 'package:drift/drift.dart' show Variable;

import '../models/feeding_pen.dart';
import '../models/feeding_schedule.dart';
import 'drift/app_database.dart';

class FeedingRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  FeedingRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<List<Map<String, dynamic>>> _select(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _db.customSelect(sql, variables: _vars(args)).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }

  Future<void> _insert(String table, Map<String, dynamic> row) async {
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    await _db.customStatement(
      'INSERT INTO $table (${cols.join(',')}) VALUES ($placeholders)',
      cols.map((c) => row[c]).toList(),
    );
  }

  Future<void> _updateById({
    required String table,
    required String id,
    required String? farmId,
    required Map<String, dynamic> data,
  }) async {
    if (data.isEmpty) return;
    final keys = data.keys.toList(growable: false);
    final setClause = keys.map((k) => '$k = ?').join(', ');
    if (farmId != null) {
      await _db.customStatement(
        'UPDATE $table SET $setClause WHERE farm_id = ? AND id = ?',
        [...keys.map((k) => data[k]), farmId, id],
      );
    } else {
      await _db.customStatement(
        'UPDATE $table SET $setClause WHERE id = ?',
        [...keys.map((k) => data[k]), id],
      );
    }
  }

  // ==================== FEEDING PENS ====================

  Future<List<FeedingPen>> getAllPens() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM feeding_pens WHERE farm_id = ? ORDER BY name ASC',
            [farmId],
          )
        : await _select('SELECT * FROM feeding_pens ORDER BY name ASC', []);
    return rows.map(FeedingPen.fromMap).toList();
  }

  Future<FeedingPen?> getPenById(String id) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM feeding_pens WHERE farm_id = ? AND id = ? LIMIT 1',
            [farmId, id],
          )
        : await _select(
            'SELECT * FROM feeding_pens WHERE id = ? LIMIT 1',
            [id],
          );
    return rows.isEmpty ? null : FeedingPen.fromMap(rows.first);
  }

  Future<void> insertPen(FeedingPen pen) async {
    final farmId = _farmId;
    final row = pen.toMap();
    if (farmId != null) row['farm_id'] = farmId;
    await _insert('feeding_pens', row);
  }

  Future<void> updatePen(FeedingPen pen) async {
    final farmId = _farmId;
    await _updateById(
      table: 'feeding_pens',
      id: pen.id,
      farmId: farmId,
      data: pen.toMap()..remove('id'),
    );
  }

  Future<void> deletePen(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM feeding_schedules WHERE farm_id = ? AND pen_id = ?',
        [farmId, id],
      );
      await _db.customStatement(
        'DELETE FROM feeding_pens WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement(
        'DELETE FROM feeding_schedules WHERE pen_id = ?',
        [id],
      );
      await _db.customStatement(
        'DELETE FROM feeding_pens WHERE id = ?',
        [id],
      );
    }
  }

  // ==================== FEEDING SCHEDULES ====================

  Future<List<FeedingSchedule>> getAllSchedules() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM feeding_schedules WHERE farm_id = ? ORDER BY created_at DESC',
            [farmId],
          )
        : await _select(
            'SELECT * FROM feeding_schedules ORDER BY created_at DESC',
            [],
          );
    return rows.map(FeedingSchedule.fromMap).toList();
  }

  Future<List<FeedingSchedule>> getSchedulesByPenId(String penId) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM feeding_schedules WHERE farm_id = ? AND pen_id = ? ORDER BY created_at DESC',
            [farmId, penId],
          )
        : await _select(
            'SELECT * FROM feeding_schedules WHERE pen_id = ? ORDER BY created_at DESC',
            [penId],
          );
    return rows.map(FeedingSchedule.fromMap).toList();
  }

  Future<Map<String, List<FeedingSchedule>>> getSchedulesByPenIds(
    List<String> penIds,
  ) async {
    if (penIds.isEmpty) return {};
    final farmId = _farmId;
    final placeholders = List.filled(penIds.length, '?').join(',');
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM feeding_schedules WHERE farm_id = ? AND pen_id IN ($placeholders) ORDER BY pen_id ASC, created_at DESC',
            [farmId, ...penIds],
          )
        : await _select(
            'SELECT * FROM feeding_schedules WHERE pen_id IN ($placeholders) ORDER BY pen_id ASC, created_at DESC',
            penIds,
          );
    final grouped = <String, List<FeedingSchedule>>{};
    for (final row in rows) {
      final s = FeedingSchedule.fromMap(row);
      grouped.putIfAbsent(s.penId, () => []).add(s);
    }
    return grouped;
  }

  Future<FeedingSchedule?> getScheduleById(String id) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM feeding_schedules WHERE farm_id = ? AND id = ? LIMIT 1',
            [farmId, id],
          )
        : await _select(
            'SELECT * FROM feeding_schedules WHERE id = ? LIMIT 1',
            [id],
          );
    return rows.isEmpty ? null : FeedingSchedule.fromMap(rows.first);
  }

  Future<void> insertSchedule(FeedingSchedule schedule) async {
    final farmId = _farmId;
    final row = schedule.toMap();
    if (farmId != null) row['farm_id'] = farmId;
    await _insert('feeding_schedules', row);
  }

  Future<void> updateSchedule(FeedingSchedule schedule) async {
    final farmId = _farmId;
    await _updateById(
      table: 'feeding_schedules',
      id: schedule.id,
      farmId: farmId,
      data: schedule.toMap()..remove('id'),
    );
  }

  Future<void> deleteSchedule(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM feeding_schedules WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement(
        'DELETE FROM feeding_schedules WHERE id = ?',
        [id],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPensWithSchedules() async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            '''
            SELECT p.*, COUNT(s.id) AS schedule_count
            FROM feeding_pens p
            LEFT JOIN feeding_schedules s ON s.pen_id = p.id AND s.farm_id = p.farm_id
            WHERE p.farm_id = ?
            GROUP BY p.id
            ORDER BY p.name ASC
            ''',
            [farmId],
          )
        : _select(
            '''
            SELECT p.*, COUNT(s.id) AS schedule_count
            FROM feeding_pens p
            LEFT JOIN feeding_schedules s ON s.pen_id = p.id
            GROUP BY p.id
            ORDER BY p.name ASC
            ''',
            [],
          );
  }
}
