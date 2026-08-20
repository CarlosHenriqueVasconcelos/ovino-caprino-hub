import 'drift/app_database.dart';

class MaintenanceRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  MaintenanceRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

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
      'matrix_evaluations',
      'financial_records',
      'financial_accounts',
      'feeding_pens',
      'pharmacy_stock',
      'reports',
      'push_tokens',
      'sync_tombstones',
      'animal_lineage',
      'animal_lineage_meta',
      'app_settings',
      'sold_animals',
      'deceased_animals',
      'animals',
    ];

    final farmId = _farmId;
    await _db.transaction(() async {
      for (final table in wipeOrder) {
        if (farmId != null && await _tableHasFarmId(table)) {
          await _db.customStatement(
            'DELETE FROM $table WHERE farm_id = ?',
            [farmId],
          );
        } else {
          await _db.customStatement('DELETE FROM $table');
        }
      }
    });
  }

  Future<bool> _tableHasFarmId(String table) async {
    final rows = await _db.customSelect('PRAGMA table_info($table)').get();
    return rows.any(
      (row) => (row.data['name']?.toString().toLowerCase() ?? '') == 'farm_id',
    );
  }
}
