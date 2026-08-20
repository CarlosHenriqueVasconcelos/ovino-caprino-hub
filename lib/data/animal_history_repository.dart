import 'package:drift/drift.dart' show Variable;

import '../models/animal.dart';
import 'drift/app_database.dart';

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
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  AnimalHistoryRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<Animal?> _loadAnimalByIdAcrossTables(String id) async {
    final farmId = _farmId;
    for (final entry in const [
      ('animals', null),
      ('sold_animals', 'Vendido'),
      ('deceased_animals', 'Óbito'),
    ]) {
      final table = entry.$1;
      final statusOverride = entry.$2;
      final rows = await _db.customSelect(
        farmId != null
            ? 'SELECT * FROM $table WHERE farm_id = ? AND id = ? LIMIT 1'
            : 'SELECT * FROM $table WHERE id = ? LIMIT 1',
        variables:
            farmId != null ? _vars([farmId, id]) : _vars([id]),
      ).get();
      if (rows.isEmpty) continue;
      final map = Map<String, dynamic>.from(rows.first.data);
      if (statusOverride != null) {
        map['status'] = statusOverride;
        if (table == 'deceased_animals') {
          map['last_vaccination'] = null;
          map['expected_delivery'] = null;
          if (map['cause_of_death'] != null &&
              map['cause_of_death'].toString().isNotEmpty) {
            map['health_issue'] = map['cause_of_death'];
          }
        }
      }
      return Animal.fromMap(map);
    }
    return null;
  }

  Future<AnimalHistoryData> loadHistory(Animal animal) async {
    final id = animal.id;
    final farmId = _farmId;

    final vaccinationsRows = await _db.customSelect(
      farmId != null
          ? '''
          SELECT * FROM vaccinations
          WHERE farm_id = ? AND animal_id = ?
          ORDER BY
            CASE WHEN applied_date IS NOT NULL THEN 0 ELSE 1 END,
            COALESCE(applied_date, scheduled_date) DESC
          '''
          : '''
          SELECT * FROM vaccinations
          WHERE animal_id = ?
          ORDER BY
            CASE WHEN applied_date IS NOT NULL THEN 0 ELSE 1 END,
            COALESCE(applied_date, scheduled_date) DESC
          ''',
      variables: farmId != null ? _vars([farmId, id]) : _vars([id]),
    ).get();

    final medicationsRows = await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM medications WHERE farm_id = ? AND animal_id = ? ORDER BY COALESCE(applied_date, date) DESC'
          : 'SELECT * FROM medications WHERE animal_id = ? ORDER BY COALESCE(applied_date, date) DESC',
      variables: farmId != null ? _vars([farmId, id]) : _vars([id]),
    ).get();

    final notesRows = await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM notes WHERE farm_id = ? AND animal_id = ? ORDER BY date DESC, created_at DESC'
          : 'SELECT * FROM notes WHERE animal_id = ? ORDER BY date DESC, created_at DESC',
      variables: farmId != null ? _vars([farmId, id]) : _vars([id]),
    ).get();

    final weightsRows = await _db.customSelect(
      farmId != null
          ? 'SELECT * FROM animal_weights WHERE farm_id = ? AND animal_id = ? ORDER BY date DESC'
          : 'SELECT * FROM animal_weights WHERE animal_id = ? ORDER BY date DESC',
      variables: farmId != null ? _vars([farmId, id]) : _vars([id]),
    ).get();

    final offspringRows = await _db.customSelect(
      farmId != null
          ? '''
          SELECT id, name, code, category, name_color, lote, 'ativo' AS status
          FROM animals WHERE farm_id = ? AND (mother_id = ? OR father_id = ?)
          UNION ALL
          SELECT id, name, code, category, name_color, lote, 'vendido' AS status
          FROM sold_animals WHERE farm_id = ? AND (mother_id = ? OR father_id = ?)
          UNION ALL
          SELECT id, name, code, category, name_color, lote, 'falecido' AS status
          FROM deceased_animals WHERE farm_id = ? AND (mother_id = ? OR father_id = ?)
          ORDER BY name
          '''
          : '''
          SELECT id, name, code, category, name_color, lote, 'ativo' AS status
          FROM animals WHERE mother_id = ? OR father_id = ?
          UNION ALL
          SELECT id, name, code, category, name_color, lote, 'vendido' AS status
          FROM sold_animals WHERE mother_id = ? OR father_id = ?
          UNION ALL
          SELECT id, name, code, category, name_color, lote, 'falecido' AS status
          FROM deceased_animals WHERE mother_id = ? OR father_id = ?
          ORDER BY name
          ''',
      variables: farmId != null
          ? _vars([farmId, id, id, farmId, id, id, farmId, id, id])
          : _vars([id, id, id, id, id, id]),
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
}
