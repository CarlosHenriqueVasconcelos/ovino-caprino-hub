import 'package:drift/drift.dart' show Variable;

import '../services/legacy_sqflite_to_drift_bridge.dart';
import 'drift/app_database.dart';
import 'local_db.dart';

/// Repository para gerenciar notas
///
/// Camada responsável por fazer
/// Widgets e Services devem falar com esse repositório, não direto com o banco.
class NoteRepository {
  final AppDatabase _db;
  final AppDriftDatabase? _driftDb;
  final String? Function()? _farmIdProvider;
  final LegacySqfliteToDriftBridge? _legacyBridge;

  NoteRepository(
    AppDatabase db, {
    AppDriftDatabase? driftDb,
    String? Function()? farmIdProvider,
  })  : _db = db,
        _driftDb = driftDb,
        _farmIdProvider = farmIdProvider,
        _legacyBridge = driftDb == null
            ? null
            : LegacySqfliteToDriftBridge(
                legacyDb: db,
                driftDb: driftDb,
              );

  String? get _currentFarmId => _farmIdProvider?.call();

  List<Variable<Object>> _asVariables(List<Object?> args) {
    return args
        .map((arg) => Variable<Object>(arg as Object))
        .toList(growable: false);
  }

  Future<String?> _prepareFarmContext() async {
    final farmId = _currentFarmId;
    if (farmId == null || _driftDb == null) return null;
    await _legacyBridge?.migrateForFarm(farmId);
    return farmId;
  }

  Future<List<Map<String, dynamic>>> _driftSelect(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _driftDb!.customSelect(
      sql,
      variables: _asVariables(args),
    ).get();
    return rows.map((row) => Map<String, dynamic>.from(row.data)).toList();
  }

  int _toCount(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> _normalizeFlags(Map<String, dynamic> source) {
    final data = Map<String, dynamic>.from(source);
    if (data.containsKey('is_read')) {
      final raw = data['is_read'];
      if (raw is bool) data['is_read'] = raw ? 1 : 0;
    }
    return data;
  }

  /// Retorna notas com filtros opcionais e paginação.
  Future<List<Map<String, dynamic>>> fetchFiltered({
    String? category,
    String? priority,
    bool? unreadOnly,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 200,
    int offset = 0,
  }) async {
    final filters = <String>[];
    final args = <Object?>[];
    final farmId = await _prepareFarmContext();

    if (farmId != null) {
      filters.add('n.farm_id = ?');
      args.add(farmId);
    }

    if (category != null && category.isNotEmpty) {
      filters.add('n.category = ?');
      args.add(category);
    }

    if (priority != null && priority.isNotEmpty) {
      filters.add('n.priority = ?');
      args.add(priority);
    }

    if (unreadOnly == true) {
      filters.add('(n.is_read = 0 OR n.is_read IS NULL)');
    }

    if (startDate != null) {
      filters.add('n.date >= ?');
      args.add(startDate.toIso8601String().split('T').first);
    }

    if (endDate != null) {
      filters.add('n.date <= ?');
      args.add(endDate.toIso8601String().split('T').first);
    }

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final like = '%${searchTerm.trim().toLowerCase()}%';
      filters.add(
        '('
        'LOWER(COALESCE(n.title, \'\')) LIKE ? OR '
        'LOWER(COALESCE(n.content, \'\')) LIKE ? OR '
        'LOWER(COALESCE(n.created_by, \'\')) LIKE ? OR '
        'LOWER(COALESCE(a.name, \'\')) LIKE ? OR '
        'LOWER(COALESCE(a.code, \'\')) LIKE ?'
        ')',
      );
      args.addAll([like, like, like, like, like]);
    }

    final whereClause =
        filters.isNotEmpty ? 'WHERE ${filters.join(' AND ')}' : '';

    final sql = '''
      SELECT
        n.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender
      FROM notes n
      LEFT JOIN animals a ON a.id = n.animal_id${farmId != null ? ' AND a.farm_id = n.farm_id' : ''}
      $whereClause
      ORDER BY n.date DESC, n.created_at DESC
      LIMIT ? OFFSET ?
    ''';
    args.addAll([limit, offset]);

    if (farmId != null) {
      return _driftSelect(sql, args);
    }

    final rows = await _db.db.rawQuery(sql, args);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Retorna uma nota específica pelo ID, ou null se não existir.
  Future<Map<String, dynamic>?> getById(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        'SELECT * FROM notes WHERE farm_id = ? AND id = ? LIMIT 1',
        [farmId, id],
      );
      if (rows.isEmpty) return null;
      return rows.first;
    }

    final rows = await _db.db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  /// Remove campos com valor null do map.
  Map<String, dynamic> _withoutNulls(Map<String, dynamic> source) {
    final result = <String, dynamic>{};
    source.forEach((key, value) {
      if (value != null) result[key] = value;
    });
    return result;
  }

  /// Normaliza qualquer valor de data para o formato yyyy-MM-dd.
  String _normalizeDate(dynamic value) {
    if (value == null) {
      final now = DateTime.now();
      return now.toIso8601String().split('T')[0];
    }

    if (value is DateTime) {
      return value.toIso8601String().split('T')[0];
    }

    if (value is String) {
      try {
        final parsed = DateTime.parse(value);
        return parsed.toIso8601String().split('T')[0];
      } catch (_) {
        final parts = value.split('/');
        if (parts.length == 3) {
          try {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            final parsed = DateTime(year, month, day);
            return parsed.toIso8601String().split('T')[0];
          } catch (_) {
            return value;
          }
        }
        return value;
      }
    }

    final asString = value.toString();
    try {
      final parsed = DateTime.parse(asString);
      return parsed.toIso8601String().split('T')[0];
    } catch (_) {
      return asString;
    }
  }

  /// Cria uma nova nota.
  Future<void> insert(Map<String, dynamic> note) async {
    final nowIso = DateTime.now().toIso8601String();
    final farmId = await _prepareFarmContext();

    var data = _withoutNulls(note);
    data = _normalizeFlags(data);
    data['date'] = _normalizeDate(data['date']);
    data['is_read'] ??= 0;
    data['created_at'] ??= nowIso;
    data['updated_at'] = nowIso;

    if (farmId != null) {
      data['farm_id'] = farmId;
      final cols = data.keys.toList(growable: false);
      final placeholders = List.filled(cols.length, '?').join(',');
      final args = cols.map((col) => data[col]).toList(growable: false);
      await _driftDb!.customStatement(
        'INSERT INTO notes (${cols.join(',')}) VALUES ($placeholders)',
        args,
      );
      return;
    }

    await _db.db.insert('notes', data);
  }

  /// Atualiza campos de uma nota existente.
  Future<void> update(String id, Map<String, dynamic> updates) async {
    final nowIso = DateTime.now().toIso8601String();
    final farmId = await _prepareFarmContext();

    var data = _withoutNulls(updates);
    data = _normalizeFlags(data);
    if (data.containsKey('date')) {
      data['date'] = _normalizeDate(data['date']);
    }
    data['updated_at'] = nowIso;
    if (data.isEmpty) return;

    if (farmId != null) {
      final keys = data.keys.toList(growable: false);
      final setClause = keys.map((key) => '$key = ?').join(', ');
      final args = <Object?>[
        ...keys.map((key) => data[key]),
        farmId,
        id,
      ];
      await _driftDb!.customStatement(
        '''
        UPDATE notes
        SET $setClause
        WHERE farm_id = ? AND id = ?
        ''',
        args,
      );
      return;
    }

    await _db.db.update(
      'notes',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Remove uma nota pelo ID.
  Future<void> delete(String id) async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      await _driftDb!.customStatement(
        'DELETE FROM notes WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
      return;
    }

    await _db.db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marca uma nota como lida (is_read = 1).
  Future<void> markAsRead(String id) async {
    await update(id, {'is_read': 1});
  }

  /// Retorna a quantidade de notas NÃO lidas (is_read = 0).
  Future<int> getUnreadCount() async {
    final farmId = await _prepareFarmContext();
    if (farmId != null) {
      final rows = await _driftSelect(
        '''
        SELECT COUNT(*) AS count
        FROM notes
        WHERE farm_id = ? AND is_read = 0
        ''',
        [farmId],
      );
      if (rows.isEmpty) return 0;
      return _toCount(rows.first['count']);
    }

    final result = await _db.db.rawQuery('''
      SELECT COUNT(*) AS count
      FROM notes
      WHERE is_read = 0
    ''');
    if (result.isEmpty) return 0;
    return _toCount(result.first['count']);
  }
}
