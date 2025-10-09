// lib/data/local_db.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  final Database db;
  AppDatabase(this.db);

  static Future<String> _resolveDbPath([String fileName = 'fazenda.db']) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'FazendaDB'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return p.join(dir.path, fileName);
  }

  /// Abre o SQLite local. **Sem migrações** — cria tudo se não existir.
  static Future<AppDatabase> open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final path = await _resolveDbPath();
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1, // se precisar recriar, apague o arquivo .db
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, v) async => _createAll(db),
      ),
    );
    // ignore: avoid_print
    print('SQLite em: $path');
    return AppDatabase(db);
  }

  static Future<String> dbPath() => _resolveDbPath();

  /// Schema puro (equivalente ao Supabase):
  /// - uuid/timestamp/date -> TEXT
  /// - numeric -> REAL
  /// - boolean -> INTEGER (0/1)
  static Future<void> _createAll(Database db) async {
    // ======== ANIMALS ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS animals (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        species TEXT NOT NULL CHECK (species IN ('Ovino','Caprino')),
        breed TEXT NOT NULL,
        gender TEXT NOT NULL CHECK (gender IN ('Macho','Fêmea')),
        birth_date TEXT NOT NULL,              -- 'YYYY-MM-DD'
        weight REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Saudável',
        location TEXT NOT NULL,
        last_vaccination TEXT,                 -- 'YYYY-MM-DD'
        pregnant INTEGER DEFAULT 0,            -- boolean 0/1
        expected_delivery TEXT,                -- 'YYYY-MM-DD'
        health_issue TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        name_color TEXT,
        category TEXT,
        birth_weight REAL,
        weight_30_days REAL,
        weight_60_days REAL,
        weight_90_days REAL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_code    ON animals(code);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_status  ON animals(status);');

    // ======== BREEDING_RECORDS ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS breeding_records (
        id TEXT PRIMARY KEY,
        female_animal_id TEXT,
        male_animal_id TEXT,
        breeding_date TEXT NOT NULL,           -- date
        expected_birth TEXT,                   -- date
        status TEXT NOT NULL DEFAULT 'Cobertura',
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        -- multiestágio
        mating_start_date TEXT,                -- date
        mating_end_date TEXT,                  -- date
        separation_date TEXT,                  -- date
        ultrasound_date TEXT,                  -- date
        ultrasound_result TEXT,
        birth_date TEXT,                       -- date
        stage TEXT DEFAULT 'Encabritamento',
        FOREIGN KEY (female_animal_id) REFERENCES animals(id) ON DELETE SET NULL,
        FOREIGN KEY (male_animal_id)   REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_male   ON breeding_records(male_animal_id);');

    // ======== MEDICATIONS ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medications (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        date TEXT NOT NULL,                    -- date
        next_date TEXT,                        -- date
        dosage TEXT,
        veterinarian TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        status TEXT NOT NULL DEFAULT 'Agendado',
        applied_date TEXT,                     -- date
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_next_date ON medications(next_date);');

    // ======== VACCINATIONS ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccinations (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        vaccine_name TEXT NOT NULL,
        vaccine_type TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,          -- date
        applied_date TEXT,                     -- date
        veterinarian TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'Agendada' CHECK (status IN ('Agendada','Aplicada','Cancelada')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);');

    // ======== NOTES ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id TEXT PRIMARY KEY,
        animal_id TEXT,
        title TEXT NOT NULL,
        content TEXT,
        category TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'Média',
        date TEXT NOT NULL DEFAULT (date('now')),
        created_by TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        is_read INTEGER NOT NULL DEFAULT 0,    -- boolean 0/1
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id);');

    // ======== FINANCIAL_RECORDS ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS financial_records (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL CHECK (type IN ('receita','despesa')),
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL DEFAULT (date('now')),
        animal_id TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_financial_animal_id ON financial_records(animal_id);');

    // ======== REPORTS ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reports (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        report_type TEXT NOT NULL CHECK (report_type IN ('Animais','Vacinações','Reprodução','Saúde','Financeiro')),
        parameters TEXT NOT NULL DEFAULT '{}', -- jsonb -> TEXT
        generated_at TEXT NOT NULL DEFAULT (datetime('now')),
        generated_by TEXT
      );
    ''');

    // ======== PUSH_TOKENS ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS push_tokens (
        id TEXT PRIMARY KEY,
        token TEXT NOT NULL UNIQUE,
        platform TEXT,
        device_info TEXT NOT NULL DEFAULT '{}', -- jsonb -> TEXT
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');

    // ======== ANIMAL_WEIGHTS (agora também no Supabase) ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS animal_weights (
        id TEXT PRIMARY KEY,                    -- uuid
        animal_id TEXT NOT NULL,
        date TEXT NOT NULL,                     -- 'YYYY-MM-DD'
        weight REAL NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_date ON animal_weights(animal_id, date);');

    // ======== COST_CENTERS ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cost_centers (
        id TEXT PRIMARY KEY,                    -- uuid
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        color TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');

    // ======== BUDGETS (vinculado a cost_centers) ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS budgets (
        id TEXT PRIMARY KEY,                    -- uuid
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL CHECK (period IN ('Mensal','Trimestral','Anual')),
        start_date TEXT NOT NULL,               -- date
        end_date TEXT NOT NULL,                 -- date
        cost_center_id TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (cost_center_id) REFERENCES cost_centers(id)
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_budgets_cost_center ON budgets(cost_center_id);');

    // ======== FINANCIAL_ACCOUNTS (contas a pagar/receber) ========
    await db.execute('''
      CREATE TABLE IF NOT EXISTS financial_accounts (
        id TEXT PRIMARY KEY,                    -- uuid
        type TEXT NOT NULL CHECK (type IN ('receita','despesa')),
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,                 -- date
        payment_date TEXT,                      -- date
        status TEXT NOT NULL DEFAULT 'Pendente' CHECK (status IN ('Pendente','Pago','Vencido','Cancelado')),
        payment_method TEXT,
        installments INTEGER,
        installment_number INTEGER,
        parent_id TEXT,                         -- FK p/ conta "mãe" (parcelamento/recorrência)
        animal_id TEXT,
        supplier_customer TEXT,
        notes TEXT,
        is_recurring INTEGER DEFAULT 0,         -- boolean 0/1
        recurrence_frequency TEXT CHECK (recurrence_frequency IN ('Diária','Semanal','Mensal','Anual')),
        recurrence_end_date TEXT,               -- date
        cost_center_id TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (parent_id)     REFERENCES financial_accounts(id),
        FOREIGN KEY (cost_center_id) REFERENCES cost_centers(id),
        FOREIGN KEY (animal_id)     REFERENCES animals(id)
      );
    ''');

    // Índices úteis p/ performance de filtros
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_due_date     ON financial_accounts(due_date);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_status       ON financial_accounts(status);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_type         ON financial_accounts(type);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_category     ON financial_accounts(category);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_animal_id    ON financial_accounts(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_cost_center  ON financial_accounts(cost_center_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_parent_id    ON financial_accounts(parent_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_is_recurring ON financial_accounts(is_recurring);');

    // ======== TRIGGERS updated_at (somente onde existe a coluna) ========
    Future<void> _makeUpdatedAtTrigger(String table) async {
      await db.execute('''
        CREATE TRIGGER IF NOT EXISTS ${table}_updated_at
        AFTER UPDATE ON $table
        FOR EACH ROW
        BEGIN
          UPDATE $table SET updated_at = datetime('now') WHERE id = OLD.id;
        END;
      ''');
    }

    for (final tbl in [
      'animals',
      'breeding_records',
      'medications',
      'vaccinations',
      'notes',
      'financial_records',
      'animal_weights',
      'budgets',
      'financial_accounts',
      // cost_centers NÃO tem updated_at no Supabase → sem trigger
      // push_tokens / reports não precisam (não usamos updated_at neles)
    ]) {
      await _makeUpdatedAtTrigger(tbl);
    }
  }
}
