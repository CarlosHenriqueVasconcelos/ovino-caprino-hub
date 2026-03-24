import '../models/animal.dart';
import 'local_db.dart';

class DeceasedRepository {
  final AppDatabase _db;

  DeceasedRepository(this._db);

  Future<List<Animal>> fetchAll() async {
    final rows = await _db.db.query(
      'deceased_animals',
      orderBy: 'death_date DESC',
    );

    return rows.map(_mapRowToAnimal).toList();
  }

  Animal _mapRowToAnimal(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['status'] = 'Óbito';
    map['last_vaccination'] = null;
    map['expected_delivery'] = null;
    if (map['cause_of_death'] != null &&
        map['cause_of_death'].toString().isNotEmpty) {
      map['health_issue'] = map['cause_of_death'];
    }
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    map['updated_at'] = map['updated_at'] ?? DateTime.now().toIso8601String();
    return Animal.fromMap(map);
  }
}
