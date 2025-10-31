// Camada de compatibilidade com o serviço antigo, delegando ao AppDatabase (SQLite).
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite/sqflite.dart' as sqflite show Sqflite;
import 'package:path_provider/path_provider.dart';

import '../models/animal.dart';
import '../data/local_db.dart';

// ✅ padronização de stage/status
import '../models/breeding_record.dart';
// ✅ garantir ID ao criar registros
import 'package:uuid/uuid.dart';

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

  static Future<Animal?> getAnimalById(String id) async {
    final db = await database;
    final rows = await db.query('animals', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Animal.fromMap(rows.first);
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

    r['breeding_date']     = _toIsoDate(r['breeding_date']);
    r['mating_start_date'] = _toIsoDate(r['mating_start_date']);
    r['mating_end_date']   = _toIsoDate(r['mating_end_date']);
    r['separation_date']   = _toIsoDate(r['separation_date']);
    r['ultrasound_date']   = _toIsoDate(r['ultrasound_date']);
    r['expected_birth']    = _toIsoDate(r['expected_birth']);
    r['birth_date']        = _toIsoDate(r['birth_date']);

    // 🔐 normaliza stage/status (aceita String ou enum)
    if (r.containsKey('stage')) {
      final s = r['stage'];
      if (s is String) {
        final st = BreedingStage.fromString(s);
        r['stage']  = st.value;
        r['status'] ??= st.statusLabel;
      } else if (s is BreedingStage) {
        r['stage']  = s.value;
        r['status'] ??= s.statusLabel;
      }
    }

    // ✅ padrão: previsão de separação = início + 60 dias (se não veio do formulário)
    if ((r['mating_end_date'] == null || (r['mating_end_date'] as String).isEmpty) && r['breeding_date'] != null) {
      r['mating_end_date'] = _addDaysYMD(r['breeding_date'] as String, 60);
    }

    r['id']         ??= const Uuid().v4(); // garante ID quando não vier
    r['created_at'] ??= _nowIso();
    r['updated_at']  = _nowIso();

    _applyBreedingInference(r);
    await db.insert('breeding_records', r);

    // 🔄 sincroniza tabela animals
    await _syncAnimalPregnancyFromRecord(r);
  }

  static Future<void> updateBreedingRecord(String id, Map<String, dynamic> updates) async {
    final db = await database;
    final r = Map<String, dynamic>.from(_withoutNulls(updates));

    if (r.containsKey('breeding_date'))     r['breeding_date']     = _toIsoDate(r['breeding_date']);
    if (r.containsKey('mating_start_date')) r['mating_start_date'] = _toIsoDate(r['mating_start_date']);
    if (r.containsKey('mating_end_date'))   r['mating_end_date']   = _toIsoDate(r['mating_end_date']);
    if (r.containsKey('separation_date'))   r['separation_date']   = _toIsoDate(r['separation_date']);
    if (r.containsKey('ultrasound_date'))   r['ultrasound_date']   = _toIsoDate(r['ultrasound_date']);
    if (r.containsKey('expected_birth'))    r['expected_birth']    = _toIsoDate(r['expected_birth']);
    if (r.containsKey('birth_date'))        r['birth_date']        = _toIsoDate(r['birth_date']);

    r['updated_at'] = _nowIso();

    // 🔐 normaliza stage/status (aceita String ou enum)
    if (r.containsKey('stage')) {
      final s = r['stage'];
      if (s is String) {
        final st = BreedingStage.fromString(s);
        r['stage']  = st.value;
        r['status'] ??= st.statusLabel;
      } else if (s is BreedingStage) {
        r['stage']  = s.value;
        r['status'] ??= s.statusLabel;
      }
    }

    _applyBreedingInference(r);
    final rowsAffected = await db.update(
      'breeding_records',
      r,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rowsAffected == 0) {
      throw Exception('Nenhum registro atualizado: id=$id');
    }

    // 🔄 sincroniza tabela animals
    if (r['female_animal_id'] == null) {
      final current = await db.query('breeding_records', where: 'id = ?', whereArgs: [id], limit: 1);
      if (current.isNotEmpty) r['female_animal_id'] = current.first['female_animal_id'];
    }
    await _syncAnimalPregnancyFromRecord(r);
  }

  static Future<void> deleteBreedingRecord(String id) async {
    final db = await database;
    await db.delete('breeding_records', where: 'id = ?', whereArgs: [id]);
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
    n['is_read'] ??= 0;
    n['created_at'] ??= _nowIso();
    n['updated_at'] = _nowIso();
    await db.insert('notes', n);
  }

  static Future<void> updateNote(String id, Map<String, dynamic> updates) async {
    final db = await database;
    final n = Map<String, dynamic>.from(_withoutNulls(updates));

    if (n.containsKey('date')) {
      n['date'] = _toIsoDate(n['date']);
    }
    n['updated_at'] = _nowIso();

    await db.update('notes', n, where: 'id = ?', whereArgs: [id]);
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
        "SELECT COUNT(*) AS c FROM animals WHERE category = 'Reprodutor' AND gender = 'Macho'"));
    final maleLambs = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE category = 'Borrego' AND gender = 'Macho'"));
    final femaleLambs = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE category = 'Borrego' AND gender = 'Fêmea'"));
    final femaleReproducers = _firstInt(await db.rawQuery(
        "SELECT COUNT(*) AS c FROM animals WHERE category = 'Reprodutor' AND gender = 'Fêmea'"));

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

  /// Adiciona dias a uma data em formato 'YYYY-MM-DD' e devolve no mesmo formato.
  static String? _addDaysYMD(String? ymd, int days) {
    if (ymd == null || ymd.isEmpty) return null;
    final dt = DateTime.tryParse(ymd);
    if (dt == null) return null;
    final base = DateTime(dt.year, dt.month, dt.day);
    final r = base.add(Duration(days: days));
    return r.toIso8601String().split('T').first;
  }

  // ranking de estágios (para promover quando necessário)
  static int _stageRank(BreedingStage s) {
    switch (s) {
      case BreedingStage.encabritamento:      return 0;
      case BreedingStage.separacao:           return 1;
      case BreedingStage.aguardandoUltrassom: return 1;
      case BreedingStage.gestacaoConfirmada:  return 2;
      case BreedingStage.partoRealizado:      return 3;
      case BreedingStage.falhou:              return 99; // terminal
    }
  }

  // Normaliza valores e preenche previsões/estágio a partir das datas fornecidas.
  static void _applyBreedingInference(Map<String, dynamic> r) {
    String? iso(dynamic v) => _toIsoDate(v);

    // normaliza datas recebidas
    if (r.containsKey('breeding_date'))     r['breeding_date']     = iso(r['breeding_date']);
    if (r.containsKey('mating_start_date')) r['mating_start_date'] = iso(r['mating_start_date']);
    if (r.containsKey('mating_end_date'))   r['mating_end_date']   = iso(r['mating_end_date']);
    if (r.containsKey('separation_date'))   r['separation_date']   = iso(r['separation_date']);
    if (r.containsKey('ultrasound_date'))   r['ultrasound_date']   = iso(r['ultrasound_date']);
    if (r.containsKey('expected_birth'))    r['expected_birth']    = iso(r['expected_birth']);
    if (r.containsKey('birth_date'))        r['birth_date']        = iso(r['birth_date']);

    // normaliza resultado do ultrassom
    final rawRes = (r['ultrasound_result'] as String?)?.toLowerCase();
    if (rawRes != null) {
      if (rawRes.contains('confirmada')) {
        r['ultrasound_result'] = 'Confirmada';
      } else if (rawRes.contains('nao_confirmada') || rawRes.contains('não confirmada')) {
        r['ultrasound_result'] = 'Nao_Confirmada';
      }
    }

    // 'confirmation_date' → usamos como ultrasound_date quando não vier
    if (r['confirmation_date'] != null &&
        (r['ultrasound_date'] == null || (r['ultrasound_date'] as String).isEmpty)) {
      r['ultrasound_date'] = iso(r['confirmation_date']);
    }
    r.remove('confirmation_date');

    final breeding = r['breeding_date'] as String?;
    final sep      = r['separation_date'] as String?;
    final usg      = r['ultrasound_date'] as String?;
    final birth    = r['birth_date'] as String?;
    final exp      = r['expected_birth'] as String?;
    final res      = (r['ultrasound_result'] as String?);

    String? addDays(String? ymd, int d) => _addDaysYMD(ymd, d);

    // 1) fim padrão do encabritamento (caso não informado)
    if ((r['mating_end_date'] == null || (r['mating_end_date'] as String).isEmpty) && breeding != null) {
      r['mating_end_date'] = addDays(breeding, 60);
    }

    // 2) se há separação, programe ultrassom = separação + 30 (se não veio)
    if (sep != null && (usg == null || usg.isEmpty)) {
      r['ultrasound_date'] = addDays(sep, 30);
    }

    // 3) se gestação confirmada, expected_birth = ultrasound_date + 150 (se não veio)
    final isConfirmed = res != null && res.toLowerCase().contains('confirmada');
    if (isConfirmed && (exp == null || exp.isEmpty)) {
      final base = r['ultrasound_date'] as String? ?? _today();
      r['expected_birth'] = addDays(base, 150);
    }

    // 4) sempre inferir estágio e PROMOVER se necessário
    BreedingStage inferred;
    if (birth != null && birth.isNotEmpty) {
      inferred = BreedingStage.partoRealizado;
    } else if (res == 'Nao_Confirmada') {
      inferred = BreedingStage.falhou;
    } else if (isConfirmed || (r['expected_birth'] as String?)?.isNotEmpty == true) {
      inferred = BreedingStage.gestacaoConfirmada;
    } else if ((r['ultrasound_date'] as String?)?.isNotEmpty == true || sep != null) {
      inferred = BreedingStage.aguardandoUltrassom;
    } else {
      inferred = BreedingStage.encabritamento;
    }

    // estágio vindo do payload (se vier)
    BreedingStage? provided;
    final s = r['stage'];
    if (s is String && s.isNotEmpty) provided = BreedingStage.fromString(s);
    if (s is BreedingStage) provided = s;

    // regra: terminal sempre respeita dados; senão, promover quando inferido > informado
    if (provided == null) {
      r['stage'] = inferred.value;
    } else if (provided == BreedingStage.falhou || provided == BreedingStage.partoRealizado) {
      r['stage'] = provided.value; // não mexe
    } else if (_stageRank(inferred) > _stageRank(provided)) {
      r['stage'] = inferred.value; // promove
    } else {
      r['stage'] = provided.value; // mantém
    }

    // status coerente
    r['status'] ??= BreedingStage.fromString(r['stage'] as String?).statusLabel;
  }

  /// Sincroniza a fêmea do registro com a tabela animals.
  static Future<void> _syncAnimalPregnancyFromRecord(Map<String, dynamic> r) async {
    final db = await database;

    final femaleId = (r['female_animal_id'] as String?)?.trim();
    if (femaleId == null || femaleId.isEmpty) return;

    final stage = BreedingStage.fromString(r['stage'] as String?);
    final usgRes = (r['ultrasound_result'] as String?)?.toLowerCase();
    final expectedBirth = r['expected_birth'] as String?;

    if (stage == BreedingStage.gestacaoConfirmada || (usgRes != null && usgRes.contains('confirmada'))) {
      await db.update('animals', {
        'pregnant': 1,
        'expected_delivery': expectedBirth,
        'status': 'Gestante',
        'updated_at': _nowIso(),
      }, where: 'id = ?', whereArgs: [femaleId]);
    } else if (stage == BreedingStage.falhou || stage == BreedingStage.partoRealizado ||
               (usgRes != null && usgRes.contains('nao_confirmada'))) {
      final rows = await db.query('animals', columns: ['status'], where: 'id = ?', whereArgs: [femaleId], limit: 1);
      final currentStatus = rows.isNotEmpty ? (rows.first['status'] as String? ?? '') : '';
      await db.update('animals', {
        'pregnant': 0,
        'expected_delivery': null,
        'status': currentStatus.trim().toLowerCase() == 'gestante' ? 'Saudável' : currentStatus,
        'updated_at': _nowIso(),
      }, where: 'id = ?', whereArgs: [femaleId]);
    }
  }

  /// (Opcional) Reprocessa todos os registros de reprodução e sincroniza as fêmeas.
  static Future<void> reconcilePregnancyFromBreeding() async {
    final db = await database;
    final rows = await db.query('breeding_records');
    for (final r in rows) {
      final m = Map<String, dynamic>.from(r);
      _applyBreedingInference(m);
      await _syncAnimalPregnancyFromRecord(m);
    }
  }
}
