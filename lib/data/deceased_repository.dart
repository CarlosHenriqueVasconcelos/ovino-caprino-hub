import 'package:drift/drift.dart' show Variable;

import '../models/animal.dart';
import 'drift/app_database.dart';

class DeceasedRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  DeceasedRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  Future<List<Animal>> fetchAll() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? (await _db.customSelect(
            'SELECT * FROM deceased_animals WHERE farm_id = ? ORDER BY death_date DESC',
            variables: [Variable<Object>(farmId)],
          ).get())
            .map((r) => r.data)
            .toList()
        : (await _db.customSelect(
            'SELECT * FROM deceased_animals ORDER BY death_date DESC',
          ).get())
            .map((r) => r.data)
            .toList();
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
