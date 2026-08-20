import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardHerdInsights extends StatelessWidget {
  final AnimalStats stats;
  final VoidCallback onGoToHerd;

  const DashboardHerdInsights({
    super.key,
    required this.stats,
    required this.onGoToHerd,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <({String label, int value, IconData icon, Color color})>[
      (
        label: 'Ativos',
        value: stats.totalAnimals,
        icon: Icons.pets_outlined,
        color: AppColors.primary,
      ),
      (
        label: 'Saudáveis',
        value: stats.healthy,
        icon: Icons.health_and_safety_outlined,
        color: AppColors.success,
      ),
      (
        label: 'Tratamento',
        value: stats.underTreatment,
        icon: Icons.healing_outlined,
        color: AppColors.warning,
      ),
      (
        label: 'Feridos',
        value: stats.injured,
        icon: Icons.warning_amber_rounded,
        color: AppColors.error,
      ),
      (
        label: 'Matrizes',
        value: stats.matrices,
        icon: Icons.workspace_premium_outlined,
        color: AppColors.primarySupport,
      ),
      (
        label: 'Gestantes',
        value: stats.pregnant,
        icon: Icons.pregnant_woman_outlined,
        color: AppColors.goldSoft,
      ),
      (
        label: 'Machos Reprod.',
        value: stats.maleReproducers,
        icon: Icons.male_outlined,
        color: AppColors.primary,
      ),
      (
        label: 'Machos Borreg.',
        value: stats.maleLambs,
        icon: Icons.male_rounded,
        color: AppColors.primary,
      ),
      (
        label: 'Fêmeas Borreg.',
        value: stats.femaleLambs,
        icon: Icons.female_rounded,
        color: AppColors.goldSoft,
      ),
      (
        label: 'Vendidos',
        value: stats.sold,
        icon: Icons.sell_outlined,
        color: AppColors.primarySupport,
      ),
      (
        label: 'Óbitos',
        value: stats.deceased,
        icon: Icons.heart_broken_outlined,
        color: AppColors.error,
      ),
    ];

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: cards
          .map(
            (c) => _InsightCard(
              label: c.label,
              value: c.value,
              icon: c.icon,
              color: c.color,
              onTap: onGoToHerd,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderNeutral.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(
                '$value',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
