import 'package:drift/drift.dart' show Variable;

import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

class AnimalCascadeRepository {
  final AppDatabase _appDatabase;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  AnimalCascadeRepository(
    AppDatabase appDatabase, {
    AppDriftDatabase? driftDb,
    String? Function()? farmIdProvider,
  })  : _appDatabase = appDatabase,
        _driftDb = driftDb,
        _farmIdProvider = farmIdProvider,
        _legacyBridge = driftDb == null
            ? null
            : LegacySqfliteToDriftBridge(
                legacyDb: appDatabase,
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
    final driftDb = _driftDb;
    if (farmId == null || driftDb == null) return null;
    await _legacyBridge?.migrateForFarm(farmId);
    return farmId;
  }

  Future<List<Map<String, dynamic>>> _driftSelect(
    String sql,
    List<Object?> args,
  ) async {
    final driftDb = _driftDb;
    if (driftDb == null) return const [];
    final rows = await driftDb.customSelect(
      sql,
      variables: _asVariables(args),
    ).get();
    return rows.map((row) => Map<String, dynamic>.from(row.data)).toList();
  }

  Future<void> deleteCascade(String animalId) async {
    final farmId = await _prepareFarmContext();
    final driftDb = _driftDb;
    if (farmId != null && driftDb != null) {
      await driftDb.transaction(() async {
        await driftDb.customStatement(
          '''
          UPDATE animals
          SET mother_id = NULL
          WHERE farm_id = ? AND mother_id = ?
          ''',
          [farmId, animalId],
        );
        await driftDb.customStatement(
          '''
          UPDATE animals
          SET father_id = NULL
          WHERE farm_id = ? AND father_id = ?
          ''',
          [farmId, animalId],
        );

        await driftDb.customStatement(
          'DELETE FROM animal_weights WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await driftDb.customStatement(
          'DELETE FROM vaccinations WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );

        final meds = await _driftSelect(
          '''
          SELECT id FROM medications
          WHERE farm_id = ? AND animal_id = ?
          ''',
          [farmId, animalId],
        );
        for (final med in meds) {
          final medId = med['id']?.toString();
          if (medId == null || medId.isEmpty) continue;
          await driftDb.customStatement(
            '''
            DELETE FROM pharmacy_stock_movements
            WHERE farm_id = ? AND medication_id = ?
            ''',
            [farmId, medId],
          );
        }
        await driftDb.customStatement(
          'DELETE FROM medications WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );

        await driftDb.customStatement(
          'DELETE FROM notes WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await driftDb.customStatement(
          'DELETE FROM financial_records WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await driftDb.customStatement(
          'DELETE FROM financial_accounts WHERE farm_id = ? AND animal_id = ?',
          [farmId, animalId],
        );
        await driftDb.customStatement(
          '''
          DELETE FROM breeding_records
          WHERE farm_id = ?
            AND (female_animal_id = ? OR male_animal_id = ?)
          ''',
          [farmId, animalId, animalId],
        );
        await driftDb.customStatement(
          'DELETE FROM animals WHERE farm_id = ? AND id = ?',
          [farmId, animalId],
        );
      });
      return;
    }

    final db = _appDatabase.db;
    await db.transaction((txn) async {
      await txn.update(
        'animals',
        {'mother_id': null},
        where: 'mother_id = ?',
        whereArgs: [animalId],
      );
      await txn.update(
        'animals',
        {'father_id': null},
        where: 'father_id = ?',
        whereArgs: [animalId],
      );

      await txn.delete(
        'animal_weights',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      await txn.delete(
        'vaccinations',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );

      final meds = await txn.query(
        'medications',
        columns: ['id'],
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      for (final med in meds) {
        final medId = med['id']?.toString();
        if (medId == null || medId.isEmpty) continue;
        await txn.delete(
          'pharmacy_stock_movements',
          where: 'medication_id = ?',
          whereArgs: [medId],
        );
      }
      await txn.delete(
        'medications',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );

      await txn.delete(
        'notes',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      await txn.delete(
        'financial_records',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      await txn.delete(
        'financial_accounts',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      await txn.delete(
        'breeding_records',
        where: 'female_animal_id = ? OR male_animal_id = ?',
        whereArgs: [animalId, animalId],
      );
      await txn.delete(
        'animals',
        where: 'id = ?',
        whereArgs: [animalId],
      );
    });
  }
}
