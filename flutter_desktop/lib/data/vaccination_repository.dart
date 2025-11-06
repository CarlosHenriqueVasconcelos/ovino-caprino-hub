import 'local_db.dart';

/// Repository para gerenciar vacinações
class VaccinationRepository {
  final AppDatabase _db;

  VaccinationRepository(this._db);

  /// Retorna todas as vacinações
  Future<List<Map<String, dynamic>>> getAll() async {
    return await _db.db.query(
      'vaccinations',
      orderBy: 'scheduled_date DESC',
    );
  }

  /// Retorna uma vacinação por ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final maps = await _db.db.query(
      'vaccinations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Retorna vacinações de um animal específico
  Future<List<Map<String, dynamic>>> getByAnimalId(String animalId) async {
    return await _db.db.query(
      'vaccinations',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'scheduled_date DESC',
    );
  }

  /// Retorna vacinações agendadas (status = 'Agendada')
  Future<List<Map<String, dynamic>>> getScheduled() async {
    return await _db.db.query(
      'vaccinations',
      where: 'status = ?',
      whereArgs: ['Agendada'],
      orderBy: 'scheduled_date ASC',
    );
  }

  /// Retorna vacinações por status
  Future<List<Map<String, dynamic>>> getByStatus(String status) async {
    return await _db.db.query(
      'vaccinations',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'scheduled_date DESC',
    );
  }

  /// Retorna vacinações vencidas (agendadas com data passada)
  Future<List<Map<String, dynamic>>> getOverdue() async {
    return await _db.db.rawQuery('''
      SELECT * FROM vaccinations
      WHERE status = 'Agendada'
      AND date(scheduled_date) < date('now')
      ORDER BY scheduled_date ASC
    ''');
  }

  /// Retorna vacinações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcoming(int daysThreshold) async {
    return await _db.db.rawQuery('''
      SELECT * FROM vaccinations
      WHERE status = 'Agendada'
      AND date(scheduled_date) BETWEEN date('now') AND date('now', '+$daysThreshold days')
      ORDER BY scheduled_date ASC
    ''');
  }

  /// Insere uma nova vacinação
  Future<void> insert(Map<String, dynamic> vaccination) async {
    await _db.db.insert('vaccinations', vaccination);
  }

  /// Atualiza uma vacinação
  Future<void> update(String id, Map<String, dynamic> updates) async {
    await _db.db.update(
      'vaccinations',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deleta uma vacinação
  Future<void> delete(String id) async {
    await _db.db.delete(
      'vaccinations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna vacinações com informações do animal (join)
  Future<List<Map<String, dynamic>>> getAllWithAnimalInfo() async {
    return await _db.db.rawQuery('''
      SELECT 
        v.*,
        a.name as animal_name,
        a.code as animal_code,
        a.name_color as animal_color
      FROM vaccinations v
      LEFT JOIN animals a ON a.id = v.animal_id
      ORDER BY v.scheduled_date DESC
    ''');
  }
}
