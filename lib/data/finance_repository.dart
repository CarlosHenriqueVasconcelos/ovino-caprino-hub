import 'package:drift/drift.dart' show Variable;

import '../models/financial_account.dart';
import 'drift/app_database.dart';

class FinanceRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  FinanceRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  String _dateStr(DateTime d) => d.toIso8601String().split('T').first;

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<List<Map<String, dynamic>>> _select(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _db.customSelect(sql, variables: _vars(args)).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }

  Future<Map<String, dynamic>> _single(String sql, List<Object?> args) async {
    final rows = await _select(sql, args);
    return rows.isEmpty ? <String, dynamic>{} : rows.first;
  }

  Future<void> _insert(String table, Map<String, dynamic> row) async {
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    await _db.customStatement(
      'INSERT INTO $table (${cols.join(',')}) VALUES ($placeholders)',
      cols.map((c) => row[c]).toList(),
    );
  }

  Future<void> _updateById({
    required String table,
    required String id,
    required String? farmId,
    required Map<String, dynamic> data,
  }) async {
    if (data.isEmpty) return;
    final keys = data.keys.toList(growable: false);
    final setClause = keys.map((k) => '$k = ?').join(', ');
    if (farmId != null) {
      await _db.customStatement(
        'UPDATE $table SET $setClause WHERE farm_id = ? AND id = ?',
        [...keys.map((k) => data[k]), farmId, id],
      );
    } else {
      await _db.customStatement(
        'UPDATE $table SET $setClause WHERE id = ?',
        [...keys.map((k) => data[k]), id],
      );
    }
  }

  String _page({required int? limit, required int? offset, required List<Object?> args}) {
    final buf = StringBuffer();
    if (limit != null) { buf.write(' LIMIT ?'); args.add(limit); }
    else if (offset != null) { buf.write(' LIMIT -1'); }
    if (offset != null) { buf.write(' OFFSET ?'); args.add(offset); }
    return buf.toString();
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // ==================== FINANCIAL RECORDS ====================

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            'SELECT * FROM financial_records WHERE farm_id = ? ORDER BY date DESC',
            [farmId],
          )
        : _select('SELECT * FROM financial_records ORDER BY date DESC', []);
  }

  Future<List<Map<String, dynamic>>> getRecordsByType(String type) async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            'SELECT * FROM financial_records WHERE farm_id = ? AND type = ? ORDER BY date DESC',
            [farmId, type],
          )
        : _select(
            'SELECT * FROM financial_records WHERE type = ? ORDER BY date DESC',
            [type],
          );
  }

  Future<void> insertRecord(Map<String, dynamic> record) async {
    final farmId = _farmId;
    final row = Map<String, dynamic>.from(record);
    if (farmId != null) row['farm_id'] = farmId;
    await _insert('financial_records', row);
  }

  Future<void> updateRecord(String id, Map<String, dynamic> updates) async {
    if (updates.isEmpty) return;
    await _updateById(
      table: 'financial_records',
      id: id,
      farmId: _farmId,
      data: Map<String, dynamic>.from(updates),
    );
  }

  Future<void> deleteRecord(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM financial_records WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement(
        'DELETE FROM financial_records WHERE id = ?',
        [id],
      );
    }
  }

  // ==================== FINANCIAL ACCOUNTS ====================

  Future<List<FinancialAccount>> getAllAccounts() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM financial_accounts WHERE farm_id = ? ORDER BY due_date DESC',
            [farmId],
          )
        : await _select(
            'SELECT * FROM financial_accounts ORDER BY due_date DESC',
            [],
          );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<List<FinancialAccount>> getAccountsPaged({
    String? type,
    String? status,
    int? limit,
    int? offset,
    bool ascending = true,
  }) async {
    final farmId = _farmId;
    final where = <String>[];
    final args = <Object?>[];
    if (farmId != null) { where.add('farm_id = ?'); args.add(farmId); }
    if (type != null && type.isNotEmpty) { where.add('type = ?'); args.add(type); }
    if (status != null && status.isNotEmpty && status != 'Todos') {
      where.add('status = ?');
      args.add(status);
    }
    final page = _page(limit: limit, offset: offset, args: args);
    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')} ';
    final rows = await _select(
      'SELECT * FROM financial_accounts ${whereClause}ORDER BY due_date ${ascending ? 'ASC' : 'DESC'}$page',
      args,
    );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<List<FinancialAccount>> getAccountsPayable() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            "SELECT * FROM financial_accounts WHERE farm_id = ? AND type = 'despesa' ORDER BY due_date ASC",
            [farmId],
          )
        : await _select(
            "SELECT * FROM financial_accounts WHERE type = 'despesa' ORDER BY due_date ASC",
            [],
          );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<List<FinancialAccount>> getAccountsReceivable() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            "SELECT * FROM financial_accounts WHERE farm_id = ? AND type = 'receita' ORDER BY due_date ASC",
            [farmId],
          )
        : await _select(
            "SELECT * FROM financial_accounts WHERE type = 'receita' ORDER BY due_date ASC",
            [],
          );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<List<FinancialAccount>> getAccountsByStatus(String status) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM financial_accounts WHERE farm_id = ? AND status = ? ORDER BY due_date ASC',
            [farmId, status],
          )
        : await _select(
            'SELECT * FROM financial_accounts WHERE status = ? ORDER BY due_date ASC',
            [status],
          );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<void> insertAccount(FinancialAccount account) async {
    final farmId = _farmId;
    final row = account.toMap();
    if (farmId != null) row['farm_id'] = farmId;
    await _insert('financial_accounts', row);
  }

  Future<void> updateAccount(FinancialAccount account) async {
    await _updateById(
      table: 'financial_accounts',
      id: account.id,
      farmId: _farmId,
      data: account.toMap()..remove('id'),
    );
  }

  Future<void> deleteAccount(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM financial_accounts WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement(
        'DELETE FROM financial_accounts WHERE id = ?',
        [id],
      );
    }
  }

  Future<FinancialAccount?> getAccountById(String id) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM financial_accounts WHERE farm_id = ? AND id = ? LIMIT 1',
            [farmId, id],
          )
        : await _select(
            'SELECT * FROM financial_accounts WHERE id = ? LIMIT 1',
            [id],
          );
    return rows.isEmpty ? null : FinancialAccount.fromMap(rows.first);
  }

  // ==================== AGREGAÇÕES ====================

  Future<double> getTotalRevenue() async {
    final farmId = _farmId;
    final row = farmId != null
        ? await _single(
            "SELECT COALESCE(SUM(amount), 0) AS total FROM financial_records WHERE farm_id = ? AND type = 'receita'",
            [farmId],
          )
        : await _single(
            "SELECT COALESCE(SUM(amount), 0) AS total FROM financial_records WHERE type = 'receita'",
            [],
          );
    return _toDouble(row['total']);
  }

  Future<double> getTotalExpenses() async {
    final farmId = _farmId;
    final row = farmId != null
        ? await _single(
            "SELECT COALESCE(SUM(amount), 0) AS total FROM financial_records WHERE farm_id = ? AND type = 'despesa'",
            [farmId],
          )
        : await _single(
            "SELECT COALESCE(SUM(amount), 0) AS total FROM financial_records WHERE type = 'despesa'",
            [],
          );
    return _toDouble(row['total']);
  }

  Future<double> getBalance() async {
    final revenue = await getTotalRevenue();
    final expenses = await getTotalExpenses();
    return revenue - expenses;
  }

  Future<List<FinancialAccount>> getOverdueAccounts() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            "SELECT * FROM financial_accounts WHERE farm_id = ? AND status = 'Pendente' AND due_date < date('now') ORDER BY due_date ASC",
            [farmId],
          )
        : await _select(
            "SELECT * FROM financial_accounts WHERE status = 'Pendente' AND due_date < date('now') ORDER BY due_date ASC",
            [],
          );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<void> updateOverdueStatus(DateTime today) async {
    final todayStr = _dateStr(today);
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        "UPDATE financial_accounts SET status = 'Vencido' WHERE farm_id = ? AND status = 'Pendente' AND due_date < ?",
        [farmId, todayStr],
      );
      await _db.customStatement(
        "UPDATE financial_accounts SET status = 'Pendente' WHERE farm_id = ? AND status = 'Vencido' AND due_date >= ?",
        [farmId, todayStr],
      );
    } else {
      await _db.customStatement(
        "UPDATE financial_accounts SET status = 'Vencido' WHERE status = 'Pendente' AND due_date < ?",
        [todayStr],
      );
      await _db.customStatement(
        "UPDATE financial_accounts SET status = 'Pendente' WHERE status = 'Vencido' AND due_date >= ?",
        [todayStr],
      );
    }
  }

  Future<Map<String, dynamic>> getDashboardStats(DateTime today) async {
    final farmId = _farmId;
    final firstDay = DateTime(today.year, today.month, 1);
    final lastDay = DateTime(today.year, today.month + 1, 0);
    final todayStr = _dateStr(today);
    final next7Str = _dateStr(today.add(const Duration(days: 7)));
    final firstMonthStr = _dateStr(firstDay);
    final lastMonthStr = _dateStr(lastDay);

    Future<double> sum(String sql, List<Object?> args) async =>
        _toDouble((await _single(sql, args))['total']);
    Future<int> count(String sql, List<Object?> args) async =>
        _toInt((await _single(sql, args))['c']);

    final fp = farmId != null ? 'farm_id = ? AND ' : '';
    final fa = farmId != null ? [farmId] : <Object?>[];

    final totalPending = await sum(
      "SELECT SUM(amount) AS total FROM financial_accounts WHERE ${fp}status = 'Pendente' AND type = 'receita'",
      fa,
    );
    final totalUpcoming = await sum(
      "SELECT SUM(amount) AS total FROM financial_accounts WHERE ${fp}status = 'Pendente' AND due_date >= ? AND due_date <= ?",
      [...fa, todayStr, next7Str],
    );
    final countUpcoming = await count(
      "SELECT COUNT(*) AS c FROM financial_accounts WHERE ${fp}status = 'Pendente' AND due_date >= ? AND due_date <= ?",
      [...fa, todayStr, next7Str],
    );
    final totalOverdue = await sum(
      "SELECT SUM(amount) AS total FROM financial_accounts WHERE ${fp}status = 'Vencido'",
      fa,
    );
    final countOverdue = await count(
      "SELECT COUNT(*) AS c FROM financial_accounts WHERE ${fp}status = 'Vencido'",
      fa,
    );
    final totalRevenue = await sum(
      "SELECT SUM(amount) AS total FROM financial_accounts WHERE ${fp}status = 'Pago' AND type = 'receita' AND payment_date >= ? AND payment_date <= ?",
      [...fa, firstMonthStr, lastMonthStr],
    );
    final totalExpense = await sum(
      "SELECT SUM(amount) AS total FROM financial_accounts WHERE ${fp}status = 'Pago' AND type = 'despesa' AND payment_date >= ? AND payment_date <= ?",
      [...fa, firstMonthStr, lastMonthStr],
    );
    final balance = totalRevenue - totalExpense;

    return {
      'totalPending': totalPending,
      'totalUpcoming': totalUpcoming,
      'countUpcoming': countUpcoming,
      'totalOverdue': totalOverdue,
      'countOverdue': countOverdue,
      'totalPaidMonth': balance,
      'balance': balance,
      'totalRevenue': totalRevenue,
      'totalExpense': totalExpense,
    };
  }

  Future<List<FinancialAccount>> getUpcomingAccounts(int days) async {
    final today = DateTime.now();
    final limit = today.add(Duration(days: days));
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            "SELECT * FROM financial_accounts WHERE farm_id = ? AND status = 'Pendente' AND due_date >= ? AND due_date <= ? ORDER BY due_date ASC",
            [farmId, _dateStr(today), _dateStr(limit)],
          )
        : await _select(
            "SELECT * FROM financial_accounts WHERE status = 'Pendente' AND due_date >= ? AND due_date <= ? ORDER BY due_date ASC",
            [_dateStr(today), _dateStr(limit)],
          );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<List<FinancialAccount>> getRecurringCandidates(DateTime today) async {
    final farmId = _farmId;
    final todayStr = _dateStr(today);
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM financial_accounts WHERE farm_id = ? AND is_recurring = 1 AND parent_id IS NULL AND (recurrence_end_date IS NULL OR recurrence_end_date >= ?)',
            [farmId, todayStr],
          )
        : await _select(
            'SELECT * FROM financial_accounts WHERE is_recurring = 1 AND parent_id IS NULL AND (recurrence_end_date IS NULL OR recurrence_end_date >= ?)',
            [todayStr],
          );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<DateTime?> getLastChildDueDate(String parentId) async {
    final farmId = _farmId;
    final row = farmId != null
        ? await _single(
            'SELECT MAX(due_date) AS last FROM financial_accounts WHERE farm_id = ? AND parent_id = ?',
            [farmId, parentId],
          )
        : await _single(
            'SELECT MAX(due_date) AS last FROM financial_accounts WHERE parent_id = ?',
            [parentId],
          );
    final lastStr = row['last'] as String?;
    return lastStr != null ? DateTime.tryParse(lastStr) : null;
  }

  Future<bool> hasChildWithDueDate(String parentId, DateTime dueDate) async {
    final farmId = _farmId;
    final due = _dateStr(dueDate);
    final rows = farmId != null
        ? await _select(
            'SELECT id FROM financial_accounts WHERE farm_id = ? AND parent_id = ? AND due_date = ? LIMIT 1',
            [farmId, parentId, due],
          )
        : await _select(
            'SELECT id FROM financial_accounts WHERE parent_id = ? AND due_date = ? LIMIT 1',
            [parentId, due],
          );
    return rows.isNotEmpty;
  }

  Future<List<FinancialAccount>> getRecurringMothers() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM financial_accounts WHERE farm_id = ? AND is_recurring = 1 AND parent_id IS NULL ORDER BY due_date ASC',
            [farmId],
          )
        : await _select(
            'SELECT * FROM financial_accounts WHERE is_recurring = 1 AND parent_id IS NULL ORDER BY due_date ASC',
            [],
          );
    return rows.map(FinancialAccount.fromMap).toList();
  }

  Future<void> deleteRecurringCascade(String motherId) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM financial_accounts WHERE farm_id = ? AND parent_id = ?',
        [farmId, motherId],
      );
      await _db.customStatement(
        'DELETE FROM financial_accounts WHERE farm_id = ? AND id = ?',
        [farmId, motherId],
      );
    } else {
      await _db.customStatement(
        'DELETE FROM financial_accounts WHERE parent_id = ?',
        [motherId],
      );
      await _db.customStatement(
        'DELETE FROM financial_accounts WHERE id = ?',
        [motherId],
      );
    }
  }

  Future<double> sumByTypeBetween(
    String type,
    DateTime start,
    DateTime end,
  ) async {
    final farmId = _farmId;
    final row = farmId != null
        ? await _single(
            'SELECT SUM(amount) AS total FROM financial_accounts WHERE farm_id = ? AND type = ? AND due_date >= ? AND due_date < ?',
            [farmId, type, _dateStr(start), _dateStr(end)],
          )
        : await _single(
            'SELECT SUM(amount) AS total FROM financial_accounts WHERE type = ? AND due_date >= ? AND due_date < ?',
            [type, _dateStr(start), _dateStr(end)],
          );
    return _toDouble(row['total']);
  }
}
