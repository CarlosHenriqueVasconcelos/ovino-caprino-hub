import 'package:flutter/foundation.dart';
import '../data/local_db.dart';
import '../models/animal.dart';

class SoldAnimalsService extends ChangeNotifier {
  final AppDatabase _appDb;
  SoldAnimalsService(this._appDb);

  Future<List<Animal>> getSoldAnimals() async {
    final rows = await _appDb.db.query(
      'sold_animals',
      orderBy: 'date(sale_date) DESC',
    );
    return rows.map((m) {
      final map = Map<String, dynamic>.from(m);
      map['status'] = 'Vendido';
      map['last_vaccination'] = null;
      map['expected_delivery'] = null;
      map['health_issue'] = null;
      map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
      map['updated_at'] = map['updated_at'] ?? DateTime.now().toIso8601String();
      return Animal.fromMap(map);
    }).toList();
  }
}
