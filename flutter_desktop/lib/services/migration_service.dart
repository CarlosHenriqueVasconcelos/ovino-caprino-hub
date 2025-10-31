import 'package:sqflite/sqflite.dart';

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
      'SELECT MAX(version) as current_version FROM schema_migrations'
    );
    final currentVersion = (result.first['current_version'] as int?) ?? 0;

    // Migração v1: Atualizar categorias de animais
    if (currentVersion < 1) {
      await _runMigrationV1(db);
      await db.insert('schema_migrations', {'version': 1});
      print('✓ Migração v1 aplicada: Categorias de animais atualizadas');
    }

    // Migração v4: Gestão reprodutiva avançada
    if (currentVersion < 4) {
      await _runMigrationV4(db);
      await db.insert('schema_migrations', {'version': 4});
      print('✓ Migração v4 aplicada: Campos de reprodução avançada adicionados');
    }

    print('✓ Todas as migrações foram aplicadas com sucesso');
  }

  /// Migração v1: Simplificar categorias de animais
  static Future<void> _runMigrationV1(Database db) async {
    await db.transaction((txn) async {
      // Atualizar animais ativos
      await txn.rawUpdate(
        "UPDATE animals SET category = 'Reprodutor' WHERE category IN ('Macho Reprodutor', 'Fêmea Reprodutora')"
      );
      await txn.rawUpdate(
        "UPDATE animals SET category = 'Borrego' WHERE category IN ('Macho Borrego', 'Fêmea Borrega')"
      );
      await txn.rawUpdate(
        "UPDATE animals SET category = 'Adulto' WHERE category IN ('Fêmea Vazia', 'Macho Vazio')"
      );

      // Atualizar animais vendidos
      await txn.rawUpdate(
        "UPDATE sold_animals SET category = 'Reprodutor' WHERE category IN ('Macho Reprodutor', 'Fêmea Reprodutora')"
      );
      await txn.rawUpdate(
        "UPDATE sold_animals SET category = 'Borrego' WHERE category IN ('Macho Borrego', 'Fêmea Borrega')"
      );
      await txn.rawUpdate(
        "UPDATE sold_animals SET category = 'Adulto' WHERE category IN ('Fêmea Vazia', 'Macho Vazio')"
      );

      // Atualizar animais falecidos
      await txn.rawUpdate(
        "UPDATE deceased_animals SET category = 'Reprodutor' WHERE category IN ('Macho Reprodutor', 'Fêmea Reprodutora')"
      );
      await txn.rawUpdate(
        "UPDATE deceased_animals SET category = 'Borrego' WHERE category IN ('Macho Borrego', 'Fêmea Borrega')"
      );
      await txn.rawUpdate(
        "UPDATE deceased_animals SET category = 'Adulto' WHERE category IN ('Fêmea Vazia', 'Macho Vazio')"
      );
    });
  }

  /// Migração v4: Adicionar campos de gestão reprodutiva avançada
  static Future<void> _runMigrationV4(Database db) async {
    await db.transaction((txn) async {
      // Verificar se as colunas já existem antes de adicionar
      final tableInfo = await txn.rawQuery('PRAGMA table_info(breeding_records)');
      final columnNames = tableInfo.map((col) => col['name'] as String).toList();

      if (!columnNames.contains('lambs_count')) {
        await txn.execute('ALTER TABLE breeding_records ADD COLUMN lambs_count INTEGER');
      }
      if (!columnNames.contains('lambs_alive')) {
        await txn.execute('ALTER TABLE breeding_records ADD COLUMN lambs_alive INTEGER');
      }
      if (!columnNames.contains('lambs_dead')) {
        await txn.execute('ALTER TABLE breeding_records ADD COLUMN lambs_dead INTEGER');
      }
      if (!columnNames.contains('heat_detected_date')) {
        await txn.execute('ALTER TABLE breeding_records ADD COLUMN heat_detected_date TEXT');
      }
      if (!columnNames.contains('natural_heat')) {
        await txn.execute('ALTER TABLE breeding_records ADD COLUMN natural_heat INTEGER DEFAULT 1');
      }
      if (!columnNames.contains('heat_notes')) {
        await txn.execute('ALTER TABLE breeding_records ADD COLUMN heat_notes TEXT');
      }
    });
  }
}
