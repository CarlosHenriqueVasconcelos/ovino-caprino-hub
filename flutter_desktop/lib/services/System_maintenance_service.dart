// lib/services/system_maintenance_service.dart
import '../data/local_db.dart';

/// Serviço de manutenção do sistema (limpar banco, rotinas administrativas, etc.)
class SystemMaintenanceService {
  final AppDatabase _appDb;

  SystemMaintenanceService(this._appDb);

  /// Apaga TODOS os dados locais.
  ///
  /// A ordem respeita as foreign keys para evitar constraint errors.
  /// Tabelas referenciadas devem ser deletadas por último.
  Future<void> clearAllData() async {
    final db = _appDb.db;

    // Ordem correta: tabelas dependentes primeiro, tabelas referenciadas por último
    const wipeOrder = <String>[
      'pharmacy_stock_movements', // referencia medications e pharmacy_stock
      'feeding_schedules', // referencia feeding_pens
      'animal_weights', // referencia animals
      'weight_alerts', // referencia animals
      'breeding_records', // referencia animals
      'vaccinations', // referencia animals
      'medications', // referencia animals e pharmacy_stock
      'notes', // referencia animals
      'financial_records', // referencia animals
      'financial_accounts', // referencia animals e parent_id
      'feeding_pens', // sem dependências
      'pharmacy_stock', // sem dependências
      'reports', // sem dependências
      'push_tokens', // sem dependências
      'sold_animals', // sem dependências
      'deceased_animals', // sem dependências
      'animals', // por último - referenciado por muitas tabelas
    ];

    await db.transaction((txn) async {
      for (final table in wipeOrder) {
        await txn.delete(table);
      }
    });
  }
}
