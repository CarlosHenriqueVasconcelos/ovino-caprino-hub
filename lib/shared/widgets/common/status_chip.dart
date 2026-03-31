import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

enum StatusChipVariant { success, warning, danger, info, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusChipVariant variant;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.variant = StatusChipVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(variant);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.$2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: colors.$3),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: TextStyle(
              color: colors.$3,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _resolveColors(StatusChipVariant value) {
    switch (value) {
      case StatusChipVariant.success:
        return (
          AppColors.primaryLight,
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.primary,
        );
      case StatusChipVariant.warning:
        return (
          AppColors.goldSoft.withValues(alpha: 0.18),
          AppColors.goldSoft.withValues(alpha: 0.35),
          const Color(0xFF8A640D),
        );
      case StatusChipVariant.danger:
        return (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error.withValues(alpha: 0.25),
          AppColors.error,
        );
      case StatusChipVariant.info:
        return (
          const Color(0xFFE9F0FF),
          const Color(0xFFBFD0FF),
          const Color(0xFF3358B8),
        );
      case StatusChipVariant.neutral:
        return (
          AppColors.surface,
          AppColors.borderNeutral,
          AppColors.textSecondary,
        );
    }
  }
}
