// lib/app/presentation/complete_dashboard_screen.dart
import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/dashboard_tab.dart';
import '../../features/herd/presentation/herd_tab.dart';
import '../../models/animal.dart';
import '../../shared/widgets/animal/animal_form.dart';
import '../../features/breeding/presentation/breeding_management_screen.dart';
import '../../features/breeding/presentation/matrix_selection_tab.dart';
import '../../features/feeding/presentation/feeding_screen.dart';
import '../../features/financial/presentation/financial_complete_screen.dart';
import '../../features/medication/presentation/medication_management_screen.dart';
import '../../features/management/presentation/management_hub_screen.dart';
import '../../features/management/presentation/widgets/management_module_card.dart';
import '../../features/more/presentation/more_hub_screen.dart';
import '../../features/more/presentation/widgets/more_module_card.dart';
import '../../features/notes/presentation/notes_management_screen.dart';
import '../../features/pharmacy/presentation/pharmacy_management_screen.dart';
import '../../features/reports/presentation/reports_hub_screen.dart';
import '../../features/system/presentation/history_screen.dart';
import '../../features/system/presentation/system_settings_screen.dart';
import '../../features/weight/presentation/weight_tracking_screen.dart';
import '../../shared/widgets/common/section_header.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../utils/responsive_utils.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/app_section_switcher.dart';
import 'widgets/app_shell_container.dart';
import 'widgets/app_shell_header.dart';
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
  String _selectedMoreModule = 'reports';
  bool _showMoreHub = true;

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
  ];

  static const List<AppSectionOption> _moreOptions = [
    AppSectionOption(
      key: 'reports',
      label: 'Relatórios',
      icon: Icons.analytics_outlined,
    ),
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

  static const List<MoreModuleItem> _moreHubModules = [
    MoreModuleItem(
      key: 'reports',
      title: 'Relatórios',
      description: 'Análises gerenciais, filtros avançados e exportação.',
      icon: Icons.analytics_outlined,
      isPrimary: true,
    ),
    MoreModuleItem(
      key: 'history',
      title: 'Histórico',
      description: 'Linha do tempo com eventos operacionais do sistema.',
      icon: Icons.history,
    ),
    MoreModuleItem(
      key: 'system',
      title: 'Sistema',
      description: 'Configurações, backup e manutenção da aplicação.',
      icon: Icons.settings_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _applyLegacyTab(widget.initialTab ?? 0);
  }

  void _goToTab(int legacyIndex) {
    if (!mounted) return;
    setState(() => _applyLegacyTab(legacyIndex));
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
        _selectedPrimaryTab = 4;
        _selectedMoreModule = 'reports';
        _showMoreHub = false;
        break;
      case 10:
        _selectedPrimaryTab = 3;
        break;
      case 11:
        _selectedPrimaryTab = 4;
        _selectedMoreModule = 'system';
        _showMoreHub = false;
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
          child: Column(
            children: [
              AppShellHeader(
                farmName: 'Fazenda São Petrônio',
                subtitle: 'Gestão de Ovinos e Caprinos',
                contextLabel: _resolveCurrentContextLabel(),
                onAddAnimal: () => _showAnimalForm(context),
                onOpenSectionMenu: _selectedPrimaryTab == 2
                    ? _openManagementMenu
                    : _selectedPrimaryTab == 4
                        ? _openMoreMenu
                        : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _selectedPrimaryTab,
        onSelected: (index) {
          setState(() {
            _selectedPrimaryTab = index;
            if (index == 2) {
              _showManagementHub = true;
            }
            if (index == 4) {
              _showMoreHub = true;
            }
          });
        },
        items: _primaryNavItems,
      ),
    );
  }

  String _resolveCurrentContextLabel() {
    switch (_selectedPrimaryTab) {
      case 0:
        return 'Painel Geral';
      case 1:
        return 'Rebanho';
      case 2:
        if (_showManagementHub) return 'Manejo';
        return _managementOptions
            .firstWhere((option) => option.key == _selectedManagementModule)
            .label;
      case 3:
        return 'Financeiro';
      case 4:
        if (_showMoreHub) return 'Mais';
        return _moreOptions
            .firstWhere((option) => option.key == _selectedMoreModule)
            .label;
      default:
        return 'Painel';
    }
  }

  Widget _buildPrimaryContent() {
    switch (_selectedPrimaryTab) {
      case 0:
        return DashboardTab(onGoToTab: _goToTab);
      case 1:
        return const HerdTab();
      case 2:
        return _buildManagementArea();
      case 3:
        return const FinancialCompleteScreen();
      case 4:
        return _buildMoreArea();
      default:
        return DashboardTab(onGoToTab: _goToTab);
    }
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
    if (_showMoreHub) {
      return MoreHubScreen(
        modules: _moreHubModules,
        selectedModuleKey: _selectedMoreModule,
        onOpenModule: (moduleKey) {
          setState(() {
            _selectedMoreModule = moduleKey;
            _showMoreHub = false;
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
            title: 'Mais',
            subtitle:
                'Módulo ativo: ${_moreOptions.firstWhere((option) => option.key == _selectedMoreModule).label}',
            actionLabel: 'Voltar ao Hub',
            onActionTap: () {
              setState(() => _showMoreHub = true);
            },
          ),
        ),
        AppSectionSwitcher(
          options: _moreOptions,
          selectedKey: _selectedMoreModule,
          onChanged: (value) {
            setState(() {
              _selectedMoreModule = value;
              _showMoreHub = false;
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
    switch (_selectedManagementModule) {
      case 'feeding':
        return const FeedingScreen();
      case 'weight':
        return const WeightTrackingScreen();
      case 'breeding':
        return const BreedingManagementScreen();
      case 'matrices':
        return const MatrixSelectionTab();
      case 'vaccines':
        return const MedicationManagementScreen();
      case 'notes':
        return const NotesManagementScreen();
      case 'pharmacy':
        return const PharmacyManagementScreen();
      default:
        return const FeedingScreen();
    }
  }

  Widget _buildMoreModule() {
    switch (_selectedMoreModule) {
      case 'reports':
        return const ReportsHubScreen();
      case 'history':
        return const HistoryScreen();
      case 'system':
        return const SystemSettingsScreen();
      default:
        return const ReportsHubScreen();
    }
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
      _showMoreHub = false;
    });
  }

  void _showAnimalForm(BuildContext context, {Animal? animal}) {
    showDialog(
      context: context,
      builder: (context) => AnimalFormDialog(animal: animal),
    );
  }
}
