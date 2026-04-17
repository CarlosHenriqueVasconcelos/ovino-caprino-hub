import 'package:sqflite_common/sqlite_api.dart' show DatabaseExecutor;

import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

class MaintenanceRepository {
  final AppDatabase _appDb;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  MaintenanceRepository(
    AppDatabase appDb, {
    AppDriftDatabase? driftDb,
    String? Function()? farmIdProvider,
  })  : _appDb = appDb,
        _driftDb = driftDb,
        _farmIdProvider = farmIdProvider,
        _legacyBridge = driftDb == null
            ? null
            : LegacySqfliteToDriftBridge(
                legacyDb: appDb,
                driftDb: driftDb,
              );

  String? get _currentFarmId => _farmIdProvider?.call();

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

    final farmId = _currentFarmId;
    final driftDb = _driftDb;
    if (farmId != null && driftDb != null) {
      await _legacyBridge?.migrateForFarm(farmId);
      await driftDb.transaction(() async {
        for (final table in wipeOrder) {
          if (await _driftTableHasFarmId(driftDb, table)) {
            await driftDb.customStatement(
              'DELETE FROM $table WHERE farm_id = ?',
              [farmId],
            );
          }
        }
      });
    } else if (driftDb != null) {
      await driftDb.transaction(() async {
        for (final table in wipeOrder) {
          await driftDb.customStatement('DELETE FROM $table');
        }
      });
    }

    final db = _appDb.db;
    await db.transaction((txn) async {
      for (final table in wipeOrder) {
        if (farmId != null) {
          if (await _legacyTableHasFarmId(txn, table)) {
            await txn.delete(
              table,
              where: 'farm_id = ?',
              whereArgs: [farmId],
            );
          }
        } else {
          await txn.delete(table);
        }
      }
    });
  }

  Future<bool> _driftTableHasFarmId(AppDriftDatabase db, String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows.any(
      (row) => (row.data['name']?.toString().toLowerCase() ?? '') == 'farm_id',
    );
  }

  Future<bool> _legacyTableHasFarmId(DatabaseExecutor db, String table) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any(
      (row) => (row['name']?.toString().toLowerCase() ?? '') == 'farm_id',
    );
  }
}
