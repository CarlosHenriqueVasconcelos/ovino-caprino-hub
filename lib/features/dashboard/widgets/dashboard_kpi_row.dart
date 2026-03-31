import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'dashboard_visual_style.dart';
import 'stats_card.dart';

class DashboardKpiRow extends StatelessWidget {
  final AnimalStats stats;
  const DashboardKpiRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards();
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
        final metrics = _KpiGridMetrics.fromWidth(availableWidth);
        final panelPadding = DashboardVisualStyle.panelPadding(availableWidth);
        final sectionGap = DashboardVisualStyle.sectionGap(availableWidth);

        return AppCard(
          variant: AppCardVariant.outlined,
          backgroundColor: DashboardVisualStyle.panelBackground(),
          borderColor: DashboardVisualStyle.panelBorder(),
          padding: panelPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Indicadores do Rebanho',
                subtitle: 'Métricas atuais para tomada de decisão',
                subtitleMaxLines: 1,
              ),
              SizedBox(height: sectionGap),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: metrics.crossAxisCount,
                  crossAxisSpacing: metrics.gridSpacing,
                  mainAxisSpacing: metrics.gridSpacing,
                  mainAxisExtent: metrics.cardHeight,
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
              ),
            ],
          ),
        );
      },
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

class _KpiGridMetrics {
  final int crossAxisCount;
  final double gridSpacing;
  final double cardHeight;

  const _KpiGridMetrics({
    required this.crossAxisCount,
    required this.gridSpacing,
    required this.cardHeight,
  });

  factory _KpiGridMetrics.fromWidth(double width) {
    final isNarrow = width <= 480;
    final spacing = isNarrow ? 10.0 : AppSpacing.xs;
    final columns = _resolveColumnCount(
      width: width,
      spacing: spacing,
      minTileWidth: 190,
    );

    final cardHeight = _resolveCardHeight(width: width, columns: columns);

    return _KpiGridMetrics(
      crossAxisCount: columns,
      gridSpacing: spacing,
      cardHeight: cardHeight,
    );
  }

  static int _resolveColumnCount({
    required double width,
    required double spacing,
    required double minTileWidth,
  }) {
    for (var columns = 4; columns >= 1; columns--) {
      final totalSpacing = spacing * (columns - 1);
      final tileWidth = (width - totalSpacing) / columns;
      if (tileWidth >= minTileWidth) return columns;
    }
    return 1;
  }

  static double _resolveCardHeight({
    required double width,
    required int columns,
  }) {
    if (columns == 1) return 170;
    if (columns == 2) return width <= 560 ? 170 : 164;
    if (columns == 4) return 154;
    return 160;
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
