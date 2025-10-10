import 'dart:convert';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:supabase/supabase.dart';
import '../data/local_db.dart';

class BackupService {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  BackupService({
    required AppDatabase db,
    required String supabaseUrl,
    required String supabaseAnonKey,
  })  : _db = db,
        _supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  /// Ordem respeitando FKs (pais antes dos filhos)
  static const List<String> _order = [
    'cost_centers',
    'animals',
    'animal_weights',
    'breeding_records',
    'medications',
    'vaccinations',
    'notes',
    'financial_records',
    'financial_accounts',
    'budgets',
    'reports',
    'push_tokens',
  ];

  static String _pk(String table) => 'id';

  // =====================
  // ===== BACKUP ========
  // =====================
  Stream<String> backupAll() async* {
    for (final table in _order) {
      yield 'Lendo $table...';
      final rows = await _db.db.query(table); // todas as colunas do SQLite
      if (rows.isEmpty) {
        yield '$table: nada a enviar';
        continue;
      }

      // Converter tipos locais → Supabase (json, bool)
      final payload = rows
          .map((row) => _toRemote(table, Map<String, Object?>.from(row)))
          .toList();

      yield 'Enviando $table (${payload.length})...';
      await _supabase.from(table).upsert(payload, onConflict: _pk(table));
      yield '$table: OK';
    }
    yield 'Backup concluído ✅';
  }

  // =====================
  // ==== RESTORE =========
  // =====================
  Stream<String> restoreAll() async* {
    final allowedColsCache = <String, Set<String>>{};

    for (final table in _order) {
      yield 'Baixando $table...';
      final res = await _supabase.from(table).select();
      final rows = (res as List).cast<Map<String, dynamic>>();

      if (rows.isEmpty) {
        yield '$table: nenhum dado na nuvem';
        continue;
      }

      // Descobrir colunas válidas no SQLite local (uma vez por tabela)
      final allowed = await _allowedCols(table, allowedColsCache);

      yield 'Restaurando $table (${rows.length})...';

      // Limpar tabela antes de restaurar
      await _db.db.delete(table);

      // Inserir em batch, filtrando nulls e colunas extras
      final batch = _db.db.batch();
      for (final row in rows) {
        final localMap = _toLocal(table, row, allowed);
        if (localMap.isEmpty) continue;
        batch.insert(
          table,
          localMap,
          conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      yield '$table: OK (${rows.length} registros)';
    }
    yield 'Restauração concluída ✅';
  }

  // =====================
  // === Helpers =========
  // =====================

  Future<Set<String>> _allowedCols(
    String table,
    Map<String, Set<String>> cache,
  ) async {
    if (cache.containsKey(table)) return cache[table]!;
    final info = await _db.db.rawQuery('PRAGMA table_info($table)');
    final cols = info.map((m) => m['name'] as String).toSet();
    cache[table] = cols;
    return cols;
  }

  /// Converte dados vindos do Supabase (jsonb, boolean) para tipos aceitos no SQLite local
  Map<String, Object?> _toLocal(
    String table,
    Map<String, dynamic> row,
    Set<String> allowedCols,
  ) {
    final out = <String, Object?>{};

    void put(String key, Object? val) {
      if (!allowedCols.contains(key)) return; // ignora colunas desconhecidas
      if (val == null) return; // remove nulls para evitar _checkArg
      out[key] = val;
    }

    // Copiar somente colunas permitidas, convertendo tipos específicos
    row.forEach((k, v) {
      if (!allowedCols.contains(k)) return;

      // Booleans → INTEGER 0/1
      if (v is bool) {
        put(k, v ? 1 : 0);
        return;
      }

      // JSONB → TEXT (para as colunas específicas)
      if ((table == 'reports' && k == 'parameters') ||
          (table == 'push_tokens' && k == 'device_info')) {
        if (v is Map || v is List) {
          put(k, jsonEncode(v));
        } else if (v is String) {
          // já é string; assume JSON já serializado
          put(k, v);
        } else {
          // fallback seguro
          put(k, jsonEncode(v));
        }
        return;
      }

      // Demais campos: manter como veio (Strings, num → REAL/TEXT)
      put(k, v);
    });

    return out;
  }

  /// Converte dados locais (SQLite) para tipos esperados no Supabase (jsonb, boolean)
  Map<String, dynamic> _toRemote(String table, Map<String, Object?> row) {
    final out = <String, dynamic>{};

    void put(String key, Object? val) {
      if (val == null) return;
      out[key] = val;
    }

    row.forEach((k, v) {
      // INTEGER 0/1 → bool (campos boolean do Supabase)
      if ((table == 'animals' && k == 'pregnant') ||
          (table == 'notes' && k == 'is_read') ||
          (table == 'financial_accounts' && k == 'is_recurring') ||
          (table == 'cost_centers' && k == 'active')) {
        if (v is int) {
          put(k, v != 0);
          return;
        }
      }

      // TEXT JSON → jsonb (reports.parameters, push_tokens.device_info)
      if ((table == 'reports' && k == 'parameters') ||
          (table == 'push_tokens' && k == 'device_info')) {
        if (v is String) {
          try {
            put(k, jsonDecode(v));
          } catch (_) {
            // se não for JSON válido, envia string mesmo
            put(k, v);
          }
          return;
        }
      }

      put(k, v);
    });

    return out;
  }
}
