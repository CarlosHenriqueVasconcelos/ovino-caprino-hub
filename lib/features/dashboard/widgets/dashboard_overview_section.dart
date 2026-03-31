import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../shared/widgets/common/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

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

    return AppCard(
      variant: AppCardVariant.outlined,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      borderColor: AppColors.borderNeutral.withValues(alpha: 0.78),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Resumo Operacional',
            subtitle: 'Visão rápida do estado atual do rebanho',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusChip(
                label: 'Saúde: $healthyPercent%',
                variant: healthyPercent >= 75
                    ? StatusChipVariant.success
                    : StatusChipVariant.warning,
                icon: Icons.health_and_safety_outlined,
              ),
              StatusChip(
                label: 'Gestação: ${stats.pregnant}',
                variant: StatusChipVariant.info,
                icon: Icons.pregnant_woman_outlined,
              ),
              StatusChip(
                label: 'Tratamento: ${stats.underTreatment}',
                variant: stats.underTreatment > 0
                    ? StatusChipVariant.warning
                    : StatusChipVariant.neutral,
                icon: Icons.medical_services_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 680;
              return compact
                  ? Column(
                      children: _buildInfoTiles(compact: true),
                    )
                  : Row(
                      children: _buildInfoTiles(compact: false),
                    );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInfoTiles({required bool compact}) {
    final tiles = [
      _OverviewInfoTile(
        title: 'Vacinas no mês',
        value: '${stats.vaccinesThisMonth}',
        icon: Icons.vaccines_outlined,
      ),
      _OverviewInfoTile(
        title: 'Nascimentos no mês',
        value: '${stats.birthsThisMonth}',
        icon: Icons.child_care_outlined,
      ),
      _OverviewInfoTile(
        title: 'Peso médio',
        value: '${stats.avgWeight.toStringAsFixed(1)} kg',
        icon: Icons.monitor_weight_outlined,
      ),
    ];

    if (compact) {
      return tiles
          .map(
            (tile) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: tile,
            ),
          )
          .toList();
    }

    return tiles
        .map(
          (tile) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: tile,
            ),
          ),
        )
        .toList();
  }
}

class _OverviewInfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _OverviewInfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderNeutral.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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
