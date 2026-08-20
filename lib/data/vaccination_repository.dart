import 'package:drift/drift.dart' show Variable;

import 'drift/app_database.dart';

class VaccinationRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  VaccinationRepository(
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
      'SELECT * FROM vaccinations ${where}ORDER BY scheduled_date DESC$page',
      args,
    );
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM vaccinations WHERE farm_id = ? AND id = ? LIMIT 1',
            [farmId, id],
          )
        : await _select(
            'SELECT * FROM vaccinations WHERE id = ? LIMIT 1',
            [id],
          );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getByAnimalId(String animalId) async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            'SELECT * FROM vaccinations WHERE farm_id = ? AND animal_id = ? ORDER BY scheduled_date DESC',
            [farmId, animalId],
          )
        : _select(
            'SELECT * FROM vaccinations WHERE animal_id = ? ORDER BY scheduled_date DESC',
            [animalId],
          );
  }

  Future<List<Map<String, dynamic>>> getScheduled({int? limit, int? offset}) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) { args.add(farmId); args.add('Agendada'); }
    else { args.add('Agendada'); }
    final page = _page(limit: limit, offset: offset, args: args);
    final where = farmId != null
        ? 'WHERE farm_id = ? AND status = ? '
        : 'WHERE status = ? ';
    return _select(
      'SELECT * FROM vaccinations ${where}ORDER BY scheduled_date ASC$page',
      args,
    );
  }

  Future<List<Map<String, dynamic>>> getByStatus(String status) async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            'SELECT * FROM vaccinations WHERE farm_id = ? AND status = ? ORDER BY scheduled_date DESC',
            [farmId, status],
          )
        : _select(
            'SELECT * FROM vaccinations WHERE status = ? ORDER BY scheduled_date DESC',
            [status],
          );
  }

  Future<List<Map<String, dynamic>>> getOverdue() async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            "SELECT * FROM vaccinations WHERE farm_id = ? AND status = 'Agendada' AND scheduled_date < date('now') ORDER BY scheduled_date ASC",
            [farmId],
          )
        : _select(
            "SELECT * FROM vaccinations WHERE status = 'Agendada' AND scheduled_date < date('now') ORDER BY scheduled_date ASC",
            [],
          );
  }

  Future<List<Map<String, dynamic>>> getUpcoming(int daysThreshold) async {
    final farmId = _farmId;
    return farmId != null
        ? _select(
            "SELECT * FROM vaccinations WHERE farm_id = ? AND status = 'Agendada' AND scheduled_date >= date('now') AND scheduled_date <= date('now', '+$daysThreshold days') ORDER BY scheduled_date ASC",
            [farmId],
          )
        : _select(
            "SELECT * FROM vaccinations WHERE status = 'Agendada' AND scheduled_date >= date('now') AND scheduled_date <= date('now', '+$daysThreshold days') ORDER BY scheduled_date ASC",
            [],
          );
  }

  Future<void> insert(Map<String, dynamic> vaccination) async {
    final farmId = _farmId;
    final row = Map<String, dynamic>.from(vaccination);
    if (farmId != null) row['farm_id'] = farmId;
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    await _db.customStatement(
      'INSERT INTO vaccinations (${cols.join(',')}) VALUES ($placeholders)',
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
        'UPDATE vaccinations SET $setClause WHERE farm_id = ? AND id = ?',
        [...keys.map((k) => updates[k]), farmId, id],
      );
    } else {
      await _db.customStatement(
        'UPDATE vaccinations SET $setClause WHERE id = ?',
        [...keys.map((k) => updates[k]), id],
      );
    }
  }

  Future<void> delete(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM vaccinations WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement('DELETE FROM vaccinations WHERE id = ?', [id]);
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
    final joinCond = hasFarmId ? ' AND a.farm_id = v.farm_id' : '';
    return _select(
      '''
      SELECT
        v.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender,
        a.species AS animal_species,
        a.category AS animal_category
      FROM vaccinations v
      LEFT JOIN animals a ON a.id = v.animal_id$joinCond
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
      baseWhere: farmId != null ? 'v.farm_id = ?' : '1 = 1',
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'v.scheduled_date DESC',
      dateColumn: 'v.scheduled_date',
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
          ? "v.farm_id = ? AND v.status = 'Agendada' AND v.scheduled_date < date('now')"
          : "v.status = 'Agendada' AND v.scheduled_date < date('now')",
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'v.scheduled_date ASC',
      dateColumn: 'v.scheduled_date',
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
          ? "v.farm_id = ? AND v.status = 'Agendada' AND v.scheduled_date >= date('now')"
          : "v.status = 'Agendada' AND v.scheduled_date >= date('now')",
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'v.scheduled_date ASC',
      dateColumn: 'v.scheduled_date',
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
          ? "v.farm_id = ? AND v.status = 'Aplicada'"
          : "v.status = 'Aplicada'",
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'COALESCE(v.applied_date, v.scheduled_date) DESC',
      dateColumn: 'COALESCE(v.applied_date, v.scheduled_date)',
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
          ? "v.farm_id = ? AND v.status = 'Cancelada'"
          : "v.status = 'Cancelada'",
      baseArgs: farmId != null ? [farmId] : [],
      orderBy: 'v.scheduled_date DESC',
      dateColumn: 'v.scheduled_date',
      species: species, category: category, searchTerm: searchTerm,
      startDate: startDate, endDate: endDate, limit: limit, offset: offset,
      hasFarmId: farmId != null,
    );
  }

  // Aliases mantidos para compatibilidade com chamadores existentes
  Future<List<Map<String, dynamic>>> getVaccinationsOverdueWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) => getOverdueWithAnimalInfo(
    species: species, category: category, searchTerm: searchTerm,
    startDate: startDate, endDate: endDate, limit: limit, offset: offset,
  );

  Future<List<Map<String, dynamic>>> getVaccinationsScheduledFutureWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) => getScheduledWithAnimalInfo(
    species: species, category: category, searchTerm: searchTerm,
    startDate: startDate, endDate: endDate, limit: limit, offset: offset,
  );

  Future<List<Map<String, dynamic>>> getVaccinationsAppliedWithAnimalInfo({
    String? species, String? category, String? searchTerm,
    DateTime? startDate, DateTime? endDate, int? limit, int? offset,
  }) => getAppliedWithAnimalInfo(
    species: species, category: category, searchTerm: searchTerm,
    startDate: startDate, endDate: endDate, limit: limit, offset: offset,
  );

  Future<List<Map<String, dynamic>>> getVaccinationsCanceledWithAnimalInfo({
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
              SUM(CASE WHEN status = 'Agendada' AND scheduled_date < date('now') THEN 1 ELSE 0 END) AS overdue,
              SUM(CASE WHEN status = 'Agendada' AND scheduled_date >= date('now') THEN 1 ELSE 0 END) AS scheduled,
              SUM(CASE WHEN status = 'Aplicada' THEN 1 ELSE 0 END) AS applied
            FROM vaccinations WHERE farm_id = ?
            ''',
            [farmId],
          )
        : await _select(
            '''
            SELECT
              SUM(CASE WHEN status = 'Agendada' AND scheduled_date < date('now') THEN 1 ELSE 0 END) AS overdue,
              SUM(CASE WHEN status = 'Agendada' AND scheduled_date >= date('now') THEN 1 ELSE 0 END) AS scheduled,
              SUM(CASE WHEN status = 'Aplicada' THEN 1 ELSE 0 END) AS applied
            FROM vaccinations
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

  Future<List<Map<String, dynamic>>> getPendingAlertsWithin(DateTime horizon) async {
    final farmId = _farmId;
    final limitDate = _isoDate(horizon);
    return farmId != null
        ? _select(
            '''
            SELECT v.*, a.name AS animal_name, a.code AS animal_code,
                   a.name_color AS animal_color, a.gender AS animal_gender
            FROM vaccinations v
            LEFT JOIN animals a ON a.id = v.animal_id AND a.farm_id = v.farm_id
            WHERE v.farm_id = ?
              AND v.status NOT IN ('Aplicada', 'Cancelada')
              AND v.scheduled_date <= ?
            ORDER BY v.scheduled_date ASC
            ''',
            [farmId, limitDate],
          )
        : _select(
            '''
            SELECT v.*, a.name AS animal_name, a.code AS animal_code,
                   a.name_color AS animal_color, a.gender AS animal_gender
            FROM vaccinations v
            LEFT JOIN animals a ON a.id = v.animal_id
            WHERE v.status NOT IN ('Aplicada', 'Cancelada')
              AND v.scheduled_date <= ?
            ORDER BY v.scheduled_date ASC
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
        "LOWER(COALESCE(v.vaccine_name, '')) LIKE ? OR LOWER(COALESCE(v.notes, '')) LIKE ?)",
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
