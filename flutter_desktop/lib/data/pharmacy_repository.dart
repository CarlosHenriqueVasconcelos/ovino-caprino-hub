import 'package:sqflite_common/sqlite_api.dart';
import '../models/pharmacy_stock.dart';
import '../models/pharmacy_stock_movement.dart';
import 'local_db.dart';

/// Repository para gerenciar estoque de medicamentos e movimentações
class PharmacyRepository {
  final AppDatabase _db;

  PharmacyRepository(this._db);

  // ==================== PHARMACY STOCK ====================

  /// Retorna todos os itens do estoque
  Future<List<PharmacyStock>> getAllStock() async {
    final maps = await _db.db.query(
      'pharmacy_stock',
      orderBy: 'medication_name ASC',
    );
    return maps.map((m) => PharmacyStock.fromMap(m)).toList();
  }

  /// Retorna um item do estoque por ID
  Future<PharmacyStock?> getStockById(String id) async {
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
    await _db.db.insert('pharmacy_stock', stock.toMap());
  }

  /// Atualiza um item do estoque
  Future<void> updateStock(PharmacyStock stock) async {
    await _db.db.update(
      'pharmacy_stock',
      stock.toMap(),
      where: 'id = ?',
      whereArgs: [stock.id],
    );
  }

  /// Deleta um item do estoque
  /// Remove vínculos em medications antes de deletar
  Future<void> deleteStock(String id) async {
    // Remover vínculos em medications (FK) antes de deletar o estoque
    await _db.db.update(
      'medications',
      {'pharmacy_stock_id': null},
      where: 'pharmacy_stock_id = ?',
      whereArgs: [id],
    );
    
    // Deletar movimentações relacionadas
    await _db.db.delete(
      'pharmacy_stock_movements',
      where: 'pharmacy_stock_id = ?',
      whereArgs: [id],
    );
    
    // Deletar o medicamento do estoque
    await _db.db.delete(
      'pharmacy_stock',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna itens com estoque baixo (abaixo do alerta mínimo)
  Future<List<PharmacyStock>> getLowStockItems() async {
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
    final maps = await _db.db.rawQuery('''
      SELECT * FROM pharmacy_stock
      WHERE expiration_date IS NOT NULL
      AND date(expiration_date) BETWEEN date('now') AND date('now', '+$daysThreshold days')
      ORDER BY expiration_date ASC
    ''');
    return maps.map((m) => PharmacyStock.fromMap(m)).toList();
  }

  // ==================== PHARMACY STOCK MOVEMENTS ====================

  /// Registra uma movimentação de estoque
  Future<void> recordMovement(PharmacyStockMovement movement) async {
    await _db.db.insert('pharmacy_stock_movements', movement.toMap());
  }

  /// Retorna todas as movimentações de um item do estoque
  Future<List<PharmacyStockMovement>> getMovementsByStockId(String stockId) async {
    final maps = await _db.db.query(
      'pharmacy_stock_movements',
      where: 'pharmacy_stock_id = ?',
      whereArgs: [stockId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => PharmacyStockMovement.fromMap(m)).toList();
  }

  /// Retorna todas as movimentações
  Future<List<PharmacyStockMovement>> getAllMovements() async {
    final maps = await _db.db.query(
      'pharmacy_stock_movements',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => PharmacyStockMovement.fromMap(m)).toList();
  }

  /// Retorna movimentações relacionadas a uma medicação específica
  Future<List<PharmacyStockMovement>> getMovementsByMedicationId(String medicationId) async {
    final maps = await _db.db.query(
      'pharmacy_stock_movements',
      where: 'medication_id = ?',
      whereArgs: [medicationId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => PharmacyStockMovement.fromMap(m)).toList();
  }
}
