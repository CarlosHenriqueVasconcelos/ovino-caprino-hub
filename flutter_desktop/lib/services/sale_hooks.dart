// lib/services/sale_hooks.dart
// Atualiza automaticamente o status do animal para "Vendido" ao lançar
// uma Receita com categoria "Venda de Animais" vinculada a um animal.
// Também grava metadados de saída (exit_date/exit_reason) SE as colunas existirem.

import 'dart:async';
import 'package:sqflite_common/sqlite_api.dart';

import '../models/financial_account.dart';
import 'database_service.dart';

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

  // Descobre colunas existentes (para exit_* ser 100% opcional)
  final info = await db.rawQuery('PRAGMA table_info(animals)');
  final cols = info.map((m) => (m['name'] ?? '').toString()).toSet();

  final nowIso = DateTime.now().toIso8601String();
  final updates = <String, Object?>{
    'status': 'Vendido',
    'updated_at': nowIso,
  };

  // exit_date: preferir paymentDate; se nulo, usar dueDate
  final exit = _tryParseDate(account.paymentDate) ?? _tryParseDate(account.dueDate);
  final exitIso = exit?.toIso8601String().split('T').first;

  if (cols.contains('exit_date') && exitIso != null) {
    updates['exit_date'] = exitIso; // YYYY-MM-DD
  }
  if (cols.contains('exit_reason')) {
    updates['exit_reason'] = 'Venda';
  }

  await db.update(
    'animals',
    updates,
    where: 'id = ?',
    whereArgs: [animalId],
  );
}
