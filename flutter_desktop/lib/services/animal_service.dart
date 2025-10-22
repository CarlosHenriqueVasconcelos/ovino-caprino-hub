// lib/services/animal_service.dart
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../data/local_db.dart';      // AppDatabase
import '../models/animal.dart';      // Animal e AnimalStats
import '../models/alert_item.dart';  // AlertItem
import 'deceased_hooks.dart';        // handleAnimalDeathIfApplicable

class AnimalService extends ChangeNotifier {
  // ----------------- Estado -----------------
  final List<Animal> _animals = [];
  AnimalStats? _stats;
  bool _loading = false;

  // Painel de alertas (vacinas + medicações)
  final List<AlertItem> _alerts = [];

  // DB
  AppDatabase? _appDb;

  // ----------------- Getters públicos -----------------
  UnmodifiableListView<Animal> get animals => UnmodifiableListView(_animals);
  AnimalStats? get stats => _stats;
  bool get isLoading => _loading;

  /// Alertas agregados (Vacinas + Medicações)
  UnmodifiableListView<AlertItem> get alerts => UnmodifiableListView(_alerts);

  // ----------------- Construtor -----------------
  /// Carrega automaticamente os dados ao iniciar o app (remove a necessidade
  /// de ver o botão "Recarregar" na primeira abertura).
  AnimalService() {
    scheduleMicrotask(() => loadData());
  }

  // ----------------- Acesso ao DB -----------------
  Future<void> _ensureDb() async {
    _appDb ??= await AppDatabase.open();
  }

  // ----------------- Ciclo de vida / carga -----------------
  Future<void> loadData() async {
    _loading = true;
    notifyListeners();
    try {
      await _ensureDb();

      // Carrega animais
      final rows = await _appDb!.db.query(
        'animals',
        orderBy: 'name COLLATE NOCASE',
      );
      final list = rows.map((m) => Animal.fromMap(m)).toList();
      _animals
        ..clear()
        ..addAll(list);

      // Estatísticas
      await _refreshStatsSafe();

      // Atualiza o painel de alertas (Vacinas + Medicações)
      await refreshAlerts();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ----------------- CRUD: Animal -----------------
  Future<void> addAnimal(Animal a) async {
    await _ensureDb();

    // Garante ID e timestamps mínimos
    final nowIso = DateTime.now().toIso8601String();
    final map = a.toMap();

    // ID local simples se não veio (evita conflito com Supabase)
    if ((map['id'] == null) || (map['id'] as String).isEmpty) {
      map['id'] = _newId();
    }
    map['created_at'] ??= nowIso;
    map['updated_at'] = nowIso;

    // Regra: (name, name_color) deve ser único (case-insensitive)
    final nameLc = (map['name'] ?? '').toString().toLowerCase();
    final colorLc = (map['name_color'] ?? '').toString().toLowerCase();
    final dup = await _appDb!.db.query(
      'animals',
      columns: ['id'],
      where: 'LOWER(name) = ? AND LOWER(IFNULL(name_color, "")) = ?',
      whereArgs: [nameLc, colorLc],
      limit: 1,
    );
    if (dup.isNotEmpty) {
      throw Exception('Já existe um animal com este Nome + Cor.');
    }


    await _appDb!.db.insert('animals', map);

    final saved = Animal.fromMap(map);
    _animals.add(saved);

    await _refreshStatsSafe();
    await refreshAlerts();
    notifyListeners();
  }

  Future<void> updateAnimal(Animal a) async {
    await _ensureDb();
    final map = a.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
        // Regra: (name, name_color) único; ignorar o próprio id
    final nameLc = (map['name'] ?? '').toString().toLowerCase();
    final colorLc = (map['name_color'] ?? '').toString().toLowerCase();
    final dup = await _appDb!.db.query(
      'animals',
      columns: ['id'],
      where: 'LOWER(name) = ? AND LOWER(IFNULL(name_color, "")) = ? AND id <> ?',
      whereArgs: [nameLc, colorLc, map['id']],
      limit: 1,
    );
    if (dup.isNotEmpty) {
      throw Exception('Já existe um animal com este Nome + Cor.');
    }

    // Verifica se o status foi alterado para "Óbito"
    final newStatus = map['status'] as String?;
    if (newStatus == 'Óbito') {
      // Move o animal para deceased_animals e remove da tabela principal
      await handleAnimalDeathIfApplicable(map['id'] as String, newStatus);
      // Remove da lista local
      _animals.removeWhere((x) => x.id == map['id']);
      await _refreshStatsSafe();
      await refreshAlerts();
      notifyListeners();
      return;
    }

    await _appDb!.db.update(
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
    await _ensureDb();

    await _appDb!.db.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
    );

    _animals.removeWhere((x) => x.id == id);

    await _refreshStatsSafe();
    await refreshAlerts();
    notifyListeners();
  }

  // ----------------- Alertas (Vacinas + Medicações) -----------------
  /// Recalcula o painel de alertas olhando até [horizonDays] dias à frente.
  /// Inclui itens vencidos (overdue) e os que estão dentro do horizonte.
  Future<void> refreshAlerts({int horizonDays = 14}) async {
    try {
      await _ensureDb();

      final now = DateTime.now();
      final horizon = now.add(Duration(days: horizonDays));

      final List<AlertItem> next = [];
      final animalsById = {for (final a in _animals) a.id: a};

      // VACINAÇÕES (status != Aplicada/Cancelada)
      try {
        final vacs = await _appDb!.db.query('vaccinations');
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

          next.add(AlertItem(
            id: row['id'].toString(),
            animalId: animalId,
            animalName: animal.name,
            animalCode: animal.code,
            type: AlertType.vaccination,
            title: 'Vacina: ${(row['vaccine_name'] ?? '').toString()}',
            dueDate: due,
          ));
        }
      } catch (e) {
        debugPrint('Erro carregando vacinações: $e');
      }

      // MEDICAÇÕES (usa next_date como “próxima dose”)
      try {
        final meds = await _appDb!.db.query('medications');
        for (final row in meds) {
          // ✅ ADIÇÃO: respeitar status se existir (Agendado/Aplicado/Cancelado)
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

          next.add(AlertItem(
            id: row['id'].toString(),
            animalId: animalId,
            animalName: animal.name,
            animalCode: animal.code,
            type: AlertType.medication,
            title: 'Medicação: ${(row['medication_name'] ?? '').toString()}',
            dueDate: due,
          ));
        }
      } catch (e) {
        debugPrint('Erro carregando medicações: $e');
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
      await _ensureDb();

      Future<int> _count(String sql, [List<Object?>? args]) async {
        final r = await _appDb!.db.rawQuery(sql, args);
        if (r.isEmpty) return 0;
        final v = r.first.values.first;
        if (v == null) return 0;
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString()) ?? 0;
      }

      Future<double> _scalarDouble(String sql, [List<Object?>? args]) async {
        final r = await _appDb!.db.rawQuery(sql, args);
        if (r.isEmpty) return 0.0;
        final v = r.first.values.first;
        if (v == null) return 0.0;
        if (v is double) return v;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0.0;
      }

      final totalAnimals = await _count('SELECT COUNT(*) FROM animals');
      final healthy = await _count(
        'SELECT COUNT(*) FROM animals WHERE status = ?',
        ['Saudável'],
      );
      final pregnant = await _count(
        'SELECT COUNT(*) FROM animals WHERE pregnant = 1',
      );
      final underTreatment = await _count(
        'SELECT COUNT(*) FROM animals WHERE status = ?',
        ['Em tratamento'],
      );
      final maleReproducers = await _count(
        'SELECT COUNT(*) FROM animals WHERE category = ?',
        ['Macho Reprodutor'],
      );
      final maleLambs = await _count(
        'SELECT COUNT(*) FROM animals WHERE category = ?',
        ['Macho Borrego'],
      );
      final femaleLambs = await _count(
        'SELECT COUNT(*) FROM animals WHERE category = ?',
        ['Fêmea Borrega'],
      );
      final femaleReproducers = await _count(
        'SELECT COUNT(*) FROM animals WHERE category = ?',
        ['Fêmea Reprodutora'],
      );

      final revenue = await _scalarDouble(
        'SELECT SUM(amount) FROM financial_records WHERE type = ?',
        ['receita'],
      );

      final avgWeight = await _scalarDouble(
        'SELECT AVG(weight) FROM animals',
      );

      // Mês atual YYYY-MM (sem dependência extra)
      final now = DateTime.now();
      final ym =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';

      final vaccinesThisMonth = await _count(
        "SELECT COUNT(*) FROM vaccinations "
        "WHERE substr(COALESCE(applied_date, scheduled_date),1,7) = ?",
        [ym],
      );

      final birthsThisMonth = await _count(
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
}
