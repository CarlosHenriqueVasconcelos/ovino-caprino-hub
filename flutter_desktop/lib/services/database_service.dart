import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/animal.dart';

class DatabaseService {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'bego_ovino_caprino.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Tabela de animais
    await db.execute('''
      CREATE TABLE animals (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        name_color TEXT,
        category TEXT,
        species TEXT NOT NULL,
        breed TEXT NOT NULL,
        gender TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        weight REAL NOT NULL,
        status TEXT NOT NULL,
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
      )
    ''');

    // Tabela de vacinações
    await db.execute('''
      CREATE TABLE vaccinations (
        id TEXT PRIMARY KEY,
        animal_id TEXT NOT NULL,
        vaccine_name TEXT NOT NULL,
        date TEXT NOT NULL,
        next_date TEXT,
        veterinarian TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabela de medicamentos
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
        created_at TEXT NOT NULL
      )
    ''');

    // Tabela de reprodução
    await db.execute('''
      CREATE TABLE breeding_records (
        id TEXT PRIMARY KEY,
        female_id TEXT NOT NULL,
        male_id TEXT NOT NULL,
        breeding_date TEXT NOT NULL,
        expected_delivery TEXT,
        actual_delivery TEXT,
        offspring_count INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabela de anotações
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        animal_id TEXT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabela de registros financeiros
    await db.execute('''
      CREATE TABLE financial_records (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        animal_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabela de relatórios
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ==================== ANIMAIS ====================
  
  static Future<List<Animal>> getAnimals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('animals');
    return List.generate(maps.length, (i) => Animal.fromMap(maps[i]));
  }

  static Future<Animal> createAnimal(Map<String, dynamic> animal) async {
    final db = await database;
    await db.insert('animals', animal);
    return Animal.fromMap(animal);
  }

  static Future<Animal> updateAnimal(String id, Map<String, dynamic> animal) async {
    final db = await database;
    await db.update(
      'animals',
      animal,
      where: 'id = ?',
      whereArgs: [id],
    );
    return Animal.fromMap(animal);
  }

  static Future<void> deleteAnimal(String id) async {
    final db = await database;
    await db.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== VACINAÇÕES ====================
  
  static Future<List<Map<String, dynamic>>> getVaccinations() async {
    final db = await database;
    return await db.query('vaccinations');
  }

  static Future<void> createVaccination(Map<String, dynamic> vaccination) async {
    final db = await database;
    await db.insert('vaccinations', vaccination);
  }

  // ==================== MEDICAMENTOS ====================
  
  static Future<List<Map<String, dynamic>>> getMedications() async {
    final db = await database;
    return await db.query('medications');
  }

  static Future<void> createMedication(Map<String, dynamic> medication) async {
    final db = await database;
    await db.insert('medications', medication);
  }

  // ==================== REPRODUÇÃO ====================
  
  static Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    final db = await database;
    return await db.query('breeding_records');
  }

  static Future<void> createBreedingRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert('breeding_records', record);
  }

  // ==================== ANOTAÇÕES ====================
  
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  static Future<void> createNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.insert('notes', note);
  }

  // ==================== FINANCEIRO ====================
  
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final db = await database;
    return await db.query('financial_records');
  }

  static Future<void> createFinancialRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert('financial_records', record);
  }

  // ==================== ESTATÍSTICAS ====================
  
  static Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    
    final totalAnimals = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals')
    ) ?? 0;
    
    final healthy = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals WHERE status = ?', ['Saudável'])
    ) ?? 0;
    
    final pregnant = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals WHERE pregnant = 1')
    ) ?? 0;
    
    final underTreatment = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals WHERE status = ?', ['Em tratamento'])
    ) ?? 0;
    
    final maleReproducers = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals WHERE category = ?', ['Macho Reprodutor'])
    ) ?? 0;
    
    final maleLambs = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals WHERE category = ?', ['Macho Borrego'])
    ) ?? 0;
    
    final femaleLambs = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals WHERE category = ?', ['Fêmea Borrega'])
    ) ?? 0;
    
    final femaleReproducers = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM animals WHERE category = ?', ['Fêmea Reprodutora'])
    ) ?? 0;
    
    final revenueResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM financial_records WHERE type = ?',
      ['receita']
    );
    
    final revenue = (revenueResult.first['total'] as num?)?.toDouble() ?? 0.0;
    
    final avgWeightResult = await db.rawQuery(
      'SELECT AVG(weight) as avg FROM animals'
    );
    
    final avgWeight = (avgWeightResult.first['avg'] as num?)?.toDouble() ?? 0.0;

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

  // ==================== BACKUP ====================
  
  static Future<void> syncWithSupabase(Function onSync) async {
    // Esta função será chamada manualmente pelo botão de backup
    await onSync();
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('animals');
    await db.delete('vaccinations');
    await db.delete('medications');
    await db.delete('breeding_records');
    await db.delete('notes');
    await db.delete('financial_records');
    await db.delete('reports');
  }
}
