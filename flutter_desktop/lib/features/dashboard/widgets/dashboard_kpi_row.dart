import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../widgets/stats_card.dart';

class DashboardKpiRow extends StatelessWidget {
  final AnimalStats stats;
  const DashboardKpiRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = [
      _StatCardData(
        title: 'Total de Animais',
        value: '${stats.totalAnimals}',
        icon: Icons.groups,
        trend: '+3 este mês',
        color: theme.colorScheme.primary,
      ),
      _StatCardData(
        title: 'Machos Reprodutores',
        value: '${stats.maleReproducers}',
        icon: Icons.male,
        trend: 'Reprodutores ativos',
        color: Colors.blue,
      ),
      _StatCardData(
        title: 'Machos Borregos',
        value: '${stats.maleLambs}',
        icon: Icons.child_care,
        trend: 'Em crescimento',
        color: Colors.lightBlue,
      ),
      _StatCardData(
        title: 'Fêmeas Borregas',
        value: '${stats.femaleLambs}',
        icon: Icons.child_friendly,
        trend: 'Crescimento saudável',
        color: Colors.pinkAccent,
      ),
      _StatCardData(
        title: 'Fêmeas Reprodutoras',
        value: '${stats.femaleReproducers}',
        icon: Icons.female,
        trend: 'Reprodução ativa',
        color: Colors.purple,
      ),
      _StatCardData(
        title: 'Animais em Tratamento',
        value: '${stats.underTreatment}',
        icon: Icons.medical_services,
        trend: 'Requer atenção',
        color: Colors.orange,
      ),
      _StatCardData(
        title: 'Gestantes',
        value: '${stats.pregnant}',
        icon: Icons.pregnant_woman,
        color: Colors.pink,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const targetWidth = 220.0;
        final crossAxis = availableWidth.isFinite && availableWidth > 0
            ? (availableWidth / targetWidth).floor().clamp(1, 5)
            : 5;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return StatsCard(
              title: card.title,
              value: card.value,
              icon: card.icon,
              trend: card.trend,
              color: card.color,
            );
          },
        );
      },
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;
  final Color? color;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
    this.color,
  });
}
