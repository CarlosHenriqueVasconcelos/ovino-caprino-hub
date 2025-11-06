import '../models/breeding_record.dart';
import 'local_db.dart';

/// Repository para gerenciar registros de reprodução
class BreedingRepository {
  final AppDatabase _db;

  BreedingRepository(this._db);

  /// Retorna todos os registros de reprodução
  Future<List<BreedingRecord>> getAll() async {
    final maps = await _db.db.query(
      'breeding_records',
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna um registro de reprodução por ID
  Future<BreedingRecord?> getById(String id) async {
    final maps = await _db.db.query(
      'breeding_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return BreedingRecord.fromMap(maps.first);
  }

  /// Insere um novo registro de reprodução
  Future<void> insert(BreedingRecord record) async {
    await _db.db.insert('breeding_records', record.toMap());
  }

  /// Atualiza um registro de reprodução
  Future<void> update(BreedingRecord record) async {
    await _db.db.update(
      'breeding_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// Deleta um registro de reprodução
  Future<void> delete(String id) async {
    await _db.db.delete(
      'breeding_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Retorna registros de reprodução de uma fêmea específica
  Future<List<BreedingRecord>> getByFemaleId(String femaleId) async {
    final maps = await _db.db.query(
      'breeding_records',
      where: 'female_animal_id = ?',
      whereArgs: [femaleId],
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros de reprodução de um macho específico
  Future<List<BreedingRecord>> getByMaleId(String maleId) async {
    final maps = await _db.db.query(
      'breeding_records',
      where: 'male_animal_id = ?',
      whereArgs: [maleId],
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros de reprodução por status
  Future<List<BreedingRecord>> getByStatus(String status) async {
    final maps = await _db.db.query(
      'breeding_records',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros de reprodução por estágio (stage)
  Future<List<BreedingRecord>> getByStage(String stage) async {
    final maps = await _db.db.query(
      'breeding_records',
      where: 'stage = ?',
      whereArgs: [stage],
      orderBy: 'breeding_date DESC',
    );
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros de reprodução ativas (não finalizadas)
  Future<List<BreedingRecord>> getActiveRecords() async {
    final maps = await _db.db.rawQuery('''
      SELECT * FROM breeding_records
      WHERE status NOT IN ('Abortado', 'Finalizado')
      ORDER BY breeding_date DESC
    ''');
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }

  /// Retorna registros com partos esperados próximos (dentro de X dias)
  Future<List<BreedingRecord>> getUpcomingBirths(int daysThreshold) async {
    final maps = await _db.db.rawQuery('''
      SELECT * FROM breeding_records
      WHERE expected_birth IS NOT NULL
      AND date(expected_birth) BETWEEN date('now') AND date('now', '+$daysThreshold days')
      ORDER BY expected_birth ASC
    ''');
    return maps.map((m) => BreedingRecord.fromMap(m)).toList();
  }
}
