import 'package:sqflite/sqflite.dart';

import '../data/local_db.dart';
import '../models/animal.dart';

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

class AnimalHistoryService {
  final AppDatabase _appDb;

  AnimalHistoryService(this._appDb);

  Database get _db => _appDb.db;

  Future<AnimalHistoryData> loadHistory(Animal animal) async {
    final id = animal.id;

    // Vacinas do animal (mesma query que estava no widget)
    final vaccinations = await _db.rawQuery('''
      SELECT * FROM vaccinations
      WHERE animal_id = ?
      ORDER BY 
        CASE WHEN applied_date IS NOT NULL THEN 0 ELSE 1 END,
        COALESCE(applied_date, scheduled_date) DESC
    ''', [id]);

    // Medicações
    final medications = await _db.rawQuery('''
      SELECT * FROM medications
      WHERE animal_id = ?
      ORDER BY COALESCE(applied_date, date) DESC
    ''', [id]);

    // Anotações
    final notes = await _db.rawQuery('''
      SELECT * FROM notes
      WHERE animal_id = ?
      ORDER BY date DESC, created_at DESC
    ''', [id]);

    // Pesos
    final weights = await _db.rawQuery('''
      SELECT * FROM animal_weights
      WHERE animal_id = ?
      ORDER BY date DESC
    ''', [id]);

    // Filhotes (ativos, vendidos, falecidos) — mesmo UNION do widget
    final offspring = await _db.rawQuery('''
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

    // Pais (mãe e pai)
    Animal? mother;
    if (animal.motherId != null) {
      final rows = await _db.query(
        'animals',
        where: 'id = ?',
        whereArgs: [animal.motherId],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        mother = Animal.fromMap(rows.first);
      }
    }

    Animal? father;
    if (animal.fatherId != null) {
      final rows = await _db.query(
        'animals',
        where: 'id = ?',
        whereArgs: [animal.fatherId],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        father = Animal.fromMap(rows.first);
      }
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
