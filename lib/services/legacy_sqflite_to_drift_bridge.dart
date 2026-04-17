import 'package:flutter/foundation.dart';

import '../data/drift/app_database.dart';
import '../data/local_db.dart';

/// Migração incremental do banco legado (sqflite) para Drift.
///
/// Organizada em fases independentes e idempotentes por farm_id:
///   - Fase 1 (v1): animals + app_settings  — mantida para retrocompatibilidade
///   - Fase 2 (v2): todas as tabelas restantes em ordem de dependência FK
///
/// Cada fase roda apenas uma vez por fazenda (marcador salvo em app_settings).
class LegacySqfliteToDriftBridge {
  LegacySqfliteToDriftBridge({
    required AppDatabase legacyDb,
    required AppDriftDatabase driftDb,
  })  : _legacyDb = legacyDb,
        _driftDb = driftDb;

  final AppDatabase _legacyDb;
  final AppDriftDatabase _driftDb;

  // Chave v1 mantida intacta para não re-migrar installs que já rodaram a fase 1.
  static const String _markerV1 = 'legacy_bridge_animals_app_settings_v1';
  static const String _markerV2 = 'legacy_bridge_all_tables_v2';

  // Ordem respeita dependências FK: pai antes do filho.
  // animals e app_settings já são cobertos pela fase 1.
  static const _phase2Tables = [
    'animal_weights',           // FK → animals
    'breeding_records',         // FK → animals
    'matrix_evaluations',       // FK → animals
    'financial_accounts',       // FK → animals
    'financial_records',        // FK → animals
    'pharmacy_stock',           // sem FK para animals
    'medications',              // FK → animals, pharmacy_stock
    'pharmacy_stock_movements', // FK → pharmacy_stock, medications
    'notes',                    // FK → animals
    'feeding_pens',             // sem FK
    'feeding_schedules',        // FK → feeding_pens
    'vaccinations',             // FK → animals
    'sold_animals',             // sem FK
    'deceased_animals',         // sem FK
    'weight_alerts',            // FK → animals
    'reports',                  // sem FK
    'push_tokens',              // sem FK
  ];

  Future<void> migrateForFarm(String farmId) async {
    // Fase 1 — animals + app_settings (retrocompat)
    await _runPhase(
      farmId: farmId,
      markerKey: '$_markerV1:$farmId',
      body: () async {
        await _migrateAnimals(farmId);
        await _migrateAppSettings(farmId);
      },
      label: 'fase-1 (animals + app_settings)',
    );

    // Fase 2 — demais tabelas
    await _runPhase(
      farmId: farmId,
      markerKey: '$_markerV2:$farmId',
      body: () async {
        for (final table in _phase2Tables) {
          await _migrateGenericTable(farmId, table);
        }
      },
      label: 'fase-2 (tabelas restantes)',
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Future<void> _runPhase({
    required String farmId,
    required String markerKey,
    required Future<void> Function() body,
    required String label,
  }) async {
    if (await _hasMarker(markerKey)) return;

    await _driftDb.transaction(() async {
      await body();
      await _saveMarker(markerKey, farmId);
    });

    debugPrint('LegacySqfliteToDriftBridge: $label concluída para farm_id=$farmId');
  }

  /// Migração genérica: copia todas as linhas da tabela sqflite para o Drift
  /// injetando farm_id em cada linha.
  Future<void> _migrateGenericTable(String farmId, String table) async {
    final List<Map<String, dynamic>> rows;
    try {
      rows = await _legacyDb.db.query(table);
    } catch (e) {
      // Tabela pode não existir em installs antigos — ignora silenciosamente.
      debugPrint('LegacySqfliteToDriftBridge: tabela $table não existe no sqflite — pulando');
      return;
    }
    if (rows.isEmpty) return;

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw);
      row['farm_id'] = farmId;
      _normalizeTimestampColumns(row);
      await _insertOrReplace(table, row);
    }

    debugPrint('LegacySqfliteToDriftBridge: $table — ${rows.length} registros migrados');
  }

  Future<void> _migrateAnimals(String farmId) async {
    final rows = await _legacyDb.db.query('animals');
    if (rows.isEmpty) return;

    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw);
      row['farm_id'] = farmId;
      _normalizeTimestampColumns(row);
      await _insertOrReplace('animals', row);
    }
  }

  Future<void> _migrateAppSettings(String farmId) async {
    final rows = await _legacyDb.db.query('app_settings');
    if (rows.isEmpty) return;

    for (final raw in rows) {
      final key = (raw['setting_key'] ?? '').toString().trim();
      if (key.isEmpty) continue;

      // Chaves de sessão são mantidas pelo AuthService no Drift.
      if (key == 'current_farm_id' || key == 'current_user_id') continue;

      final settingValue = (raw['setting_value'] ?? '').toString();
      final updatedAt = _normalizeTimestampValue(
        raw['updated_at'] ?? DateTime.now().toUtc().toIso8601String(),
      );

      await _insertOrReplace('app_settings', {
        'farm_id': farmId,
        'setting_key': key,
        'setting_value': settingValue,
        'updated_at': updatedAt,
      });
    }
  }

  static const Set<String> _timestampColumns = {
    'created_at',
    'updated_at',
    'deleted_at',
    'generated_at',
  };

  void _normalizeTimestampColumns(Map<String, dynamic> row) {
    for (final col in _timestampColumns) {
      if (!row.containsKey(col) || row[col] == null) continue;
      row[col] = _normalizeTimestampValue(row[col]);
    }
  }

  String _normalizeTimestampValue(dynamic rawValue) {
    if (rawValue == null) return DateTime.now().toUtc().toIso8601String();
    if (rawValue is DateTime) return rawValue.toUtc().toIso8601String();

    final raw = rawValue.toString().trim();
    if (raw.isEmpty) return DateTime.now().toUtc().toIso8601String();

    final sqliteUtc = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$');
    if (sqliteUtc.hasMatch(raw)) {
      return '${raw.replaceFirst(' ', 'T')}Z';
    }

    final isoWithoutZone =
        RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?$');
    if (isoWithoutZone.hasMatch(raw)) {
      return '${raw}Z';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed.toUtc().toIso8601String();
    return raw;
  }

  Future<void> _saveMarker(String markerKey, String farmId) {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return _insertOrReplace('app_settings', {
      'farm_id': farmId,
      'setting_key': markerKey,
      'setting_value': nowIso,
      'updated_at': nowIso,
    });
  }

  Future<bool> _hasMarker(String markerKey) async {
    final row = await (_driftDb.select(_driftDb.appSettings)
          ..where((s) => s.settingKey.equals(markerKey)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> _insertOrReplace(String table, Map<String, dynamic> row) async {
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    final values = cols.map((c) => row[c]).toList(growable: false);

    await _driftDb.customStatement(
      'INSERT OR REPLACE INTO $table (${cols.join(',')}) VALUES ($placeholders)',
      values,
    );
  }
}
