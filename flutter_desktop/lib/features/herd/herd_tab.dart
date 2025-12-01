import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../services/animal_delete_cascade.dart';
import '../../services/animal_service.dart';
import '../../services/data_refresh_bus.dart';
import '../../services/deceased_service.dart';
import '../../services/sold_animals_service.dart';
import '../../services/events/event_bus.dart';
import '../../services/events/app_events.dart';
import '../../widgets/animal_form.dart';
import '../../data/animal_repository.dart';
import '../../widgets/herd/herd_actions_bar.dart';
import '../../widgets/herd/herd_animal_grid.dart';
import '../../widgets/herd/herd_filters_bar.dart';

class HerdTab extends StatelessWidget {
  const HerdTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: HerdSection(),
    );
  }
}

class HerdSection extends StatefulWidget {
  const HerdSection({super.key});

  @override
  State<HerdSection> createState() => HerdSectionState();
}

class HerdSectionState extends State<HerdSection>
    with EventBusSubscriptions {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  bool _includeSold = false;
  String?
      _statusFilter; // null = todos; 'Saudável' | 'Em tratamento' | 'Vendido' | 'Óbito'
  String? _colorFilter;
  String? _categoryFilter;

  int _currentPage = 0;
  static const int _itemsPerPage = 50;

  StreamSubscription<String>? _busSub;
  Future<List<Animal>>? _deceasedFuture;
  Future<HerdQueryResult>? _futurePage;
  List<String> _availableColors = [];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    
    // Sistema reativo aprimorado (FASE 3)
    _setupReactiveListeners();
    
    // Backward compatibility com DataRefreshBus
    _busSub = DataRefreshBus.stream.listen((_) {
      if (!mounted) return;
      _refresh();
      setState(() {
        _deceasedFuture = _loadDeceasedAnimals(context);
      });
    });
    
    _deceasedFuture = _loadDeceasedAnimals(context);
    _loadFilters();
    _refresh();
  }
  
  /// FASE 3: Listeners reativos granulares
  void _setupReactiveListeners() {
    // Quando animal é criado/atualizado/deletado
    onEvent<AnimalCreatedEvent>((event) {
      debugPrint('🆕 Animal criado: ${event.name}, recarregando lista');
      _refresh();
    });
    
    onEvent<AnimalUpdatedEvent>((event) {
      debugPrint('📝 Animal ${event.animalId} atualizado, recarregando lista');
      _refresh();
    });
    
    onEvent<AnimalDeletedEvent>((event) {
      debugPrint('🗑️ Animal ${event.animalId} deletado, recarregando lista');
      _refresh();
    });
    
    // Quando animal é vendido ou morre
    onEvent<AnimalMarkedAsSoldEvent>((event) {
      debugPrint('💰 Animal ${event.animalId} vendido, recarregando');
      _refresh();
      setState(() {
        _deceasedFuture = _loadDeceasedAnimals(context);
      });
    });
    
    onEvent<AnimalMarkedAsDeceasedEvent>((event) {
      debugPrint('⚰️ Animal ${event.animalId} faleceu, recarregando');
      _refresh();
      setState(() {
        _deceasedFuture = _loadDeceasedAnimals(context);
      });
    });
    
    // Quando peso é adicionado (pode mudar categoria de borrego para adulto)
    onEvent<WeightAddedEvent>((event) {
      if (event.milestone == '120d') {
        debugPrint('⚖️ Peso 120d adicionado, animal pode ter sido promovido');
        _refresh();
      }
    });
  }

  @override
  void dispose() {
    _busSub?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<List<Animal>> _loadDeceasedAnimals(BuildContext context) async {
    final deceasedService = context.read<DeceasedService>();
    return deceasedService.getDeceasedAnimals();
  }

  Future<List<Animal>> _loadSoldAnimals(BuildContext context) async {
    final soldService = context.read<SoldAnimalsService>();
    final animalService = context.read<AnimalService>();
    // Sold table (animais já movidos)
    final soldFromTable = await soldService.getSoldAnimals();
    // Fallback: animais ainda na tabela principal com status Vendido (caso algum não tenha sido movido)
    final fromMain = await animalService.herdQuery(
      includeSold: true,
      statusEquals: 'Vendido',
      pageSize: 500,
    );
    // Mesclar evitando duplicados pelo id
    final merged = <String, Animal>{};
    for (final a in soldFromTable) {
      merged[a.id] = a;
    }
    for (final a in fromMain.items) {
      merged[a.id] = a;
    }
    return merged.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _deceasedFuture ??= _loadDeceasedAnimals(context);

    return FutureBuilder<List<Animal>>(
      future: _deceasedFuture,
      builder: (context, deceasedSnapshot) {
        final deceasedAnimals = deceasedSnapshot.data ?? const <Animal>[];
        final deceasedLoading =
            deceasedSnapshot.connectionState == ConnectionState.waiting &&
                deceasedSnapshot.data == null;

        return FutureBuilder<HerdQueryResult>(
          future: _futurePage,
          builder: (context, snapshot) {
            final page = snapshot.data;
            final items = page?.items ?? const <Animal>[];
            final total = page?.total ?? 0;
            final totalPages =
                ((total + _itemsPerPage - 1) / _itemsPerPage).ceil().clamp(1, 9999);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HerdActionsBar(
                      onAddAnimal: () => _showAnimalForm(context),
                    ),
                    const SizedBox(height: 16),
                    HerdFiltersBar(
                      searchController: _search,
                      onSearchChanged: (value) {
                        setState(() {
                          _query = value.trim().toLowerCase();
                          _currentPage = 0;
                        });
                        _refresh();
                      },
                      onClearSearch: () {
                        setState(() {
                          _query = '';
                          _search.clear();
                          _currentPage = 0;
                        });
                        _refresh();
                      },
                      includeSold: _includeSold,
                      onIncludeSoldChanged: (value) {
                        setState(() {
                          _includeSold = value;
                          _currentPage = 0;
                        });
                        _refresh();
                      },
                      statusFilter: _statusFilter,
                      statusOptions: const [
                        'Saudável',
                        'Em tratamento',
                        'Vendido',
                        'Óbito',
                      ],
                      onStatusChanged: (value) {
                        setState(() {
                          _statusFilter = value;
                          _currentPage = 0;
                        });
                        _refresh();
                      },
                      colorFilter: _colorFilter,
                      colorOptions: _availableColors,
                      onColorChanged: (value) {
                        setState(() {
                          _colorFilter = value;
                          _currentPage = 0;
                        });
                        _refresh();
                      },
                      categoryFilter: _categoryFilter,
                      categoryOptions: _availableCategories,
                      onCategoryChanged: (value) {
                        setState(() {
                          _categoryFilter = value;
                          _currentPage = 0;
                        });
                        _refresh();
                      },
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (items.isEmpty &&
                        _statusFilter != 'Óbito' &&
                        _statusFilter != 'Vendido')
                      _emptyState(theme)
                    else ...[
                      // Paginação (não aplicável a óbito/vendido)
                      if (_statusFilter != 'Óbito' &&
                          _statusFilter != 'Vendido' &&
                          items.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Exibindo ${(_currentPage * _itemsPerPage) + 1} - ${((_currentPage + 1) * _itemsPerPage).clamp(0, total)} de $total animais',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: _currentPage > 0
                                      ? () => setState(() {
                                            _currentPage--;
                                            _refresh();
                                          })
                                      : null,
                                ),
                                Text('Página ${_currentPage + 1} de $totalPages'),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed:
                                      (_currentPage + 1) < totalPages
                                          ? () => setState(() {
                                                _currentPage++;
                                                _refresh();
                                              })
                                          : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_statusFilter == 'Óbito')
                        Builder(
                          builder: (context) {
                            if (deceasedLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (deceasedAnimals.isEmpty) {
                              return _emptyState(theme);
                            }
                            final relations =
                                _AnimalRelations([], deceasedAnimals);
                            return HerdAnimalGrid(
                              animals: deceasedAnimals,
                              repository: context.read<AnimalRepository>(),
                              resolveParent: relations.parentOf,
                              resolveOffspring: relations.offspringOf,
                            );
                          },
                        )
                      else if (_statusFilter == 'Vendido')
                        FutureBuilder<List<Animal>>(
                          future: _loadSoldAnimals(context),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final list = snapshot.data!;
                            if (list.isEmpty) {
                              return _emptyState(theme);
                            }
                            final relations = _AnimalRelations(list);
                            return HerdAnimalGrid(
                              animals: list,
                              repository: context.read<AnimalRepository>(),
                              resolveParent: relations.parentOf,
                              resolveOffspring: relations.offspringOf,
                            );
                          },
                        )
                      else
                        Builder(
                          builder: (context) {
                            final deleteCascade =
                                context.read<AnimalDeleteCascade>();
                            return HerdAnimalGrid(
                              animals: items,
                              repository: context.read<AnimalRepository>(),
                              resolveParent:
                                  _AnimalRelations(items, deceasedAnimals)
                                      .parentOf,
                              resolveOffspring:
                                  _AnimalRelations(items, deceasedAnimals)
                                      .offspringOf,
                              onEdit: (animal) =>
                                  _showAnimalForm(context, animal: animal),
                              onDeleteCascade: (animal) async {
                                await deleteCascade.delete(animal.id);
                                if (!mounted) return;
                                setState(() {
                                  _currentPage = 0;
                                });
                                _refresh();
                              },
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.pets, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Nenhum animal cadastrado',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione o primeiro animal ao rebanho',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showAnimalForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Primeiro Animal'),
          ),
        ],
      ),
    );
  }

  void _showAnimalForm(BuildContext context, {Animal? animal}) {
    showDialog(
      context: context,
      builder: (context) => AnimalFormDialog(animal: animal),
    );
  }

  Future<void> _loadFilters() async {
    final service = context.read<AnimalService>();
    final colors = await service.getAvailableColors();
    final categories = await service.getAvailableCategories();
    if (!mounted) return;
    setState(() {
      _availableColors = colors;
      _availableCategories = categories;
    });
  }

  void _refresh() {
    if (_statusFilter == 'Óbito' || _statusFilter == 'Vendido') {
      setState(() {
        _futurePage = Future.value(const HerdQueryResult(items: [], total: 0));
      });
      return;
    }
    final service = context.read<AnimalService>();
    final future = service.herdQuery(
      includeSold: _includeSold,
      statusEquals: _statusFilter,
      colorFilter: _colorFilter,
      categoryFilter: _categoryFilter,
      searchQuery: _query,
      page: _currentPage,
      pageSize: _itemsPerPage,
    );
    setState(() {
      _futurePage = future;
    });
  }
}

class _AnimalRelations {
  final Map<String, Animal> _byId = {};
  final Map<String, List<Animal>> _offspring = {};

  _AnimalRelations(List<Animal> animals,
      [List<Animal> deceased = const <Animal>[]]) {
    for (final animal in [...animals, ...deceased]) {
      if (_byId.containsKey(animal.id)) continue;
      _byId[animal.id] = animal;

      final motherId = animal.motherId;
      final fatherId = animal.fatherId;
      if (motherId != null && motherId.isNotEmpty) {
        _offspring.putIfAbsent(motherId, () => []).add(animal);
      }
      if (fatherId != null && fatherId.isNotEmpty) {
        _offspring.putIfAbsent(fatherId, () => []).add(animal);
      }
    }
  }

  Animal? parentOf(String? id) {
    if (id == null || id.isEmpty) return null;
    return _byId[id];
  }

  List<Animal> offspringOf(String id) {
    if (id.isEmpty) return const [];
    return _offspring[id] ?? const [];
  }
}
