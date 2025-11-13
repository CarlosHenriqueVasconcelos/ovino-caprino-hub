import '../models/feeding_pen.dart';
import '../models/feeding_schedule.dart';
import 'local_db.dart';

/// Repository para gerenciar baias e tratos de alimentação
class FeedingRepository {
  final AppDatabase _db;

  FeedingRepository(this._db);

  // ==================== FEEDING PENS ====================

  /// Retorna todas as baias
  Future<List<FeedingPen>> getAllPens() async {
    final maps = await _db.db.query(
      'feeding_pens',
      orderBy: 'name ASC',
    );
    return maps.map((m) => FeedingPen.fromMap(m)).toList();
  }

  /// Retorna uma baia por ID
  Future<FeedingPen?> getPenById(String id) async {
    final maps = await _db.db.query(
      'feeding_pens',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FeedingPen.fromMap(maps.first);
  }

  /// Insere uma nova baia
  Future<void> insertPen(FeedingPen pen) async {
    await _db.db.insert('feeding_pens', pen.toMap());
  }

  /// Atualiza uma baia
  Future<void> updatePen(FeedingPen pen) async {
    await _db.db.update(
      'feeding_pens',
      pen.toMap(),
      where: 'id = ?',
      whereArgs: [pen.id],
    );
  }

  /// Deleta uma baia
  Future<void> deletePen(String id) async {
    // Deletar também os schedules relacionados
    await _db.db.delete(
      'feeding_schedules',
      where: 'pen_id = ?',
      whereArgs: [id],
    );

    await _db.db.delete(
      'feeding_pens',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== FEEDING SCHEDULES ====================

  /// Retorna todos os tratos de alimentação
  Future<List<FeedingSchedule>> getAllSchedules() async {
    final maps = await _db.db.query(
      'feeding_schedules',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => FeedingSchedule.fromMap(m)).toList();
  }

  /// Retorna tratos de uma baia específica
  Future<List<FeedingSchedule>> getSchedulesByPenId(String penId) async {
    final maps = await _db.db.query(
      'feeding_schedules',
      where: 'pen_id = ?',
      whereArgs: [penId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => FeedingSchedule.fromMap(m)).toList();
  }

  /// Retorna um trato por ID
  Future<FeedingSchedule?> getScheduleById(String id) async {
    final maps = await _db.db.query(
      'feeding_schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return FeedingSchedule.fromMap(maps.first);
  }

  /// Insere um novo trato
  Future<void> insertSchedule(FeedingSchedule schedule) async {
    await _db.db.insert('feeding_schedules', schedule.toMap());
  }

  /// Atualiza um trato
  Future<void> updateSchedule(FeedingSchedule schedule) async {
    await _db.db.update(
      'feeding_schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  /// Deleta um trato
  Future<void> deleteSchedule(String id) async {
    await _db.db.delete(
      'feeding_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna baias com seus tratos (join)
  Future<List<Map<String, dynamic>>> getPensWithSchedules() async {
    return await _db.db.rawQuery('''
      SELECT 
        p.*,
        COUNT(s.id) as schedule_count
      FROM feeding_pens p
      LEFT JOIN feeding_schedules s ON s.pen_id = p.id
      GROUP BY p.id
      ORDER BY p.name ASC
    ''');
  }
}
