import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'stats_card.dart';

class DashboardKpiRow extends StatelessWidget {
  final AnimalStats stats;
  const DashboardKpiRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards();
    return AppCard(
      variant: AppCardVariant.outlined,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      borderColor: AppColors.borderNeutral.withValues(alpha: 0.78),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Indicadores do Rebanho',
            subtitle: 'Métricas atuais para tomada de decisão',
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              const targetWidth = 220.0;
              final crossAxis = availableWidth.isFinite && availableWidth > 0
                  ? (availableWidth / targetWidth).floor().clamp(1, 4)
                  : 4;

              final aspectRatio = crossAxis <= 1
                  ? 2.55
                  : crossAxis == 2
                      ? 1.9
                      : 1.48;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: AppSpacing.xs,
                  mainAxisSpacing: AppSpacing.xs,
                  childAspectRatio: aspectRatio,
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
          ),
        ],
      ),
    );
  }

  List<_StatCardData> _buildCards() {
    final cards = [
      _StatCardData(
        title: 'Total de Animais',
        value: '${stats.totalAnimals}',
        icon: Icons.groups,
        trend: 'Rebanho ativo',
        color: AppColors.primary,
      ),
      _StatCardData(
        title: 'Saudáveis',
        value: '${stats.healthy}',
        icon: Icons.health_and_safety_outlined,
        trend: 'Condição sanitária',
        color: AppColors.primarySupport,
      ),
      _StatCardData(
        title: 'Em Tratamento',
        value: '${stats.underTreatment}',
        icon: Icons.medical_services_outlined,
        trend: 'Requer atenção',
        color: const Color(0xFFDE8B28),
      ),
      _StatCardData(
        title: 'Gestantes',
        value: '${stats.pregnant}',
        icon: Icons.pregnant_woman_outlined,
        trend: 'Matrizes em gestação',
        color: const Color(0xFFCE6AA5),
      ),
      _StatCardData(
        title: 'Vacinas no mês',
        value: '${stats.vaccinesThisMonth}',
        icon: Icons.vaccines_outlined,
        trend: 'Aplicações registradas',
        color: const Color(0xFF5679C4),
      ),
      _StatCardData(
        title: 'Nascimentos no mês',
        value: '${stats.birthsThisMonth}',
        icon: Icons.child_care_outlined,
        trend: 'Evolução do plantel',
        color: const Color(0xFF8E7AC5),
      ),
      _StatCardData(
        title: 'Fêmeas Reprodutoras',
        value: '${stats.femaleReproducers}',
        icon: Icons.female_outlined,
        trend: 'Matrizes ativas',
        color: const Color(0xFFB75A97),
      ),
      _StatCardData(
        title: 'Peso Médio',
        value: '${stats.avgWeight.toStringAsFixed(1)} kg',
        icon: Icons.monitor_weight_outlined,
        trend: 'Média geral atual',
        color: const Color(0xFF3E8F7D),
      ),
      _StatCardData(
        title: 'Receita',
        value: 'R\$ ${stats.revenue.toStringAsFixed(2)}',
        icon: Icons.paid_outlined,
        trend: 'Resumo financeiro',
        color: AppColors.goldSoft,
      ),
      _StatCardData(
        title: 'Machos Reprodutores',
        value: '${stats.maleReproducers}',
        icon: Icons.male_outlined,
        trend: 'Reprodutores ativos',
        color: const Color(0xFF3A7FC1),
      ),
      _StatCardData(
        title: 'Machos Borregos',
        value: '${stats.maleLambs}',
        icon: Icons.face_4_outlined,
        trend: 'Em crescimento',
        color: const Color(0xFF58A6D7),
      ),
      _StatCardData(
        title: 'Fêmeas Borregas',
        value: '${stats.femaleLambs}',
        icon: Icons.face_3_outlined,
        trend: 'Em crescimento',
        color: const Color(0xFFD27CB3),
      ),
    ];
    return cards;
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
