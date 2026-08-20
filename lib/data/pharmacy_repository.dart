import 'package:drift/drift.dart' show Variable;

import '../models/pharmacy_stock.dart';
import '../models/pharmacy_stock_movement.dart';
import 'drift/app_database.dart';

class PharmacyRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  PharmacyRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<List<Map<String, dynamic>>> _select(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _db.customSelect(sql, variables: _vars(args)).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }

  Future<void> _insert(String table, Map<String, dynamic> row) async {
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    await _db.customStatement(
      'INSERT INTO $table (${cols.join(',')}) VALUES ($placeholders)',
      cols.map((c) => row[c]).toList(),
    );
  }

  String _pagination({
    required int? limit,
    required int? offset,
    required List<Object?> args,
  }) {
    final buf = StringBuffer();
    if (limit != null) {
      buf.write(' LIMIT ?');
      args.add(limit);
    } else if (offset != null) {
      buf.write(' LIMIT -1');
    }
    if (offset != null) {
      buf.write(' OFFSET ?');
      args.add(offset);
    }
    return buf.toString();
  }

  // ==================== PHARMACY STOCK ====================

  Future<List<PharmacyStock>> getAllStock({int? limit, int? offset}) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) args.add(farmId);
    final page = _pagination(limit: limit, offset: offset, args: args);
    final where = farmId != null ? 'WHERE farm_id = ? ' : '';
    final rows = await _select(
      'SELECT * FROM pharmacy_stock ${where}ORDER BY medication_name ASC$page',
      args,
    );
    return rows.map(PharmacyStock.fromMap).toList();
  }

  Future<PharmacyStock?> getStockById(String id) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM pharmacy_stock WHERE farm_id = ? AND id = ? LIMIT 1',
            [farmId, id],
          )
        : await _select(
            'SELECT * FROM pharmacy_stock WHERE id = ? LIMIT 1',
            [id],
          );
    return rows.isEmpty ? null : PharmacyStock.fromMap(rows.first);
  }

  Future<void> insertStock(PharmacyStock stock) async {
    final farmId = _farmId;
    final row = stock.toMap();
    if (farmId != null) row['farm_id'] = farmId;
    await _insert('pharmacy_stock', row);
  }

  Future<void> updateStock(PharmacyStock stock) async {
    final farmId = _farmId;
    final data = stock.toMap()..remove('id');
    if (data.isEmpty) return;
    final keys = data.keys.toList(growable: false);
    final setClause = keys.map((k) => '$k = ?').join(', ');
    if (farmId != null) {
      await _db.customStatement(
        'UPDATE pharmacy_stock SET $setClause WHERE farm_id = ? AND id = ?',
        [...keys.map((k) => data[k]), farmId, stock.id],
      );
    } else {
      await _db.customStatement(
        'UPDATE pharmacy_stock SET $setClause WHERE id = ?',
        [...keys.map((k) => data[k]), stock.id],
      );
    }
  }

  Future<void> deleteStock(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'UPDATE medications SET pharmacy_stock_id = NULL WHERE farm_id = ? AND pharmacy_stock_id = ?',
        [farmId, id],
      );
      await _db.customStatement(
        'DELETE FROM pharmacy_stock_movements WHERE farm_id = ? AND pharmacy_stock_id = ?',
        [farmId, id],
      );
      await _db.customStatement(
        'DELETE FROM pharmacy_stock WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement(
        'UPDATE medications SET pharmacy_stock_id = NULL WHERE pharmacy_stock_id = ?',
        [id],
      );
      await _db.customStatement(
        'DELETE FROM pharmacy_stock_movements WHERE pharmacy_stock_id = ?',
        [id],
      );
      await _db.customStatement(
        'DELETE FROM pharmacy_stock WHERE id = ?',
        [id],
      );
    }
  }

  Future<List<PharmacyStock>> getLowStockItems() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            '''
            SELECT * FROM pharmacy_stock
            WHERE farm_id = ?
              AND min_stock_alert IS NOT NULL
              AND total_quantity <= min_stock_alert
            ORDER BY medication_name ASC
            ''',
            [farmId],
          )
        : await _select(
            '''
            SELECT * FROM pharmacy_stock
            WHERE min_stock_alert IS NOT NULL
              AND total_quantity <= min_stock_alert
            ORDER BY medication_name ASC
            ''',
            [],
          );
    return rows.map(PharmacyStock.fromMap).toList();
  }

  Future<List<PharmacyStock>> getExpiringItems(int daysThreshold) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            '''
            SELECT * FROM pharmacy_stock
            WHERE farm_id = ?
              AND expiration_date IS NOT NULL
              AND expiration_date >= date('now')
              AND expiration_date <= date('now', '+$daysThreshold days')
            ORDER BY expiration_date ASC
            ''',
            [farmId],
          )
        : await _select(
            '''
            SELECT * FROM pharmacy_stock
            WHERE expiration_date IS NOT NULL
              AND expiration_date >= date('now')
              AND expiration_date <= date('now', '+$daysThreshold days')
            ORDER BY expiration_date ASC
            ''',
            [],
          );
    return rows.map(PharmacyStock.fromMap).toList();
  }

  // ==================== PHARMACY STOCK MOVEMENTS ====================

  Future<void> recordMovement(PharmacyStockMovement movement) async {
    final farmId = _farmId;
    final row = movement.toMap();
    if (farmId != null) row['farm_id'] = farmId;
    await _insert('pharmacy_stock_movements', row);
  }

  Future<List<PharmacyStockMovement>> getMovementsByStockId(
    String stockId,
  ) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM pharmacy_stock_movements WHERE farm_id = ? AND pharmacy_stock_id = ? ORDER BY created_at DESC',
            [farmId, stockId],
          )
        : await _select(
            'SELECT * FROM pharmacy_stock_movements WHERE pharmacy_stock_id = ? ORDER BY created_at DESC',
            [stockId],
          );
    return rows.map(PharmacyStockMovement.fromMap).toList();
  }

  Future<List<PharmacyStockMovement>> getAllMovements({
    int? limit,
    int? offset,
  }) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) args.add(farmId);
    final page = _pagination(limit: limit, offset: offset, args: args);
    final where = farmId != null ? 'WHERE farm_id = ? ' : '';
    final rows = await _select(
      'SELECT * FROM pharmacy_stock_movements ${where}ORDER BY created_at DESC$page',
      args,
    );
    return rows.map(PharmacyStockMovement.fromMap).toList();
  }

  Future<List<PharmacyStockMovement>> getMovementsByMedicationId(
    String medicationId,
  ) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM pharmacy_stock_movements WHERE farm_id = ? AND medication_id = ? ORDER BY created_at DESC',
            [farmId, medicationId],
          )
        : await _select(
            'SELECT * FROM pharmacy_stock_movements WHERE medication_id = ? ORDER BY created_at DESC',
            [medicationId],
          );
    return rows.map(PharmacyStockMovement.fromMap).toList();
  }
}
