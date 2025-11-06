// lib/services/deceased_service.dart
import 'package:flutter/foundation.dart';

import '../data/local_db.dart';
import '../models/animal.dart';
import 'deceased_hooks.dart';

class DeceasedService extends ChangeNotifier {
  final AppDatabase _appDb;
  DeceasedService(this._appDb);

  /// Retorna a lista de animais falecidos adaptada para o modelo [Animal],
  /// para reaproveitar os mesmos widgets de exibição (cards/listas).
  Future<List<Animal>> getDeceasedAnimals() async {
    final rows = await _appDb.db.query(
      'deceased_animals',
      orderBy: 'date(death_date) DESC',
    );

    return rows.map((m) {
      final map = Map<String, dynamic>.from(m);

      // Adaptar pro shape exibível do modelo Animal
      map['status'] = 'Óbito';
      map['last_vaccination'] = null;
      map['expected_delivery'] = null;
      map['health_issue'] = map['cause_of_death'];

      map['created_at'] ??= DateTime.now().toIso8601String();
      map['updated_at'] ??= DateTime.now().toIso8601String();

      return Animal.fromMap(map);
    }).toList();
  }

  /// Lida com o fluxo de óbito de um animal:
  /// - move para a tabela deceased_animals
  /// - remove da tabela principal
  /// - executa hooks relacionados (se houver)
  Future<void> handleDeath(Animal animal) async {
    // Garante um status válido (no fluxo normal será sempre 'Óbito')
    final status = animal.status ?? 'Óbito';

    await handleAnimalDeathIfApplicable(
      _appDb,
      animal.id,
      status,
    );
  }
}
