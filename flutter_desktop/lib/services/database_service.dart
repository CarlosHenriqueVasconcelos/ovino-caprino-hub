// flutter_desktop/lib/services/database_service.dart
//
// Camada de COMPATIBILIDADE com o serviço antigo.
// Mantém a mesma API estática (getAnimals, createAnimal, etc.)
// mas delega para o AppDatabase (local_db.dart) novo.

import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite/sqflite.dart' as sqflite show Sqflite;
import 'package:path_provider/path_provider.dart';

import '../models/animal.dart';
import '../data/local_db.dart';

class DatabaseService {
  static AppDatabase? _app;
  static Future<ffi.Database> get database async {
    _app ??= await AppDatabase.open();
    return _app!.db;
  }

  /// Caminho atual do DB (útil para logs ou tela de config)
  static Future<String> dbPath() => AppDatabase.dbPath();

  // ======================================================
  // === API ESTÁTICA COMPATÍVEL COM O ARQUIVO ANTIGO  ===
  // ======================================================

  // --------- ANIMAIS ---------
  static Future<List<Animal>> getAnimals() async {
    final db = await database;
    final rows = await db.query('animals');
    return rows.map((m) => Animal.fromMap(m)).toList();
    // ou: List.generate(rows.length, (i) => Animal.fromMap(rows[i]));
  }

  static Future<Animal> createAnimal(Map<String, dynamic> animal) async {
    final db = await database;
    final data = _withoutNulls(animal);
    await db.insert('animals', data);
    return Animal.fromMap(data);
  }

  static Future<Animal> updateAnimal(String id, Map<String, dynamic> animal) async {
    final db = await database;
    final data = _withoutNulls(animal);
    await db.update('animals', data, where: 'id = ?', whereArgs: [id]);
    return Animal.fromMap({...data, 'id': id});
  }

  static Future<void> deleteAnimal(String id) async {
    final db = await database;
    await db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  // --------- VACINAÇÕES ---------
  static Future<List<Map<String, dynamic>>> getVaccinations() async {
    final db = await database;
    final rows = await db.query('vaccinations');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createVaccination(Map<String, dynamic> vaccination) async {
    final db = await database;
    await db.insert('vaccinations', _withoutNulls(vaccination));
  }

  // --------- MEDICAMENTOS ---------
  static Future<List<Map<String, dynamic>>> getMedications() async {
    final db = await database;
    final rows = await db.query('medications');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createMedication(Map<String, dynamic> medication) async {
    final db = await database;
    await db.insert('medications', _withoutNulls(medication));
  }

  // --------- REPRODUÇÃO ---------
  static Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    final db = await database;
    final rows = await db.query('breeding_records');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createBreedingRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert('breeding_records', _withoutNulls(record));
  }

  // --------- ANOTAÇÕES ---------
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    final rows = await db.query('notes');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.insert('notes', _withoutNulls(note));
  }

  // --------- FINANCEIRO ---------
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final db = await database;
    final rows = await db.query('financial_records');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createFinancialRecord(Map<String, dynamic> record) async {
    final db = await database;
    await db.insert('financial_records', _withoutNulls(record));
  }

  // --------- ESTATÍSTICAS ---------
  static Future<Map<String, dynamic>> getStats() async {
    final db = await database;

    int _firstInt(List<Map<String, Object?>> r) {
      if (r.isEmpty) return 0;
      final v = r.first.values.first;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    double _firstDouble(List<Map<String, Object?>> r) {
      if (r.isEmpty) return 0.0;
      final v = r.first.values.first;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    final totalAnimals = _firstInt(await db.rawQuery('SELECT COUNT(*) AS c FROM animals'));
    final healthy = _firstInt(await db.rawQuery("SELECT COUNT(*) AS c FROM animals WHERE status = 'Saudável' OR status = 'Ativo'"));
    final pregnant = _firstInt(await db.rawQuery('SELECT COUNT(*) AS c FROM animals WHERE pregnant = 1'));
    final underTreatment = _firstInt(await db.rawQuery("SELECT COUNT(*) AS c FROM animals WHERE status = 'Em tratamento' OR status = 'Tratamento'"));
    final maleReproducers = _firstInt(await db.rawQuery("SELECT COUNT(*) AS c FROM animals WHERE category = 'Macho Reprodutor'"));
    final maleLambs = _firstInt(await db.rawQuery("SELECT COUNT(*) AS c FROM animals WHERE category = 'Macho Borrego'"));
    final femaleLambs = _firstInt(await db.rawQuery("SELECT COUNT(*) AS c FROM animals WHERE category = 'Fêmea Borrega'"));
    final femaleReproducers = _firstInt(await db.rawQuery("SELECT COUNT(*) AS c FROM animals WHERE category = 'Fêmea Reprodutora'"));

    final revenue = _firstDouble(await db.rawQuery("SELECT SUM(amount) AS total FROM financial_records WHERE type = 'receita'"));
    final avgWeight = _firstDouble(await db.rawQuery('SELECT AVG(weight) AS avg FROM animals'));

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

  // --------- BACKUP / SYNC ---------
  /// Compat: era chamado pelo botão de backup com um callback.
  static Future<void> syncWithSupabase(Function onSync) async {
    await onSync();
  }

  // --------- LIMPEZA ---------
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('animals');
    await db.delete('vaccinations');
    await db.delete('medications');
    await db.delete('breeding_records');
    await db.delete('notes');
    await db.delete('financial_records');
    await db.delete('reports');
    await db.delete('push_tokens');
    await db.delete('animal_weights');
  }

  // --------- DADOS EXEMPLO ---------
  static Future<void> loadSampleData() async {
    final db = await database;

    final cnt = await db.rawQuery('SELECT COUNT(*) AS c FROM animals');
    final has = cnt.isNotEmpty && (cnt.first['c'] is num) && (cnt.first['c'] as num) > 0;
    if (has) {
      // ignore: avoid_print
      print('Banco já possui dados. Use clearAllData() para resetar.');
      return;
    }

    final now = DateTime.now().toIso8601String();

    await db.insert('animals', {
      'id': 'OV001',
      'code': 'OV001',
      'name': '18',
      'name_color': 'blue',
      'category': 'Fêmea Reprodutora',
      'species': 'Ovino',
      'breed': 'Santa Inês',
      'gender': 'Fêmea',
      'birth_date': '2022-03-15',
      'weight': 45.5,
      'status': 'Saudável',
      'location': 'Pasto A1',
      'last_vaccination': '2024-08-15',
      'pregnant': 1,
      'expected_delivery': '2024-12-20',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('animals', {
      'id': 'CP002',
      'code': 'CP002',
      'name': '25',
      'name_color': 'red',
      'category': 'Macho Reprodutor',
      'species': 'Caprino',
      'breed': 'Boer',
      'gender': 'Macho',
      'birth_date': '2021-07-22',
      'weight': 65.2,
      'status': 'Reprodutor',
      'location': 'Pasto B2',
      'last_vaccination': '2024-09-01',
      'pregnant': 0,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('animals', {
      'id': 'OV003',
      'code': 'OV003',
      'name': '18',
      'name_color': 'green',
      'category': 'Fêmea Borrega',
      'species': 'Ovino',
      'breed': 'Morada Nova',
      'gender': 'Fêmea',
      'birth_date': '2023-01-10',
      'weight': 38.0,
      'status': 'Em tratamento',
      'location': 'Enfermaria',
      'last_vaccination': '2024-07-20',
      'pregnant': 0,
      'health_issue': 'Verminose',
      'created_at': now,
      'updated_at': now,
    });

    // ignore: avoid_print
    print('Dados de exemplo carregados com sucesso!');
  }

  // --------- COMPAT util antigo ---------
  static Future<String> getApplicationDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // ================== HELPERS ==================
  static Map<String, dynamic> _withoutNulls(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.isEmpty) return;
      out[k] = v;
    });
    return out;
  }
}
