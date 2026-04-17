import 'package:drift/drift.dart' show Variable;
import 'package:sqflite_common/sqlite_api.dart' show Database;

import '../models/financial_account.dart';
import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

/// Repository para gerenciar registros financeiros e contas a pagar/receber
class FinanceRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  FinanceRepository(
    AppDatabase db, {
    AppDriftDatabase? driftDb,
    String? Function()? farmIdProvider,
  })  : _db = db,
        _driftDb = driftDb,
        _farmIdProvider = farmIdProvider,
        _legacyBridge = driftDb == null
            ? null
            : LegacySqfliteToDriftBridge(
                legacyDb: db,
                driftDb: driftDb,
              );

  Database get database => _db.db;

  String? get _currentFarmId => _farmIdProvider?.call();

  String _dateStr(DateTime d) => d.toIso8601String().split('T').first;

  List<Variable<Object>> _asVariables(List<Object?> args) {
    return args
        .map((arg) => Variable<Object>(arg as Object))
        .toList(growable: false);
  }

  Future<String?> _prepareFarmContext() async {
    final farmId = _currentFarmId;
    if (farmId == null || _driftDb == null) return null;
    await _legacyBridge?.migrateForFarm(farmId);
    return farmId;
  }

  String _buildPaginationClause({
    required int? limit,
    required int? offset,
    required List<Object?> args,
  }) {
    final buffer = StringBuffer();
    if (limit != null) {
      buffer.write(' LIMIT ?');
      args.add(limit);
    } else if (offset != null) {
      buffer.write(' LIMIT -1');
    }
    if (offset != null) {
      buffer.write(' OFFSET ?');
      args.add(offset);
    }
    return buffer.toString();
  }

  Future<List<Map<String, dynamic>>> _driftSelect(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _driftDb!.customSelect(
      sql,
      variables: _asVariables(args),
    ).get();
    return rows.map((row) => Map<String, dynamic>.from(row.data)).toList();
  }

  Future<Map<String, dynamic>> _driftSingle(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _driftSelect(sql, args);
    if (rows.isEmpty) return <String, dynamic>{};
    return rows.first;
  }

  Future<void> _driftInsert(String table, Map<String, dynamic> row) async {
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    final args = cols.map((col) => row[col]).toList(growable: false);
    await _driftDb!.customStatement(
      'INSERT INTO $table (${cols.join(',')}) VALUES ($placeholders)',
      args,
    );
  }

  Future<void> _driftUpdateById({
    required String table,
    required String id,
    required String farmId,
    required Map<String, dynamic> data,
  }) async {
    if (data.isEmpty) return;
    final keys = data.keys.toList(growable: false);
    final setClause = keys.map((key) => '$key = ?').join(', ');
    final args = <Object?>[...keys.map((k) => data[k]), farmId, id];
    await _driftDb!.customStatement(
      '''
      UPDATE $table
      SET $setClause
      WHERE farm_id = ? AND id = ?
      ''',
      args,
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ==================== FINANCIAL RECORDS ====================

  /// Retorna todos os registros financeiros
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT * FROM financial_records
        WHERE farm_id = ?
        ORDER BY date DESC
        ''',
        [farmId],
      );
    }

    return _db.db.query(
      'financial_records',
      orderBy: 'date DESC',
    );
  }

  /// Retorna registros financeiros por tipo (Receita/Despesa)
  Future<List<Map<String, dynamic>>> getRecordsByType(String type) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      return _driftSelect(
        '''
        SELECT * FROM financial_records
        WHERE farm_id = ? AND type = ?
        ORDER BY date DESC
        ''',
        [farmId, type],
      );
    }

    return _db.db.query(
      'financial_records',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
  }

  /// Insere um novo registro financeiro
  Future<void> insertRecord(Map<String, dynamic> record) async {
    final farmId = await _prepareFarmContext();
    final row = Map<String, dynamic>.from(record);

    if (farmId != null) {
      row['farm_id'] = farmId;
      await _driftInsert('financial_records', row);
      return;
    }

    await _db.db.insert('financial_records', row);
  }

  /// Atualiza um registro financeiro
  Future<void> updateRecord(String id, Map<String, dynamic> updates) async {
    if (updates.isEmpty) return;
    final farmId = await _prepareFarmContext();

    if (farmId != null) {
      await _driftUpdateById(
        table: 'financial_records',
        id: id,
        farmId: farmId,
        data: Map<String, dynamic>.from(updates),
      );
      return;
    }

    await _db.db.update(
      'financial_records',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deleta um registro financeiro
  Future<void> deleteRecord(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM financial_records WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.delete(
      'financial_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== FINANCIAL ACCOUNTS ====================

  /// Retorna todas as contas financeiras
  Future<List<FinancialAccount>> getAllAccounts() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        WHERE farm_id = ?
        ORDER BY due_date DESC
        ''',
        [farmId],
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

    final maps = await _db.db.query(
      'financial_accounts',
      orderBy: 'due_date DESC',
    );
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  /// Retorna contas com paginação e filtros opcionais (tipo/status)
  Future<List<FinancialAccount>> getAccountsPaged({
    String? type,
    String? status,
    int? limit,
    int? offset,
    bool ascending = true,
  }) async {
    final farmId = await _prepareFarmContext();
    final where = <String>[];
    final args = <Object?>[];

    if (farmId != null) {
      where.add('farm_id = ?');
      args.add(farmId);
    }
    if (type != null && type.isNotEmpty) {
      where.add('type = ?');
      args.add(type);
    }
    if (status != null && status.isNotEmpty && status != 'Todos') {
      where.add('status = ?');
      args.add(status);
    }

    if (farmId != null) {
      final sqlArgs = <Object?>[...args];
      final pagination = _buildPaginationClause(
        limit: limit,
        offset: offset,
        args: sqlArgs,
      );
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
        ORDER BY due_date ${ascending ? 'ASC' : 'DESC'}$pagination
        ''',
        sqlArgs,
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

    final maps = await _db.db.query(
      'financial_accounts',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'due_date ${ascending ? 'ASC' : 'DESC'}',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  /// Retorna contas a pagar
  Future<List<FinancialAccount>> getAccountsPayable() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        WHERE farm_id = ? AND type = ?
        ORDER BY due_date ASC
        ''',
        [farmId, 'despesa'],
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        WHERE farm_id = ? AND type = ?
        ORDER BY due_date ASC
        ''',
        [farmId, 'receita'],
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        WHERE farm_id = ? AND status = ?
        ORDER BY due_date ASC
        ''',
        [farmId, status],
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

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
    final farmId = await _prepareFarmContext();
    final row = account.toMap();

    if (farmId != null) {
      row['farm_id'] = farmId;
      await _driftInsert('financial_accounts', row);
      return;
    }

    await _db.db.insert('financial_accounts', row);
  }

  /// Atualiza uma conta
  Future<void> updateAccount(FinancialAccount account) async {
    final farmId = await _prepareFarmContext();
    final data = account.toMap()..remove('id');

    if (farmId != null) {
      await _driftUpdateById(
        table: 'financial_accounts',
        id: account.id,
        farmId: farmId,
        data: data,
      );
      return;
    }

    await _db.db.update(
      'financial_accounts',
      data,
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  /// Deleta uma conta
  Future<void> deleteAccount(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM financial_accounts WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.delete(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<FinancialAccount?> getAccountById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        'SELECT * FROM financial_accounts WHERE farm_id = ? AND id = ? LIMIT 1',
        [farmId, id],
      );
      if (rows.isEmpty) return null;
      return FinancialAccount.fromMap(rows.first);
    }

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
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final row = await _driftSingle(
        '''
        SELECT COALESCE(SUM(amount), 0) AS total
        FROM financial_records
        WHERE farm_id = ? AND type = 'receita'
        ''',
        [farmId],
      );
      return _toDouble(row['total']);
    }

    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM financial_records
      WHERE type = 'receita'
    ''');
    return _toDouble(result.first['total']);
  }

  /// Calcula total de despesas
  Future<double> getTotalExpenses() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final row = await _driftSingle(
        '''
        SELECT COALESCE(SUM(amount), 0) AS total
        FROM financial_records
        WHERE farm_id = ? AND type = 'despesa'
        ''',
        [farmId],
      );
      return _toDouble(row['total']);
    }

    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM financial_records
      WHERE type = 'despesa'
    ''');
    return _toDouble(result.first['total']);
  }

  /// Calcula saldo (receitas - despesas)
  Future<double> getBalance() async {
    final revenue = await getTotalRevenue();
    final expenses = await getTotalExpenses();
    return revenue - expenses;
  }

  /// Retorna contas vencidas (pendentes com data de vencimento passada)
  Future<List<FinancialAccount>> getOverdueAccounts() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        WHERE farm_id = ?
          AND status = 'Pendente'
          AND due_date < date('now')
        ORDER BY due_date ASC
        ''',
        [farmId],
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

    final maps = await _db.db.rawQuery('''
      SELECT * FROM financial_accounts
      WHERE status = 'Pendente'
      AND due_date < date('now')
      ORDER BY due_date ASC
    ''');
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  Future<void> updateOverdueStatus(DateTime today) async {
    final todayStr = _dateStr(today);
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        '''
        UPDATE financial_accounts
        SET status = 'Vencido'
        WHERE farm_id = ?
          AND status = 'Pendente'
          AND due_date < ?
        ''',
        [farmId, todayStr],
      );
      await _driftDb.customStatement(
        '''
        UPDATE financial_accounts
        SET status = 'Pendente'
        WHERE farm_id = ?
          AND status = 'Vencido'
          AND due_date >= ?
        ''',
        [farmId, todayStr],
      );
      return;
    }

    await _db.db.rawUpdate(
      "UPDATE financial_accounts SET status = 'Vencido' "
      "WHERE status = 'Pendente' AND due_date < ?",
      [todayStr],
    );
    await _db.db.rawUpdate(
      "UPDATE financial_accounts SET status = 'Pendente' "
      "WHERE status = 'Vencido' AND due_date >= ?",
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
    final farmId = await _prepareFarmContext();

    if (farmId != null) {
      Future<double> sumQuery(String sql, [List<Object?> args = const []]) async {
        final row = await _driftSingle(sql, [farmId, ...args]);
        return _toDouble(row['total']);
      }

      Future<int> countQuery(String sql, [List<Object?> args = const []]) async {
        final row = await _driftSingle(sql, [farmId, ...args]);
        return _toInt(row['c']);
      }

      final totalPending = await sumQuery(
        "SELECT SUM(amount) AS total FROM financial_accounts "
        "WHERE farm_id = ? AND status = 'Pendente' AND type = 'receita'",
      );

      final totalUpcoming = await sumQuery(
        "SELECT SUM(amount) AS total FROM financial_accounts "
        "WHERE farm_id = ? AND status = 'Pendente' AND due_date >= ? AND due_date <= ?",
        [todayStr, next7Str],
      );

      final countUpcoming = await countQuery(
        "SELECT COUNT(*) AS c FROM financial_accounts "
        "WHERE farm_id = ? AND status = 'Pendente' AND due_date >= ? AND due_date <= ?",
        [todayStr, next7Str],
      );

      final totalOverdue = await sumQuery(
        "SELECT SUM(amount) AS total FROM financial_accounts "
        "WHERE farm_id = ? AND status = 'Vencido'",
      );

      final countOverdue = await countQuery(
        "SELECT COUNT(*) AS c FROM financial_accounts "
        "WHERE farm_id = ? AND status = 'Vencido'",
      );

      final totalRevenue = await sumQuery(
        "SELECT SUM(amount) AS total FROM financial_accounts "
        "WHERE farm_id = ? AND status = 'Pago' AND type = 'receita' "
        "AND payment_date >= ? AND payment_date <= ?",
        [firstMonthStr, lastMonthStr],
      );

      final totalExpense = await sumQuery(
        "SELECT SUM(amount) AS total FROM financial_accounts "
        "WHERE farm_id = ? AND status = 'Pago' AND type = 'despesa' "
        "AND payment_date >= ? AND payment_date <= ?",
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

    Future<double> sumQuery(String sql, [List<Object?>? args]) async {
      final res = await _db.db.rawQuery(sql, args);
      return (res.first['total'] as num?)?.toDouble() ?? 0.0;
    }

    final totalPending = await sumQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pendente' AND type = 'receita'",
    );

    final totalUpcoming = await sumQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pendente' AND due_date >= ? AND due_date <= ?",
      [todayStr, next7Str],
    );

    final countUpcomingRes = await _db.db.rawQuery(
      "SELECT COUNT(*) as c FROM financial_accounts "
      "WHERE status = 'Pendente' AND due_date >= ? AND due_date <= ?",
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
      "AND payment_date >= ? AND payment_date <= ?",
      [firstMonthStr, lastMonthStr],
    );

    final totalExpense = await sumQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pago' AND type = 'despesa' "
      "AND payment_date >= ? AND payment_date <= ?",
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
    final farmId = await _prepareFarmContext();

    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        WHERE farm_id = ?
          AND status = 'Pendente'
          AND due_date >= ?
          AND due_date <= ?
        ORDER BY due_date ASC
        ''',
        [farmId, _dateStr(today), _dateStr(limit)],
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

    final res = await _db.db.query(
      'financial_accounts',
      where: "status = 'Pendente' AND due_date >= ? AND due_date <= ?",
      whereArgs: [
        _dateStr(today),
        _dateStr(limit),
      ],
      orderBy: 'due_date ASC',
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  Future<List<FinancialAccount>> getRecurringCandidates(DateTime today) async {
    final farmId = await _prepareFarmContext();
    final todayStr = _dateStr(today);
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        WHERE farm_id = ?
          AND is_recurring = 1
          AND parent_id IS NULL
          AND (recurrence_end_date IS NULL OR recurrence_end_date >= ?)
        ''',
        [farmId, todayStr],
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

    final res = await _db.db.query(
      'financial_accounts',
      where:
          'is_recurring = ? AND parent_id IS NULL AND (recurrence_end_date IS NULL OR recurrence_end_date >= ?)',
      whereArgs: [1, todayStr],
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  Future<DateTime?> getLastChildDueDate(String parentId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final row = await _driftSingle(
        '''
        SELECT MAX(due_date) AS last
        FROM financial_accounts
        WHERE farm_id = ? AND parent_id = ?
        ''',
        [farmId, parentId],
      );
      final lastStr = row['last'] as String?;
      return lastStr != null ? DateTime.tryParse(lastStr) : null;
    }

    final lastRow = await _db.db.rawQuery(
      'SELECT MAX(due_date) AS last FROM financial_accounts WHERE parent_id = ?',
      [parentId],
    );
    final String? lastStr = lastRow.first['last'] as String?;
    return lastStr != null ? DateTime.tryParse(lastStr) : null;
  }

  Future<bool> hasChildWithDueDate(String parentId, DateTime dueDate) async {
    final farmId = await _prepareFarmContext();
    final due = _dateStr(dueDate);
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT id FROM financial_accounts
        WHERE farm_id = ? AND parent_id = ? AND due_date = ?
        LIMIT 1
        ''',
        [farmId, parentId, due],
      );
      return rows.isNotEmpty;
    }

    final existing = await _db.db.query(
      'financial_accounts',
      where: 'parent_id = ? AND due_date = ?',
      whereArgs: [parentId, due],
      limit: 1,
    );
    return existing.isNotEmpty;
  }

  Future<List<FinancialAccount>> getRecurringMothers() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT * FROM financial_accounts
        WHERE farm_id = ? AND is_recurring = 1 AND parent_id IS NULL
        ORDER BY due_date ASC
        ''',
        [farmId],
      );
      return rows.map(FinancialAccount.fromMap).toList();
    }

    final res = await _db.db.query(
      'financial_accounts',
      where: 'is_recurring = 1 AND parent_id IS NULL',
      orderBy: 'due_date ASC',
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  Future<void> deleteRecurringCascade(String motherId) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        '''
        DELETE FROM financial_accounts
        WHERE farm_id = ? AND parent_id = ?
        ''',
        [farmId, motherId],
      );
      await _driftDb.customStatement(
        '''
        DELETE FROM financial_accounts
        WHERE farm_id = ? AND id = ?
        ''',
        [farmId, motherId],
      );
      return;
    }

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
    final farmId = await _prepareFarmContext();
    final startStr = _dateStr(start);
    final endStr = _dateStr(end);
    if (farmId != null) {
      final row = await _driftSingle(
        '''
        SELECT SUM(amount) AS total
        FROM financial_accounts
        WHERE farm_id = ?
          AND type = ?
          AND due_date >= ?
          AND due_date < ?
        ''',
        [farmId, type, startStr, endStr],
      );
      return _toDouble(row['total']);
    }

    final res = await _db.db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_accounts '
      'WHERE type = ? AND due_date >= ? AND due_date < ?',
      [type, startStr, endStr],
    );
    return _toDouble(res.first['total']);
  }
}
