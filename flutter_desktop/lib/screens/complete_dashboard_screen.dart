import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../widgets/stats_card.dart';
import '../widgets/animal_card.dart';
import '../widgets/animal_form.dart';
import '../widgets/breeding_management_screen.dart';
import '../widgets/weight_tracking_screen.dart';
import '../widgets/notes_management_screen.dart';
import '../widgets/reports_screen.dart';
import '../widgets/financial_management_screen.dart';
import '../widgets/system_settings_screen.dart';

class CompleteDashboardScreen extends StatefulWidget {
  const CompleteDashboardScreen({super.key});

  @override
  State<CompleteDashboardScreen> createState() => _CompleteDashboardScreenState();
}

class _CompleteDashboardScreenState extends State<CompleteDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  final List<TabData> _tabs = [
    TabData(
      title: 'Dashboard',
      icon: Icons.home,
      label: 'Dashboard',
    ),
    TabData(
      title: 'Reprodução',
      icon: Icons.favorite,
      label: 'Reprodução',
    ),
    TabData(
      title: 'Peso & Crescimento',
      icon: Icons.monitor_weight,
      label: 'Peso',
    ),
    TabData(
      title: 'Anotações',
      icon: Icons.note_alt,
      label: 'Anotações',
    ),
    TabData(
      title: 'Relatórios',
      icon: Icons.analytics,
      label: 'Relatórios',
    ),
    TabData(
      title: 'Financeiro',
      icon: Icons.attach_money,
      label: 'Financeiro',
    ),
    TabData(
      title: 'Sistema',
      icon: Icons.settings,
      label: 'Sistema',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
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
                  _buildDashboardTab(),
                  const BreedingManagementScreen(),
                  const WeightTrackingScreen(),
                  const NotesManagementScreen(),
                  const ReportsScreen(),
                  const FinancialManagementScreen(),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🐑', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.agriculture,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  const Text('🐐', style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BEGO Agritech',
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
            // Status and Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offline Ready',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
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
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        tabs: _tabs.map((tab) {
          return Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, size: 20),
                const SizedBox(height: 4),
                Text(tab.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Consumer<AnimalService>(
        builder: (context, animalService, _) {
          if (animalService.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando dados...'),
                ],
              ),
            );
          }

          if (animalService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Modo Offline Ativo',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usando dados locais - ${animalService.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: animalService.loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Reconectar'),
                  ),
                ],
              ),
            );
          }

          final stats = animalService.stats;
          if (stats == null) {
            return const Center(child: Text('Nenhum dado disponível'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Overview
              _buildStatsGrid(stats),
              const SizedBox(height: 32),
              // Animals Grid
              _buildAnimalsSection(animalService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(stats) {
    final theme = Theme.of(context);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        StatsCard(
          title: 'Total de Animais',
          value: '${stats.totalAnimals}',
          icon: Icons.groups,
          trend: '+3 este mês',
          color: theme.colorScheme.primary,
        ),
        StatsCard(
          title: 'Animais Saudáveis',
          value: '${stats.healthy}',
          icon: Icons.favorite,
          trend: '${((stats.healthy / stats.totalAnimals) * 100).toStringAsFixed(0)}% do rebanho',
          color: theme.colorScheme.tertiary,
        ),
        StatsCard(
          title: 'Fêmeas Gestantes',
          value: '${stats.pregnant}',
          icon: Icons.child_care,
          trend: '${stats.birthsThisMonth} partos próximos',
          color: theme.colorScheme.secondary,
        ),
        StatsCard(
          title: 'Receita Mensal',
          value: 'R\$ ${stats.revenue.toStringAsFixed(2).replaceAll('.', ',')}',
          icon: Icons.trending_up,
          trend: '+12% vs. mês anterior',
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildAnimalsSection(AnimalService animalService) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Rebanho',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showAnimalForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Animal'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (animalService.animals.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
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
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: animalService.animals.length,
                itemBuilder: (context, index) {
                  return AnimalCard(
                    animal: animalService.animals[index],
                    onEdit: (animal) => _showAnimalForm(context, animal: animal),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAnimalForm(BuildContext context, {animal}) {
    showDialog(
      context: context,
      builder: (context) => AnimalFormDialog(animal: animal),
    );
  }
}

class TabData {
  final String title;
  final IconData icon;
  final String label;

  TabData({
    required this.title,
    required this.icon,
    required this.label,
  });
}