// lib/services/system_maintenance_service.dart
import '../data/local_db.dart';

/// Serviço de manutenção do sistema (limpar banco, rotinas administrativas, etc.)
class SystemMaintenanceService {
  final AppDatabase _appDb;

  SystemMaintenanceService(this._appDb);

  /// Apaga TODOS os dados locais.
  ///
  /// A ordem importa por causa de FKs – usa a mesma sequência que você já tinha
  /// no `SystemSettingsScreen`.
  Future<void> clearAllData() async {
    final db = _appDb.db;

    const wipeOrder = <String>[
      'animal_weights',
      'breeding_records',
      'vaccinations',
      'medications',
      'notes',
      'financial_records',
      'financial_accounts',
      'reports',
      'push_tokens',
      'animals',
    ];

    await db.transaction((txn) async {
      for (final table in wipeOrder) {
        await txn.delete(table);
      }
    });
  }
}
