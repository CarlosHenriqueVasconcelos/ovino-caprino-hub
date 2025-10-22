// lib/services/deceased_hooks.dart
// Atualiza automaticamente o animal para "Óbito" e move para deceased_animals
// quando o status do animal for alterado para "Óbito"

import 'dart:async';
import 'package:sqflite_common/sqlite_api.dart';

import 'database_service.dart';

Future<void> handleAnimalDeathIfApplicable(String animalId, String newStatus) async {
  if (newStatus != 'Óbito') return;

  final db = await DatabaseService.database;

  // Busca os dados do animal
  final animals = await db.query('animals', where: 'id = ?', whereArgs: [animalId]);
  if (animals.isEmpty) return;

  final animalData = animals.first;
  final nowIso = DateTime.now().toIso8601String();
  final dateOnly = nowIso.split('T').first;

  // Insere na tabela de falecidos
  await db.insert('deceased_animals', {
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
    'death_date': dateOnly,
    'cause_of_death': animalData['health_issue'],
    'death_notes': 'Animal registrado como óbito',
    'created_at': nowIso,
    'updated_at': nowIso,
  });

  // Remove da tabela principal
  await db.delete('animals', where: 'id = ?', whereArgs: [animalId]);
}
