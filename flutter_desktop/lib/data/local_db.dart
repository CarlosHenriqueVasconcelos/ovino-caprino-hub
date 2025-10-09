// lib/data/local_db.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/animal.dart'; // usado no DatabaseService para mapear Animal

class AppDatabase {
  final Database db;
  AppDatabase(this.db);

  static const int _dbVersion = 10; // bump destrutivo (drop + create)

  static Future<String> _resolveDbPath([String fileName = 'fazenda.db']) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'FazendaDB'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return p.join(dir.path, fileName);
  }

  static Future<AppDatabase> open() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final path = await _resolveDbPath();
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
          await db.execute('PRAGMA journal_mode = WAL;');
          await db.execute('PRAGMA synchronous = NORMAL;');
        },
        onCreate: (db, v) async => _createAll(db),
        // MIGRAÇÃO DESTRUTIVA: derruba tudo e recria aderente ao schema do Supabase
        onUpgrade: (db, oldV, newV) async {
          await _dropAllKnownTables(db);
          await _createAll(db);
        },
      ),
    );
    // ignore: avoid_print
    print('SQLite em: $path');
    return AppDatabase(db);
  }

  static Future<void> destroyAndRecreate() async {
    final path = await _resolveDbPath();
    if (await File(path).exists()) {
      await databaseFactory.deleteDatabase(path);
    }
    await open();
  }

  static Future<String> dbPath() => _resolveDbPath();

  // ==================== CREATE (espelhado ao Supabase) ====================
  static Future<void> _createAll(Database db) async {
    // ANIMALS
    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        species TEXT NOT NULL CHECK (species IN ('Ovino','Caprino')),
        breed TEXT NOT NULL,
        gender TEXT NOT NULL CHECK (gender IN ('Macho','Fêmea')),
        birth_date TEXT NOT NULL,           -- DATE
        weight REAL NOT NULL,               -- NUMERIC
        status TEXT NOT NULL DEFAULT 'Saudável',
        location TEXT NOT NULL,             -- NOT NULL (como no Supabase)
        last_vaccination TEXT,              -- DATE
        pregnant INTEGER DEFAULT 0,         -- boolean
        expected_delivery TEXT,             -- DATE
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
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);');

    // VACCINATIONS
    await db.execute('''
      CREATE TABLE vaccinations (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        vaccine_name TEXT NOT NULL,
        vaccine_type TEXT NOT NULL,
        scheduled_date TEXT NOT NULL,       -- DATE
        applied_date TEXT,                  -- DATE
        veterinarian TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'Agendada'
          CHECK (status IN ('Agendada','Aplicada','Cancelada')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_status ON vaccinations(status);');

    // MEDICATIONS
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        date TEXT NOT NULL,                 -- DATE
        next_date TEXT,                     -- DATE
        dosage TEXT,
        veterinarian TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        status TEXT NOT NULL DEFAULT 'Agendado',
        applied_date TEXT,                  -- DATE
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_next_date ON medications(next_date);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_status ON medications(status);');

    // BREEDING_RECORDS (multi-estágio)
    await db.execute('''
      CREATE TABLE breeding_records (
        id TEXT PRIMARY KEY,
        female_animal_id TEXT,
        male_animal_id TEXT,
        breeding_date TEXT NOT NULL,        -- DATE
        expected_birth TEXT,                -- DATE
        status TEXT NOT NULL DEFAULT 'Cobertura',
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        mating_start_date TEXT,             -- DATE
        mating_end_date TEXT,               -- DATE
        separation_date TEXT,               -- DATE
        ultrasound_date TEXT,               -- DATE
        ultrasound_result TEXT,
        birth_date TEXT,                    -- DATE
        stage TEXT DEFAULT 'Encabritamento',
        FOREIGN KEY (female_animal_id) REFERENCES animals(id) ON DELETE SET NULL,
        FOREIGN KEY (male_animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_breeding_male ON breeding_records(male_animal_id);');

    // NOTES
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

    // FINANCIAL_RECORDS
    await db.execute('''
      CREATE TABLE financial_records (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL CHECK (type IN ('receita','despesa')),
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,               -- NUMERIC
        date TEXT NOT NULL DEFAULT (date('now')),
        animal_id TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (animal_id) REFERENCES animals(id) ON DELETE SET NULL
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_financial_animal_id ON financial_records(animal_id);');

    // REPORTS
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        report_type TEXT NOT NULL CHECK (report_type IN ('Animais','Vacinações','Reprodução','Saúde','Financeiro')),
        parameters TEXT NOT NULL DEFAULT '{}', -- JSONB no Supabase
        generated_at TEXT NOT NULL DEFAULT (datetime('now')),
        generated_by TEXT
      );
    ''');

    // PUSH_TOKENS
    await db.execute('''
      CREATE TABLE push_tokens (
        id TEXT PRIMARY KEY,
        token TEXT NOT NULL UNIQUE,
        platform TEXT,
        device_info TEXT DEFAULT '{}',      -- JSONB no Supabase
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');

    await _createUpdateTriggers(db);
  }

  static Future<void> _dropAllKnownTables(Database db) async {
    final tables = <String>[
      'animal_weights',
      'vaccinations',
      'medications',
      'breeding_records',
      'notes',
      'financial_records',
      'reports',
      'push_tokens',
      'animals',
    ];
    for (final t in tables) {
      await db.execute('DROP TABLE IF EXISTS $t;');
    }
  }

  static Future<void> _createUpdateTriggers(Database db) async {
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

/// ======================================================================
/// Shim compatível: mantém a API estática que você já usava.
/// ======================================================================
class DatabaseService {
  // ---------- ANIMAIS ----------
  static Future<List<Animal>> getAnimals() async {
    final app = await AppDatabase.open();
    final rows = await app.db.query('animals', orderBy: 'name COLLATE NOCASE');
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  static Future<Animal> createAnimal(Map<String, dynamic> animal) async {
    final app = await AppDatabase.open();
    await app.db.insert('animals', animal);
    return Animal.fromMap(animal);
  }

  static Future<Animal> updateAnimal(String id, Map<String, dynamic> animal) async {
    final app = await AppDatabase.open();
    await app.db.update('animals', animal, where: 'id = ?', whereArgs: [id]);
    return Animal.fromMap(animal);
  }

  static Future<void> deleteAnimal(String id) async {
    final app = await AppDatabase.open();
    await app.db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- VACINAÇÕES ----------
  static Future<List<Map<String, dynamic>>> getVaccinations() async {
    final app = await AppDatabase.open();
    return await app.db.query('vaccinations');
  }

  static Future<void> createVaccination(Map<String, dynamic> vaccination) async {
    final app = await AppDatabase.open();
    await app.db.insert('vaccinations', vaccination);
  }

  // ---------- MEDICAMENTOS ----------
  static Future<List<Map<String, dynamic>>> getMedications() async {
    final app = await AppDatabase.open();
    return await app.db.query('medications');
  }

  static Future<void> createMedication(Map<String, dynamic> medication) async {
    final app = await AppDatabase.open();
    await app.db.insert('medications', medication);
  }

  // ---------- REPRODUÇÃO ----------
  static Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    final app = await AppDatabase.open();
    return await app.db.query('breeding_records');
  }

  static Future<void> createBreedingRecord(Map<String, dynamic> record) async {
    final app = await AppDatabase.open();
    await app.db.insert('breeding_records', record);
  }

  // ---------- ANOTAÇÕES ----------
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final app = await AppDatabase.open();
    return await app.db.query('notes');
  }

  static Future<void> createNote(Map<String, dynamic> note) async {
    final app = await AppDatabase.open();
    await app.db.insert('notes', note);
  }

  // ---------- FINANCEIRO ----------
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final app = await AppDatabase.open();
    return await app.db.query('financial_records');
  }

  static Future<void> createFinancialRecord(Map<String, dynamic> record) async {
    final app = await AppDatabase.open();
    await app.db.insert('financial_records', record);
  }

  // ---------- ESTATÍSTICAS ----------
  static Future<Map<String, dynamic>> getStats() async {
    final app = await AppDatabase.open();
    final db = app.db;

    Future<int> _count(String sql, [List<Object?>? args]) async {
      final r = await db.rawQuery(sql, args);
      if (r.isEmpty) return 0;
      final v = r.first.values.first;
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final totalAnimals = await _count('SELECT COUNT(*) FROM animals');
    final healthy = await _count('SELECT COUNT(*) FROM animals WHERE status = ?', ['Saudável']);
    final pregnant = await _count('SELECT COUNT(*) FROM animals WHERE pregnant = 1');
    final underTreatment = await _count('SELECT COUNT(*) FROM animals WHERE status = ?', ['Em tratamento']);
    final maleReproducers = await _count('SELECT COUNT(*) FROM animals WHERE category = ?', ['Macho Reprodutor']);
    final maleLambs = await _count('SELECT COUNT(*) FROM animals WHERE category = ?', ['Macho Borrego']);
    final femaleLambs = await _count('SELECT COUNT(*) FROM animals WHERE category = ?', ['Fêmea Borrega']);
    final femaleReproducers = await _count('SELECT COUNT(*) FROM animals WHERE category = ?', ['Fêmea Reprodutora']);

    final revenueResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_records WHERE type = ?',
      ['receita'],
    );
    final revenueRaw = revenueResult.isNotEmpty ? revenueResult.first['total'] : null;
    final revenue = (revenueRaw is num) ? revenueRaw.toDouble() : 0.0;

    final avgWeightResult = await db.rawQuery('SELECT AVG(weight) as avg FROM animals');
    final avgRaw = avgWeightResult.isNotEmpty ? avgWeightResult.first['avg'] : null;
    final avgWeight = (avgRaw is num) ? avgRaw.toDouble() : 0.0;

    return {
      'totalAnimals': totalAnimals,
      'healthy': healthy,
      'pregnant': pregnant,
      'underTreatment': underTreatment,
      'maleReproducers': maleReproducers,
      'maleLambs': maleLambs,
      'femaleLambs': femaleLambs,
      'femaleReproducers': femaleReproducers,
      'revenue': revenue,
      'avgWeight': avgWeight,
      'vaccinesThisMonth': 0,
      'birthsThisMonth': 0,
    };
  }

  // ---------- BACKUP / UTIL ----------
  static Future<void> syncWithSupabase(Future<void> Function() onSync) async {
    await onSync();
  }

  static Future<void> clearAllData() async {
    final app = await AppDatabase.open();
    for (final t in [
      'vaccinations',
      'medications',
      'breeding_records',
      'notes',
      'financial_records',
      'reports',
      'animals',
    ]) {
      await app.db.delete(t);
    }
  }
}
