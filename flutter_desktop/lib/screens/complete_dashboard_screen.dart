// lib/screens/complete_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/dashboard/dashboard_tab.dart';
import '../features/herd/herd_tab.dart';
import '../features/navigation/dashboard_tabs.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';
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
    return Container(
      padding: const EdgeInsets.all(24),
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
        child: Row(
          children: [
            // Logo and Title
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🐑', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 4),
                  Icon(Icons.agriculture, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text('🐐', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fazenda São Petronio',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Sistema Completo de Gestão para Ovinocultura e Caprinocultura',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Botão para recarregar os dados
            OutlinedButton.icon(
              onPressed: () => context.read<AnimalService>().loadData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Recarregar dados'),
            ),
            const SizedBox(width: 12),

            ElevatedButton.icon(
              onPressed: () => _showAnimalForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Novo Animal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation(ThemeData theme) {
    return Container(
      color: theme.cardColor.withOpacity(0.60),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        tabAlignment: TabAlignment.fill,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        tabs: _tabs
            .map(
              (tab) => Tab(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon, size: 20),
                    const SizedBox(height: 4),
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
