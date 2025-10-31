// lib/screens/complete_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async' show StreamSubscription;
import '../services/data_refresh_bus.dart';

import '../services/animal_service.dart';
import '../data/animal_repository.dart';
import '../widgets/stats_card.dart';
import '../widgets/animal_card.dart';
import '../models/animal.dart';
import '../utils/animal_display_utils.dart';
import '../widgets/animal_form.dart';
import '../widgets/breeding_management_screen.dart';
import '../widgets/weight_tracking_screen.dart';
import '../widgets/notes_management_screen.dart';
import '../widgets/reports_hub_screen.dart';
import '../widgets/financial_complete_screen.dart';
import '../widgets/system_settings_screen.dart';
// Importar APENAS o widget para evitar conflito de nomes
import '../widgets/vaccination_alerts.dart' show VaccinationAlerts;
import '../widgets/vaccination_form.dart';
import '../widgets/medication_management_screen.dart';
import '../widgets/history_screen.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';
import '../services/animal_delete_cascade.dart';
import '../widgets/repro_alerts_card.dart';
import '../widgets/feeding_screen.dart';
import '../widgets/weight_alerts_card.dart';
import '../widgets/pharmacy_management_screen.dart';

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
      title: 'Rebanho',
      icon: Icons.groups,
      label: 'Rebanho',
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
      title: 'Farmácia',
      icon: Icons.local_pharmacy,
      label: 'Farmácia',
    ),
    TabData(
      title: 'Anotações',
      icon: Icons.note_alt,
      label: 'Anotações',
    ),
    TabData(
      title: 'Alimentação',
      icon: Icons.agriculture,
      label: 'Alimentação',
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
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTab ?? 0,
    );
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  void _goToTab(int index) {
    _tabController.animateTo(index);
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
                children: [
                  _DashboardTabContent(onGoToTab: _goToTab),
                  const _HerdTabContent(),
                  const BreedingManagementScreen(),
                  const WeightTrackingScreen(),
                  const MedicationManagementScreen(),
                  const PharmacyManagementScreen(),
                  const NotesManagementScreen(),
                  const FeedingScreen(),
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

            // ⬇️ Botão para recarregar os dados
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
  final void Function(int) onGoToTab;
  const _DashboardTabContent({required this.onGoToTab});

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
              _QuickActions(onGoToTab: onGoToTab),
              const SizedBox(height: 32),

              // Alertas (vacinações/medicações) — seu widget original
              VaccinationAlerts(onGoToVaccinations: () => onGoToTab(4)),
              const SizedBox(height: 16),

              // NOVO: Alertas de Reprodução (separações, ultrassons, partos)
              const ReproAlertsCard(daysAhead: 30),
              const SizedBox(height: 16),

              // NOVO: Alertas de Pesagem
              const WeightAlertsCard(),
              const SizedBox(height: 32),

              // Estatísticas (mesmo layout com StatsCard)
              _StatsOverview(stats: stats),
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
        StatsCard(
          title: 'Fêmeas Gestantes',
          value: '${stats.pregnant}',
          icon: Icons.pregnant_woman,
          color: Colors.pinkAccent,
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final void Function(int) onGoToTab;
  const _QuickActions({required this.onGoToTab});

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

    void showMedicationDialog() {
      showDialog(
        context: context,
        builder: (context) => _MedicationFormDialog(
          onSaved: () {
            // Recarregar dados se necessário
            animalService.loadData();
          },
        ),
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
                  onTap: showMedicationDialog,
                ),
                _ActionCard(
                  title: 'Gerar Relatório',
                  icon: Icons.description,
                  color: Colors.purple,
                  onTap: () => onGoToTab(8),
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

// Nova aba dedicada ao Rebanho
class _HerdTabContent extends StatelessWidget {
  const _HerdTabContent();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: _HerdSection(),
    );
  }
}

class _HerdSection extends StatefulWidget {
  const _HerdSection();

  @override
  State<_HerdSection> createState() => _HerdSectionState();
}

class _HerdSectionState extends State<_HerdSection> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  bool _includeSold = false;
  String? _statusFilter; // null = todos; 'Saudável' | 'Em tratamento' | 'Vendido' | 'Óbito'
  String? _colorFilter;
  String? _categoryFilter;

  StreamSubscription<String>? _busSub;

  @override
  void initState() {
    super.initState();
    // Recarrega automaticamente quando hooks mexerem no banco
    _busSub = DataRefreshBus.stream.listen((_) {
      if (!mounted) return;
      // Atualiza lista viva e refaz FutureBuilders de vendidos/óbitos
      context.read<AnimalService>().loadData();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _busSub?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AnimalService>(
      builder: (context, animalService, _) {
        final all = animalService.animals;
        final baseList = (() {
          if (_statusFilter == 'Vendido') {
            return all.where((a) => a.status == 'Vendido').toList();
          } else if (_statusFilter == 'Em tratamento') {
            return all.where((a) => a.status == 'Em tratamento').toList();
          } else if (_statusFilter == 'Saudável') {
            return all.where((a) => a.status == 'Saudável').toList();
          } else if (_statusFilter == 'Óbito') {
            // Lista especial renderizada abaixo via FutureBuilder
            return <dynamic>[];
          } else {
            // Sem status específico: volta a valer o toggle "Incluir vendidos"
            return _includeSold
                ? all
                : all.where((a) => a.status == null || a.status != 'Vendido').toList();
          }
        })();
        
        // Aplicar filtros de cor e categoria
        var filtered = baseList.where((a) {
          if (_colorFilter != null && a.nameColor != _colorFilter) return false;
          if (_categoryFilter != null && a.category != _categoryFilter) return false;
          return true;
        }).toList();
        
        // Aplicar busca por texto
        filtered = _filter(filtered, _query);
        
        // Ordenar por cor e depois por número
        filtered.sort((a, b) {
          final colorCompare = a.nameColor.compareTo(b.nameColor);
          if (colorCompare != 0) return colorCompare;
          
          // Extrair números do código para ordenação numérica
          final numA = int.tryParse(a.code.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final numB = int.tryParse(b.code.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          return numA.compareTo(numB);
        });
        
        // Obter listas únicas de cores e categorias
        final availableColors = all.map((a) => a.nameColor).toSet().toList()..sort();
        final availableCategories = all.map((a) => a.category).toSet().toList()..sort();

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
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Incluir vendidos'),
                      selected: _includeSold,
                      onSelected: (v) => setState(() => _includeSold = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    ChoiceChip(
                      label: const Text('Saudáveis'),
                      selected: _statusFilter == 'Saudável',
                      onSelected: (_) => setState(() => _statusFilter = 'Saudável'),
                    ),
                    ChoiceChip(
                      label: const Text('Em tratamento'),
                      selected: _statusFilter == 'Em tratamento',
                      onSelected: (_) => setState(() => _statusFilter = 'Em tratamento'),
                    ),
                    ChoiceChip(
                      label: const Text('Vendidos'),
                      selected: _statusFilter == 'Vendido',
                      onSelected: (_) => setState(() => _statusFilter = 'Vendido'),
                    ),
                    ChoiceChip(
                      label: const Text('Óbito'),
                      selected: _statusFilter == 'Óbito',
                      onSelected: (_) => setState(() => _statusFilter = 'Óbito'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Filtro de Cor
                Text('Filtrar por Cor:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _colorFilter == null,
                      onSelected: (_) => setState(() => _colorFilter = null),
                    ),
                    ...availableColors.map((color) => ChoiceChip(
                      label: Text(color),
                      selected: _colorFilter == color,
                      onSelected: (_) => setState(() => _colorFilter = color),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Filtro de Categoria
                Text('Filtrar por Categoria:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _categoryFilter == null,
                      onSelected: (_) => setState(() => _categoryFilter = null),
                    ),
                    ...availableCategories.map((category) => ChoiceChip(
                      label: Text(category),
                      selected: _categoryFilter == category,
                      onSelected: (_) => setState(() => _categoryFilter = category),
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                if (all.isEmpty)
                  _emptyState(theme)
                else
                  // Quando filtro = Óbito, carrega da tabela deceased_animals
                  if (_statusFilter == 'Óbito')
                    FutureBuilder<List<Animal>>(
                      future: (() async {
                        final db = await DatabaseService.database;
                        final rows = await db.query(
                          'deceased_animals',
                          orderBy: 'date(death_date) DESC',
                        );
                        return rows.map((m) {
                          final map = Map<String, dynamic>.from(m);
                          map['status'] = 'Óbito';
                          map['last_vaccination'] = null;
                          map['expected_delivery'] = null;
                          map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
                          map['updated_at'] = map['updated_at'] ?? DateTime.now().toIso8601String();
                          return Animal.fromMap(map);
                        }).toList();
                      })(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final list = snapshot.data!;
                        if (list.isEmpty) {
                          return _emptyState(theme);
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                          return AnimalCard(
                            animal: list[index],
                            repository: context.read<AnimalRepository>(),
                            onEdit: null,
                            onDeleteCascade: null,
                          );
                          },
                        );
                      },
                    )
                  // Quando filtro = Vendido, carrega da tabela sold_animals
                  else if (_statusFilter == 'Vendido')
                    FutureBuilder<List<Animal>>(
                      future: (() async {
                        final db = await DatabaseService.database;
                        final rows = await db.query(
                          'sold_animals',
                          orderBy: 'date(sale_date) DESC',
                        );
                        return rows.map((m) {
                          final map = Map<String, dynamic>.from(m);
                          // Adaptar para o shape do modelo Animal exibível
                          map['status'] = 'Vendido';
                          map['last_vaccination'] = null;
                          map['expected_delivery'] = null;
                          map['health_issue'] = null;
                          map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
                          map['updated_at'] = map['updated_at'] ?? DateTime.now().toIso8601String();
                          return Animal.fromMap(map);
                        }).toList();
                      })(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final list = snapshot.data!;
                        if (list.isEmpty) {
                          return _emptyState(theme);
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                          return AnimalCard(
                            animal: list[index],
                            repository: context.read<AnimalRepository>(),
                            onEdit: null,
                            onDeleteCascade: null,
                          );
                          },
                        );
                      },
                    )
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
                          repository: context.read<AnimalRepository>(),
                          onEdit: (animal) =>
                              _showAnimalForm(context, animal: animal),
                          onDeleteCascade: (animal) async {
                            await AnimalDeleteCascade.delete(animal.id);
                            final svc = context.read<AnimalService>();
                            await svc.loadData();        // recarrega do banco
                            if (mounted) setState(() {}); // atualiza a UI
                          },
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
      // Busca exata - retorna apenas se algum campo for exatamente igual ao termo buscado
      return name == q ||
          code == q ||
          category == q ||
          breed == q;
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

// Dialog para agendar medicamento
class _MedicationFormDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const _MedicationFormDialog({required this.onSaved});

  @override
  State<_MedicationFormDialog> createState() => _MedicationFormDialogState();
}

class _MedicationFormDialogState extends State<_MedicationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _scheduledDate = DateTime.now();
  String? _selectedAnimalId;

  @override
  Widget build(BuildContext context) {
    final animalService = Provider.of<AnimalService>(context);

    return AlertDialog(
      title: const Text('Agendar Medicamento'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animal
                DropdownButtonFormField<String>(
                  value: _selectedAnimalId,
                  decoration: const InputDecoration(
                    labelText: 'Animal *',
                    border: OutlineInputBorder(),
                  ),
                  items: animalService.animals.map((animal) {
                    return DropdownMenuItem(
                      value: animal.id,
                      child: AnimalDisplayUtils.buildAnimalDropdownItem(animal),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedAnimalId = value);
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Selecione um animal';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nome do medicamento
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Medicamento *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo obrigatório';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dosagem
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosagem',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 5ml, 2 comprimidos',
                  ),
                ),
                const SizedBox(height: 16),

                // Data
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _scheduledDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data Agendada *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_scheduledDate.day.toString().padLeft(2, '0')}/${_scheduledDate.month.toString().padLeft(2, '0')}/${_scheduledDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Veterinário
                TextFormField(
                  controller: _veterinarianController,
                  decoration: const InputDecoration(
                    labelText: 'Veterinário',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Observações
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Agendar'),
        ),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate() || _selectedAnimalId == null) return;

    try {
      final now = DateTime.now().toIso8601String();

      final medication = {
        'id': const Uuid().v4(),
        'animal_id': _selectedAnimalId!,
        'medication_name': _nameController.text,
        'date': _scheduledDate.toIso8601String().split('T')[0],
        'next_date': _scheduledDate
            .add(const Duration(days: 30))
            .toIso8601String()
            .split('T')[0],
        'dosage': _dosageController.text.isEmpty ? null : _dosageController.text,
        'veterinarian': _veterinarianController.text.isEmpty
            ? null
            : _veterinarianController.text,
        'notes':
            _notesController.text.isEmpty ? null : _notesController.text,
        'created_at': now,
      };

      await DatabaseService.createMedication(medication);

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Medicamento agendado com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
