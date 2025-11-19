// lib/services/sale_hooks.dart
// Move automaticamente o animal para a tabela sold_animals ao lançar
// uma Receita com categoria "Venda de Animais" vinculada a um animal.

import '../data/animal_lifecycle_repository.dart';
import '../models/financial_account.dart';
import 'data_refresh_bus.dart';

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

Future<void> handleAnimalSaleIfApplicable(
  AnimalLifecycleRepository repository,
  FinancialAccount account,
) async {
  // Só interessa para receitas de "Venda de Animais"
  if (account.type != 'receita') return;
  if (account.category != 'Venda de Animais') return;

  final animalId = account.animalId;
  if (animalId == null || animalId.isEmpty) return;

  // sale_date: preferir paymentDate; se nulo, usar dueDate; senão hoje (YYYY-MM-DD)
  final saleDate =
      _tryParseDate(account.paymentDate) ?? _tryParseDate(account.dueDate);
  final saleDateValue = saleDate ?? DateTime.now();

  await repository.moveToSold(
    animalId: animalId,
    saleDate: saleDateValue,
    salePrice: account.amount,
    buyer: account.supplierCustomer,
    notes: account.notes ?? account.description,
  );

  // Notifica a UI
  DataRefreshBus.emit('sold');
}
