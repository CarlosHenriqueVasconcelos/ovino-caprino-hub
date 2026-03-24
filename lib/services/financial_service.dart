// lib/services/financial_service.dart
import '../data/animal_lifecycle_repository.dart';
import '../data/finance_repository.dart';
import '../models/financial_account.dart';
import 'sale_hooks.dart';
import 'events/event_bus.dart';
import 'events/app_events.dart';

class FinancialService {
  final FinanceRepository _repository;
  final AnimalLifecycleRepository _lifecycleRepository;

  FinancialService(
    this._repository,
    this._lifecycleRepository,
  );

  String _dateStr(DateTime d) => d.toIso8601String().split('T')[0];

  // ========== CRUD ==========

  Future<void> createAccount(FinancialAccount account) async {
    await _repository.insertAccount(account);
    await handleAnimalSaleIfApplicable(_lifecycleRepository, account);
    
    EventBus().emit(FinancialAccountCreatedEvent(
      accountId: account.id,
      type: account.type,
      amount: account.amount,
    ));
  }

  Future<void> updateAccount(FinancialAccount account) async {
    await _repository.updateAccount(account);
    await handleAnimalSaleIfApplicable(_lifecycleRepository, account);
    
    EventBus().emit(FinancialAccountUpdatedEvent(
      accountId: account.id,
      status: account.status,
    ));
  }

  Future<void> deleteAccount(String id) async {
    await _repository.deleteAccount(id);
    
    EventBus().emit(FinancialAccountDeletedEvent(accountId: id));
  }

  Future<FinancialAccount> getById(String id) async {
    final result = await _repository.getAccountById(id);
    if (result == null) {
      throw Exception('FinancialAccount $id não encontrado');
    }
    return result;
  }

  Future<List<FinancialAccount>> getAllAccounts() {
    return _repository.getAllAccounts();
  }

  Future<List<FinancialAccount>> getAccountsPage({
    String? type,
    String? status,
    int? limit,
    int? offset,
    bool ascending = true,
  }) {
    return _repository.getAccountsPaged(
      type: type,
      status: status,
      limit: limit,
      offset: offset,
      ascending: ascending,
    );
  }

  Future<void> markAsPaid(String id, DateTime paymentDate) async {
    final acc = await getById(id);
    final updated = acc.copyWith(
      status: 'Pago',
      paymentDate: paymentDate,
      updatedAt: DateTime.now(),
    );
    await updateAccount(updated);
  }

  // ========== STATUS VENCIDO ==========

  Future<void> updateOverdueStatus() async {
    await _repository.updateOverdueStatus(DateTime.now());
  }

  // ========== DASHBOARD ==========

  Future<Map<String, dynamic>> getDashboardStats() async {
    await updateOverdueStatus();
    return _repository.getDashboardStats(DateTime.now());
  }

  Future<List<FinancialAccount>> getUpcomingAccounts(int days) async {
    return _repository.getUpcomingAccounts(days);
  }

  Future<List<FinancialAccount>> getOverdueAccounts() {
    return _repository.getOverdueAccounts();
  }

  // ========== RECORRENTES ==========

  Future<void> generateRecurringAccounts() async {
    final candidates = await _repository.getRecurringCandidates(DateTime.now());

    for (final mother in candidates) {
      final lastDue =
          await _repository.getLastChildDueDate(mother.id) ?? mother.dueDate;

      DateTime? nextDue;
      switch (mother.recurrenceFrequency) {
        case 'Mensal':
          nextDue = DateTime(lastDue.year, lastDue.month + 1, lastDue.day);
          break;
        case 'Semanal':
          nextDue = lastDue.add(const Duration(days: 7));
          break;
        case 'Anual':
          nextDue = DateTime(lastDue.year + 1, lastDue.month, lastDue.day);
          break;
        default:
          nextDue = null;
      }
      if (nextDue == null) continue;

      if (mother.recurrenceEndDate != null &&
          nextDue.isAfter(mother.recurrenceEndDate!)) {
        continue;
      }

      final exists = await _repository.hasChildWithDueDate(mother.id, nextDue);
      if (exists) continue;

      final child = FinancialAccount(
        id: '${mother.id}_${nextDue.millisecondsSinceEpoch}',
        type: mother.type,
        category: mother.category,
        description: mother.description,
        amount: mother.amount,
        dueDate: nextDue,
        paymentDate: null,
        status: 'Pendente',
        paymentMethod: mother.paymentMethod,
        installments: mother.installments,
        installmentNumber: mother.installmentNumber,
        parentId: mother.id,
        animalId: mother.animalId,
        supplierCustomer: mother.supplierCustomer,
        notes: mother.notes,
        isRecurring: false,
        recurrenceFrequency: null,
        recurrenceEndDate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createAccount(child);
    }
  }

  Future<List<FinancialAccount>> getRecurringMothers() async {
    return _repository.getRecurringMothers();
  }

  Future<void> deleteRecurringCascade(String motherId) async {
    await _repository.deleteRecurringCascade(motherId);
  }

  // ========== PROJEÇÃO FLUXO DE CAIXA ==========

  Future<List<Map<String, dynamic>>> getCashFlowProjection(
      int months) async {
    final today = DateTime.now();
    final List<Map<String, dynamic>> projection = [];

    for (int i = 0; i < months; i++) {
      final month = DateTime(today.year, today.month + i, 1);
      final nextMonth = DateTime(month.year, month.month + 1, 1);

      final revenue = await _repository.sumByTypeBetween(
        'receita',
        month,
        nextMonth,
      );
      final expense = await _repository.sumByTypeBetween(
        'despesa',
        month,
        nextMonth,
      );

      projection.add({
        'month': month,
        'revenue': revenue,
        'expense': expense,
        'balance': revenue - expense,
      });
    }

    return projection;
  }

  // ========== ADAPTADOR PARA TELA ==========

  Future<List<Map<String, dynamic>>> getFinancialRecords({
    int? limit,
    int? offset,
  }) async {
    final accounts = await getAccountsPage(
      limit: limit,
      offset: offset,
      ascending: false,
    );

    return accounts.map((acc) {
      final dueStr = _dateStr(acc.dueDate);
      return <String, dynamic>{
        'id': acc.id,
        'type': acc.type,
        'category': acc.category,
        'description': acc.description,
        'amount': acc.amount,
        'date': dueStr,
        'due_date': dueStr,
        'status': acc.status,
        'payment_date':
            acc.paymentDate != null ? _dateStr(acc.paymentDate!) : null,
      };
    }).toList();
  }
}
