import 'package:drift/drift.dart' show Variable;

import '../models/breeding_record.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

/// Repository para gerenciar registros de reprodução
class BreedingRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  BreedingRepository(
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

  String _buildPaginationClause({
    required int? limit,
    required int? offset,
    required List<Object?> args,
  }) {
    final buffer = StringBuffer();
    if (limit != null) {
      buffer.write(' LIMIT ?');
      args.add(limit);
    } else if (offset != null) {
      buffer.write(' LIMIT -1');
    }
    if (offset != null) {
      buffer.write(' OFFSET ?');
      args.add(offset);
    }
    return buffer.toString();
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

  /// Retorna todos os registros de reprodução
  Future<List<BreedingRecord>> getAll({int? limit, int? offset}) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final args = <Object?>[farmId];
      final pagination = _buildPaginationClause(
        limit: limit,
        offset: offset,
        args: args,
      );
      final rows = await _driftSelect(
        '''
        SELECT * FROM breeding_records
        WHERE farm_id = ?
        ORDER BY breeding_date DESC$pagination
        ''',
        args,
      );
      return rows.map(BreedingRecord.fromMap).toList();
    }

    final maps = await _db.db.query(
      'breeding_records',
      orderBy: 'breeding_date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna um registro de reprodução por ID
  Future<BreedingRecord?> getById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        'SELECT * FROM breeding_records WHERE farm_id = ? AND id = ? LIMIT 1',
        [farmId, id],
      );
      if (rows.isEmpty) return null;
      return BreedingRecord.fromMap(rows.first);
    }

    final maps = await _db.db.query(
      'breeding_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BreedingRecord.fromMap(maps.first);
  }

  /// Insere um novo registro de reprodução
  Future<void> insert(BreedingRecord record) async {
    final farmId = await _prepareFarmContext();
    final row = record.toMap();
    if (farmId != null) {
      row['farm_id'] = farmId;
      await _driftInsert('breeding_records', row);
      return;
    }

    await _db.db.insert('breeding_records', row);
  }

  /// Atualiza um registro de reprodução
  Future<void> update(BreedingRecord record) async {
    final farmId = await _prepareFarmContext();
    final data = record.toMap()..remove('id');
    if (farmId != null) {
      await _driftUpdateById(
        table: 'breeding_records',
        id: record.id,
        farmId: farmId,
        data: data,
      );
      return;
    }

    await _db.db.update(
      'breeding_records',
      data,
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// Deleta um registro de reprodução
  Future<void> delete(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM breeding_records WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.delete(
      'breeding_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna registros de reprodução de uma fêmea específica
  Future<List<BreedingRecord>> getByFemaleId(String femaleId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM breeding_records
        WHERE farm_id = ? AND female_animal_id = ?
        ORDER BY breeding_date DESC
        ''',
        [farmId, femaleId],
      );
      return rows.map(BreedingRecord.fromMap).toList();
    }

    final maps = await _db.db.query(
      'breeding_records',
      where: 'female_animal_id = ?',
      whereArgs: [femaleId],
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros de reprodução de um macho específico
  Future<List<BreedingRecord>> getByMaleId(String maleId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM breeding_records
        WHERE farm_id = ? AND male_animal_id = ?
        ORDER BY breeding_date DESC
        ''',
        [farmId, maleId],
      );
      return rows.map(BreedingRecord.fromMap).toList();
    }

    final maps = await _db.db.query(
      'breeding_records',
      where: 'male_animal_id = ?',
      whereArgs: [maleId],
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros de reprodução por status
  Future<List<BreedingRecord>> getByStatus(String status) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM breeding_records
        WHERE farm_id = ? AND status = ?
        ORDER BY breeding_date DESC
        ''',
        [farmId, status],
      );
      return rows.map(BreedingRecord.fromMap).toList();
    }

    final maps = await _db.db.query(
      'breeding_records',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros de reprodução por estágio (stage)
  Future<List<BreedingRecord>> getByStage(String stage) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM breeding_records
        WHERE farm_id = ? AND stage = ?
        ORDER BY breeding_date DESC
        ''',
        [farmId, stage],
      );
      return rows.map(BreedingRecord.fromMap).toList();
    }

    final maps = await _db.db.query(
      'breeding_records',
      where: 'stage = ?',
      whereArgs: [stage],
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros de reprodução ativas (não finalizadas)
  Future<List<BreedingRecord>> getActiveRecords() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM breeding_records
        WHERE farm_id = ?
          AND status NOT IN ('Abortado', 'Finalizado')
        ORDER BY breeding_date DESC
        ''',
        [farmId],
      );
      return rows.map(BreedingRecord.fromMap).toList();
    }

    final maps = await _db.db.rawQuery('''
      SELECT * FROM breeding_records
      WHERE status NOT IN ('Abortado', 'Finalizado')
      ORDER BY breeding_date DESC
    ''');
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros com partos esperados próximos (dentro de X dias)
  Future<List<BreedingRecord>> getUpcomingBirths(int daysThreshold) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM breeding_records
        WHERE farm_id = ?
          AND expected_birth IS NOT NULL
          AND expected_birth >= date('now')
          AND expected_birth <= date('now', '+$daysThreshold days')
        ORDER BY expected_birth ASC
        ''',
        [farmId],
      );
      return rows.map(BreedingRecord.fromMap).toList();
    }

    final maps = await _db.db.rawQuery('''
      SELECT * FROM breeding_records
      WHERE expected_birth IS NOT NULL
      AND expected_birth >= date('now')
      AND expected_birth <= date('now', '+$daysThreshold days')
      ORDER BY expected_birth ASC
    ''');
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }
}
