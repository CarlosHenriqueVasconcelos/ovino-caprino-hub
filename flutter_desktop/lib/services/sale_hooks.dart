// lib/services/sale_hooks.dart
// Move automaticamente o animal para a tabela sold_animals ao lançar
// uma Receita com categoria "Venda de Animais" vinculada a um animal.

import 'dart:async';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

import '../models/financial_account.dart';
import 'database_service.dart';

const _uuid = Uuid();

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

Future<void> handleAnimalSaleIfApplicable(FinancialAccount account) async {
  if (account.type != 'receita') return;
  if (account.category != 'Venda de Animais') return;

  final animalId = account.animalId;
  if (animalId == null || animalId.isEmpty) return;

  final db = await DatabaseService.database;

  // Busca os dados do animal
  final animals = await db.query('animals', where: 'id = ?', whereArgs: [animalId]);
  if (animals.isEmpty) return;

  final animalData = animals.first;
  final nowIso = DateTime.now().toIso8601String();

  // exit_date: preferir paymentDate; se nulo, usar dueDate
  final saleDate = _tryParseDate(account.paymentDate) ?? _tryParseDate(account.dueDate);
  final saleDateIso = saleDate?.toIso8601String().split('T').first ?? nowIso.split('T').first;

  // Executa em transação para evitar quebra de FKs
  await db.transaction((txn) async {
    // Insere na tabela de vendidos (com novo ID único)
    await txn.insert('sold_animals', {
      'id': _uuid.v4(),
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
      'sale_date': saleDateIso,
      'sale_price': account.amount,
      'buyer': account.supplierCustomer,
      'sale_notes': account.notes ?? account.description,
      'created_at': nowIso,
      'updated_at': nowIso,
    });

    // 1) Zera referências que não podem ser nulas via DELETE/UPDATE
    await txn.update('financial_records', {'animal_id': null}, where: 'animal_id = ?', whereArgs: [animalId]);
    await txn.update('financial_accounts', {'animal_id': null}, where: 'animal_id = ?', whereArgs: [animalId]);
    await txn.update('notes', {'animal_id': null}, where: 'animal_id = ?', whereArgs: [animalId]);

    // 2) Remove registros dependentes obrigatórios
    await txn.delete('animal_weights', where: 'animal_id = ?', whereArgs: [animalId]);
    await txn.delete('vaccinations', where: 'animal_id = ?', whereArgs: [animalId]);
    await txn.delete('medications', where: 'animal_id = ?', whereArgs: [animalId]);

    // 3) Desvincula reprodução (preserva histórico)
    await txn.update('breeding_records', {'female_animal_id': null}, where: 'female_animal_id = ?', whereArgs: [animalId]);
    await txn.update('breeding_records', {'male_animal_id': null}, where: 'male_animal_id = ?', whereArgs: [animalId]);

    // 4) Por fim, remove o animal principal
    await txn.delete('animals', where: 'id = ?', whereArgs: [animalId]);
  });
}
