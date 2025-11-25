// lib/services/animal_service.dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../data/animal_lifecycle_repository.dart';
import '../data/animal_repository.dart';
import '../data/medication_repository.dart';
import '../data/vaccination_repository.dart';
import '../models/animal.dart'; // Animal e AnimalStats
import '../models/alert_item.dart'; // AlertItem
import '../utils/animal_display_utils.dart';
import 'animal/animal_stats_calculator.dart';
import 'deceased_hooks.dart'; // handleAnimalDeathIfApplicable
import 'weight_alert_service.dart'; // WeightAlertService

enum WeightCategoryFilter { all, juveniles, adults, reproducers }

class AnimalService extends ChangeNotifier {
  // ----------------- Estado -----------------
  final List<Animal> _animals = [];
  int _animalsVersion = 0;
  AnimalStats? _stats;
  bool _loading = false;
  Timer? _alertsDebounceTimer;
  Timer? _statsDebounceTimer;

  // Painel de alertas (vacinas + medicações + pesagens)
  final List<AlertItem> _alerts = [];

  // DB e serviço de alertas de peso
  final AnimalRepository _animalRepository;
  final AnimalLifecycleRepository _animalLifecycleRepository;
  final VaccinationRepository _vaccinationRepository;
  final MedicationRepository _medicationRepository;
  final WeightAlertService _weightAlertService;

  // ----------------- Getters públicos -----------------
  UnmodifiableListView<Animal> get animals => UnmodifiableListView(_animals);
  int get animalsVersion => _animalsVersion;
  AnimalStats? get stats => _stats;
  bool get isLoading => _loading;

  /// Alertas agregados (Vacinas + Medicações + Pesagens)
  UnmodifiableListView<AlertItem> get alerts => UnmodifiableListView(_alerts);

  // ----------------- Construtor -----------------
  /// Agenda o carregamento inicial dos dados e recebe todas as dependências.
  AnimalService(
    this._animalRepository,
    this._animalLifecycleRepository,
    this._vaccinationRepository,
    this._medicationRepository,
    this._weightAlertService,
  ) {
    scheduleMicrotask(() => loadData());
  }

  // ----------------- Ciclo de vida / carga -----------------
  Future<void> loadData() async {
    _loading = true;
    notifyListeners();
    try {
      // Carrega animais
      final list = await _animalRepository.all();
      _animals
        ..clear()
        ..addAll(list);
      _markAnimalsChanged();

      // Estatísticas
      await _scheduleStatsRefresh(immediate: true);

      // Atualiza o painel de alertas (Vacinas + Medicações + Pesagens)
      await refreshAlerts(immediate: true);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ----------------- Métodos auxiliares -----------------
  void _markAnimalsChanged() {
    _animalsVersion++;
  }

  Future<List<Animal>> getAllAnimals() async {
    if (_animals.isEmpty && !_loading) {
      await loadData();
    }
    return List<Animal>.unmodifiable(_animals);
  }

  // ----------------- CRUD: Animal -----------------
  Future<void> addAnimal(Animal a) async {
    // Garante ID e timestamps mínimos
    final nowIso = DateTime.now().toIso8601String();
    final map = a.toMap();

    // ID local simples se não veio (evita conflito com Supabase)
    if ((map['id'] == null) || (map['id'] as String).isEmpty) {
      map['id'] = _newId();
    }
    map['created_at'] ??= nowIso;
    map['updated_at'] = nowIso;

    // Preencher year com o ano da data de nascimento se não foi especificado
    if (map['year'] == null) {
      map['year'] = a.birthDate.year;
    }

    final saved = Animal.fromMap(map);
    await _validateUniqueness(saved, isUpdate: false);
    await _animalRepository.upsert(saved);
    _animals.add(saved);
    _markAnimalsChanged();

    // Cria alertas de pesagem se for borrego
    if (_isLambCategory(saved.category)) {
      await _weightAlertService.createLambWeightAlerts(saved);
    }

    await _scheduleStatsRefresh();
    await refreshAlerts();
    notifyListeners();
  }

  // Helper para verificar se é categoria de borrego
  bool _isLambCategory(String? category) {
    if (category == null) return false;
    final catLower = category.toLowerCase();
    return catLower.contains('borrego') || catLower.contains('borrega');
  }

  // Normaliza números removendo zeros à esquerda
  String _normalizeNumber(String name) {
    // Tenta converter para número e volta para string, removendo zeros à esquerda
    final numMatch = RegExp(r'^\d+$').hasMatch(name);
    if (numMatch) {
      final num = int.tryParse(name);
      if (num != null) return num.toString();
    }
    return name;
  }

  // Valida a unicidade de name + name_color segundo as novas regras
  Future<void> _validateUniqueness(
    Animal animal, {
    required bool isUpdate,
  }) async {
    final nameLc = animal.name.toLowerCase();
    final normalizedName = _normalizeNumber(nameLc);
    final colorLc = animal.nameColor.toLowerCase();
    final currentId = animal.id;
    final category = animal.category;
    final lote = animal.lote ?? '';

    final candidateNames = <String>{
      nameLc,
      normalizedName,
    }.toList();
    final existing = await _animalRepository.findIdentityConflicts(
      candidateNamesLower: candidateNames,
      colorLower: colorLc,
      excludeId: isUpdate ? currentId : null,
    );

    final isLamb = _isLambCategory(category);

    if (isLamb) {
      final sameNameColorLote = existing.where((e) {
        final isLambCat = _isLambCategory(e['category']?.toString());
        final sameLote = (e['lote']?.toString() ?? '') == lote;
        return isLambCat && sameLote;
      }).length;

      if (sameNameColorLote >= 2) {
        throw Exception(
          'Já existem 2 borregos com este Nome + Cor no Lote "$lote".\n\n'
          'Você pode:\n'
          '• Usar um lote diferente para registrar mais filhotes\n'
          '• Alterar o nome ou cor',
        );
      }

      final hasAdult =
          existing.any((e) => !_isLambCategory(e['category']?.toString()));
      if (!hasAdult) {
        debugPrint(
          '⚠️ Aviso: Registrando borrego sem mãe correspondente '
          '(Nome: ${animal.name}, Cor: ${animal.nameColor})',
        );
      }
    } else {
      final hasAdult =
          existing.any((e) => !_isLambCategory(e['category']?.toString()));
      if (hasAdult) {
        throw Exception('Já existe um animal adulto com este Nome + Cor.');
      }
    }
  }

  Future<void> updateAnimal(Animal a) async {
    final map = a.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    final updated = Animal.fromMap(map);

    await _validateUniqueness(updated, isUpdate: true);

    // Verifica se o status foi alterado para "Óbito"
    final newStatus = map['status'] as String?;
    if (newStatus == 'Óbito') {
      // Move o animal para deceased_animals e remove da tabela principal.
      await handleAnimalDeathIfApplicable(
        _animalLifecycleRepository,
        map['id'] as String,
        newStatus!,
      );
      // Remove da lista local
      _animals.removeWhere((x) => x.id == map['id']);
      _markAnimalsChanged();
      await _scheduleStatsRefresh();
      await refreshAlerts();
      notifyListeners();
      return;
    }

    await _animalRepository.upsert(updated);
    final i = _animals.indexWhere((x) => x.id == updated.id);
    if (i >= 0) {
      _animals[i] = updated;
      _markAnimalsChanged();
    }

    await _scheduleStatsRefresh();
    await refreshAlerts();
    notifyListeners();
  }

  Future<void> deleteAnimal(String id) async {
    await _animalRepository.delete(id);

    _animals.removeWhere((x) => x.id == id);
    _markAnimalsChanged();

    await _scheduleStatsRefresh();
    await refreshAlerts();
    notifyListeners();
  }

  Future<void> removeFromCache(
    String id, {
    bool refreshStats = true,
    bool refreshAlertsData = true,
  }) async {
    final index = _animals.indexWhere((animal) => animal.id == id);
    if (index == -1) return;
    _animals.removeAt(index);
    _markAnimalsChanged();

    if (refreshStats) {
      await _scheduleStatsRefresh();
    }

    if (refreshAlertsData) {
      await refreshAlerts();
    } else {
      notifyListeners();
    }
  }

  List<Animal> weightTrackingQuery({
    WeightCategoryFilter category = WeightCategoryFilter.all,
    String? colorFilter,
    String searchQuery = '',
  }) {
    final reference = DateTime.now();
    final query = searchQuery.trim().toLowerCase();

    Iterable<Animal> filtered = _animals;

    filtered = filtered.where((animal) {
      final ageInMonths = _ageInMonths(animal.birthDate, reference);
      final categoryLabel = (animal.category).toLowerCase();
      switch (category) {
        case WeightCategoryFilter.juveniles:
          return ageInMonths < 12;
        case WeightCategoryFilter.adults:
          return ageInMonths >= 12 && !categoryLabel.contains('reprodutor');
        case WeightCategoryFilter.reproducers:
          return categoryLabel.contains('reprodutor');
        case WeightCategoryFilter.all:
        default:
          return true;
      }
    });

    if (colorFilter != null && colorFilter.isNotEmpty) {
      filtered = filtered.where((animal) => animal.nameColor == colorFilter);
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((animal) {
        final name = animal.name.toLowerCase();
        final code = animal.code.toLowerCase();
        return name.contains(query) || code.contains(query);
      });
    }

    final result = filtered.toList();
    AnimalDisplayUtils.sortAnimalsList(result);
    return result;
  }

  // ----------------- Helpers de gestação (para Reprodução) -----------------

  /// Marca a fêmea como gestante, com data prevista de parto opcional.
  ///
  /// Essa função é pensada para ser usada pelos widgets de Reprodução,
  /// em vez de fazer `db.update('animals', ...)` direto na UI.
  Future<void> markAsPregnant(
    String animalId,
    DateTime? expectedBirth,
  ) async {
    try {
      // Garante que temos o animal em memória
      if (_animals.isEmpty && !_loading) {
        await loadData();
      }

      Map<String, dynamic> map;

      final idx = _animals.indexWhere((a) => a.id == animalId);
      if (idx >= 0) {
        map = Map<String, dynamic>.from(_animals[idx].toMap());
      } else {
        // fallback: busca direto no DB
        final fetched = await _animalRepository.getAnimalById(animalId);
        if (fetched == null) return;
        map = Map<String, dynamic>.from(fetched.toMap());
      }

      map['pregnant'] = 1;
      map['expected_delivery'] = expectedBirth != null
          ? expectedBirth.toIso8601String().split('T')[0]
          : null;
      map['status'] = 'Gestante';

      final updated = Animal.fromMap(map);
      await updateAnimal(updated);
    } catch (e) {
      debugPrint('Erro em markAsPregnant: $e');
      rethrow;
    }
  }

  /// Remove a marcação de gestante da fêmea.
  ///
  /// Usado quando a gestação falha ou após o parto, para voltar o status
  /// padrão (Saudável) quando fizer sentido.
  Future<void> markAsNotPregnant(String animalId) async {
    try {
      // Garante que temos o animal em memória
      if (_animals.isEmpty && !_loading) {
        await loadData();
      }

      Map<String, dynamic> map;

      final idx = _animals.indexWhere((a) => a.id == animalId);
      if (idx >= 0) {
        map = Map<String, dynamic>.from(_animals[idx].toMap());
      } else {
        // fallback: busca direto no DB
        final fetched = await _animalRepository.getAnimalById(animalId);
        if (fetched == null) return;
        map = Map<String, dynamic>.from(fetched.toMap());
      }

      map['pregnant'] = 0;
      map['expected_delivery'] = null;

      final currentStatus = (map['status'] ?? '').toString();
      if (currentStatus == 'Gestante') {
        map['status'] = 'Saudável';
      }

      final updated = Animal.fromMap(map);
      await updateAnimal(updated);
    } catch (e) {
      debugPrint('Erro em markAsNotPregnant: $e');
      rethrow;
    }
  }

  // ----------------- Alertas (Vacinas + Medicações + Pesagens) -----------------
  /// Recalcula o painel de alertas olhando até [horizonDays] dias à frente.
  /// Inclui itens vencidos (overdue) e os que estão dentro do horizonte.
  Future<void> refreshAlerts({
    int horizonDays = 14,
    bool immediate = false,
  }) async {
    if (immediate) {
      _alertsDebounceTimer?.cancel();
      await _performAlertsRefresh(horizonDays: horizonDays);
      return;
    }

    _alertsDebounceTimer?.cancel();
    _alertsDebounceTimer = Timer(
      const Duration(milliseconds: 400),
      () => refreshAlerts(horizonDays: horizonDays, immediate: true),
    );
  }

  Future<void> _performAlertsRefresh({int horizonDays = 14}) async {
    try {
      final now = DateTime.now();
      final horizon = now.add(Duration(days: horizonDays));

      final List<AlertItem> next = [];
      final animalsById = {for (final a in _animals) a.id: a};

      try {
        final vacs =
            await _vaccinationRepository.getPendingAlertsWithin(horizon);
        for (final row in vacs) {
          final animalId = (row['animal_id'] ?? '').toString();
          final animal = animalsById[animalId];
          if (animal == null) continue;

          final due = _parseDate(row['scheduled_date']);
          if (due == null) continue;

          next.add(
            AlertItem(
              id: row['id'].toString(),
              animalId: animalId,
              animalName: animal.name,
              animalCode: animal.code,
              type: AlertType.vaccination,
              title: 'Vacina: ${(row['vaccine_name'] ?? '').toString()}',
              dueDate: due,
            ),
          );
        }
      } catch (e) {
        debugPrint('Erro carregando vacinações: $e');
      }

      try {
        final meds =
            await _medicationRepository.getPendingAlertsWithin(horizon);
        for (final row in meds) {
          final animalId = (row['animal_id'] ?? '').toString();
          final animal = animalsById[animalId];
          if (animal == null) continue;

          final due =
              _parseDate(row['due_date'] ?? row['next_date'] ?? row['date']);
          if (due == null) continue;

          next.add(
            AlertItem(
              id: row['id'].toString(),
              animalId: animalId,
              animalName: animal.name,
              animalCode: animal.code,
              type: AlertType.medication,
              title: 'Medicação: ${(row['medication_name'] ?? '').toString()}',
              dueDate: due,
            ),
          );
        }
      } catch (e) {
        debugPrint('Erro carregando medicações: $e');
      }

      try {
        final weighings =
            await _weightAlertService.getPendingWeightAlerts(horizon);
        for (final row in weighings) {
          final due = _parseDate(row['due_date']);
          if (due == null || due.isAfter(horizon)) continue;

          final animalId = (row['animal_id'] ?? '').toString();
          final animal = animalsById[animalId];
          if (animal == null) continue;

          final alertType = (row['alert_type'] ?? '').toString();
          String title = 'Pesagem';
          switch (alertType) {
            case '30d':
              title = 'Pesagem 30 dias';
              break;
            case '60d':
              title = 'Pesagem 60 dias';
              break;
            case '90d':
              title = 'Pesagem 90 dias';
              break;
            case 'monthly':
              title = 'Pesagem mensal';
              break;
          }

          next.add(
            AlertItem(
              id: row['id'].toString(),
              animalId: animalId,
              animalName: animal.name,
              animalCode: animal.code,
              type: AlertType.weighing,
              title: title,
              dueDate: due,
            ),
          );
        }
      } catch (e) {
        debugPrint('Erro carregando alertas de pesagem: $e');
      }

      next.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      _alerts
        ..clear()
        ..addAll(next);
    } catch (e) {
      debugPrint('refreshAlerts error: $e');
    } finally {
      notifyListeners();
    }
  }

  // ----------------- Estatísticas -----------------
  Future<void> _scheduleStatsRefresh({bool immediate = false}) async {
    if (immediate) {
      _statsDebounceTimer?.cancel();
      await _refreshStatsSafe();
      return;
    }

    _statsDebounceTimer?.cancel();
    _statsDebounceTimer = Timer(
      const Duration(milliseconds: 400),
      () {
        _scheduleStatsRefresh(immediate: true);
      },
    );
  }

  Future<void> _refreshStatsSafe() async {
    try {
      _stats = await AnimalStatsCalculator(_animalRepository).calculate();
    } catch (e) {
      debugPrint('Erro ao atualizar stats: $e');
    }
  }

  // ----------------- Utilidades -----------------
  String _newId() {
    final t = DateTime.now().microsecondsSinceEpoch;
    return 'loc_$t';
  }

  int _ageInMonths(DateTime birthDate, DateTime reference) {
    return (reference.year - birthDate.year) * 12 +
        (reference.month - birthDate.month);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  void dispose() {
    _alertsDebounceTimer?.cancel();
    _statsDebounceTimer?.cancel();
    super.dispose();
  }
}
