// lib/data/reports_repository.dart
// Data layer helpers for generating report datasets.
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:sqflite_common/sqlite_api.dart';

import '../data/local_db.dart';
import '../models/animal.dart';
import '../models/report_filters.dart';

void _log(String message) {
  developer.log(message, name: 'ReportsRepository');
}

class _ReportsQueries {
  static Future<Database> _resolveDatabase(Database? injected) async {
    if (injected != null) return injected;
    throw StateError(
      'Database instance must be provided when querying reports.',
    );
  }

  // ----------------- Helpers -----------------
  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is num) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(v.toInt());
      } catch (_) {}
    }

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    // dd/MM/yyyy
    if (s.contains('/')) {
      final p = s.split('/');
      if (p.length >= 3) {
        final d = int.tryParse(p[0]);
        final m = int.tryParse(p[1]);
        final y = int.tryParse(p[2]);
        if (d != null && m != null && y != null) {
          try {
            return DateTime(y, m, d);
          } catch (_) {}
        }
      }
    }

    // ISO
    try {
      final dtFull = DateTime.tryParse(s);
      if (dtFull != null) return dtFull;
      if (s.length >= 10) {
        final iso = s.substring(0, 10);
        if (iso.length == 10 && iso[4] == '-' && iso[7] == '-') {
          return DateTime.tryParse(iso);
        }
      }
    } catch (_) {}
    return null;
  }

  static bool _between(DateTime? d, DateTime start, DateTime end) {
    if (d == null) return false;
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// Aplica paginação em memória e registra total em [out] para uso na UI.
  static List<T> _paginate<T>(
    List<T> data,
    ReportFilters filters,
    Map<String, dynamic> out,
  ) {
    out['total'] = data.length;
    final offset = (filters.offset ?? 0);
    final limit = filters.limit;
    if (offset >= data.length) return const [];
    if (limit == null) return data.sublist(offset);
    final end = (offset + limit).clamp(0, data.length);
    return data.sublist(offset, end);
  }

  static String _asLower(dynamic v) =>
      (v == null ? '' : v.toString()).trim().toLowerCase();

  static bool _isAll(String? value) =>
      value == null || value.trim().isEmpty || value.trim() == 'Todos';

  static String _normText(dynamic v) {
    return _asLower(v)
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  static String _normColor(dynamic color) {
    final c = _normText(color);
    switch (c) {
      case 'blue':
      case 'azul':
        return 'azul';
      case 'red':
      case 'vermelho':
      case 'vermelha':
        return 'vermelho';
      case 'green':
      case 'verde':
        return 'verde';
      case 'yellow':
      case 'amarelo':
      case 'amarela':
        return 'amarelo';
      case 'orange':
      case 'laranja':
        return 'laranja';
      case 'purple':
      case 'roxo':
      case 'roxa':
        return 'roxo';
      case 'pink':
      case 'rosa':
        return 'rosa';
      case 'grey':
      case 'gray':
      case 'cinza':
        return 'cinza';
      case 'white':
      case 'branco':
      case 'branca':
        return 'branco';
      case 'black':
      case 'preto':
      case 'preta':
        return 'preto';
      default:
        return c;
    }
  }

  static bool _animalMatchesReportFilters(
    Animal animal,
    ReportFilters filters, {
    bool includeStatus = true,
  }) {
    if (!_isAll(filters.species) &&
        _normText(animal.species) != _normText(filters.species)) {
      return false;
    }
    if (!_isAll(filters.gender) &&
        _normText(animal.gender) != _normText(filters.gender)) {
      return false;
    }
    if (includeStatus &&
        !_isAll(filters.status) &&
        _normText(animal.status) != _normText(filters.status)) {
      return false;
    }
    if (!_isAll(filters.category) &&
        _normText(animal.category) != _normText(filters.category)) {
      return false;
    }
    if (!_isAll(filters.reproductiveStatus) &&
        _normText(animal.reproductiveStatus) !=
            _normText(filters.reproductiveStatus)) {
      return false;
    }
    if (!_isAll(filters.color) &&
        _normColor(animal.nameColor) != _normColor(filters.color)) {
      return false;
    }
    final loteFilter = (filters.lote ?? '').trim();
    if (loteFilter.isNotEmpty &&
        !_normText(animal.lote).contains(_normText(loteFilter))) {
      return false;
    }
    return true;
  }

  static bool _rowAnimalMatchesReportFilters(
    Map<String, dynamic> row,
    ReportFilters filters, {
    bool includeStatus = true,
  }
  ) {
    if (!_isAll(filters.species) &&
        _normText(row['animal_species']) != _normText(filters.species)) {
      return false;
    }
    if (!_isAll(filters.gender) &&
        _normText(row['animal_gender']) != _normText(filters.gender)) {
      return false;
    }
    if (includeStatus &&
        !_isAll(filters.status) &&
        _normText(row['animal_status']) != _normText(filters.status)) {
      return false;
    }
    if (!_isAll(filters.category) &&
        _normText(row['animal_category']) != _normText(filters.category)) {
      return false;
    }
    if (!_isAll(filters.reproductiveStatus) &&
        _normText(row['animal_reproductive_status']) !=
            _normText(filters.reproductiveStatus)) {
      return false;
    }
    if (!_isAll(filters.color) &&
        _normColor(row['animal_color']) != _normColor(filters.color)) {
      return false;
    }
    final loteFilter = (filters.lote ?? '').trim();
    if (loteFilter.isNotEmpty &&
        !_normText(row['animal_lote']).contains(_normText(loteFilter))) {
      return false;
    }
    return true;
  }

  static String _stagePtLabel(dynamic stage) {
    switch (_normText(stage)) {
      case 'encabritamento':
        return 'Encabritamento';
      case 'separacao':
        return 'Separação';
      case 'aguardando_ultrassom':
        return 'Aguardando Ultrassom';
      case 'gestacao_confirmada':
        return 'Gestação Confirmada';
      case 'parto_realizado':
        return 'Parto Realizado';
      case 'falhou':
        return 'Falhou';
      default:
        return (stage ?? '').toString();
    }
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    final s = v
        .toString()
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(s) ?? 0.0;
  }

  static String _firstNonEmpty(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '';
  }

  // remove acentos, espaços e normaliza para snake-case minúsculo
  static String _slug(String s) {
    final lower = s.toLowerCase();
    final noAccents = lower
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
    return noAccents.replaceAll(' ', '_');
  }

  static String _yyyyMmDd(DateTime d) => d.toIso8601String().substring(0, 10);

  static String _normalizeStoredReportType(String reportType) {
    final normalized = reportType.trim();
    switch (normalized) {
      case 'Animais':
      case 'Vacinações':
      case 'Reprodução':
      case 'Saúde':
      case 'Financeiro':
        return normalized;
      case 'Pesos':
      case 'Medicações':
      case 'Anotações':
        return 'Saúde';
      default:
        return 'Saúde';
    }
  }

  static Future<List<Animal>> _loadAnimals(Database db) async {
    final rows = await db.query('animals');
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  // ==================== ANIMAIS ====================
  static Future<Map<String, dynamic>> getAnimalsReport(
    ReportFilters filters, {
    Database? db,
  }) async {
    final database = await _resolveDatabase(db);
    var animals = await _animalsWithinPeriod(database, filters);
    animals = _applyAnimalReportFilters(animals, filters);
    final map = <String, dynamic>{};
    final paged = _paginate(animals, filters, map);

    return {
      'summary': _buildAnimalSummary(animals),
      'data': _mapAnimalsReportRows(paged),
      'total': map['total'] ?? animals.length,
    };
  }

  // ---------- Pesos: leitor robusto ----------
  static Future<List<Map<String, dynamic>>> _readWeightRows(
    Database db,
    DateTime start,
    DateTime end,
  ) async {
    final s = _yyyyMmDd(start);
    final e = _yyyyMmDd(end);

    Future<List<Map<String, dynamic>>> tryQuery(
        String table, String dcol, String wcol) async {
      try {
        final rows = await db.rawQuery('''
          SELECT id, animal_id, $dcol AS date, $wcol AS weight
          FROM $table
          WHERE $dcol >= ? AND $dcol <= ?
          ORDER BY $dcol ASC
        ''', [s, e]);
        _log('✅ Encontrados ${rows.length} registros de peso em $table');
        return rows;
      } catch (err) {
        _log('⚠️ Erro ao buscar pesos em $table: $err');
        return [];
      }
    }

    // ordem de tentativas (tabelas/colunas legadas comuns)
    var rows = await tryQuery('animal_weights', 'date', 'weight');
    if (rows.isEmpty) rows = await tryQuery('weights', 'date', 'weight');
    if (rows.isEmpty) {
      rows = await tryQuery('weights', 'weigh_date', 'weight');
    }
    if (rows.isEmpty) {
      rows = await tryQuery('animal_weight', 'date', 'weight');
    }
    if (rows.isEmpty) {
      rows = await tryQuery('animal_weight', 'recorded_at', 'weight');
    }

    return rows;
  }

  // ==================== PESOS ====================
  static Future<Map<String, dynamic>> getWeightsReport(
    ReportFilters filters, {
    Database? db,
  }) async {
    final database = await _resolveDatabase(db);
    var animals = await _loadAnimals(database);
    animals = _applyAnimalReportFilters(animals, filters);
    final animalMap = {for (var a in animals) a.id: a};
    final weights =
        await _readWeightRows(database, filters.startDate, filters.endDate);
    final groupedWeights = _groupWeightsByAnimal(weights, animals, filters);

    final animalStats = _buildWeightStatistics(groupedWeights, animalMap);
    final summary = _buildWeightSummary(weights, groupedWeights, animalStats);
    final map = <String, dynamic>{};
    final paged = _paginate(animalStats, filters, map);

    return {
      'summary': summary,
      'data': paged,
      'total': map['total'] ?? animalStats.length,
    };
  }

  // ==================== VACINAÇÕES ====================
  static Future<Map<String, dynamic>> getVaccinationsReport(
    ReportFilters filters, {
    Database? db,
  }) async {
    final database = await _resolveDatabase(db);
    final vaccinations = (await _fetchVaccinationsWithAnimals(database, filters))
        .where((row) => _rowAnimalMatchesReportFilters(
              row,
              filters,
              includeStatus: false,
            ))
        .toList();
    final map = <String, dynamic>{};
    final paged = _paginate(vaccinations, filters, map);

    return {
      'summary': _buildStatusSummary(vaccinations),
      'data': paged.map(_mapVaccinationRow).toList(),
      'total': map['total'] ?? vaccinations.length,
    };
  }

  // ==================== MEDICAÇÕES ====================
  static Future<Map<String, dynamic>> getMedicationsReport(
    ReportFilters filters, {
    Database? db,
  }) async {
    final database = await _resolveDatabase(db);
    final medications = (await _fetchMedicationsWithAnimals(database, filters))
        .where((row) => _rowAnimalMatchesReportFilters(
              row,
              filters,
              includeStatus: false,
            ))
        .toList();
    final map = <String, dynamic>{};
    final paged = _paginate(medications, filters, map);

    return {
      'summary': _buildStatusSummary(medications),
      'data': paged.map(_mapMedicationRow).toList(),
      'total': map['total'] ?? medications.length,
    };
  }

  // ==================== REPRODUÇÃO ====================
  static Future<Map<String, dynamic>> getBreedingReport(
    ReportFilters filters, {
    Database? db,
  }) async {
    final database = await _resolveDatabase(db);

    final breeding = await _fetchBreedingRecords(database, filters);
    final animals = await _loadAnimals(database);
    final animalMap = {for (var a in animals) a.id: a};
    final filteredBreeding = breeding
        .where((row) => _breedingMatchesFilters(row, animalMap, filters))
        .toList();

    final summary = _stageSummary(filteredBreeding);
    final map = <String, dynamic>{};
    final paged = _paginate(filteredBreeding, filters, map);

    return {
      'summary': summary,
      'data': paged.map((b) => _mapBreedingRow(b, animalMap)).toList(),
      'total': map['total'] ?? filteredBreeding.length,
    };
  }

  // ==================== FINANCEIRO ====================
  static Future<List<Map<String, dynamic>>> _readFinancialRows(
    Database db,
    ReportFilters filters,
  ) async {
    List<Map<String, dynamic>> rows = [];
    final startDate = _yyyyMmDd(filters.startDate);
    final endDate = _yyyyMmDd(filters.endDate);

    Future<void> tryTable(String name) async {
      if (rows.isNotEmpty) return;
      try {
        rows = await db.rawQuery('''
          SELECT *
          FROM $name
          WHERE DATE(COALESCE(paid_date, date, due_date, created_at, updated_at)) >= ?
            AND DATE(COALESCE(paid_date, date, due_date, created_at, updated_at)) <= ?
        ''', [startDate, endDate]);
      } catch (_) {
        try {
          rows = await db.query(name);
        } catch (_) {}
      }
    }

    await tryTable('financial_accounts');
    await tryTable('finance_accounts');
    await tryTable('financial');
    await tryTable('accounts');
    await tryTable('financial_records');

    return rows;
  }

  /// Compatível com chaves snake/camel e datas dd/MM/yyyy ou ISO.
  /// Período usa data efetiva: paid_date ?? date ?? due_date ?? created_at.
  static Future<Map<String, dynamic>> getFinancialReport(
    ReportFilters filters, {
    Database? db,
  }) async {
    final database = await _resolveDatabase(db);
    final animals = await _loadAnimals(database);
    final animalMap = {for (var a in animals) a.id: a};

    final raw = await _readFinancialRows(database, filters);
    var normalized = _normalizeFinancialRows(raw, animalMap);
    normalized = _filterFinancialRows(normalized, filters);
    normalized.sort(_sortByEffectiveDateDesc);

    final summary = _buildFinancialSummary(normalized);
    final map = <String, dynamic>{};
    final paged = _paginate(normalized, filters, map);
    final data = paged.map(_mapFinancialRow).toList();

    return {
      'summary': summary,
      'data': data,
      'total': map['total'] ?? normalized.length,
    };
  }

  // ==================== ANOTAÇÕES ====================
  static Future<Map<String, dynamic>> getNotesReport(
    ReportFilters filters, {
    Database? db,
  }) async {
    final database = await _resolveDatabase(db);

    var notes = await _fetchNotes(database, filters);
    final animals = await _loadAnimals(database);
    final animalMap = {for (var a in animals) a.id: a};
    notes = notes.where((note) {
      final animalId = note['animal_id']?.toString();
      if (animalId == null || animalId.isEmpty) {
        return _isAll(filters.species) &&
            _isAll(filters.gender) &&
            _isAll(filters.status) &&
            _isAll(filters.category) &&
            _isAll(filters.color) &&
            _isAll(filters.reproductiveStatus) &&
            (filters.lote ?? '').trim().isEmpty;
      }
      final animal = animalMap[animalId];
      if (animal == null) return false;
      return _animalMatchesReportFilters(animal, filters);
    }).toList();

    final summary = _buildNotesSummary(notes);
    final map = <String, dynamic>{};
    final paged = _paginate(notes, filters, map);

    return {
      'summary': summary,
      'data': paged.map((n) => _mapNoteRow(n, animalMap)).toList(),
      'total': map['total'] ?? notes.length,
    };
  }

  // ==================== SALVAR HISTÓRICO DE RELATÓRIOS ====================
  static Future<void> saveGeneratedReport({
    required String title,
    required String reportType,
    required Map<String, dynamic> parameters,
    String generatedBy = 'Dashboard',
    Database? db,
  }) async {
    final database = await _resolveDatabase(db);
    final normalizedType = _normalizeStoredReportType(reportType);
    final paramsToStore = Map<String, dynamic>.from(parameters);
    if (normalizedType != reportType) {
      paramsToStore['source_report_type'] = reportType;
    }

    await database.insert('reports', {
      'id': 'rep_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'report_type': normalizedType,
      'parameters': jsonEncode(paramsToStore),
      'generated_at': DateTime.now().toIso8601String(),
      'generated_by': generatedBy,
    });
  }

  // ---------- Animals helpers ----------
  static Future<List<Animal>> _animalsWithinPeriod(
    Database db,
    ReportFilters filters,
  ) async {
    final startDate = _yyyyMmDd(filters.startDate);
    final endDate = _yyyyMmDd(filters.endDate);
    final rows = await db.query(
      'animals',
      where: 'DATE(created_at) >= ? AND DATE(created_at) <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Animal.fromMap).toList();
  }

  static List<Animal> _applyAnimalReportFilters(
    List<Animal> animals,
    ReportFilters filters,
  ) {
    return animals
        .where((a) => _animalMatchesReportFilters(a, filters))
        .toList();
  }

  static Map<String, dynamic> _buildAnimalSummary(List<Animal> animals) {
    final ovinos = animals.where((a) => a.species == 'Ovino').length;
    final caprinos = animals.where((a) => a.species == 'Caprino').length;
    final machos = animals.where((a) => a.gender == 'Macho').length;
    final femeas = animals.where((a) => a.gender == 'Fêmea').length;

    return {
      'total': animals.length,
      'ovinos': ovinos,
      'caprinos': caprinos,
      'machos': machos,
      'femeas': femeas,
    };
  }

  static List<Map<String, dynamic>> _mapAnimalsReportRows(
      List<Animal> animals) {
    return animals
        .map((a) => {
              'code': a.code,
              'name': a.name,
              'species': a.species,
              'breed': a.breed,
              'gender': a.gender,
              'name_color': a.nameColor,
              'lote': a.lote ?? '',
              'birth_date': _yyyyMmDd(a.birthDate),
              'weight': a.weight,
              'status': a.status,
              'reproductive_status': a.reproductiveStatus,
              'location': a.location,
              'category': a.category,
              'pregnant': a.pregnant,
              'expected_delivery': a.expectedDelivery ?? '',
            })
        .toList();
  }

  // ---------- Weights helpers ----------
  static Map<String, List<Map<String, dynamic>>> _groupWeightsByAnimal(
    List<Map<String, dynamic>> weights,
    List<Animal> animals,
    ReportFilters filters,
  ) {
    final allowedAnimalIds = animals.map((a) => a.id).toSet();
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var w in weights) {
      final animalId = (w['animal_id'] ?? '').toString();
      if (animalId.isEmpty) continue;
      if (!allowedAnimalIds.contains(animalId)) continue;
      grouped.putIfAbsent(animalId, () => []);
      grouped[animalId]!.add(w);
    }

    _log('📊 Histórico de pesagens encontrado: ${weights.length}');
    _log('📊 Animais com histórico: ${grouped.length}');

    if (weights.isEmpty) {
      _log(
        '⚠️ Nenhum histórico de pesagens encontrado, usando pesos atuais dos animais',
      );
      for (var animal in animals) {
        final createdAt = _toDate(animal.createdAt);
        if (!_between(createdAt, filters.startDate, filters.endDate)) continue;
        if (animal.weight <= 0) continue;
        grouped.putIfAbsent(animal.id, () => []);
        grouped[animal.id]!.add({
          'animal_id': animal.id,
          'date': _yyyyMmDd(animal.createdAt),
          'weight': animal.weight,
        });
      }
      _log('📊 Animais adicionados com peso atual: ${grouped.length}');
    }

    return grouped;
  }

  static List<Map<String, dynamic>> _buildWeightStatistics(
    Map<String, List<Map<String, dynamic>>> groupedWeights,
    Map<String, Animal> animalMap,
  ) {
    return groupedWeights.entries.map((entry) {
      final animalId = entry.key;
      final weighings = entry.value;
      final animal = animalMap[animalId];

      final weightValues =
          weighings.map((w) => (w['weight'] as num).toDouble()).toList();

      weighings
          .sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

      final double lastWeight =
          weighings.isEmpty ? 0 : (weighings[0]['weight'] as num).toDouble();

      return {
        'animal_id': animalId,
        'animal_code': animal?.code ?? 'N/A',
        'animal_name': animal?.name ?? 'N/A',
        'animal_color': animal?.nameColor ?? '',
        'animal_gender': animal?.gender ?? '',
        'animal_species': animal?.species ?? '',
        'animal_status': animal?.status ?? '',
        'animal_category': animal?.category ?? '',
        'animal_reproductive_status': animal?.reproductiveStatus ?? '',
        'animal_lote': animal?.lote ?? '',
        'count': weightValues.length,
        'min': weightValues.isEmpty
            ? 0
            : weightValues.reduce((a, b) => a < b ? a : b),
        'max': weightValues.isEmpty
            ? 0
            : weightValues.reduce((a, b) => a > b ? a : b),
        'avg': weightValues.isEmpty
            ? 0
            : weightValues.reduce((a, b) => a + b) / weightValues.length,
        'last_weight': lastWeight,
        'last_date': weighings.isEmpty ? '' : weighings[0]['date'],
      };
    }).toList();
  }

  static Map<String, dynamic> _buildWeightSummary(
    List<Map<String, dynamic>> weights,
    Map<String, List<Map<String, dynamic>>> groupedWeights,
    List<Map<String, dynamic>> animalStats,
  ) {
    final allLastWeights = animalStats
        .map((s) => (s['last_weight'] as num).toDouble())
        .where((w) => w > 0)
        .toList();

    return {
      'total_weighings':
          weights.isEmpty ? groupedWeights.length : weights.length,
      'animals_weighed': groupedWeights.length,
      'avg_last_weight': allLastWeights.isEmpty
          ? 0
          : allLastWeights.reduce((a, b) => a + b) / allLastWeights.length,
    };
  }

  // ---------- Vaccination / Medication helpers ----------
  static Future<List<Map<String, dynamic>>> _fetchVaccinationsWithAnimals(
    Database db,
    ReportFilters filters,
  ) {
    final startDate = _yyyyMmDd(filters.startDate);
    final endDate = _yyyyMmDd(filters.endDate);
    final clauses = <String>[
      'DATE(COALESCE(v.applied_date, v.scheduled_date)) >= ?',
      'DATE(COALESCE(v.applied_date, v.scheduled_date)) <= ?',
    ];
    final args = <dynamic>[startDate, endDate];

    if (filters.status != null && filters.status != 'Todos') {
      clauses.add('v.status = ?');
      args.add(filters.status);
    }
    if (filters.vaccineType != null && filters.vaccineType != 'Todos') {
      clauses.add('v.vaccine_type = ?');
      args.add(filters.vaccineType);
    }

    final where = clauses.join(' AND ');
    return db.rawQuery('''
      SELECT 
        v.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender,
        a.species AS animal_species,
        a.status AS animal_status,
        a.category AS animal_category,
        a.reproductive_status AS animal_reproductive_status,
        a.lote AS animal_lote
      FROM vaccinations v
      LEFT JOIN animals a ON a.id = v.animal_id
      WHERE $where
      ORDER BY COALESCE(v.applied_date, v.scheduled_date) DESC
    ''', args);
  }

  static Future<List<Map<String, dynamic>>> _fetchMedicationsWithAnimals(
    Database db,
    ReportFilters filters,
  ) {
    const dateExpr =
        "CASE WHEN m.status = 'Aplicado' AND m.applied_date IS NOT NULL THEN m.applied_date ELSE m.date END";

    final startDate = _yyyyMmDd(filters.startDate);
    final endDate = _yyyyMmDd(filters.endDate);
    final clauses = <String>[
      'DATE($dateExpr) >= ?',
      'DATE($dateExpr) <= ?',
    ];
    final args = <dynamic>[startDate, endDate];

    if (filters.medicationStatus != null &&
        filters.medicationStatus != 'Todos') {
      clauses.add('m.status = ?');
      args.add(filters.medicationStatus);
    }

    final where = clauses.join(' AND ');
    return db.rawQuery('''
      SELECT 
        m.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color,
        a.gender AS animal_gender,
        a.species AS animal_species,
        a.status AS animal_status,
        a.category AS animal_category,
        a.reproductive_status AS animal_reproductive_status,
        a.lote AS animal_lote
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
      WHERE $where
      ORDER BY $dateExpr DESC
    ''', args);
  }

  static Map<String, dynamic> _buildStatusSummary(
      List<Map<String, dynamic>> rows) {
    final scheduled = rows.where((m) => m['status'] == 'Agendado').length;
    final applied = rows.where((m) => m['status'] == 'Aplicado').length;
    final cancelled = rows.where((m) => m['status'] == 'Cancelado').length;

    return {
      'total': rows.length,
      'scheduled': scheduled,
      'applied': applied,
      'cancelled': cancelled,
    };
  }

  static Map<String, dynamic> _mapVaccinationRow(Map<String, dynamic> row) {
    return {
      'animal_code': row['animal_code'] ?? 'N/A',
      'animal_name': row['animal_name'] ?? 'N/A',
      'animal_color': row['animal_color'] ?? '',
      'animal_gender': row['animal_gender'] ?? '',
      'animal_species': row['animal_species'] ?? '',
      'animal_category': row['animal_category'] ?? '',
      'animal_reproductive_status': row['animal_reproductive_status'] ?? '',
      'animal_lote': row['animal_lote'] ?? '',
      'vaccine_name': row['vaccine_name'],
      'vaccine_type': row['vaccine_type'],
      'scheduled_date': row['scheduled_date'],
      'applied_date': row['applied_date'] ?? '',
      'status': row['status'],
      'veterinarian': row['veterinarian'] ?? '',
      'notes': row['notes'] ?? '',
    };
  }

  static Map<String, dynamic> _mapMedicationRow(Map<String, dynamic> row) {
    return {
      'animal_code': row['animal_code'] ?? 'N/A',
      'animal_name': row['animal_name'] ?? 'N/A',
      'animal_color': row['animal_color'] ?? '',
      'animal_gender': row['animal_gender'] ?? '',
      'animal_species': row['animal_species'] ?? '',
      'animal_category': row['animal_category'] ?? '',
      'animal_reproductive_status': row['animal_reproductive_status'] ?? '',
      'animal_lote': row['animal_lote'] ?? '',
      'medication_name': row['medication_name'],
      'date': row['date'],
      'next_date': row['next_date'] ?? '',
      'applied_date': row['applied_date'] ?? '',
      'status': row['status'],
      'dosage': row['dosage'] ?? '',
      'veterinarian': row['veterinarian'] ?? '',
      'notes': row['notes'] ?? '',
    };
  }

  // ---------- Breeding helpers ----------
  static Future<List<Map<String, dynamic>>> _fetchBreedingRecords(
    Database db,
    ReportFilters filters,
  ) async {
    final startDate = _yyyyMmDd(filters.startDate);
    final endDate = _yyyyMmDd(filters.endDate);
    final clauses = <String>[
      'DATE(breeding_date) >= ?',
      'DATE(breeding_date) <= ?',
    ];
    final args = <dynamic>[startDate, endDate];

    if (filters.breedingStage != null && filters.breedingStage != 'Todos') {
      clauses.add('stage = ?');
      args.add(_slug(filters.breedingStage!));
    }

    final rows = await db.query(
      'breeding_records',
      where: clauses.join(' AND '),
      whereArgs: args,
    );
    _log('📊 Registros após filtros: ${rows.length}');
    return rows;
  }

  static Map<String, dynamic> _stageSummary(List<Map<String, dynamic>> rows) {
    final byStage = <String, int>{};
    for (var b in rows) {
      final stage = _stagePtLabel(b['stage']).trim().isEmpty
          ? 'Não definido'
          : _stagePtLabel(b['stage']);
      byStage[stage] = (byStage[stage] ?? 0) + 1;
    }
    return {
      'total': rows.length,
      ...byStage,
    };
  }

  static Map<String, dynamic> _mapBreedingRow(
    Map<String, dynamic> row,
    Map<String, Animal> animals,
  ) {
    final female = animals[row['female_animal_id']];
    final male = animals[row['male_animal_id']];
    return {
      'female_code': female?.code ?? 'N/A',
      'female_name': female?.name ?? 'N/A',
      'female_color': female?.nameColor ?? '',
      'female_lote': female?.lote ?? '',
      'male_code': male?.code ?? 'N/A',
      'male_name': male?.name ?? 'N/A',
      'male_color': male?.nameColor ?? '',
      'male_lote': male?.lote ?? '',
      'breeding_date': row['breeding_date'] ?? '',
      'expected_birth': row['expected_birth'] ?? '',
      'stage': _stagePtLabel(row['stage']),
      'status': row['status'] ?? '',
      'mating_start_date': row['mating_start_date'] ?? '',
      'mating_end_date': row['mating_end_date'] ?? '',
      'separation_date': row['separation_date'] ?? '',
      'ultrasound_date': row['ultrasound_date'] ?? '',
      'ultrasound_result': row['ultrasound_result'] ?? '',
      'birth_date': row['birth_date'] ?? '',
    };
  }

  static bool _breedingMatchesFilters(
    Map<String, dynamic> row,
    Map<String, Animal> animals,
    ReportFilters filters,
  ) {
    final female = animals[row['female_animal_id']];
    final male = animals[row['male_animal_id']];
    final pair = <Animal>[if (female != null) female, if (male != null) male];
    bool anyMatch(bool Function(Animal a) test) => pair.any(test);

    if (!_isAll(filters.species) &&
        !anyMatch((a) => _normText(a.species) == _normText(filters.species))) {
      return false;
    }
    if (!_isAll(filters.gender) &&
        !anyMatch((a) => _normText(a.gender) == _normText(filters.gender))) {
      return false;
    }
    if (!_isAll(filters.status) &&
        !anyMatch((a) => _normText(a.status) == _normText(filters.status))) {
      return false;
    }
    if (!_isAll(filters.category) &&
        !anyMatch((a) => _normText(a.category) == _normText(filters.category))) {
      return false;
    }
    if (!_isAll(filters.reproductiveStatus) &&
        !anyMatch((a) =>
            _normText(a.reproductiveStatus) ==
            _normText(filters.reproductiveStatus))) {
      return false;
    }
    if (!_isAll(filters.color) &&
        !anyMatch((a) => _normColor(a.nameColor) == _normColor(filters.color))) {
      return false;
    }
    final loteFilter = (filters.lote ?? '').trim();
    if (loteFilter.isNotEmpty &&
        !anyMatch((a) => _normText(a.lote).contains(_normText(loteFilter)))) {
      return false;
    }
    return true;
  }

  // ---------- Financial helpers ----------
  static List<Map<String, dynamic>> _normalizeFinancialRows(
    List<Map<String, dynamic>> raw,
    Map<String, Animal> animalMap,
  ) {
    final normalized = <Map<String, dynamic>>[];
    for (final f in raw) {
      final map = Map<String, dynamic>.from(f);

      var type = _asLower(map['type'] ?? map['tipo']);
      if (type.isEmpty) {
        final t2 = _asLower(map['kind'] ?? map['categoria_tipo']);
        if (t2 == 'income') type = 'receita';
        if (t2 == 'expense') type = 'despesa';
      }
      if (type == 'income') type = 'receita';
      if (type == 'expense') type = 'despesa';

      final status = _asLower(map['status']);
      final category = (map['category'] ?? map['categoria'] ?? '').toString();
      final rawDate = _firstNonEmpty(map, [
        'paid_date',
        'paidDate',
        'payment_date',
        'date',
        'data',
        'due_date',
        'dueDate',
        'created_at',
        'createdAt'
      ]);
      final eff = _toDate(rawDate);
      final amount = _toDouble(map['amount'] ?? map['valor']);

      final animalId = map['animal_id'] ?? map['animalId'];
      Animal? animal;
      if (animalId != null && animalMap.containsKey(animalId)) {
        animal = animalMap[animalId];
      }

      normalized.add({
        'effective_date': eff,
        'date': rawDate,
        'type': type,
        'status': status,
        'category': category,
        'amount': amount,
        'description':
            (map['description'] ?? map['descricao'] ?? '').toString(),
        'animal_code': animal?.code ?? '',
        'animal_name': animal?.name ?? '',
        'animal_color': animal?.nameColor ?? '',
        'animal_gender': animal?.gender ?? '',
        'animal_species': animal?.species ?? '',
        'animal_status': animal?.status ?? '',
        'animal_category': animal?.category ?? '',
        'animal_reproductive_status': animal?.reproductiveStatus ?? '',
        'animal_lote': animal?.lote ?? '',
      });
    }
    return normalized;
  }

  static List<Map<String, dynamic>> _filterFinancialRows(
    List<Map<String, dynamic>> rows,
    ReportFilters filters,
  ) {
    var result = rows
        .where((m) => _between(m['effective_date'] as DateTime?,
            filters.startDate, filters.endDate))
        .toList();

    if (filters.financialType != null && filters.financialType != 'Todos') {
      final ft = _asLower(filters.financialType);
      result = result.where((m) => m['type'] == ft).toList();
    }
    if (filters.financialCategory != null &&
        filters.financialCategory != 'Todos') {
      final catFilter = _normText(filters.financialCategory);
      result = result
          .where((m) => _normText(m['category']).contains(catFilter))
          .toList();
    }

    result = result
        .where((row) => _rowAnimalMatchesReportFilters(
              row,
              filters,
              includeStatus: false,
            ))
        .toList();
    return result;
  }

  static int _sortByEffectiveDateDesc(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final da = a['effective_date'] as DateTime?;
    final db = b['effective_date'] as DateTime?;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  }

  static Map<String, double> _buildFinancialSummary(
      List<Map<String, dynamic>> rows) {
    final revenue = rows
        .where((m) => m['type'] == 'receita')
        .fold<double>(0.0, (sum, m) => sum + (m['amount'] as double));
    final expense = rows
        .where((m) => m['type'] == 'despesa')
        .fold<double>(0.0, (sum, m) => sum + (m['amount'] as double));
    return {
      'revenue': revenue,
      'expense': expense,
      'balance': revenue - expense,
    };
  }

  static Map<String, dynamic> _mapFinancialRow(Map<String, dynamic> row) {
    final type = (row['type'] ?? '').toString().toLowerCase();
    return {
      'date': row['date'] ?? '',
      'type': type == 'receita'
          ? 'Receita'
          : type == 'despesa'
              ? 'Despesa'
              : row['type'],
      'category': row['category'],
      'amount': row['amount'],
      'description': row['description'],
      'status':
          (row['status'] as String?)?.isEmpty ?? true ? '' : row['status'],
      'animal_code': row['animal_code'],
      'animal_name': row['animal_name'] ?? '',
      'animal_color': row['animal_color'] ?? '',
      'animal_gender': row['animal_gender'] ?? '',
      'animal_species': row['animal_species'] ?? '',
      'animal_category': row['animal_category'] ?? '',
      'animal_reproductive_status': row['animal_reproductive_status'] ?? '',
      'animal_lote': row['animal_lote'] ?? '',
    };
  }

  // ---------- Notes helpers ----------
  static Future<List<Map<String, dynamic>>> _fetchNotes(
    Database db,
    ReportFilters filters,
  ) async {
    final startDate = _yyyyMmDd(filters.startDate);
    final endDate = _yyyyMmDd(filters.endDate);
    final clauses = <String>[
      'DATE(date) >= ?',
      'DATE(date) <= ?',
    ];
    final args = <dynamic>[startDate, endDate];

    if (filters.notesIsRead != null) {
      clauses.add('is_read = ?');
      args.add(filters.notesIsRead! ? 1 : 0);
    }
    if (filters.notesPriority != null && filters.notesPriority != 'Todos') {
      clauses.add('priority = ?');
      args.add(filters.notesPriority);
    }

    return db.query(
      'notes',
      where: clauses.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC',
    );
  }

  static Map<String, int> _buildNotesSummary(List<Map<String, dynamic>> notes) {
    final read = notes.where((n) => n['is_read'] == 1).length;
    final unread = notes.where((n) => n['is_read'] != 1).length;
    final high = notes.where((n) => n['priority'] == 'Alta').length;
    final medium = notes.where((n) => n['priority'] == 'Média').length;
    final low = notes.where((n) => n['priority'] == 'Baixa').length;
    return {
      'total': notes.length,
      'read': read,
      'unread': unread,
      'high': high,
      'medium': medium,
      'low': low,
    };
  }

  static Map<String, dynamic> _mapNoteRow(
    Map<String, dynamic> row,
    Map<String, Animal> animals,
  ) {
    final animal = row['animal_id'] != null ? animals[row['animal_id']] : null;
    return {
      'date': row['date'],
      'title': row['title'],
      'category': row['category'],
      'priority': row['priority'],
      'is_read': row['is_read'] == 1,
      'animal_code': animal?.code ?? '',
      'animal_name': animal?.name ?? '',
      'animal_color': animal?.nameColor ?? '',
      'animal_gender': animal?.gender ?? '',
      'animal_species': animal?.species ?? '',
      'animal_status': animal?.status ?? '',
      'animal_category': animal?.category ?? '',
      'animal_reproductive_status': animal?.reproductiveStatus ?? '',
      'animal_lote': animal?.lote ?? '',
    };
  }
}

class ReportsRepository {
  final AppDatabase _appDatabase;

  ReportsRepository(this._appDatabase);

  Database get _db => _appDatabase.db;

  Future<Map<String, dynamic>> getAnimalsReport(ReportFilters filters) =>
      _ReportsQueries.getAnimalsReport(filters, db: _db);

  Future<Map<String, dynamic>> getWeightsReport(ReportFilters filters) =>
      _ReportsQueries.getWeightsReport(filters, db: _db);

  Future<Map<String, dynamic>> getVaccinationsReport(ReportFilters filters) =>
      _ReportsQueries.getVaccinationsReport(filters, db: _db);

  Future<Map<String, dynamic>> getMedicationsReport(ReportFilters filters) =>
      _ReportsQueries.getMedicationsReport(filters, db: _db);

  Future<Map<String, dynamic>> getBreedingReport(ReportFilters filters) =>
      _ReportsQueries.getBreedingReport(filters, db: _db);

  Future<Map<String, dynamic>> getFinancialReport(ReportFilters filters) =>
      _ReportsQueries.getFinancialReport(filters, db: _db);

  Future<Map<String, dynamic>> getNotesReport(ReportFilters filters) =>
      _ReportsQueries.getNotesReport(filters, db: _db);

  Future<void> saveGeneratedReport({
    required String title,
    required String reportType,
    required Map<String, dynamic> parameters,
    String generatedBy = 'Dashboard',
  }) =>
      _ReportsQueries.saveGeneratedReport(
        title: title,
        reportType: reportType,
        parameters: parameters,
        generatedBy: generatedBy,
        db: _db,
      );
}
