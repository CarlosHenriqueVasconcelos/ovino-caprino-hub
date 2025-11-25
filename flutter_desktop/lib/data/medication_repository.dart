import 'local_db.dart';

/// Repository para gerenciar medicações
class MedicationRepository {
  final AppDatabase _db;

  MedicationRepository(this._db);

  String _isoDate(DateTime value) => value.toIso8601String().split('T').first;

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
      AND COALESCE(date, next_date) < date('now')
      ORDER BY COALESCE(date, next_date) ASC
    ''');
  }

  /// Retorna medicações próximas (dentro de X dias)
  Future<List<Map<String, dynamic>>> getUpcoming(int daysThreshold) async {
    return await _db.db.rawQuery('''
      SELECT * FROM medications
      WHERE status = 'Agendado'
      AND COALESCE(date, next_date) >= date('now')
      AND COALESCE(date, next_date) <= date('now', '+$daysThreshold days')
      ORDER BY COALESCE(date, next_date) ASC
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
  Future<List<Map<String, dynamic>>> getAllWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final args = <dynamic>[];
    final filters = _buildFilters(
      args,
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      dateColumn: "COALESCE(m.date, m.next_date)",
    );

    final rows = await _db.db.rawQuery('''
      SELECT 
        m.*,
        a.name as animal_name,
        a.code as animal_code,
        a.name_color as animal_color,
        a.species as animal_species,
        a.category as animal_category
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      ${filters.isNotEmpty ? 'WHERE ${filters.join(' AND ')}' : ''}
      ORDER BY m.date DESC
    ''', args);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getOverdueWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final args = <dynamic>[];
    final filters = _buildFilters(
      args,
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      dateColumn: "COALESCE(m.date, m.next_date)",
    );
    final whereClause = StringBuffer(
      "m.status = 'Agendado' AND COALESCE(m.date, m.next_date) < date('now')",
    );
    if (filters.isNotEmpty) {
      whereClause.write(' AND ${filters.join(' AND ')}');
    }

    final rows = await _db.db.rawQuery('''
      SELECT m.*, 
             a.name AS animal_name, 
             a.code AS animal_code, 
             a.name_color AS animal_color,
             a.species AS animal_species,
             a.category AS animal_category
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE ${whereClause.toString()}
      ORDER BY COALESCE(m.date, m.next_date) ASC
    ''', args);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getScheduledWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final args = <dynamic>[];
    final filters = _buildFilters(
      args,
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      dateColumn: "COALESCE(m.date, m.next_date)",
    );
    final whereClause = StringBuffer(
      "m.status = 'Agendado' AND COALESCE(m.date, m.next_date) >= date('now')",
    );
    if (filters.isNotEmpty) {
      whereClause.write(' AND ${filters.join(' AND ')}');
    }

    final rows = await _db.db.rawQuery('''
      SELECT m.*, 
             a.name AS animal_name, 
             a.code AS animal_code, 
             a.name_color AS animal_color,
             a.species AS animal_species,
             a.category AS animal_category
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE ${whereClause.toString()}
      ORDER BY COALESCE(m.date, m.next_date) ASC
    ''', args);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getAppliedWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final args = <dynamic>[];
    final filters = _buildFilters(
      args,
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      dateColumn: "COALESCE(m.applied_date, m.date)",
    );
    final whereClause = StringBuffer("m.status = 'Aplicado'");
    if (filters.isNotEmpty) {
      whereClause.write(' AND ${filters.join(' AND ')}');
    }

    final rows = await _db.db.rawQuery('''
      SELECT m.*, 
             a.name AS animal_name, 
             a.code AS animal_code, 
             a.name_color AS animal_color,
             a.species AS animal_species,
             a.category AS animal_category
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE ${whereClause.toString()}
      ORDER BY COALESCE(m.applied_date, m.date) DESC
    ''', args);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getCancelledWithAnimalInfo({
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final args = <dynamic>[];
    final filters = _buildFilters(
      args,
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      dateColumn: "COALESCE(m.date, m.next_date)",
    );
    final whereClause = StringBuffer("m.status = 'Cancelado'");
    if (filters.isNotEmpty) {
      whereClause.write(' AND ${filters.join(' AND ')}');
    }

    final rows = await _db.db.rawQuery('''
      SELECT m.*, 
             a.name AS animal_name, 
             a.code AS animal_code, 
             a.name_color AS animal_color,
             a.species AS animal_species,
             a.category AS animal_category
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE ${whereClause.toString()}
      ORDER BY COALESCE(m.date, m.next_date) DESC
    ''', args);
    return rows.map((e) => Map<String, dynamic>.from(e)).toList();
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

  Future<List<Map<String, dynamic>>> getPendingAlertsWithin(
      DateTime horizon) async {
    final limit = horizon.toIso8601String().split('T').first;
    return await _db.db.rawQuery('''
      SELECT 
        m.*, 
        a.name AS animal_name, 
        a.code AS animal_code, 
        a.name_color AS animal_color,
        COALESCE(m.next_date, m.date) AS due_date
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE m.status NOT IN ('Aplicado', 'Cancelado')
        AND COALESCE(m.next_date, m.date) <= ?
      ORDER BY COALESCE(m.next_date, m.date) ASC
    ''', [limit]);
  }

  List<String> _buildFilters(
    List<dynamic> args, {
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    required String dateColumn,
  }) {
    final filters = <String>[];

    if (species != null && species.isNotEmpty) {
      filters.add(
        "LOWER(COALESCE(m.species, a.species, '')) = ?",
      );
      args.add(species.toLowerCase());
    }

    if (category != null && category.isNotEmpty) {
      filters.add(
        "LOWER(COALESCE(m.category, a.category, '')) = ?",
      );
      args.add(category.toLowerCase());
    }

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final like = '%${searchTerm.trim().toLowerCase()}%';
      filters.add(
        '('
        "LOWER(COALESCE(a.name, '')) LIKE ? OR "
        "LOWER(COALESCE(a.code, '')) LIKE ? OR "
        "LOWER(COALESCE(m.medication_name, '')) LIKE ? OR "
        "LOWER(COALESCE(m.notes, '')) LIKE ?"
        ')',
      );
      args.addAll([like, like, like, like]);
    }

    if (startDate != null) {
      filters.add('$dateColumn >= ?');
      args.add(startDate.toIso8601String().split('T').first);
    }

    if (endDate != null) {
      filters.add('$dateColumn <= ?');
      args.add(endDate.toIso8601String().split('T').first);
    }

    return filters;
  }
}
