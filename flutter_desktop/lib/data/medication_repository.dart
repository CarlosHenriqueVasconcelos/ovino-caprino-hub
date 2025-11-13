import 'local_db.dart';

/// Repository para gerenciar medicações
class MedicationRepository {
  final AppDatabase _db;

  MedicationRepository(this._db);

  /// Retorna todas as medicações
  Future<List<Map<String, dynamic>>> getAll() async {
    return await _db.db.query(
      'medications',
      orderBy: 'date DESC',
    );
  }

  /// Retorna uma medicação por ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final maps = await _db.db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  /// Retorna medicações de um animal específico
  Future<List<Map<String, dynamic>>> getByAnimalId(String animalId) async {
    return await _db.db.query(
      'medications',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'date DESC',
    );
  }

  /// Retorna medicações agendadas (status = 'Agendado')
  Future<List<Map<String, dynamic>>> getScheduled() async {
    return await _db.db.query(
      'medications',
      where: 'status = ?',
      whereArgs: ['Agendado'],
      orderBy: 'date ASC',
    );
  }

  /// Retorna medicações por status
  Future<List<Map<String, dynamic>>> getByStatus(String status) async {
    return await _db.db.query(
      'medications',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'date DESC',
    );
  }

  /// Retorna medicações vencidas (agendadas com data passada)
  Future<List<Map<String, dynamic>>> getOverdue() async {
    return await _db.db.rawQuery('''
      SELECT * FROM medications
      WHERE status = 'Agendado'
      AND date(COALESCE(date, next_date)) < date('now')
      ORDER BY date ASC
    ''');
  }

  /// Retorna medicações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcoming(int daysThreshold) async {
    return await _db.db.rawQuery('''
      SELECT * FROM medications
      WHERE status = 'Agendado'
      AND date(COALESCE(date, next_date)) BETWEEN date('now') AND date('now', '+$daysThreshold days')
      ORDER BY date ASC
    ''');
  }

  /// Insere uma nova medicação
  Future<void> insert(Map<String, dynamic> medication) async {
    await _db.db.insert('medications', medication);
  }

  /// Atualiza uma medicação
  Future<void> update(String id, Map<String, dynamic> updates) async {
    await _db.db.update(
      'medications',
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deleta uma medicação
  Future<void> delete(String id) async {
    await _db.db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna medicações com informações do animal (join)
  Future<List<Map<String, dynamic>>> getAllWithAnimalInfo() async {
    return await _db.db.rawQuery('''
      SELECT 
        m.*,
        a.name as animal_name,
        a.code as animal_code,
        a.name_color as animal_color
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      ORDER BY m.date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getOverdueWithAnimalInfo() async {
    return await _db.db.rawQuery('''
      SELECT m.*, a.name AS animal_name, a.code AS animal_code, a.name_color AS animal_color
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE m.status = 'Agendado'
        AND date(COALESCE(m.date, m.next_date)) < date('now')
      ORDER BY date(COALESCE(m.date, m.next_date)) ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getScheduledWithAnimalInfo() async {
    return await _db.db.rawQuery('''
      SELECT m.*, a.name AS animal_name, a.code AS animal_code, a.name_color AS animal_color
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE m.status = 'Agendado'
        AND date(COALESCE(m.date, m.next_date)) >= date('now')
      ORDER BY date(COALESCE(m.date, m.next_date)) ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> getAppliedWithAnimalInfo() async {
    return await _db.db.rawQuery('''
      SELECT m.*, a.name AS animal_name, a.code AS animal_code, a.name_color AS animal_color
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE m.status = 'Aplicado'
      ORDER BY date(COALESCE(m.applied_date, m.date)) DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getCancelledWithAnimalInfo() async {
    return await _db.db.rawQuery('''
      SELECT m.*, a.name AS animal_name, a.code AS animal_code, a.name_color AS animal_color
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE m.status = 'Cancelado'
      ORDER BY date(COALESCE(m.date, m.next_date)) DESC
    ''');
  }

  /// Retorna medicações relacionadas a um item do estoque
  Future<List<Map<String, dynamic>>> getByPharmacyStockId(
      String stockId) async {
    return await _db.db.query(
      'medications',
      where: 'pharmacy_stock_id = ?',
      whereArgs: [stockId],
      orderBy: 'date DESC',
    );
  }
}
