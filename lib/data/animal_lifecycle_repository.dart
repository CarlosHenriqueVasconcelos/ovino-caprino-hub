import 'package:drift/drift.dart' show Variable;

import '../services/events/app_events.dart';
import '../services/events/event_bus.dart';
import 'drift/app_database.dart';

class AnimalLifecycleRepository {
  final AppDriftDatabase _db;
  final String? Function()? _farmIdProvider;

  AnimalLifecycleRepository(
    AppDriftDatabase db, {
    String? Function()? farmIdProvider,
  })  : _db = db,
        _farmIdProvider = farmIdProvider;

  String? get _farmId => _farmIdProvider?.call();

  List<Variable<Object>> _vars(List<Object?> args) =>
      args.map((a) => Variable<Object>(a as Object)).toList(growable: false);

  Future<void> moveToDeceased(
    String animalId, {
    DateTime? deathDate,
    String? causeOfDeath,
    String? notes,
  }) async {
    final farmId = _farmId;
    await _db.transaction(() async {
      final rows = await _db.customSelect(
        farmId != null
            ? 'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1'
            : 'SELECT * FROM animals WHERE id = ? LIMIT 1',
        variables: farmId != null
            ? _vars([farmId, animalId])
            : _vars([animalId]),
      ).get();
      if (rows.isEmpty) {
        throw Exception(
          'Animal não encontrado na tabela ativa para registrar óbito.',
        );
      }

      final d = rows.first.data;
      final nowIso = DateTime.now().toIso8601String();
      final deathDateOnly =
          (deathDate ?? DateTime.now()).toIso8601String().split('T').first;
      final resolvedCause =
          (causeOfDeath != null && causeOfDeath.trim().isNotEmpty)
              ? causeOfDeath.trim()
              : (d['health_issue']?.toString().trim().isNotEmpty == true
                  ? d['health_issue']?.toString().trim()
                  : null);
      final resolvedNotes = (notes != null && notes.trim().isNotEmpty)
          ? notes.trim()
          : 'Animal registrado como óbito';

      await _db.customStatement(
        '''
        INSERT OR REPLACE INTO deceased_animals(
          id, farm_id, original_animal_id, code, name, species, breed, gender,
          birth_date, weight, location, reproductive_status, name_color, category,
          birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
          year, lote, mother_id, father_id, registration_note,
          death_date, cause_of_death, death_notes, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          d['id'], farmId, d['id'], d['code'], d['name'], d['species'],
          d['breed'], d['gender'], d['birth_date'], d['weight'], d['location'],
          d['reproductive_status'], d['name_color'], d['category'],
          d['birth_weight'], d['weight_30_days'], d['weight_60_days'],
          d['weight_90_days'], d['weight_120_days'], d['year'], d['lote'],
          d['mother_id'], d['father_id'], d['registration_note'],
          deathDateOnly, resolvedCause, resolvedNotes, nowIso, nowIso,
        ],
      );

      await _deleteAnimalDependencies(animalId, farmId);
      await _db.customStatement(
        farmId != null
            ? 'DELETE FROM animals WHERE farm_id = ? AND id = ?'
            : 'DELETE FROM animals WHERE id = ?',
        farmId != null ? [farmId, animalId] : [animalId],
      );
    });
  }

  Future<void> moveToSold({
    required String animalId,
    required DateTime saleDate,
    required double salePrice,
    String? buyer,
    String? notes,
  }) async {
    await _moveToSoldInternal(
      animalId: animalId,
      saleDate: saleDate,
      salePrice: salePrice,
      buyer: buyer,
      notes: notes,
    );
    EventBus().emit(
      AnimalMarkedAsSoldEvent(
        animalId: animalId,
        saleDate: saleDate,
        salePrice: salePrice,
      ),
    );
  }

  Future<void> moveToSoldManual({
    required String animalId,
    DateTime? saleDate,
    double salePrice = 0,
    String? buyer,
    String? notes,
  }) async {
    final saleDateValue = saleDate ?? DateTime.now();
    await _moveToSoldInternal(
      animalId: animalId,
      saleDate: saleDateValue,
      salePrice: salePrice,
      buyer: buyer,
      notes: notes,
      defaultNotes: 'Status marcado como Vendido',
    );
    EventBus().emit(
      AnimalMarkedAsSoldEvent(
        animalId: animalId,
        saleDate: saleDateValue,
        salePrice: salePrice,
      ),
    );
  }

  Future<void> _moveToSoldInternal({
    required String animalId,
    required DateTime saleDate,
    required double salePrice,
    String? buyer,
    String? notes,
    String? defaultNotes,
  }) async {
    final farmId = _farmId;
    await _db.transaction(() async {
      final rows = await _db.customSelect(
        farmId != null
            ? 'SELECT * FROM animals WHERE farm_id = ? AND id = ? LIMIT 1'
            : 'SELECT * FROM animals WHERE id = ? LIMIT 1',
        variables: farmId != null
            ? _vars([farmId, animalId])
            : _vars([animalId]),
      ).get();
      if (rows.isEmpty) return;

      final d = rows.first.data;
      final nowIso = DateTime.now().toIso8601String();
      final saleDateIso = saleDate.toIso8601String().split('T').first;
      final resolvedNotes = (notes != null && notes.trim().isNotEmpty)
          ? notes.trim()
          : defaultNotes;

      await _db.customStatement(
        '''
        INSERT OR REPLACE INTO sold_animals(
          id, farm_id, original_animal_id, code, name, species, breed, gender,
          birth_date, weight, location, reproductive_status, name_color, category,
          birth_weight, weight_30_days, weight_60_days, weight_90_days, weight_120_days,
          year, lote, mother_id, father_id, registration_note,
          sale_date, sale_price, buyer, sale_notes, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          d['id'], farmId, d['id'], d['code'], d['name'], d['species'],
          d['breed'], d['gender'], d['birth_date'], d['weight'], d['location'],
          d['reproductive_status'], d['name_color'], d['category'],
          d['birth_weight'], d['weight_30_days'], d['weight_60_days'],
          d['weight_90_days'], d['weight_120_days'], d['year'], d['lote'],
          d['mother_id'], d['father_id'], d['registration_note'],
          saleDateIso, salePrice, buyer, resolvedNotes, nowIso, nowIso,
        ],
      );

      await _deleteAnimalDependencies(animalId, farmId);
      await _db.customStatement(
        farmId != null
            ? 'DELETE FROM animals WHERE farm_id = ? AND id = ?'
            : 'DELETE FROM animals WHERE id = ?',
        farmId != null ? [farmId, animalId] : [animalId],
      );
    });
  }

  Future<void> _deleteAnimalDependencies(
    String animalId,
    String? farmId,
  ) async {
    // Remove apenas alertas e agendamentos futuros/pendentes.
    // Registros já aplicados (vacinas aplicadas, medicamentos aplicados,
    // pesagens reais) ficam preservados para consulta histórica.
    Future<void> del(String sqlWithFarm, String sqlWithout) async {
      if (farmId != null) {
        await _db.customStatement(sqlWithFarm, [farmId, animalId]);
      } else {
        await _db.customStatement(sqlWithout, [animalId]);
      }
    }

    // Alertas de pesagem (sempre futuros por natureza)
    await del(
      'DELETE FROM weight_alerts WHERE farm_id = ? AND animal_id = ?',
      'DELETE FROM weight_alerts WHERE animal_id = ?',
    );

    // Vacinas agendadas mas ainda não aplicadas
    await del(
      'DELETE FROM vaccinations WHERE farm_id = ? AND animal_id = ? AND applied_date IS NULL',
      'DELETE FROM vaccinations WHERE animal_id = ? AND applied_date IS NULL',
    );

    // Medicamentos agendados mas ainda não aplicados
    await del(
      "DELETE FROM medications WHERE farm_id = ? AND animal_id = ? AND status = 'Agendado' AND applied_date IS NULL",
      "DELETE FROM medications WHERE animal_id = ? AND status = 'Agendado' AND applied_date IS NULL",
    );
  }
}
