import '../models/animal.dart';
import 'local_db.dart';

class SoldAnimalsRepository {
  final AppDatabase _db;

  SoldAnimalsRepository(this._db);

  Future<List<Animal>> fetchAll() async {
    final rows = await _db.db.query(
      'sold_animals',
      orderBy: 'date(sale_date) DESC',
    );

    return rows.map(_mapRowToAnimal).toList();
  }

  Animal _mapRowToAnimal(Map<String, dynamic> row) {
    final map = Map<String, dynamic>.from(row);
    map['status'] = 'Vendido';
    map['last_vaccination'] = null;
    map['expected_delivery'] = null;
    map['health_issue'] = null;
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    map['updated_at'] = map['updated_at'] ?? DateTime.now().toIso8601String();
    return Animal.fromMap(map);
  }
}
