import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/animal_service.dart';
import '../widgets/stats_card.dart';
import '../widgets/animal_card.dart';
import '../widgets/alert_card.dart';
import 'management_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Alertas Importantes',
                                            style: theme.textTheme.headlineSmall
                                                ?.copyWith(
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
                                      AlertCard(
                                        title: 'Vacinação Pendente',
                                        description:
                                            '3 animais precisam receber vacina contra clostridiose',
                                        icon: Icons.vaccines,
                                        color: theme.colorScheme.error,
                                        onTap: () => _goToManagement(context, 0),
                                      ),
                                      const SizedBox(height: 12),
                                      AlertCard(
                                        title: 'Parto Previsto',
                                        description:
                                            'Benedita (OV001) - Previsão para 20/12/2024',
                                        icon: Icons.child_care,
                                        color: theme.colorScheme.tertiary,
                                        onTap: () => _goToManagement(context, 1),
                                      ),
                                    ],
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
                                Row(
                                  children: [
                                    Text(
                                      'Rebanho',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.search),
                                      label: const Text('Buscar'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.filter_alt),
                                      label: const Text('Filtrar'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
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
                                  itemCount: animalService.animals.length,
                                  itemBuilder: (context, index) {
                                    return AnimalCard(
                                      animal: animalService.animals[index],
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
          ],
        ),
      ),
    );
  }
}
