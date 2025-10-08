import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/animal_service.dart';
import '../services/database_service.dart';
import '../models/animal.dart';
import '../widgets/stats_card.dart';
import '../widgets/animal_card.dart';
import '../widgets/alert_card.dart';
import 'management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToManagement(BuildContext context, int initialTab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManagementScreen(initialTab: initialTab),
      ),
    );
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature em desenvolvimento')),
    );
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
              theme.colorScheme.primary.withOpacity(0.10),
              theme.colorScheme.primary.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor.withOpacity(0.85),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
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
                      child: Icon(
                        Icons.groups,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
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
                            ),
                          ),
                          Text(
                            'Sistema de Gestão Pecuária',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox.shrink(),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _comingSoon(context, 'Cadastro de animal'),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Animal'),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Consumer<AnimalService>(
                  builder: (context, animalService, _) {
                    final stats = animalService.stats;
                    if (stats == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Overview
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
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
                              trend: '93% do rebanho',
                              color: theme.colorScheme.tertiary,
                            ),
                            StatsCard(
                              title: 'Fêmeas Gestantes',
                              value: '${stats.pregnant}',
                              icon: Icons.calendar_today,
                              trend: '2 partos próximos',
                              color: theme.colorScheme.secondary,
                            ),
                            StatsCard(
                              title: 'Receita Mensal',
                              value: NumberFormat.currency(
                                locale: 'pt_BR',
                                symbol: 'R\$ ',
                              ).format(stats.revenue),
                              icon: Icons.trending_up,
                              trend: '+12% vs. mês anterior',
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Alerts & Quick Actions
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Alerts
                            Expanded(
                              flex: 2,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: FutureBuilder<Map<String, dynamic>>(
                                    future: _loadAlerts(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(child: CircularProgressIndicator());
                                      }

                                      final alerts = snapshot.data!;
                                      final vaccinations = alerts['vaccinations'] as List<Map<String, dynamic>>;
                                      final medications = alerts['medications'] as List<Map<String, dynamic>>;
                                      final animals = alerts['animals'] as List<Map<String, dynamic>>;

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Alertas Importantes',
                                                style: theme.textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.warning,
                                                color: theme.colorScheme.error,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          if (vaccinations.isNotEmpty)
                                            AlertCard(
                                              title: 'Vacinações Pendentes',
                                              description: '${vaccinations.length} vacinação(ões) agendada(s)',
                                              icon: Icons.vaccines,
                                              color: theme.colorScheme.error,
                                              onTap: () => _goToManagement(context, 0),
                                            ),
                                          if (vaccinations.isNotEmpty && medications.isNotEmpty)
                                            const SizedBox(height: 12),
                                          if (medications.isNotEmpty)
                                            AlertCard(
                                              title: 'Medicamentos Pendentes',
                                              description: '${medications.length} medicamento(s) a aplicar',
                                              icon: Icons.medical_services,
                                              color: theme.colorScheme.error,
                                              onTap: () => _goToManagement(context, 0),
                                            ),
                                          if ((vaccinations.isNotEmpty || medications.isNotEmpty) && _hasUpcomingBirths(animals))
                                            const SizedBox(height: 12),
                                          if (_hasUpcomingBirths(animals))
                                            AlertCard(
                                              title: 'Partos Previstos',
                                              description: _getUpcomingBirthsText(animals),
                                              icon: Icons.child_care,
                                              color: theme.colorScheme.tertiary,
                                              onTap: () => _goToManagement(context, 1),
                                            ),
                                          if (vaccinations.isEmpty && medications.isEmpty && !_hasUpcomingBirths(animals))
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(24),
                                                child: Text(
                                                  'Nenhum alerta no momento',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Quick Actions
                            Expanded(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ações Rápidas',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _goToManagement(context, 1),
                                          icon: const Icon(Icons.add),
                                          label:
                                              const Text('Registrar Nascimento'),
                                          style: OutlinedButton.styleFrom(
                                            alignment: Alignment.centerLeft,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _goToManagement(context, 0),
                                          icon: const Icon(Icons.calendar_today),
                                          label:
                                              const Text('Agendar Vacinação'),
                                          style: OutlinedButton.styleFrom(
                                            alignment: Alignment.centerLeft,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _comingSoon(
                                              context, 'Movimentar Animais'),
                                          icon: const Icon(Icons.location_on),
                                          label: const Text('Movimentar Animais'),
                                          style: OutlinedButton.styleFrom(
                                            alignment: Alignment.centerLeft,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () => _comingSoon(
                                              context, 'Relatório Mensal'),
                                          icon: const Icon(Icons.trending_up),
                                          label: const Text('Relatório Mensal'),
                                          style: OutlinedButton.styleFrom(
                                            alignment: Alignment.centerLeft,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Animals Grid
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
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
                                        SizedBox(
                                          width: 300,
                                          child: TextField(
                                            controller: _searchController,
                                            decoration: InputDecoration(
                                              hintText: 'Buscar animal...',
                                              prefixIcon: const Icon(Icons.search),
                                              suffixIcon: _searchQuery.isNotEmpty
                                                  ? IconButton(
                                                      icon: const Icon(Icons.clear),
                                                      onPressed: () {
                                                        setState(() {
                                                          _searchController.clear();
                                                          _searchQuery = '';
                                                        });
                                                      },
                                                    )
                                                  : null,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery = value.toLowerCase();
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.8,
                                      ),
                                      itemCount: _getFilteredAnimals(animalService.animals).length,
                                      itemBuilder: (context, index) {
                                        final filteredAnimals = _getFilteredAnimals(animalService.animals);
                                        return AnimalCard(
                                          animal: filteredAnimals[index],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Animal> _getFilteredAnimals(List<Animal> animals) {
    if (_searchQuery.isEmpty) return animals;

    final matching = <Animal>[];
    final nonMatching = <Animal>[];

    for (final animal in animals) {
      final searchableText = '${animal.name} ${animal.code} ${animal.breed}'.toLowerCase();
      if (searchableText.contains(_searchQuery)) {
        matching.add(animal);
      } else {
        nonMatching.add(animal);
      }
    }

    return [...matching, ...nonMatching];
  }

  Future<Map<String, dynamic>> _loadAlerts() async {
    final db = await DatabaseService.database;
    
    // Buscar vacinações pendentes (próximos 7 dias)
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final vaccinations = await db.query(
      'vaccinations',
      where: "status = 'Agendada' AND scheduled_date <= ?",
      whereArgs: [nextWeek.toIso8601String()],
      orderBy: 'scheduled_date ASC',
    );

    // Buscar medicações pendentes (próximos 7 dias)
    final medications = await db.query(
      'medications',
      where: 'next_date IS NOT NULL AND next_date <= ?',
      whereArgs: [nextWeek.toIso8601String()],
      orderBy: 'next_date ASC',
    );

    // Buscar animais gestantes
    final animals = await db.query(
      'animals',
      where: 'pregnant = 1',
    );

    return {
      'vaccinations': vaccinations,
      'medications': medications,
      'animals': animals,
    };
  }

  bool _hasUpcomingBirths(List<Map<String, dynamic>> animals) {
    final now = DateTime.now();
    final nextMonth = now.add(const Duration(days: 30));
    
    for (final animal in animals) {
      final deliveryStr = animal['expected_delivery'];
      if (deliveryStr != null) {
        final delivery = DateTime.tryParse(deliveryStr.toString());
        if (delivery != null && delivery.isBefore(nextMonth)) {
          return true;
        }
      }
    }
    return false;
  }

  String _getUpcomingBirthsText(List<Map<String, dynamic>> animals) {
    final now = DateTime.now();
    final nextMonth = now.add(const Duration(days: 30));
    int count = 0;
    
    for (final animal in animals) {
      final deliveryStr = animal['expected_delivery'];
      if (deliveryStr != null) {
        final delivery = DateTime.tryParse(deliveryStr.toString());
        if (delivery != null && delivery.isBefore(nextMonth)) {
          count++;
        }
      }
    }
    
    return '$count parto(s) previsto(s) nos próximos 30 dias';
  }
}
