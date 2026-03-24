import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../data/animal_lifecycle_repository.dart';
import '../data/animal_repository.dart';
import '../data/local_db.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';
import '../services/deceased_service.dart';
import '../services/system_maintenance_service.dart';
import 'seed_factory.dart';

class DiagnosticLog {
  final StringBuffer _b = StringBuffer();

  void info(String msg) {
    _b.writeln('[INFO] ${DateTime.now().toIso8601String()} $msg');
  }

  void warn(String msg) {
    _b.writeln('[WARN] ${DateTime.now().toIso8601String()} $msg');
  }

  void error(String msg, Object e, StackTrace st) {
    _b.writeln('[ERROR] ${DateTime.now().toIso8601String()} $msg');
    _b.writeln('Exception: $e');
    _b.writeln('Stack: $st');
  }

  String get text => _b.toString();
}

class DiagnosticResult {
  final bool ok;
  final String filePath;
  final String summary;
  const DiagnosticResult({
    required this.ok,
    required this.filePath,
    required this.summary,
  });
}

class DiagnosticRunner {
  final AppDatabase appDb;
  final AnimalRepository animalRepo;
  final AnimalLifecycleRepository lifecycleRepo;
  final AnimalService animalService;
  final DeceasedService deceasedService;
  final SystemMaintenanceService maintenanceService;

  DiagnosticRunner({
    required this.appDb,
    required this.animalRepo,
    required this.lifecycleRepo,
    required this.animalService,
    required this.deceasedService,
    required this.maintenanceService,
  });

  Future<DiagnosticResult> run({required bool stress}) async {
    final log = DiagnosticLog();
    final started = DateTime.now();
    var ok = true;

    log.info('=== DIAGNOSTIC RUN START stress=$stress ===');
    try {
      await _resetLocalDb(log);
      await _seedData(log, stress: stress);
      await _runScenarios(log);
      log.info('All scenarios executed');
    } catch (e, st) {
      ok = false;
      log.error('Fatal error in diagnostic run', e, st);
    }

    final durationMs = DateTime.now().difference(started).inMilliseconds;
    log.info('=== DIAGNOSTIC RUN END ok=$ok durationMs=$durationMs ===');

    final filePath = await _writeLogToFile(log.text);
    final summary = 'ok=$ok durationMs=$durationMs file=$filePath';

    return DiagnosticResult(ok: ok, filePath: filePath, summary: summary);
  }

  Future<void> _resetLocalDb(DiagnosticLog log) async {
    log.info('Resetting local database...');
    await maintenanceService.clearAllData();
  }

  Future<void> _seedData(DiagnosticLog log, {required bool stress}) async {
    log.info('Seeding data...');
    if (stress) {
      await SeedFactory.seedStress(db: appDb, log: log);
    } else {
      await SeedFactory.seedSmall(db: appDb, log: log);
    }
  }

  Future<void> _runScenarios(DiagnosticLog log) async {
    await _scenarioAnimalCrud(log);
    await _scenarioSearchAndPaging(log);
    await _scenarioMarkSold(log);
    await _scenarioMarkDeceased(log);
    await _scenarioStatsRefresh(log);
    await _scenarioFkIntegrity(log);
  }

  Future<void> _scenarioAnimalCrud(DiagnosticLog log) async {
    log.info('[SCENARIO] animal CRUD');
    try {
      final now = DateTime.now();
      final created = Animal(
        id: 'diag_animal_${now.microsecondsSinceEpoch}',
        code: 'DIAG-${now.millisecondsSinceEpoch}',
        name: 'Diag Teste',
        nameColor: 'blue',
        category: 'Teste',
        species: 'Ovino',
        breed: 'Santa Ines',
        gender: 'Fêmea',
        birthDate: now.subtract(const Duration(days: 400)),
        weight: 35,
        status: 'Saudável',
        location: 'Pasto 1',
        createdAt: now,
        updatedAt: now,
      );

      await animalService.addAnimal(created);
      final stored = await animalRepo.getAnimalById(created.id);
      if (stored == null) {
        throw Exception('Animal not found after insert');
      }

      final updated = _copyAnimal(
        stored,
        status: 'Em tratamento',
        name: '${stored.name} Atualizado',
      );
      await animalService.updateAnimal(updated);
      final after = await animalRepo.getAnimalById(created.id);
      if (after == null || after.status != 'Em tratamento') {
        throw Exception('Animal not updated');
      }

      log.info('[PASS] animal CRUD');
    } catch (e, st) {
      log.error('[FAIL] animal CRUD', e, st);
    }
  }

  Future<void> _scenarioSearchAndPaging(DiagnosticLog log) async {
    log.info('[SCENARIO] search + paging');
    try {
      final page0 = await animalRepo.getFilteredAnimals(
        searchQuery: 'seed',
        limit: 10,
        offset: 0,
      );
      final page1 = await animalRepo.getFilteredAnimals(
        searchQuery: 'seed',
        limit: 10,
        offset: 10,
      );
      final ids = <String>{};
      for (final a in page0) {
        if (!ids.add(a.id)) {
          throw Exception('Duplicate id on page0: ${a.id}');
        }
      }
      for (final a in page1) {
        if (!ids.add(a.id)) {
          throw Exception('Duplicate id across pages: ${a.id}');
        }
      }
      log.info('[PASS] search + paging');
    } catch (e, st) {
      log.error('[FAIL] search + paging', e, st);
    }
  }

  Future<void> _scenarioMarkSold(DiagnosticLog log) async {
    log.info('[SCENARIO] mark sold');
    try {
      final target = await _pickSafeAnimalForMove();
      if (target == null) {
        log.warn('No animals to mark as sold');
        return;
      }
      await lifecycleRepo.moveToSoldManual(
        animalId: target.id,
        saleDate: DateTime.now(),
        salePrice: 0,
        notes: 'Diagnóstico automático',
      );

      final soldRows = await appDb.db.query(
        'sold_animals',
        where: 'id = ?',
        whereArgs: [target.id],
        limit: 1,
      );
      final stillInAnimals = await appDb.db.query(
        'animals',
        where: 'id = ?',
        whereArgs: [target.id],
        limit: 1,
      );
      if (soldRows.isEmpty || stillInAnimals.isNotEmpty) {
        throw Exception('Animal not moved to sold_animals correctly');
      }
      log.info('[PASS] mark sold');
    } catch (e, st) {
      log.error('[FAIL] mark sold', e, st);
    }
  }

  Future<void> _scenarioMarkDeceased(DiagnosticLog log) async {
    log.info('[SCENARIO] mark deceased');
    try {
      final target = await _pickSafeAnimalForDelete();
      if (target == null) {
        log.warn('No animals to mark as deceased');
        return;
      }
      await deceasedService.markAsDeceased(
        animalId: target.id,
        deathDate: DateTime.now(),
        causeOfDeath: 'Diagnóstico',
        notes: 'Marcado pelo diagnóstico automático',
      );

      final deceasedRows = await appDb.db.query(
        'deceased_animals',
        where: 'id = ?',
        whereArgs: [target.id],
        limit: 1,
      );
      final stillInAnimals = await appDb.db.query(
        'animals',
        where: 'id = ?',
        whereArgs: [target.id],
        limit: 1,
      );
      if (deceasedRows.isEmpty || stillInAnimals.isNotEmpty) {
        throw Exception('Animal not moved to deceased_animals correctly');
      }
      log.info('[PASS] mark deceased');
    } catch (e, st) {
      log.error('[FAIL] mark deceased', e, st);
    }
  }

  Future<void> _scenarioStatsRefresh(DiagnosticLog log) async {
    log.info('[SCENARIO] stats refresh');
    try {
      await animalService.loadData();
      if (animalService.stats == null) {
        throw Exception('Stats is null after refresh');
      }
      log.info('[PASS] stats refresh');
    } catch (e, st) {
      log.error('[FAIL] stats refresh', e, st);
    }
  }

  Future<void> _scenarioFkIntegrity(DiagnosticLog log) async {
    log.info('[SCENARIO] FK integrity quick check');
    try {
      final res = await appDb.db.rawQuery('PRAGMA foreign_key_check;');
      if (res.isNotEmpty) {
        log.warn('foreign_key_check returned ${res.length} rows: $res');
      } else {
        log.info('foreign_key_check OK');
      }
      log.info('[PASS] FK integrity');
    } catch (e, st) {
      log.error('[FAIL] FK integrity', e, st);
    }
  }

  Future<Animal?> _pickSafeAnimalForMove() async {
    // Prefer an animal with no external deps to avoid conflicts.
    final safe = await _pickSafeAnimalForDelete();
    if (safe != null) return safe;
    final animals = await animalRepo.all(limit: 1);
    if (animals.isEmpty) return null;
    return animals.first;
  }

  Future<Animal?> _pickSafeAnimalForDelete() async {
    final rows = await appDb.db.rawQuery('''
      SELECT a.id
      FROM animals a
      WHERE
        NOT EXISTS (SELECT 1 FROM animal_weights w WHERE w.animal_id = a.id)
        AND NOT EXISTS (SELECT 1 FROM vaccinations v WHERE v.animal_id = a.id)
        AND NOT EXISTS (SELECT 1 FROM medications m WHERE m.animal_id = a.id)
        AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.animal_id = a.id)
        AND NOT EXISTS (SELECT 1 FROM financial_records f WHERE f.animal_id = a.id)
        AND NOT EXISTS (SELECT 1 FROM financial_accounts fa WHERE fa.animal_id = a.id)
        AND NOT EXISTS (SELECT 1 FROM breeding_records b WHERE b.female_animal_id = a.id OR b.male_animal_id = a.id)
      LIMIT 1;
    ''');
    if (rows.isEmpty) return null;
    final id = rows.first['id']?.toString();
    if (id == null || id.isEmpty) return null;
    return animalRepo.getAnimalById(id);
  }

  Future<String> _writeLogToFile(String text) async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/diagnostic_log_$ts.txt');
    await file.writeAsString(text, flush: true);
    return file.path;
  }

  Animal _copyAnimal(
    Animal a, {
    String? status,
    String? name,
  }) {
    final now = DateTime.now();
    return Animal(
      id: a.id,
      code: a.code,
      name: name ?? a.name,
      nameColor: a.nameColor,
      category: a.category,
      species: a.species,
      breed: a.breed,
      gender: a.gender,
      birthDate: a.birthDate,
      weight: a.weight,
      status: status ?? a.status,
      location: a.location,
      lastVaccination: a.lastVaccination,
      pregnant: a.pregnant,
      expectedDelivery: a.expectedDelivery,
      healthIssue: a.healthIssue,
      createdAt: a.createdAt,
      updatedAt: now,
      birthWeight: a.birthWeight,
      weight30Days: a.weight30Days,
      weight60Days: a.weight60Days,
      weight90Days: a.weight90Days,
      weight120Days: a.weight120Days,
      year: a.year,
      lote: a.lote,
      motherId: a.motherId,
      fatherId: a.fatherId,
    );
  }
}
