// lib/services/animal_delete_cascade.dart
// Exclusão "forte": remove o animal e TODOS os registros relacionados
// (pesos, vacinas, medicações, notas, financeiro, reprodução). Use com cautela.

import 'package:sqflite_common/sqlite_api.dart';
import 'database_service.dart';

class AnimalDeleteCascade {
  static Future<void> delete(String animalId) async {
    final db = await DatabaseService.database;

    await db.transaction((txn) async {
      await txn.delete('animal_weights', where: 'animal_id = ?', whereArgs: [animalId]);
      await txn.delete('vaccinations',  where: 'animal_id = ?', whereArgs: [animalId]);
      await txn.delete('medications',   where: 'animal_id = ?', whereArgs: [animalId]);
      await txn.delete('notes',         where: 'animal_id = ?', whereArgs: [animalId]);
      await txn.delete('financial_records',  where: 'animal_id = ?', whereArgs: [animalId]);
      await txn.delete('financial_accounts', where: 'animal_id = ?', whereArgs: [animalId]);

      await txn.delete(
        'breeding_records',
        where: 'female_animal_id = ? OR male_animal_id = ?',
        whereArgs: [animalId, animalId],
      );

      await txn.delete('animals', where: 'id = ?', whereArgs: [animalId]);
    });
  }
}
