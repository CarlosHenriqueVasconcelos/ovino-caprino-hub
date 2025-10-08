// lib/screens/complete_dashboard_screen.dart
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
// Importar APENAS o widget para evitar conflito de nomes
import '../widgets/vaccination_alerts.dart' show VaccinationAlerts;
import '../widgets/vaccination_form.dart';
import '../widgets/medication_management_screen.dart';
import '../widgets/history_screen.dart';

class CompleteDashboardScreen extends StatefulWidget {
  const CompleteDashboardScreen({super.key});

  @override
  State<CompleteDashboardScreen> createState() =>
      _CompleteDashboardScreenState();
}

class _CompleteDashboardScreenState extends State<CompleteDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  // Busca fixa do rebanho (filtro em tempo real)
  final TextEditingController _herdSearchController = TextEditingController();
  String _herdSearchQuery = '';

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
    _herdSearchController.dispose();
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
                children: const [
                  _DashboardTabContent(),
                  BreedingManagementScreen(),
                  WeightTrackingScreen(),
                  MedicationManagementScreen(),
                  NotesManagementScreen(),
                  ReportsScreen(),
                  FinancialManagementScreen(),
                  SystemSettingsScreen(),
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
                children: const [
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
}

class _DashboardTabContent extends StatelessWidget {
  const _DashboardTabContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Consumer<AnimalService>(
        builder: (context, animalService, _) {
          if (animalService.isLoading) {
            // Mantém apenas estado de carregamento (sem botão "Recarregar")
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando dados...'),
                  ],
                ),
              ),
            );
          }

          final stats = animalService.stats;
          if (stats == null) {
            // Primeiro frame antes das stats: mesma UX de carregamento
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Preparando painel...'),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ações rápidas
              _QuickActions(),
              const SizedBox(height: 32),

              // Alertas (vacinações/medicações) — seu widget original
              const VaccinationAlerts(),
              const SizedBox(height: 32),

              // Estatísticas (mesmo layout com StatsCard)
              _StatsOverview(stats: stats),
              const SizedBox(height: 32),

              // Rebanho com barra de busca fixa + grid original de AnimalCard
              _HerdSection(),
            ],
          );
        },
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  const _StatsOverview({required this.stats});
  final dynamic stats;

  @override
  Widget build(BuildContext context) {
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
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = Provider.of<AnimalService>(context, listen: false);

    void showAnimalForm({animal}) {
      showDialog(
        context: context,
        builder: (context) => AnimalFormDialog(animal: animal),
      );
    }

    void showVaccinationForm({animal}) {
      showDialog(
        context: context,
        builder: (context) => VaccinationFormDialog(animalId: animal?.id),
      );
    }

    void showHistory() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HistoryScreen(),
        ),
      );
    }

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
                _ActionCard(
                  title: 'Novo Animal',
                  icon: Icons.add,
                  color: theme.colorScheme.primary,
                  onTap: () => showAnimalForm(),
                ),
                _ActionCard(
                  title: 'Agendar Vacinação',
                  icon: Icons.vaccines,
                  color: Colors.blue,
                  onTap: () => showVaccinationForm(),
                ),
                _ActionCard(
                  title: 'Agendar Medicamento',
                  icon: Icons.medication,
                  color: Colors.teal,
                  // OBS: se quiser trocar de aba programaticamente a partir daqui,
                  // faça via callback do pai usando TabController. Mantive sua lógica visual.
                  onTap: () {
                    // noop: abre aba de medicamentos se você preferir:
                    // DefaultTabController.of(context)?.animateTo(3);
                  },
                ),
                _ActionCard(
                  title: 'Gerar Relatório',
                  icon: Icons.description,
                  color: Colors.purple,
                  onTap: () {
                    // DefaultTabController.of(context)?.animateTo(5);
                  },
                ),
                _ActionCard(
                  title: 'Ver Histórico',
                  icon: Icons.history,
                  color: Colors.orange,
                  onTap: showHistory,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            Icon(icon, color: color, size: 24),
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
}

class _HerdSection extends StatefulWidget {
  @override
  State<_HerdSection> createState() => _HerdSectionState();
}

class _HerdSectionState extends State<_HerdSection> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AnimalService>(
      builder: (context, animalService, _) {
        final all = animalService.animals;
        final filtered = _filter(all, _query);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título e ações (mantém "Adicionar Animal"; troca “Buscar Animal” pela barra fixa)
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
                const SizedBox(height: 16),

                // Barra de busca fixa
                TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    labelText:
                        'Buscar por nome, código, categoria ou raça (filtra em tempo real)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _query = '';
                                _search.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = value.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 24),

                if (all.isEmpty)
                  _emptyState(theme)
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return AnimalCard(
                        animal: filtered[index],
                        onEdit: (animal) =>
                            _showAnimalForm(context, animal: animal),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _filter(List<dynamic> animals, String q) {
    if (q.isEmpty) return animals;
    return animals.where((animal) {
      final name = animal.name.toLowerCase();
      final code = animal.code.toLowerCase();
      final category = (animal.category).toLowerCase();
      final breed = animal.breed.toLowerCase();
      return name.contains(q) ||
          code.contains(q) ||
          category.contains(q) ||
          breed.contains(q);
    }).toList();
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.pets, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('Nenhum animal cadastrado',
              style: theme.textTheme.headlineSmall),
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
    // Mantém a experiência visual que você já tinha
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
