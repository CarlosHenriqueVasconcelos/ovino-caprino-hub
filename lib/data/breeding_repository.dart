import 'package:drift/drift.dart' show Variable;

import '../models/breeding_record.dart';
import 'drift/app_database.dart';

class BreedingRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  BreedingRepository(
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

  Future<void> _insert(String table, Map<String, dynamic> row) async {
    final cols = row.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(',');
    await _db.customStatement(
      'INSERT INTO $table (${cols.join(',')}) VALUES ($placeholders)',
      cols.map((c) => row[c]).toList(),
    );
  }

  Future<void> _updateById({
    required String id,
    required String? farmId,
    required Map<String, dynamic> data,
  }) async {
    if (data.isEmpty) return;
    final keys = data.keys.toList(growable: false);
    final setClause = keys.map((k) => '$k = ?').join(', ');
    if (farmId != null) {
      await _db.customStatement(
        'UPDATE breeding_records SET $setClause WHERE farm_id = ? AND id = ?',
        [...keys.map((k) => data[k]), farmId, id],
      );
    } else {
      await _db.customStatement(
        'UPDATE breeding_records SET $setClause WHERE id = ?',
        [...keys.map((k) => data[k]), id],
      );
    }
  }

  String _page({required int? limit, required int? offset, required List<Object?> args}) {
    final buf = StringBuffer();
    if (limit != null) { buf.write(' LIMIT ?'); args.add(limit); }
    else if (offset != null) { buf.write(' LIMIT -1'); }
    if (offset != null) { buf.write(' OFFSET ?'); args.add(offset); }
    return buf.toString();
  }

  Future<List<BreedingRecord>> getAll({int? limit, int? offset}) async {
    final farmId = _farmId;
    final args = <Object?>[];
    if (farmId != null) args.add(farmId);
    final page = _page(limit: limit, offset: offset, args: args);
    final where = farmId != null ? 'WHERE farm_id = ? ' : '';
    final rows = await _select(
      'SELECT * FROM breeding_records ${where}ORDER BY breeding_date DESC$page',
      args,
    );
    return rows.map(BreedingRecord.fromMap).toList();
  }

  Future<BreedingRecord?> getById(String id) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM breeding_records WHERE farm_id = ? AND id = ? LIMIT 1',
            [farmId, id],
          )
        : await _select(
            'SELECT * FROM breeding_records WHERE id = ? LIMIT 1',
            [id],
          );
    return rows.isEmpty ? null : BreedingRecord.fromMap(rows.first);
  }

  Future<void> insert(BreedingRecord record) async {
    final farmId = _farmId;
    final row = record.toMap();
    if (farmId != null) row['farm_id'] = farmId;
    await _insert('breeding_records', row);
  }

  Future<void> update(BreedingRecord record) async {
    await _updateById(
      id: record.id,
      farmId: _farmId,
      data: record.toMap()..remove('id'),
    );
  }

  Future<void> delete(String id) async {
    final farmId = _farmId;
    if (farmId != null) {
      await _db.customStatement(
        'DELETE FROM breeding_records WHERE farm_id = ? AND id = ?',
        [farmId, id],
      );
    } else {
      await _db.customStatement(
        'DELETE FROM breeding_records WHERE id = ?',
        [id],
      );
    }
  }

  Future<List<BreedingRecord>> getByFemaleId(String femaleId) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM breeding_records WHERE farm_id = ? AND female_animal_id = ? ORDER BY breeding_date DESC',
            [farmId, femaleId],
          )
        : await _select(
            'SELECT * FROM breeding_records WHERE female_animal_id = ? ORDER BY breeding_date DESC',
            [femaleId],
          );
    return rows.map(BreedingRecord.fromMap).toList();
  }

  Future<List<BreedingRecord>> getByMaleId(String maleId) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM breeding_records WHERE farm_id = ? AND male_animal_id = ? ORDER BY breeding_date DESC',
            [farmId, maleId],
          )
        : await _select(
            'SELECT * FROM breeding_records WHERE male_animal_id = ? ORDER BY breeding_date DESC',
            [maleId],
          );
    return rows.map(BreedingRecord.fromMap).toList();
  }

  Future<List<BreedingRecord>> getByStatus(String status) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM breeding_records WHERE farm_id = ? AND status = ? ORDER BY breeding_date DESC',
            [farmId, status],
          )
        : await _select(
            'SELECT * FROM breeding_records WHERE status = ? ORDER BY breeding_date DESC',
            [status],
          );
    return rows.map(BreedingRecord.fromMap).toList();
  }

  Future<List<BreedingRecord>> getByStage(String stage) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            'SELECT * FROM breeding_records WHERE farm_id = ? AND stage = ? ORDER BY breeding_date DESC',
            [farmId, stage],
          )
        : await _select(
            'SELECT * FROM breeding_records WHERE stage = ? ORDER BY breeding_date DESC',
            [stage],
          );
    return rows.map(BreedingRecord.fromMap).toList();
  }

  Future<List<BreedingRecord>> getActiveRecords() async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            "SELECT * FROM breeding_records WHERE farm_id = ? AND status NOT IN ('Abortado', 'Finalizado') ORDER BY breeding_date DESC",
            [farmId],
          )
        : await _select(
            "SELECT * FROM breeding_records WHERE status NOT IN ('Abortado', 'Finalizado') ORDER BY breeding_date DESC",
            [],
          );
    return rows.map(BreedingRecord.fromMap).toList();
  }

  Future<List<BreedingRecord>> getUpcomingBirths(int daysThreshold) async {
    final farmId = _farmId;
    final rows = farmId != null
        ? await _select(
            '''
            SELECT * FROM breeding_records
            WHERE farm_id = ?
              AND expected_birth IS NOT NULL
              AND expected_birth >= date('now')
              AND expected_birth <= date('now', '+$daysThreshold days')
            ORDER BY expected_birth ASC
            ''',
            [farmId],
          )
        : await _select(
            '''
            SELECT * FROM breeding_records
            WHERE expected_birth IS NOT NULL
              AND expected_birth >= date('now')
              AND expected_birth <= date('now', '+$daysThreshold days')
            ORDER BY expected_birth ASC
            ''',
            [],
          );
    return rows.map(BreedingRecord.fromMap).toList();
  }
}
