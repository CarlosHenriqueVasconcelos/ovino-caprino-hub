import 'package:sqflite_common/sqlite_api.dart' show ConflictAlgorithm;

import '../models/matrix_candidate_ranking.dart';
import '../models/matrix_evaluation.dart';
import 'local_db.dart';

class MatrixEvaluationRepository {
  final AppDatabase _db;

  MatrixEvaluationRepository(this._db);

  Future<void> upsertEvaluation(MatrixEvaluation evaluation) async {
    final nowIso = DateTime.now().toIso8601String();
    final row = Map<String, dynamic>.from(evaluation.toMap());
    final id = row['id']?.toString().trim() ?? '';

    row['id'] = id.isEmpty ? _newId() : id;
    row['created_at'] ??= nowIso;
    row['updated_at'] = nowIso;

    await _db.db.insert(
      'matrix_evaluations',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEvaluation(String id) async {
    await _db.db.delete(
      'matrix_evaluations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<MatrixEvaluation?> getById(String id) async {
    final rows = await _db.db.query(
      'matrix_evaluations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MatrixEvaluation.fromMap(Map<String, dynamic>.from(rows.first));
  }

  Future<MatrixEvaluation?> getLatestEvaluationByAnimal(String animalId) async {
    final rows = await _db.db.query(
      'matrix_evaluations',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'evaluation_date DESC, updated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MatrixEvaluation.fromMap(Map<String, dynamic>.from(rows.first));
  }

  Future<List<MatrixEvaluation>> getEvaluationsByAnimal(
    String animalId, {
    int limit = 30,
    int offset = 0,
  }) async {
    final rows = await _db.db.query(
      'matrix_evaluations',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'evaluation_date DESC, updated_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows
        .map((m) => MatrixEvaluation.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<List<MatrixCandidateRanking>> getLatestRanking({
    String? species,
    String? category,
    String? reproductiveStatus,
    String? lote,
    double? minScore,
    bool onlyFemales = true,
    int limit = 100,
    int offset = 0,
  }) async {
    final where = <String>[
      '''
      me.id = (
        SELECT me2.id
        FROM matrix_evaluations me2
        WHERE me2.animal_id = me.animal_id
        ORDER BY me2.evaluation_date DESC, me2.updated_at DESC
        LIMIT 1
      )
      ''',
    ];
    final args = <dynamic>[];

    if (onlyFemales) {
      where.add("LOWER(a.gender) = 'fêmea'");
    }
    if (species != null && species.trim().isNotEmpty) {
      where.add('a.species = ?');
      args.add(species.trim());
    }
    if (category != null && category.trim().isNotEmpty) {
      where.add('a.category = ?');
      args.add(category.trim());
    }
    if (reproductiveStatus != null && reproductiveStatus.trim().isNotEmpty) {
      where.add('a.reproductive_status = ?');
      args.add(reproductiveStatus.trim());
    }
    if (lote != null && lote.trim().isNotEmpty) {
      where.add('a.lote = ?');
      args.add(lote.trim());
    }
    if (minScore != null) {
      where.add('COALESCE(me.final_score, 0) >= ?');
      args.add(minScore);
    }

    final rows = await _db.db.rawQuery(
      '''
      SELECT
        me.animal_id AS animal_id,
        me.evaluation_date AS evaluation_date,
        me.final_score AS final_score,
        me.recommendation AS recommendation,
        me.notes AS notes,
        me.hoof_condition AS hoof_condition,
        me.verminosis_level AS verminosis_level,
        me.twinning_history AS twinning_history,
        me.lambing_weight AS lambing_weight,
        me.weaning_weight AS weaning_weight,
        me.lactation_score AS lactation_score,
        me.body_condition_score AS body_condition_score,
        me.dentition_score AS dentition_score,
        me.age_months AS age_months,
        a.name AS animal_name,
        a.code AS animal_code,
        a.species AS animal_species,
        a.category AS animal_category,
        a.reproductive_status AS reproductive_status,
        a.gender AS animal_gender,
        a.lote AS animal_lote,
        a.name_color AS animal_name_color
      FROM matrix_evaluations me
      INNER JOIN animals a ON a.id = me.animal_id
      WHERE ${where.join(' AND ')}
      ORDER BY me.final_score DESC, me.evaluation_date DESC
      LIMIT ? OFFSET ?
      ''',
      [...args, limit, offset],
    );

    return rows
        .map((m) => MatrixCandidateRanking.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }

  String _newId() => 'me_${DateTime.now().microsecondsSinceEpoch}';
}
