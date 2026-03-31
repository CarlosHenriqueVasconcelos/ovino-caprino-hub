import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/animal_repository.dart';
import '../../../models/animal.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/app_empty_state.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../services/animal_delete_cascade.dart';
import '../../../services/animal_service.dart';
import '../../../services/deceased_service.dart';
import '../../../services/events/app_events.dart';
import '../../../services/events/event_bus.dart';
import '../../../services/sold_animals_service.dart';
import '../../../utils/debouncer.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/animal_display_utils.dart';
import '../../../shared/widgets/animal/animal_form.dart';
import '../data/herd_repository.dart';
import 'widgets/herd_actions_bar.dart';
import 'widgets/herd_animal_grid.dart';
import 'widgets/herd_filters_bar.dart';
import '../application/herd_controller.dart';

class HerdTab extends StatelessWidget {
  const HerdTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return MultiProvider(
      providers: [
        Provider<HerdRepository>(
          create: (context) => HerdRepository(
            animalRepository: context.read<AnimalRepository>(),
            animalService: context.read<AnimalService>(),
            soldAnimalsService: context.read<SoldAnimalsService>(),
            deceasedService: context.read<DeceasedService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HerdController(
            herdRepository: context.read<HerdRepository>(),
          )..refreshAll(),
        ),
      ],
      child: Stack(
        children: [
          const HerdView(),
          if (isMobile)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: () => _showAnimalFormDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Animal'),
              ),
            ),
        ],
      ),
    );
  }
}

class HerdView extends StatefulWidget {
  const HerdView({super.key});

  @override
  State<HerdView> createState() => _HerdViewState();
}

class _HerdViewState extends State<HerdView>
    with AutomaticKeepAliveClientMixin, EventBusSubscriptions {
  final TextEditingController _search = TextEditingController();
  final Debouncer _searchDebouncer =
      Debouncer(delay: const Duration(milliseconds: 300));
  final ScrollController _scrollCtrl = ScrollController();

  String _query = '';
  String _queryPending = '';

  bool _includeSold = false;
  String?
      _statusFilter; // null = todos; 'Saudável' | 'Em tratamento' | 'Ferido' | especiais: 'Vendido'/'Óbito'
  String? _colorFilter;
  String? _categoryFilter;

  Future<List<Animal>>? _deceasedFuture;
  List<String> _availableColors = [];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();

    _setupReactiveListeners();

    _deceasedFuture = _loadDeceasedAnimals(context);
    _loadFilters();
    _scrollCtrl.addListener(_onScroll);
  }

  void _setupReactiveListeners() {
    onEvent<AnimalCreatedEvent>((event) {
      if (kDebugMode) {
        debugPrint('🆕 Animal criado: ${event.name}, recarregando lista');
      }
      _refreshActiveList();
    });

    onEvent<AnimalUpdatedEvent>((event) {
      if (kDebugMode) {
        debugPrint('📝 Animal ${event.animalId} atualizado, recarregando lista');
      }
      _refreshActiveList();
    });

    onEvent<AnimalDeletedEvent>((event) {
      if (kDebugMode) {
        debugPrint('🗑️ Animal ${event.animalId} deletado, recarregando lista');
      }
      _refreshActiveList();
    });

    onEvent<AnimalMarkedAsSoldEvent>((event) {
      if (kDebugMode) {
        debugPrint('💰 Animal ${event.animalId} vendido, recarregando');
      }
      if (mounted) {
        setState(() {});
      }
      _refreshActiveList();
    });

    onEvent<AnimalMarkedAsDeceasedEvent>((event) {
      if (kDebugMode) {
        debugPrint('⚰️ Animal ${event.animalId} faleceu, recarregando');
      }
      if (mounted) {
        setState(() {
          _deceasedFuture = _loadDeceasedAnimals(context);
        });
      }
      _refreshActiveList();
    });

    onEvent<WeightAddedEvent>((event) {
      if (event.milestone == '120d') {
        if (kDebugMode) {
          debugPrint('⚖️ Peso 120d adicionado, animal pode ter sido promovido');
        }
        _refreshActiveList();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _searchDebouncer.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<List<Animal>> _loadDeceasedAnimals(BuildContext context) async {
    final herdRepository = context.read<HerdRepository>();
    return herdRepository.getDeceasedAnimals();
  }

  Future<List<Animal>> _loadSoldAnimals(BuildContext context) async {
    final herdRepository = context.read<HerdRepository>();
    return herdRepository.getSoldAnimals();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _deceasedFuture ??= _loadDeceasedAnimals(context);
    final contentPadding = ResponsiveUtils.isMobile(context)
        ? AppSpacing.sm
        : AppSpacing.lg;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Padding(
          padding: EdgeInsets.all(contentPadding),
          child: FutureBuilder<List<Animal>>(
            future: _deceasedFuture,
            builder: (context, deceasedSnapshot) {
              final deceasedAnimals = deceasedSnapshot.data ?? const <Animal>[];
              final deceasedLoading =
                  deceasedSnapshot.connectionState == ConnectionState.waiting &&
                      deceasedSnapshot.data == null;

              return Scrollbar(
                controller: _scrollCtrl,
                thumbVisibility: !ResponsiveUtils.isMobile(context),
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HerdActionsBar(
                        onAddAnimal: () => _showAnimalFormDialog(context),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      HerdFiltersBar(
                        searchController: _search,
                        onSearchChanged: (value) {
                          _queryPending = value.trim().toLowerCase();
                          _searchDebouncer.run(() {
                            _query = _queryPending;
                            _applyFilters(refresh: true);
                          });
                        },
                        onClearSearch: () {
                          _query = '';
                          _search.clear();
                          _applyFilters(refresh: true);
                          setState(() {});
                        },
                        includeSold: _includeSold,
                        onIncludeSoldChanged: (value) {
                          setState(() {
                            _includeSold = value;
                          });
                          _applyFilters(refresh: true);
                        },
                        statusFilter: _statusFilter,
                        statusOptions: const [
                          'Saudável',
                          'Em tratamento',
                          'Ferido',
                          'Vendido',
                          'Óbito',
                        ],
                        onStatusChanged: (value) {
                          setState(() {
                            _statusFilter = value;
                          });
                          _applyFilters(refresh: true);
                        },
                        colorFilter: _colorFilter,
                        colorOptions: _availableColors,
                        onColorChanged: (value) {
                          setState(() {
                            _colorFilter = value;
                          });
                          _applyFilters(refresh: true);
                        },
                        categoryFilter: _categoryFilter,
                        categoryOptions: _availableCategories,
                        onCategoryChanged: (value) {
                          setState(() {
                            _categoryFilter = value;
                          });
                          _applyFilters(refresh: true);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Selector<HerdController, ({int count, bool loading})>(
                        selector: (_, c) => (
                          count: c.items.length,
                          loading: c.isRefreshing,
                        ),
                        builder: (_, state, __) {
                          final subtitle = _isSpecialStatus()
                              ? 'Listagem filtrada por status especial'
                              : state.loading
                                  ? 'Atualizando lista de animais...'
                                  : '${state.count} registro(s) nesta página';
                          return SectionHeader(
                            title: 'Animais do Rebanho',
                            subtitle: subtitle,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Selector<HerdController, String?>(
                        selector: (_, c) => c.error,
                        builder: (_, error, __) {
                          if (error == null || error.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return _ErrorBanner(message: error);
                        },
                      ),
                      Selector<HerdController, ({bool isRefreshing, bool hasItems})>(
                        selector: (_, c) => (
                          isRefreshing: c.isRefreshing,
                          hasItems: c.items.isNotEmpty,
                        ),
                        builder: (_, state, __) {
                          if (_isSpecialStatus()) {
                            return const SizedBox.shrink();
                          }
                          if (state.isRefreshing && state.hasItems) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.xs),
                              child: LinearProgressIndicator(minHeight: 2),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      Selector<HerdController, ({bool isRefreshing, List<Animal> items})>(
                        selector: (_, c) =>
                            (isRefreshing: c.isRefreshing, items: c.items),
                        builder: (_, state, __) {
                          if (!_isSpecialStatus() &&
                              state.isRefreshing &&
                              state.items.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return AppCard(
                            variant: AppCardVariant.outlined,
                            backgroundColor: AppColors.surface.withValues(
                              alpha: 0.94,
                            ),
                            borderColor: AppColors.borderNeutral.withValues(
                              alpha: 0.72,
                            ),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: _buildGridContent(
                              items: state.items,
                              deceasedAnimals: deceasedAnimals,
                              deceasedLoading: deceasedLoading,
                            ),
                          );
                        },
                      ),
                      Selector<HerdController, ({bool hasMore, bool isLoadingMore})>(
                        selector: (_, c) => (
                          hasMore: c.hasMore,
                          isLoadingMore: c.isLoadingMore,
                        ),
                        builder: (_, state, __) {
                          if (_isSpecialStatus()) {
                            return const SizedBox.shrink();
                          }
                          if (!state.hasMore && !state.isLoadingMore) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Center(
                              child: state.isLoadingMore
                                  ? const _LoadingFooter()
                                  : SecondaryButton(
                                      onPressed: () {
                                        context.read<HerdController>().loadMore();
                                      },
                                      label: 'Carregar mais',
                                    ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: ResponsiveUtils.isMobile(context) ? 88 : 24,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGridContent({
    required List<Animal> items,
    required List<Animal> deceasedAnimals,
    required bool deceasedLoading,
  }) {
    if (_statusFilter == 'Óbito') {
      if (deceasedLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (deceasedAnimals.isEmpty) {
        return _emptyState();
      }
      final sortedDeceased = List<Animal>.of(deceasedAnimals);
      AnimalDisplayUtils.sortAnimalsList(sortedDeceased);
      final relations = _AnimalRelations([], sortedDeceased);
      return HerdAnimalGrid(
        animals: sortedDeceased,
        resolveParent: relations.parentOf,
        resolveOffspring: relations.offspringOf,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    }

    if (_statusFilter == 'Vendido') {
      return FutureBuilder<List<Animal>>(
        future: _loadSoldAnimals(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data!;
          if (list.isEmpty) {
            return _emptyState();
          }
          final relations = _AnimalRelations(list);
          return HerdAnimalGrid(
            animals: list,
            resolveParent: relations.parentOf,
            resolveOffspring: relations.offspringOf,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          );
        },
      );
    }

    if (items.isEmpty) {
      return _emptyState();
    }

    final deleteCascade = context.read<AnimalDeleteCascade>();
    final herdController = context.read<HerdController>();
    return HerdAnimalGrid(
      animals: items,
      resolveParent: herdController.resolveById,
      resolveOffspring: herdController.resolveOffspring,
      onEdit: (animal) => _showAnimalFormDialog(context, animal: animal),
      onDeleteCascade: (animal) async {
        await deleteCascade.delete(animal.id);
        if (!mounted) return;
        _refreshActiveList();
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _emptyState() {
    return AppEmptyState(
      icon: Icons.pets_outlined,
      title: 'Nenhum animal encontrado',
      description: 'Ajuste os filtros ou cadastre um novo animal no rebanho.',
      action: PrimaryButton(
        label: 'Adicionar Animal',
        icon: Icons.add,
        onPressed: () => _showAnimalFormDialog(context),
      ),
    );
  }

  void _applyFilters({required bool refresh}) {
    final controller = context.read<HerdController>();
    controller.setSearch(_query);
    controller.setIncludeSold(_includeSold);
    controller.setStatus(_statusFilter);
    controller.setColor(_colorFilter);
    controller.setCategory(_categoryFilter);

    if (refresh && !_isSpecialStatus()) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(0);
      }
      controller.refreshAll();
    }
  }

  void _refreshActiveList() {
    _applyFilters(refresh: true);
  }

  void _onScroll() {
    if (_isSpecialStatus()) return;
    if (_scrollCtrl.position.extentAfter < 600) {
      context.read<HerdController>().loadMore();
    }
  }

  Future<void> _loadFilters() async {
    final herdRepository = context.read<HerdRepository>();
    final colors = await herdRepository.getAvailableColors();
    final categories = await herdRepository.getAvailableCategories();
    if (!mounted) return;
    setState(() {
      _availableColors = colors;
      _availableCategories = categories;
    });
  }

  bool _isSpecialStatus() {
    return _statusFilter == 'Óbito' || _statusFilter == 'Vendido';
  }

  @override
  bool get wantKeepAlive => true;
}

class _LoadingFooter extends StatelessWidget {
  const _LoadingFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 8),
        Text('Carregando...'),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        variant: AppCardVariant.soft,
        backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.8),
        borderColor: theme.colorScheme.error.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAnimalFormDialog(BuildContext context, {Animal? animal}) {
  showDialog(
    context: context,
    builder: (context) => AnimalFormDialog(animal: animal),
  );
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
