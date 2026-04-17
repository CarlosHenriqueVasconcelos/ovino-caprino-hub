import 'package:flutter/foundation.dart';
import '../../../models/animal.dart';
import '../../../utils/animal_display_utils.dart';
import '../data/herd_repository.dart';

class HerdController extends ChangeNotifier {
  HerdController({required HerdRepository herdRepository})
      : _repo = herdRepository;

  final HerdRepository _repo;

  List<Animal> _items = const [];
  Map<String, Animal> _byId = const {};
  Map<String, List<Animal>> _childrenByParentId = const {};
  Map<String, ({int male, int female, int total})> _offspringStatsByParentId =
      const {};
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  int _page = 0;
  final int _pageSize = 50;

  String _search = '';
  String? _species;
  String? _gender;
  String? _category;
  String? _lote;
  String? _status;
  String? _color;
  bool _includeSold = false;

  List<Animal> get items => List.unmodifiable(_items);
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  String get search => _search;
  String? get species => _species;
  String? get gender => _gender;
  String? get category => _category;
  String? get lote => _lote;
  String? get status => _status;
  String? get color => _color;
  bool get includeSold => _includeSold;

  int _requestToken = 0;

  void _rebuildIndexes(List<Animal> items) {
    final byId = <String, Animal>{};
    final children = <String, List<Animal>>{};

    for (final a in items) {
      byId[a.id] = a;
      final motherId = (a.motherId ?? '').trim();
      final fatherId = (a.fatherId ?? '').trim();

      if (motherId.isNotEmpty) {
        (children[motherId] ??= <Animal>[]).add(a);
      }
      if (fatherId.isNotEmpty) {
        (children[fatherId] ??= <Animal>[]).add(a);
      }
    }

    _byId = Map.unmodifiable(byId);
    final frozenChildren = <String, List<Animal>>{};
    children.forEach((key, value) {
      frozenChildren[key] = List.unmodifiable(value);
    });
    _childrenByParentId = Map.unmodifiable(frozenChildren);
  }

  Animal? resolveById(String? id) {
    if (id == null) return null;
    final key = id.trim();
    if (key.isEmpty) return null;
    return _byId[key];
  }

  List<Animal> resolveOffspring(String parentId) {
    final key = parentId.trim();
    if (key.isEmpty) return const <Animal>[];
    return _childrenByParentId[key] ?? const <Animal>[];
  }

  ({int male, int female, int total}) resolveOffspringStats(String parentId) {
    final key = parentId.trim();
    if (key.isEmpty) return (male: 0, female: 0, total: 0);

    final fromDb = _offspringStatsByParentId[key];
    if (fromDb != null) return fromDb;

    final fallback = _childrenByParentId[key] ?? const <Animal>[];
    int male = 0;
    int female = 0;
    for (final child in fallback) {
      final gender = child.gender.toLowerCase().trim();
      if (gender.startsWith('m')) male++;
      if (gender.startsWith('f')) female++;
    }
    return (male: male, female: female, total: fallback.length);
  }

  Future<void> _refreshOffspringStats() async {
    final parentIds = _items
        .map((animal) => animal.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (parentIds.isEmpty) {
      _offspringStatsByParentId = const {};
      return;
    }

    final stats = await _repo.getOffspringGenderStatsByParentIds(parentIds);
    _offspringStatsByParentId = Map.unmodifiable(stats);
  }

  void setSearch(String value) {
    _search = value.trim().toLowerCase();
  }

  void setSpecies(String? value) {
    _species = value;
  }

  void setGender(String? value) {
    _gender = value;
  }

  void setCategory(String? value) {
    _category = value;
  }

  void setLote(String? value) {
    _lote = value;
  }

  void setStatus(String? value) {
    _status = value;
  }

  void setColor(String? value) {
    _color = value;
  }

  void setIncludeSold(bool value) {
    _includeSold = value;
  }

  Future<void> refreshAll() async {
    final token = ++_requestToken;
    _error = null;
    _isRefreshing = true;
    _isLoadingMore = false;
    _hasMore = true;
    _page = 0;
    _items = const [];
    _offspringStatsByParentId = const {};
    notifyListeners();

    try {
      final results = await _repo.getFilteredAnimals(
        includeSold: _includeSold,
        statusEquals: _status,
        genderEquals: _gender,
        nameColor: _color,
        categoryEquals: _category,
        searchQuery: _search,
        limit: _pageSize,
        offset: 0,
      );

      if (token != _requestToken) return;

      final sorted = List<Animal>.of(results);
      AnimalDisplayUtils.sortAnimalsList(sorted);
      _items = List<Animal>.unmodifiable(sorted);
      _rebuildIndexes(_items);
      _hasMore = results.length == _pageSize;

      // Exibe a lista imediatamente sem esperar as stats de prole.
      // _refreshOffspringStats roda em background e notifica quando terminar.
      _isRefreshing = false;
      notifyListeners();

      if (token != _requestToken) return;
      await _refreshOffspringStats();
      if (token != _requestToken) return;
      notifyListeners();
      return; // evita o notifyListeners() duplo no finally
    } catch (e) {
      if (token != _requestToken) return;
      _error = e.toString();
      _hasMore = false;
    } finally {
      if (token == _requestToken && _isRefreshing) {
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isRefreshing) return;

    final token = ++_requestToken;
    _error = null;
    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    try {
      final results = await _repo.getFilteredAnimals(
        includeSold: _includeSold,
        statusEquals: _status,
        genderEquals: _gender,
        nameColor: _color,
        categoryEquals: _category,
        searchQuery: _search,
        limit: _pageSize,
        offset: nextPage * _pageSize,
      );

      if (token != _requestToken) return;

      if (results.isEmpty) {
        _hasMore = false;
      } else {
        final merged = List<Animal>.of(_items)..addAll(results);
        AnimalDisplayUtils.sortAnimalsList(merged);
        _items = List<Animal>.unmodifiable(merged);
        _rebuildIndexes(_items);
        await _refreshOffspringStats();
        if (token != _requestToken) return;
        _page = nextPage;
        _hasMore = results.length == _pageSize;
      }
    } catch (e) {
      if (token != _requestToken) return;
      _error = e.toString();
    } finally {
      if (token == _requestToken) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }
}
