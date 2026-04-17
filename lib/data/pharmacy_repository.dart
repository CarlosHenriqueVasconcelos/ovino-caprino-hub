import 'package:drift/drift.dart' show Variable;

import '../models/pharmacy_stock.dart';
import '../models/pharmacy_stock_movement.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

/// Repository para gerenciar estoque de medicamentos e movimentações
class PharmacyRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  PharmacyRepository(
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

  // ==================== PHARMACY STOCK ====================

  /// Retorna todos os itens do estoque
  Future<List<PharmacyStock>> getAllStock({
    int? limit,
    int? offset,
  }) async {
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
        SELECT * FROM pharmacy_stock
        WHERE farm_id = ?
        ORDER BY medication_name ASC$pagination
        ''',
        args,
      );
      return rows.map(PharmacyStock.fromMap).toList();
    }

    final maps = await _db.db.query(
      'pharmacy_stock',
      orderBy: 'medication_name ASC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => PharmacyStock.fromMap(m)).toList();
  }

  /// Retorna um item do estoque por ID
  Future<PharmacyStock?> getStockById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        'SELECT * FROM pharmacy_stock WHERE farm_id = ? AND id = ? LIMIT 1',
        [farmId, id],
      );
      if (rows.isEmpty) return null;
      return PharmacyStock.fromMap(rows.first);
    }

    final maps = await _db.db.query(
      'pharmacy_stock',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return PharmacyStock.fromMap(maps.first);
  }

  /// Insere um novo item no estoque
  Future<void> insertStock(PharmacyStock stock) async {
    final farmId = await _prepareFarmContext();
    final row = stock.toMap();

    if (farmId != null) {
      row['farm_id'] = farmId;
      await _driftInsert('pharmacy_stock', row);
      return;
    }

    await _db.db.insert('pharmacy_stock', row);
  }

  /// Atualiza um item do estoque
  Future<void> updateStock(PharmacyStock stock) async {
    final farmId = await _prepareFarmContext();
    final data = stock.toMap()..remove('id');
    if (farmId != null) {
      if (data.isEmpty) return;
      final keys = data.keys.toList(growable: false);
      final setClause = keys.map((k) => '$k = ?').join(', ');
      final args = <Object?>[...keys.map((k) => data[k]), farmId, stock.id];
      await _driftDb!.customStatement(
        '''
        UPDATE pharmacy_stock
        SET $setClause
        WHERE farm_id = ? AND id = ?
        ''',
        args,
      );
      return;
    }

    await _db.db.update(
      'pharmacy_stock',
      data,
      where: 'id = ?',
      whereArgs: [stock.id],
    );
  }

  /// Deleta um item do estoque
  /// Remove vínculos em medications antes de deletar
  Future<void> deleteStock(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        '''
        UPDATE medications
        SET pharmacy_stock_id = NULL
        WHERE farm_id = ? AND pharmacy_stock_id = ?
        ''',
        [farmId, id],
      );
      await _driftDb.customStatement(
        '''
        DELETE FROM pharmacy_stock_movements
        WHERE farm_id = ? AND pharmacy_stock_id = ?
        ''',
        [farmId, id],
      );
      await _driftDb.customStatement(
        'DELETE FROM pharmacy_stock WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.update(
      'medications',
      {'pharmacy_stock_id': null},
      where: 'pharmacy_stock_id = ?',
      whereArgs: [id],
    );
    await _db.db.delete(
      'pharmacy_stock_movements',
      where: 'pharmacy_stock_id = ?',
      whereArgs: [id],
    );
    await _db.db.delete(
      'pharmacy_stock',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna itens com estoque baixo (abaixo do alerta mínimo)
  Future<List<PharmacyStock>> getLowStockItems() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM pharmacy_stock
        WHERE farm_id = ?
          AND min_stock_alert IS NOT NULL
          AND total_quantity <= min_stock_alert
        ORDER BY medication_name ASC
        ''',
        [farmId],
      );
      return rows.map(PharmacyStock.fromMap).toList();
    }

    final maps = await _db.db.rawQuery('''
      SELECT * FROM pharmacy_stock
      WHERE min_stock_alert IS NOT NULL
      AND total_quantity <= min_stock_alert
      ORDER BY medication_name ASC
    ''');
    return maps.map((m) => PharmacyStock.fromMap(m)).toList();
  }

  /// Retorna itens próximos da data de validade
  Future<List<PharmacyStock>> getExpiringItems(int daysThreshold) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM pharmacy_stock
        WHERE farm_id = ?
          AND expiration_date IS NOT NULL
          AND expiration_date >= date('now')
          AND expiration_date <= date('now', '+$daysThreshold days')
        ORDER BY expiration_date ASC
        ''',
        [farmId],
      );
      return rows.map(PharmacyStock.fromMap).toList();
    }

    final maps = await _db.db.rawQuery('''
      SELECT * FROM pharmacy_stock
      WHERE expiration_date IS NOT NULL
      AND expiration_date >= date('now')
      AND expiration_date <= date('now', '+$daysThreshold days')
      ORDER BY expiration_date ASC
    ''');
    return maps.map((m) => PharmacyStock.fromMap(m)).toList();
  }

  // ==================== PHARMACY STOCK MOVEMENTS ====================

  /// Registra uma movimentação de estoque
  Future<void> recordMovement(PharmacyStockMovement movement) async {
    final farmId = await _prepareFarmContext();
    final row = movement.toMap();

    if (farmId != null) {
      row['farm_id'] = farmId;
      await _driftInsert('pharmacy_stock_movements', row);
      return;
    }

    await _db.db.insert('pharmacy_stock_movements', row);
  }

  /// Retorna todas as movimentações de um item do estoque
  Future<List<PharmacyStockMovement>> getMovementsByStockId(
    String stockId,
  ) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM pharmacy_stock_movements
        WHERE farm_id = ? AND pharmacy_stock_id = ?
        ORDER BY created_at DESC
        ''',
        [farmId, stockId],
      );
      return rows.map(PharmacyStockMovement.fromMap).toList();
    }

    final maps = await _db.db.query(
      'pharmacy_stock_movements',
      where: 'pharmacy_stock_id = ?',
      whereArgs: [stockId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => PharmacyStockMovement.fromMap(m)).toList();
  }

  /// Retorna todas as movimentações
  Future<List<PharmacyStockMovement>> getAllMovements({
    int? limit,
    int? offset,
  }) async {
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
        SELECT * FROM pharmacy_stock_movements
        WHERE farm_id = ?
        ORDER BY created_at DESC$pagination
        ''',
        args,
      );
      return rows.map(PharmacyStockMovement.fromMap).toList();
    }

    final maps = await _db.db.query(
      'pharmacy_stock_movements',
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => PharmacyStockMovement.fromMap(m)).toList();
  }

  /// Retorna movimentações relacionadas a uma medicação específica
  Future<List<PharmacyStockMovement>> getMovementsByMedicationId(
    String medicationId,
  ) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM pharmacy_stock_movements
        WHERE farm_id = ? AND medication_id = ?
        ORDER BY created_at DESC
        ''',
        [farmId, medicationId],
      );
      return rows.map(PharmacyStockMovement.fromMap).toList();
    }

    final maps = await _db.db.query(
      'pharmacy_stock_movements',
      where: 'medication_id = ?',
      whereArgs: [medicationId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => PharmacyStockMovement.fromMap(m)).toList();
  }
}
