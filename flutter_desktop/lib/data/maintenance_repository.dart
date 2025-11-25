import 'local_db.dart';

class MaintenanceRepository {
  final AppDatabase _appDb;

  MaintenanceRepository(this._appDb);

  Future<void> clearAllData() async {
    const wipeOrder = <String>[
      'pharmacy_stock_movements',
      'feeding_schedules',
      'animal_weights',
      'weight_alerts',
      'breeding_records',
      'vaccinations',
      'medications',
      'notes',
      'financial_records',
      'financial_accounts',
      'feeding_pens',
      'pharmacy_stock',
      'reports',
      'push_tokens',
      'sold_animals',
      'deceased_animals',
      'animals',
    ];

    final db = _appDb.db;
    await db.transaction((txn) async {
      for (final table in wipeOrder) {
        await txn.delete(table);
      }
    });
  }
}
