import 'package:sqflite_common/sqlite_api.dart';
import 'local_db.dart';

/// Repository para gerenciar notas
class NoteRepository {
  final AppDatabase _db;

  NoteRepository(this._db);

  /// Retorna todas as notas
  Future<List<Map<String, dynamic>>> getAll() async {
    return await _db.db.query(
      'notes',
      orderBy: 'date DESC',
    );
  }

  /// Retorna uma nota por ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final maps = await _db.db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Retorna notas de um animal específico
  Future<List<Map<String, dynamic>>> getByAnimalId(String animalId) async {
    return await _db.db.query(
      'notes',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'date DESC',
    );
  }

  /// Retorna notas por categoria
  Future<List<Map<String, dynamic>>> getByCategory(String category) async {
    return await _db.db.query(
      'notes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
  }

  /// Retorna notas não lidas
  Future<List<Map<String, dynamic>>> getUnread() async {
    return await _db.db.query(
      'notes',
      where: 'is_read = ?',
      whereArgs: [0],
      orderBy: 'date DESC',
    );
  }

  /// Retorna notas por prioridade
  Future<List<Map<String, dynamic>>> getByPriority(String priority) async {
    return await _db.db.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'date DESC',
    );
  }

  /// Insere uma nova nota
  Future<void> insert(Map<String, dynamic> note) async {
    await _db.db.insert('notes', note);
  }

  /// Atualiza uma nota
  Future<void> update(String id, Map<String, dynamic> updates) async {
    await _db.db.update(
      'notes',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Marca uma nota como lida
  Future<void> markAsRead(String id) async {
    await update(id, {'is_read': 1});
  }

  /// Deleta uma nota
  Future<void> delete(String id) async {
    await _db.db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna contagem de notas não lidas
  Future<int> getUnreadCount() async {
    final result = await _db.db.rawQuery('''
      SELECT COUNT(*) as count
      FROM notes
      WHERE is_read = 0
    ''');
    return (result.first['count'] as int?) ?? 0;
  }
}
