import 'package:drift/drift.dart' show Variable;

import '../models/weight_alert.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

class WeightAlertRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  WeightAlertRepository(
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

  Future<void> replaceAlerts(
    String animalId,
    List<WeightAlert> alerts,
  ) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM weight_alerts WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      for (final alert in alerts) {
        final row = Map<String, dynamic>.from(alert.toMap())..['farm_id'] = farmId;
        final cols = row.keys.toList(growable: false);
        final placeholders = List.filled(cols.length, '?').join(',');
        final args = cols.map((c) => row[c]).toList(growable: false);
        await _driftDb.customStatement(
          'INSERT OR REPLACE INTO weight_alerts (${cols.join(',')}) VALUES ($placeholders)',
          args,
        );
      }
      return;
    }

    final database = _db.db;
    await database.delete(
      'weight_alerts',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );

    for (final alert in alerts) {
      await database.insert('weight_alerts', alert.toMap());
    }
  }

  Future<int> countMonthlyAlerts(String animalId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        '''
        SELECT COUNT(*) AS c FROM weight_alerts
        WHERE farm_id = ? AND animal_id = ? AND alert_type = 'monthly'
        ''',
        variables: _asVariables([farmId, animalId]),
      ).getSingle();
      final value = rows.data['c'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final rows = await _db.db.query(
      'weight_alerts',
      where: "animal_id = ? AND alert_type = 'monthly'",
      whereArgs: [animalId],
    );
    return rows.length;
  }

  Future<void> insertAlert(WeightAlert alert) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final row = Map<String, dynamic>.from(alert.toMap())..['farm_id'] = farmId;
      final cols = row.keys.toList(growable: false);
      final placeholders = List.filled(cols.length, '?').join(',');
      final args = cols.map((c) => row[c]).toList(growable: false);
      await _driftDb!.customStatement(
        'INSERT OR REPLACE INTO weight_alerts (${cols.join(',')}) VALUES ($placeholders)',
        args,
      );
      return;
    }

    await _db.db.insert('weight_alerts', alert.toMap());
  }

  Future<List<Map<String, dynamic>>> getPendingRaw(DateTime horizon) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        '''
        SELECT
          wa.*,
          a.name AS animal_name,
          a.code AS animal_code,
          a.name_color AS animal_color,
          a.gender AS animal_gender
        FROM weight_alerts wa
        LEFT JOIN animals a
          ON a.id = wa.animal_id AND a.farm_id = wa.farm_id
        WHERE wa.farm_id = ?
          AND wa.completed = 0
          AND wa.due_date <= date(?)
        ORDER BY wa.due_date ASC
        ''',
        variables: _asVariables([farmId, horizon.toIso8601String().split('T').first]),
      ).get();
      return rows.map((row) => Map<String, dynamic>.from(row.data)).toList();
    }

    final rows = await _db.db.rawQuery('''
      SELECT 
        wa.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender
      FROM weight_alerts wa
      LEFT JOIN animals a ON a.id = wa.animal_id
      WHERE wa.completed = 0
        AND wa.due_date <= date(?)
      ORDER BY wa.due_date ASC
    ''', [horizon.toIso8601String().split('T').first]);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<List<WeightAlert>> getPendingAlerts(int horizonDays) async {
    final horizon = DateTime.now().add(Duration(days: horizonDays));
    final rows = await getPendingRaw(horizon);
    return rows.map(WeightAlert.fromMap).toList();
  }

  Future<List<WeightAlert>> getAnimalAlerts(String animalId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftDb!.customSelect(
        '''
        SELECT * FROM weight_alerts
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY due_date ASC
        ''',
        variables: _asVariables([farmId, animalId]),
      ).get();
      return rows.map((r) => WeightAlert.fromMap(r.data)).toList();
    }

    final rows = await _db.db.query(
      'weight_alerts',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'due_date ASC',
    );
    return rows.map(WeightAlert.fromMap).toList();
  }

  Future<void> deleteAnimalAlerts(String animalId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM weight_alerts WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      return;
    }

    await _db.db.delete(
      'weight_alerts',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
  }

  Future<void> markCompleted(String alertId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        '''
        UPDATE weight_alerts
        SET completed = 1, updated_at = ?
        WHERE farm_id = ? AND id = ?
        ''',
        [DateTime.now().toIso8601String(), farmId, alertId],
      );
      return;
    }

    await _db.db.update(
      'weight_alerts',
      {
        'completed': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }
}
