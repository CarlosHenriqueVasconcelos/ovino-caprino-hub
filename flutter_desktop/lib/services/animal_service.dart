// lib/services/animal_service.dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../data/local_db.dart'; // AppDatabase
import '../models/animal.dart'; // Animal e AnimalStats
import '../models/alert_item.dart'; // AlertItem
import '../utils/animal_display_utils.dart';
import 'deceased_hooks.dart'; // handleAnimalDeathIfApplicable
import 'weight_alert_service.dart'; // WeightAlertService

enum WeightCategoryFilter { all, juveniles, adults, reproducers }

class AnimalService extends ChangeNotifier {
  // ----------------- Estado -----------------
  final List<Animal> _animals = [];
  AnimalStats? _stats;
  bool _loading = false;

  // Painel de alertas (vacinas + medicações + pesagens)
  final List<AlertItem> _alerts = [];

  // DB e serviço de alertas de peso
  final AppDatabase _appDb;
  final WeightAlertService _weightAlertService;

  // ----------------- Getters públicos -----------------
  UnmodifiableListView<Animal> get animals => UnmodifiableListView(_animals);
  AnimalStats? get stats => _stats;
  bool get isLoading => _loading;

  /// Alertas agregados (Vacinas + Medicações + Pesagens)
  UnmodifiableListView<AlertItem> get alerts => UnmodifiableListView(_alerts);

  // ----------------- Construtor -----------------
  /// Recebe o AppDatabase já aberto (injeção de dependência)
  /// e inicializa o WeightAlertService com o mesmo DB.
  ///
  /// Também agenda o carregamento inicial dos dados.
  AnimalService(this._appDb, this._weightAlertService) {
    scheduleMicrotask(() => loadData());
  }

  // ----------------- Ciclo de vida / carga -----------------
  Future<void> loadData() async {
    _loading = true;
    notifyListeners();
    try {
      // Carrega animais
      final rows = await _appDb.db.query(
        'animals',
        orderBy: 'name COLLATE NOCASE',
      );
      final list = rows.map((m) => Animal.fromMap(m)).toList();
      _animals
        ..clear()
        ..addAll(list);

      // Estatísticas
      await _refreshStatsSafe();

      // Atualiza o painel de alertas (Vacinas + Medicações + Pesagens)
      await refreshAlerts();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ----------------- Métodos auxiliares -----------------
  Future<List<Animal>> getAllAnimals() async {
    final rows = await _appDb.db.query(
      'animals',
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map((m) => Animal.fromMap(m)).toList();
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

    // Nova regra de validação de unicidade
    await _validateUniqueness(map, isUpdate: false);

    await _appDb.db.insert('animals', map);

    final saved = Animal.fromMap(map);
    _animals.add(saved);

    // Cria alertas de pesagem se for borrego
    if (_isLambCategory(saved.category)) {
      await _weightAlertService.createLambWeightAlerts(saved);
    }

    await _refreshStatsSafe();
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
    Map<String, dynamic> map, {
    required bool isUpdate,
  }) async {
    final nameLc = (map['name'] ?? '').toString().toLowerCase();
    final normalizedName = _normalizeNumber(nameLc);
    final colorLc = (map['name_color'] ?? '').toString().toLowerCase();
    final currentId = map['id']?.toString() ?? '';
    final category = map['category']?.toString() ?? '';
    final lote = map['lote']?.toString() ?? '';

    // Busca todos os animais (excluindo o próprio se for update)
    final List<Map<String, dynamic>> allAnimals;
    if (isUpdate) {
      allAnimals = await _appDb.db.query(
        'animals',
        columns: ['id', 'name', 'name_color', 'category', 'lote'],
        where: 'id <> ?',
        whereArgs: [currentId],
      );
    } else {
      allAnimals = await _appDb.db.query(
        'animals',
        columns: ['id', 'name', 'name_color', 'category', 'lote'],
      );
    }

    // Filtrar animais que têm mesmo nome+cor (normalizados)
    final existing = allAnimals.where((animal) {
      final animalName = (animal['name'] ?? '').toString().toLowerCase();
      final animalNormalized = _normalizeNumber(animalName);
      final animalColor = (animal['name_color'] ?? '').toString().toLowerCase();
      return animalNormalized == normalizedName && animalColor == colorLc;
    }).toList();

    final isLamb = _isLambCategory(category);

    if (isLamb) {
      // Para borregos: permite até 2 com mesmo nome+cor no mesmo lote
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

      // Verifica se existe uma mãe (adulto) com esse name + color
      final hasAdult =
          existing.any((e) => !_isLambCategory(e['category']?.toString()));
      if (!hasAdult) {
        // Apenas loga aviso (não impede)
        debugPrint(
          '⚠️ Aviso: Registrando borrego sem mãe correspondente '
          '(Nome: ${map['name']}, Cor: ${map['name_color']})',
        );
      }
    } else {
      // É categoria adulta - verifica se já existe um adulto com esse name + color
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

    // Nova validação de unicidade
    await _validateUniqueness(map, isUpdate: true);

    // Verifica se o status foi alterado para "Óbito"
    final newStatus = map['status'] as String?;
    if (newStatus == 'Óbito') {
      // Move o animal para deceased_animals e remove da tabela principal.
      await handleAnimalDeathIfApplicable(
        _appDb,
        map['id'] as String,
        newStatus!,
      );
      // Remove da lista local
      _animals.removeWhere((x) => x.id == map['id']);
      await _refreshStatsSafe();
      await refreshAlerts();
      notifyListeners();
      return;
    }

    await _appDb.db.update(
      'animals',
      map,
      where: 'id = ?',
      whereArgs: [map['id']],
    );

    final updated = Animal.fromMap(map);
    final i = _animals.indexWhere((x) => x.id == updated.id);
    if (i >= 0) {
      _animals[i] = updated;
    }

    await _refreshStatsSafe();
    await refreshAlerts();
    notifyListeners();
  }

  Future<void> deleteAnimal(String id) async {
    await _appDb.db.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
    );

    _animals.removeWhere((x) => x.id == id);

    await _refreshStatsSafe();
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

    if (refreshStats) {
      await _refreshStatsSafe();
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
        final rows = await _appDb.db.query(
          'animals',
          where: 'id = ?',
          whereArgs: [animalId],
          limit: 1,
        );
        if (rows.isEmpty) return;
        map = Map<String, dynamic>.from(rows.first);
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
        final rows = await _appDb.db.query(
          'animals',
          where: 'id = ?',
          whereArgs: [animalId],
          limit: 1,
        );
        if (rows.isEmpty) return;
        map = Map<String, dynamic>.from(rows.first);
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
  Future<void> refreshAlerts({int horizonDays = 14}) async {
    try {
      final now = DateTime.now();
      final horizon = now.add(Duration(days: horizonDays));

      final List<AlertItem> next = [];
      final animalsById = {for (final a in _animals) a.id: a};

      // VACINAÇÕES (status != Aplicada/Cancelada)
      try {
        final vacs = await _appDb.db.query('vaccinations');
        for (final row in vacs) {
          final status = (row['status'] ?? 'Agendada').toString();
          if (status == 'Aplicada' || status == 'Cancelada') continue;

          final dateStr = row['scheduled_date']?.toString();
          if (dateStr == null || dateStr.isEmpty) continue;

          final due = DateTime.tryParse(dateStr);
          if (due == null) continue;
          if (due.isAfter(horizon)) continue; // mantemos vencidas + próximas

          final animalId = (row['animal_id'] ?? '').toString();
          final animal = animalsById[animalId];
          if (animal == null) continue;

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

      // MEDICAÇÕES (usa next_date como "próxima dose")
      try {
        final meds = await _appDb.db.query('medications');
        for (final row in meds) {
          // Respeitar status se existir (Agendado/Aplicado/Cancelado)
          final mstatus = (row['status'] ?? 'Agendado').toString();
          if (mstatus == 'Aplicado' || mstatus == 'Cancelado') continue;

          final nextStr = row['next_date']?.toString();
          if (nextStr == null || nextStr.isEmpty) continue;

          final due = DateTime.tryParse(nextStr);
          if (due == null) continue;
          if (due.isAfter(horizon)) continue;

          final animalId = (row['animal_id'] ?? '').toString();
          final animal = animalsById[animalId];
          if (animal == null) continue;

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

      // PESAGENS (weight_alerts)
      try {
        final weighings = await _appDb.db.query(
          'weight_alerts',
          where: 'completed = 0',
        );
        for (final row in weighings) {
          final dateStr = row['due_date']?.toString();
          if (dateStr == null || dateStr.isEmpty) continue;

          final due = DateTime.tryParse(dateStr);
          if (due == null) continue;
          if (due.isAfter(horizon)) continue;

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

      // Ordena por data e publica
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
  Future<void> _refreshStatsSafe() async {
    try {
      Future<int> countRows(String sql, [List<Object?>? args]) async {
        final r = await _appDb.db.rawQuery(sql, args);
        if (r.isEmpty) return 0;
        final v = r.first.values.first;
        if (v == null) return 0;
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString()) ?? 0;
      }

      Future<double> scalarDouble(String sql, [List<Object?>? args]) async {
        final r = await _appDb.db.rawQuery(sql, args);
        if (r.isEmpty) return 0.0;
        final v = r.first.values.first;
        if (v == null) return 0.0;
        if (v is double) return v;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0.0;
      }

      final totalAnimals = await countRows('SELECT COUNT(*) FROM animals');
      final healthy = await countRows(
        'SELECT COUNT(*) FROM animals WHERE status = ?',
        ['Saudável'],
      );
      final pregnant = await countRows(
        'SELECT COUNT(*) FROM animals WHERE pregnant = 1',
      );
      final underTreatment = await countRows(
        'SELECT COUNT(*) FROM animals WHERE status = ?',
        ['Em tratamento'],
      );
      final maleReproducers = await countRows(
        'SELECT COUNT(*) FROM animals WHERE category = ? AND gender = ?',
        ['Reprodutor', 'Macho'],
      );
      final maleLambs = await countRows(
        'SELECT COUNT(*) FROM animals WHERE category = ? AND gender = ?',
        ['Borrego', 'Macho'],
      );
      final femaleLambs = await countRows(
        'SELECT COUNT(*) FROM animals WHERE category = ? AND gender = ?',
        ['Borrego', 'Fêmea'],
      );
      final femaleReproducers = await countRows(
        'SELECT COUNT(*) FROM animals WHERE category = ? AND gender = ?',
        ['Reprodutor', 'Fêmea'],
      );

      final revenue = await scalarDouble(
        'SELECT SUM(amount) FROM financial_records WHERE type = ?',
        ['receita'],
      );

      final avgWeight = await scalarDouble(
        'SELECT AVG(weight) FROM animals',
      );

      // Mês atual YYYY-MM (sem dependência extra)
      final now = DateTime.now();
      final ym =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';

      final vaccinesThisMonth = await countRows(
        "SELECT COUNT(*) FROM vaccinations "
        "WHERE substr(COALESCE(applied_date, scheduled_date),1,7) = ?",
        [ym],
      );

      final birthsThisMonth = await countRows(
        "SELECT COUNT(*) FROM animals "
        "WHERE expected_delivery IS NOT NULL AND substr(expected_delivery,1,7) = ?",
        [ym],
      );

      _stats = AnimalStats.fromMap({
        'totalAnimals': totalAnimals,
        'healthy': healthy,
        'pregnant': pregnant,
        'underTreatment': underTreatment,
        'maleReproducers': maleReproducers,
        'maleLambs': maleLambs,
        'femaleLambs': femaleLambs,
        'femaleReproducers': femaleReproducers,
        'revenue': revenue,
        'avgWeight': avgWeight,
        'vaccinesThisMonth': vaccinesThisMonth,
        'birthsThisMonth': birthsThisMonth,
      });
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
}
