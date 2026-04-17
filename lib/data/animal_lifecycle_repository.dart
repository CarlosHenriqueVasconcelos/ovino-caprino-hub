import 'package:drift/drift.dart' show Variable;
import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;

import '../services/events/app_events.dart';
import '../services/events/event_bus.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

class AnimalLifecycleRepository {
  final AppDatabase _appDb;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  AnimalLifecycleRepository(
    AppDatabase appDb, {
    AppDriftDatabase? driftDb,
    String? Function()? farmIdProvider,
  })  : _appDb = appDb,
        _driftDb = driftDb,
        _farmIdProvider = farmIdProvider,
        _legacyBridge = driftDb == null
            ? null
            : LegacySqfliteToDriftBridge(
                legacyDb: appDb,
                driftDb: driftDb,
              );

  String? get _currentFarmId => _farmIdProvider?.call();

  List<Variable<Object>> _asVariables(List<Object?> args) {
    return args
        .map((arg) => Variable<Object>(arg as Object))
        .toList(growable: false);
  }

  Future<String?> _prepareFarmContext() async {
    final farmId = _currentFarmId;
    if (farmId == null || _driftDb == null) return null;
    await _legacyBridge?.migrateForFarm(farmId);
    return farmId;
  }

  Future<void> moveToDeceased(
    String animalId, {
    DateTime? deathDate,
    String? causeOfDeath,
    String? notes,
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _moveToDeceasedDrift(
        farmId: farmId,
        animalId: animalId,
        deathDate: deathDate,
        causeOfDeath: causeOfDeath,
        notes: notes,
      );
      return;
    }

    await _moveToDeceasedLegacy(
      animalId: animalId,
      deathDate: deathDate,
      causeOfDeath: causeOfDeath,
      notes: notes,
    );
  }

  Future<void> _moveToDeceasedDrift({
    required String farmId,
    required String animalId,
    DateTime? deathDate,
    String? causeOfDeath,
    String? notes,
  }) async {
    await _driftDb!.transaction(() async {
      final rows = await _driftDb.customSelect(
        'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1',
        variables: _asVariables([farmId, animalId]),
      ).get();
      if (rows.isEmpty) {
        throw Exception(
          'Animal não encontrado na tabela ativa para registrar óbito.',
        );
      }

      final animalData = rows.first.data;
      final nowIso = DateTime.now().toIso8601String();
      final deathDateOnly =
          (deathDate ?? DateTime.now()).toIso8601String().split('T').first;
      final resolvedCause =
          (causeOfDeath != null && causeOfDeath.trim().isNotEmpty)
              ? causeOfDeath.trim()
              : (animalData['health_issue']?.toString().trim().isNotEmpty ==
                      true
                  ? animalData['health_issue']?.toString().trim()
                  : null);
      final resolvedNotes = (notes != null && notes.trim().isNotEmpty)
          ? notes.trim()
          : 'Animal registrado como óbito';

      await _driftDb.customStatement(
        '''
        INSERT OR REPLACE INTO deceased_animals(
          id, farm_id, original_animal_id, code, name, species, breed, gender,
          birth_date, weight, location, reproductive_status, name_color, category,
          birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
          year, lote, mother_id, father_id, registration_note,
          death_date, cause_of_death, death_notes, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          animalData['id'],
          farmId,
          animalData['id'],
          animalData['code'],
          animalData['name'],
          animalData['species'],
          animalData['breed'],
          animalData['gender'],
          animalData['birth_date'],
          animalData['weight'],
          animalData['location'],
          animalData['reproductive_status'],
          animalData['name_color'],
          animalData['category'],
          animalData['birth_weight'],
          animalData['weight_30_days'],
          animalData['weight_60_days'],
          animalData['weight_90_days'],
          animalData['weight_120_days'],
          animalData['year'],
          animalData['lote'],
          animalData['mother_id'],
          animalData['father_id'],
          animalData['registration_note'],
          deathDateOnly,
          resolvedCause,
          resolvedNotes,
          nowIso,
          nowIso,
        ],
      );

      await _driftDb.customStatement(
        'DELETE FROM animal_weights WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM weight_alerts WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM vaccinations WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM matrix_evaluations WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );

      final meds = (await _driftDb
              .customSelect(
                'SELECT id FROM medications WHERE farm_id = ? AND animal_id = ?',
                variables: _asVariables([farmId, animalId]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      for (final med in meds) {
        final medId = med['id']?.toString();
        if (medId == null || medId.isEmpty) continue;
        await _driftDb.customStatement(
          'DELETE FROM pharmacy_stock_movements WHERE farm_id = ? AND medication_id = ?',
          [farmId, medId],
        );
      }
      await _driftDb.customStatement(
        'DELETE FROM medications WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );

      await _driftDb.customStatement(
        'UPDATE notes SET animal_id = NULL WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'UPDATE financial_records SET animal_id = NULL WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'UPDATE financial_accounts SET animal_id = NULL WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'UPDATE breeding_records SET female_animal_id = NULL WHERE farm_id = ? AND female_animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'UPDATE breeding_records SET male_animal_id = NULL WHERE farm_id = ? AND male_animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM animals WHERE farm_id = ? AND id = ?',
        [farmId, animalId],
      );
    });
  }

  Future<void> _moveToDeceasedLegacy({
    required String animalId,
    DateTime? deathDate,
    String? causeOfDeath,
    String? notes,
  }) async {
    final db = _appDb.db;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'animals',
        where: 'id = ?',
        whereArgs: [animalId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw Exception(
          'Animal não encontrado na tabela ativa para registrar óbito.',
        );
      }
      final animalData = rows.first;
      final nowIso = DateTime.now().toIso8601String();
      final deathDateOnly =
          (deathDate ?? DateTime.now()).toIso8601String().split('T').first;
      final resolvedCause =
          (causeOfDeath != null && causeOfDeath.trim().isNotEmpty)
              ? causeOfDeath.trim()
              : (animalData['health_issue']?.toString().trim().isNotEmpty ==
                      true
                  ? animalData['health_issue']?.toString().trim()
                  : null);
      final resolvedNotes = (notes != null && notes.trim().isNotEmpty)
          ? notes.trim()
          : 'Animal registrado como óbito';

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
          'reproductive_status': animalData['reproductive_status'],
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
          'registration_note': animalData['registration_note'],
          'death_date': deathDateOnly,
          'cause_of_death': resolvedCause,
          'death_notes': resolvedNotes,
          'created_at': nowIso,
          'updated_at': nowIso,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'animal_weights',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      await txn.delete(
        'weight_alerts',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      await txn.delete(
        'vaccinations',
        where: 'animal_id = ?',
        whereArgs: [animalId],
      );
      await txn.delete(
        'matrix_evaluations',
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
        'notes',
        {'animal_id': null},
        where: 'animal_id = ?',
        whereArgs: [animalId],
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
    });
  }

  Future<void> moveToSold({
    required String animalId,
    required DateTime saleDate,
    required double salePrice,
    String? buyer,
    String? notes,
  }) async {
    await _moveToSoldInternal(
      animalId: animalId,
      saleDate: saleDate,
      salePrice: salePrice,
      buyer: buyer,
      notes: notes,
    );
    EventBus().emit(
      AnimalMarkedAsSoldEvent(
        animalId: animalId,
        saleDate: saleDate,
        salePrice: salePrice,
      ),
    );
  }

  Future<void> moveToSoldManual({
    required String animalId,
    DateTime? saleDate,
    double salePrice = 0,
    String? buyer,
    String? notes,
  }) async {
    final saleDateValue = saleDate ?? DateTime.now();
    await _moveToSoldInternal(
      animalId: animalId,
      saleDate: saleDateValue,
      salePrice: salePrice,
      buyer: buyer,
      notes: notes,
      defaultNotes: 'Status marcado como Vendido',
    );
    EventBus().emit(
      AnimalMarkedAsSoldEvent(
        animalId: animalId,
        saleDate: saleDateValue,
        salePrice: salePrice,
      ),
    );
  }

  Future<void> _moveToSoldInternal({
    required String animalId,
    required DateTime saleDate,
    required double salePrice,
    String? buyer,
    String? notes,
    String? defaultNotes,
  }) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _moveToSoldDrift(
        farmId: farmId,
        animalId: animalId,
        saleDate: saleDate,
        salePrice: salePrice,
        buyer: buyer,
        notes: notes,
        defaultNotes: defaultNotes,
      );
      return;
    }

    await _moveToSoldLegacy(
      animalId: animalId,
      saleDate: saleDate,
      salePrice: salePrice,
      buyer: buyer,
      notes: notes,
      defaultNotes: defaultNotes,
    );
  }

  Future<void> _moveToSoldDrift({
    required String farmId,
    required String animalId,
    required DateTime saleDate,
    required double salePrice,
    String? buyer,
    String? notes,
    String? defaultNotes,
  }) async {
    await _driftDb!.transaction(() async {
      final rows = await _driftDb.customSelect(
        'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1',
        variables: _asVariables([farmId, animalId]),
      ).get();
      if (rows.isEmpty) return;

      final animalData = rows.first.data;
      final nowIso = DateTime.now().toIso8601String();
      final saleDateIso = saleDate.toIso8601String().split('T').first;
      final resolvedNotes = (notes != null && notes.trim().isNotEmpty)
          ? notes.trim()
          : defaultNotes;

      await _driftDb.customStatement(
        '''
        INSERT OR REPLACE INTO sold_animals(
          id, farm_id, original_animal_id, code, name, species, breed, gender,
          birth_date, weight, location, reproductive_status, name_color, category,
          birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
          year, lote, mother_id, father_id, registration_note,
          sale_date, sale_price, buyer, sale_notes, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          animalData['id'],
          farmId,
          animalData['id'],
          animalData['code'],
          animalData['name'],
          animalData['species'],
          animalData['breed'],
          animalData['gender'],
          animalData['birth_date'],
          animalData['weight'],
          animalData['location'],
          animalData['reproductive_status'],
          animalData['name_color'],
          animalData['category'],
          animalData['birth_weight'],
          animalData['weight_30_days'],
          animalData['weight_60_days'],
          animalData['weight_90_days'],
          animalData['weight_120_days'],
          animalData['year'],
          animalData['lote'],
          animalData['mother_id'],
          animalData['father_id'],
          animalData['registration_note'],
          saleDateIso,
          salePrice,
          buyer,
          resolvedNotes,
          nowIso,
          nowIso,
        ],
      );

      await _driftDb.customStatement(
        'UPDATE financial_records SET animal_id = NULL WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'UPDATE financial_accounts SET animal_id = NULL WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'UPDATE notes SET animal_id = NULL WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM animal_weights WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM weight_alerts WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM vaccinations WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM matrix_evaluations WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );

      final meds = (await _driftDb
              .customSelect(
                'SELECT id FROM medications WHERE farm_id = ? AND animal_id = ?',
                variables: _asVariables([farmId, animalId]),
              )
              .get())
          .map((r) => r.data)
          .toList();
      for (final med in meds) {
        final medId = med['id']?.toString();
        if (medId == null || medId.isEmpty) continue;
        await _driftDb.customStatement(
          'DELETE FROM pharmacy_stock_movements WHERE farm_id = ? AND medication_id = ?',
          [farmId, medId],
        );
      }
      await _driftDb.customStatement(
        'DELETE FROM medications WHERE farm_id = ? AND animal_id = ?',
        [farmId, animalId],
      );

      await _driftDb.customStatement(
        'UPDATE breeding_records SET female_animal_id = NULL WHERE farm_id = ? AND female_animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'UPDATE breeding_records SET male_animal_id = NULL WHERE farm_id = ? AND male_animal_id = ?',
        [farmId, animalId],
      );
      await _driftDb.customStatement(
        'DELETE FROM animals WHERE farm_id = ? AND id = ?',
        [farmId, animalId],
      );
    });
  }

  Future<void> _moveToSoldLegacy({
    required String animalId,
    required DateTime saleDate,
    required double salePrice,
    String? buyer,
    String? notes,
    String? defaultNotes,
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
        final resolvedNotes = (notes != null && notes.trim().isNotEmpty)
            ? notes.trim()
            : defaultNotes;

        await txn.insert(
          'sold_animals',
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
            'reproductive_status': animalData['reproductive_status'],
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
            'registration_note': animalData['registration_note'],
            'sale_date': saleDateIso,
            'sale_price': salePrice,
            'buyer': buyer,
            'sale_notes': resolvedNotes,
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
          'weight_alerts',
          where: 'animal_id = ?',
          whereArgs: [animalId],
        );
        await txn.delete(
          'vaccinations',
          where: 'animal_id = ?',
          whereArgs: [animalId],
        );
        await txn.delete(
          'matrix_evaluations',
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
  }
}
