import 'local_db.dart';

/// Repository para gerenciar notas
///
/// Camada responsável por fazer
/// Widgets e Services devem falar com esse repositório, não direto com o banco.
class NoteRepository {
  final AppDatabase _db;

  NoteRepository(this._db);

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
    final args = <dynamic>[];

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
      filters.add('('
          'LOWER(n.title) LIKE ? OR '
          'LOWER(n.content) LIKE ? OR '
          'LOWER(n.created_by) LIKE ? OR '
          'LOWER(a.name) LIKE ? OR '
          'LOWER(a.code) LIKE ?)');
      args.addAll([like, like, like, like, like]);
    }

    final whereClause =
        filters.isNotEmpty ? 'WHERE ${filters.join(' AND ')}' : '';

    final rows = await _db.db.rawQuery('''
      SELECT 
        n.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color
      FROM notes n
      LEFT JOIN animals a ON a.id = n.animal_id
      $whereClause
      ORDER BY n.date DESC, n.created_at DESC
      LIMIT ? OFFSET ?
    ''', [...args, limit, offset]);

    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Retorna uma nota específica pelo ID, ou null se não existir.
  Future<Map<String, dynamic>?> getById(String id) async {
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
      // Tenta parsear diretamente (yyyy-MM-dd ou ISO completo)
      try {
        final parsed = DateTime.parse(value);
        return parsed.toIso8601String().split('T')[0];
      } catch (_) {
        // tenta dd/MM/yyyy
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

    final data = _withoutNulls(note);

    // Garante data normalizada (equivalente ao _toIsoDate/_today)
    data['date'] = _normalizeDate(data['date']);

    // Defaults inspirados no DatabaseService
    data['is_read'] ??= 0;
    data['created_at'] ??= nowIso;
    data['updated_at'] = nowIso;

    await _db.db.insert('notes', data);
  }

  /// Atualiza campos de uma nota existente.
  Future<void> update(String id, Map<String, dynamic> updates) async {
    final nowIso = DateTime.now().toIso8601String();

    final data = _withoutNulls(updates);

    if (data.containsKey('date')) {
      data['date'] = _normalizeDate(data['date']);
    }

    data['updated_at'] = nowIso;

    await _db.db.update(
      'notes',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Remove uma nota pelo ID.
  Future<void> delete(String id) async {
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
    final result = await _db.db.rawQuery('''
      SELECT COUNT(*) AS count
      FROM notes
      WHERE is_read = 0
    ''');

    if (result.isEmpty) return 0;

    final value = result.first['count'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
