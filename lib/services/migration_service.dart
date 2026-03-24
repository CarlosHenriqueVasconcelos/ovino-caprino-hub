// lib/services/migration_service.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart'
    show ConflictAlgorithm, Database;

/// Serviço para executar migrações do banco de dados
class MigrationService {
  /// Executa todas as migrações pendentes
  static Future<void> runMigrations(Database db) async {
    // Criar tabela de controle de migrações se não existir
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version INTEGER PRIMARY KEY,
        applied_at TEXT NOT NULL DEFAULT (datetime('now'))
      );
    ''');

    // Verificar versão atual do schema
    final result = await db.rawQuery(
      'SELECT MAX(version) as current_version FROM schema_migrations',
    );

    final dynamic raw = result.first['current_version'];
    final int currentVersion = raw == null
        ? 0
        : (raw is int)
            ? raw
            : (raw is num)
                ? raw.toInt()
                : int.tryParse(raw.toString()) ?? 0;

    // Migração v1: Atualizar categorias de animais
    if (currentVersion < 1) {
      await _runMigrationV1(db);
      await db.insert('schema_migrations', {'version': 1});
      debugPrint('✓ Migração v1 aplicada: Categorias de animais atualizadas');
    }

    // Migração v5: Adicionar campo father_id
    if (currentVersion < 5) {
      await _runMigrationV5(db);
      await db.insert('schema_migrations', {'version': 5});
      debugPrint('✓ Migração v5 aplicada: Campo father_id adicionado');
    }

    // Migração v7: Adicionar campo opened_quantity na tabela pharmacy_stock
    if (currentVersion < 7) {
      await _runMigrationV7(db);
      await db.insert('schema_migrations', {'version': 7});
      debugPrint('✓ Migração v7 aplicada: Campo opened_quantity adicionado');
    }

    // Migração v8: Adicionar campo registration_note nas tabelas de animais
    if (currentVersion < 8) {
      await _runMigrationV8(db);
      await db.insert('schema_migrations', {'version': 8});
      debugPrint(
        '✓ Migração v8 aplicada: Campo registration_note adicionado',
      );
    }

    // Migração v9: Tabelas de linhagem para validação de parentesco
    if (currentVersion < 9) {
      await _runMigrationV9(db);
      await db.insert('schema_migrations', {'version': 9});
      debugPrint(
        '✓ Migração v9 aplicada: Estruturas de animal_lineage criadas',
      );
    }

    // Migração v10: Configurações de regra de parentesco
    if (currentVersion < 10) {
      await _runMigrationV10(db);
      await db.insert('schema_migrations', {'version': 10});
      debugPrint(
        '✓ Migração v10 aplicada: Tabela app_settings criada',
      );
    }

    // Migração v11: Backfill de marcos de peso para histórico (animal_weights)
    if (currentVersion < 11) {
      await _runMigrationV11(db);
      await db.insert('schema_migrations', {'version': 11});
      debugPrint(
        '✓ Migração v11 aplicada: Marcos de peso sincronizados para histórico',
      );
    }

    // Migração v12: Avaliação de matrizes
    if (currentVersion < 12) {
      await _runMigrationV12(db);
      await db.insert('schema_migrations', {'version': 12});
      debugPrint(
        '✓ Migração v12 aplicada: Tabela matrix_evaluations criada',
      );
    }

    // Migração v13: separar status sanitário e status reprodutivo
    if (currentVersion < 13) {
      await _runMigrationV13(db);
      await db.insert('schema_migrations', {'version': 13});
      debugPrint(
        '✓ Migração v13 aplicada: Campo reproductive_status e normalização de categoria/status',
      );
    }

    // Migração v14: consolidar vendidos na tabela sold_animals
    if (currentVersion < 14) {
      await _runMigrationV14(db);
      await db.insert('schema_migrations', {'version': 14});
      debugPrint(
        '✓ Migração v14 aplicada: vendidos legados migrados para sold_animals',
      );
    }

    // Migração v15: campos técnicos para avaliação de matrizes
    if (currentVersion < 15) {
      await _runMigrationV15(db);
      await db.insert('schema_migrations', {'version': 15});
      debugPrint(
        '✓ Migração v15 aplicada: critérios técnicos de matrizes adicionados',
      );
    }

    debugPrint('✓ Todas as migrações foram aplicadas com sucesso');
  }

  /// Migração v1: Simplificar categorias de animais
  static Future<void> _runMigrationV1(Database db) async {
    await db.transaction((txn) async {
      // Atualizar animais ativos
      await txn.rawUpdate(
        "UPDATE animals SET category = 'Reprodutor' WHERE category IN ('Macho Reprodutor', 'Fêmea Reprodutora')",
      );
      await txn.rawUpdate(
        "UPDATE animals SET category = 'Borrego' WHERE category IN ('Macho Borrego', 'Fêmea Borrega')",
      );
      await txn.rawUpdate(
        "UPDATE animals SET category = 'Adulto' WHERE category IN ('Fêmea Vazia', 'Macho Vazio')",
      );

      // Atualizar animais vendidos
      await txn.rawUpdate(
        "UPDATE sold_animals SET category = 'Reprodutor' WHERE category IN ('Macho Reprodutor', 'Fêmea Reprodutora')",
      );
      await txn.rawUpdate(
        "UPDATE sold_animals SET category = 'Borrego' WHERE category IN ('Macho Borrego', 'Fêmea Borrega')",
      );
      await txn.rawUpdate(
        "UPDATE sold_animals SET category = 'Adulto' WHERE category IN ('Fêmea Vazia', 'Macho Vazio')",
      );

      // Atualizar animais falecidos
      await txn.rawUpdate(
        "UPDATE deceased_animals SET category = 'Reprodutor' WHERE category IN ('Macho Reprodutor', 'Fêmea Reprodutora')",
      );
      await txn.rawUpdate(
        "UPDATE deceased_animals SET category = 'Borrego' WHERE category IN ('Macho Borrego', 'Fêmea Borrega')",
      );
      await txn.rawUpdate(
        "UPDATE deceased_animals SET category = 'Adulto' WHERE category IN ('Fêmea Vazia', 'Macho Vazio')",
      );
    });
  }

  /// Migração v5: Adicionar campo father_id
  static Future<void> _runMigrationV5(Database db) async {
    await db.transaction((txn) async {
      // Adicionar coluna father_id nas tabelas principais
      // Ignora erro se a coluna já existir
      try {
        await txn.execute('ALTER TABLE animals ADD COLUMN father_id TEXT');
      } catch (_) {
        // Coluna já existe
      }
      try {
        await txn.execute(
          'ALTER TABLE sold_animals ADD COLUMN father_id TEXT',
        );
      } catch (_) {
        // Coluna já existe
      }
      try {
        await txn.execute(
          'ALTER TABLE deceased_animals ADD COLUMN father_id TEXT',
        );
      } catch (_) {
        // Coluna já existe
      }
    });
  }

  /// Migração v7: Adicionar campo opened_quantity
  static Future<void> _runMigrationV7(Database db) async {
    await db.transaction((txn) async {
      try {
        await txn.execute(
          'ALTER TABLE pharmacy_stock ADD COLUMN opened_quantity REAL DEFAULT 0',
        );
      } catch (_) {
        // Coluna já existe
      }
    });
  }

  /// Migração v8: Adicionar campo registration_note
  static Future<void> _runMigrationV8(Database db) async {
    await db.transaction((txn) async {
      try {
        await txn.execute(
          'ALTER TABLE animals ADD COLUMN registration_note TEXT',
        );
      } catch (_) {
        // Coluna já existe
      }
      try {
        await txn.execute(
          'ALTER TABLE sold_animals ADD COLUMN registration_note TEXT',
        );
      } catch (_) {
        // Coluna já existe
      }
      try {
        await txn.execute(
          'ALTER TABLE deceased_animals ADD COLUMN registration_note TEXT',
        );
      } catch (_) {
        // Coluna já existe
      }
    });
  }

  /// Migração v9: Criar tabelas e índices de linhagem
  static Future<void> _runMigrationV9(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS animal_lineage (
          descendant_id TEXT NOT NULL,
          ancestor_id TEXT NOT NULL,
          depth INTEGER NOT NULL CHECK (depth > 0),
          line_type TEXT NOT NULL DEFAULT 'unknown'
            CHECK (line_type IN ('maternal','paternal','mixed','unknown')),
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now')),
          PRIMARY KEY (descendant_id, ancestor_id)
        );
      ''');

      await txn.execute('''
        CREATE TABLE IF NOT EXISTS animal_lineage_meta (
          meta_key TEXT PRIMARY KEY,
          meta_value TEXT NOT NULL,
          updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        );
      ''');

      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_animal_lineage_descendant ON animal_lineage(descendant_id);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_animal_lineage_ancestor ON animal_lineage(ancestor_id);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_animal_lineage_depth ON animal_lineage(depth);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_animal_lineage_desc_depth ON animal_lineage(descendant_id, depth);',
      );
    });
  }

  /// Migração v10: Tabela de configurações globais do app
  static Future<void> _runMigrationV10(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS app_settings (
          setting_key TEXT PRIMARY KEY,
          setting_value TEXT NOT NULL,
          updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        );
      ''');
      await txn.insert(
        'app_settings',
        {
          'setting_key': 'block_cousin_breeding',
          'setting_value': '1',
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });
  }

  /// Migração v11: preencher `animal_weights` a partir dos campos cache de `animals`
  static Future<void> _runMigrationV11(Database db) async {
    await db.transaction((txn) async {
      const inserts = <String>[
        '''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_birth',
          a.id,
          date(a.birth_date),
          a.birth_weight,
          'birth',
          datetime('now'),
          datetime('now')
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.birth_weight IS NOT NULL
          AND a.birth_weight > 0
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = 'birth'
          );
      ''',
        '''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_30d',
          a.id,
          date(a.birth_date, '+30 day'),
          a.weight_30_days,
          '30d',
          datetime('now'),
          datetime('now')
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.weight_30_days IS NOT NULL
          AND a.weight_30_days > 0
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = '30d'
          );
      ''',
        '''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_60d',
          a.id,
          date(a.birth_date, '+60 day'),
          a.weight_60_days,
          '60d',
          datetime('now'),
          datetime('now')
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.weight_60_days IS NOT NULL
          AND a.weight_60_days > 0
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = '60d'
          );
      ''',
        '''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_90d',
          a.id,
          date(a.birth_date, '+90 day'),
          a.weight_90_days,
          '90d',
          datetime('now'),
          datetime('now')
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.weight_90_days IS NOT NULL
          AND a.weight_90_days > 0
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = '90d'
          );
      ''',
        '''
        INSERT OR IGNORE INTO animal_weights(id, animal_id, date, weight, milestone, created_at, updated_at)
        SELECT
          'wtm_' || a.id || '_120d',
          a.id,
          date(a.birth_date, '+120 day'),
          a.weight_120_days,
          '120d',
          datetime('now'),
          datetime('now')
        FROM animals a
        WHERE a.birth_date IS NOT NULL
          AND trim(a.birth_date) != ''
          AND a.weight_120_days IS NOT NULL
          AND a.weight_120_days > 0
          AND NOT EXISTS (
            SELECT 1
            FROM animal_weights w
            WHERE w.animal_id = a.id
              AND w.milestone = '120d'
          );
      ''',
      ];

      for (final sql in inserts) {
        await txn.execute(sql);
      }
    });
  }

  /// Migração v12: estrutura base para seleção/ranking de matrizes
  static Future<void> _runMigrationV12(Database db) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS matrix_evaluations (
          id TEXT PRIMARY KEY,
          animal_id TEXT NOT NULL,
          evaluation_date TEXT NOT NULL,
          fertility_score REAL NOT NULL CHECK (fertility_score >= 0 AND fertility_score <= 10),
          maternal_score REAL NOT NULL CHECK (maternal_score >= 0 AND maternal_score <= 10),
          health_score REAL NOT NULL CHECK (health_score >= 0 AND health_score <= 10),
          temperament_score REAL NOT NULL CHECK (temperament_score >= 0 AND temperament_score <= 10),
          growth_score REAL NOT NULL CHECK (growth_score >= 0 AND growth_score <= 10),
          hoof_condition TEXT NOT NULL DEFAULT 'Sem problema',
          verminosis_level TEXT NOT NULL DEFAULT 'Nenhuma',
          twinning_history TEXT NOT NULL DEFAULT 'Sem histórico',
          lambing_weight REAL,
          weaning_weight REAL,
          lactation_score REAL NOT NULL DEFAULT 7 CHECK (lactation_score >= 0 AND lactation_score <= 10),
          body_condition_score REAL NOT NULL DEFAULT 3 CHECK (body_condition_score >= 1 AND body_condition_score <= 5),
          dentition_score REAL NOT NULL DEFAULT 7 CHECK (dentition_score >= 0 AND dentition_score <= 10),
          age_months INTEGER,
          final_score REAL NOT NULL CHECK (final_score >= 0 AND final_score <= 10),
          recommendation TEXT NOT NULL DEFAULT 'Observação',
          notes TEXT,
          created_at TEXT NOT NULL DEFAULT (datetime('now')),
          updated_at TEXT NOT NULL DEFAULT (datetime('now')),
          FOREIGN KEY (animal_id) REFERENCES animals(id)
        );
      ''');

      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_matrix_eval_animal ON matrix_evaluations(animal_id);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_matrix_eval_final_score ON matrix_evaluations(final_score DESC);',
      );
      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_matrix_eval_animal_date ON matrix_evaluations(animal_id, evaluation_date DESC);',
      );

      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS matrix_evaluations_updated_at
        AFTER UPDATE ON matrix_evaluations
        FOR EACH ROW
        WHEN NEW.updated_at = OLD.updated_at
        BEGIN
          UPDATE matrix_evaluations
             SET updated_at = datetime('now')
           WHERE id = OLD.id;
        END;
      ''');
    });
  }

  /// Migração v13: novo campo `reproductive_status` e ajustes de categoria/status
  static Future<void> _runMigrationV13(Database db) async {
    await db.transaction((txn) async {
      // Novas colunas para manter consistência entre tabelas de ciclo de vida
      for (final table in const ['animals', 'sold_animals', 'deceased_animals']) {
        try {
          await txn.execute(
            "ALTER TABLE $table ADD COLUMN reproductive_status TEXT NOT NULL DEFAULT 'Não aplicável'",
          );
        } catch (_) {
          // Coluna já existe
        }
      }

      // Categoria "Vazia" vira categoria estrutural "Matriz"
      await txn.rawUpdate(
        "UPDATE animals SET category = 'Matriz' WHERE LOWER(TRIM(COALESCE(category, ''))) = 'vazia'",
      );
      await txn.rawUpdate(
        "UPDATE sold_animals SET category = 'Matriz' WHERE LOWER(TRIM(COALESCE(category, ''))) = 'vazia'",
      );
      await txn.rawUpdate(
        "UPDATE deceased_animals SET category = 'Matriz' WHERE LOWER(TRIM(COALESCE(category, ''))) = 'vazia'",
      );

      // Preenche status reprodutivo a partir dos dados existentes (sem perder dados)
      await txn.rawUpdate('''
        UPDATE animals
           SET reproductive_status = CASE
             WHEN LOWER(TRIM(COALESCE(gender, ''))) <> 'fêmea' THEN 'Não aplicável'
             WHEN LOWER(TRIM(COALESCE(status, ''))) = 'gestante' OR COALESCE(pregnant, 0) = 1 THEN 'Gestante'
             WHEN LOWER(TRIM(COALESCE(category, ''))) = 'matriz' THEN 'Vazia'
            ELSE 'Não aplicável'
           END
         WHERE TRIM(COALESCE(reproductive_status, '')) = ''
            OR LOWER(TRIM(COALESCE(reproductive_status, ''))) = 'não aplicável';
      ''');

      // Status de saúde deve ficar sanitário (saudável/em tratamento/ferido)
      await txn.rawUpdate(
        "UPDATE animals SET status = 'Saudável' WHERE status IN ('Gestante', 'Reprodutor')",
      );

      // Sold/deceased guardam snapshot coerente de campo (não influencia fluxos ativos)
      await txn.rawUpdate('''
        UPDATE sold_animals
           SET reproductive_status = CASE
             WHEN LOWER(TRIM(COALESCE(gender, ''))) <> 'fêmea' THEN 'Não aplicável'
             WHEN LOWER(TRIM(COALESCE(category, ''))) = 'matriz' THEN 'Vazia'
             ELSE 'Não aplicável'
           END
         WHERE TRIM(COALESCE(reproductive_status, '')) = ''
            OR LOWER(TRIM(COALESCE(reproductive_status, ''))) = 'não aplicável';
      ''');
      await txn.rawUpdate('''
        UPDATE deceased_animals
           SET reproductive_status = CASE
             WHEN LOWER(TRIM(COALESCE(gender, ''))) <> 'fêmea' THEN 'Não aplicável'
             WHEN LOWER(TRIM(COALESCE(category, ''))) = 'matriz' THEN 'Vazia'
             ELSE 'Não aplicável'
           END
         WHERE TRIM(COALESCE(reproductive_status, '')) = ''
           OR LOWER(TRIM(COALESCE(reproductive_status, ''))) = 'não aplicável';
      ''');

      await txn.execute(
        'CREATE INDEX IF NOT EXISTS idx_animals_reproductive_status ON animals(reproductive_status);',
      );
    });
  }

  /// Migração v14: mover qualquer legado `status = Vendido` para sold_animals.
  static Future<void> _runMigrationV14(Database db) async {
    await db.transaction((txn) async {
      const legacySoldWhere = "LOWER(TRIM(COALESCE(status, ''))) = 'vendido'";

      await txn.execute('''
        INSERT OR IGNORE INTO sold_animals (
          id,
          original_animal_id,
          code,
          name,
          species,
          breed,
          gender,
          birth_date,
          weight,
          location,
          reproductive_status,
          name_color,
          category,
          birth_weight,
          weight_30_days,
          weight_60_days,
          weight_90_days,
          weight_120_days,
          year,
          lote,
          mother_id,
          father_id,
          registration_note,
          sale_date,
          sale_price,
          buyer,
          sale_notes,
          created_at,
          updated_at
        )
        SELECT
          a.id,
          a.id,
          a.code,
          a.name,
          a.species,
          a.breed,
          a.gender,
          a.birth_date,
          a.weight,
          a.location,
          COALESCE(NULLIF(TRIM(a.reproductive_status), ''), 'Não aplicável'),
          a.name_color,
          a.category,
          a.birth_weight,
          a.weight_30_days,
          a.weight_60_days,
          a.weight_90_days,
          a.weight_120_days,
          a.year,
          a.lote,
          a.mother_id,
          a.father_id,
          a.registration_note,
          date(COALESCE(NULLIF(TRIM(a.updated_at), ''), NULLIF(TRIM(a.created_at), ''), datetime('now'))),
          NULL,
          NULL,
          'Migração automática: status legado Vendido',
          COALESCE(NULLIF(TRIM(a.created_at), ''), datetime('now')),
          COALESCE(NULLIF(TRIM(a.updated_at), ''), datetime('now'))
        FROM animals a
        WHERE $legacySoldWhere;
      ''');

      // Solta referências opcionais para preservar histórico em tabelas auxiliares.
      await txn.rawUpdate('''
        UPDATE financial_records
           SET animal_id = NULL
         WHERE animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere);
      ''');
      await txn.rawUpdate('''
        UPDATE financial_accounts
           SET animal_id = NULL
         WHERE animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere);
      ''');
      await txn.rawUpdate('''
        UPDATE notes
           SET animal_id = NULL
         WHERE animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere);
      ''');
      await txn.rawUpdate('''
        UPDATE breeding_records
           SET female_animal_id = NULL
         WHERE female_animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere);
      ''');
      await txn.rawUpdate('''
        UPDATE breeding_records
           SET male_animal_id = NULL
         WHERE male_animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere);
      ''');

      // Remove dependências que não fazem mais sentido após venda.
      await txn.rawDelete('''
        DELETE FROM pharmacy_stock_movements
         WHERE medication_id IN (
           SELECT id FROM medications
            WHERE animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere)
         );
      ''');
      await txn.rawDelete('''
        DELETE FROM medications
         WHERE animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere);
      ''');
      await txn.rawDelete('''
        DELETE FROM vaccinations
         WHERE animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere);
      ''');
      await txn.rawDelete('''
        DELETE FROM animal_weights
         WHERE animal_id IN (SELECT id FROM animals WHERE $legacySoldWhere);
      ''');

      await txn.rawDelete('''
        DELETE FROM animals
         WHERE $legacySoldWhere;
      ''');
    });
  }

  /// Migração v15: adiciona critérios técnicos na tabela matrix_evaluations.
  static Future<void> _runMigrationV15(Database db) async {
    await db.transaction((txn) async {
      final alterStatements = <String>[
        "ALTER TABLE matrix_evaluations ADD COLUMN hoof_condition TEXT NOT NULL DEFAULT 'Sem problema'",
        "ALTER TABLE matrix_evaluations ADD COLUMN verminosis_level TEXT NOT NULL DEFAULT 'Nenhuma'",
        "ALTER TABLE matrix_evaluations ADD COLUMN twinning_history TEXT NOT NULL DEFAULT 'Sem histórico'",
        'ALTER TABLE matrix_evaluations ADD COLUMN lambing_weight REAL',
        'ALTER TABLE matrix_evaluations ADD COLUMN weaning_weight REAL',
        "ALTER TABLE matrix_evaluations ADD COLUMN lactation_score REAL NOT NULL DEFAULT 7",
        "ALTER TABLE matrix_evaluations ADD COLUMN body_condition_score REAL NOT NULL DEFAULT 3",
        "ALTER TABLE matrix_evaluations ADD COLUMN dentition_score REAL NOT NULL DEFAULT 7",
        'ALTER TABLE matrix_evaluations ADD COLUMN age_months INTEGER',
      ];

      for (final statement in alterStatements) {
        try {
          await txn.execute(statement);
        } catch (_) {
          // Coluna já existe
        }
      }

      await txn.rawUpdate('''
        UPDATE matrix_evaluations
           SET hoof_condition = 'Sem problema'
         WHERE TRIM(COALESCE(hoof_condition, '')) = '';
      ''');
      await txn.rawUpdate('''
        UPDATE matrix_evaluations
           SET verminosis_level = 'Nenhuma'
         WHERE TRIM(COALESCE(verminosis_level, '')) = '';
      ''');
      await txn.rawUpdate('''
        UPDATE matrix_evaluations
           SET twinning_history = 'Sem histórico'
         WHERE TRIM(COALESCE(twinning_history, '')) = '';
      ''');
      await txn.rawUpdate('''
        UPDATE matrix_evaluations
           SET lactation_score = 7
         WHERE lactation_score IS NULL OR lactation_score < 0 OR lactation_score > 10;
      ''');
      await txn.rawUpdate('''
        UPDATE matrix_evaluations
           SET body_condition_score = 3
         WHERE body_condition_score IS NULL OR body_condition_score < 1 OR body_condition_score > 5;
      ''');
      await txn.rawUpdate('''
        UPDATE matrix_evaluations
           SET dentition_score = 7
         WHERE dentition_score IS NULL OR dentition_score < 0 OR dentition_score > 10;
      ''');

      await txn.rawUpdate('''
        UPDATE matrix_evaluations
           SET age_months = (
             SELECT CAST(
               (julianday(matrix_evaluations.evaluation_date) - julianday(a.birth_date)) / 30.4375
               AS INTEGER
             )
             FROM animals a
             WHERE a.id = matrix_evaluations.animal_id
           )
         WHERE age_months IS NULL;
      ''');
    });
  }
}
