import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;

import 'local_db.dart';
import '../services/events/event_bus.dart';
import '../services/events/app_events.dart';

class AnimalLifecycleRepository {
  final AppDatabase _appDb;

  AnimalLifecycleRepository(this._appDb);

  Future<void> moveToDeceased(String animalId) async {
    final db = _appDb.db;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'animals',
        where: 'id = ?',
        whereArgs: [animalId],
        limit: 1,
      );
      if (rows.isEmpty) return;
      final animalData = rows.first;
      final nowIso = DateTime.now().toIso8601String();
      final dateOnly = nowIso.split('T').first;

      await txn.insert(
        'deceased_animals',
        {
          'id': animalData['id'],
          'original_animal_id': animalData['id'],
          'code': animalData['code'],
          'name': animalData['name'],
          'species': animalData['species'],
          'breed': animalData['breed'],
          'gender': animalData['gender'],
          'birth_date': animalData['birth_date'],
          'weight': animalData['weight'],
          'location': animalData['location'],
          'name_color': animalData['name_color'],
          'category': animalData['category'],
          'birth_weight': animalData['birth_weight'],
          'weight_30_days': animalData['weight_30_days'],
          'weight_60_days': animalData['weight_60_days'],
          'weight_90_days': animalData['weight_90_days'],
          'weight_120_days': animalData['weight_120_days'],
          'year': animalData['year'],
          'lote': animalData['lote'],
          'mother_id': animalData['mother_id'],
          'father_id': animalData['father_id'],
          'death_date': dateOnly,
          'cause_of_death': animalData['health_issue'],
          'death_notes': 'Animal registrado como óbito',
          'created_at': nowIso,
          'updated_at': nowIso,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'animals',
        where: 'id = ?',
        whereArgs: [animalId],
      );
    });
  }

  Future<void> moveToSold({
    required String animalId,
    required DateTime saleDate,
    required double salePrice,
    String? buyer,
    String? notes,
  }) async {
    final db = _appDb.db;
    await db.transaction((txn) async {
      try {
        await txn.execute('PRAGMA foreign_keys = OFF');
        final animals = await txn.query(
          'animals',
          where: 'id = ?',
          whereArgs: [animalId],
          limit: 1,
        );
        if (animals.isEmpty) return;

        final animalData = animals.first;
        final nowIso = DateTime.now().toIso8601String();
        final saleDateIso = saleDate.toIso8601String().split('T').first;

        await txn.insert(
          'sold_animals',
          {
            // Preserva o id original para facilitar joins/listas
            'id': animalData['id'],
            'original_animal_id': animalData['id'],
            'code': animalData['code'],
            'name': animalData['name'],
            'species': animalData['species'],
            'breed': animalData['breed'],
            'gender': animalData['gender'],
            'birth_date': animalData['birth_date'],
            'weight': animalData['weight'],
            'location': animalData['location'],
            'name_color': animalData['name_color'],
            'category': animalData['category'],
            'birth_weight': animalData['birth_weight'],
            'weight_30_days': animalData['weight_30_days'],
            'weight_60_days': animalData['weight_60_days'],
            'weight_90_days': animalData['weight_90_days'],
            'weight_120_days': animalData['weight_120_days'],
            'year': animalData['year'],
            'lote': animalData['lote'],
            'mother_id': animalData['mother_id'],
            'father_id': animalData['father_id'],
            'sale_date': saleDateIso,
            'sale_price': salePrice,
            'buyer': buyer,
            'sale_notes': notes,
            'created_at': nowIso,
            'updated_at': nowIso,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.update(
          'financial_records',
          {'animal_id': null},
          where: 'animal_id = ?',
          whereArgs: [animalId],
        );
        await txn.update(
          'financial_accounts',
          {'animal_id': null},
          where: 'animal_id = ?',
          whereArgs: [animalId],
        );
        await txn.update(
          'notes',
          {'animal_id': null},
          where: 'animal_id = ?',
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

        await txn.update(
          'breeding_records',
          {'female_animal_id': null},
          where: 'female_animal_id = ?',
          whereArgs: [animalId],
        );
        await txn.update(
          'breeding_records',
          {'male_animal_id': null},
          where: 'male_animal_id = ?',
          whereArgs: [animalId],
        );

        await txn.delete(
          'animals',
          where: 'id = ?',
          whereArgs: [animalId],
        );
      } catch (_) {
        rethrow;
      } finally {
        await txn.execute('PRAGMA foreign_keys = ON');
      }
    });
    EventBus().emit(AnimalMarkedAsSoldEvent(
      animalId: animalId,
      saleDate: saleDate,
      salePrice: salePrice,
    ));
  }

  Future<void> moveToSoldManual({
    required String animalId,
    DateTime? saleDate,
    double salePrice = 0,
    String? buyer,
    String? notes,
  }) async {
    final db = _appDb.db;
    await db.transaction((txn) async {
      try {
        await txn.execute('PRAGMA foreign_keys = OFF');
        final animals = await txn.query(
          'animals',
          where: 'id = ?',
          whereArgs: [animalId],
          limit: 1,
        );
        if (animals.isEmpty) return;

        final animalData = animals.first;
        final nowIso = DateTime.now().toIso8601String();
        final saleDateIso =
            (saleDate ?? DateTime.now()).toIso8601String().split('T').first;

        await txn.insert(
          'sold_animals',
          {
            // Preserva o id original para facilitar joins/listas
            'id': animalData['id'],
            'original_animal_id': animalData['id'],
            'code': animalData['code'],
            'name': animalData['name'],
            'species': animalData['species'],
            'breed': animalData['breed'],
            'gender': animalData['gender'],
            'birth_date': animalData['birth_date'],
            'weight': animalData['weight'],
            'location': animalData['location'],
            'name_color': animalData['name_color'],
            'category': animalData['category'],
            'birth_weight': animalData['birth_weight'],
            'weight_30_days': animalData['weight_30_days'],
            'weight_60_days': animalData['weight_60_days'],
            'weight_90_days': animalData['weight_90_days'],
            'weight_120_days': animalData['weight_120_days'],
            'year': animalData['year'],
            'lote': animalData['lote'],
            'mother_id': animalData['mother_id'],
            'father_id': animalData['father_id'],
            'sale_date': saleDateIso,
            'sale_price': salePrice,
            'buyer': buyer,
            'sale_notes': notes ?? 'Status marcado como Vendido',
            'created_at': nowIso,
            'updated_at': nowIso,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.update(
          'financial_records',
          {'animal_id': null},
          where: 'animal_id = ?',
          whereArgs: [animalId],
        );
        await txn.update(
          'financial_accounts',
          {'animal_id': null},
          where: 'animal_id = ?',
          whereArgs: [animalId],
        );
        await txn.update(
          'notes',
          {'animal_id': null},
          where: 'animal_id = ?',
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

        await txn.update(
          'breeding_records',
          {'female_animal_id': null},
          where: 'female_animal_id = ?',
          whereArgs: [animalId],
        );
        await txn.update(
          'breeding_records',
          {'male_animal_id': null},
          where: 'male_animal_id = ?',
          whereArgs: [animalId],
        );

        await txn.delete(
          'animals',
          where: 'id = ?',
          whereArgs: [animalId],
        );
      } catch (_) {
        rethrow;
      } finally {
        await txn.execute('PRAGMA foreign_keys = ON');
      }
    });
    EventBus().emit(AnimalMarkedAsSoldEvent(
      animalId: animalId,
      saleDate: saleDate ?? DateTime.now(),
      salePrice: salePrice,
    ));
  }
}
