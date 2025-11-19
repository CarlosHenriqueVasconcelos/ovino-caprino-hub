import 'local_db.dart';

class AnimalCascadeRepository {
  final AppDatabase _appDatabase;

  AnimalCascadeRepository(this._appDatabase);

  Future<void> deleteCascade(String animalId) async {
    final db = _appDatabase.db;
    await db.transaction((txn) async {
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

