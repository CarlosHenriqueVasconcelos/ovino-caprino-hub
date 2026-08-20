import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show Variable;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'drift/app_database.dart';

typedef Progress = void Function(String step);

class BackupRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;
  final SupabaseClient Function() _clientProvider;

  BackupRepository({
    required AppDriftDatabase database,
    required SupabaseClient Function() clientProvider,
    String? Function()? farmIdProvider,
  })  : _db = database,
        _farmIdProvider = farmIdProvider,
        _clientProvider = clientProvider;

  String? get _farmId => _farmIdProvider?.call();
  SupabaseClient get _client => _clientProvider();

  static const List<String> _pushOrder = [
    'animals',
    'sold_animals',
    'deceased_animals',
    'feeding_pens',
    'feeding_schedules',
    'app_settings',
    'animal_lineage_meta',
    'animal_lineage',
    'financial_accounts',
    'financial_records',
    'notes',
    'matrix_evaluations',
    'pharmacy_stock',
    'pharmacy_stock_movements',
    'vaccinations',
    'medications',
    'animal_weights',
    'breeding_records',
    'weight_alerts',
    'reports',
    'push_tokens',
  ];

  static const Set<String> _farmScopedTables = {
    'animals',
    'sold_animals',
    'deceased_animals',
    'feeding_pens',
    'feeding_schedules',
    'app_settings',
    'animal_lineage_meta',
    'animal_lineage',
    'financial_accounts',
    'financial_records',
    'notes',
    'matrix_evaluations',
    'pharmacy_stock',
    'pharmacy_stock_movements',
    'vaccinations',
    'medications',
    'animal_weights',
    'breeding_records',
    'weight_alerts',
    'reports',
  };

  static const List<String> _deleteChildFirst = [
    'pharmacy_stock_movements',
    'medications',
    'vaccinations',
    'animal_weights',
    'weight_alerts',
    'breeding_records',
    'feeding_schedules',
    'notes',
    'matrix_evaluations',
    'financial_records',
    'financial_accounts',
    'reports',
    'push_tokens',
    'animal_lineage',
    'animal_lineage_meta',
    'app_settings',
    'pharmacy_stock',
    'feeding_pens',
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
      _FkRef('matrix_evaluations', 'animal_id'),
      _FkRef('weight_alerts', 'animal_id'),
    ],
    'financial_accounts': const [
      _FkRef('financial_accounts', 'parent_id'),
    ],
    'pharmacy_stock': const [
      _FkRef('pharmacy_stock_movements', 'pharmacy_stock_id'),
      _FkRef('medications', 'pharmacy_stock_id'),
    ],
    'medications': const [
      _FkRef('pharmacy_stock_movements', 'medication_id'),
    ],
  };

  static final Map<String, Set<String>> _cols = {
    'animals': {
      'id',
      'farm_id',
      'code',
      'name',
      'species',
      'breed',
      'gender',
      'birth_date',
      'weight',
      'status',
      'reproductive_status',
      'location',
      'last_vaccination',
      'pregnant',
      'expected_delivery',
      'health_issue',
      'registration_note',
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
      'farm_id',
      'animal_id',
      'date',
      'weight',
      'milestone',
      'created_at',
      'updated_at',
    },
    'weight_alerts': {
      'id',
      'farm_id',
      'animal_id',
      'alert_type',
      'due_date',
      'completed',
      'created_at',
      'updated_at',
    },
    'breeding_records': {
      'id',
      'farm_id',
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
    'feeding_pens': {
      'id',
      'farm_id',
      'name',
      'number',
      'notes',
      'created_at',
      'updated_at',
    },
    'feeding_schedules': {
      'id',
      'farm_id',
      'pen_id',
      'feed_type',
      'quantity',
      'times_per_day',
      'feeding_times',
      'notes',
      'created_at',
      'updated_at',
    },
    'financial_accounts': {
      'id',
      'farm_id',
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
      'farm_id',
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
      'farm_id',
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
      'pharmacy_stock_id',
      'quantity_used',
    },
    'notes': {
      'id',
      'farm_id',
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
    'matrix_evaluations': {
      'id',
      'farm_id',
      'animal_id',
      'evaluation_date',
      'fertility_score',
      'maternal_score',
      'health_score',
      'temperament_score',
      'growth_score',
      'hoof_condition',
      'verminosis_level',
      'twinning_history',
      'lambing_weight',
      'weaning_weight',
      'lactation_score',
      'body_condition_score',
      'dentition_score',
      'age_months',
      'final_score',
      'recommendation',
      'notes',
      'created_at',
      'updated_at',
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
      'farm_id',
      'title',
      'report_type',
      'parameters',
      'generated_at',
      'generated_by',
    },
    'sold_animals': {
      'id',
      'farm_id',
      'original_animal_id',
      'code',
      'name',
      'species',
      'breed',
      'gender',
      'birth_date',
      'weight',
      'location',
      'reproductive_status',
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
      'registration_note',
      'sale_date',
      'sale_price',
      'buyer',
      'sale_notes',
      'created_at',
      'updated_at',
    },
    'deceased_animals': {
      'id',
      'farm_id',
      'original_animal_id',
      'code',
      'name',
      'species',
      'breed',
      'gender',
      'birth_date',
      'weight',
      'location',
      'reproductive_status',
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
      'registration_note',
      'death_date',
      'cause_of_death',
      'death_notes',
      'created_at',
      'updated_at',
    },
    'app_settings': {
      'farm_id',
      'setting_key',
      'setting_value',
      'updated_at',
    },
    'animal_lineage': {
      'farm_id',
      'descendant_id',
      'ancestor_id',
      'depth',
      'line_type',
      'created_at',
      'updated_at',
    },
    'animal_lineage_meta': {
      'farm_id',
      'meta_key',
      'meta_value',
      'updated_at',
    },
    'vaccinations': {
      'id',
      'farm_id',
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
      'farm_id',
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
      'farm_id',
      'pharmacy_stock_id',
      'medication_id',
      'movement_type',
      'quantity',
      'reason',
      'created_at',
    },
  };

  static bool _isFarmScopedTable(String table) =>
      _farmScopedTables.contains(table);

  List<Variable<Object>> _asVariables(List<Object?> args) {
    return args
        .map((arg) => Variable<Object>(arg as Object))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _select(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _db.customSelect(
      sql,
      variables: _asVariables(args),
    ).get();
    return rows.map((row) => Map<String, dynamic>.from(row.data)).toList();
  }

  Future<void> _insert(String table, Map<String, dynamic> row) async {
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    final args = cols.map((col) => row[col]).toList(growable: false);
    await _db.customStatement(
      'INSERT INTO $table (${cols.join(',')}) VALUES ($placeholders)',
      args,
    );
  }

  Future<void> backupMirrorRemote({
    Progress? onProgress,
    int chunk = 500,
  }) async {
    final farmId = _farmId;
    if (farmId == null) {
      onProgress?.call('Fazenda não identificada. Backup cancelado.');
      return;
    }
    onProgress?.call('Verificando/ajustando IDs inválidos…');
    await _sanitizeIds(farmId);
    await _pushTablesToRemote(
      farmId: farmId,
      onProgress: onProgress,
      chunk: chunk,
    );
    await _syncRemoteDeletions(farmId: farmId, onProgress: onProgress);
    onProgress?.call('Upload finalizado.');
  }

  Future<void> restoreFromRemote({
    Progress? onProgress,
    int pageSize = 1000,
  }) async {
    final farmId = _farmId;
    if (farmId == null) {
      onProgress?.call('Fazenda não identificada. Restauração cancelada.');
      return;
    }
    await _restoreFromRemote(
      farmId: farmId,
      onProgress: onProgress,
      pageSize: pageSize,
    );
  }

  Future<void> _restoreFromRemote({
    required String farmId,
    Progress? onProgress,
    int pageSize = 1000,
  }) async {
    onProgress?.call('Validando estrutura remota e baixando dados…');
    final remoteByTable = <String, List<Map<String, dynamic>>>{};
    for (final table in _pushOrder) {
      if (!_isFarmScopedTable(table)) continue;
      onProgress?.call('Baixando $table…');
      final rows = await _fetchRemoteTableRows(
        table,
        pageSize,
        farmId: farmId,
      );
      remoteByTable[table] = rows;
    }

    onProgress?.call('Aplicando restauração local…');
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await _db.transaction(() async {
        for (final table in _deleteChildFirst) {
          if (!_isFarmScopedTable(table)) continue;
          await _db.customStatement(
            'DELETE FROM $table WHERE farm_id = ?',
            [farmId],
          );
        }

        for (final table in _pushOrder) {
          if (!_isFarmScopedTable(table)) continue;
          final rows = remoteByTable[table] ?? const <Map<String, dynamic>>[];
          if (rows.isEmpty) continue;
          final toLocal = rows
              .map((r) => _toLocal(table, r, farmId: farmId))
              .toList(growable: false);
          onProgress?.call('Gravando $table (${toLocal.length})…');
          for (final row in toLocal) {
            await _insert(table, row);
          }
        }
      });
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }

    onProgress?.call('Download finalizado.');
  }

  Future<void> _sanitizeIds(String farmId) async {
    for (final table in _pushOrder) {
      if (!_tableHasIdColumn(table)) continue;
      if (!_isFarmScopedTable(table)) continue;
      await _fixInvalidIdsCascade(table, farmId);
    }
  }

  Future<void> _fixInvalidIdsCascade(String table, String farmId) async {
    final uuidRe = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    final rows = await _select(
      'SELECT rowid AS __rid, id FROM $table WHERE farm_id = ?',
      [farmId],
    );
    final fixes = <_IdFix>[];
    for (final row in rows) {
      final old = (row['id'] ?? '').toString();
      final needFix = old.isEmpty || !uuidRe.hasMatch(old);
      if (needFix) {
        fixes.add(
          _IdFix(
            rowId: (row['__rid'] as int),
            oldId: old.isEmpty ? null : old,
            newId: _uuidV4(),
          ),
        );
      }
    }
    if (fixes.isEmpty) return;

    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await _db.transaction(() async {
        final refs = _fkMap[table] ?? const <_FkRef>[];
        for (final fix in fixes) {
          if (fix.oldId != null && fix.oldId!.isNotEmpty) {
            for (final ref in refs) {
              if (_isFarmScopedTable(ref.childTable)) {
                await _db.customStatement(
                  '''
                  UPDATE ${ref.childTable}
                  SET ${ref.childColumn} = ?
                  WHERE farm_id = ? AND ${ref.childColumn} = ?
                  ''',
                  [fix.newId, farmId, fix.oldId],
                );
              } else {
                await _db.customStatement(
                  '''
                  UPDATE ${ref.childTable}
                  SET ${ref.childColumn} = ?
                  WHERE ${ref.childColumn} = ?
                  ''',
                  [fix.newId, fix.oldId],
                );
              }
            }
          }
          await _updateId(table, farmId, fix);
        }
      });
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _updateId(String table, String farmId, _IdFix fix) async {
    if (fix.oldId == null || fix.oldId!.isEmpty) {
      await _db.customStatement(
        'UPDATE $table SET id = ? WHERE farm_id = ? AND rowid = ?',
        [fix.newId, farmId, fix.rowId],
      );
      return;
    }
    await _db.customStatement(
      'UPDATE $table SET id = ? WHERE farm_id = ? AND id = ?',
      [fix.newId, farmId, fix.oldId],
    );
  }

  Future<void> _pushTablesToRemote({
    required String farmId,
    Progress? onProgress,
    int chunk = 500,
  }) async {
    for (final table in _pushOrder) {
      if (!_isFarmScopedTable(table)) continue;
      onProgress?.call('Preparando $table…');
      final rows = await _select(
        'SELECT * FROM $table WHERE farm_id = ?',
        [farmId],
      );
      if (rows.isEmpty) continue;

      final payload = rows
          .map((r) => _toRemote(table, r, farmId: farmId))
          .toList(growable: false);
      final hasIdColumn = _tableHasIdColumn(table);
      for (final row in payload) {
        if (hasIdColumn && _missingId(row['id'])) {
          row['id'] = _uuidV4();
        }
      }

      onProgress?.call('Enviando $table (${payload.length})…');
      for (var i = 0; i < payload.length; i += chunk) {
        final end = (i + chunk) > payload.length ? payload.length : i + chunk;
        final part = payload.sublist(i, end);
        await _upsertChunk(table, part, farmId: farmId);
      }
    }
  }

  Future<void> _upsertChunk(
    String table,
    List<Map<String, dynamic>> part, {
    String? farmId,
  }) async {
    final payload = part
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
    if (farmId != null && _isFarmScopedTable(table)) {
      for (final row in payload) {
        row['farm_id'] = row['farm_id'] ?? farmId;
      }
    }

    switch (table) {
      case 'app_settings':
        await _client.from(table).upsert(
              payload,
              onConflict:
                  farmId == null ? 'setting_key' : 'farm_id,setting_key',
            );
        return;
      case 'animal_lineage':
        await _client
            .from(table)
            .upsert(payload, onConflict: 'descendant_id,ancestor_id');
        return;
      case 'animal_lineage_meta':
        await _client.from(table).upsert(
              payload,
              onConflict: farmId == null ? 'meta_key' : 'meta_key,farm_id',
            );
        return;
      default:
        await _client.from(table).upsert(payload);
    }
  }

  Future<void> _syncRemoteDeletions({
    required String farmId,
    Progress? onProgress,
  }) async {
    for (final table in _deleteChildFirst) {
      if (!_isFarmScopedTable(table)) continue;
      onProgress?.call('Sincronizando exclusões em $table…');
      if (_tableHasIdColumn(table)) {
        await _syncRemoteDeletionsById(table, farmId);
        continue;
      }

      if (table == 'app_settings') {
        await _syncRemoteDeletionsBySingleKey(
          table: table,
          keyColumn: 'setting_key',
          farmId: farmId,
        );
        continue;
      }

      if (table == 'animal_lineage_meta') {
        await _syncRemoteDeletionsBySingleKey(
          table: table,
          keyColumn: 'meta_key',
          farmId: farmId,
        );
        continue;
      }

      if (table == 'animal_lineage') {
        await _syncRemoteDeletionsLineage(farmId);
      }
    }
  }

  Future<void> _syncRemoteDeletionsById(String table, String farmId) async {
    final localIds = (await _select(
      'SELECT id FROM $table WHERE farm_id = ?',
      [farmId],
    ))
        .map((row) => (row['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();

    final remoteIds = (await _client
            .from(table)
            .select('id')
            .eq('farm_id', farmId))
        .map<String>((row) => (row['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();

    final toDelete = remoteIds.difference(localIds).toList(growable: false);
    if (toDelete.isEmpty) return;

    const batch = 300;
    for (var i = 0; i < toDelete.length; i += batch) {
      final end = (i + batch) > toDelete.length ? toDelete.length : i + batch;
      final part = toDelete.sublist(i, end);
      final orExpr = part.map((id) => 'id.eq.$id').join(',');
      await _client.from(table).delete().eq('farm_id', farmId).or(orExpr);
    }
  }

  Future<void> _syncRemoteDeletionsBySingleKey({
    required String table,
    required String keyColumn,
    required String farmId,
  }) async {
    final localKeys = (await _select(
      'SELECT $keyColumn FROM $table WHERE farm_id = ?',
      [farmId],
    ))
        .map((row) => (row[keyColumn] ?? '').toString())
        .where((key) => key.isNotEmpty)
        .toSet();

    final remoteKeys = (await _client
            .from(table)
            .select(keyColumn)
            .eq('farm_id', farmId))
        .map<String>((row) => (row[keyColumn] ?? '').toString())
        .where((key) => key.isNotEmpty)
        .toSet();

    final toDelete = remoteKeys.difference(localKeys);
    for (final key in toDelete) {
      await _client
          .from(table)
          .delete()
          .eq('farm_id', farmId)
          .eq(keyColumn, key);
    }
  }

  Future<void> _syncRemoteDeletionsLineage(String farmId) async {
    final localRows = await _select(
      '''
      SELECT descendant_id, ancestor_id
      FROM animal_lineage
      WHERE farm_id = ?
      ''',
      [farmId],
    );
    final localKeys = localRows
        .map(
          (row) =>
              '${(row['descendant_id'] ?? '').toString()}|${(row['ancestor_id'] ?? '').toString()}',
        )
        .where((key) => !key.startsWith('|') && !key.endsWith('|'))
        .toSet();

    final remoteRows = await _client
        .from('animal_lineage')
        .select('descendant_id,ancestor_id')
        .eq('farm_id', farmId);
    final remoteKeys = remoteRows
        .map<String>(
          (row) =>
              '${(row['descendant_id'] ?? '').toString()}|${(row['ancestor_id'] ?? '').toString()}',
        )
        .where((key) => !key.startsWith('|') && !key.endsWith('|'))
        .toSet();

    final toDelete = remoteKeys.difference(localKeys);
    for (final key in toDelete) {
      final parts = key.split('|');
      if (parts.length != 2) continue;
      await _client
          .from('animal_lineage')
          .delete()
          .eq('farm_id', farmId)
          .eq('descendant_id', parts[0])
          .eq('ancestor_id', parts[1]);
    }
  }

  static bool _tableHasIdColumn(String table) {
    final cols = _cols[table];
    if (cols == null) return false;
    return cols.contains('id');
  }

  Future<List<Map<String, dynamic>>> _fetchRemoteTableRows(
    String table,
    int pageSize, {
    String? farmId,
  }) async {
    try {
      final out = <Map<String, dynamic>>[];
      int from = 0;
      while (true) {
        final to = from + pageSize - 1;
        dynamic query = _client.from(table).select('*');
        if (farmId != null && _isFarmScopedTable(table)) {
          query = query.eq('farm_id', farmId);
        }
        final page = await query.range(from, to);
        if (page.isEmpty) break;
        out.addAll(page.map((e) => Map<String, dynamic>.from(e)));
        if (page.length < pageSize) break;
        from += pageSize;
      }
      return out;
    } catch (e) {
      throw Exception('Falha ao baixar tabela "$table": $e');
    }
  }

  static Map<String, dynamic> _toRemote(
    String table,
    Map<String, dynamic> row, {
    String? farmId,
  }) {
    final r = Map<String, dynamic>.from(row);
    if (farmId != null && _isFarmScopedTable(table)) {
      r['farm_id'] = farmId;
    }

    if (table == 'animals') r['pregnant'] = _toBool(row['pregnant']);
    if (table == 'notes') r['is_read'] = _toBool(row['is_read']);
    if (table == 'financial_accounts') {
      r['is_recurring'] = _toBool(row['is_recurring']);
    }
    if (table == 'pharmacy_stock') {
      r['is_opened'] = _toBool(row['is_opened']);
    }
    if (table == 'weight_alerts') {
      r['completed'] = _toBool(row['completed']);
    }
    if (table == 'reports') r['parameters'] = _jsonIn(row['parameters']);
    if (table == 'push_tokens') r['device_info'] = _jsonIn(row['device_info']);

    return _only(r, _cols[table] ?? {});
  }

  static Map<String, dynamic> _toLocal(
    String table,
    Map<String, dynamic> row, {
    String? farmId,
  }) {
    final r = Map<String, dynamic>.from(row);
    if (farmId != null && _isFarmScopedTable(table)) {
      r['farm_id'] = farmId;
    }

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
    if (table == 'weight_alerts') {
      r['completed'] = _toInt01(row['completed']);
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
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'ê': 'e', 'è': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i',
      'ó': 'o', 'ô': 'o', 'õ': 'o', 'ò': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u',
      'ç': 'c',
      'Á': 'A', 'À': 'A', 'Ã': 'A', 'Â': 'A', 'Ä': 'A',
      'É': 'E', 'Ê': 'E', 'È': 'E', 'Ë': 'E',
      'Í': 'I', 'Ì': 'I', 'Ï': 'I',
      'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ò': 'O', 'Ö': 'O',
      'Ú': 'U', 'Ù': 'U', 'Ü': 'U',
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
