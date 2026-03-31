import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardVisualStyle {
  const DashboardVisualStyle._();

  static const double tileRadius = 16;
  static const double panelRadius = 18;

  static Color panelBackground({double alpha = 0.96}) =>
      AppColors.surface.withValues(alpha: alpha);
  static Color panelBorder({double alpha = 0.78}) =>
      AppColors.borderNeutral.withValues(alpha: alpha);
  static Color innerBackground({double alpha = 0.94}) =>
      AppColors.white.withValues(alpha: alpha);
  static Color innerBorder({double alpha = 0.82}) =>
      AppColors.borderNeutral.withValues(alpha: alpha);

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  static EdgeInsets panelPadding(double width) =>
      EdgeInsets.all(width < 430 ? AppSpacing.md : AppSpacing.lg);

  static double sectionGap(double width) => width < 430 ? AppSpacing.md : AppSpacing.lg;

  static double blockGap(double width) => width < 680 ? AppSpacing.sm : AppSpacing.md;

  static TextStyle? eyebrowStyle(ThemeData theme) => theme.textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}
