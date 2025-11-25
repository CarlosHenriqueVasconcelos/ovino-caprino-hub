import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../services/animal_delete_cascade.dart';
import '../../services/animal_service.dart';
import '../../services/data_refresh_bus.dart';
import '../../services/deceased_service.dart';
import '../../services/sold_animals_service.dart';
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

class HerdSectionState extends State<HerdSection> {
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

  @override
  void initState() {
    super.initState();
    // Recarrega automaticamente quando hooks mexerem no banco
    _busSub = DataRefreshBus.stream.listen((_) {
      if (!mounted) return;
      // Atualiza lista viva e refaz FutureBuilders de vendidos/óbitos
      context.read<AnimalService>().loadData();
      setState(() {
        _deceasedFuture = _loadDeceasedAnimals(context);
      });
    });
    _deceasedFuture = _loadDeceasedAnimals(context);
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
    return soldService.getSoldAnimals();
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
        return Selector<AnimalService, int>(
          selector: (_, service) => service.animalsVersion,
          builder: (context, _, __) {
            final animalService = context.read<AnimalService>();
            final animalRepo = context.read<AnimalRepository>();
            final deleteCascade = context.read<AnimalDeleteCascade>();
            final UnmodifiableListView<Animal> all = animalService.animals;
            final baseList = (() {
              if (_statusFilter == 'Vendido') {
                return all.where((a) => a.status == 'Vendido').toList();
              } else if (_statusFilter == 'Em tratamento') {
                return all.where((a) => a.status == 'Em tratamento').toList();
              } else if (_statusFilter == 'Saudável') {
                return all.where((a) => a.status == 'Saudável').toList();
              } else if (_statusFilter == 'Óbito') {
                // Lista especial renderizada abaixo via FutureBuilder
                return <Animal>[];
              } else {
                // Sem status específico: volta a valer o toggle "Incluir vendidos"
                return _includeSold
                    ? all
                    : all.where((a) => a.status != 'Vendido').toList();
              }
            })();

            // Aplicar filtros de cor e categoria
            var filtered = baseList.where((a) {
              final color = a.nameColor;
              if (_colorFilter != null && color != _colorFilter) {
                return false;
              }
              final category = a.category;
              if (_categoryFilter != null && category != _categoryFilter) {
                return false;
              }
              return true;
            }).toList();

            // Aplicar busca por texto (exata)
            filtered = _filter(filtered, _query);

            // Ordenar por cor e depois por número
            filtered.sort((a, b) {
              final colorA = a.nameColor;
              final colorB = b.nameColor;
              final colorCompare = colorA.compareTo(colorB);
              if (colorCompare != 0) return colorCompare;

              // Extrair números do código para ordenação numérica
              final numA =
                  int.tryParse(a.code.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              final numB =
                  int.tryParse(b.code.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              return numA.compareTo(numB);
            });

            // Obter listas únicas de cores e categorias
            final availableColors = all
                .map((a) => a.nameColor)
                .whereType<String>()
                .toSet()
                .toList()
              ..sort();
            final availableCategories = all
                .map((a) => a.category)
                .whereType<String>()
                .toSet()
                .toList()
              ..sort();

            final relations = _AnimalRelations(all, deceasedAnimals);

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
                        });
                      },
                      onClearSearch: () {
                        setState(() {
                          _query = '';
                          _search.clear();
                        });
                      },
                      includeSold: _includeSold,
                      onIncludeSoldChanged: (value) {
                        setState(() => _includeSold = value);
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
                      },
                      colorFilter: _colorFilter,
                      colorOptions: availableColors,
                      onColorChanged: (value) {
                        setState(() {
                          _colorFilter = value;
                          _currentPage = 0;
                        });
                      },
                      categoryFilter: _categoryFilter,
                      categoryOptions: availableCategories,
                      onCategoryChanged: (value) {
                        setState(() {
                          _categoryFilter = value;
                          _currentPage = 0;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (all.isEmpty)
                      _emptyState(theme)
                    else ...[
                      // Informações de paginação (apenas quando não está em Óbito/Vendido)
                      if (_statusFilter != 'Óbito' &&
                          _statusFilter != 'Vendido' &&
                          filtered.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Exibindo ${(_currentPage * _itemsPerPage) + 1} - ${((_currentPage + 1) * _itemsPerPage).clamp(0, filtered.length)} de ${filtered.length} animais',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: _currentPage > 0
                                      ? () => setState(
                                            () => _currentPage--,
                                          )
                                      : null,
                                ),
                                Text(
                                  'Página ${_currentPage + 1} de ${((filtered.length - 1) ~/ _itemsPerPage) + 1}',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed:
                                      (_currentPage + 1) * _itemsPerPage <
                                              filtered.length
                                          ? () => setState(
                                                () => _currentPage++,
                                              )
                                          : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Quando filtro = Óbito, carrega da tabela deceased_animals via service
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
                            final deceasedRelations =
                                _AnimalRelations([...all], deceasedAnimals);
                            return HerdAnimalGrid(
                              animals: deceasedAnimals,
                              repository: animalRepo,
                              resolveParent: deceasedRelations.parentOf,
                              resolveOffspring: deceasedRelations.offspringOf,
                            );
                          },
                        )
                      // Quando filtro = Vendido, carrega da tabela sold_animals
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
                            final soldRelations = _AnimalRelations(
                              [...all, ...list],
                            );
                            return HerdAnimalGrid(
                              animals: list,
                              repository: animalRepo,
                              resolveParent: soldRelations.parentOf,
                              resolveOffspring: soldRelations.offspringOf,
                            );
                          },
                        )
                      else
                        Builder(
                          builder: (context) {
                            // Aplicar paginação
                            final startIndex = _currentPage * _itemsPerPage;
                            final endIndex = (startIndex + _itemsPerPage)
                                .clamp(0, filtered.length);
                            final paginatedList =
                                filtered.sublist(startIndex, endIndex);

                            return HerdAnimalGrid(
                              animals: paginatedList,
                              repository: animalRepo,
                              resolveParent: relations.parentOf,
                              resolveOffspring: relations.offspringOf,
                              onEdit: (animal) =>
                                  _showAnimalForm(context, animal: animal),
                              onDeleteCascade: (animal) async {
                                await deleteCascade.delete(animal.id);
                                if (!mounted) return;
                                await animalService.removeFromCache(animal.id);
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

  List<Animal> _filter(List<Animal> animals, String q) {
    if (q.isEmpty) return animals;
    return animals.where((animal) {
      final name = animal.name.toLowerCase();
      final code = animal.code.toLowerCase();
      final category = animal.category.toLowerCase();
      final breed = animal.breed.toLowerCase();
      // Busca exata - retorna apenas se algum campo for exatamente igual ao termo buscado
      return name == q || code == q || category == q || breed == q;
    }).toList();
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
