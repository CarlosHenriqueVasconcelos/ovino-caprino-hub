// lib/screens/complete_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/dashboard/dashboard_tab.dart';
import '../features/herd/herd_tab.dart';
import '../features/navigation/dashboard_tabs.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/animal_form.dart';
import '../widgets/breeding_management_screen.dart';
import '../widgets/feeding_screen.dart';
import '../widgets/financial_complete_screen.dart';
import '../widgets/medication_management_screen.dart';
import '../widgets/notes_management_screen.dart';
import '../widgets/pharmacy_management_screen.dart';
import '../widgets/reports_hub_screen.dart';
import '../widgets/system_settings_screen.dart';
import '../widgets/weight_tracking_screen.dart';

class CompleteDashboardScreen extends StatefulWidget {
  final int? initialTab;
  const CompleteDashboardScreen({super.key, this.initialTab});

  @override
  State<CompleteDashboardScreen> createState() =>
      _CompleteDashboardScreenState();
}

class _CompleteDashboardScreenState extends State<CompleteDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<TabData> _tabs = dashboardTabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
  }

  void _goToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.colorScheme.primary.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(theme),
            // Navigation Tabs
            _buildNavigation(theme),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  DashboardTab(onGoToTab: _goToTab),
                  const HerdTab(),
                  const FeedingScreen(),
                  const WeightTrackingScreen(),
                  const BreedingManagementScreen(),
                  const MedicationManagementScreen(),
                  const NotesManagementScreen(),
                  const PharmacyManagementScreen(),
                  const ReportsHubScreen(),
                  const FinancialCompleteScreen(),
                  const SystemSettingsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getPadding(context),
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.90),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo compacto
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🐑', style: TextStyle(fontSize: isMobile ? 14 : 16)),
                      const SizedBox(width: 2),
                      Icon(Icons.agriculture, color: Colors.white, size: isMobile ? 14 : 16),
                      const SizedBox(width: 2),
                      Text('🐐', style: TextStyle(fontSize: isMobile ? 14 : 16)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Título
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fazenda São Petrônio',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                          if (!isMobile)
                            Text(
                              'Gestão de Ovinos e Caprinos',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Botão adicionar
                    if (!isMobile)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                        ),
                        onPressed: () => _showAnimalForm(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Novo'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation(ThemeData theme) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Container(
      color: theme.cardColor.withOpacity(0.60),
      child: TabBar(
        controller: _tabController,
        isScrollable: isMobile || isTablet,
        tabAlignment: (isMobile || isTablet) ? TabAlignment.start : TabAlignment.fill,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600, 
          fontSize: isMobile ? 10 : (isTablet ? 11 : 12),
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal, 
          fontSize: isMobile ? 10 : (isTablet ? 11 : 12),
        ),
        tabs: _tabs
            .map(
              (tab) => Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon, size: ResponsiveUtils.getIconSize(context)),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(tab.label),
                  ],
                ),
              ),
            )
            .toList(),
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
