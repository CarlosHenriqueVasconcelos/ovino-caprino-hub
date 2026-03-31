import 'package:flutter/material.dart';

import '../../../shared/widgets/common/app_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'dashboard_visual_style.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;
  final Color? color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.primary;

    return AppCard(
      variant: AppCardVariant.outlined,
      backgroundColor: DashboardVisualStyle.innerBackground(alpha: 0.93),
      borderColor: DashboardVisualStyle.innerBorder(alpha: 0.82),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight < 150 || constraints.maxWidth < 208;
          const titleMaxLines = 2;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accent, size: compact ? 16 : 17),
                  ),
                ],
              ),
              SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.titleLarge)
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
              ),
              if (!compact && trend != null && trend!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  trend!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
