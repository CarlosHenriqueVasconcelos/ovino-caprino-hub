import 'package:drift/drift.dart' show Variable;

import 'drift/app_database.dart';

class MedicationRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  MedicationRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  String _isoDate(DateTime v) => v.toIso8601String().split('T').first;

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<List<Map<String, dynamic>>> _select(
    String sql,
    List<Object?> args,
  ) async {
    final rows = await _db.customSelect(sql, variables: _vars(args)).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }

  String _page({required int? limit, required int? offset, required List<Object?> args}) {
    final buf = StringBuffer();
    if (limit != null) { buf.write(' LIMIT ?'); args.add(limit); }
    else if (offset != null) { buf.write(' LIMIT -1'); }
    if (offset != null) { buf.write(' OFFSET ?'); args.add(offset); }
    return buf.toString();
  }

  int _toCount(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // ==================== QUERIES BASE ====================

  Future<List<Map<String, dynamic>>> getAll({int? limit, int? offset}) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) args.add(farmId);
    final page = _page(limit: limit, offset: offset, args: args);
    final where = farmId != null ? 'WHERE farm_id = ? ' : '';
    return _select(
      'SELECT * FROM medications ${where}ORDER BY date DESC$page',
      args,
    );
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM medications WHERE farm_id = ? AND id = ? LIMIT 1',
            [farmId, id],
          )
        : await _select(
            'SELECT * FROM medications WHERE id = ? LIMIT 1',
            [id],
          );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getByAnimalId(String animalId) async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            'SELECT * FROM medications WHERE farm_id = ? AND animal_id = ? ORDER BY date DESC',
            [farmId, animalId],
          )
        : _select(
            'SELECT * FROM medications WHERE animal_id = ? ORDER BY date DESC',
            [animalId],
          );
  }

  Future<List<Map<String, dynamic>>> getScheduled({int? limit, int? offset}) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) { args.add(farmId); args.add('Agendado'); }
    else { args.add('Agendado'); }
    final page = _page(limit: limit, offset: offset, args: args);
    final where = farmId != null ? 'WHERE farm_id = ? AND status = ? ' : 'WHERE status = ? ';
    return _select(
      'SELECT * FROM medications ${where}ORDER BY date ASC$page',
      args,
    );
  }

  Future<List<Map<String, dynamic>>> getByStatus(
    String status, {
    int? limit,
    int? offset,
  }) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) { args.add(farmId); args.add(status); }
    else { args.add(status); }
    final page = _page(limit: limit, offset: offset, args: args);
    final where = farmId != null ? 'WHERE farm_id = ? AND status = ? ' : 'WHERE status = ? ';
    return _select(
      'SELECT * FROM medications ${where}ORDER BY date DESC$page',
      args,
    );
  }

  Future<List<Map<String, dynamic>>> getOverdue({int? limit, int? offset}) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) args.add(farmId);
    final page = _page(limit: limit, offset: offset, args: args);
    final where = farmId != null
        ? "WHERE farm_id = ? AND status = 'Agendado' AND COALESCE(date, next_date) < date('now') "
        : "WHERE status = 'Agendado' AND COALESCE(date, next_date) < date('now') ";
    return _select(
      "SELECT * FROM medications ${where}ORDER BY COALESCE(date, next_date) ASC$page",
      args,
    );
  }

  Future<List<Map<String, dynamic>>> getUpcoming(
    int daysThreshold, {
    int? limit,
    int? offset,
  }) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) args.add(farmId);
    final page = _page(limit: limit, offset: offset, args: args);
    final where = farmId != null
        ? "WHERE farm_id = ? AND status = 'Agendado' AND COALESCE(date, next_date) >= date('now') AND COALESCE(date, next_date) <= date('now', '+$daysThreshold days') "
        : "WHERE status = 'Agendado' AND COALESCE(date, next_date) >= date('now') AND COALESCE(date, next_date) <= date('now', '+$daysThreshold days') ";
    return _select(
      "SELECT * FROM medications ${where}ORDER BY COALESCE(date, next_date) ASC$page",
      args,
    );
  }

  Future<void> insert(Map<String, dynamic> medication) async {
    final farmId = _farmId;
    final row = Map<String, dynamic>.from(medication);
    if (farmId != null) row['farm_id'] = farmId;
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    await _db.customStatement(
      'INSERT INTO medications (${cols.join(',')}) VALUES ($placeholders)',
      cols.map((c) => row[c]).toList(),
    );
  }

  Future<void> update(String id, Map<String, dynamic> updates) async {
    if (updates.isEmpty) return;
    final farmId = _farmId;
    final keys = updates.keys.toList(growable: false);
    final setClause = keys.map((k) => '$k = ?').join(', ');
    if (farmId != null) {
      await _db.customStatement(
        'UPDATE medications SET $setClause WHERE farm_id = ? AND id = ?',
        [...keys.map((k) => updates[k]), farmId, id],
      );
    } else {
      await _db.customStatement(
        'UPDATE medications SET $setClause WHERE id = ?',
        [...keys.map((k) => updates[k]), id],
      );
    }
  }

  Future<void> delete(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM medications WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement('DELETE FROM medications WHERE id = ?', [id]);
    }
  }

  // ==================== QUERIES COM JOIN ====================

  Future<List<Map<String, dynamic>>> _withAnimalInfo({
    required String baseWhere,
    required List<Object?> baseArgs,
    required String orderBy,
    required String dateColumn,
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
    required bool hasFarmId,
  }) async {
    final args = <Object?>[...baseArgs];
    final extra = _buildFilters(
      args,
      species: species,
      category: category,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      dateColumn: dateColumn,
    );
    final where = extra.isEmpty ? baseWhere : '$baseWhere AND ${extra.join(' AND ')}';
    final page = _page(limit: limit, offset: offset, args: args);
    final joinCond = hasFarmId ? ' AND a.farm_id = m.farm_id' : '';
    return _select(
      '''
      SELECT
        m.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender,
        a.species AS animal_species,
        a.category AS animal_category
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id$joinCond
      WHERE $where
      ORDER BY $orderBy$page
      ''',
      args,
    );
  }

  Future<List<Map<String, dynamic>>> getAllWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) async {
    final farmId = _farmId;
    return _withAnimalInfo(
      baseWhere: farmId != null ? 'm.farm_id = ?' : '1 = 1',
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'm.date DESC',
      dateColumn: 'COALESCE(m.date, m.next_date)',
      species: species, category: category, searchTerm: searchTerm,
      startDate: startDate, endDate: endDate, limit: limit, offset: offset,
      hasFarmId: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getOverdueWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) async {
    final farmId = _farmId;
    return _withAnimalInfo(
      baseWhere: farmId != null
          ? "m.farm_id = ? AND m.status = 'Agendado' AND COALESCE(m.date, m.next_date) < date('now')"
          : "m.status = 'Agendado' AND COALESCE(m.date, m.next_date) < date('now')",
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'COALESCE(m.date, m.next_date) ASC',
      dateColumn: 'COALESCE(m.date, m.next_date)',
      species: species, category: category, searchTerm: searchTerm,
      startDate: startDate, endDate: endDate, limit: limit, offset: offset,
      hasFarmId: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getScheduledWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) async {
    final farmId = _farmId;
    return _withAnimalInfo(
      baseWhere: farmId != null
          ? "m.farm_id = ? AND m.status = 'Agendado' AND COALESCE(m.date, m.next_date) >= date('now')"
          : "m.status = 'Agendado' AND COALESCE(m.date, m.next_date) >= date('now')",
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'COALESCE(m.date, m.next_date) ASC',
      dateColumn: 'COALESCE(m.date, m.next_date)',
      species: species, category: category, searchTerm: searchTerm,
      startDate: startDate, endDate: endDate, limit: limit, offset: offset,
      hasFarmId: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getAppliedWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) async {
    final farmId = _farmId;
    return _withAnimalInfo(
      baseWhere: farmId != null
          ? "m.farm_id = ? AND m.status = 'Aplicado'"
          : "m.status = 'Aplicado'",
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'COALESCE(m.applied_date, m.date) DESC',
      dateColumn: 'COALESCE(m.applied_date, m.date)',
      species: species, category: category, searchTerm: searchTerm,
      startDate: startDate, endDate: endDate, limit: limit, offset: offset,
      hasFarmId: farmId != null,
    );
  }

  Future<List<Map<String, dynamic>>> getCancelledWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) async {
    final farmId = _farmId;
    return _withAnimalInfo(
      baseWhere: farmId != null
          ? "m.farm_id = ? AND m.status = 'Cancelado'"
          : "m.status = 'Cancelado'",
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'COALESCE(m.date, m.next_date) DESC',
      dateColumn: 'COALESCE(m.date, m.next_date)',
      species: species, category: category, searchTerm: searchTerm,
      startDate: startDate, endDate: endDate, limit: limit, offset: offset,
      hasFarmId: farmId != null,
    );
  }

  // Aliases mantidos para compatibilidade
  Future<List<Map<String, dynamic>>> getMedicationsOverdueWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) => getOverdueWithAnimalInfo(
    species: species, category: category, searchTerm: searchTerm,
    startDate: startDate, endDate: endDate, limit: limit, offset: offset,
  );

  Future<List<Map<String, dynamic>>> getMedicationsScheduledFutureWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) => getScheduledWithAnimalInfo(
    species: species, category: category, searchTerm: searchTerm,
    startDate: startDate, endDate: endDate, limit: limit, offset: offset,
  );

  Future<List<Map<String, dynamic>>> getMedicationsAppliedWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) => getAppliedWithAnimalInfo(
    species: species, category: category, searchTerm: searchTerm,
    startDate: startDate, endDate: endDate, limit: limit, offset: offset,
  );

  Future<List<Map<String, dynamic>>> getMedicationsCanceledWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) => getCancelledWithAnimalInfo(
    species: species, category: category, searchTerm: searchTerm,
    startDate: startDate, endDate: endDate, limit: limit, offset: offset,
  );

  Future<({int overdue, int scheduled, int applied})> getKpiCounts() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            '''
            SELECT
              SUM(CASE WHEN status = 'Agendado' AND COALESCE(date, next_date) < date('now') AND applied_date IS NULL THEN 1 ELSE 0 END) AS overdue,
              SUM(CASE WHEN status = 'Agendado' AND COALESCE(date, next_date) >= date('now') THEN 1 ELSE 0 END) AS scheduled,
              SUM(CASE WHEN status = 'Aplicado' OR applied_date IS NOT NULL THEN 1 ELSE 0 END) AS applied
            FROM medications WHERE farm_id = ?
            ''',
            [farmId],
          )
        : await _select(
            '''
            SELECT
              SUM(CASE WHEN status = 'Agendado' AND COALESCE(date, next_date) < date('now') AND applied_date IS NULL THEN 1 ELSE 0 END) AS overdue,
              SUM(CASE WHEN status = 'Agendado' AND COALESCE(date, next_date) >= date('now') THEN 1 ELSE 0 END) AS scheduled,
              SUM(CASE WHEN status = 'Aplicado' OR applied_date IS NOT NULL THEN 1 ELSE 0 END) AS applied
            FROM medications
            ''',
            [],
          );
    final row = rows.first;
    return (
      overdue: _toCount(row['overdue']),
      scheduled: _toCount(row['scheduled']),
      applied: _toCount(row['applied']),
    );
  }

  Future<List<Map<String, dynamic>>> getByPharmacyStockId(String stockId) async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            'SELECT * FROM medications WHERE farm_id = ? AND pharmacy_stock_id = ? ORDER BY date DESC',
            [farmId, stockId],
          )
        : _select(
            'SELECT * FROM medications WHERE pharmacy_stock_id = ? ORDER BY date DESC',
            [stockId],
          );
  }

  Future<List<Map<String, dynamic>>> getPendingAlertsWithin(DateTime horizon) async {
    final farmId = _farmId;
    final limitDate = _isoDate(horizon);
    return farmId != null
        ? _select(
            '''
            SELECT m.*, a.name AS animal_name, a.code AS animal_code,
                   a.name_color AS animal_color, a.gender AS animal_gender,
                   COALESCE(m.next_date, m.date) AS due_date
            FROM medications m
            LEFT JOIN animals a ON a.id = m.animal_id AND a.farm_id = m.farm_id
            WHERE m.farm_id = ?
              AND m.status NOT IN ('Aplicado', 'Cancelado')
              AND COALESCE(m.next_date, m.date) <= ?
            ORDER BY COALESCE(m.next_date, m.date) ASC
            ''',
            [farmId, limitDate],
          )
        : _select(
            '''
            SELECT m.*, a.name AS animal_name, a.code AS animal_code,
                   a.name_color AS animal_color, a.gender AS animal_gender,
                   COALESCE(m.next_date, m.date) AS due_date
            FROM medications m
            LEFT JOIN animals a ON a.id = m.animal_id
            WHERE m.status NOT IN ('Aplicado', 'Cancelado')
              AND COALESCE(m.next_date, m.date) <= ?
            ORDER BY COALESCE(m.next_date, m.date) ASC
            ''',
            [limitDate],
          );
  }

  List<String> _buildFilters(
    List<Object?> args, {
    String? species,
    String? category,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    required String dateColumn,
  }) {
    final filters = <String>[];
    if (species != null && species.isNotEmpty) {
      filters.add("LOWER(COALESCE(a.species, '')) = ?");
      args.add(species.toLowerCase());
    }
    if (category != null && category.isNotEmpty) {
      filters.add("LOWER(COALESCE(a.category, '')) = ?");
      args.add(category.toLowerCase());
    }
    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      final like = '%${searchTerm.trim().toLowerCase()}%';
      filters.add(
        "(LOWER(COALESCE(a.name, '')) LIKE ? OR LOWER(COALESCE(a.code, '')) LIKE ? OR "
        "LOWER(COALESCE(m.medication_name, '')) LIKE ? OR LOWER(COALESCE(m.notes, '')) LIKE ?)",
      );
      args.addAll([like, like, like, like]);
    }
    if (startDate != null) {
      filters.add('$dateColumn >= ?');
      args.add(_isoDate(startDate));
    }
    if (endDate != null) {
      filters.add('$dateColumn <= ?');
      args.add(_isoDate(endDate));
    }
    return filters;
  }
}
