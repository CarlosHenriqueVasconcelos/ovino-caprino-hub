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

  void _goToVaccination(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ManagementScreen(initialTab: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header da Sidebar
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Buscar Animal',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Digite código ou nome...',
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
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Info da Busca
                if (_searchQuery.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    child: Consumer<AnimalService>(
                      builder: (context, animalService, _) {
                        final matchCount = _getMatchingAnimals(animalService.animals).length;
                        return Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$matchCount resultado(s) encontrado(s)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                // Dicas
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dicas de busca',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTip(
                          context,
                          Icons.tag,
                          'Digite o código do animal',
                          'Ex: OV001, CP002',
                        ),
                        const SizedBox(height: 8),
                        _buildTip(
                          context,
                          Icons.abc,
                          'Busque pelo nome',
                          'Ex: Benedita, Valente',
                        ),
                        const SizedBox(height: 8),
                        _buildTip(
                          context,
                          Icons.pets,
                          'Filtre por raça',
                          'Ex: Santa Inês, Dorper',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
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
                            'Fazenda São Petronio',
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
                                            ...vaccinations.take(3).map((vacc) {
                                              final color = _getAlertColorForDate(vacc['scheduled_date']);
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: AlertCard(
                                                  title: 'Vacinação: ${vacc['vaccine_name']}',
                                                  description: _getVaccinationDescription(vacc),
                                                  icon: Icons.vaccines,
                                                  color: color,
                                                  onTap: () => _goToVaccination(context),
                                                ),
                                              );
                                            }).toList(),
                                          if (medications.isNotEmpty)
                                            ...medications.take(3).map((med) {
                                              final color = _getAlertColorForDate(med['next_date']);
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: AlertCard(
                                                  title: 'Medicamento: ${med['medication_name']}',
                                                  description: _getMedicationDescription(med),
                                                  icon: Icons.medical_services,
                                                  color: color,
                                                  onTap: () => _goToVaccination(context),
                                                ),
                                              );
                                            }).toList(),
                                          if (_hasUpcomingBirths(animals))
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: AlertCard(
                                                title: 'Partos Previstos',
                                                description: _getUpcomingBirthsText(animals),
                                                icon: Icons.child_care,
                                                color: theme.colorScheme.tertiary,
                                                onTap: () => _goToManagement(context, 1),
                                              ),
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
                                    Text(
                                      'Rebanho',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
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
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Animal> _getMatchingAnimals(List<Animal> animals) {
    if (_searchQuery.isEmpty) return [];
    
    return animals.where((animal) {
      final searchableText = '${animal.name} ${animal.code} ${animal.breed}'.toLowerCase();
      return searchableText.contains(_searchQuery);
    }).toList();
  }

  List<Animal> _getFilteredAnimals(List<Animal> animals) {
    if (_searchQuery.isEmpty) return animals;

    final matching = _getMatchingAnimals(animals);
    final nonMatching = animals.where((a) => !matching.contains(a)).toList();

    return [...matching, ...nonMatching];
  }

  Widget _buildTip(BuildContext context, IconData icon, String title, String subtitle) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

  Color _getAlertColorForDate(dynamic dateStr) {
    if (dateStr == null) return Colors.grey;
    
    final date = DateTime.tryParse(dateStr.toString());
    if (date == null) return Colors.grey;
    
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red; // Atrasado
    } else if (difference <= 2) {
      return Colors.red; // Urgente (0-2 dias)
    } else if (difference <= 5) {
      return Colors.orange; // Atenção (3-5 dias)
    } else {
      return Colors.blue; // Normal (6+ dias)
    }
  }

  String _getVaccinationDescription(Map<String, dynamic> vacc) {
    final dateStr = vacc['scheduled_date'];
    if (dateStr == null) return 'Data não informada';
    
    final date = DateTime.tryParse(dateStr.toString());
    if (date == null) return 'Data inválida';
    
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    
    if (difference < 0) {
      return 'ATRASADO - Agendado para $formattedDate';
    } else if (difference == 0) {
      return 'HOJE - $formattedDate';
    } else if (difference == 1) {
      return 'AMANHÃ - $formattedDate';
    } else if (difference <= 5) {
      return 'Em $difference dias - $formattedDate';
    } else {
      return 'Agendado para $formattedDate';
    }
  }

  String _getMedicationDescription(Map<String, dynamic> med) {
    final dateStr = med['next_date'];
    if (dateStr == null) return 'Data não informada';
    
    final date = DateTime.tryParse(dateStr.toString());
    if (date == null) return 'Data inválida';
    
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    
    if (difference < 0) {
      return 'ATRASADO - Previsto para $formattedDate';
    } else if (difference == 0) {
      return 'HOJE - $formattedDate';
    } else if (difference == 1) {
      return 'AMANHÃ - $formattedDate';
    } else if (difference <= 5) {
      return 'Em $difference dias - $formattedDate';
    } else {
      return 'Previsto para $formattedDate';
    }
  }
}
