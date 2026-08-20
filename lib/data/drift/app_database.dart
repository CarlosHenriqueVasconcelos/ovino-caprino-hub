// lib/data/drift/app_database.dart
//
// Banco Drift — geração de código via build_runner.
//
// Para gerar o arquivo .g.dart execute:
//   flutter pub get
//   dart run build_runner build --delete-conflicting-outputs
//
// O arquivo app_database.g.dart gerado NÃO deve ser commitado
// (adicione ao .gitignore se preferir); é sempre regenerado localmente.
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'drift_tables.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Classe principal do banco Drift.
// Lista todas as tabelas definidas em drift_tables.dart.
// ---------------------------------------------------------------------------
@DriftDatabase(tables: [
  Animals,
  AnimalWeights,
  AnimalLineage,
  AnimalLineageMeta,
  AppSettings,
  BreedingRecords,
  MatrixEvaluations,
  FinancialAccounts,
  FinancialRecords,
  PharmacyStock,
  Medications,
  PharmacyStockMovements,
  Notes,
  Reports,
  PushTokens,
  FeedingPens,
  FeedingSchedules,
  Vaccinations,
  SoldAnimals,
  DeceasedAnimals,
  WeightAlerts,
])
class AppDriftDatabase extends _$AppDriftDatabase {
  AppDriftDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  // -------------------------------------------------------------------------
  // Versão do schema — incremente junto com cada MigrationStep abaixo.
  // -------------------------------------------------------------------------
  @override
  int get schemaVersion => 1;

  // -------------------------------------------------------------------------
  // Estratégia de migração
  // -------------------------------------------------------------------------
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _ensureSyncTombstonesInfra();
          await _ensureFarmIdColumns();
          await _createIndexes();
          await _createSyncIndexes();
          await _ensureUpdatedAtTriggers();
          await _seedDefaults();
        },
        beforeOpen: (details) async {
          // Apenas o PRAGMA obrigatório — pesado em beforeOpen bloqueia o cold start.
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  // -------------------------------------------------------------------------
  // Singleton — uma única instância por processo.
  // -------------------------------------------------------------------------
  static AppDriftDatabase? _instance;

  static AppDriftDatabase get instance {
    _instance ??= AppDriftDatabase();
    return _instance!;
  }

  static void resetInstance() => _instance = null;

  static const List<String> _farmScopedTables = [
    'animals',
    'animal_weights',
    'animal_lineage',
    'animal_lineage_meta',
    'app_settings',
    'breeding_records',
    'matrix_evaluations',
    'financial_accounts',
    'financial_records',
    'pharmacy_stock',
    'medications',
    'pharmacy_stock_movements',
    'notes',
    'reports',
    'push_tokens',
    'feeding_pens',
    'feeding_schedules',
    'vaccinations',
    'sold_animals',
    'deceased_animals',
    'weight_alerts',
    'sync_tombstones',
  ];

  static const List<String> _tombstoneTrackedTables = [
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
    'pharmacy_stock_movements',
    'vaccinations',
    'medications',
    'animal_weights',
    'breeding_records',
    'weight_alerts',
    'reports',
  ];

  static const String _tombstoneSuppressionSettingKey =
      'sync_suppress_tombstone';

  Future<void> _ensureFarmIdColumns() async {
    for (final table in _farmScopedTables) {
      final exists = await _tableExists(table);
      if (!exists) continue;
      final hasFarmId = await _tableHasColumn(table, 'farm_id');
      if (hasFarmId) continue;
      await customStatement('ALTER TABLE $table ADD COLUMN farm_id TEXT');
    }
  }

  /// Cria triggers AFTER UPDATE que atualizam `updated_at` automaticamente,
  /// espelhando o comportamento já existente no sqflite (local_db.dart).
  /// A cláusula WHEN evita recursão: só dispara se `updated_at` não foi
  /// alterado pelo UPDATE original.
  Future<void> _ensureUpdatedAtTriggers() async {
    // Tabelas com PK simples `id`
    const tablesWithId = [
      'animals',
      'animal_weights',
      'breeding_records',
      'matrix_evaluations',
      'financial_accounts',
      'financial_records',
      'pharmacy_stock',
      'medications',
      'notes',
      'feeding_pens',
      'feeding_schedules',
      'vaccinations',
      'sold_animals',
      'deceased_animals',
      'weight_alerts',
    ];

    for (final table in tablesWithId) {
      final exists = await _tableExists(table);
      if (!exists) continue;
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS ${table}_updated_at
        AFTER UPDATE ON $table
        FOR EACH ROW
        WHEN NEW.updated_at = OLD.updated_at
        BEGIN
          UPDATE $table SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now')
          WHERE id = OLD.id;
        END
      ''');
    }

    // animal_lineage — PK composta (descendant_id, ancestor_id)
    if (await _tableExists('animal_lineage')) {
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS animal_lineage_updated_at
        AFTER UPDATE ON animal_lineage
        FOR EACH ROW
        WHEN NEW.updated_at = OLD.updated_at
        BEGIN
          UPDATE animal_lineage
          SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now')
          WHERE descendant_id = OLD.descendant_id
            AND ancestor_id   = OLD.ancestor_id;
        END
      ''');
    }

    // animal_lineage_meta — PK: meta_key
    if (await _tableExists('animal_lineage_meta')) {
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS animal_lineage_meta_updated_at
        AFTER UPDATE ON animal_lineage_meta
        FOR EACH ROW
        WHEN NEW.updated_at = OLD.updated_at
        BEGIN
          UPDATE animal_lineage_meta
          SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now')
          WHERE meta_key = OLD.meta_key;
        END
      ''');
    }

    // app_settings — PK: setting_key
    if (await _tableExists('app_settings')) {
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS app_settings_updated_at
        AFTER UPDATE ON app_settings
        FOR EACH ROW
        WHEN NEW.updated_at = OLD.updated_at
        BEGIN
          UPDATE app_settings
          SET updated_at = strftime('%Y-%m-%dT%H:%M:%fZ','now')
          WHERE setting_key = OLD.setting_key
            AND farm_id IS OLD.farm_id;
        END
      ''');
    }
  }

  Future<bool> _tableExists(String table) async {
    final row = await customSelect(
      '''
      SELECT 1 AS ok
      FROM sqlite_master
      WHERE type = 'table' AND name = ?
      LIMIT 1
      ''',
      variables: [Variable<String>(table)],
    ).getSingleOrNull();
    return row != null;
  }

  Future<bool> _tableHasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    final target = column.toLowerCase();
    return rows.any((row) {
      final name = row.data['name']?.toString().toLowerCase();
      return name == target;
    });
  }

  Future<void> _ensureSyncTombstonesInfra() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS sync_tombstones (
        id TEXT PRIMARY KEY,
        farm_id TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        deleted_at TEXT NOT NULL,
        deleted_by_device TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_tombstones_target
      ON sync_tombstones(farm_id, table_name, record_id)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_sync_tombstones_farm_updated
      ON sync_tombstones(farm_id, updated_at)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS idx_sync_tombstones_farm_table
      ON sync_tombstones(farm_id, table_name, deleted_at)
    ''');

    for (final table in _tombstoneTrackedTables) {
      final exists = await _tableExists(table);
      if (!exists) continue;
      await customStatement('''
        CREATE TRIGGER IF NOT EXISTS trg_sync_tombstone_$table
        AFTER DELETE ON $table
        WHEN COALESCE(
          (SELECT setting_value FROM app_settings
           WHERE setting_key = '$_tombstoneSuppressionSettingKey'
             AND farm_id = OLD.farm_id LIMIT 1),
          (SELECT setting_value FROM app_settings
           WHERE setting_key = '$_tombstoneSuppressionSettingKey'
             AND farm_id IS NULL LIMIT 1),
          '0'
        ) != '1'
        AND COALESCE(
          OLD.farm_id,
          (SELECT setting_value FROM app_settings
           WHERE setting_key = 'current_farm_id'
             AND farm_id = OLD.farm_id LIMIT 1),
          (SELECT setting_value FROM app_settings
           WHERE setting_key = 'current_farm_id'
             AND farm_id IS NULL LIMIT 1),
          ''
        ) != ''
        BEGIN
          INSERT OR REPLACE INTO sync_tombstones(
            id, farm_id, table_name, record_id, deleted_at, deleted_by_device, created_at, updated_at
          ) VALUES (
            COALESCE(OLD.farm_id, '') || '|' || '$table' || '|' || OLD.id,
            COALESCE(
              OLD.farm_id,
              (SELECT setting_value FROM app_settings
               WHERE setting_key = 'current_farm_id'
                 AND farm_id = OLD.farm_id
               LIMIT 1),
              (SELECT setting_value FROM app_settings
               WHERE setting_key = 'current_farm_id'
                 AND farm_id IS NULL
               LIMIT 1)
            ),
            '$table',
            OLD.id,
            strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
            COALESCE(
              (SELECT setting_value FROM app_settings
               WHERE setting_key = 'sync_device_id'
                 AND farm_id = OLD.farm_id
               LIMIT 1),
              (SELECT setting_value FROM app_settings
               WHERE setting_key = 'sync_device_id'
                 AND farm_id IS NULL
               LIMIT 1)
            ),
            strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
            strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
          );
        END
      ''');
    }
  }

  // =========================================================================
  // ÍNDICES
  // Espelham os índices do local_db.dart + índices de farm_id para multi-tenancy.
  // =========================================================================
  Future<void> _createIndexes() async {
    // --- farm_id: índice composto em todas as tabelas principais ---
    // Padrão: (farm_id, <coluna_mais_filtrada>) → queries isoladas por fazenda são O(log n)
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_farm ON animals(farm_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_farm_status ON animals(farm_id, status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_farm_category ON animals(farm_id, category);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animal_weights_farm ON animal_weights(farm_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_breeding_farm ON breeding_records(farm_id, stage);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_matrix_farm ON matrix_evaluations(farm_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finacc_farm ON financial_accounts(farm_id, type, status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finrec_farm ON financial_records(farm_id, type);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_farm ON pharmacy_stock(farm_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_medications_farm ON medications(farm_id, status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_notes_farm ON notes(farm_id, is_read);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_farm ON vaccinations(farm_id, status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_weight_alerts_farm ON weight_alerts(farm_id, completed);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sold_farm ON sold_animals(farm_id, sale_date DESC);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_deceased_farm ON deceased_animals(farm_id, death_date DESC);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_feeding_pens_farm ON feeding_pens(farm_id);');

    // --- animals ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_code ON animals(code);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_species ON animals(species);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_reproductive_status ON animals(reproductive_status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_category ON animals(category);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_gender ON animals(gender);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_pregnant ON animals(pregnant);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_name ON animals(name COLLATE NOCASE);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_code_nocase ON animals(code COLLATE NOCASE);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_category_gender ON animals(category, gender);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_status_category ON animals(status, category);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_pregnant_delivery ON animals(pregnant, expected_delivery);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_category_birth ON animals(category, birth_date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_birth_date ON animals(birth_date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_mother_id ON animals(mother_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_father_id ON animals(father_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_identity ON animals(name_color, category, lote);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animals_name_color ON animals(name COLLATE NOCASE, name_color);');

    // --- animal_weights ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_date ON animal_weights(animal_id, date DESC);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_milestone ON animal_weights(animal_id, milestone);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animal_weights_date ON animal_weights(date);');

    // --- animal_lineage ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animal_lineage_descendant ON animal_lineage(descendant_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animal_lineage_ancestor ON animal_lineage(ancestor_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animal_lineage_depth ON animal_lineage(depth);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_animal_lineage_desc_depth ON animal_lineage(descendant_id, depth);');

    // --- breeding_records ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_breeding_male ON breeding_records(male_animal_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_breeding_stage ON breeding_records(stage);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_breeding_status ON breeding_records(status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_breeding_female_status ON breeding_records(female_animal_id, status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_breeding_stage_status ON breeding_records(stage, status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_breeding_expected_birth ON breeding_records(expected_birth);');

    // --- matrix_evaluations ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_matrix_eval_animal ON matrix_evaluations(animal_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_matrix_eval_final_score ON matrix_evaluations(final_score DESC);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_matrix_eval_animal_date ON matrix_evaluations(animal_id, evaluation_date DESC);');

    // --- financial_accounts ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finacc_due_date ON financial_accounts(due_date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finacc_status ON financial_accounts(status);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finacc_type ON financial_accounts(type);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finacc_category ON financial_accounts(category);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finacc_animal_id ON financial_accounts(animal_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finacc_type_status_due ON financial_accounts(type, status, due_date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_finacc_type_category ON financial_accounts(type, category);');

    // --- financial_records ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_financial_animal_id ON financial_records(animal_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_financial_type_date ON financial_records(type, date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_financial_date ON financial_records(date);');

    // --- pharmacy_stock ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_name ON pharmacy_stock(medication_name COLLATE NOCASE);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_expiration ON pharmacy_stock(expiration_date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_type_name ON pharmacy_stock(medication_type, medication_name);');

    // --- medications ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_medications_status_date ON medications(status, date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_medications_status_next ON medications(status, next_date);');

    // --- notes ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_notes_animal_read ON notes(animal_id, is_read);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_notes_category_priority_read ON notes(category, priority, is_read);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_notes_read_date ON notes(is_read, date DESC);');

    // --- vaccinations ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_status ON vaccinations(animal_id, status, scheduled_date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_vaccinations_status_scheduled ON vaccinations(status, scheduled_date);');

    // --- weight_alerts ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_weight_alerts_completed_due ON weight_alerts(completed, due_date);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_weight_alerts_animal_completed ON weight_alerts(animal_id, completed);');

    // --- sold_animals ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sold_animals_sale_date ON sold_animals(sale_date DESC);');

    // --- deceased_animals ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_deceased_animals_death_date ON deceased_animals(death_date DESC);');

    // --- pharmacy_stock_movements ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_movements_stock_type ON pharmacy_stock_movements(pharmacy_stock_id, movement_type);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_movements_created ON pharmacy_stock_movements(created_at DESC);');

    // --- feeding_schedules ---
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_feeding_schedules_pen ON feeding_schedules(pen_id);');
  }

  // =========================================================================
  // ÍNDICES DE SYNC — (farm_id, updated_at) para as queries de pull incremental
  // WHERE farm_id = ? AND updated_at > ?
  // Separados de _createIndexes() para serem aplicados via migração v5.
  // =========================================================================
  Future<void> _createSyncIndexes() async {
    // Tabelas com updated_at — usada pelo sync incremental WHERE farm_id = ? AND updated_at > ?
    const tablesWithUpdatedAt = [
      'animals',
      'animal_weights',
      'animal_lineage',
      'animal_lineage_meta',
      'app_settings',
      'breeding_records',
      'matrix_evaluations',
      'financial_accounts',
      'financial_records',
      'pharmacy_stock',
      'medications',
      'notes',
      'feeding_pens',
      'feeding_schedules',
      'vaccinations',
      'sold_animals',
      'deceased_animals',
      'weight_alerts',
    ];
    for (final t in tablesWithUpdatedAt) {
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_${t}_farm_updated ON $t(farm_id, updated_at);',
      );
    }
    // pharmacy_stock_movements e push_tokens não têm updated_at — usam created_at
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_movements_farm_updated '
      'ON pharmacy_stock_movements(farm_id, created_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_push_tokens_farm_updated '
      'ON push_tokens(farm_id, created_at);',
    );
  }

  // =========================================================================
  // SEEDS (valores padrão)
  // =========================================================================
  Future<void> _seedDefaults() async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        settingKey: 'block_cousin_breeding',
        settingValue: '1',
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conexão com SQLite via drift/native.dart (LazyDatabase).
// Isola do banco sqflite existente (fazenda.db) usando arquivo diferente.
// Durante a migração ambos coexistem sem conflito.
// ---------------------------------------------------------------------------
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'FazendaDB'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File(p.join(dir.path, 'fazenda_drift.db'));
    return NativeDatabase.createInBackground(file);
  });
}
