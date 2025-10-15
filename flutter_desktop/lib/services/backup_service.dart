// lib/services/backup_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local_db.dart';

typedef Progress = void Function(String step);

class BackupService {
  final AppDatabase _appDb;
  final SupabaseClient _client;

  BackupService({
    required AppDatabase db,
    String? supabaseUrl,
    String? supabaseAnonKey,
  })  : _appDb = db,
        _client = Supabase.instance.client;

  // ======= Compat: wrappers estáticos (opcionais) =======
  static Future<void> pushAllToSupabase(
    SupabaseClient client, {
    AppDatabase? db,
    Progress? onProgress,
    bool mirrorDeletes = true,
    int chunk = 500,
  }) async {
    final appDb = db ?? await AppDatabase.open();
    try {
      final svc = BackupService(db: appDb);
      await svc._backupMirrorRemote(
        onProgress: onProgress,
        mirrorDeletes: mirrorDeletes,
        chunk: chunk,
      );
    } finally {
      if (db == null) await appDb.db.close();
    }
  }

  static Future<void> pullAllFromSupabase(
    SupabaseClient client, {
    AppDatabase? db,
    Progress? onProgress,
    bool wipeLocalFirst = true,
    int pageSize = 1000,
  }) async {
    final appDb = db ?? await AppDatabase.open();
    try {
      final svc = BackupService(db: appDb);
      await svc._restoreFromRemote(
        onProgress: onProgress,
        wipeLocalFirst: wipeLocalFirst,
        pageSize: pageSize,
      );
    } finally {
      if (db == null) await appDb.db.close();
    }
  }

  // ======= Ordem (pais → filhos) / (filhos → pais) =======
  static const List<String> _pushOrder = [
    'animals',
    'financial_accounts',
    'financial_records',
    'notes',
    'vaccinations',
    'medications',
    'animal_weights',
    'breeding_records',
    'reports',
    'push_tokens',
  ];

  static const List<String> _deleteChildFirst = [
    'animal_weights',
    'breeding_records',
    'vaccinations',
    'medications',
    'notes',
    'financial_records',
    'financial_accounts',
    'reports',
    'push_tokens',
    'animals',
  ];

  // ======= Mapa de FKs (para corrigir IDs inválidos) =======
  static final Map<String, List<_FkRef>> _fkMap = {
    'animals': [
      _FkRef('animal_weights', 'animal_id'),
      _FkRef('breeding_records', 'female_animal_id'),
      _FkRef('breeding_records', 'male_animal_id'),
      _FkRef('financial_records', 'animal_id'),
      _FkRef('financial_accounts', 'animal_id'),
      _FkRef('medications', 'animal_id'),
      _FkRef('vaccinations', 'animal_id'),
      _FkRef('notes', 'animal_id'),
    ],
    'financial_accounts': [
      _FkRef('financial_accounts', 'parent_id'), // self-ref
    ],
  };

  // ======= Colunas válidas por tabela =======
  static final Map<String, Set<String>> _cols = {
    'animals': {
      'id','code','name','species','breed','gender','birth_date','weight','status','location',
      'last_vaccination','pregnant','expected_delivery','health_issue','created_at','updated_at',
      'name_color','category','birth_weight','weight_30_days','weight_60_days','weight_90_days',
    },
    'animal_weights': {'id','animal_id','date','weight','created_at','updated_at'},
    'breeding_records': {
      'id','female_animal_id','male_animal_id','breeding_date','expected_birth','status','notes',
      'created_at','updated_at','mating_start_date','mating_end_date','separation_date',
      'ultrasound_date','ultrasound_result','birth_date','stage',
    },
    'financial_accounts': {
      'id','type','category','description','amount','due_date','payment_date','status','payment_method',
      'installments','installment_number','parent_id','animal_id','supplier_customer','notes',
      'is_recurring','recurrence_frequency','recurrence_end_date','created_at','updated_at',
    },
    'financial_records': {'id','type','category','description','amount','date','animal_id','created_at','updated_at'},
    'medications': {
      'id','animal_id','medication_name','date','next_date','dosage','veterinarian','notes',
      'created_at','updated_at','status','applied_date',
    },
    'notes': {
      'id','animal_id','title','content','category','priority','date','created_by','created_at',
      'updated_at','is_read',
    },
    'push_tokens': {'id','token','platform','device_info','created_at'},
    'reports': {'id','title','report_type','parameters','generated_at','generated_by'},
    'vaccinations': {
      'id','animal_id','vaccine_name','vaccine_type','scheduled_date','applied_date','veterinarian',
      'notes','status','created_at','updated_at',
    },
  };

  // ======= Streams p/ UI =======
  Stream<String> backupAll({bool mirrorDeletes = true, int chunk = 500}) {
    final c = StreamController<String>();
    () async {
      try {
        await _backupMirrorRemote(
          onProgress: c.add,
          mirrorDeletes: mirrorDeletes,
          chunk: chunk,
        );
        c.add('Concluído (upload).');
      } catch (e) {
        c.add('Erro no upload: $e');
      } finally {
        await c.close();
      }
    }();
    return c.stream;
  }

  Stream<String> restoreAll({bool wipeLocalFirst = true, int pageSize = 1000}) {
    final c = StreamController<String>();
    () async {
      try {
        await _restoreFromRemote(
          onProgress: c.add,
          wipeLocalFirst: wipeLocalFirst,
          pageSize: pageSize,
        );
        c.add('Concluído (download).');
      } catch (e) {
        c.add('Erro no download: $e');
      } finally {
        await c.close();
      }
    }();
    return c.stream;
  }

  // ======= Upload: local → Supabase (com espelho de exclusões) =======
  Future<void> _backupMirrorRemote({
    Progress? onProgress,
    bool mirrorDeletes = true,
    int chunk = 500,
  }) async {
    final db = _appDb.db;
    final supa = _client;

    // 0) Sanitiza IDs inválidos (pais→filhos)
    onProgress?.call('Verificando/ajustando IDs inválidos…');
    for (final t in _pushOrder) {
      await _fixInvalidIdsCascade(t);
    }

    // 1) Upsert de tudo
    for (final table in _pushOrder) {
      onProgress?.call('Preparando $table…');
      final rows = await db.query(table);
      if (rows.isEmpty) continue;

      final payload = rows.map((r) => _toRemote(table, r)).toList();
      for (final r in payload) {
        if (_missingId(r['id'])) r['id'] = _uuidV4();
      }

      onProgress?.call('Enviando $table (${payload.length})…');
      for (var i = 0; i < payload.length; i += chunk) {
        final part = payload.sublist(i, (i + chunk).clamp(0, payload.length));
        await supa.from(table).upsert(part);
      }
    }

    // 2) Espelha exclusões (opcional)
    if (mirrorDeletes) {
      for (final table in _deleteChildFirst) {
        onProgress?.call('Sincronizando exclusões em $table…');

        final localIds = (await db.query(table, columns: ['id']))
            .map((m) => (m['id'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toSet();

        final remoteIds = (await supa.from(table).select('id'))
            .map<String>((e) => (e['id'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toSet();

        final toDelete = remoteIds.difference(localIds).toList();
        if (toDelete.isEmpty) continue;

        const batch = 300;
        for (var i = 0; i < toDelete.length; i += batch) {
          final part = toDelete.sublist(i, (i + batch).clamp(0, toDelete.length));
          final orExpr = part.map((id) => 'id.eq.$id').join(',');
          await supa.from(table).delete().or(orExpr);
        }
      }
    }

    onProgress?.call('Upload finalizado.');
  }

  // ======= Download: Supabase → local =======
  Future<void> _restoreFromRemote({
    Progress? onProgress,
    bool wipeLocalFirst = true,
    int pageSize = 1000,
  }) async {
    final db = _appDb.db;
    final supa = _client;

    if (wipeLocalFirst) {
      onProgress?.call('Limpando base local…');
      await db.transaction((txn) async {
        for (final t in _deleteChildFirst) {
          await txn.delete(t);
        }
      });
    }

    Future<List<Map<String, dynamic>>> fetchAll(String table) async {
      final out = <Map<String, dynamic>>[];
      int from = 0;
      while (true) {
        final to = from + pageSize - 1;
        final page = await supa.from(table).select('*').range(from, to);
        if (page.isEmpty) break;
        out.addAll(page.map((e) => Map<String, dynamic>.from(e)));
        if (page.length < pageSize) break;
        from += pageSize;
      }
      return out;
    }

    for (final table in _pushOrder) {
      onProgress?.call('Baixando $table…');
      final rows = await fetchAll(table);
      if (rows.isEmpty) continue;

      final toLocal = rows.map((r) => _toLocal(table, r)).toList();

      onProgress?.call('Gravando $table (${toLocal.length})…');
      await db.transaction((txn) async {
        for (final r in toLocal) {
          await txn.insert(table, r, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    }

    onProgress?.call('Download finalizado.');
  }

  // ======= Correção de IDs inválidos e FKs =======
  Future<void> _fixInvalidIdsCascade(String table) async {
    final db = _appDb.db;
    final uuidRe = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

    final rows = await db.rawQuery('SELECT rowid AS __rid, id FROM $table');
    final fixes = <_IdFix>[];

    for (final r in rows) {
      final old = (r['id'] ?? '').toString();
      final needFix = old.isEmpty || !uuidRe.hasMatch(old);
      if (needFix) {
        fixes.add(_IdFix(
          rowId: (r['__rid'] as int),
          oldId: old.isEmpty ? null : old,
          newId: _uuidV4(),
        ));
      }
    }
    if (fixes.isEmpty) return;

    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');

      final refs = _fkMap[table] ?? const <_FkRef>[];
      for (final fix in fixes) {
        for (final ref in refs) {
          await txn.update(
            ref.childTable,
            {ref.childColumn: fix.newId},
            where: '${ref.childColumn} ${fix.oldId == null ? "IS NULL" : "= ?"}',
            whereArgs: fix.oldId == null ? null : [fix.oldId],
          );
        }
        if (fix.oldId == null) {
          await txn.update(table, {'id': fix.newId}, where: 'rowid = ?', whereArgs: [fix.rowId]);
        } else {
          await txn.update(table, {'id': fix.newId}, where: 'id = ?', whereArgs: [fix.oldId]);
        }
      }

      await txn.execute('PRAGMA foreign_keys = ON');
    });
  }

  // ======= Converters =======
  static Map<String, dynamic> _toRemote(String table, Map<String, dynamic> row) {
    final r = Map<String, dynamic>.from(row);

    // 0/1 -> bool
    if (table == 'animals') r['pregnant'] = _toBool(row['pregnant']);
    if (table == 'notes')   r['is_read']  = _toBool(row['is_read']);
    if (table == 'financial_accounts') {
      final v = row['is_recurring'];
      r['is_recurring'] = (v == 1 || v == true);
    }

    // json string -> json
    if (table == 'reports')     r['parameters']  = _jsonIn(row['parameters']);
    if (table == 'push_tokens') r['device_info'] = _jsonIn(row['device_info']);

    return _only(r, _cols[table] ?? {});
  }

  static Map<String, dynamic> _toLocal(String table, Map<String, dynamic> row) {
    final r = Map<String, dynamic>.from(row);

    // bool -> INTEGER 0/1 (SQLite)
    if (table == 'animals') r['pregnant'] = (row['pregnant'] == true) ? 1 : 0;
    if (table == 'notes')   r['is_read']  = (row['is_read']  == true) ? 1 : 0;
    if (table == 'financial_accounts') {
      r['is_recurring'] = (row['is_recurring'] == true) ? 1 : 0;
    }

    // json -> string
    if (table == 'reports')     r['parameters']  = _jsonOut(row['parameters']);
    if (table == 'push_tokens') r['device_info'] = _jsonOut(row['device_info']);

    return _only(r, _cols[table] ?? {});
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = (v ?? '').toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 't' || s == 'y' || s == 'yes';
  }

  static dynamic _jsonIn(dynamic v) {
    if (v == null) return {};
    if (v is Map<String, dynamic>) return v;
    if (v is String) {
      if (v.isEmpty) return {};
      try { return jsonDecode(v); } catch (_) { return {}; }
    }
    return {};
  }

  static dynamic _jsonOut(dynamic v) => (v == null) ? '{}' : jsonEncode(v);

  static Map<String, dynamic> _only(Map<String, dynamic> m, Set<String> allow) {
    final out = <String, dynamic>{};
    m.forEach((k, v) { if (allow.contains(k)) out[k] = v; });
    return out;
  }

  static String _uuidV4() {
    final rnd = Random.secure();
    final b = List<int>.generate(16, (_) => rnd.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String h(int x) => x.toRadixString(16).padLeft(2, '0');
    return '${h(b[0])}${h(b[1])}${h(b[2])}${h(b[3])}-'
           '${h(b[4])}${h(b[5])}-'
           '${h(b[6])}${h(b[7])}-'
           '${h(b[8])}${h(b[9])}-'
           '${h(b[10])}${h(b[11])}${h(b[12])}${h(b[13])}${h(b[14])}${h(b[15])}';
  }

  static bool _missingId(dynamic v) {
    if (v == null) return true;
    final s = v.toString().trim();
    return s.isEmpty || s.toLowerCase() == 'null';
  }
}

// ===== Auxiliares =====
class _FkRef {
  final String childTable;
  final String childColumn;
  const _FkRef(this.childTable, this.childColumn);
}

class _IdFix {
  final int rowId;
  final String? oldId;
  final String newId;
  _IdFix({required this.rowId, required this.oldId, required this.newId});
}
