import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardBottomStats extends StatelessWidget {
  final AnimalStats stats;

  const DashboardBottomStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatCard(
            title: 'Reprodução',
            icon: Icons.favorite_outline,
            iconColor: const Color(0xFFCE6AA5),
            rows: [
              _StatRow(label: 'Gestantes', value: '${stats.pregnant}'),
              _StatRow(
                label: 'Borregos',
                value: '${stats.maleLambs + stats.femaleLambs}',
              ),
              _StatRow(label: 'Reprodutores', value: '${stats.maleReproducers}'),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _StatCard(
            title: 'Peso Médio',
            icon: Icons.monitor_weight_outlined,
            iconColor: const Color(0xFF3D9E8D),
            header: stats.avgWeight > 0
                ? '${stats.avgWeight.toStringAsFixed(1)} kg'
                : null,
            rows: [
              if (stats.avgWeightOvino > 0)
                _StatRow(
                  label: 'Ovinos',
                  value: '${stats.avgWeightOvino.toStringAsFixed(1)} kg',
                  valueColor: AppColors.primary,
                ),
              if (stats.avgWeightCaprino > 0)
                _StatRow(
                  label: 'Caprinos',
                  value: '${stats.avgWeightCaprino.toStringAsFixed(1)} kg',
                  valueColor: AppColors.primary,
                ),
              if (stats.avgWeightOvino == 0 && stats.avgWeightCaprino == 0)
                _StatRow(label: 'Geral', value: '${stats.avgWeight.toStringAsFixed(1)} kg'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? header;
  final List<_StatRow> rows;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.header,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (header != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              header!,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          ...rows.map((row) => _buildRow(context, row)),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, _StatRow row) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            row.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            row.value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: row.valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({required this.label, required this.value, this.valueColor});
}
