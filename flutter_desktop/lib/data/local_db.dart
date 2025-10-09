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

  /// Abre o SQLite local. **Sem migrações** — apenas criação quando não existir.
  static Future<AppDatabase> open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final path = await _resolveDbPath();
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        // Pode deixar 1. Se já existir um banco antigo, apague o arquivo para recriar.
        version: 1,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, v) async => _createAll(db),
      ),
    );
    // ignore: avoid_print
    print('SQLite em: $path');
    return AppDatabase(db);
  }

  static Future<String> dbPath() => _resolveDbPath();

  /// Criação completa do schema (alinhado ao Supabase), usando tipos SQLite:
  /// - TEXT p/ uuid/timestamp/date
  /// - REAL p/ numeric
  /// - INTEGER p/ boolean (0/1)
  static Future<void> _createAll(Database db) async {
    // =========================
    // TABELA: animals
    // =========================
    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        species TEXT NOT NULL CHECK (species IN ('Ovino','Caprino')),
        breed TEXT NOT NULL,
        gender TEXT NOT NULL CHECK (gender IN ('Macho','Fêmea')),
        birth_date TEXT NOT NULL,              -- 'YYYY-MM-DD'
        weight REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Saudável',
        location TEXT NOT NULL DEFAULT '',
        last_vaccination TEXT,                 -- 'YYYY-MM-DD'
        pregnant INTEGER DEFAULT 0,            -- 0/1
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

    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_code ON animals(code);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);');

    // =========================
    // TABELA: animal_weights
    // =========================
    await db.execute('''
      CREATE TABLE animal_weights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id TEXT NOT NULL,
        date TEXT NOT NULL,
        weight REAL NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_date ON animal_weights(animal_id, date);');

    // =========================
    // TABELA: vaccinations
    // =========================
    await db.execute('''
      CREATE TABLE vaccinations (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        vaccine_name TEXT NOT NULL,
        vaccine_type TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,          -- 'YYYY-MM-DD'
        applied_date TEXT,                     -- 'YYYY-MM-DD'
        veterinarian TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'Agendada' CHECK (status IN ('Agendada','Aplicada','Cancelada')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);');

    // =========================
    // TABELA: medications
    // =========================
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        date TEXT NOT NULL,                    -- 'YYYY-MM-DD'
        next_date TEXT,                        -- 'YYYY-MM-DD'
        dosage TEXT,
        veterinarian TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        status TEXT NOT NULL DEFAULT 'Agendado',
        applied_date TEXT,                     -- 'YYYY-MM-DD'
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_next_date ON medications(next_date);');

    // =========================
    // TABELA: breeding_records
    // =========================
    await db.execute('''
      CREATE TABLE breeding_records (
        id TEXT PRIMARY KEY,
        female_animal_id TEXT,
        male_animal_id TEXT,
        breeding_date TEXT NOT NULL,           -- 'YYYY-MM-DD'
        expected_birth TEXT,                   -- 'YYYY-MM-DD'
        status TEXT NOT NULL DEFAULT 'Cobertura',
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        -- campos multiestágio
        mating_start_date TEXT,                -- 'YYYY-MM-DD'
        mating_end_date TEXT,                  -- 'YYYY-MM-DD'
        separation_date TEXT,                  -- 'YYYY-MM-DD'
        ultrasound_date TEXT,                  -- 'YYYY-MM-DD'
        ultrasound_result TEXT,
        birth_date TEXT,                       -- 'YYYY-MM-DD'
        stage TEXT DEFAULT 'Encabritamento',
        FOREIGN KEY (female_animal_id) REFERENCES animals(id) ON DELETE SET NULL,
        FOREIGN KEY (male_animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_male ON breeding_records(male_animal_id);');

    // =========================
    // TABELA: notes
    // =========================
    await db.execute('''
      CREATE TABLE notes (
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
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id);');

    // =========================
    // TABELA: financial_records
    // =========================
    await db.execute('''
      CREATE TABLE financial_records (
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

    // =========================
    // TABELA: reports
    // =========================
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        report_type TEXT NOT NULL CHECK (report_type IN ('Animais','Vacinações','Reprodução','Saúde','Financeiro')),
        parameters TEXT NOT NULL DEFAULT '{}',
        generated_at TEXT NOT NULL DEFAULT (datetime('now')),
        generated_by TEXT
      );
    ''');

    // =========================
    // TABELA: push_tokens
    // =========================
    await db.execute('''
      CREATE TABLE push_tokens (
        id TEXT PRIMARY KEY,
        token TEXT NOT NULL UNIQUE,
        platform TEXT,
        device_info TEXT NOT NULL DEFAULT '{}',
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');

    // ========== TRIGGERS updated_at ==========
    for (final tbl in [
      'animals',
      'vaccinations',
      'medications',
      'breeding_records',
      'notes',
      'financial_records',
    ]) {
      await db.execute('''
        CREATE TRIGGER IF NOT EXISTS ${tbl}_updated_at
        AFTER UPDATE ON $tbl
        FOR EACH ROW
        BEGIN
          UPDATE $tbl SET updated_at = datetime('now') WHERE id = OLD.id;
        END;
      ''');
    }
  }
}
