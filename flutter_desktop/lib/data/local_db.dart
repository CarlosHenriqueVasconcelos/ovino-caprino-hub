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

  static Future<AppDatabase> open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final path = await _resolveDbPath();
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 5,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, v) async => _createAll(db),
        onUpgrade: (db, oldV, newV) async => _migrate(db, oldV, newV),
        onOpen: (db) async {
          await _ensureCoreColumns(db);
          await _ensureTriggers(db);
        },
      ),
    );
    // ignore: avoid_print
    print('SQLite em: $path');
    return AppDatabase(db);
  }

  static Future<String> dbPath() => _resolveDbPath();

  // ============== CREATE DO ZERO ==============
  static Future<void> _createAll(Database db) async {
    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        name_color TEXT,
        category TEXT,
        species TEXT NOT NULL CHECK (species IN ('Ovino','Caprino')),
        breed TEXT NOT NULL,
        gender TEXT NOT NULL CHECK (gender IN ('Macho','Fêmea')),
        birth_date TEXT NOT NULL,
        weight REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Saudável',
        location TEXT,
        last_vaccination TEXT,
        pregnant INTEGER DEFAULT 0,
        expected_delivery TEXT,
        health_issue TEXT,
        birth_weight REAL,
        weight_30_days REAL,
        weight_60_days REAL,
        weight_90_days REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');

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

    await db.execute('''
      CREATE TABLE vaccinations (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        vaccine_name TEXT NOT NULL,
        vaccine_type TEXT,
        scheduled_date TEXT NOT NULL,
        applied_date TEXT,
        status TEXT NOT NULL DEFAULT 'Agendada',
        veterinarian TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        date TEXT NOT NULL,
        next_date TEXT,
        dosage TEXT,
        veterinarian TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE breeding_records (
        id TEXT PRIMARY KEY,
        female_animal_id TEXT NOT NULL,
        male_animal_id TEXT,
        breeding_date TEXT NOT NULL,
        expected_birth TEXT,
        status TEXT DEFAULT 'Cobertura',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (female_animal_id) REFERENCES animals(id) ON DELETE SET NULL,
        FOREIGN KEY (male_animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        animal_id TEXT,
        title TEXT NOT NULL,
        content TEXT,
        category TEXT,
        priority TEXT DEFAULT 'Média',
        date TEXT NOT NULL,
        created_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE financial_records (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL CHECK (type IN ('receita','despesa')),
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        animal_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        report_type TEXT NOT NULL CHECK (
          report_type IN ('Animais','Vacinações','Reprodução','Saúde','Financeiro')
        ),
        parameters TEXT NOT NULL DEFAULT '{}',
        generated_at TEXT NOT NULL,
        generated_by TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE push_tokens (
        id TEXT PRIMARY KEY,
        token TEXT NOT NULL UNIQUE,
        platform TEXT,
        device_info TEXT DEFAULT '{}',
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_code ON animals(code);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_financial_animal_id ON financial_records(animal_id);');

    await _ensureTriggers(db);
  }

  // ============== MIGRAÇÕES ==============
  static Future<void> _migrate(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS animal_weights (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          animal_id TEXT NOT NULL,
          date TEXT NOT NULL,
          weight REAL NOT NULL,
          FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
        );
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_date ON animal_weights(animal_id, date);');
    }
    if (oldV < 3) {
      await _ensureCoreColumns(db);
    }
    if (oldV < 4) {
      await _ensureTriggers(db);
    }
    if (oldV < 5) {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id);');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_financial_animal_id ON financial_records(animal_id);');
      await _safeAddColumn(db, table: 'medications', column: 'updated_at', typeSql: 'TEXT');
    }
  }

  // ============== HELPERS ==============
  static Future<List<String>> _columnsOf(Database db, String table) async {
    final info = await db.rawQuery('PRAGMA table_info($table);');
    return info.map((r) => (r['name'] as String).toLowerCase()).toList();
  }

  static Future<void> _safeAddColumn(
    Database db, {
    required String table,
    required String column,
    required String typeSql,
    String? defaultSql,
    String? backfillSql,
  }) async {
    final cols = await _columnsOf(db, table);
    if (cols.contains(column.toLowerCase())) return;

    final sql = StringBuffer('ALTER TABLE $table ADD COLUMN $column $typeSql');
    if (defaultSql != null) sql.write(' DEFAULT $defaultSql');
    sql.write(';');
    await db.execute(sql.toString());

    if (backfillSql != null && backfillSql.trim().isNotEmpty) {
      await db.execute(backfillSql);
    }
  }

  static Future<void> _ensureCoreColumns(Database db) async {
    await _safeAddColumn(db, table: 'animals', column: 'created_at', typeSql: 'TEXT',
        backfillSql: "UPDATE animals SET created_at = COALESCE(created_at, datetime('now'));");
    await _safeAddColumn(db, table: 'animals', column: 'updated_at', typeSql: 'TEXT',
        backfillSql: "UPDATE animals SET updated_at = COALESCE(updated_at, datetime('now'));");
    await _safeAddColumn(db, table: 'animals', column: 'name_color', typeSql: 'TEXT');
    await _safeAddColumn(db, table: 'animals', column: 'category', typeSql: 'TEXT');
    await _safeAddColumn(db, table: 'animals', column: 'birth_weight', typeSql: 'REAL');
    await _safeAddColumn(db, table: 'animals', column: 'weight_30_days', typeSql: 'REAL');
    await _safeAddColumn(db, table: 'animals', column: 'weight_60_days', typeSql: 'REAL');
    await _safeAddColumn(db, table: 'animals', column: 'weight_90_days', typeSql: 'REAL');
    await _safeAddColumn(db, table: 'animals', column: 'last_vaccination', typeSql: 'TEXT');
    await _safeAddColumn(db, table: 'animals', column: 'expected_delivery', typeSql: 'TEXT');
    await _safeAddColumn(db, table: 'animals', column: 'health_issue', typeSql: 'TEXT');
    await _safeAddColumn(db, table: 'animals', column: 'pregnant', typeSql: 'INTEGER', defaultSql: '0',
        backfillSql: "UPDATE animals SET pregnant = COALESCE(pregnant, 0);");
    await _safeAddColumn(db, table: 'animals', column: 'location', typeSql: 'TEXT');

    await _safeAddColumn(db, table: 'breeding_records', column: 'created_at', typeSql: 'TEXT',
        backfillSql: "UPDATE breeding_records SET created_at = COALESCE(created_at, datetime('now'));");
    await _safeAddColumn(db, table: 'breeding_records', column: 'updated_at', typeSql: 'TEXT',
        backfillSql: "UPDATE breeding_records SET updated_at = COALESCE(updated_at, datetime('now'));");

    await _safeAddColumn(db, table: 'financial_records', column: 'created_at', typeSql: 'TEXT',
        backfillSql: "UPDATE financial_records SET created_at = COALESCE(created_at, datetime('now'));");
    await _safeAddColumn(db, table: 'financial_records', column: 'updated_at', typeSql: 'TEXT',
        backfillSql: "UPDATE financial_records SET updated_at = COALESCE(updated_at, datetime('now'));");

    await _safeAddColumn(db, table: 'medications', column: 'created_at', typeSql: 'TEXT',
        backfillSql: "UPDATE medications SET created_at = COALESCE(created_at, datetime('now'));");
    await _safeAddColumn(db, table: 'medications', column: 'updated_at', typeSql: 'TEXT',
        backfillSql: "UPDATE medications SET updated_at = COALESCE(updated_at, datetime('now'));");

    await _safeAddColumn(db, table: 'notes', column: 'created_at', typeSql: 'TEXT',
        backfillSql: "UPDATE notes SET created_at = COALESCE(created_at, datetime('now'));");
    await _safeAddColumn(db, table: 'notes', column: 'updated_at', typeSql: 'TEXT',
        backfillSql: "UPDATE notes SET updated_at = COALESCE(updated_at, datetime('now'));");

    await _safeAddColumn(db, table: 'vaccinations', column: 'created_at', typeSql: 'TEXT',
        backfillSql: "UPDATE vaccinations SET created_at = COALESCE(created_at, datetime('now'));");
    await _safeAddColumn(db, table: 'vaccinations', column: 'updated_at', typeSql: 'TEXT',
        backfillSql: "UPDATE vaccinations SET updated_at = COALESCE(updated_at, datetime('now'));");
  }

  static Future<void> _ensureTriggers(Database db) async {
    for (final tbl in [
      'animals',
      'breeding_records',
      'financial_records',
      'medications',
      'notes',
      'vaccinations',
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
