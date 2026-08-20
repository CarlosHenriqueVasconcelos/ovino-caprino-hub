import 'package:drift/drift.dart' show Variable;

import 'drift/app_database.dart';

class AnimalCascadeRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  AnimalCascadeRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<void> deleteCascade(String animalId) async {
    final farmId = _farmId;
    await _db.transaction(() async {
      Future<void> stmt(
        String sqlWithFarm,
        String sqlWithout, [
        List<Object?> extra = const [],
      ]) async {
        if (farmId != null) {
          await _db.customStatement(sqlWithFarm, [farmId, animalId, ...extra]);
        } else {
          await _db.customStatement(sqlWithout, [animalId, ...extra]);
        }
      }

      await stmt(
        'UPDATE animals SET mother_id = NULL WHERE farm_id = ? AND mother_id = ?',
        'UPDATE animals SET mother_id = NULL WHERE mother_id = ?',
      );
      await stmt(
        'UPDATE animals SET father_id = NULL WHERE farm_id = ? AND father_id = ?',
        'UPDATE animals SET father_id = NULL WHERE father_id = ?',
      );
      await stmt(
        'DELETE FROM animal_weights WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM animal_weights WHERE animal_id = ?',
      );
      await stmt(
        'DELETE FROM vaccinations WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM vaccinations WHERE animal_id = ?',
      );

      final meds = await _db.customSelect(
        farmId != null
            ? 'SELECT id FROM medications WHERE farm_id = ? AND animal_id = ?'
            : 'SELECT id FROM medications WHERE animal_id = ?',
        variables: farmId != null ? _vars([farmId, animalId]) : _vars([animalId]),
      ).get();
      for (final med in meds) {
        final medId = med.data['id']?.toString();
        if (medId == null || medId.isEmpty) continue;
        if (farmId != null) {
          await _db.customStatement(
            'DELETE FROM pharmacy_stock_movements WHERE farm_id = ? AND medication_id = ?',
            [farmId, medId],
          );
        } else {
          await _db.customStatement(
            'DELETE FROM pharmacy_stock_movements WHERE medication_id = ?',
            [medId],
          );
        }
      }

      await stmt(
        'DELETE FROM medications WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM medications WHERE animal_id = ?',
      );
      await stmt(
        'DELETE FROM notes WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM notes WHERE animal_id = ?',
      );
      await stmt(
        'DELETE FROM financial_records WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM financial_records WHERE animal_id = ?',
      );
      await stmt(
        'DELETE FROM financial_accounts WHERE farm_id = ? AND animal_id = ?',
        'DELETE FROM financial_accounts WHERE animal_id = ?',
      );

      if (farmId != null) {
        await _db.customStatement(
          'DELETE FROM breeding_records WHERE farm_id = ? AND (female_animal_id = ? OR male_animal_id = ?)',
          [farmId, animalId, animalId],
        );
      } else {
        await _db.customStatement(
          'DELETE FROM breeding_records WHERE female_animal_id = ? OR male_animal_id = ?',
          [animalId, animalId],
        );
      }

      await stmt(
        'DELETE FROM animals WHERE farm_id = ? AND id = ?',
        'DELETE FROM animals WHERE id = ?',
      );
    });
  }
}
