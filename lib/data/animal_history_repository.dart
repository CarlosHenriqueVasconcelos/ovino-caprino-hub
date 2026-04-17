import 'package:drift/drift.dart' show Variable;

import '../models/animal.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

class AnimalHistoryData {
  final List<Map<String, Object?>> vaccinations;
  final List<Map<String, Object?>> medications;
  final List<Map<String, Object?>> notes;
  final List<Map<String, Object?>> weights;
  final List<Map<String, Object?>> offspring;
  final Animal? mother;
  final Animal? father;

  const AnimalHistoryData({
    required this.vaccinations,
    required this.medications,
    required this.notes,
    required this.weights,
    required this.offspring,
    required this.mother,
    required this.father,
  });
}

class AnimalHistoryRepository {
  final AppDatabase _appDb;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  AnimalHistoryRepository(
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

  Future<Animal?> _loadAnimalByIdAcrossTables(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final activeRows = await _driftDb!.customSelect(
        'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1',
        variables: _asVariables([farmId, id]),
      ).get();
      if (activeRows.isNotEmpty) {
        return Animal.fromMap(activeRows.first.data);
      }

      final soldRows = await _driftDb.customSelect(
        'SELECT * FROM sold_animals WHERE farm_id = ? AND id = ? LIMIT 1',
        variables: _asVariables([farmId, id]),
      ).get();
      if (soldRows.isNotEmpty) {
        final map = Map<String, dynamic>.from(soldRows.first.data);
        map['status'] = 'Vendido';
        return Animal.fromMap(map);
      }

      final deceasedRows = await _driftDb.customSelect(
        'SELECT * FROM deceased_animals WHERE farm_id = ? AND id = ? LIMIT 1',
        variables: _asVariables([farmId, id]),
      ).get();
      if (deceasedRows.isNotEmpty) {
        final map = Map<String, dynamic>.from(deceasedRows.first.data);
        map['status'] = 'Óbito';
        map['last_vaccination'] = null;
        map['expected_delivery'] = null;
        if (map['cause_of_death'] != null &&
            map['cause_of_death'].toString().isNotEmpty) {
          map['health_issue'] = map['cause_of_death'];
        }
        return Animal.fromMap(map);
      }
      return null;
    }

    final db = _appDb.db;
    final activeRows = await db.query(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (activeRows.isNotEmpty) {
      return Animal.fromMap(activeRows.first);
    }

    final soldRows = await db.query(
      'sold_animals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (soldRows.isNotEmpty) {
      final map = Map<String, dynamic>.from(soldRows.first);
      map['status'] = 'Vendido';
      return Animal.fromMap(map);
    }

    final deceasedRows = await db.query(
      'deceased_animals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (deceasedRows.isNotEmpty) {
      final map = Map<String, dynamic>.from(deceasedRows.first);
      map['status'] = 'Óbito';
      map['last_vaccination'] = null;
      map['expected_delivery'] = null;
      if (map['cause_of_death'] != null &&
          map['cause_of_death'].toString().isNotEmpty) {
        map['health_issue'] = map['cause_of_death'];
      }
      return Animal.fromMap(map);
    }

    return null;
  }

  Future<AnimalHistoryData> loadHistory(Animal animal) async {
    final id = animal.id;
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final vaccinationsRows = await _driftDb!.customSelect(
        '''
        SELECT * FROM vaccinations
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY
          CASE WHEN applied_date IS NOT NULL THEN 0 ELSE 1 END,
          COALESCE(applied_date, scheduled_date) DESC
        ''',
        variables: _asVariables([farmId, id]),
      ).get();
      final medicationsRows = await _driftDb.customSelect(
        '''
        SELECT * FROM medications
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY COALESCE(applied_date, date) DESC
        ''',
        variables: _asVariables([farmId, id]),
      ).get();
      final notesRows = await _driftDb.customSelect(
        '''
        SELECT * FROM notes
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY date DESC, created_at DESC
        ''',
        variables: _asVariables([farmId, id]),
      ).get();
      final weightsRows = await _driftDb.customSelect(
        '''
        SELECT * FROM animal_weights
        WHERE farm_id = ? AND animal_id = ?
        ORDER BY date DESC
        ''',
        variables: _asVariables([farmId, id]),
      ).get();
      final offspringRows = await _driftDb.customSelect(
        '''
        SELECT id, name, code, category, name_color, lote, 'ativo' AS status
        FROM animals
        WHERE farm_id = ? AND (mother_id = ? OR father_id = ?)
        UNION ALL
        SELECT id, name, code, category, name_color, lote, 'vendido' AS status
        FROM sold_animals
        WHERE farm_id = ? AND (mother_id = ? OR father_id = ?)
        UNION ALL
        SELECT id, name, code, category, name_color, lote, 'falecido' AS status
        FROM deceased_animals
        WHERE farm_id = ? AND (mother_id = ? OR father_id = ?)
        ORDER BY name
        ''',
        variables: _asVariables([
          farmId,
          id,
          id,
          farmId,
          id,
          id,
          farmId,
          id,
          id,
        ]),
      ).get();

      Animal? mother;
      if (animal.motherId != null && animal.motherId!.isNotEmpty) {
        mother = await _loadAnimalByIdAcrossTables(animal.motherId!);
      }

      Animal? father;
      if (animal.fatherId != null && animal.fatherId!.isNotEmpty) {
        father = await _loadAnimalByIdAcrossTables(animal.fatherId!);
      }

      return AnimalHistoryData(
        vaccinations:
            vaccinationsRows.map((r) => Map<String, Object?>.from(r.data)).toList(),
        medications:
            medicationsRows.map((r) => Map<String, Object?>.from(r.data)).toList(),
        notes: notesRows.map((r) => Map<String, Object?>.from(r.data)).toList(),
        weights:
            weightsRows.map((r) => Map<String, Object?>.from(r.data)).toList(),
        offspring:
            offspringRows.map((r) => Map<String, Object?>.from(r.data)).toList(),
        mother: mother,
        father: father,
      );
    }

    final db = _appDb.db;
    final vaccinations = await db.rawQuery('''
      SELECT * FROM vaccinations
      WHERE animal_id = ?
      ORDER BY 
        CASE WHEN applied_date IS NOT NULL THEN 0 ELSE 1 END,
        COALESCE(applied_date, scheduled_date) DESC
    ''', [id]);

    final medications = await db.rawQuery('''
      SELECT * FROM medications
      WHERE animal_id = ?
      ORDER BY COALESCE(applied_date, date) DESC
    ''', [id]);

    final notes = await db.rawQuery('''
      SELECT * FROM notes
      WHERE animal_id = ?
      ORDER BY date DESC, created_at DESC
    ''', [id]);

    final weights = await db.rawQuery('''
      SELECT * FROM animal_weights
      WHERE animal_id = ?
      ORDER BY date DESC
    ''', [id]);

    final offspring = await db.rawQuery('''
      SELECT id, name, code, category, name_color, lote, 'ativo' as status 
      FROM animals 
      WHERE mother_id = ? OR father_id = ?
      UNION ALL
      SELECT id, name, code, category, name_color, lote, 'vendido' as status 
      FROM sold_animals 
      WHERE mother_id = ? OR father_id = ?
      UNION ALL
      SELECT id, name, code, category, name_color, lote, 'falecido' as status 
      FROM deceased_animals 
      WHERE mother_id = ? OR father_id = ?
      ORDER BY name
    ''', [id, id, id, id, id, id]);

    Animal? mother;
    if (animal.motherId != null && animal.motherId!.isNotEmpty) {
      mother = await _loadAnimalByIdAcrossTables(animal.motherId!);
    }

    Animal? father;
    if (animal.fatherId != null && animal.fatherId!.isNotEmpty) {
      father = await _loadAnimalByIdAcrossTables(animal.fatherId!);
    }

    return AnimalHistoryData(
      vaccinations: vaccinations,
      medications: medications,
      notes: notes,
      weights: weights,
      offspring: offspring,
      mother: mother,
      father: father,
    );
  }
}
