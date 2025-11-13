// lib/services/animal_delete_cascade.dart
//
// Exclusão "forte": remove o animal e TODOS os registros relacionados
// (pesos, vacinas, medicações, notas, financeiro, reprodução). Use com cautela.

import '../data/local_db.dart'; // AppDatabase

class AnimalDeleteCascade {
  final AppDatabase _appDatabase;

  AnimalDeleteCascade(this._appDatabase);

  /// Exclui o animal [animalId] e todos os registros relacionados.
  ///
  /// IMPORTANTE:
  /// - Essa operação é destrutiva e não pode ser desfeita.
  /// - Envolve múltiplas tabelas dentro de uma transação.
  Future<void> delete(String animalId) async {
    final db = _appDatabase.db;

    await db.transaction((txn) async {
      // Limpa vínculos de parentesco antes da exclusão para não violar FKs
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
