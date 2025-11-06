// lib/services/financial_service.dart
import 'package:sqflite_common/sqlite_api.dart' show Database, ConflictAlgorithm;

import '../data/local_db.dart';
import '../models/financial_account.dart';


class FinancialService {
  // Obtém o Database e garante que as tabelas existam
  static Future<Database> _getDb() async {
    final appDb = await AppDatabase.open();
    final db = appDb.db;
    await _ensureTablesExist(db);
    return db;
  }

  // Garante que a tabela/índices existem
  static Future<void> _ensureTablesExist(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS financial_accounts (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,                -- 'receita' | 'despesa'
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,            -- 'YYYY-MM-DD'
        payment_date TEXT,                 -- 'YYYY-MM-DD' quando pago
        status TEXT NOT NULL,              -- 'Pendente' | 'Pago' | 'Vencido'
        payment_method TEXT,
        installments INTEGER,
        installment_number INTEGER,
        parent_id TEXT,                    -- recorrente (filha) aponta p/ mãe
        animal_id TEXT,
        supplier_customer TEXT,
        notes TEXT,
        is_recurring INTEGER NOT NULL DEFAULT 0,  -- 1 só na "mãe"
        recurrence_frequency TEXT,         -- 'Semanal' | 'Mensal' | 'Anual'
        recurrence_end_date TEXT,          -- 'YYYY-MM-DD'
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fin_due_date ON financial_accounts(due_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fin_status ON financial_accounts(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fin_type ON financial_accounts(type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_fin_parent ON financial_accounts(parent_id)',
    );

    // Evita duplicar a mesma filha por (parent_id, due_date)
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ux_fin_parent_due ON financial_accounts(parent_id, due_date)',
    );
  }

  // Helper para data yyyy-MM-dd
  static String _dateStr(DateTime d) => d.toIso8601String().split('T')[0];

  // ========== CRUD ==========

  static Future<void> createAccount(FinancialAccount account) async {
    final db = await _getDb();

    await db.insert(
      'financial_accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Se for "Venda de Animais", atualiza o status do animal
    
  }

  static Future<void> updateAccount(FinancialAccount account) async {
    final db = await _getDb();

    await db.update(
      'financial_accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );

  
  }

  static Future<void> deleteAccount(String id) async {
    final db = await _getDb();
    await db.delete(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    // Obs.: não fazemos "desvenda" automática do animal ao excluir o título.
  }

  static Future<FinancialAccount> getById(String id) async {
    final db = await _getDb();

    final res = await db.query(
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

  static Future<List<FinancialAccount>> getAllAccounts() async {
    final db = await _getDb();

    final res = await db.query(
      'financial_accounts',
      orderBy: 'date(due_date) ASC',
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  static Future<void> markAsPaid(String id, DateTime paymentDate) async {
    final db = await _getDb();

    final res = await db.query(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (res.isEmpty) {
      throw Exception('FinancialAccount $id não encontrado');
    }

    final acc = FinancialAccount.fromMap(res.first);
    final updated = acc.copyWith(
      status: 'Pago',
      paymentDate: paymentDate,
      updatedAt: DateTime.now(),
    );

    await db.update(
      'financial_accounts',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );


  }

  // ========== STATUS VENCIDO ==========

  static Future<void> updateOverdueStatus() async {
    final db = await _getDb();
    final today = _dateStr(DateTime.now());

    // Pendente que já passou da data => Vencido
    await db.rawUpdate(
      "UPDATE financial_accounts SET status = 'Vencido' "
      "WHERE status = 'Pendente' AND date(due_date) < date(?)",
      [today],
    );

    // Voltar de Vencido para Pendente caso data tenha sido alterada para futuro
    await db.rawUpdate(
      "UPDATE financial_accounts SET status = 'Pendente' "
      "WHERE status = 'Vencido' AND date(due_date) >= date(?)",
      [today],
    );
  }

  // ========== DASHBOARD ==========

  static Future<Map<String, dynamic>> getDashboardStats() async {
    await updateOverdueStatus();
    final db = await _getDb();
    final today = DateTime.now();
    final firstDayOfMonth = DateTime(today.year, today.month, 1);
    final lastDayOfMonth = DateTime(today.year, today.month + 1, 0);

    // Total pendente (APENAS A RECEBER)
    final pendingResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_accounts '
      'WHERE status = ? AND type = ?',
      ['Pendente', 'receita'],
    );
    final totalPending =
        (pendingResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // A vencer nos próximos 7 dias (receita + despesa)
    final next7 = today.add(const Duration(days: 7));
    final todayStr = _dateStr(today);
    final next7Str = _dateStr(next7);

    final upcomingResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pendente' AND date(due_date) >= date(?) AND date(due_date) <= date(?)",
      [todayStr, next7Str],
    );
    final totalUpcoming =
        (upcomingResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final countUpcomingRes = await db.rawQuery(
      "SELECT COUNT(*) as c FROM financial_accounts "
      "WHERE status = 'Pendente' AND date(due_date) >= date(?) AND date(due_date) <= date(?)",
      [todayStr, next7Str],
    );
    final countUpcoming = (countUpcomingRes.first['c'] as num?)?.toInt() ?? 0;

    // Vencidas (soma e quantidade)
    final overdueResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM financial_accounts WHERE status = 'Vencido'",
    );
    final totalOverdue =
        (overdueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final countOverdueRes = await db.rawQuery(
      "SELECT COUNT(*) as c FROM financial_accounts WHERE status = 'Vencido'",
    );
    final countOverdue = (countOverdueRes.first['c'] as num?)?.toInt() ?? 0;

    // Receitas e despesas PAGAS no mês
    final firstMonthStr = _dateStr(firstDayOfMonth);
    final lastMonthStr = _dateStr(lastDayOfMonth);

    final revenueResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pago' AND type = 'receita' "
      "AND date(payment_date) >= date(?) AND date(payment_date) <= date(?)",
      [firstMonthStr, lastMonthStr],
    );
    final totalRevenue =
        (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final expenseResult = await db.rawQuery(
      "SELECT SUM(amount) as total FROM financial_accounts "
      "WHERE status = 'Pago' AND type = 'despesa' "
      "AND date(payment_date) >= date(?) AND date(payment_date) <= date(?)",
      [firstMonthStr, lastMonthStr],
    );
    final totalExpense =
        (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final balance = totalRevenue - totalExpense;

    return {
      'totalPending': totalPending,      // a receber pendente
      'totalUpcoming': totalUpcoming,    // próximos 7 dias (receita + despesa)
      'countUpcoming': countUpcoming,
      'totalOverdue': totalOverdue,
      'countOverdue': countOverdue,
      'totalPaidMonth': totalRevenue - totalExpense,
      'balance': balance,
      'totalRevenue': totalRevenue,
      'totalExpense': totalExpense,
    };
  }

  // Próximos N dias (pendentes)
  static Future<List<FinancialAccount>> getUpcomingAccounts(int days) async {
    final db = await _getDb();

    final today = DateTime.now();
    final limit = today.add(Duration(days: days));

    final res = await db.query(
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

  // Vencidos
  static Future<List<FinancialAccount>> getOverdueAccounts() async {
    final db = await _getDb();

    final res = await db.query(
      'financial_accounts',
      where: "status = 'Vencido'",
      orderBy: 'date(due_date) ASC',
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  // ========== RECORRENTES ==========

  // Gera SEMPRE a próxima "filha" a partir do último vencimento existente
  static Future<void> generateRecurringAccounts() async {
    final db = await _getDb();
    final todayStr = _dateStr(DateTime.now());

    // Seleciona apenas as "mães" (sem parent_id) ativas
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_accounts',
      where:
          'is_recurring = ? AND parent_id IS NULL AND (recurrence_end_date IS NULL OR date(recurrence_end_date) >= date(?))',
      whereArgs: [1, todayStr],
    );

    for (final map in maps) {
      final mother = FinancialAccount.fromMap(map);

      // Última data conhecida: filho mais recente; caso não exista, due da mãe
      final lastRow = await db.rawQuery(
        'SELECT MAX(date(due_date)) AS last FROM financial_accounts WHERE parent_id = ?',
        [mother.id],
      );
      final String? lastStr = lastRow.first['last'] as String?;
      final DateTime lastDue =
          lastStr != null ? DateTime.parse(lastStr) : mother.dueDate;

      // Próxima data baseada na última
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

      // Respeita data de término
      if (mother.recurrenceEndDate != null &&
          nextDue.isAfter(mother.recurrenceEndDate!)) {
        continue;
      }

      // Evita duplicar (mesmo parent + mesma data)
      final existing = await db.query(
        'financial_accounts',
        where: 'parent_id = ? AND date(due_date) = date(?)',
        whereArgs: [mother.id, _dateStr(nextDue)],
      );
      if (existing.isNotEmpty) continue;

      final newMap = {
        'id': '${mother.id}_${nextDue.millisecondsSinceEpoch}',
        'type': mother.type,
        'category': mother.category,
        'description': mother.description,
        'amount': mother.amount,
        'due_date': _dateStr(nextDue),
        'payment_date': null,
        'status': 'Pendente',
        'payment_method': mother.paymentMethod,
        'installments': mother.installments,
        'installment_number': mother.installmentNumber,
        'parent_id': mother.id, // filha aponta para a mãe
        'animal_id': mother.animalId,
        'supplier_customer': mother.supplierCustomer,
        'notes': mother.notes,
        'is_recurring': 0, // filha NÃO é "mãe"
        'recurrence_frequency': null,
        'recurrence_end_date': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final child = FinancialAccount.fromMap(newMap);
      await createAccount(child);
    }
  }

  // Lista apenas as "mães" recorrentes (útil para a tela)
  static Future<List<FinancialAccount>> getRecurringMothers() async {
    final db = await _getDb();
    final res = await db.query(
      'financial_accounts',
      where: 'is_recurring = 1 AND parent_id IS NULL',
      orderBy: 'date(due_date) ASC',
    );
    return res.map(FinancialAccount.fromMap).toList();
  }

  // Exclui a recorrência inteira: primeiro as filhas, depois a mãe
  static Future<void> deleteRecurringCascade(String motherId) async {
    final db = await _getDb();
    await db.delete(
      'financial_accounts',
      where: 'parent_id = ?',
      whereArgs: [motherId],
    );
    await db.delete(
      'financial_accounts',
      where: 'id = ?',
      whereArgs: [motherId],
    );
  }

  // ========== PROJEÇÃO FLUXO DE CAIXA ==========

  static Future<List<Map<String, dynamic>>> getCashFlowProjection(
      int months) async {
    final db = await _getDb();
    final today = DateTime.now();
    final List<Map<String, dynamic>> projection = [];

    for (int i = 0; i < months; i++) {
      final month = DateTime(today.year, today.month + i, 1);
      final nextMonth = DateTime(month.year, month.month + 1, 1);

      final revenueResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM financial_accounts '
        'WHERE type = ? AND date(due_date) >= date(?) AND date(due_date) < date(?)',
        [
          'receita',
          _dateStr(month),
          _dateStr(nextMonth),
        ],
      );
      final revenue =
          (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;

      final expenseResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM financial_accounts '
        'WHERE type = ? AND date(due_date) >= date(?) AND date(due_date) < date(?)',
        [
          'despesa',
          _dateStr(month),
          _dateStr(nextMonth),
        ],
      );
      final expense =
          (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

      projection.add({
        'month': month,
        'revenue': revenue,
        'expense': expense,
        'balance': revenue - expense,
      });
    }

    return projection;
  }

  // ========== ADAPTADOR PARA A TELA (INSTANCE METHOD) ==========

  /// Método de instância usado pela `_FinancialTab` no ManagementScreen.
  ///
  /// Ele converte a lista de `FinancialAccount` em `List<Map<String, dynamic>>`
  /// com as chaves esperadas pela tela: `type`, `category`, `description`,
  /// `amount`, `date` (mapeada a partir de `due_date`).
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
        // campo que o ManagementScreen usa para exibir a data:
        'date': dueStr,
        // mantemos também o due_date original, se você quiser usar depois
        'due_date': dueStr,
        'status': acc.status,
        'payment_date': acc.paymentDate != null
            ? _dateStr(acc.paymentDate!)
            : null,
      };
    }).toList();
  }
}
