import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../app/app_logging.dart';
import '../data/drift/app_database.dart';
import 'auth_service.dart';

enum SyncStatus { idle, syncing, success, error }

/// Sincroniza dados entre Drift local e Supabase.
///
/// Estratégia:
///   - LWW por timestamp (`updated_at`/equivalente) para conflitos de update.
///   - Tombstones para propagar exclusões entre dispositivos.
///   - Push/Pull incremental por tenant (`farm_id`).
///
/// O banco local usa AppDriftDatabase (fazenda_drift.db) que já tem farm_id
/// em todas as tabelas — compatível com o schema do Supabase.
class SyncService extends ChangeNotifier {
  static const Uuid _uuid = Uuid();
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{12}$',
  );

  final AppDriftDatabase _db;
  final AuthService _auth;

  SyncStatus _status = SyncStatus.idle;
  String? _lastError;
  DateTime? _lastSyncAt;
  bool _syncEnabled = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicSyncTimer;
  DateTime? _lastReachabilityCheckAt;
  bool _lastReachability = false;
  bool _lastOfflineMode = false;
  String? _lastKnownFarmId;
  final Set<String> _preparedFarmIds = <String>{};

  // Cache de colunas locais por tabela — populado lazily, válido por sessão.
  final Map<String, Set<String>> _localColumnCache = {};

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncAt => _lastSyncAt;
  bool get isSyncing => _status == SyncStatus.syncing;
  bool get syncEnabled => _syncEnabled;

  SyncService(this._db, this._auth);

  /// Carrega preferências e inicia listener de conectividade.
  Future<void> initialize() async {
    final val = await _readScopedSetting(
      'sync_enabled',
      farmId: _auth.currentFarmId,
    );
    _syncEnabled = val != '0';
    await _ensureSyncDeviceId();

    _lastOfflineMode = _auth.isOfflineMode;
    _lastKnownFarmId = _auth.currentFarmId;
    _auth.removeListener(_handleAuthStateChanged);
    _auth.addListener(_handleAuthStateChanged);

    // Auto-sync sempre que a rede voltar
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && _syncEnabled) sync();
    });

    // Sync periodico para reduzir divergencias entre dispositivos.
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (_syncEnabled) sync();
    });
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthStateChanged);
    _connectivitySub?.cancel();
    _periodicSyncTimer?.cancel();
    super.dispose();
  }

  void _handleAuthStateChanged() {
    final isOffline = _auth.isOfflineMode;
    final farmId = _auth.currentFarmId;
    final wasOffline = _lastOfflineMode;
    final previousFarmId = _lastKnownFarmId;

    _lastOfflineMode = isOffline;
    _lastKnownFarmId = farmId;

    if (!_syncEnabled) return;

    // Sessão Supabase foi restaurada após fast path offline.
    if (wasOffline && !isOffline) {
      unawaited(sync());
      return;
    }

    // Primeiro login no ciclo atual (farm passou de nulo para valor).
    if (previousFarmId == null && farmId != null && !isOffline) {
      unawaited(sync());
    }
  }

  /// Liga/desliga o sync automático e persiste a preferência.
  Future<void> setSyncEnabled(bool enabled) async {
    _syncEnabled = enabled;
    await _saveScopedSetting(
      'sync_enabled',
      enabled ? '1' : '0',
      farmId: _auth.currentFarmId,
    );
    notifyListeners();
  }

  static const String _tombstoneTable = 'sync_tombstones';
  static const String _tombstoneSuppressionSettingKey =
      'sync_suppress_tombstone';

  // Ordem de push respeita dependências FK (pai antes do filho).
  static const _dataTables = [
    'animals',
    'sold_animals',
    'deceased_animals',
    'feeding_pens',
    'feeding_schedules',
    'financial_accounts',
    'financial_records',
    'notes',
    'matrix_evaluations',
    'pharmacy_stock',
    'medications',
    'pharmacy_stock_movements',
    'vaccinations',
    'animal_weights',
    'breeding_records',
    'weight_alerts',
    'reports',
  ];

  static const _syncTables = [
    _tombstoneTable,
    ..._dataTables,
  ];

  // Tabelas sem updated_at usam coluna alternativa para filtragem.
  static const _altTsCol = <String, String>{
    'pharmacy_stock_movements': 'created_at',
    'reports': 'generated_at',
  };

  static String _tsCol(String table) => _altTsCol[table] ?? 'updated_at';

  // ── Ponto de entrada público ─────────────────────────────────

  Future<void> sync() async {
    if (!_syncEnabled) return;
    if (_status == SyncStatus.syncing) return;
    if (_auth.isOfflineMode) return; // sem sessão Supabase válida
    final farmId = _auth.currentFarmId;
    if (farmId == null) return;
    if (!await _hasNetworkLink()) return;

    await _prepareTenantData(farmId);

    _status = SyncStatus.syncing;
    _lastError = null;
    notifyListeners();

    try {
      await _push(farmId);
      await _pull(farmId);
      _lastSyncAt = DateTime.now();
      _status = SyncStatus.success;
    } catch (e, st) {
      _lastError = e.toString();
      _status = SyncStatus.error;
      unawaited(
        logService.logError(
          'Falha de sincronização: $e',
          stackTrace: st,
          widget: 'SyncService.sync',
        ),
      );
      debugPrint('SyncService error: $e\n$st');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> _hasNetworkLink() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final hasNetworkInterface = connectivity.any(
        (r) => r != ConnectivityResult.none,
      );
      if (!hasNetworkInterface) return false;
    } catch (_) {
      // Se o plugin falhar, mantém comportamento de tentar sincronizar.
      return true;
    }

    final now = DateTime.now();
    final cachedAt = _lastReachabilityCheckAt;
    if (cachedAt != null &&
        now.difference(cachedAt) < const Duration(seconds: 8)) {
      return _lastReachability;
    }

    final reachable = await _canReachSupabase();
    _lastReachability = reachable;
    _lastReachabilityCheckAt = now;
    return reachable;
  }

  Future<bool> _canReachSupabase() async {
    HttpClient? client;
    try {
      final restUri = Uri.parse(Supabase.instance.client.rest.url);
      final probeUri = Uri(
        scheme: restUri.scheme,
        host: restUri.host,
        port: restUri.hasPort ? restUri.port : null,
        path: '/rest/v1/',
      );
      final apiKey = Supabase.instance.client.headers['apikey'];
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 2);
      final request = await client
          .getUrl(probeUri)
          .timeout(const Duration(seconds: 2));
      if (apiKey != null && apiKey.isNotEmpty) {
        request.headers.set('apikey', apiKey);
      }
      final response = await request.close().timeout(const Duration(seconds: 2));
      return response.statusCode > 0 && response.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      client?.close(force: true);
    }
  }

  // ── Push: local → Supabase ───────────────────────────────────

  Future<void> _push(String farmId) async {
    final client = Supabase.instance.client;
    final since = await _readScopedSetting('last_push_at', farmId: farmId);
    final tombstoneSince = await _readScopedSetting(
      'last_push_tombstone_at',
      farmId: farmId,
    );
    final now = DateTime.now().toUtc();
    final closedAnimalIds = await _collectClosedAnimalIds(farmId);

    try {
      await _pushTableWithLww(
        client: client,
        farmId: farmId,
        table: _tombstoneTable,
        since: tombstoneSince,
      );
      await _applyRemoteTombstones(
        client: client,
        farmId: farmId,
        since: tombstoneSince,
      );
      await _saveScopedSetting(
        'last_push_tombstone_at',
        now.toIso8601String(),
        farmId: farmId,
      );
    } catch (e, st) {
      // Tombstone push indisponível (tabela remota ou RLS ausente).
      // Dados continuam sendo enviados normalmente.
      unawaited(logService.logWarning('Tombstone push ignorado: $e'));
      debugPrint('SyncService: tombstone push skipped — $e\n$st');
    }

    for (final table in _dataTables) {
      await _pushTableWithLww(
        client: client,
        farmId: farmId,
        table: table,
        since: since,
      );
    }

    await _pushLineage(client: client, farmId: farmId, since: since);
    await _pushLineageMeta(client: client, farmId: farmId, since: since);

    await _deleteRemoteClosedAnimals(
      client: client,
      farmId: farmId,
      ids: closedAnimalIds,
    );

    await _saveScopedSetting(
      'last_push_at',
      now.toIso8601String(),
      farmId: farmId,
    );
  }

  // ── Pull: Supabase → local ───────────────────────────────────

  Future<void> _pull(String farmId) async {
    final client = Supabase.instance.client;
    final since = await _readScopedSetting('last_pull_at', farmId: farmId);
    final tombstoneSince = await _readScopedSetting(
      'last_pull_tombstone_at',
      farmId: farmId,
    );
    final now = DateTime.now().toUtc();

    var tombstoneCutoffs = <String, DateTime>{};
    try {
      await _pullTableWithLww(
        client: client,
        farmId: farmId,
        table: _tombstoneTable,
        since: tombstoneSince,
        tombstoneCutoffs: const {},
      );
      await _applyLocalTombstones(farmId);
      tombstoneCutoffs = await _loadLocalTombstoneCutoffs(farmId);
      await _saveScopedSetting(
        'last_pull_tombstone_at',
        now.toIso8601String(),
        farmId: farmId,
      );
    } catch (e, st) {
      // Tombstone pull indisponível (tabela remota ou RLS ausente).
      // Pull de dados continua com cutoffs vazios (sem filtro de deleção).
      unawaited(logService.logWarning('Tombstone pull ignorado: $e'));
      debugPrint('SyncService: tombstone pull skipped — $e\n$st');
    }

    for (final table in _dataTables) {
      await _pullTableWithLww(
        client: client,
        farmId: farmId,
        table: table,
        since: since,
        tombstoneCutoffs: tombstoneCutoffs,
      );
    }

    await _pullLineage(client: client, farmId: farmId, since: since);
    await _pullLineageMeta(client: client, farmId: farmId, since: since);

    await _withTombstoneSuppressed(() async {
      await _reconcileClosedAnimalsLocally(farmId);
    });

    await _saveScopedSetting(
      'last_pull_at',
      now.toIso8601String(),
      farmId: farmId,
    );
  }

  // ── Schema local (PRAGMA table_info) ────────────────────────

  Future<Set<String>> _localColumns(String table) async {
    if (_localColumnCache.containsKey(table)) return _localColumnCache[table]!;
    final rows = await _db.customSelect('PRAGMA table_info($table)').get();
    final cols = rows
        .map((r) => r.data['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();
    _localColumnCache[table] = cols;
    return cols;
  }

  // ── Fetch paginado do Supabase ───────────────────────────────

  static const int _supabasePageSize = 1000;

  Future<List<Map<String, dynamic>>> _fetchAllRemoteRows({
    required SupabaseClient client,
    required String table,
    required String farmId,
    required String tsCol,
    required String? since,
  }) async {
    final all = <Map<String, dynamic>>[];
    var from = 0;

    while (true) {
      final base = client.from(table).select().eq('farm_id', farmId);
      final List<Map<String, dynamic>> page;

      if (since != null) {
        page = List<Map<String, dynamic>>.from(
          await base
              .gt(tsCol, since)
              .range(from, from + _supabasePageSize - 1),
        );
      } else {
        page = List<Map<String, dynamic>>.from(
          await base.range(from, from + _supabasePageSize - 1),
        );
      }

      all.addAll(page);
      if (page.length < _supabasePageSize) break;
      from += _supabasePageSize;
    }

    return all;
  }

  // ── Conversor remoto → local ─────────────────────────────────

  /// Preserva farm_id e converte bool → 0/1 para SQLite/Drift.
  Map<String, dynamic> _toLocal(Map<String, dynamic> remote) {
    final r = Map<String, dynamic>.from(remote);
    for (final key in r.keys.toList()) {
      final v = r[key];
      if (v is bool) r[key] = v ? 1 : 0;
    }
    return r;
  }

  Future<void> _prepareTenantData(String farmId) async {
    if (_preparedFarmIds.contains(farmId)) return;

    for (final table in _syncTables) {
      await _db.customStatement(
        'UPDATE $table SET farm_id = ? WHERE farm_id IS NULL',
        [farmId],
      );
    }
    for (final table in const ['animal_lineage', 'animal_lineage_meta']) {
      await _db.customStatement(
        'UPDATE $table SET farm_id = ? WHERE farm_id IS NULL',
        [farmId],
      );
    }
    await _normalizeLegacyMatrixEvaluationIds(farmId);
    _preparedFarmIds.add(farmId);
  }

  bool _isUuid(String value) => _uuidRegex.hasMatch(value.trim());

  Future<void> _normalizeLegacyMatrixEvaluationIds(String farmId) async {
    final rows = await _db.customSelect(
      'SELECT id FROM matrix_evaluations WHERE farm_id = ?',
      variables: [Variable.withString(farmId)],
    ).get();
    if (rows.isEmpty) return;

    var converted = 0;
    for (final row in rows) {
      final oldId = row.data['id']?.toString().trim() ?? '';
      if (oldId.isEmpty || _isUuid(oldId)) continue;

      final newId = _uuid.v4();
      await _db.customStatement(
        '''
        UPDATE matrix_evaluations
        SET id = ?, updated_at = ?
        WHERE id = ? AND farm_id = ?
        ''',
        [newId, DateTime.now().toIso8601String(), oldId, farmId],
      );
      converted++;
    }

    if (converted > 0) {
      debugPrint(
        'SyncService: matrix_evaluations com ID legado convertidos para UUID: $converted',
      );
    }
  }

  Future<void> _pushTableWithLww({
    required SupabaseClient client,
    required String farmId,
    required String table,
    required String? since,
  }) async {
    final tsCol = _tsCol(table);

    final List<Map<String, dynamic>> rows;
    if (since == null) {
      rows = (await _db.customSelect(
        'SELECT * FROM $table WHERE farm_id = ?',
        variables: [Variable.withString(farmId)],
      ).get())
          .map((r) => r.data)
          .toList();
    } else {
      rows = (await _db.customSelect(
        'SELECT * FROM $table WHERE farm_id = ? AND $tsCol > ?',
        variables: [Variable.withString(farmId), Variable.withString(since)],
      ).get())
          .map((r) => r.data)
          .toList();
    }

    if (rows.isEmpty) return;

    final remoteRows = rows
        .map((r) => {
              ...r,
              'farm_id': (r['farm_id'] ?? farmId).toString(),
            })
        .toList(growable: false);

    for (var i = 0; i < remoteRows.length; i += 100) {
      final batch = remoteRows.sublist(i, min(i + 100, remoteRows.length));
      final batchIds = batch
          .map((r) => r['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList(growable: false);
      final remoteTimestamps = await _loadRemoteTimestamps(
        client: client,
        table: table,
        farmId: farmId,
        tsCol: tsCol,
        ids: batchIds,
      );

      final winners = <Map<String, dynamic>>[];
      var skipped = 0;
      for (final row in batch) {
        final id = row['id']?.toString() ?? '';
        if (id.isEmpty) {
          winners.add(row);
          continue;
        }
        final localTs = _parseTimestamp(row[tsCol]);
        final remoteTs = remoteTimestamps[id];
        if (_shouldApplyLocal(localTs: localTs, remoteTs: remoteTs)) {
          winners.add(row);
        } else {
          skipped++;
        }
      }

      if (winners.isNotEmpty) {
        await client.from(table).upsert(winners, onConflict: 'id');
      }
      if (skipped > 0) {
        debugPrint(
          'SyncService push [$table]: $skipped conflitos ignorados por LWW',
        );
      }
    }

    debugPrint('SyncService push [$table]: ${rows.length} registros');
  }

  Future<void> _pullTableWithLww({
    required SupabaseClient client,
    required String farmId,
    required String table,
    required String? since,
    required Map<String, DateTime> tombstoneCutoffs,
  }) async {
    final tsCol = _tsCol(table);

    // Pagina até esgotar — Supabase limita 1000 rows por request por padrão.
    final rows = await _fetchAllRemoteRows(
      client: client,
      table: table,
      farmId: farmId,
      tsCol: tsCol,
      since: since,
    );

    if (rows.isEmpty) return;

    final incomingIds = rows
        .map((r) => r['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final localTimestamps = await _loadLocalTimestamps(
      table: table,
      farmId: farmId,
      tsCol: tsCol,
      ids: incomingIds,
    );

    // Descobre colunas existentes no schema local para não falhar em colunas
    // novas adicionadas no Supabase antes de uma migration local ser aplicada.
    final allowedCols = await _localColumns(table);

    var skippedLww = 0;
    var skippedByTombstone = 0;
    for (final row in rows) {
      final id = row['id']?.toString() ?? '';
      final remoteTs = _parseTimestamp(row[tsCol]);

      if (id.isNotEmpty &&
          _isShadowedByTombstone(
            table: table,
            recordId: id,
            remoteTs: remoteTs,
            tombstoneCutoffs: tombstoneCutoffs,
          )) {
        skippedByTombstone++;
        continue;
      }

      if (id.isNotEmpty) {
        final localTs = localTimestamps[id];
        if (!_shouldApplyRemote(remoteTs: remoteTs, localTs: localTs)) {
          skippedLww++;
          continue;
        }
      }

      final local = _toLocal(row);
      final filtered = Map<String, dynamic>.fromEntries(
        local.entries.where((e) => allowedCols.contains(e.key)),
      );
      if (filtered.isEmpty) continue;
      final cols = filtered.keys.toList();
      final vals = filtered.values.toList();
      final placeholders = cols.map((_) => '?').join(',');
      await _db.customStatement(
        'INSERT OR REPLACE INTO $table (${cols.join(',')}) VALUES ($placeholders)',
        vals,
      );
    }

    debugPrint('SyncService pull [$table]: ${rows.length} registros');
    if (skippedLww > 0) {
      debugPrint(
        'SyncService pull [$table]: $skippedLww conflitos ignorados por LWW',
      );
    }
    if (skippedByTombstone > 0) {
      debugPrint(
        'SyncService pull [$table]: $skippedByTombstone ignorados por tombstone',
      );
    }
  }

  Future<void> _applyRemoteTombstones({
    required SupabaseClient client,
    required String farmId,
    required String? since,
  }) async {
    final rows = await _loadLocalTombstones(
      farmId: farmId,
      since: since,
    );
    if (rows.isEmpty) return;

    final grouped = <String, Set<String>>{};
    for (final row in rows) {
      final table = row['table_name']?.toString() ?? '';
      final recordId = row['record_id']?.toString() ?? '';
      if (table.isEmpty || recordId.isEmpty) continue;
      if (!_dataTables.contains(table)) continue;
      grouped.putIfAbsent(table, () => <String>{}).add(recordId);
    }

    for (final entry in grouped.entries) {
      final ids = entry.value.toList(growable: false);
      for (var i = 0; i < ids.length; i += 100) {
        final batch = ids.sublist(i, min(i + 100, ids.length));
        await client
            .from(entry.key)
            .delete()
            .eq('farm_id', farmId)
            .inFilter('id', batch);
      }
      debugPrint(
        'SyncService push [${entry.key} tombstones]: ${ids.length} registros',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _loadLocalTombstones({
    required String farmId,
    required String? since,
  }) async {
    final tsCol = _tsCol(_tombstoneTable);
    final rows = since == null
        ? await _db.customSelect(
            'SELECT * FROM $_tombstoneTable WHERE farm_id = ?',
            variables: [Variable.withString(farmId)],
          ).get()
        : await _db.customSelect(
            'SELECT * FROM $_tombstoneTable WHERE farm_id = ? AND $tsCol > ?',
            variables: [Variable.withString(farmId), Variable.withString(since)],
          ).get();

    return rows.map((r) => r.data).toList(growable: false);
  }

  Future<void> _applyLocalTombstones(String farmId) async {
    final rows = await _db.customSelect(
      '''
      SELECT table_name, record_id
      FROM $_tombstoneTable
      WHERE farm_id = ?
      ''',
      variables: [Variable.withString(farmId)],
    ).get();
    if (rows.isEmpty) return;

    final grouped = <String, Set<String>>{};
    for (final row in rows) {
      final table = row.data['table_name']?.toString() ?? '';
      final recordId = row.data['record_id']?.toString() ?? '';
      if (table.isEmpty || recordId.isEmpty) continue;
      if (!_dataTables.contains(table)) continue;
      grouped.putIfAbsent(table, () => <String>{}).add(recordId);
    }

    await _withTombstoneSuppressed(() async {
      for (final entry in grouped.entries) {
        final ids = entry.value.toList(growable: false);
        final placeholders = List.filled(ids.length, '?').join(',');
        final args = <Object?>[
          farmId,
          ...ids,
        ];
        await _db.customStatement(
          'DELETE FROM ${entry.key} WHERE farm_id = ? AND id IN ($placeholders)',
          args,
        );
      }
    });
  }

  Future<Map<String, DateTime>> _loadLocalTombstoneCutoffs(String farmId) async {
    final rows = await _db.customSelect(
      '''
      SELECT table_name, record_id, deleted_at
      FROM $_tombstoneTable
      WHERE farm_id = ?
      ''',
      variables: [Variable.withString(farmId)],
    ).get();

    final map = <String, DateTime>{};
    for (final row in rows) {
      final table = row.data['table_name']?.toString() ?? '';
      final recordId = row.data['record_id']?.toString() ?? '';
      if (table.isEmpty || recordId.isEmpty) continue;
      final deletedAt = _parseTimestamp(row.data['deleted_at']);
      if (deletedAt == null) continue;
      map['$table|$recordId'] = deletedAt;
    }
    return map;
  }

  bool _isShadowedByTombstone({
    required String table,
    required String recordId,
    required DateTime? remoteTs,
    required Map<String, DateTime> tombstoneCutoffs,
  }) {
    final cutoff = tombstoneCutoffs['$table|$recordId'];
    if (cutoff == null) return false;
    if (remoteTs == null) return true;
    return !remoteTs.isAfter(cutoff);
  }

  Future<void> _withTombstoneSuppressed(Future<void> Function() action) async {
    await _setTombstoneSuppression(enabled: true);
    try {
      await action();
    } finally {
      await _setTombstoneSuppression(enabled: false);
    }
  }

  Future<void> _setTombstoneSuppression({required bool enabled}) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        settingKey: const Value(_tombstoneSuppressionSettingKey),
        settingValue: Value(enabled ? '1' : '0'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<Set<String>> _collectClosedAnimalIds(String farmId) async {
    final rows = await _db.customSelect(
      '''
      SELECT id FROM sold_animals WHERE farm_id = ?
      UNION
      SELECT id FROM deceased_animals WHERE farm_id = ?
      ''',
      variables: [Variable.withString(farmId), Variable.withString(farmId)],
    ).get();

    return rows
        .map((r) => r.data['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> _deleteRemoteClosedAnimals({
    required SupabaseClient client,
    required String farmId,
    required Set<String> ids,
  }) async {
    if (ids.isEmpty) return;
    final sortedIds = ids.toList(growable: false);

    for (var i = 0; i < sortedIds.length; i += 100) {
      final batch = sortedIds.sublist(i, min(i + 100, sortedIds.length));
      await client
          .from('animals')
          .delete()
          .eq('farm_id', farmId)
          .inFilter('id', batch);
    }

    debugPrint(
      'SyncService push [animals cleanup]: ${sortedIds.length} registros',
    );
  }

  Future<void> _reconcileClosedAnimalsLocally(String farmId) async {
    final countRow = await _db.customSelect(
      '''
      SELECT COUNT(*) AS total
      FROM animals
      WHERE farm_id = ?
      AND id IN (
        SELECT id FROM sold_animals WHERE farm_id = ?
        UNION
        SELECT id FROM deceased_animals WHERE farm_id = ?
      )
      ''',
      variables: [
        Variable.withString(farmId),
        Variable.withString(farmId),
        Variable.withString(farmId),
      ],
    ).getSingle();

    final rawTotal = countRow.data['total'];
    final total = rawTotal is int
        ? rawTotal
        : int.tryParse(rawTotal?.toString() ?? '') ?? 0;
    if (total == 0) return;

    await _db.customStatement(
      '''
      DELETE FROM animals
      WHERE farm_id = ?
      AND id IN (
        SELECT id FROM sold_animals WHERE farm_id = ?
        UNION
        SELECT id FROM deceased_animals WHERE farm_id = ?
      )
      ''',
      [farmId, farmId, farmId],
    );

    debugPrint('SyncService pull [animals cleanup]: $total registros');
  }

  Future<Map<String, DateTime>> _loadRemoteTimestamps({
    required SupabaseClient client,
    required String table,
    required String farmId,
    required String tsCol,
    required List<String> ids,
  }) async {
    if (ids.isEmpty) return const {};
    final rows = List<Map<String, dynamic>>.from(
      await client
          .from(table)
          .select('id,$tsCol')
          .eq('farm_id', farmId)
          .inFilter('id', ids),
    );
    final map = <String, DateTime>{};
    for (final row in rows) {
      final id = row['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final ts = _parseTimestamp(row[tsCol]);
      if (ts != null) map[id] = ts;
    }
    return map;
  }

  Future<Map<String, DateTime>> _loadLocalTimestamps({
    required String table,
    required String farmId,
    required String tsCol,
    required List<String> ids,
  }) async {
    if (ids.isEmpty) return const {};
    final uniqueIds = ids.toSet().toList(growable: false);
    final placeholders = List.filled(uniqueIds.length, '?').join(',');
    final variables = [
      Variable.withString(farmId),
      ...uniqueIds.map(Variable.withString),
    ];

    final rows = await _db.customSelect(
      'SELECT id, $tsCol FROM $table WHERE farm_id = ? AND id IN ($placeholders)',
      variables: variables,
    ).get();

    final map = <String, DateTime>{};
    for (final row in rows) {
      final id = row.data['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final ts = _parseTimestamp(row.data[tsCol]);
      if (ts != null) map[id] = ts;
    }
    return map;
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }

  bool _shouldApplyLocal({
    required DateTime? localTs,
    required DateTime? remoteTs,
  }) {
    if (remoteTs == null) return true;
    if (localTs == null) return true;
    // Push usa > estrito: em empate de timestamp o pull (remoto) prevalece,
    // evitando double-upsert desnecessário no mesmo ciclo de sync.
    return localTs.isAfter(remoteTs);
  }

  bool _shouldApplyRemote({
    required DateTime? remoteTs,
    required DateTime? localTs,
  }) {
    if (localTs == null) return true;
    if (remoteTs == null) return true;
    return remoteTs.isAfter(localTs) || remoteTs.isAtSameMomentAs(localTs);
  }

  String _scopedKey(String key, String? farmId) {
    if (farmId == null || farmId.isEmpty) return key;
    return '$key@$farmId';
  }

  Future<String?> _readScopedSetting(
    String key, {
    required String? farmId,
  }) async {
    final scoped = _scopedKey(key, farmId);
    final scopedValue = await _readSetting(scoped);
    if (scopedValue != null) return scopedValue;

    // Compatibilidade retroativa: lê chave antiga não-escopada.
    return _readSetting(key);
  }

  Future<void> _saveScopedSetting(
    String key,
    String value, {
    required String? farmId,
  }) async {
    final scoped = _scopedKey(key, farmId);
    await _saveSetting(scoped, value);
  }

  // ── Persistência de configurações (app_settings Drift) ───────

  Future<String?> _readSetting(String key) async {
    final globalRows = await _db.customSelect(
      'SELECT setting_value FROM app_settings WHERE setting_key = ? AND farm_id IS NULL',
      variables: [Variable.withString(key)],
    ).get();
    if (globalRows.isNotEmpty) {
      return globalRows.first.data['setting_value']?.toString();
    }

    // Fallback defensivo para bases antigas com a mesma key fora do escopo global.
    final fallback = await _db.customSelect(
      'SELECT setting_value FROM app_settings WHERE setting_key = ?',
      variables: [Variable.withString(key)],
    ).get();
    return fallback.isNotEmpty ? fallback.first.data['setting_value']?.toString() : null;
  }

  Future<void> _saveSetting(String key, String value) async {
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        farmId: const Value(null),
        settingKey: Value(key),
        settingValue: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ── Genealogia: push/pull com chave composta ─────────────────

  Future<void> _pushLineage({
    required SupabaseClient client,
    required String farmId,
    required String? since,
  }) async {
    const table = 'animal_lineage';
    const tsCol = 'updated_at';

    final localRows = since == null
        ? (await _db.customSelect(
            'SELECT * FROM $table WHERE farm_id = ?',
            variables: [Variable.withString(farmId)],
          ).get()).map((r) => r.data).toList()
        : (await _db.customSelect(
            'SELECT * FROM $table WHERE farm_id = ? AND $tsCol > ?',
            variables: [Variable.withString(farmId), Variable.withString(since)],
          ).get()).map((r) => r.data).toList();

    if (localRows.isEmpty) return;

    final remoteAll = List<Map<String, dynamic>>.from(
      await client
          .from(table)
          .select('descendant_id,ancestor_id,$tsCol')
          .eq('farm_id', farmId),
    );
    final remoteTs = <String, DateTime>{};
    for (final r in remoteAll) {
      final key = '${r['descendant_id']}|${r['ancestor_id']}';
      final ts = _parseTimestamp(r[tsCol]);
      if (ts != null) remoteTs[key] = ts;
    }

    final winners = <Map<String, dynamic>>[];
    for (final row in localRows) {
      final key = '${row['descendant_id']}|${row['ancestor_id']}';
      final localTs = _parseTimestamp(row[tsCol]);
      if (_shouldApplyLocal(localTs: localTs, remoteTs: remoteTs[key])) {
        winners.add({...row, 'farm_id': (row['farm_id'] ?? farmId).toString()});
      }
    }
    if (winners.isEmpty) return;

    for (var i = 0; i < winners.length; i += 100) {
      final batch = winners.sublist(i, min(i + 100, winners.length));
      await client.from(table).upsert(batch, onConflict: 'descendant_id,ancestor_id');
    }
    debugPrint('SyncService push [$table]: ${localRows.length} registros');
  }

  Future<void> _pullLineage({
    required SupabaseClient client,
    required String farmId,
    required String? since,
  }) async {
    const table = 'animal_lineage';
    const tsCol = 'updated_at';

    final remoteRows = await _fetchAllRemoteRows(
      client: client,
      table: table,
      farmId: farmId,
      tsCol: tsCol,
      since: since,
    );
    if (remoteRows.isEmpty) return;

    final localAll = (await _db.customSelect(
      'SELECT descendant_id, ancestor_id, $tsCol FROM $table WHERE farm_id = ?',
      variables: [Variable.withString(farmId)],
    ).get()).map((r) => r.data).toList();
    final localTs = <String, DateTime>{};
    for (final r in localAll) {
      final key = '${r['descendant_id']}|${r['ancestor_id']}';
      final ts = _parseTimestamp(r[tsCol]);
      if (ts != null) localTs[key] = ts;
    }

    final allowedCols = await _localColumns(table);
    for (final row in remoteRows) {
      final key = '${row['descendant_id']}|${row['ancestor_id']}';
      final remote = _parseTimestamp(row[tsCol]);
      if (!_shouldApplyRemote(remoteTs: remote, localTs: localTs[key])) continue;

      final local = _toLocal(row);
      final filtered = Map<String, dynamic>.fromEntries(
        local.entries.where((e) => allowedCols.contains(e.key)),
      );
      if (filtered.isEmpty) continue;
      final cols = filtered.keys.toList();
      final placeholders = cols.map((_) => '?').join(',');
      await _db.customStatement(
        'INSERT OR REPLACE INTO $table (${cols.join(',')}) VALUES ($placeholders)',
        filtered.values.toList(),
      );
    }
    debugPrint('SyncService pull [$table]: ${remoteRows.length} registros');
  }

  Future<void> _pushLineageMeta({
    required SupabaseClient client,
    required String farmId,
    required String? since,
  }) async {
    const table = 'animal_lineage_meta';
    const tsCol = 'updated_at';

    final localRows = since == null
        ? (await _db.customSelect(
            'SELECT * FROM $table WHERE farm_id = ?',
            variables: [Variable.withString(farmId)],
          ).get()).map((r) => r.data).toList()
        : (await _db.customSelect(
            'SELECT * FROM $table WHERE farm_id = ? AND $tsCol > ?',
            variables: [Variable.withString(farmId), Variable.withString(since)],
          ).get()).map((r) => r.data).toList();

    if (localRows.isEmpty) return;

    final remoteAll = List<Map<String, dynamic>>.from(
      await client
          .from(table)
          .select('meta_key,$tsCol')
          .eq('farm_id', farmId),
    );
    final remoteTs = <String, DateTime>{};
    for (final r in remoteAll) {
      final key = r['meta_key']?.toString() ?? '';
      if (key.isEmpty) continue;
      final ts = _parseTimestamp(r[tsCol]);
      if (ts != null) remoteTs[key] = ts;
    }

    final winners = <Map<String, dynamic>>[];
    for (final row in localRows) {
      final key = row['meta_key']?.toString() ?? '';
      final localTs = _parseTimestamp(row[tsCol]);
      if (_shouldApplyLocal(localTs: localTs, remoteTs: remoteTs[key])) {
        winners.add({...row, 'farm_id': (row['farm_id'] ?? farmId).toString()});
      }
    }
    if (winners.isEmpty) return;

    for (var i = 0; i < winners.length; i += 100) {
      final batch = winners.sublist(i, min(i + 100, winners.length));
      await client.from(table).upsert(batch, onConflict: 'meta_key,farm_id');
    }
    debugPrint('SyncService push [$table]: ${localRows.length} registros');
  }

  Future<void> _pullLineageMeta({
    required SupabaseClient client,
    required String farmId,
    required String? since,
  }) async {
    const table = 'animal_lineage_meta';
    const tsCol = 'updated_at';

    final remoteRows = await _fetchAllRemoteRows(
      client: client,
      table: table,
      farmId: farmId,
      tsCol: tsCol,
      since: since,
    );
    if (remoteRows.isEmpty) return;

    final localAll = (await _db.customSelect(
      'SELECT meta_key, $tsCol FROM $table WHERE farm_id = ?',
      variables: [Variable.withString(farmId)],
    ).get()).map((r) => r.data).toList();
    final localTs = <String, DateTime>{};
    for (final r in localAll) {
      final key = r['meta_key']?.toString() ?? '';
      if (key.isEmpty) continue;
      final ts = _parseTimestamp(r[tsCol]);
      if (ts != null) localTs[key] = ts;
    }

    final allowedCols = await _localColumns(table);
    for (final row in remoteRows) {
      final key = row['meta_key']?.toString() ?? '';
      if (key.isEmpty) continue;
      final remote = _parseTimestamp(row[tsCol]);
      if (!_shouldApplyRemote(remoteTs: remote, localTs: localTs[key])) continue;

      final local = _toLocal(row);
      final filtered = Map<String, dynamic>.fromEntries(
        local.entries.where((e) => allowedCols.contains(e.key)),
      );
      if (filtered.isEmpty) continue;
      final cols = filtered.keys.toList();
      final placeholders = cols.map((_) => '?').join(',');
      await _db.customStatement(
        'INSERT OR REPLACE INTO $table (${cols.join(',')}) VALUES ($placeholders)',
        filtered.values.toList(),
      );
    }
    debugPrint('SyncService pull [$table]: ${remoteRows.length} registros');
  }

  Future<void> _ensureSyncDeviceId() async {
    final existing = await _readSetting('sync_device_id');
    if (existing != null && existing.trim().isNotEmpty) return;
    final randomPart = Random().nextInt(1 << 32).toRadixString(16);
    final deviceId = 'dev_${DateTime.now().millisecondsSinceEpoch}_$randomPart';
    await _saveSetting('sync_device_id', deviceId);
  }
}
