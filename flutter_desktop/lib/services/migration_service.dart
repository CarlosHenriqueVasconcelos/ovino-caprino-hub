// lib/services/migration_service.dart
import 'package:flutter/foundation.dart';
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
}
