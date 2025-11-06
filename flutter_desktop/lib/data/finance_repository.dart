import '../models/financial_account.dart';
import 'local_db.dart';

/// Repository para gerenciar registros financeiros e contas a pagar/receber
class FinanceRepository {
  final AppDatabase _db;

  FinanceRepository(this._db);

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
      whereArgs: ['Despesa'],
      orderBy: 'due_date ASC',
    );
    return maps.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  /// Retorna contas a receber
  Future<List<FinancialAccount>> getAccountsReceivable() async {
    final maps = await _db.db.query(
      'financial_accounts',
      where: 'type = ?',
      whereArgs: ['Receita'],
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

  // ==================== AGREGAÇÕES ====================

  /// Calcula total de receitas
  Future<double> getTotalRevenue() async {
    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM financial_records
      WHERE type = 'Receita'
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Calcula total de despesas
  Future<double> getTotalExpenses() async {
    final result = await _db.db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM financial_records
      WHERE type = 'Despesa'
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
}
