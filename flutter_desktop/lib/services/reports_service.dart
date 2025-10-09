// Service for generating comprehensive reports with filters and KPIs
import 'database_service.dart';
import '../models/animal.dart';

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
  // ============ Animais Report ============
  static Future<Map<String, dynamic>> getAnimalsReport(ReportFilters filters) async {
    var animals = await DatabaseService.getAnimals();
    
    // Filter by created_at
    animals = animals.where((a) {
      final createdAt = DateTime.tryParse(a.createdAt);
      if (createdAt == null) return false;
      return createdAt.isAfter(filters.startDate.subtract(const Duration(days: 1))) &&
             createdAt.isBefore(filters.endDate.add(const Duration(days: 1)));
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
      'data': animals.map((a) => {
        'code': a.code,
        'name': a.name,
        'species': a.species,
        'breed': a.breed,
        'gender': a.gender,
        'birth_date': a.birthDate,
        'weight': a.weight,
        'status': a.status,
        'location': a.location,
        'category': a.category ?? '',
        'pregnant': a.pregnant,
        'expected_delivery': a.expectedDelivery ?? '',
      }).toList(),
    };
  }

  // ============ Pesos Report ============
  static Future<Map<String, dynamic>> getWeightsReport(ReportFilters filters) async {
    final db = await DatabaseService.database;
    final animals = await DatabaseService.getAnimals();
    final animalMap = {for (var a in animals) a.id: a};
    
    // Query animal_weights within period
    final weights = await db.query(
      'animal_weights',
      where: 'date(date) >= date(?) AND date(date) <= date(?)',
      whereArgs: [
        filters.startDate.toIso8601String().split('T')[0],
        filters.endDate.toIso8601String().split('T')[0],
      ],
    );
    
    // Group by animal
    final byAnimal = <String, List<Map<String, dynamic>>>{};
    for (var w in weights) {
      final animalId = w['animal_id'] as String;
      byAnimal.putIfAbsent(animalId, () => []);
      byAnimal[animalId]!.add(w);
    }
    
    final animalStats = byAnimal.entries.map((entry) {
      final animalId = entry.key;
      final weighings = entry.value;
      final animal = animalMap[animalId];
      
      final weightValues = weighings.map((w) => (w['weight'] as num).toDouble()).toList();
      weighings.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      
      return {
        'animal_id': animalId,
        'animal_code': animal?.code ?? 'N/A',
        'animal_name': animal?.name ?? 'N/A',
        'count': weightValues.length,
        'min': weightValues.isEmpty ? 0 : weightValues.reduce((a, b) => a < b ? a : b),
        'max': weightValues.isEmpty ? 0 : weightValues.reduce((a, b) => a > b ? a : b),
        'avg': weightValues.isEmpty ? 0 : weightValues.reduce((a, b) => a + b) / weightValues.length,
        'last_weight': weighings.isEmpty ? 0 : weighings[0]['weight'],
        'last_date': weighings.isEmpty ? '' : weighings[0]['date'],
      };
    }).toList();
    
    final allLastWeights = animalStats
        .map((s) => s['last_weight'] as double)
        .where((w) => w > 0)
        .toList();
    
    return {
      'summary': {
        'total_weighings': weights.length,
        'animals_weighed': byAnimal.length,
        'avg_last_weight': allLastWeights.isEmpty ? 0 
            : allLastWeights.reduce((a, b) => a + b) / allLastWeights.length,
      },
      'data': animalStats,
    };
  }

  // ============ Vacinações Report ============
  static Future<Map<String, dynamic>> getVaccinationsReport(ReportFilters filters) async {
    var vaccinations = await DatabaseService.getVaccinations();
    final animals = await DatabaseService.getAnimals();
    final animalMap = {for (var a in animals) a.id: a};
    
    // Filter by effective date (applied_date if exists, else scheduled_date)
    vaccinations = vaccinations.where((v) {
      final effectiveDate = v['applied_date'] ?? v['scheduled_date'];
      if (effectiveDate == null) return false;
      final date = DateTime.tryParse(effectiveDate);
      if (date == null) return false;
      return date.isAfter(filters.startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(filters.endDate.add(const Duration(days: 1)));
    }).toList();
    
    if (filters.status != null && filters.status != 'Todos') {
      vaccinations = vaccinations.where((v) => v['status'] == filters.status).toList();
    }
    if (filters.vaccineType != null && filters.vaccineType != 'Todos') {
      vaccinations = vaccinations.where((v) => v['vaccine_type'] == filters.vaccineType).toList();
    }
    
    final scheduled = vaccinations.where((v) => v['status'] == 'Agendada').length;
    final applied = vaccinations.where((v) => v['status'] == 'Aplicada').length;
    final cancelled = vaccinations.where((v) => v['status'] == 'Cancelada').length;
    
    return {
      'summary': {
        'total': vaccinations.length,
        'scheduled': scheduled,
        'applied': applied,
        'cancelled': cancelled,
      },
      'data': vaccinations.map((v) {
        final animal = animalMap[v['animal_id']];
        return {
          'animal_code': animal?.code ?? 'N/A',
          'animal_name': animal?.name ?? 'N/A',
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

  // ============ Medicações Report ============
  static Future<Map<String, dynamic>> getMedicationsReport(ReportFilters filters) async {
    var medications = await DatabaseService.getMedications();
    final animals = await DatabaseService.getAnimals();
    final animalMap = {for (var a in animals) a.id: a};
    
    // Filter by event date
    medications = medications.where((m) {
      final eventDate = (m['status'] == 'Aplicado' && m['applied_date'] != null)
          ? m['applied_date']
          : m['date'];
      if (eventDate == null) return false;
      final date = DateTime.tryParse(eventDate);
      if (date == null) return false;
      return date.isAfter(filters.startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(filters.endDate.add(const Duration(days: 1)));
    }).toList();
    
    if (filters.medicationStatus != null && filters.medicationStatus != 'Todos') {
      medications = medications.where((m) => m['status'] == filters.medicationStatus).toList();
    }
    
    final scheduled = medications.where((m) => m['status'] == 'Agendado').length;
    final applied = medications.where((m) => m['status'] == 'Aplicado').length;
    final cancelled = medications.where((m) => m['status'] == 'Cancelado').length;
    
    return {
      'summary': {
        'total': medications.length,
        'scheduled': scheduled,
        'applied': applied,
        'cancelled': cancelled,
      },
      'data': medications.map((m) {
        final animal = animalMap[m['animal_id']];
        return {
          'animal_code': animal?.code ?? 'N/A',
          'animal_name': animal?.name ?? 'N/A',
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

  // ============ Reprodução Report ============
  static Future<Map<String, dynamic>> getBreedingReport(ReportFilters filters) async {
    var breeding = await DatabaseService.getBreedingRecords();
    final animals = await DatabaseService.getAnimals();
    final animalMap = {for (var a in animals) a.id: a};
    
    // Filter by breeding_date
    breeding = breeding.where((b) {
      final date = DateTime.tryParse(b['breeding_date'] ?? '');
      if (date == null) return false;
      return date.isAfter(filters.startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(filters.endDate.add(const Duration(days: 1)));
    }).toList();
    
    if (filters.breedingStage != null && filters.breedingStage != 'Todos') {
      breeding = breeding.where((b) => b['stage'] == filters.breedingStage).toList();
    }
    
    final byStage = <String, int>{};
    for (var b in breeding) {
      final stage = b['stage'] ?? 'Não definido';
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

  // ============ Financeiro Report ============
  static Future<Map<String, dynamic>> getFinancialReport(ReportFilters filters) async {
    var financial = await DatabaseService.getFinancialRecords();
    final animals = await DatabaseService.getAnimals();
    final animalMap = {for (var a in animals) a.id: a};
    
    // Filter by date
    financial = financial.where((f) {
      final date = DateTime.tryParse(f['date'] ?? '');
      if (date == null) return false;
      return date.isAfter(filters.startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(filters.endDate.add(const Duration(days: 1)));
    }).toList();
    
    if (filters.financialType != null && filters.financialType != 'Todos') {
      financial = financial.where((f) => f['type'] == filters.financialType).toList();
    }
    if (filters.financialCategory != null && filters.financialCategory != 'Todos') {
      financial = financial.where((f) => f['category'] == filters.financialCategory).toList();
    }
    
    final revenue = financial
        .where((f) => f['type'] == 'receita')
        .fold<double>(0, (sum, f) => sum + ((f['amount'] as num?)?.toDouble() ?? 0));
    final expense = financial
        .where((f) => f['type'] == 'despesa')
        .fold<double>(0, (sum, f) => sum + ((f['amount'] as num?)?.toDouble() ?? 0));
    
    return {
      'summary': {
        'revenue': revenue,
        'expense': expense,
        'balance': revenue - expense,
      },
      'data': financial.map((f) {
        final animal = f['animal_id'] != null ? animalMap[f['animal_id']] : null;
        return {
          'date': f['date'],
          'type': f['type'],
          'category': f['category'],
          'amount': f['amount'],
          'description': f['description'] ?? '',
          'animal_code': animal?.code ?? '',
        };
      }).toList(),
    };
  }

  // ============ Anotações Report ============
  static Future<Map<String, dynamic>> getNotesReport(ReportFilters filters) async {
    var notes = await DatabaseService.getNotes();
    final animals = await DatabaseService.getAnimals();
    final animalMap = {for (var a in animals) a.id: a};
    
    // Filter by date
    notes = notes.where((n) {
      final date = DateTime.tryParse(n['date'] ?? '');
      if (date == null) return false;
      return date.isAfter(filters.startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(filters.endDate.add(const Duration(days: 1)));
    }).toList();
    
    if (filters.notesIsRead != null) {
      notes = notes.where((n) => (n['is_read'] == 1) == filters.notesIsRead!).toList();
    }
    if (filters.notesPriority != null && filters.notesPriority != 'Todos') {
      notes = notes.where((n) => n['priority'] == filters.notesPriority).toList();
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
        final animal = n['animal_id'] != null ? animalMap[n['animal_id']] : null;
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
}
