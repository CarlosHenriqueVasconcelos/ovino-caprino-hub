import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/animal_repository.dart';
import '../../../models/animal.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/app_brand_header.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/app_empty_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
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
import 'widgets/herd_animal_grid.dart';
import 'widgets/herd_primary_chips.dart';
import 'widgets/herd_search_bar.dart';
import 'widgets/herd_secondary_actions_row.dart';
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
              left: 0,
              right: 0,
              bottom: 9,
              child: Center(
                child: _NewAnimalPillButton(
                  onTap: () => _showAnimalFormDialog(context),
                ),
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
  String? _genderFilter;
  String? _colorFilter;
  String? _categoryFilter;
  static const List<String> _statusOptions = <String>[
    'Saudável',
    'Em tratamento',
    'Ferido',
    'Vendido',
    'Óbito',
  ];
  static const List<String> _genderOptions = <String>['Fêmea', 'Macho'];

  Future<List<Animal>>? _deceasedFuture;
  Future<List<Animal>>? _soldFuture;
  List<String> _availableColors = [];
  List<String> _availableCategories = [];
  bool _insightsLoading = false;
  _HerdInsights? _insights;

  @override
  void initState() {
    super.initState();

    _setupReactiveListeners();

    _deceasedFuture = _loadDeceasedAnimals(context);
    _loadFilters();
    _loadInsights();
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
        setState(() {
          _soldFuture = _loadSoldAnimals(context);
        });
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
    _soldFuture ??= _loadSoldAnimals(context);
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
              final pageBackground = Color.alphaBlend(
                AppColors.beigeSoft.withValues(alpha: 0.06),
                AppColors.surface,
              );

              return DecoratedBox(
                decoration: BoxDecoration(color: pageBackground),
                child: Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: !ResponsiveUtils.isMobile(context),
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      const AppBrandHeader(
                        title: 'Fazenda São Petrônio',
                        subtitle: 'Gestão de Ovinos e Caprinos',
                        margin: EdgeInsets.zero,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: AppColors.borderNeutral.withValues(alpha: 0.58),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.014),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HerdSearchBar(
                              controller: _search,
                              onChanged: _onSearchChanged,
                              onOpenFilters: _openFiltersSheet,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            HerdPrimaryChips(
                              selectedCategory: _categoryFilter,
                              onSelected: (value) {
                                _updateFilters(() => _categoryFilter = value);
                              },
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            HerdSecondaryActionsRow(
                              onOpenFilters: _openFiltersSheet,
                              onClearFilters: _clearAllFilters,
                              onToggleIncludeSold: _toggleIncludeSold,
                              includeSold: _includeSold,
                              hasAnyFilter: _hasAnyFilter(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_insightsLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: LinearProgressIndicator(minHeight: 2),
                        )
                      else if (_insights != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _HerdInsightsCards(
                            insights: _insights!,
                            onApply: _applyInsightFilter,
                          ),
                        ),
                      Selector<HerdController, ({int count, bool loading, bool hasMore})>(
                        selector: (_, c) => (
                          count: c.items.length,
                          loading: c.isRefreshing,
                          hasMore: c.hasMore,
                        ),
                        builder: (_, state, __) {
                          if (_isSpecialStatus()) {
                            return const SizedBox.shrink();
                          }
                          return _HerdPagerBar(
                            count: state.count,
                            isLoading: state.loading,
                            hasMore: state.hasMore,
                            onPrevious: _goToFirstPage,
                            onNext: _loadNextPage,
                          );
                        },
                      ),
                      const SizedBox(height: 6),
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxs,
                            ),
                            child: _buildGridContent(
                              items: state.items,
                              deceasedAnimals: deceasedAnimals,
                              deceasedLoading: deceasedLoading,
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _updateFilters(VoidCallback update) {
    setState(update);
    _applyFilters(refresh: true);
  }

  void _onSearchChanged(String value) {
    _queryPending = value.trim().toLowerCase();
    _searchDebouncer.run(() {
      _query = _queryPending;
      _applyFilters(refresh: true);
    });
  }

  bool _hasAnyFilter() {
    return _search.text.trim().isNotEmpty ||
        _includeSold ||
        _statusFilter != null ||
        _genderFilter != null ||
        _colorFilter != null ||
        _categoryFilter != null;
  }

  void _clearAllFilters() {
    _search.clear();
    _query = '';
    _queryPending = '';
    _updateFilters(() {
      _includeSold = false;
      _statusFilter = null;
      _genderFilter = null;
      _colorFilter = null;
      _categoryFilter = null;
    });
  }

  void _toggleIncludeSold() {
    _updateFilters(() => _includeSold = !_includeSold);
  }

  Future<void> _openFiltersSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            void applyAndRefresh(VoidCallback update) {
              setState(update);
              _applyFilters(refresh: true);
              sheetSetState(() {});
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtros',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Refine por status, cor e categoria.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile.adaptive(
                        value: _includeSold,
                        onChanged: (value) =>
                            applyAndRefresh(() => _includeSold = value),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Incluir vendidos'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _FilterSheetSection(
                        title: 'Status',
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            ChoiceChip(
                              label: const Text('Todos'),
                              selected: _statusFilter == null,
                              onSelected: (_) =>
                                  applyAndRefresh(() => _statusFilter = null),
                            ),
                            ..._statusOptions.map(
                              (status) => ChoiceChip(
                                label: Text(
                                  status == 'Saudável' ? 'Saudáveis' : status,
                                ),
                                selected: _statusFilter == status,
                                onSelected: (_) =>
                                    applyAndRefresh(() => _statusFilter = status),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FilterSheetSection(
                        title: 'Sexo',
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            ChoiceChip(
                              label: const Text('Todos'),
                              selected: _genderFilter == null,
                              onSelected: (_) =>
                                  applyAndRefresh(() => _genderFilter = null),
                            ),
                            ..._genderOptions.map(
                              (gender) => ChoiceChip(
                                label: Text(gender),
                                selected: _genderFilter == gender,
                                onSelected: (_) =>
                                    applyAndRefresh(() => _genderFilter = gender),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FilterSheetSection(
                        title: 'Cor',
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            ChoiceChip(
                              label: const Text('Todas'),
                              selected: _colorFilter == null,
                              onSelected: (_) =>
                                  applyAndRefresh(() => _colorFilter = null),
                            ),
                            ..._availableColors.map(
                              (color) => ChoiceChip(
                                label: Text(
                                  AnimalDisplayUtils.getColorName(color),
                                ),
                                selected: _colorFilter == color,
                                onSelected: (_) =>
                                    applyAndRefresh(() => _colorFilter = color),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FilterSheetSection(
                        title: 'Categoria',
                        child: Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            ChoiceChip(
                              label: const Text('Todas'),
                              selected: _categoryFilter == null,
                              onSelected: (_) =>
                                  applyAndRefresh(() => _categoryFilter = null),
                            ),
                            ..._availableCategories.map(
                              (category) => ChoiceChip(
                                label: Text(category),
                                selected: _categoryFilter == category,
                                onSelected: (_) => applyAndRefresh(
                                  () => _categoryFilter = category,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _hasAnyFilter()
                                  ? () {
                                      _clearAllFilters();
                                      sheetSetState(() {});
                                    }
                                  : null,
                              child: const Text('Limpar'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              child: const Text('Fechar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
        resolveOffspringStats: relations.offspringStatsOf,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    }

    if (_statusFilter == 'Vendido') {
      return FutureBuilder<List<Animal>>(
        future: _soldFuture,
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
            resolveOffspringStats: relations.offspringStatsOf,
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
      resolveOffspringStats: herdController.resolveOffspringStats,
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
    controller.setGender(_genderFilter);
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
    _loadInsights();
    _applyFilters(refresh: true);
  }

  void _onScroll() {
    // Paginação controlada por setas visuais no topo da listagem.
  }

  Future<void> _loadFilters() async {
    final herdRepository = context.read<HerdRepository>();
    final colors = await herdRepository.getAvailableColors();
    final categories = await herdRepository.getAvailableCategories();
    final normalizedCategories = List<String>.from(categories);
    if (!normalizedCategories.contains('Reprodutor')) {
      normalizedCategories.add('Reprodutor');
    }
    if (!normalizedCategories.contains('Venda')) {
      normalizedCategories.add('Venda');
    }
    if (!mounted) return;
    setState(() {
      _availableColors = colors;
      _availableCategories = normalizedCategories;
    });
  }

  Future<void> _loadInsights() async {
    if (!mounted) return;
    setState(() => _insightsLoading = true);
    try {
      final herdRepository = context.read<HerdRepository>();
      final results = await Future.wait<List<Animal>>([
        herdRepository.getFilteredAnimals(includeSold: false),
        herdRepository.getSoldAnimals(),
        herdRepository.getDeceasedAnimals(),
      ]);
      if (!mounted) return;
      final activeAnimals = results[0];
      final soldAnimals = results[1];
      final deceasedAnimals = results[2];
      setState(() {
        _insights = _HerdInsights.fromAnimals(
          active: activeAnimals,
          soldCount: soldAnimals.length,
          deceasedCount: deceasedAnimals.length,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _insights = null);
    } finally {
      if (mounted) setState(() => _insightsLoading = false);
    }
  }

  void _applyInsightFilter(_HerdInsightPreset preset) {
    _updateFilters(() {
      _search.clear();
      _query = '';
      _queryPending = '';
      _includeSold = false;
      _statusFilter = null;
      _genderFilter = null;
      _categoryFilter = null;

      switch (preset) {
        case _HerdInsightPreset.totalActive:
          break;
        case _HerdInsightPreset.healthy:
          _statusFilter = 'Saudável';
          break;
        case _HerdInsightPreset.inTreatment:
          _statusFilter = 'Em tratamento';
          break;
        case _HerdInsightPreset.injured:
          _statusFilter = 'Ferido';
          break;
        case _HerdInsightPreset.matrices:
          _categoryFilter = 'Matriz';
          _genderFilter = 'Fêmea';
          break;
        case _HerdInsightPreset.pregnant:
          _categoryFilter = 'Matriz';
          _genderFilter = 'Fêmea';
          break;
        case _HerdInsightPreset.maleReproducers:
          _categoryFilter = 'Reprodutor';
          _genderFilter = 'Macho';
          break;
        case _HerdInsightPreset.maleLambs:
          _categoryFilter = 'Borrego';
          _genderFilter = 'Macho';
          break;
        case _HerdInsightPreset.femaleLambs:
          _categoryFilter = 'Borrego';
          _genderFilter = 'Fêmea';
          break;
        case _HerdInsightPreset.sold:
          _includeSold = true;
          _statusFilter = 'Vendido';
          break;
        case _HerdInsightPreset.deceased:
          _statusFilter = 'Óbito';
          break;
      }
    });
  }

  bool _isSpecialStatus() {
    return _statusFilter == 'Óbito' || _statusFilter == 'Vendido';
  }

  void _goToFirstPage() {
    if (_isSpecialStatus()) return;
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.jumpTo(0);
    }
    context.read<HerdController>().refreshAll();
  }

  void _loadNextPage() {
    if (_isSpecialStatus()) return;
    context.read<HerdController>().loadMore();
  }

  @override
  bool get wantKeepAlive => true;
}

class _HerdPagerBar extends StatelessWidget {
  final int count;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _HerdPagerBar({
    required this.count,
    required this.isLoading,
    required this.hasMore,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = count > 50 && !isLoading;
    final canGoNext = hasMore && !isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          _PagerArrowButton(
            icon: Icons.chevron_left_rounded,
            enabled: canGoPrevious,
            onTap: onPrevious,
            tooltip: 'Voltar',
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              isLoading ? 'Atualizando...' : '$count registro(s) nesta página',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _PagerArrowButton(
            icon: Icons.chevron_right_rounded,
            enabled: canGoNext,
            onTap: onNext,
            tooltip: 'Próxima',
          ),
        ],
      ),
    );
  }
}

class _PagerArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;

  const _PagerArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: enabled ? onTap : null,
        radius: 18,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.white.withValues(alpha: 0.9)
                : AppColors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.borderNeutral.withValues(alpha: 0.65),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _FilterSheetSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSheetSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderNeutral.withValues(alpha: 0.8),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

enum _HerdInsightPreset {
  totalActive,
  healthy,
  inTreatment,
  injured,
  matrices,
  pregnant,
  maleReproducers,
  maleLambs,
  femaleLambs,
  sold,
  deceased,
}

class _HerdInsights {
  final int totalActive;
  final int healthy;
  final int inTreatment;
  final int injured;
  final int matrices;
  final int pregnant;
  final int maleReproducers;
  final int maleLambs;
  final int femaleLambs;
  final int sold;
  final int deceased;

  const _HerdInsights({
    required this.totalActive,
    required this.healthy,
    required this.inTreatment,
    required this.injured,
    required this.matrices,
    required this.pregnant,
    required this.maleReproducers,
    required this.maleLambs,
    required this.femaleLambs,
    required this.sold,
    required this.deceased,
  });

  static _HerdInsights fromAnimals({
    required List<Animal> active,
    required int soldCount,
    required int deceasedCount,
  }) {
    bool isFemale(Animal animal) {
      final normalized = animal.gender.toLowerCase().trim();
      return normalized.startsWith('f') ||
          normalized.contains('fêmea') ||
          normalized.contains('femea');
    }

    bool isMale(Animal animal) => !isFemale(animal);

    bool isLamb(Animal animal) {
      final category = animal.category.toLowerCase().trim();
      return category.contains('borrego') || category.contains('borrega');
    }

    bool isPregnant(Animal animal) {
      return animal.pregnant ||
          animal.reproductiveStatus.toLowerCase().contains('gest');
    }

    int countWhere(bool Function(Animal animal) test) =>
        active.where(test).length;

    return _HerdInsights(
      totalActive: active.length,
      healthy: countWhere((a) => a.status == 'Saudável'),
      inTreatment: countWhere((a) => a.status == 'Em tratamento'),
      injured: countWhere((a) => a.status == 'Ferido'),
      matrices: countWhere((a) => a.category.toLowerCase().contains('matriz')),
      pregnant: countWhere(isPregnant),
      maleReproducers: countWhere(
        (a) => isMale(a) && a.category.toLowerCase().contains('reprodutor'),
      ),
      maleLambs: countWhere((a) => isMale(a) && isLamb(a)),
      femaleLambs: countWhere((a) => isFemale(a) && isLamb(a)),
      sold: soldCount,
      deceased: deceasedCount,
    );
  }
}

class _HerdInsightsCards extends StatelessWidget {
  const _HerdInsightsCards({
    required this.insights,
    required this.onApply,
  });

  final _HerdInsights insights;
  final ValueChanged<_HerdInsightPreset> onApply;

  @override
  Widget build(BuildContext context) {
    final cards = <({
      String label,
      int value,
      IconData icon,
      _HerdInsightPreset preset,
      Color color,
    })>[
      (
        label: 'Ativos',
        value: insights.totalActive,
        icon: Icons.pets_outlined,
        preset: _HerdInsightPreset.totalActive,
        color: AppColors.primary,
      ),
      (
        label: 'Saudáveis',
        value: insights.healthy,
        icon: Icons.health_and_safety_outlined,
        preset: _HerdInsightPreset.healthy,
        color: AppColors.success,
      ),
      (
        label: 'Tratamento',
        value: insights.inTreatment,
        icon: Icons.healing_outlined,
        preset: _HerdInsightPreset.inTreatment,
        color: AppColors.warning,
      ),
      (
        label: 'Feridos',
        value: insights.injured,
        icon: Icons.warning_amber_rounded,
        preset: _HerdInsightPreset.injured,
        color: AppColors.error,
      ),
      (
        label: 'Matrizes',
        value: insights.matrices,
        icon: Icons.workspace_premium_outlined,
        preset: _HerdInsightPreset.matrices,
        color: AppColors.primarySupport,
      ),
      (
        label: 'Gestantes',
        value: insights.pregnant,
        icon: Icons.pregnant_woman_outlined,
        preset: _HerdInsightPreset.pregnant,
        color: AppColors.goldSoft,
      ),
      (
        label: 'Machos Reprod.',
        value: insights.maleReproducers,
        icon: Icons.male_outlined,
        preset: _HerdInsightPreset.maleReproducers,
        color: AppColors.primary,
      ),
      (
        label: 'Machos Borregos',
        value: insights.maleLambs,
        icon: Icons.male_rounded,
        preset: _HerdInsightPreset.maleLambs,
        color: AppColors.primary,
      ),
      (
        label: 'Fêmeas Borregas',
        value: insights.femaleLambs,
        icon: Icons.female_rounded,
        preset: _HerdInsightPreset.femaleLambs,
        color: AppColors.goldSoft,
      ),
      (
        label: 'Vendidos',
        value: insights.sold,
        icon: Icons.sell_outlined,
        preset: _HerdInsightPreset.sold,
        color: AppColors.primarySupport,
      ),
      (
        label: 'Óbitos',
        value: insights.deceased,
        icon: Icons.heart_broken_outlined,
        preset: _HerdInsightPreset.deceased,
        color: AppColors.error,
      ),
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: cards
          .map(
            (card) => _InsightCard(
              label: card.label,
              value: card.value,
              icon: card.icon,
              color: card.color,
              onTap: () => onApply(card.preset),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.26),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 15, color: color),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$value',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewAnimalPillButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewAnimalPillButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompact = ResponsiveUtils.isMobile(context);
    final buttonHeight = isCompact ? 40.0 : 42.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Ink(
          height: buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primarySupport.withValues(alpha: 0.94),
                AppColors.primary.withValues(alpha: 0.94),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: AppColors.white),
              const SizedBox(width: 6),
              Text(
                'Novo Animal',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
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

  ({int male, int female, int total}) offspringStatsOf(String id) {
    final children = offspringOf(id);
    int male = 0;
    int female = 0;
    for (final child in children) {
      final gender = child.gender.toLowerCase().trim();
      if (gender.startsWith('m')) male++;
      if (gender.startsWith('f')) female++;
    }
    return (male: male, female: female, total: children.length);
  }
}
