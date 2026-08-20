import 'package:drift/drift.dart' show Variable;

import '../models/weight_alert.dart';
import 'drift/app_database.dart';

class WeightAlertRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  WeightAlertRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<void> replaceAlerts(String animalId, List<WeightAlert> alerts) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM weight_alerts WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      for (final alert in alerts) {
        final row = Map<String, dynamic>.from(alert.toMap())
          ..['farm_id'] = farmId;
        final cols = row.keys.toList(growable: false);
        final placeholders = List.filled(cols.length, '?').join(',');
        await _db.customStatement(
          'INSERT OR REPLACE INTO weight_alerts (${cols.join(',')}) VALUES ($placeholders)',
          cols.map((c) => row[c]).toList(),
        );
      }
    } else {
      await _db.customStatement(
        'DELETE FROM weight_alerts WHERE animal_id = ?',
        [animalId],
      );
      for (final alert in alerts) {
        final row = alert.toMap();
        final cols = row.keys.toList(growable: false);
        final placeholders = List.filled(cols.length, '?').join(',');
        await _db.customStatement(
          'INSERT OR REPLACE INTO weight_alerts (${cols.join(',')}) VALUES ($placeholders)',
          cols.map((c) => row[c]).toList(),
        );
      }
    }
  }

  Future<int> countMonthlyAlerts(String animalId) async {
    final farmId = _farmId;
    final row = farmId != null
        ? await _db.customSelect(
            "SELECT COUNT(*) AS c FROM weight_alerts WHERE farm_id = ? AND animal_id = ? AND alert_type = 'monthly'",
            variables: _vars([farmId, animalId]),
          ).getSingle()
        : await _db.customSelect(
            "SELECT COUNT(*) AS c FROM weight_alerts WHERE animal_id = ? AND alert_type = 'monthly'",
            variables: _vars([animalId]),
          ).getSingle();
    final value = row.data['c'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> insertAlert(WeightAlert alert) async {
    final farmId = _farmId;
    final row = Map<String, dynamic>.from(alert.toMap());
    if (farmId != null) row['farm_id'] = farmId;
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    await _db.customStatement(
      'INSERT OR REPLACE INTO weight_alerts (${cols.join(',')}) VALUES ($placeholders)',
      cols.map((c) => row[c]).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getPendingRaw(DateTime horizon) async {
    final farmId = _farmId;
    final dateStr = horizon.toIso8601String().split('T').first;
    final rows = farmId != null
        ? await _db.customSelect(
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
            variables: _vars([farmId, dateStr]),
          ).get()
        : await _db.customSelect(
            '''
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
            ''',
            variables: _vars([dateStr]),
          ).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }

  Future<List<WeightAlert>> getPendingAlerts(int horizonDays) async {
    final horizon = DateTime.now().add(Duration(days: horizonDays));
    final rows = await getPendingRaw(horizon);
    return rows.map(WeightAlert.fromMap).toList();
  }

  Future<List<WeightAlert>> getAnimalAlerts(String animalId) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _db.customSelect(
            'SELECT * FROM weight_alerts WHERE farm_id = ? AND animal_id = ? ORDER BY due_date ASC',
            variables: _vars([farmId, animalId]),
          ).get()
        : await _db.customSelect(
            'SELECT * FROM weight_alerts WHERE animal_id = ? ORDER BY due_date ASC',
            variables: _vars([animalId]),
          ).get();
    return rows.map((r) => WeightAlert.fromMap(r.data)).toList();
  }

  Future<void> deleteAnimalAlerts(String animalId) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM weight_alerts WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
    } else {
      await _db.customStatement(
        'DELETE FROM weight_alerts WHERE animal_id = ?',
        [animalId],
      );
    }
  }

  Future<void> markCompleted(String alertId) async {
    final farmId = _farmId;
    final now = DateTime.now().toIso8601String();
    if (farmId != null) {
      await _db.customStatement(
        'UPDATE weight_alerts SET completed = 1, updated_at = ? WHERE farm_id = ? AND id = ?',
        [now, farmId, alertId],
      );
    } else {
      await _db.customStatement(
        'UPDATE weight_alerts SET completed = 1, updated_at = ? WHERE id = ?',
        [now, alertId],
      );
    }
  }
}
