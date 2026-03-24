# Análise de Índices do Sistema

## Como Verificar se os Índices Estão Funcionando

### 1. Query Plan Analysis

Use `EXPLAIN QUERY PLAN` para verificar se SQLite está usando os índices:

```dart
import 'package:flutter/material.dart';
import '../data/local_db.dart';

class IndexAnalyzer {
  static Future<void> analyzeQuery(String query, List<dynamic> args) async {
    final db = await AppDatabase.open();
    
    final plan = await db.db.rawQuery(
      'EXPLAIN QUERY PLAN $query',
      args,
    );
    
    debugPrint('═══ QUERY PLAN ═══');
    debugPrint('Query: $query');
    debugPrint('Args: $args');
    debugPrint('Plan:');
    for (final row in plan) {
      debugPrint('  ${row['detail']}');
    }
    
    // Verifica se está usando índice
    final usingIndex = plan.any((row) => 
      row['detail'].toString().contains('USING INDEX')
    );
    
    if (usingIndex) {
      debugPrint('✅ Query usando índice!');
    } else {
      debugPrint('❌ Query fazendo SCAN (sem índice)!');
    }
    debugPrint('═══════════════════');
  }
}

// Uso:
void testIndexUsage() async {
  // Testa query filtrada
  await IndexAnalyzer.analyzeQuery(
    'SELECT * FROM animals WHERE category = ? AND gender = ?',
    ['Borrego', 'Macho'],
  );
  
  // Deve mostrar: USING INDEX idx_animals_category_gender
}
```

### 2. Performance Benchmarking

Compare performance antes/depois dos índices:

```dart
class PerformanceTester {
  static Future<void> benchmarkQuery(
    String name,
    Future<void> Function() query,
  ) async {
    final stopwatch = Stopwatch()..start();
    await query();
    stopwatch.stop();
    
    debugPrint('⏱️  $name: ${stopwatch.elapsedMilliseconds}ms');
  }
  
  static Future<void> runBenchmarks() async {
    final repo = AnimalRepository(await AppDatabase.open());
    
    debugPrint('═══ PERFORMANCE BENCHMARKS ═══');
    
    // Test 1: Busca filtrada
    await benchmarkQuery(
      'getFilteredAnimals (category + gender)',
      () => repo.getFilteredAnimals(
        categoryEquals: 'Borrego',
        searchQuery: '',
      ),
    );
    
    // Test 2: Busca case-insensitive
    await benchmarkQuery(
      'searchAnimals (nome)',
      () => repo.searchAnimals(searchQuery: 'bezerra'),
    );
    
    // Test 3: Offspring lookup
    await benchmarkQuery(
      'getOffspring (mother_id)',
      () => repo.getOffspring('some-mother-id'),
    );
    
    // Test 4: Peso mais recente
    await benchmarkQuery(
      'latestWeight',
      () => repo.latestWeight('some-animal-id'),
    );
    
    // Test 5: Alertas pendentes
    await benchmarkQuery(
      'weight alerts (completed + due_date)',
      () async {
        final db = await AppDatabase.open();
        await db.db.query(
          'weight_alerts',
          where: 'completed = 0',
          orderBy: 'due_date ASC',
        );
      },
    );
    
    debugPrint('═══════════════════════════════');
  }
}

// Executar no app:
// PerformanceTester.runBenchmarks();
```

### 3. Index List

Liste todos os índices criados:

```dart
class IndexInspector {
  static Future<void> listAllIndexes() async {
    final db = await AppDatabase.open();
    
    final indexes = await db.db.rawQuery('''
      SELECT 
        name,
        tbl_name as table_name,
        sql
      FROM sqlite_master 
      WHERE type = 'index'
        AND name NOT LIKE 'sqlite_%'
      ORDER BY tbl_name, name
    ''');
    
    debugPrint('═══ ÍNDICES DO BANCO ═══');
    debugPrint('Total: ${indexes.length} índices');
    debugPrint('');
    
    String? currentTable;
    for (final idx in indexes) {
      final table = idx['table_name'];
      final name = idx['name'];
      final sql = idx['sql'];
      
      if (table != currentTable) {
        debugPrint('');
        debugPrint('📊 Tabela: $table');
        currentTable = table;
      }
      
      debugPrint('  • $name');
      if (sql != null) {
        debugPrint('    $sql');
      }
    }
    
    debugPrint('');
    debugPrint('═══════════════════════');
  }
}
```

### 4. Database Statistics

Informações sobre tamanho e performance:

```dart
class DatabaseStats {
  static Future<void> printStats() async {
    final db = await AppDatabase.open();
    
    // Tamanho do banco
    final path = await AppDatabase.dbPath();
    final file = File(path);
    final size = await file.length();
    final sizeMB = (size / (1024 * 1024)).toStringAsFixed(2);
    
    // Contagem de tabelas
    final tables = await db.db.rawQuery('''
      SELECT name FROM sqlite_master 
      WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
    ''');
    
    // Contagem de índices
    final indexes = await db.db.rawQuery('''
      SELECT COUNT(*) as count FROM sqlite_master 
      WHERE type = 'index' AND name NOT LIKE 'sqlite_%'
    ''');
    final indexCount = indexes.first['count'];
    
    // Contagem de registros em tabelas principais
    final animalsCount = Sqflite.firstIntValue(
      await db.db.rawQuery('SELECT COUNT(*) FROM animals')
    );
    final weightsCount = Sqflite.firstIntValue(
      await db.db.rawQuery('SELECT COUNT(*) FROM animal_weights')
    );
    final vaccinationsCount = Sqflite.firstIntValue(
      await db.db.rawQuery('SELECT COUNT(*) FROM vaccinations')
    );
    
    debugPrint('═══ DATABASE STATISTICS ═══');
    debugPrint('📁 Tamanho: $sizeMB MB');
    debugPrint('📊 Tabelas: ${tables.length}');
    debugPrint('🔍 Índices: $indexCount');
    debugPrint('');
    debugPrint('📈 Registros:');
    debugPrint('  Animals: $animalsCount');
    debugPrint('  Weights: $weightsCount');
    debugPrint('  Vaccinations: $vaccinationsCount');
    debugPrint('═══════════════════════════');
  }
}
```

## Queries a Testar

### Query 1: Filtro Composto
```sql
-- Deve usar: idx_animals_category_gender
SELECT * FROM animals 
WHERE category = 'Borrego' AND gender = 'Macho'
ORDER BY birth_date DESC;
```

### Query 2: Busca Case-Insensitive
```sql
-- Deve usar: idx_animals_name
SELECT * FROM animals 
WHERE name LIKE '%bezerra%' COLLATE NOCASE;
```

### Query 3: Gestação + Parto
```sql
-- Deve usar: idx_animals_pregnant_delivery
SELECT * FROM animals 
WHERE pregnant = 1 
ORDER BY expected_delivery ASC;
```

### Query 4: Filhotes por Mãe
```sql
-- Deve usar: idx_animals_mother_id
SELECT * FROM animals 
WHERE mother_id = 'some-id';
```

### Query 5: Peso Mais Recente
```sql
-- Deve usar: idx_animal_weights_animal_date
SELECT * FROM animal_weights 
WHERE animal_id = 'some-id' 
ORDER BY date DESC 
LIMIT 1;
```

### Query 6: Alertas Pendentes
```sql
-- Deve usar: idx_weight_alerts_completed_due
SELECT * FROM weight_alerts 
WHERE completed = 0 
ORDER BY due_date ASC;
```

### Query 7: Vacinas Agendadas
```sql
-- Deve usar: idx_vaccinations_status_scheduled
SELECT * FROM vaccinations 
WHERE status = 'Agendada' 
ORDER BY scheduled_date ASC;
```

### Query 8: Medicações por Animal
```sql
-- Deve usar: idx_medications_animal_status
SELECT * FROM medications 
WHERE animal_id = 'some-id' AND status = 'Agendado'
ORDER BY date DESC;
```

### Query 9: Notas Não Lidas
```sql
-- Deve usar: idx_notes_read_date
SELECT * FROM notes 
WHERE is_read = 0 
ORDER BY date DESC;
```

### Query 10: Financeiro por Tipo e Status
```sql
-- Deve usar: idx_finacc_type_status_due
SELECT * FROM financial_accounts 
WHERE type = 'despesa' AND status = 'Pendente'
ORDER BY due_date ASC;
```

## Widget de Diagnóstico

Adicione um botão debug para inspecionar índices:

```dart
class DatabaseDebugButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await IndexInspector.listAllIndexes();
        await DatabaseStats.printStats();
        await PerformanceTester.runBenchmarks();
      },
      child: Icon(Icons.analytics),
      tooltip: 'Database Debug Info',
    );
  }
}
```

## Resultados Esperados

### Com Índices (FASE 4):
```
⏱️  getFilteredAnimals: 12ms
⏱️  searchAnimals: 8ms
⏱️  getOffspring: 3ms
⏱️  latestWeight: 2ms
⏱️  weight alerts: 5ms
```

### Sem Índices (hipotético):
```
⏱️  getFilteredAnimals: 180ms
⏱️  searchAnimals: 250ms
⏱️  getOffspring: 45ms
⏱️  latestWeight: 35ms
⏱️  weight alerts: 90ms
```

### Ganho: 10-30x mais rápido! 🚀

## Troubleshooting

### Índice Não Sendo Usado?

1. **Verifique a query**
```dart
// ❌ Não usa índice (função em coluna)
WHERE LOWER(category) = 'borrego'

// ✅ Usa índice
WHERE category = 'Borrego'
```

2. **Verifique ordem das colunas**
```dart
// ✅ Usa idx_animals_category_gender
WHERE category = 'Borrego' AND gender = 'Macho'

// ⚠️ Pode não usar índice completo
WHERE gender = 'Macho' AND category = 'Borrego'
```

3. **Verifique tipo de dados**
```dart
// ❌ Não usa índice (tipo errado)
WHERE pregnant = '1'  // String

// ✅ Usa índice
WHERE pregnant = 1    // Integer
```

### Performance Ainda Lenta?

1. **ANALYZE** o banco:
```dart
final db = await AppDatabase.open();
await db.db.execute('ANALYZE');
```

2. **VACUUM** para compactar:
```dart
await db.db.execute('VACUUM');
```

3. **Recriar banco** (última opção):
```dart
// Apagar e recriar
final path = await AppDatabase.dbPath();
await File(path).delete();
// App vai recriar com todos os índices
```

## Conclusão

Use essas ferramentas para:
- ✅ Verificar que índices estão funcionando
- ✅ Medir performance real
- ✅ Diagnosticar problemas
- ✅ Validar otimizações

**Lembre-se:** Índices são criados automaticamente, mas é sempre bom validar!
