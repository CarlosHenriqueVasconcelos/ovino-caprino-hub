// lib/services/reports_service.dart
// Service for generating comprehensive reports with filters and KPIs
import 'dart:convert';
import 'dart:developer' as developer;

import '../data/local_db.dart';
import '../models/animal.dart';

void _log(String message) {
  developer.log(message, name: 'ReportsService');
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});
}

class ReportFilters {
  final DateTime startDate;
  final DateTime endDate;
  final String? species;
  final String? gender;
  final String? status;
  final String? category;
  final String? vaccineType;
  final String? medicationStatus;
  final String? breedingStage;
  final String? financialType;
  final String? financialCategory;
  final String? notesPriority;
  final bool? notesIsRead;

  ReportFilters({
    required this.startDate,
    required this.endDate,
    this.species,
    this.gender,
    this.status,
    this.category,
    this.vaccineType,
    this.medicationStatus,
    this.breedingStage,
    this.financialType,
    this.financialCategory,
    this.notesPriority,
    this.notesIsRead,
  });
}

class ReportSummary {
  final Map<String, dynamic> data;
  ReportSummary(this.data);
}

class ReportsService {
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

  static String _asLower(dynamic v) =>
      (v == null ? '' : v.toString()).trim().toLowerCase();

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

  static Future<List<Animal>> _loadAnimals() async {
    final appDb = await AppDatabase.open();
    final rows = await appDb.db.query('animals');
    return rows.map((m) => Animal.fromMap(m)).toList();
  }

  // ==================== ANIMAIS ====================
  static Future<Map<String, dynamic>> getAnimalsReport(
      ReportFilters filters) async {
    var animals = await _loadAnimals();

    animals = animals.where((a) {
      final createdAt = _toDate(a.createdAt);
      return _between(createdAt, filters.startDate, filters.endDate);
    }).toList();

    if (filters.species != null && filters.species != 'Todos') {
      animals = animals.where((a) => a.species == filters.species).toList();
    }
    if (filters.gender != null && filters.gender != 'Todos') {
      animals = animals.where((a) => a.gender == filters.gender).toList();
    }
    if (filters.status != null && filters.status != 'Todos') {
      animals = animals.where((a) => a.status == filters.status).toList();
    }
    if (filters.category != null && filters.category != 'Todos') {
      animals = animals.where((a) => a.category == filters.category).toList();
    }

    final ovinos = animals.where((a) => a.species == 'Ovino').length;
    final caprinos = animals.where((a) => a.species == 'Caprino').length;
    final machos = animals.where((a) => a.gender == 'Macho').length;
    final femeas = animals.where((a) => a.gender == 'Fêmea').length;

    return {
      'summary': {
        'total': animals.length,
        'ovinos': ovinos,
        'caprinos': caprinos,
        'machos': machos,
        'femeas': femeas,
      },
      'data': animals
          .map((a) => {
                'code': a.code,
                'name': a.name,
                'species': a.species,
                'breed': a.breed,
                'gender': a.gender,
                'birth_date': _yyyyMmDd(a.birthDate),
                'weight': a.weight,
                'status': a.status,
                'location': a.location,
                'category': a.category,
                'pregnant': a.pregnant,
                'expected_delivery': a.expectedDelivery ?? '',
              })
          .toList(),
    };
  }

  // ---------- Pesos: leitor robusto ----------
  static Future<List<Map<String, dynamic>>> _readWeightRows(
      DateTime start, DateTime end) async {
    final appDb = await AppDatabase.open();
    final db = appDb.db;
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
      ReportFilters filters) async {
    final animals = await _loadAnimals();
    final animalMap = {for (var a in animals) a.id: a};

    // Busca histórico de pesagens
    final weights = await _readWeightRows(filters.startDate, filters.endDate);

    final byAnimal = <String, List<Map<String, dynamic>>>{};

    // Adiciona pesagens do histórico
    for (var w in weights) {
      final animalId = (w['animal_id'] ?? '').toString();
      if (animalId.isEmpty) continue;
      byAnimal.putIfAbsent(animalId, () => []);
      byAnimal[animalId]!.add(w);
    }

    _log('📊 Histórico de pesagens encontrado: ${weights.length}');
    _log('📊 Animais com histórico: ${byAnimal.length}');

    // Se não houver histórico, usa os pesos atuais da tabela animals
    if (weights.isEmpty) {
      _log(
        '⚠️ Nenhum histórico de pesagens encontrado, usando pesos atuais dos animais',
      );

      for (var animal in animals) {
        final createdAt = _toDate(animal.createdAt);
        if (!_between(createdAt, filters.startDate, filters.endDate)) {
          continue;
        }

        if (animal.weight > 0) {
          byAnimal.putIfAbsent(animal.id, () => []);
          byAnimal[animal.id]!.add({
            'animal_id': animal.id,
            'date': _yyyyMmDd(animal.createdAt),
            'weight': animal.weight,
          });
        }
      }
    _log('📊 Animais adicionados com peso atual: ${byAnimal.length}');
    }

    final animalStats = byAnimal.entries.map((entry) {
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

    final allLastWeights = animalStats
        .map((s) => (s['last_weight'] as num).toDouble())
        .where((w) => w > 0)
        .toList();

    _log('📊 Total de animais no relatório final: ${animalStats.length}');

    return {
      'summary': {
        'total_weighings': weights.isEmpty ? byAnimal.length : weights.length,
        'animals_weighed': byAnimal.length,
        'avg_last_weight': allLastWeights.isEmpty
            ? 0
            : allLastWeights.reduce((a, b) => a + b) / allLastWeights.length,
      },
      'data': animalStats,
    };
  }

  // ==================== VACINAÇÕES ====================
  static Future<Map<String, dynamic>> getVaccinationsReport(
      ReportFilters filters) async {
    final appDb = await AppDatabase.open();
    final db = appDb.db;

    var vaccinations = await db.rawQuery('''
      SELECT 
        v.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color
      FROM vaccinations v
      LEFT JOIN animals a ON a.id = v.animal_id
    ''');

    vaccinations = vaccinations.where((v) {
      final effectiveDate = v['applied_date'] ?? v['scheduled_date'];
      final d = _toDate(effectiveDate);
      return _between(d, filters.startDate, filters.endDate);
    }).toList();

    if (filters.status != null && filters.status != 'Todos') {
      vaccinations =
          vaccinations.where((v) => v['status'] == filters.status).toList();
    }
    if (filters.vaccineType != null && filters.vaccineType != 'Todos') {
      vaccinations = vaccinations
          .where((v) => v['vaccine_type'] == filters.vaccineType)
          .toList();
    }

    final scheduled =
        vaccinations.where((v) => v['status'] == 'Agendada').length;
    final applied = vaccinations.where((v) => v['status'] == 'Aplicada').length;
    final cancelled =
        vaccinations.where((v) => v['status'] == 'Cancelada').length;

    return {
      'summary': {
        'total': vaccinations.length,
        'scheduled': scheduled,
        'applied': applied,
        'cancelled': cancelled,
      },
      'data': vaccinations.map((v) {
        return {
          'animal_code': v['animal_code'] ?? 'N/A',
          'animal_name': v['animal_name'] ?? 'N/A',
          'animal_color': v['animal_color'] ?? '',
          'vaccine_name': v['vaccine_name'],
          'vaccine_type': v['vaccine_type'],
          'scheduled_date': v['scheduled_date'],
          'applied_date': v['applied_date'] ?? '',
          'status': v['status'],
          'veterinarian': v['veterinarian'] ?? '',
          'notes': v['notes'] ?? '',
        };
      }).toList(),
    };
  }

  // ==================== MEDICAÇÕES ====================
  static Future<Map<String, dynamic>> getMedicationsReport(
      ReportFilters filters) async {
    final appDb = await AppDatabase.open();
    final db = appDb.db;

    var medications = await db.rawQuery('''
      SELECT 
        m.*,
        a.name AS animal_name,
        a.code AS animal_code,
        a.name_color AS animal_color
      FROM medications m
      LEFT JOIN animals a ON a.id = m.animal_id
    ''');

    medications = medications.where((m) {
      final eventDate = (m['status'] == 'Aplicado' && m['applied_date'] != null)
          ? m['applied_date']
          : m['date'];
      final d = _toDate(eventDate);
      return _between(d, filters.startDate, filters.endDate);
    }).toList();

    if (filters.medicationStatus != null &&
        filters.medicationStatus != 'Todos') {
      medications = medications
          .where((m) => m['status'] == filters.medicationStatus)
          .toList();
    }

    final scheduled =
        medications.where((m) => m['status'] == 'Agendado').length;
    final applied = medications.where((m) => m['status'] == 'Aplicado').length;
    final cancelled =
        medications.where((m) => m['status'] == 'Cancelado').length;

    return {
      'summary': {
        'total': medications.length,
        'scheduled': scheduled,
        'applied': applied,
        'cancelled': cancelled,
      },
      'data': medications.map((m) {
        return {
          'animal_code': m['animal_code'] ?? 'N/A',
          'animal_name': m['animal_name'] ?? 'N/A',
          'animal_color': m['animal_color'] ?? '',
          'medication_name': m['medication_name'],
          'date': m['date'],
          'next_date': m['next_date'] ?? '',
          'applied_date': m['applied_date'] ?? '',
          'status': m['status'],
          'dosage': m['dosage'] ?? '',
          'veterinarian': m['veterinarian'] ?? '',
          'notes': m['notes'] ?? '',
        };
      }).toList(),
    };
  }

  // ==================== REPRODUÇÃO ====================
  static Future<Map<String, dynamic>> getBreedingReport(
      ReportFilters filters) async {
    final appDb = await AppDatabase.open();
    final db = appDb.db;

    var breeding = await db.query('breeding_records');
    final animals = await _loadAnimals();
    final animalMap = {for (var a in animals) a.id: a};

    _log(
      '📊 Total de registros de reprodução encontrados: ${breeding.length}',
    );

    breeding = breeding.where((b) {
      final d = _toDate(b['breeding_date']);
      final inRange = _between(d, filters.startDate, filters.endDate);
      if (!inRange) {
        _log('⏭️ Registro fora do período: ${b['breeding_date']}');
      }
      return inRange;
    }).toList();

    _log('📊 Registros após filtro de data: ${breeding.length}');

    if (filters.breedingStage != null && filters.breedingStage != 'Todos') {
      final expected = _slug(filters.breedingStage!);
      breeding = breeding.where((b) {
        final stage = _slug((b['stage'] ?? '').toString());
        return stage == expected;
      }).toList();
      _log('📊 Registros após filtro de estágio: ${breeding.length}');
    }

    final byStage = <String, int>{};
    for (var b in breeding) {
      final stage = (b['stage'] ?? 'nao_definido').toString();
      byStage[stage] = (byStage[stage] ?? 0) + 1;
    }

    return {
      'summary': {
        'total': breeding.length,
        ...byStage,
      },
      'data': breeding.map((b) {
        final female = animalMap[b['female_animal_id']];
        final male = animalMap[b['male_animal_id']];
        return {
          'female_code': female?.code ?? 'N/A',
          'female_name': female?.name ?? 'N/A',
          'male_code': male?.code ?? 'N/A',
          'male_name': male?.name ?? 'N/A',
          'breeding_date': b['breeding_date'] ?? '',
          'expected_birth': b['expected_birth'] ?? '',
          'stage': b['stage'] ?? '',
          'status': b['status'] ?? '',
          'mating_start_date': b['mating_start_date'] ?? '',
          'mating_end_date': b['mating_end_date'] ?? '',
          'separation_date': b['separation_date'] ?? '',
          'ultrasound_date': b['ultrasound_date'] ?? '',
          'ultrasound_result': b['ultrasound_result'] ?? '',
          'birth_date': b['birth_date'] ?? '',
        };
      }).toList(),
    };
  }

  // ==================== FINANCEIRO ====================
  static Future<List<Map<String, dynamic>>> _readFinancialRows() async {
    final appDb = await AppDatabase.open();
    final db = appDb.db;
    List<Map<String, dynamic>> rows = [];

    Future<void> tryTable(String name) async {
      if (rows.isNotEmpty) return;
      try {
        rows = await db.query(name);
      } catch (_) {}
    }

    // Tenta as tabelas mais prováveis
    await tryTable('financial_accounts'); // app atual
    await tryTable('finance_accounts');
    await tryTable('financial'); // planos antigos
    await tryTable('accounts');
    await tryTable('financial_records'); // legado

    return rows;
  }

  /// Compatível com chaves snake/camel e datas dd/MM/yyyy ou ISO.
  /// Período usa data efetiva: paid_date ?? date ?? due_date ?? created_at.
  static Future<Map<String, dynamic>> getFinancialReport(
      ReportFilters filters) async {
    final animals = await _loadAnimals();
    final animalMap = {for (var a in animals) a.id: a};

    var raw = await _readFinancialRows();

    // Normaliza
    List<Map<String, dynamic>> norm = [];
    for (final f in raw) {
      final map = Map<String, dynamic>.from(f);

      // tipo
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

      // datas
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
      // valor
      final amount = _toDouble(map['amount'] ?? map['valor']);

      // animal
      final animalId = map['animal_id'] ?? map['animalId'];
      Animal? animal;
      if (animalId != null && animalMap.containsKey(animalId)) {
        animal = animalMap[animalId];
      }

      norm.add({
        'effective_date': eff,
        'date': rawDate,
        'type': type,
        'status': status,
        'category': category,
        'amount': amount,
        'description':
            (map['description'] ?? map['descricao'] ?? '').toString(),
        'animal_code': animal?.code ?? '',
      });
    }

    // Filtra por período
    norm = norm
        .where((m) => _between(m['effective_date'] as DateTime?,
            filters.startDate, filters.endDate))
        .toList();

    // Filtros tipo/categoria
    if (filters.financialType != null && filters.financialType != 'Todos') {
      final ft = _asLower(filters.financialType);
      norm = norm.where((m) => m['type'] == ft).toList();
    }
    if (filters.financialCategory != null &&
        filters.financialCategory != 'Todos') {
      norm = norm
          .where((m) => (m['category'] ?? '') == filters.financialCategory)
          .toList();
    }

    // Somatórios
    final revenue = norm
        .where((m) => m['type'] == 'receita')
        .fold<double>(0.0, (sum, m) => sum + (m['amount'] as double));
    final expense = norm
        .where((m) => m['type'] == 'despesa')
        .fold<double>(0.0, (sum, m) => sum + (m['amount'] as double));

    // Ordena desc por data efetiva
    norm.sort((a, b) {
      final da = a['effective_date'] as DateTime?;
      final db = b['effective_date'] as DateTime?;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    // Dados para a tabela
    final data = norm
        .map((m) => {
              'date': m['date'] ?? '',
              'type': m['type'],
              'category': m['category'],
              'amount': m['amount'],
              'description': m['description'],
              'status':
                  (m['status'] as String?)?.isEmpty ?? true ? '' : m['status'],
              'animal_code': m['animal_code'],
            })
        .toList();

    return {
      'summary': {
        'revenue': revenue,
        'expense': expense,
        'balance': revenue - expense,
      },
      'data': data,
    };
  }

  // ==================== ANOTAÇÕES ====================
  static Future<Map<String, dynamic>> getNotesReport(
      ReportFilters filters) async {
    final appDb = await AppDatabase.open();
    final db = appDb.db;

    var notes = await db.query('notes');
    final animals = await _loadAnimals();
    final animalMap = {for (var a in animals) a.id: a};

    notes = notes.where((n) {
      final d = _toDate(n['date']);
      return _between(d, filters.startDate, filters.endDate);
    }).toList();

    if (filters.notesIsRead != null) {
      notes = notes
          .where((n) => (n['is_read'] == 1) == filters.notesIsRead!)
          .toList();
    }
    if (filters.notesPriority != null && filters.notesPriority != 'Todos') {
      notes =
          notes.where((n) => n['priority'] == filters.notesPriority).toList();
    }

    final read = notes.where((n) => n['is_read'] == 1).length;
    final unread = notes.where((n) => n['is_read'] != 1).length;
    final high = notes.where((n) => n['priority'] == 'Alta').length;
    final medium = notes.where((n) => n['priority'] == 'Média').length;
    final low = notes.where((n) => n['priority'] == 'Baixa').length;

    return {
      'summary': {
        'total': notes.length,
        'read': read,
        'unread': unread,
        'high': high,
        'medium': medium,
        'low': low,
      },
      'data': notes.map((n) {
        final animal =
            n['animal_id'] != null ? animalMap[n['animal_id']] : null;
        return {
          'date': n['date'],
          'title': n['title'],
          'category': n['category'],
          'priority': n['priority'],
          'is_read': n['is_read'] == 1,
          'animal_code': animal?.code ?? '',
        };
      }).toList(),
    };
  }

  // ==================== SALVAR HISTÓRICO DE RELATÓRIOS ====================
  static Future<void> saveGeneratedReport({
    required String title,
    required String reportType,
    required Map<String, dynamic> parameters,
    String generatedBy = 'Dashboard',
  }) async {
    final appDb = await AppDatabase.open();
    final db = appDb.db;

    await db.insert('reports', {
      'id': 'rep_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'report_type': reportType,
      'parameters': jsonEncode(parameters),
      'generated_at': DateTime.now().toIso8601String(),
      'generated_by': generatedBy,
    });
  }
}
