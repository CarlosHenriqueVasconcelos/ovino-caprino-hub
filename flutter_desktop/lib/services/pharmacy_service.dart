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

      // 1) Insere no SQLite local
      await db.insert('pharmacy_stock', map);

      // 2) Sincroniza com Supabase primeiro para garantir a FK das movimentações
      if (SupabaseService.isConfigured) {
        await SupabaseService.supabase.from('pharmacy_stock').insert(map);
      }

      // 3) Só então registra a movimentação inicial (evita erro de FK no Supabase)
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

      if ((isAmpoule || stock.medicationType.toLowerCase() == 'ampola' || stock.medicationType.toLowerCase() == 'frasco')
          && stock.quantityPerUnit != null) {
        // Lógica para recipientes (Ampola/Frasco)
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

  // Lógica de uso de ampolas/frascos parciais
  static Future<void> _handleAmpouleUsage(PharmacyStock stock, double quantityUsed, String medicationId) async {
    final container = stock.medicationType.toLowerCase() == 'frasco' ? 'Frasco' : 'Ampola';
    final unitSize = stock.quantityPerUnit!; // ml por recipiente
    
    // Se usar exatamente o conteúdo do recipiente
    if (quantityUsed == unitSize) {
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
          reason: 'Aplicação de medicamento ($container completo)',
          createdAt: DateTime.now(),
        ),
      );
    } else {
      // Uso parcial do recipiente (ml)
      final remaining = unitSize - quantityUsed;
      if (remaining < 0) throw Exception('Quantidade usada maior que a capacidade do $container');
      
      // Deduzir 1 recipiente completo do estoque principal
      final newQuantity = stock.totalQuantity - 1;
      if (newQuantity < 0) throw Exception('Quantidade insuficiente em estoque');

      final updated = stock.copyWith(
        totalQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      await updateMedication(stock.id, updated);

      // Registrar saída do recipiente completo
      await recordMovement(
        PharmacyStockMovement(
          id: _uuid.v4(),
          pharmacyStockId: stock.id,
          medicationId: medicationId,
          movementType: 'saida',
          quantity: 1,
          reason: 'Aplicação de medicamento (${quantityUsed}ml usados de ${unitSize}ml)',
          createdAt: DateTime.now(),
        ),
      );

      // Se sobrou líquido, criar nova entrada de recipiente aberto
      if (remaining > 0) {
        final opened = PharmacyStock(
          id: _uuid.v4(),
          medicationName: '${stock.medicationName} ($container Aberto)',
          medicationType: stock.medicationType,
          unitOfMeasure: stock.unitOfMeasure,
          quantityPerUnit: unitSize,
          totalQuantity: remaining, // ml restantes no recipiente
          minStockAlert: null,
          expirationDate: stock.expirationDate,
          isOpened: true,
          notes: '$container aberto em ${DateTime.now().toIso8601String().split('T')[0]}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await createMedication(opened);
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
