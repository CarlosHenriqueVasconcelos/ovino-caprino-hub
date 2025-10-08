// Camada de compatibilidade com o serviço antigo, delegando ao AppDatabase (SQLite).
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

  static Future<String> dbPath() => AppDatabase.dbPath();

  // ================== ANIMAIS ==================
  static Future<List<Animal>> getAnimals() async {
    final db = await database;
    final rows = await db.query('animals', orderBy: 'created_at DESC');
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  static Future<Animal> createAnimal(Map<String, dynamic> animal) async {
    final db = await database;
    final data = _prepareAnimalMap(animal, isNew: true);
    await db.insert('animals', data);
    return Animal.fromMap(data);
  }

  static Future<Animal> updateAnimal(String id, Map<String, dynamic> animal) async {
    final db = await database;
    final data = _prepareAnimalMap(animal, isNew: false);
    await db.update('animals', data, where: 'id = ?', whereArgs: [id]);
    return Animal.fromMap({...data, 'id': id});
  }

  static Future<void> deleteAnimal(String id) async {
    final db = await database;
    await db.delete('animals', where: 'id = ?', whereArgs: [id]);
  }

  // ================== VACINAÇÕES ==================
  static Future<List<Map<String, dynamic>>> getVaccinations() async {
    final db = await database;
    final rows = await db.query('vaccinations', orderBy: 'scheduled_date ASC');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createVaccination(Map<String, dynamic> vaccination) async {
    final db = await database;
    final v = Map<String, dynamic>.from(_withoutNulls(vaccination));

    v['scheduled_date'] = _toIsoDate(v['scheduled_date']);
    v['applied_date'] = _toIsoDate(v['applied_date']);
    v['created_at'] ??= _nowIso();
    v['updated_at'] = _nowIso();

    await db.insert('vaccinations', v);
  }

  static Future<void> updateVaccination(String id, Map<String, dynamic> updates) async {
    final db = await database;
    final v = Map<String, dynamic>.from(_withoutNulls(updates));
    
    if (v.containsKey('scheduled_date')) {
      v['scheduled_date'] = _toIsoDate(v['scheduled_date']);
    }
    if (v.containsKey('applied_date')) {
      v['applied_date'] = _toIsoDate(v['applied_date']);
    }
    v['updated_at'] = _nowIso();

    await db.update('vaccinations', v, where: 'id = ?', whereArgs: [id]);
  }

  // ================== MEDICAMENTOS ==================
  static Future<List<Map<String, dynamic>>> getMedications() async {
    final db = await database;
    final rows = await db.query('medications', orderBy: 'date ASC');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createMedication(Map<String, dynamic> medication) async {
    final db = await database;
    final m = Map<String, dynamic>.from(_withoutNulls(medication));

    m['date'] = _toIsoDate(m['date']);
    m['next_date'] = _toIsoDate(m['next_date']);
    m['applied_date'] = _toIsoDate(m['applied_date']);
    m['created_at'] ??= _nowIso();
    m['updated_at'] = _nowIso();

    await db.insert('medications', m);
  }

  static Future<void> updateMedication(String id, Map<String, dynamic> updates) async {
    final db = await database;
    final m = Map<String, dynamic>.from(_withoutNulls(updates));
    
    if (m.containsKey('date')) {
      m['date'] = _toIsoDate(m['date']);
    }
    if (m.containsKey('next_date')) {
      m['next_date'] = _toIsoDate(m['next_date']);
    }
    if (m.containsKey('applied_date')) {
      m['applied_date'] = _toIsoDate(m['applied_date']);
    }
    m['updated_at'] = _nowIso();

    await db.update('medications', m, where: 'id = ?', whereArgs: [id]);
  }

  // ================== REPRODUÇÃO ==================
  static Future<List<Map<String, dynamic>>> getBreedingRecords() async {
    final db = await database;
    final rows = await db.query('breeding_records', orderBy: 'breeding_date DESC');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createBreedingRecord(Map<String, dynamic> record) async {
    final db = await database;
    final r = Map<String, dynamic>.from(_withoutNulls(record));
    r['breeding_date'] = _toIsoDate(r['breeding_date']);
    r['expected_birth'] = _toIsoDate(r['expected_birth']);
    r['created_at'] ??= _nowIso();
    r['updated_at'] = _nowIso();
    await db.insert('breeding_records', r);
  }

  // ================== ANOTAÇÕES ==================
  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'date DESC');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createNote(Map<String, dynamic> note) async {
    final db = await database;
    final n = Map<String, dynamic>.from(_withoutNulls(note));
    n['date'] = _toIsoDate(n['date']) ?? _today();
    n['created_at'] ??= _nowIso();
    n['updated_at'] = _nowIso();
    await db.insert('notes', n);
  }

  // ================== FINANCEIRO ==================
  static Future<List<Map<String, dynamic>>> getFinancialRecords() async {
    final db = await database;
    final rows = await db.query('financial_records', orderBy: 'date DESC');
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> createFinancialRecord(Map<String, dynamic> record) async {
    final db = await database;
    final r = Map<String, dynamic>.from(_withoutNulls(record));
    r['date'] = _toIsoDate(r['date']) ?? _today();
    r['created_at'] ??= _nowIso();
    r['updated_at'] = _nowIso();
    await db.insert('financial_records', r);
  }

  // ================== ESTATÍSTICAS ==================
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
    final healthy = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE status IN ('Saudável','Ativo')"));
    final pregnant = _firstInt(await db.rawQuery('SELECT COUNT(*) AS c FROM animals WHERE pregnant = 1'));
    final underTreatment = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE status IN ('Em tratamento','Tratamento')"));
    final maleReproducers = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE category = 'Macho Reprodutor'"));
    final maleLambs = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE category = 'Macho Borrego'"));
    final femaleLambs = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE category = 'Fêmea Borrega'"));
    final femaleReproducers = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE category = 'Fêmea Reprodutora'"));

    final revenue = _firstDouble(await db.rawQuery(
        "SELECT COALESCE(SUM(amount),0) AS total FROM financial_records WHERE type = 'receita'"));
    final avgWeight = _firstDouble(await db.rawQuery('SELECT COALESCE(AVG(weight),0) AS avg FROM animals'));

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

  // ================== BACKUP / SYNC ==================
  static Future<void> syncWithSupabase(Function onSync) async {
    await onSync();
  }

  // ================== UTIL ANTIGO ==================
  static Future<String> getApplicationDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // ================== HELPERS ==================
  static Map<String, dynamic> _prepareAnimalMap(Map<String, dynamic> m, {required bool isNew}) {
    final out = _withoutNulls(m);
    // normaliza datas/comuns
    out['birth_date'] = _toIsoDate(out['birth_date']) ?? _today();
    out['last_vaccination'] = _toIsoDate(out['last_vaccination']);
    out['expected_delivery'] = _toIsoDate(out['expected_delivery']);
    // timestamps
    final now = _nowIso();
    if (isNew) out['created_at'] ??= now;
    out['updated_at'] = now;
    return out;
  }

  static Map<String, dynamic> _withoutNulls(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (v == null) return;
      if (v is String && v.isEmpty) return;
      out[k] = v;
    });
    return out;
  }

  static String _nowIso() => DateTime.now().toIso8601String();
  static String _today() => DateTime.now().toIso8601String().split('T').first;

  /// Converte String/DateTime para 'YYYY-MM-DD' quando possível.
  static String? _toIsoDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v.toIso8601String().split('T').first;
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;

      // já está no formato correto?
      final ymd = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (ymd.hasMatch(s)) return s;

      // tenta parse direto
      final p1 = DateTime.tryParse(s);
      if (p1 != null) return p1.toIso8601String().split('T').first;

      // tenta dd/MM/yyyy
      final dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
      final m = dmy.firstMatch(s);
      if (m != null) {
        final d = int.parse(m.group(1)!);
        final mo = int.parse(m.group(2)!);
        final y = int.parse(m.group(3)!);
        final dt = DateTime(y, mo, d);
        return dt.toIso8601String().split('T').first;
      }
    }
    return null;
  }
}
