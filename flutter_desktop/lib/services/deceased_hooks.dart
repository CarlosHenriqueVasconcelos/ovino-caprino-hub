// lib/services/deceased_hooks.dart
// Atualiza automaticamente o animal para "Óbito" e move para deceased_animals
// quando o status do animal for alterado para "Óbito"

import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;

import 'database_service.dart';
import 'data_refresh_bus.dart';

Future<void> handleAnimalDeathIfApplicable(String animalId, String newStatus) async {
  if (newStatus != 'Óbito') return;

  final db = await DatabaseService.database;

  await db.transaction((txn) async {
    // 1) Busca dados atuais do animal
    final animals = await txn.query(
      'animals',
      where: 'id = ?',
      whereArgs: [animalId],
      limit: 1,
    );
    if (animals.isEmpty) return; // nada a fazer

    final animalData = animals.first;
    final nowIso = DateTime.now().toIso8601String();
    final dateOnly = nowIso.split('T').first;

    // 2) Insere/atualiza em deceased_animals (REPLACE evita erro de duplicidade)
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
        'name_color': animalData['name_color'],
        'category': animalData['category'],
        'birth_weight': animalData['birth_weight'],
        'weight_30_days': animalData['weight_30_days'],
        'weight_60_days': animalData['weight_60_days'],
        'weight_90_days': animalData['weight_90_days'],
        'weight_120_days': animalData['weight_120_days'],
        'death_date': dateOnly,
        'cause_of_death': animalData['health_issue'],
        'death_notes': 'Animal registrado como óbito',
        'created_at': nowIso,
        'updated_at': nowIso,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 3) Remove da tabela principal
    await txn.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [animalId],
    );
  }); // <- commit

  // 4) Notifica a UI após a transação concluir
  DataRefreshBus.emit('deceased');
}
