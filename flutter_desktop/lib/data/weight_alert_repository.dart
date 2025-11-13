import '../models/weight_alert.dart';
import 'local_db.dart';

class WeightAlertRepository {
  final AppDatabase _db;

  WeightAlertRepository(this._db);

  Future<void> replaceAlerts(
    String animalId,
    List<WeightAlert> alerts,
  ) async {
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
    final rows = await _db.db.query(
      'weight_alerts',
      where: "animal_id = ? AND alert_type = 'monthly'",
      whereArgs: [animalId],
    );
    return rows.length;
  }

  Future<void> insertAlert(WeightAlert alert) async {
    await _db.db.insert('weight_alerts', alert.toMap());
  }

  Future<List<Map<String, dynamic>>> getPendingRaw(DateTime horizon) async {
    final rows = await _db.db.rawQuery('''
      SELECT 
        wa.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color
      FROM weight_alerts wa
      LEFT JOIN animals a ON a.id = wa.animal_id
      WHERE wa.completed = 0
        AND date(wa.due_date) <= date(?)
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
    final rows = await _db.db.query(
      'weight_alerts',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'due_date ASC',
    );
    return rows.map(WeightAlert.fromMap).toList();
  }

  Future<void> deleteAnimalAlerts(String animalId) async {
    await _db.db.delete(
      'weight_alerts',
      where: 'animal_id = ?',
      whereArgs: [animalId],
    );
  }

  Future<void> markCompleted(String alertId) async {
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
