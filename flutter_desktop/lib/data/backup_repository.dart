import 'dart:convert';
import 'dart:math';

import 'package:sqflite_common/sqlite_api.dart'
    show ConflictAlgorithm, Database, DatabaseExecutor;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_db.dart';

typedef Progress = void Function(String step);

class BackupRepository {
  final AppDatabase _appDb;
  final SupabaseClient _client;

  BackupRepository({
    required AppDatabase database,
    required SupabaseClient client,
  })  : _appDb = database,
        _client = client;

  static const List<String> _pushOrder = [
    'animals',
    'sold_animals',
    'deceased_animals',
    'financial_accounts',
    'financial_records',
    'notes',
    'pharmacy_stock',
    'pharmacy_stock_movements',
    'vaccinations',
    'medications',
    'animal_weights',
    'breeding_records',
    'reports',
    'push_tokens',
  ];

  static const List<String> _deleteChildFirst = [
    'pharmacy_stock_movements',
    'medications',
    'pharmacy_stock',
    'animal_weights',
    'breeding_records',
    'vaccinations',
    'notes',
    'financial_records',
    'financial_accounts',
    'reports',
    'push_tokens',
    'sold_animals',
    'deceased_animals',
    'animals',
  ];

  static final Map<String, List<_FkRef>> _fkMap = {
    'animals': const [
      _FkRef('animal_weights', 'animal_id'),
      _FkRef('breeding_records', 'female_animal_id'),
      _FkRef('breeding_records', 'male_animal_id'),
      _FkRef('financial_records', 'animal_id'),
      _FkRef('financial_accounts', 'animal_id'),
      _FkRef('medications', 'animal_id'),
      _FkRef('vaccinations', 'animal_id'),
      _FkRef('notes', 'animal_id'),
    ],
    'financial_accounts': const [
      _FkRef('financial_accounts', 'parent_id'),
    ],
    'pharmacy_stock': const [
      _FkRef('pharmacy_stock_movements', 'pharmacy_stock_id'),
      _FkRef('medications', 'pharmacy_stock_id'),
    ],
  };

  static final Map<String, Set<String>> _cols = {
    'animals': {
      'id',
      'code',
      'name',
      'species',
      'breed',
      'gender',
      'birth_date',
      'weight',
      'status',
      'location',
      'last_vaccination',
      'pregnant',
      'expected_delivery',
      'health_issue',
      'created_at',
      'updated_at',
      'name_color',
      'category',
      'birth_weight',
      'weight_30_days',
      'weight_60_days',
      'weight_90_days',
      'weight_120_days',
      'year',
      'lote',
      'mother_id',
      'father_id',
    },
    'animal_weights': {
      'id',
      'animal_id',
      'date',
      'weight',
      'created_at',
      'updated_at',
    },
    'breeding_records': {
      'id',
      'female_animal_id',
      'male_animal_id',
      'breeding_date',
      'expected_birth',
      'status',
      'notes',
      'created_at',
      'updated_at',
      'mating_start_date',
      'mating_end_date',
      'separation_date',
      'ultrasound_date',
      'ultrasound_result',
      'birth_date',
      'stage',
    },
    'financial_accounts': {
      'id',
      'type',
      'category',
      'description',
      'amount',
      'due_date',
      'payment_date',
      'status',
      'payment_method',
      'installments',
      'installment_number',
      'parent_id',
      'animal_id',
      'supplier_customer',
      'notes',
      'is_recurring',
      'recurrence_frequency',
      'recurrence_end_date',
      'created_at',
      'updated_at',
    },
    'financial_records': {
      'id',
      'type',
      'category',
      'description',
      'amount',
      'date',
      'animal_id',
      'created_at',
      'updated_at',
    },
    'medications': {
      'id',
      'animal_id',
      'medication_name',
      'date',
      'next_date',
      'dosage',
      'veterinarian',
      'notes',
      'created_at',
      'updated_at',
      'status',
      'applied_date',
    },
    'notes': {
      'id',
      'animal_id',
      'title',
      'content',
      'category',
      'priority',
      'date',
      'created_by',
      'created_at',
      'updated_at',
      'is_read',
    },
    'push_tokens': {
      'id',
      'token',
      'platform',
      'device_info',
      'created_at',
    },
    'reports': {
      'id',
      'title',
      'report_type',
      'parameters',
      'generated_at',
      'generated_by',
    },
    'sold_animals': {
      'id',
      'original_animal_id',
      'code',
      'name',
      'species',
      'breed',
      'gender',
      'birth_date',
      'weight',
      'location',
      'name_color',
      'category',
      'birth_weight',
      'weight_30_days',
      'weight_60_days',
      'weight_90_days',
      'weight_120_days',
      'year',
      'lote',
      'mother_id',
      'father_id',
      'sale_date',
      'sale_price',
      'buyer',
      'sale_notes',
      'created_at',
      'updated_at',
    },
    'deceased_animals': {
      'id',
      'original_animal_id',
      'code',
      'name',
      'species',
      'breed',
      'gender',
      'birth_date',
      'weight',
      'location',
      'name_color',
      'category',
      'birth_weight',
      'weight_30_days',
      'weight_60_days',
      'weight_90_days',
      'weight_120_days',
      'year',
      'lote',
      'mother_id',
      'father_id',
      'death_date',
      'cause_of_death',
      'death_notes',
      'created_at',
      'updated_at',
    },
    'vaccinations': {
      'id',
      'animal_id',
      'vaccine_name',
      'vaccine_type',
      'scheduled_date',
      'applied_date',
      'veterinarian',
      'notes',
      'status',
      'created_at',
      'updated_at',
    },
    'pharmacy_stock': {
      'id',
      'medication_name',
      'medication_type',
      'unit_of_measure',
      'quantity_per_unit',
      'total_quantity',
      'min_stock_alert',
      'expiration_date',
      'is_opened',
      'opened_quantity',
      'notes',
      'created_at',
      'updated_at',
    },
    'pharmacy_stock_movements': {
      'id',
      'pharmacy_stock_id',
      'medication_id',
      'movement_type',
      'quantity',
      'reason',
      'created_at',
    },
  };

  Future<void> backupMirrorRemote({
    Progress? onProgress,
    int chunk = 500,
  }) async {
    onProgress?.call('Verificando/ajustando IDs inválidos…');
    await _sanitizeLocalIds();
    await _pushTablesToRemote(onProgress: onProgress, chunk: chunk);
    await _syncRemoteDeletions(onProgress: onProgress);
    onProgress?.call('Upload finalizado.');
  }

  Future<void> restoreFromRemote({
    Progress? onProgress,
    int pageSize = 1000,
  }) async {
    final db = _appDb.db;
    onProgress?.call('Limpando base local…');
    await _clearLocalTables(db);

    for (final table in _pushOrder) {
      onProgress?.call('Baixando $table…');
      final rows = await _fetchRemoteTableRows(table, pageSize);
      if (rows.isEmpty) continue;

      final toLocal = rows.map((r) => _toLocal(table, r)).toList();
      onProgress?.call('Gravando $table (${toLocal.length})…');
      await _insertRows(db, table, toLocal);
    }

    onProgress?.call('Download finalizado.');
  }

  Future<void> _sanitizeLocalIds() async {
    for (final table in _pushOrder) {
      await _fixInvalidIdsCascade(table);
    }
  }

  Future<void> _pushTablesToRemote({
    Progress? onProgress,
    int chunk = 500,
  }) async {
    final db = _appDb.db;
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
        final end = (i + chunk) > payload.length ? payload.length : i + chunk;
        final part = payload.sublist(i, end);
        await _client.from(table).upsert(part);
      }
    }
  }

  Future<void> _syncRemoteDeletions({Progress? onProgress}) async {
    final db = _appDb.db;
    for (final table in _deleteChildFirst) {
      onProgress?.call('Sincronizando exclusões em $table…');

      final localIds = (await db.query(table, columns: ['id']))
          .map((m) => (m['id'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet();

      final remoteIds = (await _client.from(table).select('id'))
          .map<String>((e) => (e['id'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet();

      final toDelete = remoteIds.difference(localIds).toList();
      if (toDelete.isEmpty) continue;

      const batch = 300;
      for (var i = 0; i < toDelete.length; i += batch) {
        final end = (i + batch) > toDelete.length ? toDelete.length : i + batch;
        final part = toDelete.sublist(i, end);
        final orExpr = part.map((id) => 'id.eq.$id').join(',');
        await _client.from(table).delete().or(orExpr);
      }
    }
  }

  Future<void> _clearLocalTables(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');
      for (final table in _deleteChildFirst) {
        await txn.delete(table);
      }
      await txn.execute('PRAGMA foreign_keys = ON');
    });
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteTableRows(
    String table,
    int pageSize,
  ) async {
    final out = <Map<String, dynamic>>[];
    int from = 0;
    while (true) {
      final to = from + pageSize - 1;
      final page = await _client.from(table).select('*').range(from, to);
      if (page.isEmpty) break;
      out.addAll(page.map((e) => Map<String, dynamic>.from(e)));
      if (page.length < pageSize) break;
      from += pageSize;
    }
    return out;
  }

  Future<void> _insertRows(
    Database db,
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    await db.transaction((txn) async {
      for (final row in rows) {
        await txn.insert(
          table,
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> _fixInvalidIdsCascade(String table) async {
    final db = _appDb.db;
    final uuidRe = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    final rows = await db.rawQuery('SELECT rowid AS __rid, id FROM $table');
    final fixes = <_IdFix>[];

    for (final r in rows) {
      final old = (r['id'] ?? '').toString();
      final needFix = old.isEmpty || !uuidRe.hasMatch(old);
      if (needFix) {
        fixes.add(
          _IdFix(
            rowId: (r['__rid'] as int),
            oldId: old.isEmpty ? null : old,
            newId: _uuidV4(),
          ),
        );
      }
    }

    if (fixes.isEmpty) return;

    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');

      final refs = _fkMap[table] ?? const <_FkRef>[];
      for (final fix in fixes) {
        if (fix.oldId != null && fix.oldId!.isNotEmpty) {
          for (final ref in refs) {
            await txn.update(
              ref.childTable,
              {ref.childColumn: fix.newId},
              where: '${ref.childColumn} = ?',
              whereArgs: [fix.oldId],
            );
          }
        }

        await _updateId(txn, table, fix);
      }

      await txn.execute('PRAGMA foreign_keys = ON');
    });
  }

  Future<void> _updateId(
    DatabaseExecutor txn,
    String table,
    _IdFix fix,
  ) async {
    if (fix.oldId == null || fix.oldId!.isEmpty) {
      await txn.update(
        table,
        {'id': fix.newId},
        where: 'rowid = ?',
        whereArgs: [fix.rowId],
      );
    } else {
      await txn.update(
        table,
        {'id': fix.newId},
        where: 'id = ?',
        whereArgs: [fix.oldId],
      );
    }
  }

  static Map<String, dynamic> _toRemote(
    String table,
    Map<String, dynamic> row,
  ) {
    final r = Map<String, dynamic>.from(row);

    if (table == 'animals') r['pregnant'] = _toBool(row['pregnant']);
    if (table == 'notes') r['is_read'] = _toBool(row['is_read']);
    if (table == 'financial_accounts') {
      r['is_recurring'] = _toBool(row['is_recurring']);
    }
    if (table == 'pharmacy_stock') {
      r['is_opened'] = _toBool(row['is_opened']);
    }
    if (table == 'reports') r['parameters'] = _jsonIn(row['parameters']);
    if (table == 'push_tokens') r['device_info'] = _jsonIn(row['device_info']);

    return _only(r, _cols[table] ?? {});
  }

  static Map<String, dynamic> _toLocal(
    String table,
    Map<String, dynamic> row,
  ) {
    final r = Map<String, dynamic>.from(row);

    if (table == 'reports') r['parameters'] = _jsonOut(row['parameters']);
    if (table == 'push_tokens') {
      r['device_info'] = _jsonOut(row['device_info']);
    }

    if (table == 'animals') r['pregnant'] = _toInt01(row['pregnant']);
    if (table == 'notes') r['is_read'] = _toInt01(row['is_read']);
    if (table == 'financial_accounts') {
      r['is_recurring'] = _toInt01(row['is_recurring']);
    }
    if (table == 'pharmacy_stock') {
      r['is_opened'] = _toInt01(row['is_opened']);
    }

    if (table == 'breeding_records') {
      final ur = row['ultrasound_result'];
      final urStr = (ur ?? '').toString().toLowerCase();
      final isBoolish = ur is bool ||
          ur is num ||
          urStr == '0' ||
          urStr == '1' ||
          urStr == 'true' ||
          urStr == 'false';
      if (isBoolish) {
        r['ultrasound_result'] = _toInt01(ur);
      }
      r['stage'] = _canonStage(row['stage']);
    }

    r.updateAll(
      (k, v) => v is bool ? (v ? 1 : 0) : v,
    );

    return _only(r, _cols[table] ?? {});
  }

  static bool _missingId(dynamic v) {
    if (v == null) return true;
    final s = v.toString().trim();
    return s.isEmpty || s.toLowerCase() == 'null';
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

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final lower = v.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

  static int _toInt01(dynamic v) {
    if (v == null) return 0;
    if (v is bool) return v ? 1 : 0;
    if (v is num) return v != 0 ? 1 : 0;
    if (v is String) {
      final lower = v.toLowerCase();
      return (lower == 'true' || lower == '1') ? 1 : 0;
    }
    return 0;
  }

  static dynamic _jsonIn(dynamic v) {
    if (v == null) return {};
    if (v is Map<String, dynamic>) return v;
    if (v is String) {
      if (v.isEmpty) return {};
      try {
        return jsonDecode(v);
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  static dynamic _jsonOut(dynamic v) => (v == null) ? '{}' : jsonEncode(v);

  static Map<String, dynamic> _only(
    Map<String, dynamic> m,
    Set<String> allow,
  ) {
    final out = <String, dynamic>{};
    m.forEach((k, v) {
      if (allow.contains(k)) out[k] = v;
    });
    return out;
  }

  static String _canonStage(dynamic value) {
    final t = _deaccent((value ?? '').toString())
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');

    const map = {
      'encabritamento': 'encabritamento',
      'separacao': 'separacao',
      'aguardando_ultrassom': 'aguardando_ultrassom',
      'gestacao_confirmada': 'gestacao_confirmada',
      'gestantes': 'gestacao_confirmada',
      'gestante': 'gestacao_confirmada',
      'parto_realizado': 'parto_realizado',
      'concluido': 'parto_realizado',
      'concluidos': 'parto_realizado',
      'falhou': 'falhou',
      'falhado': 'falhou',
      'falhados': 'falhou',
    };

    return map[t] ?? 'encabritamento';
  }

  static String _deaccent(String s) {
    const map = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'ê': 'e',
      'è': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ò': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'ç': 'c',
      'Á': 'A',
      'À': 'A',
      'Ã': 'A',
      'Â': 'A',
      'Ä': 'A',
      'É': 'E',
      'Ê': 'E',
      'È': 'E',
      'Ë': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Ï': 'I',
      'Ó': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ò': 'O',
      'Ö': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Ü': 'U',
      'Ç': 'C',
    };
    final sb = StringBuffer();
    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      sb.write(map[ch] ?? ch);
    }
    return sb.toString();
  }
}

class _FkRef {
  final String childTable;
  final String childColumn;
  const _FkRef(this.childTable, this.childColumn);
}

class _IdFix {
  final int rowId;
  final String? oldId;
  final String newId;

  _IdFix({
    required this.rowId,
    required this.oldId,
    required this.newId,
  });
}
