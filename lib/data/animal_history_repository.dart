import '../models/animal.dart';
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

  AnimalHistoryRepository(this._appDb);

  Future<Animal?> _loadAnimalByIdAcrossTables(String id) async {
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
