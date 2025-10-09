import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/animal.dart'; // para mapear Animal no shim DatabaseService

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
        // ⬆️ bump para disparar migrations
        version: 7,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON;'),
        onCreate: (db, v) async => _createAll(db),
        onUpgrade: (db, oldV, newV) async => _migrate(db, oldV, newV),
        onOpen: (db) async {
          // Garantias idempotentes
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
        -- 🔹 colunas novas já previstas na criação
        status TEXT NOT NULL DEFAULT 'Agendado',
        applied_date TEXT,
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
    await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_next_date ON medications(next_date);');

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
    // v6: garante novas colunas de medications
    if (oldV < 6) {
      await _safeAddColumn(
        db,
        table: 'medications',
        column: 'status',
        typeSql: 'TEXT',
        defaultSql: "'Agendado'",
        backfillSql: "UPDATE medications SET status = COALESCE(status, 'Agendado');",
      );
      await _safeAddColumn(
        db,
        table: 'medications',
        column: 'applied_date',
        typeSql: 'TEXT',
      );
      await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_next_date ON medications(next_date);');
    }
    // v7: reforço idempotente
    if (oldV < 7) {
      await _safeAddColumn(
        db,
        table: 'medications',
        column: 'status',
        typeSql: 'TEXT',
        defaultSql: "'Agendado'",
        backfillSql: "UPDATE medications SET status = COALESCE(status, 'Agendado');",
      );
      await _safeAddColumn(
        db,
        table: 'medications',
        column: 'applied_date',
        typeSql: 'TEXT',
      );
      await db.execute('CREATE INDEX IF NOT EXISTS idx_medications_next_date ON medications(next_date);');
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
    // 🔸 novas colunas garantidas mesmo sem bump
    await _safeAddColumn(db, table: 'medications', column: 'status', typeSql: 'TEXT',
        defaultSql: "'Agendado'",
        backfillSql: "UPDATE medications SET status = COALESCE(status, 'Agendado');");
    await _safeAddColumn(db, table: 'medications', column: 'applied_date', typeSql: 'TEXT');

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

/// ======================================================================
/// BACKWARDS-COMPAT: Classe "shim" que mantém a API antiga (estática)
/// redirecionando para o AppDatabase por baixo. Nada do que você usava
/// foi removido.
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
    final healthy =
        await _count('SELECT COUNT(*) FROM animals WHERE status = ?', ['Saudável']);
    final pregnant =
        await _count('SELECT COUNT(*) FROM animals WHERE pregnant = 1');
    final underTreatment =
        await _count('SELECT COUNT(*) FROM animals WHERE status = ?', ['Em tratamento']);
    final maleReproducers =
        await _count('SELECT COUNT(*) FROM animals WHERE category = ?', ['Macho Reprodutor']);
    final maleLambs =
        await _count('SELECT COUNT(*) FROM animals WHERE category = ?', ['Macho Borrego']);
    final femaleLambs =
        await _count('SELECT COUNT(*) FROM animals WHERE category = ?', ['Fêmea Borrega']);
    final femaleReproducers =
        await _count('SELECT COUNT(*) FROM animals WHERE category = ?', ['Fêmea Reprodutora']);

    final revenueResult =
        await db.rawQuery('SELECT SUM(amount) as total FROM financial_records WHERE type = ?', ['receita']);
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
    await app.db.delete('animals');
    await app.db.delete('vaccinations');
    await app.db.delete('medications');
    await app.db.delete('breeding_records');
    await app.db.delete('notes');
    await app.db.delete('financial_records');
    await app.db.delete('reports');
  }
}
