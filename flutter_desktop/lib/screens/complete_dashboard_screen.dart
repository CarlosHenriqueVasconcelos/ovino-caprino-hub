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
import '../widgets/vaccination_alerts.dart';
import '../widgets/vaccination_form.dart';
import '../widgets/medication_management_screen.dart';
import '../widgets/history_screen.dart';

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
      title: 'Vacinações e Medicamentos',
      icon: Icons.medication,
      label: 'Vacinas',
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
                  const MedicationManagementScreen(),
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
            const SizedBox.shrink(),
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

          final stats = animalService.stats;
          if (stats == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text('Carregando dados...'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => animalService.loadData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recarregar'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 32),
              // Vaccination Alerts
              const VaccinationAlerts(),
              const SizedBox(height: 32),
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
      crossAxisCount: 5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        StatsCard(
          title: 'Total de Animais',
          value: '${stats.totalAnimals}',
          icon: Icons.groups,
          trend: '+3 este mês',
          color: theme.colorScheme.primary,
        ),
        StatsCard(
          title: 'Machos Reprodutores',
          value: '${stats.maleReproducers}',
          icon: Icons.male,
          trend: 'Reprodutores ativos',
          color: Colors.blue,
        ),
        StatsCard(
          title: 'Machos Borrego',
          value: '${stats.maleLambs}',
          icon: Icons.child_care,
          trend: 'Em crescimento',
          color: Colors.lightBlue,
        ),
        StatsCard(
          title: 'Fêmeas Borregas',
          value: '${stats.femaleLambs}',
          icon: Icons.child_friendly,
          trend: 'Em crescimento',
          color: Colors.pink,
        ),
        StatsCard(
          title: 'Fêmeas Reprodutoras',
          value: '${stats.femaleReproducers}',
          icon: Icons.female,
          trend: 'Reprodução ativa',
          color: Colors.purple,
        ),
        StatsCard(
          title: 'Animais em Tratamento',
          value: '${stats.underTreatment}',
          icon: Icons.medical_services,
          trend: 'Necessita atenção',
          color: Colors.orange,
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

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    final animalService = Provider.of<AnimalService>(context, listen: false);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildActionCard(
                  title: 'Novo Animal',
                  icon: Icons.add,
                  color: theme.colorScheme.primary,
                  onTap: () => _showAnimalForm(context),
                ),
                _buildActionCard(
                  title: 'Agendar Vacinação',
                  icon: Icons.vaccines,
                  color: Colors.blue,
                  onTap: () => _showVaccinationForm(context),
                ),
                _buildActionCard(
                  title: 'Agendar Medicamento',
                  icon: Icons.medication,
                  color: Colors.teal,
                  onTap: () => _showMedicationForm(context),
                ),
                _buildActionCard(
                  title: 'Gerar Relatório',
                  icon: Icons.description,
                  color: Colors.purple,
                  onTap: () => _tabController.animateTo(5), // Reports tab
                ),
                _buildActionCard(
                  title: 'Ver Histórico',
                  icon: Icons.history,
                  color: Colors.orange,
                  onTap: () => _showHistory(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationAlerts(AnimalService animalService) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    // Simulate vaccination alerts (in real app, this would come from database)
    final alerts = animalService.animals
        .where((animal) => animal.lastVaccination != null)
        .where((animal) {
          final lastVacc = animal.lastVaccination!;
          final daysSince = now.difference(lastVacc).inDays;
          return daysSince > 90; // Alert if more than 90 days
        })
        .take(3)
        .toList();

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: theme.colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alertas de Vacinação',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: TextStyle(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...alerts.map((animal) {
              final daysSince = now.difference(animal.lastVaccination!).inDays;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${animal.code} - ${animal.name}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Última vacinação há $daysSince dias',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showVaccinationForm(context, animal: animal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      child: const Text('Vacinar'),
                    ),
                  ],
                ),
              );
            }).toList(),
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

  void _showVaccinationForm(BuildContext context, {animal}) {
    showDialog(
      context: context,
      builder: (context) => VaccinationFormDialog(animalId: animal?.id),
    );
  }

  void _showMedicationForm(BuildContext context) {
    // Navega para a aba de medicamentos
    _tabController.animateTo(3);
  }

  void _showHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
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