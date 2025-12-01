// lib/data/local_db.dart
// SQLite local espelhado do Supabase (Out/2025) — versão sem Cost Centers & Budgets
// Mapas de tipos: uuid→TEXT | timestamptz→TEXT(ISO8601) | date→TEXT(YYYY-MM-DD) | numeric→REAL | boolean→INTEGER(0/1)
//
// Observações:
// - Chaves estrangeiras habilitadas (PRAGMA foreign_keys = ON)
// - Triggers de updated_at (com cláusula WHEN para evitar recursã
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_factory.dart';
import '../services/migration_service.dart';

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

  /// Abre o SQLite local, habilita foreign_keys e executa migrações.
  /// Usa factory dinâmica:
  /// - Desktop: sqflite_common_ffi
  /// - Mobile:  sqflite nativo
  static Future<AppDatabase> open() async {
    // Decide a factory correta para a plataforma atual
    final factory = await getDatabaseFactory();

    final path = await _resolveDbPath();
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        // mantenha 1; se mudar o schema, use MigrationService ou apague o .db
        version: 1,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, v) async => _createAll(db),
        onOpen: (db) async {
          // Executar migrações após abrir o banco
          await MigrationService.runMigrations(db);
        },
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
        weight_120_days REAL,
        year INTEGER,
        lote TEXT,
        mother_id TEXT,
        father_id TEXT
      );
    ''');
    // ============ FASE 4: ÍNDICES COMPOSTOS OTIMIZADOS ============
    
    // Índices simples básicos
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_code ON animals(code);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_category ON animals(category);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_gender ON animals(gender);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_pregnant ON animals(pregnant);');
    
    // Índices para buscas case-insensitive
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_name ON animals(name COLLATE NOCASE);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_code_nocase ON animals(code COLLATE NOCASE);');
    
    // Índices compostos para queries filtradas (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_category_gender ON animals(category, gender);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_status_category ON animals(status, category);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_pregnant_delivery ON animals(pregnant, expected_delivery);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_category_birth ON animals(category, birth_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_birth_date ON animals(birth_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_mother_id ON animals(mother_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_father_id ON animals(father_id);');
    
    // Índice para validação de unicidade (name + color + category + lote)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_identity ON animals(name_color, category, lote);');
    
    // Índice para busca por nome e cor
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_name_color ON animals(name COLLATE NOCASE, name_color);');

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
    // Índices compostos para peso (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_date ON animal_weights(animal_id, date DESC);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_milestone ON animal_weights(animal_id, milestone);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_animal_weights_date ON animal_weights(date);');

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

    // Índices compostos para reprodução (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_breeding_male ON breeding_records(male_animal_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_breeding_stage ON breeding_records(stage);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_breeding_status ON breeding_records(status);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_breeding_female_status ON breeding_records(female_animal_id, status);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_breeding_male_status ON breeding_records(male_animal_id, status);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_breeding_stage_status ON breeding_records(stage, status);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_breeding_expected_birth ON breeding_records(expected_birth);');

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

    // === Gatilhos: mantêm animals.pregnant/expected_delivery coerentes com o estágio ===
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
    // Índices simples para financeiro
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_due_date ON financial_accounts(due_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_status ON financial_accounts(status);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_type ON financial_accounts(type);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_category ON financial_accounts(category);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_animal_id ON financial_accounts(animal_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_parent_id ON financial_accounts(parent_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_is_recurring ON financial_accounts(is_recurring);');
    
    // Índices compostos para financeiro (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_type_status_due ON financial_accounts(type, status, due_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_status_due ON financial_accounts(status, due_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_finacc_type_category ON financial_accounts(type, category);');

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
    // Índices para financial_records (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_financial_animal_id ON financial_records(animal_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_financial_type_date ON financial_records(type, date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_financial_date ON financial_records(date);');

    // -------- pharmacy_stock
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pharmacy_stock (
        id TEXT PRIMARY KEY,
        medication_name TEXT NOT NULL,
        medication_type TEXT NOT NULL,
        unit_of_measure TEXT NOT NULL,
        quantity_per_unit REAL,
        total_quantity REAL NOT NULL DEFAULT 0,
        min_stock_alert REAL,
        expiration_date TEXT,
        is_opened INTEGER DEFAULT 0,
        opened_quantity REAL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');
    // Índices para pharmacy_stock (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_name ON pharmacy_stock(medication_name COLLATE NOCASE);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_expiration ON pharmacy_stock(expiration_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_type ON pharmacy_stock(medication_type);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_type_name ON pharmacy_stock(medication_type, medication_name);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_opened ON pharmacy_stock(is_opened, expiration_date);');

    // -------- pharmacy_stock_movements
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pharmacy_stock_movements (
        id TEXT PRIMARY KEY,
        pharmacy_stock_id TEXT NOT NULL,
        medication_id TEXT,
        movement_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        reason TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (pharmacy_stock_id) REFERENCES pharmacy_stock(id) ON DELETE CASCADE,
        FOREIGN KEY (medication_id) REFERENCES medications(id)
      );
    ''');
    // Índices para pharmacy_stock_movements (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_movements_stock_id ON pharmacy_stock_movements(pharmacy_stock_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_movements_medication_id ON pharmacy_stock_movements(medication_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_movements_stock_type ON pharmacy_stock_movements(pharmacy_stock_id, movement_type);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_movements_created ON pharmacy_stock_movements(created_at DESC);');

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
        pharmacy_stock_id TEXT,
        quantity_used REAL,
        FOREIGN KEY (animal_id) REFERENCES animals(id),
        FOREIGN KEY (pharmacy_stock_id) REFERENCES pharmacy_stock(id)
      );
    ''');
    // Índices simples para medications
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_next_date ON medications(next_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_pharmacy_stock ON medications(pharmacy_stock_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_status ON medications(status);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_date ON medications(date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_applied_date ON medications(applied_date);');
    
    // Índices compostos para medications (FASE 4) - para alertas e dashboard
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_animal_status ON medications(animal_id, status, date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_status_date ON medications(status, date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_medications_status_next ON medications(status, next_date);');

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
    // Índices simples para notes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(category);');
    await db
        .execute('CREATE INDEX IF NOT EXISTS idx_notes_date ON notes(date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_is_read ON notes(is_read);');
    
    // Índices compostos para notes (FASE 4) - para filtros de notas não lidas
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_animal_read ON notes(animal_id, is_read);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_category_priority_read ON notes(category, priority, is_read);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notes_read_date ON notes(is_read, date DESC);');

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
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_feeding_schedules_pen ON feeding_schedules(pen_id);');

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
    // Índices simples para vaccinations
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_status ON vaccinations(status);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_scheduled_date ON vaccinations(scheduled_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_applied_date ON vaccinations(applied_date);');
    
    // Índices compostos para vaccinations (FASE 4) - para alertas e dashboard
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_status ON vaccinations(animal_id, status, scheduled_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_status_scheduled ON vaccinations(status, scheduled_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_type_status ON vaccinations(vaccine_type, status);');

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
        year INTEGER,
        lote TEXT,
        mother_id TEXT,
        father_id TEXT,
        sale_date TEXT NOT NULL,
        sale_price REAL,
        buyer TEXT,
        sale_notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');
    // Índices para sold_animals (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sold_animals_code ON sold_animals(code COLLATE NOCASE);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sold_animals_name ON sold_animals(name COLLATE NOCASE);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sold_animals_name_color ON sold_animals(name COLLATE NOCASE, name_color);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sold_animals_sale_date ON sold_animals(sale_date DESC);');

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
        year INTEGER,
        lote TEXT,
        mother_id TEXT,
        father_id TEXT,
        death_date TEXT NOT NULL,
        cause_of_death TEXT,
        death_notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');
    // Índices para deceased_animals (FASE 4)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_deceased_animals_code ON deceased_animals(code COLLATE NOCASE);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_deceased_animals_name ON deceased_animals(name COLLATE NOCASE);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_deceased_animals_name_color ON deceased_animals(name COLLATE NOCASE, name_color);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_deceased_animals_death_date ON deceased_animals(death_date DESC);');

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
    // Índices simples para weight_alerts
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_weight_alerts_animal_id ON weight_alerts(animal_id);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_weight_alerts_due_date ON weight_alerts(due_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_weight_alerts_completed ON weight_alerts(completed);');
    
    // Índices compostos para weight_alerts (FASE 4) - para alertas pendentes
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_weight_alerts_completed_due ON weight_alerts(completed, due_date);');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_weight_alerts_animal_completed ON weight_alerts(animal_id, completed);');

    // ==========================
    // ====== TRIGGERS ==========
    // ==========================
    Future<void> makeUpdatedAtTrigger(String table) async {
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
      await makeUpdatedAtTrigger(tbl);
    }
  }
}
