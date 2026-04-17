import 'package:drift/drift.dart' show Variable;

import '../models/animal.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

class SoldAnimalsRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  SoldAnimalsRepository(
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

  Future<List<Animal>> fetchAll() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = (await _driftDb!
              .customSelect(
                '''
                SELECT * FROM sold_animals
                WHERE farm_id = ?
                ORDER BY sale_date DESC
                ''',
                variables: _asVariables([farmId]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      return rows.map(_mapRowToAnimal).toList();
    }

    final rows = await _db.db.query(
      'sold_animals',
      orderBy: 'sale_date DESC',
    );
    return rows.map(_mapRowToAnimal).toList();
  }

  Animal _mapRowToAnimal(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['status'] = 'Vendido';
    map['last_vaccination'] = null;
    map['expected_delivery'] = null;
    map['health_issue'] = null;
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    map['updated_at'] = map['updated_at'] ?? DateTime.now().toIso8601String();
    return Animal.fromMap(map);
  }
}
