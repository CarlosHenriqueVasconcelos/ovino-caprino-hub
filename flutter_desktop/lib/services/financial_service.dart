// lib/services/financial_service.dart
import 'package:sqflite_common/sqlite_api.dart' show Database;

import '../data/finance_repository.dart';
import '../models/financial_account.dart';
import 'sale_hooks.dart';

class FinancialService {
  FinancialService(FinanceRepository repository) {
    _repository = repository;
  }

  static late FinanceRepository _repository;

  static Database get _db => _repository.database;

  static String _dateStr(DateTime d) => d.toIso8601String().split('T')[0];

  // ========== CRUD ==========

  static Future<void> createAccount(FinancialAccount account) async {
    await _repository.insertAccount(account);
    await handleAnimalSaleIfApplicable(account);
  }

  static Future<void> updateAccount(FinancialAccount account) async {
    await _repository.updateAccount(account);
  }

  static Future<void> deleteAccount(String id) async {
    await _repository.deleteAccount(id);
  }

  static Future<FinancialAccount> getById(String id) async {
    final res = await _db.query(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isEmpty) {
      throw Exception('FinancialAccount $id não encontrado');
    }
    return FinancialAccount.fromMap(res.first);
  }

  static Future<List<FinancialAccount>> getAllAccounts() {
    return _repository.getAllAccounts();
  }

  static Future<void> markAsPaid(String id, DateTime paymentDate) async {
    final acc = await getById(id);
    final updated = acc.copyWith(
      status: 'Pago',
      paymentDate: paymentDate,
      updatedAt: DateTime.now(),
    );
    await updateAccount(updated);
  }

  // ========== STATUS VENCIDO ==========

  static Future<void> updateOverdueStatus() async {
    final today = _dateStr(DateTime.now());

    await _db.rawUpdate(
      "UPDATE financial_accounts SET status = 'Vencido' "
      "WHERE status = 'Pendente' AND date(due_date) < date(?)",
      [today],
    );

    await _db.rawUpdate(
      "UPDATE financial_accounts SET status = 'Pendente' "
      "WHERE status = 'Vencido' AND date(due_date) >= date(?)",
      [today],
    );
  }

  // ========== DASHBOARD ==========

  static Future<Map<String, dynamic>> getDashboardStats() async {
    await updateOverdueStatus();
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final lastDayOfMonth = DateTime(today.year, today.month + 1, 0);

    final pendingResult = await _db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_accounts '
      "WHERE status = 'Pendente' AND type = 'receita'",
    );
    final totalPending =
        (pendingResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final next7 = today.add(const Duration(days: 7));
    final todayStr = _dateStr(today);
    final next7Str = _dateStr(next7);

    final upcomingResult = await _db.rawQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pendente' AND date(due_date) >= date(?) AND date(due_date) <= date(?)",
      [todayStr, next7Str],
    );
    final totalUpcoming =
        (upcomingResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final countUpcomingRes = await _db.rawQuery(
      "SELECT COUNT(*) as c FROM financial_accounts "
      "WHERE status = 'Pendente' AND date(due_date) >= date(?) AND date(due_date) <= date(?)",
      [todayStr, next7Str],
    );
    final countUpcoming = (countUpcomingRes.first['c'] as num?)?.toInt() ?? 0;

    final overdueResult = await _db.rawQuery(
      "SELECT SUM(amount) as total FROM financial_accounts WHERE status = 'Vencido'",
    );
    final totalOverdue =
        (overdueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final countOverdueRes = await _db.rawQuery(
      "SELECT COUNT(*) as c FROM financial_accounts WHERE status = 'Vencido'",
    );
    final countOverdue = (countOverdueRes.first['c'] as num?)?.toInt() ?? 0;

    final firstMonthStr = _dateStr(firstDayOfMonth);
    final lastMonthStr = _dateStr(lastDayOfMonth);

    final revenueResult = await _db.rawQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pago' AND type = 'receita' "
      "AND date(payment_date) >= date(?) AND date(payment_date) <= date(?)",
      [firstMonthStr, lastMonthStr],
    );
    final totalRevenue =
        (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final expenseResult = await _db.rawQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pago' AND type = 'despesa' "
      "AND date(payment_date) >= date(?) AND date(payment_date) <= date(?)",
      [firstMonthStr, lastMonthStr],
    );
    final totalExpense =
        (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final balance = totalRevenue - totalExpense;

    return {
      'totalPending': totalPending,
      'totalUpcoming': totalUpcoming,
      'countUpcoming': countUpcoming,
      'totalOverdue': totalOverdue,
      'countOverdue': countOverdue,
      'totalPaidMonth': totalRevenue - totalExpense,
      'balance': balance,
      'totalRevenue': totalRevenue,
      'totalExpense': totalExpense,
    };
  }

  static Future<List<FinancialAccount>> getUpcomingAccounts(int days) async {
    final today = DateTime.now();
    final limit = today.add(Duration(days: days));

    final res = await _db.query(
      'financial_accounts',
      where:
          "status = 'Pendente' AND date(due_date) >= date(?) AND date(due_date) <= date(?)",
      whereArgs: [
        _dateStr(today),
        _dateStr(limit),
      ],
      orderBy: 'date(due_date) ASC',
    );

    return res.map(FinancialAccount.fromMap).toList();
  }

  static Future<List<FinancialAccount>> getOverdueAccounts() {
    return _repository.getOverdueAccounts();
  }

  // ========== RECORRENTES ==========

  static Future<void> generateRecurringAccounts() async {
    final todayStr = _dateStr(DateTime.now());

    final List<Map<String, dynamic>> maps = await _db.query(
      'financial_accounts',
      where:
          'is_recurring = ? AND parent_id IS NULL AND (recurrence_end_date IS NULL OR date(recurrence_end_date) >= date(?))',
      whereArgs: [1, todayStr],
    );

    for (final map in maps) {
      final mother = FinancialAccount.fromMap(map);

      final lastRow = await _db.rawQuery(
        'SELECT MAX(date(due_date)) AS last FROM financial_accounts WHERE parent_id = ?',
        [mother.id],
      );
      final String? lastStr = lastRow.first['last'] as String?;
      final DateTime lastDue =
          lastStr != null ? DateTime.parse(lastStr) : mother.dueDate;

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

      final existing = await _db.query(
        'financial_accounts',
        where: 'parent_id = ? AND date(due_date) = date(?)',
        whereArgs: [mother.id, _dateStr(nextDue)],
      );
      if (existing.isNotEmpty) continue;

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

  static Future<List<FinancialAccount>> getRecurringMothers() async {
    final res = await _db.query(
      'financial_accounts',
      where: 'is_recurring = 1 AND parent_id IS NULL',
      orderBy: 'date(due_date) ASC',
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  static Future<void> deleteRecurringCascade(String motherId) async {
    await _db.delete(
      'financial_accounts',
      where: 'parent_id = ?',
      whereArgs: [motherId],
    );
    await _db.delete(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [motherId],
    );
  }

  // ========== PROJEÇÃO FLUXO DE CAIXA ==========

  static Future<List<Map<String, dynamic>>> getCashFlowProjection(
      int months) async {
    final today = DateTime.now();
    final List<Map<String, dynamic>> projection = [];

    for (int i = 0; i < months; i++) {
      final month = DateTime(today.year, today.month + i, 1);
      final nextMonth = DateTime(month.year, month.month + 1, 1);

      final revenueResult = await _db.rawQuery(
        'SELECT SUM(amount) as total FROM financial_accounts '
        'WHERE type = ? AND date(due_date) >= date(?) AND date(due_date) < date(?)',
        [
          'receita',
          _dateStr(month),
          _dateStr(nextMonth),
        ],
      );
      final revenue = (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

      final expenseResult = await _db.rawQuery(
        'SELECT SUM(amount) as total FROM financial_accounts '
        'WHERE type = ? AND date(due_date) >= date(?) AND date(due_date) < date(?)',
        [
          'despesa',
          _dateStr(month),
          _dateStr(nextMonth),
        ],
      );
      final expense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

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

  Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final accounts = await FinancialService.getAllAccounts();

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
