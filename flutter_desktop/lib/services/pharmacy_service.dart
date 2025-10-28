import 'package:uuid/uuid.dart';
import '../models/pharmacy_stock.dart';
import '../models/pharmacy_stock_movement.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';

class PharmacyService {
  static final _uuid = Uuid();

  // Listar medicamentos em estoque
  static Future<List<PharmacyStock>> getPharmacyStock() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query('pharmacy_stock', orderBy: 'medication_name');
      return result.map((row) => PharmacyStock.fromMap(row)).toList();
    } catch (e) {
      print('Erro ao buscar estoque da farmácia: $e');
      return [];
    }
  }

  // Buscar medicamento por ID
  static Future<PharmacyStock?> getStockById(String id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query(
        'pharmacy_stock',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isEmpty) return null;
      return PharmacyStock.fromMap(result.first);
    } catch (e) {
      print('Erro ao buscar medicamento: $e');
      return null;
    }
  }

  // Criar medicamento
  static Future<void> createMedication(PharmacyStock stock) async {
    try {
      final db = await DatabaseService.database;
      final map = stock.toMap();
      await db.insert('pharmacy_stock', map);
      
      // Registrar movimentação de entrada inicial
      if (stock.totalQuantity > 0) {
        await recordMovement(
          PharmacyStockMovement(
            id: _uuid.v4(),
            pharmacyStockId: stock.id,
            movementType: 'entrada',
            quantity: stock.totalQuantity,
            reason: 'Cadastro inicial',
            createdAt: DateTime.now(),
          ),
        );
      }

      // Sincronizar com Supabase se disponível
      if (SupabaseService.isConfigured) {
        await SupabaseService.supabase.from('pharmacy_stock').insert(map);
      }
    } catch (e) {
      print('Erro ao criar medicamento: $e');
      rethrow;
    }
  }

  // Atualizar medicamento
  static Future<void> updateMedication(String id, PharmacyStock stock) async {
    try {
      final db = await DatabaseService.database;
      final map = stock.toMap();
      await db.update('pharmacy_stock', map, where: 'id = ?', whereArgs: [id]);

      if (SupabaseService.isConfigured) {
        await SupabaseService.supabase
            .from('pharmacy_stock')
            .update(map)
            .eq('id', id);
      }
    } catch (e) {
      print('Erro ao atualizar medicamento: $e');
      rethrow;
    }
  }

  // Deletar medicamento
  static Future<void> deleteMedication(String id) async {
    try {
      final db = await DatabaseService.database;
      await db.delete('pharmacy_stock', where: 'id = ?', whereArgs: [id]);

      if (SupabaseService.isConfigured) {
        await SupabaseService.supabase.from('pharmacy_stock').delete().eq('id', id);
      }
    } catch (e) {
      print('Erro ao deletar medicamento: $e');
      rethrow;
    }
  }

  // Registrar movimentação
  static Future<void> recordMovement(PharmacyStockMovement movement) async {
    try {
      final db = await DatabaseService.database;
      final map = movement.toMap();
      await db.insert('pharmacy_stock_movements', map);

      if (SupabaseService.isConfigured) {
        await SupabaseService.supabase.from('pharmacy_stock_movements').insert(map);
      }
    } catch (e) {
      print('Erro ao registrar movimentação: $e');
      rethrow;
    }
  }

  // Buscar histórico de movimentações
  static Future<List<PharmacyStockMovement>> getMovements(String stockId) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query(
        'pharmacy_stock_movements',
        where: 'pharmacy_stock_id = ?',
        whereArgs: [stockId],
        orderBy: 'created_at DESC',
      );
      return result.map((row) => PharmacyStockMovement.fromMap(row)).toList();
    } catch (e) {
      print('Erro ao buscar movimentações: $e');
      return [];
    }
  }

  // Verificar estoque baixo
  static Future<List<PharmacyStock>> getLowStockItems() async {
    try {
      final db = await DatabaseService.database;
      final result = await db.rawQuery(
        'SELECT * FROM pharmacy_stock WHERE min_stock_alert IS NOT NULL AND total_quantity <= min_stock_alert ORDER BY total_quantity',
      );
      return result.map((row) => PharmacyStock.fromMap(row)).toList();
    } catch (e) {
      print('Erro ao buscar itens com estoque baixo: $e');
      return [];
    }
  }

  // Verificar medicamentos próximos ao vencimento
  static Future<List<PharmacyStock>> getExpiringItems(int daysThreshold) async {
    try {
      final db = await DatabaseService.database;
      final thresholdDate = DateTime.now().add(Duration(days: daysThreshold));
      final result = await db.rawQuery(
        'SELECT * FROM pharmacy_stock WHERE expiration_date IS NOT NULL AND expiration_date <= ? AND expiration_date >= ? ORDER BY expiration_date',
        [thresholdDate.toIso8601String().split('T')[0], DateTime.now().toIso8601String().split('T')[0]],
      );
      return result.map((row) => PharmacyStock.fromMap(row)).toList();
    } catch (e) {
      print('Erro ao buscar itens vencendo: $e');
      return [];
    }
  }

  // Deduzir do estoque (ao aplicar medicação)
  static Future<void> deductFromStock(String stockId, double quantity, String medicationId, {bool isAmpoule = false}) async {
    try {
      final stock = await getStockById(stockId);
      if (stock == null) throw Exception('Medicamento não encontrado');

      if (isAmpoule && stock.quantityPerUnit != null) {
        // Lógica para ampolas
        await _handleAmpouleUsage(stock, quantity, medicationId);
      } else {
        // Lógica normal
        final newQuantity = stock.totalQuantity - quantity;
        if (newQuantity < 0) throw Exception('Quantidade insuficiente em estoque');

        final updated = stock.copyWith(
          totalQuantity: newQuantity,
          updatedAt: DateTime.now(),
        );
        await updateMedication(stockId, updated);

        // Registrar movimentação
        await recordMovement(
          PharmacyStockMovement(
            id: _uuid.v4(),
            pharmacyStockId: stockId,
            medicationId: medicationId,
            movementType: 'saida',
            quantity: quantity,
            reason: 'Aplicação de medicamento',
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      print('Erro ao deduzir do estoque: $e');
      rethrow;
    }
  }

  // Lógica de uso de ampolas parciais
  static Future<void> _handleAmpouleUsage(PharmacyStock stock, double quantityUsed, String medicationId) async {
    final ampuleSize = stock.quantityPerUnit!;
    
    // Se usar exatamente a ampola toda
    if (quantityUsed == ampuleSize) {
      final newQuantity = stock.totalQuantity - 1;
      if (newQuantity < 0) throw Exception('Quantidade insuficiente em estoque');

      final updated = stock.copyWith(
        totalQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      await updateMedication(stock.id, updated);

      await recordMovement(
        PharmacyStockMovement(
          id: _uuid.v4(),
          pharmacyStockId: stock.id,
          medicationId: medicationId,
          movementType: 'saida',
          quantity: 1,
          reason: 'Aplicação de medicamento (ampola completa)',
          createdAt: DateTime.now(),
        ),
      );
    } else {
      // Uso parcial de ampola
      final remaining = ampuleSize - quantityUsed;
      
      // Deduzir 1 ampola completa do estoque principal
      final newQuantity = stock.totalQuantity - 1;
      if (newQuantity < 0) throw Exception('Quantidade insuficiente em estoque');

      final updated = stock.copyWith(
        totalQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      await updateMedication(stock.id, updated);

      // Registrar saída da ampola completa
      await recordMovement(
        PharmacyStockMovement(
          id: _uuid.v4(),
          pharmacyStockId: stock.id,
          medicationId: medicationId,
          movementType: 'saida',
          quantity: 1,
          reason: 'Aplicação de medicamento (${quantityUsed}ml usados de ${ampuleSize}ml)',
          createdAt: DateTime.now(),
        ),
      );

      // Se sobrou líquido, criar nova entrada de ampola aberta
      if (remaining > 0) {
        final openedAmpoule = PharmacyStock(
          id: _uuid.v4(),
          medicationName: '${stock.medicationName} (Ampola Aberta)',
          medicationType: stock.medicationType,
          unitOfMeasure: stock.unitOfMeasure,
          quantityPerUnit: ampuleSize,
          totalQuantity: remaining,
          minStockAlert: null,
          expirationDate: stock.expirationDate,
          manufacturer: stock.manufacturer,
          batchNumber: stock.batchNumber,
          purchasePrice: null,
          isOpened: true,
          notes: 'Ampola aberta em ${DateTime.now().toIso8601String().split('T')[0]} - Restante de ${stock.batchNumber ?? 'lote não especificado'}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await createMedication(openedAmpoule);
      }
    }
  }

  // Adicionar ao estoque (ao cancelar medicação ou comprar)
  static Future<void> addToStock(String stockId, double quantity, {String? reason}) async {
    try {
      final stock = await getStockById(stockId);
      if (stock == null) throw Exception('Medicamento não encontrado');

      final newQuantity = stock.totalQuantity + quantity;
      final updated = stock.copyWith(
        totalQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      await updateMedication(stockId, updated);

      // Registrar movimentação
      await recordMovement(
        PharmacyStockMovement(
          id: _uuid.v4(),
          pharmacyStockId: stockId,
          movementType: 'entrada',
          quantity: quantity,
          reason: reason ?? 'Entrada manual',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Erro ao adicionar ao estoque: $e');
      rethrow;
    }
  }
}
