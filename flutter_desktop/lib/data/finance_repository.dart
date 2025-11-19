import 'package:sqflite_common/sqlite_api.dart' show Database;

import '../models/financial_account.dart';
import 'local_db.dart';

/// Repository para gerenciar registros financeiros e contas a pagar/receber
class FinanceRepository {
  final AppDatabase _db;

  FinanceRepository(this._db);

  Database get database => _db.db;

  String _dateStr(DateTime d) => d.toIso8601String().split('T').first;

  // ==================== FINANCIAL RECORDS ====================

  /// Retorna todos os registros financeiros
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    return await _db.db.query(
      'financial_records',
      orderBy: 'date DESC',
    );
  }

  /// Retorna registros financeiros por tipo (Receita/Despesa)
  Future<List<Map<String, dynamic>>> getRecordsByType(String type) async {
    return await _db.db.query(
      'financial_records',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
  }

  /// Insere um novo registro financeiro
  Future<void> insertRecord(Map<String, dynamic> record) async {
    await _db.db.insert('financial_records', record);
  }

  /// Atualiza um registro financeiro
  Future<void> updateRecord(String id, Map<String, dynamic> updates) async {
    await _db.db.update(
      'financial_records',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deleta um registro financeiro
  Future<void> deleteRecord(String id) async {
    await _db.db.delete(
      'financial_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== FINANCIAL ACCOUNTS ====================

  /// Retorna todas as contas financeiras
  Future<List<FinancialAccount>> getAllAccounts() async {
    final maps = await _db.db.query(
      'financial_accounts',
      orderBy: 'due_date DESC',
    );
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  /// Retorna contas a pagar
  Future<List<FinancialAccount>> getAccountsPayable() async {
    final maps = await _db.db.query(
      'financial_accounts',
      where: 'type = ?',
      whereArgs: ['despesa'],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  /// Retorna contas a receber
  Future<List<FinancialAccount>> getAccountsReceivable() async {
    final maps = await _db.db.query(
      'financial_accounts',
      where: 'type = ?',
      whereArgs: ['receita'],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  /// Retorna contas por status
  Future<List<FinancialAccount>> getAccountsByStatus(String status) async {
    final maps = await _db.db.query(
      'financial_accounts',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  /// Insere uma nova conta
  Future<void> insertAccount(FinancialAccount account) async {
    await _db.db.insert('financial_accounts', account.toMap());
  }

  /// Atualiza uma conta
  Future<void> updateAccount(FinancialAccount account) async {
    await _db.db.update(
      'financial_accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// Deleta uma conta
  Future<void> deleteAccount(String id) async {
    await _db.db.delete(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<FinancialAccount?> getAccountById(String id) async {
    final rows = await _db.db.query(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return FinancialAccount.fromMap(rows.first);
  }

  // ==================== AGREGAÇÕES ====================

  /// Calcula total de receitas
  Future<double> getTotalRevenue() async {
    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM financial_records
      WHERE type = 'receita'
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calcula total de despesas
  Future<double> getTotalExpenses() async {
    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM financial_records
      WHERE type = 'despesa'
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calcula saldo (receitas - despesas)
  Future<double> getBalance() async {
    final revenue = await getTotalRevenue();
    final expenses = await getTotalExpenses();
    return revenue - expenses;
  }

  /// Retorna contas vencidas (pendentes com data de vencimento passada)
  Future<List<FinancialAccount>> getOverdueAccounts() async {
    final maps = await _db.db.rawQuery('''
      SELECT * FROM financial_accounts
      WHERE status = 'Pendente'
      AND date(due_date) < date('now')
      ORDER BY due_date ASC
    ''');
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  Future<void> updateOverdueStatus(DateTime today) async {
    final todayStr = _dateStr(today);
    await _db.db.rawUpdate(
      "UPDATE financial_accounts SET status = 'Vencido' "
      "WHERE status = 'Pendente' AND date(due_date) < date(?)",
      [todayStr],
    );
    await _db.db.rawUpdate(
      "UPDATE financial_accounts SET status = 'Pendente' "
      "WHERE status = 'Vencido' AND date(due_date) >= date(?)",
      [todayStr],
    );
  }

  Future<Map<String, dynamic>> getDashboardStats(DateTime today) async {
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final lastDayOfMonth = DateTime(today.year, today.month + 1, 0);
    final todayStr = _dateStr(today);
    final next7Str = _dateStr(today.add(const Duration(days: 7)));
    final firstMonthStr = _dateStr(firstDayOfMonth);
    final lastMonthStr = _dateStr(lastDayOfMonth);

    Future<double> sumQuery(String sql, [List<Object?>? args]) async {
      final res = await _db.db.rawQuery(sql, args);
      return (res.first['total'] as num?)?.toDouble() ?? 0.0;
    }

    double totalPending = await sumQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pendente' AND type = 'receita'",
    );

    double totalUpcoming = await sumQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pendente' AND date(due_date) >= date(?) AND date(due_date) <= date(?)",
      [todayStr, next7Str],
    );

    final countUpcomingRes = await _db.db.rawQuery(
      "SELECT COUNT(*) as c FROM financial_accounts "
      "WHERE status = 'Pendente' AND date(due_date) >= date(?) AND date(due_date) <= date(?)",
      [todayStr, next7Str],
    );
    final countUpcoming = (countUpcomingRes.first['c'] as num?)?.toInt() ?? 0;

    final totalOverdue = await sumQuery(
      "SELECT SUM(amount) as total FROM financial_accounts WHERE status = 'Vencido'",
    );

    final countOverdueRes = await _db.db.rawQuery(
      "SELECT COUNT(*) as c FROM financial_accounts WHERE status = 'Vencido'",
    );
    final countOverdue = (countOverdueRes.first['c'] as num?)?.toInt() ?? 0;

    final totalRevenue = await sumQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pago' AND type = 'receita' "
      "AND date(payment_date) >= date(?) AND date(payment_date) <= date(?)",
      [firstMonthStr, lastMonthStr],
    );

    final totalExpense = await sumQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pago' AND type = 'despesa' "
      "AND date(payment_date) >= date(?) AND date(payment_date) <= date(?)",
      [firstMonthStr, lastMonthStr],
    );

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

  Future<List<FinancialAccount>> getUpcomingAccounts(int days) async {
    final today = DateTime.now();
    final limit = today.add(Duration(days: days));

    final res = await _db.db.query(
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

  Future<List<FinancialAccount>> getRecurringCandidates(DateTime today) async {
    final res = await _db.db.query(
      'financial_accounts',
      where:
          'is_recurring = ? AND parent_id IS NULL AND (recurrence_end_date IS NULL OR date(recurrence_end_date) >= date(?))',
      whereArgs: [1, _dateStr(today)],
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  Future<DateTime?> getLastChildDueDate(String parentId) async {
    final lastRow = await _db.db.rawQuery(
      'SELECT MAX(date(due_date)) AS last FROM financial_accounts WHERE parent_id = ?',
      [parentId],
    );
    final String? lastStr = lastRow.first['last'] as String?;
    return lastStr != null ? DateTime.tryParse(lastStr) : null;
  }

  Future<bool> hasChildWithDueDate(String parentId, DateTime dueDate) async {
    final existing = await _db.db.query(
      'financial_accounts',
      where: 'parent_id = ? AND date(due_date) = date(?)',
      whereArgs: [parentId, _dateStr(dueDate)],
      limit: 1,
    );
    return existing.isNotEmpty;
  }

  Future<List<FinancialAccount>> getRecurringMothers() async {
    final res = await _db.db.query(
      'financial_accounts',
      where: 'is_recurring = 1 AND parent_id IS NULL',
      orderBy: 'date(due_date) ASC',
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  Future<void> deleteRecurringCascade(String motherId) async {
    await _db.db.delete(
      'financial_accounts',
      where: 'parent_id = ?',
      whereArgs: [motherId],
    );
    await _db.db.delete(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [motherId],
    );
  }

  Future<double> sumByTypeBetween(
    String type,
    DateTime start,
    DateTime end,
  ) async {
    final res = await _db.db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_accounts '
      'WHERE type = ? AND date(due_date) >= date(?) AND date(due_date) < date(?)',
      [type, _dateStr(start), _dateStr(end)],
    );
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
