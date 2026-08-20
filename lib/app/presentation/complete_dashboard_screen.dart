// lib/app/presentation/complete_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/dashboard/presentation/dashboard_tab.dart';
import '../../features/herd/presentation/herd_tab.dart';
import '../../features/breeding/presentation/breeding_management_screen.dart';
import '../../features/breeding/presentation/matrix_selection_tab.dart';
import '../../features/feeding/presentation/feeding_screen.dart';
import '../../features/financial/presentation/financial_complete_screen.dart';
import '../../features/medication/presentation/medication_management_screen.dart';
import '../../features/management/presentation/management_hub_screen.dart';
import '../../features/management/presentation/widgets/management_module_card.dart';
import '../../features/notes/presentation/notes_management_screen.dart';
import '../../features/pharmacy/presentation/pharmacy_management_screen.dart';
import '../../features/reports/presentation/reports_hub_screen.dart';
import '../../features/system/presentation/history_screen.dart';
import '../../features/system/presentation/system_settings_screen.dart';
import '../../features/weight/presentation/weight_tracking_screen.dart';
import '../../services/sync_service.dart';
import '../../shared/widgets/common/section_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../utils/responsive_utils.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_section_switcher.dart';
import 'widgets/app_shell_container.dart';
import 'widgets/management_menu_sheet.dart';
import 'widgets/more_menu_sheet.dart';

class CompleteDashboardScreen extends StatefulWidget {
  final int? initialTab;
  const CompleteDashboardScreen({super.key, this.initialTab});

  @override
  State<CompleteDashboardScreen> createState() =>
      _CompleteDashboardScreenState();
}

class _CompleteDashboardScreenState extends State<CompleteDashboardScreen> {
  int _selectedPrimaryTab = 0;
  String _selectedManagementModule = 'feeding';
  bool _showManagementHub = true;
  String _selectedMoreModule = 'system';
  bool _financialTabVisited = false;
  final Set<int> _builtPrimaryTabs = <int>{};
  final Set<int> _builtManagementModules = <int>{};
  final Set<int> _builtMoreModules = <int>{};

  static const List<AppBottomNavItem> _primaryNavItems = [
    AppBottomNavItem(
      label: 'Início',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AppBottomNavItem(
      label: 'Rebanho',
      icon: Icons.pets_outlined,
      selectedIcon: Icons.pets,
    ),
    AppBottomNavItem(
      label: 'Manejo',
      icon: Icons.agriculture_outlined,
      selectedIcon: Icons.agriculture,
    ),
    AppBottomNavItem(
      label: 'Financeiro',
      icon: Icons.attach_money_outlined,
      selectedIcon: Icons.attach_money,
    ),
    AppBottomNavItem(
      label: 'Mais',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
    ),
  ];

  static const List<AppSectionOption> _managementOptions = [
    AppSectionOption(
      key: 'feeding',
      label: 'Alimentação',
      icon: Icons.agriculture,
    ),
    AppSectionOption(
      key: 'weight',
      label: 'Peso',
      icon: Icons.monitor_weight_outlined,
    ),
    AppSectionOption(
      key: 'breeding',
      label: 'Reprodução',
      icon: Icons.favorite_outline,
    ),
    AppSectionOption(
      key: 'matrices',
      label: 'Matrizes',
      icon: Icons.workspace_premium_outlined,
    ),
    AppSectionOption(
      key: 'vaccines',
      label: 'Vacinas',
      icon: Icons.vaccines_outlined,
    ),
    AppSectionOption(
      key: 'notes',
      label: 'Anotações',
      icon: Icons.note_alt_outlined,
    ),
    AppSectionOption(
      key: 'pharmacy',
      label: 'Farmácia',
      icon: Icons.local_pharmacy_outlined,
    ),
    AppSectionOption(
      key: 'reports',
      label: 'Relatórios',
      icon: Icons.analytics_outlined,
    ),
  ];

  static const List<ManagementModuleItem> _managementHubModules = [
    ManagementModuleItem(
      key: 'feeding',
      title: 'Alimentação',
      description: 'Controle de baias, rotina de fornecimento e dietas.',
      icon: Icons.agriculture,
      isPrimary: true,
    ),
    ManagementModuleItem(
      key: 'weight',
      title: 'Peso',
      description: 'Acompanhamento mensal, marcos e alertas de pesagem.',
      icon: Icons.monitor_weight_outlined,
      isPrimary: true,
    ),
    ManagementModuleItem(
      key: 'breeding',
      title: 'Reprodução',
      description: 'Fluxo reprodutivo, ciclos e monitoramento por etapa.',
      icon: Icons.favorite_outline,
      isPrimary: true,
    ),
    ManagementModuleItem(
      key: 'matrices',
      title: 'Matrizes',
      description: 'Seleção técnica e avaliação de candidatas.',
      icon: Icons.workspace_premium_outlined,
      isPrimary: true,
    ),
    ManagementModuleItem(
      key: 'vaccines',
      title: 'Vacinas',
      description: 'Agenda clínica de vacinas e medicações.',
      icon: Icons.vaccines_outlined,
    ),
    ManagementModuleItem(
      key: 'notes',
      title: 'Anotações',
      description: 'Registros operacionais e lembretes do manejo.',
      icon: Icons.note_alt_outlined,
    ),
    ManagementModuleItem(
      key: 'pharmacy',
      title: 'Farmácia',
      description: 'Estoque de medicamentos e validade dos insumos.',
      icon: Icons.local_pharmacy_outlined,
    ),
    ManagementModuleItem(
      key: 'reports',
      title: 'Relatórios',
      description: 'Visão analítica consolidada dos dados da fazenda.',
      icon: Icons.analytics_outlined,
    ),
  ];

  static const List<AppSectionOption> _moreOptions = [
    AppSectionOption(
      key: 'history',
      label: 'Histórico',
      icon: Icons.history,
    ),
    AppSectionOption(
      key: 'system',
      label: 'Sistema',
      icon: Icons.settings_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _applyLegacyTab(widget.initialTab ?? 0);
    _markCurrentSelectionsAsBuilt();
    // Sync inicial ao abrir o dashboard (login ou sessão restaurada)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        await context.read<SyncService>().sync();
      });
    });
  }

  void _goToTab(int legacyIndex) {
    if (!mounted) return;
    setState(() {
      _applyLegacyTab(legacyIndex);
      _markCurrentSelectionsAsBuilt();
    });
  }

  void _applyLegacyTab(int legacyIndex) {
    switch (legacyIndex) {
      case 0:
        _selectedPrimaryTab = 0;
        break;
      case 1:
        _selectedPrimaryTab = 1;
        break;
      case 2:
        _selectedPrimaryTab = 2;
        _selectedManagementModule = 'feeding';
        _showManagementHub = false;
        break;
      case 3:
        _selectedPrimaryTab = 2;
        _selectedManagementModule = 'weight';
        _showManagementHub = false;
        break;
      case 4:
        _selectedPrimaryTab = 2;
        _selectedManagementModule = 'breeding';
        _showManagementHub = false;
        break;
      case 5:
        _selectedPrimaryTab = 2;
        _selectedManagementModule = 'matrices';
        _showManagementHub = false;
        break;
      case 6:
        _selectedPrimaryTab = 2;
        _selectedManagementModule = 'vaccines';
        _showManagementHub = false;
        break;
      case 7:
        _selectedPrimaryTab = 2;
        _selectedManagementModule = 'notes';
        _showManagementHub = false;
        break;
      case 8:
        _selectedPrimaryTab = 2;
        _selectedManagementModule = 'pharmacy';
        _showManagementHub = false;
        break;
      case 9:
        _selectedPrimaryTab = 2;
        _selectedManagementModule = 'reports';
        _showManagementHub = false;
        break;
      case 10:
        _selectedPrimaryTab = 3;
        _financialTabVisited = true;
        break;
      case 11:
        _selectedPrimaryTab = 4;
        _selectedMoreModule = 'system';
        break;
      default:
        _selectedPrimaryTab = 0;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shellHorizontalInset = ResponsiveUtils.getShellHorizontalInset(context);

    return Scaffold(
      body: AppShellContainer(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: shellHorizontalInset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.94),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xxl),
                ),
                border: Border.all(
                  color: AppColors.borderNeutral.withValues(alpha: 0.75),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xxl),
                ),
                child: _buildPrimaryContent(),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedPrimaryTab,
        onSelected: (index) {
          setState(() {
            _selectedPrimaryTab = index;
            _builtPrimaryTabs.add(index);
            if (index == 2) {
              _showManagementHub = true;
              _builtManagementModules
                  .add(_managementIndexForKey(_selectedManagementModule));
            }
            if (index == 3) {
              _financialTabVisited = true;
            }
            if (index == 4) {
              _selectedMoreModule = 'system';
              _builtMoreModules.add(_moreIndexForKey(_selectedMoreModule));
            }
          });
        },
        items: _primaryNavItems,
      ),
    );
  }

  // Índices fixos dos módulos de manejo e "mais" — usados pelo IndexedStack interno.
  static const _managementModuleKeys = [
    'feeding', 'weight', 'breeding', 'matrices', 'vaccines', 'notes', 'pharmacy', 'reports',
  ];
  static const _moreModuleKeys = ['history', 'system'];

  int _managementIndexForKey(String key) {
    return _managementModuleKeys
        .indexOf(key)
        .clamp(0, _managementModuleKeys.length - 1);
  }

  int _moreIndexForKey(String key) {
    return _moreModuleKeys.indexOf(key).clamp(0, _moreModuleKeys.length - 1);
  }

  void _markCurrentSelectionsAsBuilt() {
    _builtPrimaryTabs.add(_selectedPrimaryTab);
    _builtManagementModules.add(_managementIndexForKey(_selectedManagementModule));
    _builtMoreModules.add(_moreIndexForKey(_selectedMoreModule));
  }

  Widget _lazyStackChild({
    required int index,
    required Set<int> builtIndexes,
    required Widget child,
  }) {
    if (!builtIndexes.contains(index)) return const SizedBox.shrink();
    return child;
  }

  Widget _buildPrimaryContent() {
    // IndexedStack com lazy mount: mantém estado dos tabs já visitados,
    // sem montar todos os módulos no primeiro frame.
    return IndexedStack(
      index: _selectedPrimaryTab,
      children: [
        _lazyStackChild(
          index: 0,
          builtIndexes: _builtPrimaryTabs,
          child: DashboardTab(onGoToTab: _goToTab),
        ),
        _lazyStackChild(
          index: 1,
          builtIndexes: _builtPrimaryTabs,
          child: const HerdTab(),
        ),
        _lazyStackChild(
          index: 2,
          builtIndexes: _builtPrimaryTabs,
          child: _buildManagementArea(),
        ),
        _lazyStackChild(
          index: 3,
          builtIndexes: _builtPrimaryTabs,
          child: _financialTabVisited
              ? const FinancialCompleteScreen()
              : const SizedBox.shrink(),
        ),
        _lazyStackChild(
          index: 4,
          builtIndexes: _builtPrimaryTabs,
          child: _buildMoreArea(),
        ),
      ],
    );
  }

  Widget _buildManagementArea() {
    if (_showManagementHub) {
      return ManagementHubScreen(
        modules: _managementHubModules,
        selectedModuleKey: _selectedManagementModule,
        onOpenModule: (moduleKey) {
          setState(() {
            _selectedManagementModule = moduleKey;
            _showManagementHub = false;
            _builtManagementModules.add(_managementIndexForKey(moduleKey));
          });
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: SectionHeader(
            title: 'Manejo',
            subtitle:
                'Módulo ativo: ${_managementOptions.firstWhere((option) => option.key == _selectedManagementModule).label}',
            actionLabel: 'Voltar ao Hub',
            onActionTap: () {
              setState(() => _showManagementHub = true);
            },
          ),
        ),
        AppSectionSwitcher(
          options: _managementOptions,
          selectedKey: _selectedManagementModule,
          onChanged: (value) {
            setState(() {
              _selectedManagementModule = value;
              _showManagementHub = false;
              _builtManagementModules.add(_managementIndexForKey(value));
            });
          },
          onOpenMenu: _openManagementMenu,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: _buildManagementModule(),
        ),
      ],
    );
  }

  Widget _buildMoreArea() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: SectionHeader(
            title: 'Mais',
            subtitle:
                'Módulo ativo: ${_moreOptions.firstWhere((option) => option.key == _selectedMoreModule).label}',
          ),
        ),
        AppSectionSwitcher(
          options: _moreOptions,
          selectedKey: _selectedMoreModule,
          onChanged: (value) {
            setState(() {
              _selectedMoreModule = value;
              _builtMoreModules.add(_moreIndexForKey(value));
            });
          },
          onOpenMenu: _openMoreMenu,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: _buildMoreModule(),
        ),
      ],
    );
  }

  Widget _buildManagementModule() {
    final idx = _managementIndexForKey(_selectedManagementModule);
    return IndexedStack(
      index: idx,
      children: [
        _lazyStackChild(
          index: 0,
          builtIndexes: _builtManagementModules,
          child: const FeedingScreen(),
        ),
        _lazyStackChild(
          index: 1,
          builtIndexes: _builtManagementModules,
          child: const WeightTrackingScreen(),
        ),
        _lazyStackChild(
          index: 2,
          builtIndexes: _builtManagementModules,
          child: const BreedingManagementScreen(),
        ),
        _lazyStackChild(
          index: 3,
          builtIndexes: _builtManagementModules,
          child: const MatrixSelectionTab(),
        ),
        _lazyStackChild(
          index: 4,
          builtIndexes: _builtManagementModules,
          child: const MedicationManagementScreen(),
        ),
        _lazyStackChild(
          index: 5,
          builtIndexes: _builtManagementModules,
          child: const NotesManagementScreen(),
        ),
        _lazyStackChild(
          index: 6,
          builtIndexes: _builtManagementModules,
          child: const PharmacyManagementScreen(),
        ),
        _lazyStackChild(
          index: 7,
          builtIndexes: _builtManagementModules,
          child: const ReportsHubScreen(),
        ),
      ],
    );
  }

  Widget _buildMoreModule() {
    final idx = _moreIndexForKey(_selectedMoreModule);
    return IndexedStack(
      index: idx,
      children: [
        _lazyStackChild(
          index: 0,
          builtIndexes: _builtMoreModules,
          child: const HistoryScreen(),
        ),
        _lazyStackChild(
          index: 1,
          builtIndexes: _builtMoreModules,
          child: const SystemSettingsScreen(),
        ),
      ],
    );
  }

  Future<void> _openManagementMenu() async {
    final selected = await ManagementMenuSheet.show(
      context,
      options: _managementOptions,
      selectedKey: _selectedManagementModule,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _selectedPrimaryTab = 2;
      _selectedManagementModule = selected;
      _showManagementHub = false;
      _builtPrimaryTabs.add(2);
      _builtManagementModules.add(_managementIndexForKey(selected));
    });
  }

  Future<void> _openMoreMenu() async {
    final selected = await MoreMenuSheet.show(
      context,
      options: _moreOptions,
      selectedKey: _selectedMoreModule,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _selectedPrimaryTab = 4;
      _selectedMoreModule = selected;
      _builtPrimaryTabs.add(4);
      _builtMoreModules.add(_moreIndexForKey(selected));
    });
  }
}
