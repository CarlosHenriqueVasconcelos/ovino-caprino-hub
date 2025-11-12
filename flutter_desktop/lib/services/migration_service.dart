// lib/services/migration_service.dart
import 'package:sqflite_common/sqlite_api.dart' show Database;

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
      // ignore: avoid_print
      print('✓ Migração v1 aplicada: Categorias de animais atualizadas');
    }

    // Migração v5: Adicionar campo father_id
    if (currentVersion < 5) {
      await _runMigrationV5(db);
      await db.insert('schema_migrations', {'version': 5});
      // ignore: avoid_print
      print('✓ Migração v5 aplicada: Campo father_id adicionado');
    }

    // Migração v6: Adicionar índices para otimizar consultas
    if (currentVersion < 6) {
      await _runMigrationV6(db);
      await db.insert('schema_migrations', {'version': 6});
      // ignore: avoid_print
      print('✓ Migração v6 aplicada: Índices de performance adicionados');
    }

    // Migração v7: Adicionar campo opened_quantity na tabela pharmacy_stock
    if (currentVersion < 7) {
      await _runMigrationV7(db);
      await db.insert('schema_migrations', {'version': 7});
      // ignore: avoid_print
      print('✓ Migração v7 aplicada: Campo opened_quantity adicionado');
    }

    // ignore: avoid_print
    print('✓ Todas as migrações foram aplicadas com sucesso');
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

  /// Migração v6: Adicionar índices para otimizar consultas SQL
  static Future<void> _runMigrationV6(Database db) async {
    await db.transaction((txn) async {
      // Índices para vaccinations
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_status ON vaccinations(status)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_scheduled_date ON vaccinations(scheduled_date)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_animal_id ON vaccinations(animal_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_vaccinations_applied_date ON vaccinations(applied_date)');

      // Índices para medications
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_medications_status ON medications(status)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_medications_date ON medications(date)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_medications_animal_id ON medications(animal_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_medications_applied_date ON medications(applied_date)');

      // Índices para animals
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_animals_status ON animals(status)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_animals_category ON animals(category)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_animals_gender ON animals(gender)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_animals_pregnant ON animals(pregnant)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_animals_name ON animals(name COLLATE NOCASE)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_animals_code ON animals(code)');

      // Índices para breeding_records
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_breeding_stage ON breeding_records(stage)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_breeding_status ON breeding_records(status)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_breeding_female ON breeding_records(female_animal_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_breeding_male ON breeding_records(male_animal_id)');

      // Índices para weight_alerts
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_weight_alerts_completed ON weight_alerts(completed)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_weight_alerts_due_date ON weight_alerts(due_date)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_weight_alerts_animal_id ON weight_alerts(animal_id)');

      // Índices para animal_weights
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_animal_weights_animal_id ON animal_weights(animal_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_animal_weights_date ON animal_weights(date)');

      // Índices para financial_accounts
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_financial_accounts_status ON financial_accounts(status)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_financial_accounts_type ON financial_accounts(type)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_financial_accounts_due_date ON financial_accounts(due_date)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_financial_accounts_animal_id ON financial_accounts(animal_id)');

      // Índices para notes
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_notes_animal_id ON notes(animal_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(category)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_notes_date ON notes(date)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_notes_is_read ON notes(is_read)');

      // Índices para feeding_schedules
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_feeding_schedules_pen_id ON feeding_schedules(pen_id)');

      // Índices para pharmacy_stock
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_medication_name ON pharmacy_stock(medication_name)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_expiration_date ON pharmacy_stock(expiration_date)');

      // Índices para pharmacy_stock_movements
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_movements_stock_id ON pharmacy_stock_movements(pharmacy_stock_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_pharmacy_stock_movements_medication_id ON pharmacy_stock_movements(medication_id)');
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
}
