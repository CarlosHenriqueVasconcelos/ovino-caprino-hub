import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardMiniStats extends StatelessWidget {
  final AnimalStats stats;

  const DashboardMiniStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.totalAnimals;
    final healthyPct =
        total == 0 ? 0 : ((stats.healthy / total) * 100).round();

    return Row(
      children: [
        Expanded(
          child: _MiniStatTile(
            value: '${stats.healthy}',
            label: 'Saudáveis',
            sub: '$healthyPct%',
            icon: Icons.health_and_safety_outlined,
            color: AppColors.primary,
            subColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _MiniStatTile(
            value: '${stats.underTreatment}',
            label: 'Tratamento',
            sub: stats.underTreatment > 0
                ? '${stats.underTreatment} urgentes'
                : 'Nenhum',
            icon: Icons.medical_services_outlined,
            color: const Color(0xFFDE8B28),
            subColor: const Color(0xFFDE8B28),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _MiniStatTile(
            value: '${stats.pregnant}',
            label: 'Gestantes',
            sub: stats.birthsThisMonth > 0
                ? '${stats.birthsThisMonth} partos'
                : 'No mês',
            icon: Icons.favorite_outline,
            color: const Color(0xFFCE6AA5),
            subColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  final String value;
  final String label;
  final String sub;
  final IconData icon;
  final Color color;
  final Color subColor;

  const _MiniStatTile({
    required this.value,
    required this.label,
    required this.sub,
    required this.icon,
    required this.color,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderNeutral.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: subColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
