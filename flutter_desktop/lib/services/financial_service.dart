import 'package:sqflite/sqflite.dart';
import '../models/financial_account.dart';
import 'database_service.dart';
import 'sale_hooks.dart';

class FinancialService {
  static Future<void> _ensureTablesExist() async {
    final db = await DatabaseService.database;
    
    // Create financial_accounts table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS financial_accounts (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        payment_date TEXT,
        status TEXT NOT NULL,
        payment_method TEXT,
        installments INTEGER,
        installment_number INTEGER,
        parent_id TEXT,
        animal_id TEXT,
        supplier_customer TEXT,
        notes TEXT,
        cost_center TEXT,
        is_recurring INTEGER DEFAULT 0,
        recurrence_frequency TEXT,
        recurrence_end_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create cost_centers table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cost_centers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        cost_center TEXT,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // Financial Accounts CRUD
  static Future<List<FinancialAccount>> getAllAccounts() async {
    await _ensureTablesExist();
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_accounts',
      orderBy: 'due_date DESC',
    );
    return List.generate(maps.length, (i) => FinancialAccount.fromMap(maps[i]));
  }

  static Future<FinancialAccount> createAccount(FinancialAccount account) async {
    await _ensureTablesExist();
    final db = await DatabaseService.database;
    await db.insert('financial_accounts', account.toMap());
    await handleAnimalSaleIfApplicable(account);
    return account;
  }

  static Future<void> updateAccount(FinancialAccount account) async {
    final db = await DatabaseService.database;
    await db.update(
      'financial_accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
    await handleAnimalSaleIfApplicable(account);
  }

  static Future<void> deleteAccount(String id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> markAsPaid(String id, DateTime paymentDate) async {
    final db = await DatabaseService.database;
    await db.update(
      'financial_accounts',
      {
        'status': 'Pago',
        'payment_date': paymentDate.toIso8601String().split('T')[0],
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateOverdueStatus() async {
    final db = await DatabaseService.database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await db.update(
      'financial_accounts',
      {'status': 'Vencido', 'updated_at': DateTime.now().toIso8601String()},
      where: 'status = ? AND date(due_date) < date(?)',
      whereArgs: ['Pendente', today],
    );
  }

  static Future<List<FinancialAccount>> getAccountsByStatus(String status) async {
    await updateOverdueStatus();
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_accounts',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => FinancialAccount.fromMap(maps[i]));
  }

  static Future<List<FinancialAccount>> getUpcomingAccounts(int days) async {
    await updateOverdueStatus();
    final db = await DatabaseService.database;
    final today = DateTime.now();
    final futureDate = today.add(Duration(days: days));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_accounts',
      where: 'status IN (?, ?) AND date(due_date) BETWEEN date(?) AND date(?)',
      whereArgs: ['Pendente', 'Vencido', today.toIso8601String().split('T')[0], futureDate.toIso8601String().split('T')[0]],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => FinancialAccount.fromMap(maps[i]));
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    await updateOverdueStatus();
    final db = await DatabaseService.database;
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final lastDayOfMonth = DateTime(today.year, today.month + 1, 0);

    // Total pendente
    final pendingResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_accounts WHERE status = ?',
      ['Pendente'],
    );
    final totalPending = (pendingResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // A vencer (próximos 7 dias)
    final upcomingDate = today.add(Duration(days: 7));
    final upcomingResult = await db.rawQuery(
      'SELECT SUM(amount) as total, COUNT(*) as count FROM financial_accounts WHERE status = ? AND date(due_date) BETWEEN date(?) AND date(?)',
      ['Pendente', today.toIso8601String().split('T')[0], upcomingDate.toIso8601String().split('T')[0]],
    );
    final totalUpcoming = (upcomingResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final countUpcoming = (upcomingResult.first['count'] as int?) ?? 0;

    // Vencidas
    final overdueResult = await db.rawQuery(
      'SELECT SUM(amount) as total, COUNT(*) as count FROM financial_accounts WHERE status = ?',
      ['Vencido'],
    );
    final totalOverdue = (overdueResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final countOverdue = (overdueResult.first['count'] as int?) ?? 0;

    // Pago no mês
    final paidMonthResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_accounts WHERE status = ? AND date(payment_date) BETWEEN date(?) AND date(?)',
      ['Pago', firstDayOfMonth.toIso8601String().split('T')[0], lastDayOfMonth.toIso8601String().split('T')[0]],
    );
    final totalPaidMonth = (paidMonthResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Receitas e despesas do mês
    final revenueResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_accounts WHERE type = ? AND status = ? AND date(payment_date) BETWEEN date(?) AND date(?)',
      ['receita', 'Pago', firstDayOfMonth.toIso8601String().split('T')[0], lastDayOfMonth.toIso8601String().split('T')[0]],
    );
    final totalRevenue = (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_accounts WHERE type = ? AND status = ? AND date(payment_date) BETWEEN date(?) AND date(?)',
      ['despesa', 'Pago', firstDayOfMonth.toIso8601String().split('T')[0], lastDayOfMonth.toIso8601String().split('T')[0]],
    );
    final totalExpense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'totalPending': totalPending,
      'totalUpcoming': totalUpcoming,
      'countUpcoming': countUpcoming,
      'totalOverdue': totalOverdue,
      'countOverdue': countOverdue,
      'totalPaidMonth': totalPaidMonth,
      'balance': totalRevenue - totalExpense,
      'totalRevenue': totalRevenue,
      'totalExpense': totalExpense,
    };
  }

  // Generate installments
  static Future<List<FinancialAccount>> createInstallments(FinancialAccount account) async {
    if (account.installments == null || account.installments! <= 1) {
      return [await createAccount(account)];
    }

    final installmentAmount = account.amount / account.installments!;
    final List<FinancialAccount> installments = [];
    final parentId = account.id;

    for (int i = 1; i <= account.installments!; i++) {
      final dueDate = DateTime(
        account.dueDate.year,
        account.dueDate.month + (i - 1),
        account.dueDate.day,
      );

      final installment = FinancialAccount(
        id: '${account.id}_$i',
        type: account.type,
        category: account.category,
        description: '${account.description} ($i/${account.installments})',
        amount: installmentAmount,
        dueDate: dueDate,
        status: 'Pendente',
        paymentMethod: account.paymentMethod,
        installments: account.installments,
        installmentNumber: i,
        parentId: parentId,
        animalId: account.animalId,
        supplierCustomer: account.supplierCustomer,
        notes: account.notes,
        costCenter: account.costCenter,
        createdAt: account.createdAt,
        updatedAt: account.updatedAt,
      );

      await createAccount(installment);
      installments.add(installment);
    }

    return installments;
  }

  // Recurring expenses
  static Future<void> generateRecurringAccounts() async {
    final db = await DatabaseService.database;
    final today = DateTime.now();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_accounts',
      where: 'is_recurring = ? AND (recurrence_end_date IS NULL OR date(recurrence_end_date) >= date(?))',
      whereArgs: [1, today.toIso8601String().split('T')[0]],
    );

    for (var map in maps) {
      final recurring = FinancialAccount.fromMap(map);
      final nextDueDate = _calculateNextDueDate(recurring);
      
      if (nextDueDate != null) {
        // Check if next occurrence already exists
        final existing = await db.query(
          'financial_accounts',
          where: 'parent_id = ? AND date(due_date) = date(?)',
          whereArgs: [recurring.id, nextDueDate.toIso8601String().split('T')[0]],
        );

        if (existing.isEmpty) {
          final newAccount = FinancialAccount(
            id: '${recurring.id}_${nextDueDate.millisecondsSinceEpoch}',
            type: recurring.type,
            category: recurring.category,
            description: recurring.description,
            amount: recurring.amount,
            dueDate: nextDueDate,
            status: 'Pendente',
            paymentMethod: recurring.paymentMethod,
            animalId: recurring.animalId,
            supplierCustomer: recurring.supplierCustomer,
            notes: recurring.notes,
            costCenter: recurring.costCenter,
            parentId: recurring.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await createAccount(newAccount);
        }
      }
    }
  }

  static DateTime? _calculateNextDueDate(FinancialAccount recurring) {
    final today = DateTime.now();
    final lastDue = recurring.dueDate;

    switch (recurring.recurrenceFrequency) {
      case 'Mensal':
        return DateTime(today.year, today.month + 1, lastDue.day);
      case 'Semanal':
        return today.add(Duration(days: 7));
      case 'Anual':
        return DateTime(today.year + 1, lastDue.month, lastDue.day);
      default:
        return null;
    }
  }

  // Cost Centers
  static Future<List<CostCenter>> getAllCostCenters() async {
    await _ensureTablesExist();
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('cost_centers', where: 'active = ?', whereArgs: [1]);
    return List.generate(maps.length, (i) => CostCenter.fromMap(maps[i]));
  }

  static Future<CostCenter> createCostCenter(CostCenter costCenter) async {
    await _ensureTablesExist();
    final db = await DatabaseService.database;
    await db.insert('cost_centers', costCenter.toMap());
    return costCenter;
  }

  static Future<void> deleteCostCenter(String id) async {
    final db = await DatabaseService.database;
    await db.update('cost_centers', {'active': 0}, where: 'id = ?', whereArgs: [id]);
  }

  // Budgets
  static Future<List<Budget>> getAllBudgets() async {
    await _ensureTablesExist();
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('budgets', orderBy: 'year DESC, month DESC');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  static Future<Budget> createBudget(Budget budget) async {
    await _ensureTablesExist();
    final db = await DatabaseService.database;
    await db.insert('budgets', budget.toMap());
    return budget;
  }

  static Future<void> updateBudget(Budget budget) async {
    final db = await DatabaseService.database;
    await db.update('budgets', budget.toMap(), where: 'id = ?', whereArgs: [budget.id]);
  }

  static Future<void> deleteBudget(String id) async {
    final db = await DatabaseService.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, dynamic>> getBudgetAnalysis(String category, int year, int? month) async {
    final db = await DatabaseService.database;
    
    String dateCondition;
    List<dynamic> dateArgs;
    
    if (month != null) {
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      dateCondition = 'date(payment_date) BETWEEN date(?) AND date(?)';
      dateArgs = [firstDay.toIso8601String().split('T')[0], lastDay.toIso8601String().split('T')[0]];
    } else {
      final firstDay = DateTime(year, 1, 1);
      final lastDay = DateTime(year, 12, 31);
      dateCondition = 'date(payment_date) BETWEEN date(?) AND date(?)';
      dateArgs = [firstDay.toIso8601String().split('T')[0], lastDay.toIso8601String().split('T')[0]];
    }

    final result = await db.rawQuery(
      'SELECT SUM(amount) as spent FROM financial_accounts WHERE category = ? AND status = ? AND $dateCondition',
      [category, 'Pago', ...dateArgs],
    );

    final spent = (result.first['spent'] as num?)?.toDouble() ?? 0.0;

    return {
      'spent': spent,
    };
  }

  // Cash Flow Projection
  static Future<List<Map<String, dynamic>>> getCashFlowProjection(int months) async {
    final db = await DatabaseService.database;
    final today = DateTime.now();
    final List<Map<String, dynamic>> projection = [];

    for (int i = 0; i < months; i++) {
      final month = DateTime(today.year, today.month + i, 1);
      final nextMonth = DateTime(today.year, today.month + i + 1, 1);

      final revenueResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM financial_accounts WHERE type = ? AND date(due_date) >= date(?) AND date(due_date) < date(?)',
        ['receita', month.toIso8601String().split('T')[0], nextMonth.toIso8601String().split('T')[0]],
      );
      final revenue = (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

      final expenseResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM financial_accounts WHERE type = ? AND date(due_date) >= date(?) AND date(due_date) < date(?)',
        ['despesa', month.toIso8601String().split('T')[0], nextMonth.toIso8601String().split('T')[0]],
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
}
