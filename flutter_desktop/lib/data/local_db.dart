// lib/data/local_db.dart
// SQLite local espelhado do Supabase (Out/2025) — versão sem Cost Centers & Budgets
// Mapas de tipos: uuid→TEXT | timestamptz→TEXT(ISO8601) | date→TEXT(YYYY-MM-DD) | numeric→REAL | boolean→INTEGER(0/1)
//
// Observações:
// - Chaves estrangeiras habilitadas (PRAGMA foreign_keys = ON)
// - Triggers de updated_at (com cláusula WHEN para evitar recursão)
// - Sem migrações: apague o .db para recriar caso já exista.

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
        version: 1, // mantenha 1; apague o .db para recriar sempre que mudar o schema
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, v) async => _createAll(db),
      ),
    );
    return AppDatabase(db);
  }

  static Future<String> dbPath() => _resolveDbPath();

  /// Criação do schema 1:1 com o Supabase (tipos mapeados p/ SQLite),
  /// já **sem** budgets, cost_centers e cost_center_id.
  static Future<void> _createAll(Database db) async {
    // =====================
    // ====== TABLES =======
    // =====================

    // -------- animals
    await db.execute('''
      CREATE TABLE IF NOT EXISTS animals (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        species TEXT NOT NULL CHECK (species IN ('Ovino','Caprino')),
        breed TEXT NOT NULL,
        gender TEXT NOT NULL CHECK (gender IN ('Macho','Fêmea')),
        birth_date TEXT NOT NULL,
        weight REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Saudável',
        location TEXT NOT NULL,
        last_vaccination TEXT,
        pregnant INTEGER DEFAULT 0,
        expected_delivery TEXT,
        health_issue TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        name_color TEXT,
        category TEXT,
        birth_weight REAL,
        weight_30_days REAL,
        weight_60_days REAL,
        weight_90_days REAL,
        weight_120_days REAL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_code ON animals(code);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);');

    // -------- animal_weights
    await db.execute('''
      CREATE TABLE IF NOT EXISTS animal_weights (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        date TEXT NOT NULL,
        weight REAL NOT NULL,
        milestone TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id)
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_date ON animal_weights(animal_id, date);');

    // -------- breeding_records
    await db.execute('''
      CREATE TABLE IF NOT EXISTS breeding_records (
        id TEXT PRIMARY KEY,
        female_animal_id TEXT,
        male_animal_id TEXT,
        breeding_date TEXT NOT NULL,                 -- ISO8601
        expected_birth TEXT,                         -- ISO8601
        status TEXT NOT NULL DEFAULT 'Cobertura',    -- derivado de stage
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        mating_start_date TEXT,                      -- ISO8601
        mating_end_date TEXT,                        -- ISO8601
        separation_date TEXT,                        -- ISO8601
        ultrasound_date TEXT,                        -- ISO8601
        ultrasound_result TEXT,
        birth_date TEXT,                             -- ISO8601
        stage TEXT NOT NULL DEFAULT 'encabritamento'
          CHECK (stage IN ('encabritamento','separacao','aguardando_ultrassom','gestacao_confirmada','parto_realizado','falhou')),
        FOREIGN KEY (female_animal_id) REFERENCES animals(id),
        FOREIGN KEY (male_animal_id)   REFERENCES animals(id)
      );
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_male ON breeding_records(male_animal_id);');

    // === Trigger: traduz stage -> status na inserção ===
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS breeding_records_stage_status_trg
      AFTER INSERT ON breeding_records
      BEGIN
        UPDATE breeding_records
          SET status = CASE NEW.stage
            WHEN 'encabritamento'       THEN 'Cobertura'
            WHEN 'separacao'            THEN 'Separação'
            WHEN 'aguardando_ultrassom' THEN 'Aguardando Ultrassom'
            WHEN 'gestacao_confirmada'  THEN 'Gestação Confirmada'
            WHEN 'parto_realizado'      THEN 'Parto Realizado'
            WHEN 'falhou'               THEN 'Falhou'
            ELSE 'Cobertura' END
        WHERE id = NEW.id;
      END;
    ''');

    // === Trigger: traduz stage -> status no update ===
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS breeding_records_stage_status_upd_trg
      AFTER UPDATE OF stage ON breeding_records
      BEGIN
        UPDATE breeding_records
          SET status = CASE NEW.stage
            WHEN 'encabritamento'       THEN 'Cobertura'
            WHEN 'separacao'            THEN 'Separação'
            WHEN 'aguardando_ultrassom' THEN 'Aguardando Ultrassom'
            WHEN 'gestacao_confirmada'  THEN 'Gestação Confirmada'
            WHEN 'parto_realizado'      THEN 'Parto Realizado'
            WHEN 'falhou'               THEN 'Falhou'
            ELSE 'Cobertura' END
        WHERE id = NEW.id;
      END;
    ''');

    // === NOVOS gatilhos: mantêm animals.pregnant/expected_delivery coerentes com o estágio ===
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS breeding_records_pregnancy_ins_trg
      AFTER INSERT ON breeding_records
      BEGIN
        UPDATE animals
        SET
          pregnant = CASE NEW.stage
            WHEN 'gestacao_confirmada' THEN 1
            WHEN 'parto_realizado'     THEN 0
            WHEN 'falhou'              THEN 0
            ELSE pregnant
          END,
          expected_delivery = CASE
            WHEN NEW.stage = 'gestacao_confirmada' THEN COALESCE(NEW.expected_birth, expected_delivery)
            WHEN NEW.stage IN ('parto_realizado','falhou') THEN NULL
            ELSE expected_delivery
          END
        WHERE id = NEW.female_animal_id;
      END;
    ''');

    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS breeding_records_pregnancy_upd_trg
      AFTER UPDATE OF stage, expected_birth ON breeding_records
      BEGIN
        UPDATE animals
        SET
          pregnant = CASE NEW.stage
            WHEN 'gestacao_confirmada' THEN 1
            WHEN 'parto_realizado'     THEN 0
            WHEN 'falhou'              THEN 0
            ELSE pregnant
          END,
          expected_delivery = CASE
            WHEN NEW.stage = 'gestacao_confirmada' THEN COALESCE(NEW.expected_birth, expected_delivery)
            WHEN NEW.stage IN ('parto_realizado','falhou') THEN NULL
            ELSE expected_delivery
          END
        WHERE id = NEW.female_animal_id;
      END;
    ''');

    // -------- financial_accounts (SEM cost_center_id)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS financial_accounts (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL CHECK (type IN ('receita','despesa')),
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        payment_date TEXT,
        status TEXT NOT NULL DEFAULT 'Pendente' CHECK (status IN ('Pendente','Pago','Vencido','Cancelado')),
        payment_method TEXT,
        installments INTEGER,
        installment_number INTEGER,
        parent_id TEXT,
        animal_id TEXT,
        supplier_customer TEXT,
        notes TEXT,
        is_recurring INTEGER DEFAULT 0,
        recurrence_frequency TEXT CHECK (recurrence_frequency IN ('Diária','Semanal','Mensal','Anual')),
        recurrence_end_date TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (parent_id) REFERENCES financial_accounts(id),
        FOREIGN KEY (animal_id) REFERENCES animals(id)
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_due_date ON financial_accounts(due_date);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_status ON financial_accounts(status);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_type ON financial_accounts(type);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_category ON financial_accounts(category);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_animal_id ON financial_accounts(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_parent_id ON financial_accounts(parent_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_finacc_is_recurring ON financial_accounts(is_recurring);');

    // -------- financial_records
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
        FOREIGN KEY (animal_id) REFERENCES animals(id)
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_financial_animal_id ON financial_records(animal_id);');

    // -------- medications
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medications (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        date TEXT NOT NULL,
        next_date TEXT,
        dosage TEXT,
        veterinarian TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        status TEXT NOT NULL DEFAULT 'Agendado',
        applied_date TEXT,
        FOREIGN KEY (animal_id) REFERENCES animals(id)
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_next_date ON medications(next_date);');

    // -------- notes
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
        is_read INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (animal_id) REFERENCES animals(id)
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id);');

    // -------- reports
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reports (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        report_type TEXT NOT NULL CHECK (report_type IN ('Animais','Vacinações','Reprodução','Saúde','Financeiro')),
        parameters TEXT NOT NULL DEFAULT '{}',
        generated_at TEXT NOT NULL DEFAULT (datetime('now')),
        generated_by TEXT
      );
    ''');

    // -------- push_tokens
    await db.execute('''
      CREATE TABLE IF NOT EXISTS push_tokens (
        id TEXT PRIMARY KEY,
        token TEXT NOT NULL UNIQUE,
        platform TEXT,
        device_info TEXT DEFAULT '{}',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');

    // -------- feeding_pens (Baias)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS feeding_pens (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        number TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');

    // -------- feeding_schedules (Tratos)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS feeding_schedules (
        id TEXT PRIMARY KEY,
        pen_id TEXT NOT NULL,
        feed_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        times_per_day INTEGER NOT NULL DEFAULT 1,
        feeding_times TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (pen_id) REFERENCES feeding_pens(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_feeding_schedules_pen ON feeding_schedules(pen_id);');

    // -------- vaccinations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vaccinations (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        vaccine_name TEXT NOT NULL,
        vaccine_type TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,
        applied_date TEXT,
        veterinarian TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'Agendada' CHECK (status IN ('Agendada','Aplicada','Cancelada')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id)
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);');

    // -------- sold_animals (animais vendidos)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sold_animals (
        id TEXT PRIMARY KEY,
        original_animal_id TEXT NOT NULL,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT NOT NULL,
        gender TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        weight REAL NOT NULL,
        location TEXT NOT NULL,
        name_color TEXT,
        category TEXT,
        birth_weight REAL,
        weight_30_days REAL,
        weight_60_days REAL,
        weight_90_days REAL,
        weight_120_days REAL,
        sale_date TEXT NOT NULL,
        sale_price REAL,
        buyer TEXT,
        sale_notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sold_animals_code ON sold_animals(code);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sold_animals_name_color ON sold_animals(name, name_color);');

    // -------- deceased_animals (animais falecidos)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS deceased_animals (
        id TEXT PRIMARY KEY,
        original_animal_id TEXT NOT NULL,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        breed TEXT NOT NULL,
        gender TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        weight REAL NOT NULL,
        location TEXT NOT NULL,
        name_color TEXT,
        category TEXT,
        birth_weight REAL,
        weight_30_days REAL,
        weight_60_days REAL,
        weight_90_days REAL,
        weight_120_days REAL,
        death_date TEXT NOT NULL,
        cause_of_death TEXT,
        death_notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_deceased_animals_code ON deceased_animals(code);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_deceased_animals_name_color ON deceased_animals(name, name_color);');

    // -------- weight_alerts (alertas de pesagem)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS weight_alerts (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        alert_type TEXT NOT NULL,
        due_date TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_weight_alerts_animal_id ON weight_alerts(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_weight_alerts_due_date ON weight_alerts(due_date);');

    // ==========================
    // ====== TRIGGERS ==========
    // ==========================
    Future<void> _makeUpdatedAtTrigger(String table) async {
      // Evita recursão: só roda se updated_at não foi alterado pelo UPDATE original.
      await db.execute('''
        CREATE TRIGGER IF NOT EXISTS ${table}_updated_at
        AFTER UPDATE ON $table
        FOR EACH ROW
        WHEN NEW.updated_at = OLD.updated_at
        BEGIN
          UPDATE $table SET updated_at = datetime('now') WHERE id = OLD.id;
        END;
      ''');
    }

    for (final tbl in [
      'animals',
      'animal_weights',
      'breeding_records',
      'financial_accounts',
      'financial_records',
      'medications',
      'notes',
      'vaccinations',
      'sold_animals',
      'deceased_animals',
      'feeding_pens',
      'feeding_schedules',
      'weight_alerts',
    ]) {
      await _makeUpdatedAtTrigger(tbl);
    }
  }
}
