import 'package:drift/drift.dart' show Variable;

import 'drift/app_database.dart';

class NoteRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  NoteRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<List<Map<String, dynamic>>> _select(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _db.customSelect(sql, variables: _vars(args)).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
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
    final farmId = _farmId;
    final filters = <String>[];
    final args = <Object?>[];

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
    final joinCondition =
        farmId != null ? ' AND a.farm_id = n.farm_id' : '';

    final sql = '''
      SELECT
        n.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender
      FROM notes n
      LEFT JOIN animals a ON a.id = n.animal_id$joinCondition
      $whereClause
      ORDER BY n.date DESC, n.created_at DESC
      LIMIT ? OFFSET ?
    ''';
    args.addAll([limit, offset]);

    return _select(sql, args);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM notes WHERE farm_id = ? AND id = ? LIMIT 1',
            [farmId, id],
          )
        : await _select(
            'SELECT * FROM notes WHERE id = ? LIMIT 1',
            [id],
          );
    return rows.isEmpty ? null : rows.first;
  }

  Map<String, dynamic> _withoutNulls(Map<String, dynamic> source) {
    return {
      for (final e in source.entries)
        if (e.value != null) e.key: e.value,
    };
  }

  String _normalizeDate(dynamic value) {
    if (value == null) return DateTime.now().toIso8601String().split('T')[0];
    if (value is DateTime) return value.toIso8601String().split('T')[0];
    if (value is String) {
      try {
        return DateTime.parse(value).toIso8601String().split('T')[0];
      } catch (_) {
        final parts = value.split('/');
        if (parts.length == 3) {
          try {
            final d = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            return d.toIso8601String().split('T')[0];
          } catch (_) {
            return value;
          }
        }
        return value;
      }
    }
    final s = value.toString();
    try {
      return DateTime.parse(s).toIso8601String().split('T')[0];
    } catch (_) {
      return s;
    }
  }

  Future<void> insert(Map<String, dynamic> note) async {
    final nowIso = DateTime.now().toIso8601String();
    final farmId = _farmId;

    var data = _withoutNulls(note);
    data = _normalizeFlags(data);
    data['date'] = _normalizeDate(data['date']);
    data['is_read'] ??= 0;
    data['created_at'] ??= nowIso;
    data['updated_at'] = nowIso;
    if (farmId != null) data['farm_id'] = farmId;

    final cols = data.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    await _db.customStatement(
      'INSERT INTO notes (${cols.join(',')}) VALUES ($placeholders)',
      cols.map((c) => data[c]).toList(),
    );
  }

  Future<void> update(String id, Map<String, dynamic> updates) async {
    final nowIso = DateTime.now().toIso8601String();
    final farmId = _farmId;

    var data = _withoutNulls(updates);
    data = _normalizeFlags(data);
    if (data.containsKey('date')) {
      data['date'] = _normalizeDate(data['date']);
    }
    data['updated_at'] = nowIso;
    if (data.isEmpty) return;

    final keys = data.keys.toList(growable: false);
    final setClause = keys.map((k) => '$k = ?').join(', ');
    if (farmId != null) {
      await _db.customStatement(
        'UPDATE notes SET $setClause WHERE farm_id = ? AND id = ?',
        [...keys.map((k) => data[k]), farmId, id],
      );
    } else {
      await _db.customStatement(
        'UPDATE notes SET $setClause WHERE id = ?',
        [...keys.map((k) => data[k]), id],
      );
    }
  }

  Future<void> delete(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM notes WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement('DELETE FROM notes WHERE id = ?', [id]);
    }
  }

  Future<void> markAsRead(String id) async {
    await update(id, {'is_read': 1});
  }

  Future<int> getUnreadCount() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT COUNT(*) AS count FROM notes WHERE farm_id = ? AND is_read = 0',
            [farmId],
          )
        : await _select(
            'SELECT COUNT(*) AS count FROM notes WHERE is_read = 0',
            [],
          );
    if (rows.isEmpty) return 0;
    return _toCount(rows.first['count']);
  }
}
