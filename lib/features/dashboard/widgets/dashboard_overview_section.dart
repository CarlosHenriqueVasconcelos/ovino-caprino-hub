import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../shared/widgets/common/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'dashboard_visual_style.dart';

class DashboardOverviewSection extends StatelessWidget {
  final AnimalStats stats;

  const DashboardOverviewSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats.totalAnimals;
    final healthyPercent =
        total == 0 ? 0 : ((stats.healthy / total) * 100).round();
    final healthyVariant = healthyPercent >= 75
        ? StatusChipVariant.success
        : healthyPercent >= 60
            ? StatusChipVariant.warning
            : StatusChipVariant.danger;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final metrics = _OverviewLayoutMetrics.fromWidth(width);
        final tileWidth = metrics.tileWidthFor(width);

        final tiles = [
          _OverviewInfoTile(
            title: 'Vacinas no mês',
            value: '${stats.vaccinesThisMonth}',
            icon: Icons.vaccines_outlined,
            color: const Color(0xFF4B73C7),
          ),
          _OverviewInfoTile(
            title: 'Nascimentos no mês',
            value: '${stats.birthsThisMonth}',
            icon: Icons.child_care_outlined,
            color: const Color(0xFFB06496),
          ),
          _OverviewInfoTile(
            title: 'Peso médio',
            value: '${stats.avgWeight.toStringAsFixed(1)} kg',
            icon: Icons.monitor_weight_outlined,
            color: const Color(0xFF3D9E8D),
          ),
        ];

        return AppCard(
          variant: AppCardVariant.outlined,
          backgroundColor: DashboardVisualStyle.panelBackground(),
          borderColor: DashboardVisualStyle.panelBorder(),
          padding: DashboardVisualStyle.panelPadding(width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Resumo Operacional',
                subtitle: 'Leitura rápida da saúde e evolução do rebanho',
                subtitleMaxLines: 1,
              ),
              SizedBox(height: metrics.sectionGap),
              _OverviewHighlightCard(
                healthyPercent: healthyPercent,
                healthyCount: stats.healthy,
                totalCount: total,
                healthyVariant: healthyVariant,
                pregnantCount: stats.pregnant,
                underTreatmentCount: stats.underTreatment,
              ),
              SizedBox(height: metrics.sectionGap),
              Wrap(
                spacing: metrics.tileGap,
                runSpacing: metrics.tileGap,
                children: tiles
                    .map(
                      (tile) => SizedBox(
                        width: tileWidth,
                        child: tile,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewHighlightCard extends StatelessWidget {
  final int healthyPercent;
  final int healthyCount;
  final int totalCount;
  final StatusChipVariant healthyVariant;
  final int pregnantCount;
  final int underTreatmentCount;

  const _OverviewHighlightCard({
    required this.healthyPercent,
    required this.healthyCount,
    required this.totalCount,
    required this.healthyVariant,
    required this.pregnantCount,
    required this.underTreatmentCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: DashboardVisualStyle.innerBackground(),
        borderRadius: BorderRadius.circular(DashboardVisualStyle.panelRadius),
        border: Border.all(color: DashboardVisualStyle.innerBorder()),
        boxShadow: DashboardVisualStyle.softShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;

          Widget summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saúde do Rebanho',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '$healthyPercent%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$healthyCount de $totalCount animais saudáveis',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );

          final chips = Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusChip(
                label: 'Saúde: $healthyPercent%',
                variant: healthyVariant,
                icon: Icons.health_and_safety_outlined,
              ),
              StatusChip(
                label: 'Gestação: $pregnantCount',
                variant: StatusChipVariant.info,
                icon: Icons.pregnant_woman_outlined,
              ),
              StatusChip(
                label: 'Tratamento: $underTreatmentCount',
                variant: underTreatmentCount > 0
                    ? StatusChipVariant.warning
                    : StatusChipVariant.neutral,
                icon: Icons.medical_services_outlined,
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                summary,
                const SizedBox(height: AppSpacing.sm),
                chips,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: summary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: chips),
            ],
          );
        },
      ),
    );
  }
}

class _OverviewInfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewInfoTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: DashboardVisualStyle.innerBackground(alpha: 0.93),
        borderRadius: BorderRadius.circular(DashboardVisualStyle.tileRadius),
        border: Border.all(color: DashboardVisualStyle.innerBorder()),
        boxShadow: DashboardVisualStyle.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewLayoutMetrics {
  final int columns;
  final double tileGap;
  final double sectionGap;

  const _OverviewLayoutMetrics({
    required this.columns,
    required this.tileGap,
    required this.sectionGap,
  });

  factory _OverviewLayoutMetrics.fromWidth(double width) {
    if (width < 560) {
      return const _OverviewLayoutMetrics(
        columns: 1,
        tileGap: AppSpacing.xs,
        sectionGap: AppSpacing.md,
      );
    }
    if (width < 920) {
      return const _OverviewLayoutMetrics(
        columns: 2,
        tileGap: AppSpacing.sm,
        sectionGap: AppSpacing.md,
      );
    }
    return const _OverviewLayoutMetrics(
      columns: 3,
      tileGap: AppSpacing.sm,
      sectionGap: AppSpacing.lg,
    );
  }

  double tileWidthFor(double availableWidth) {
    if (columns <= 1) return availableWidth;
    final widthWithoutSpacing = availableWidth - (tileGap * (columns - 1));
    return widthWithoutSpacing / columns;
  }
}
