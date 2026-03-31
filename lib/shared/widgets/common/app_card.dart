import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';

enum AppCardVariant { outlined, soft, elevated }

class AppCard extends StatelessWidget {
  final Widget child;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.padding,
    this.margin,
    this.variant = AppCardVariant.outlined,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resolvedPadding = padding ?? const EdgeInsets.all(AppSpacing.md);
    final resolvedMargin = margin ?? EdgeInsets.zero;
    final cardColor = backgroundColor ?? _cardColorForVariant(theme);
    final lineColor = borderColor ?? _borderColorForVariant();
    final shadow = _shadowForVariant();

    final cardBody = Container(
      margin: resolvedMargin,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppRadius.card,
        border: Border.all(color: lineColor),
        boxShadow: shadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: AppSpacing.sm),
          ],
          child,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      ),
    );

    if (onTap == null) return cardBody;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: cardBody,
      ),
    );
  }

  Color _cardColorForVariant(ThemeData theme) {
    switch (variant) {
      case AppCardVariant.soft:
        return AppColors.primaryLight;
      case AppCardVariant.elevated:
        return AppColors.white;
      case AppCardVariant.outlined:
        return theme.cardColor;
    }
  }

  Color _borderColorForVariant() {
    switch (variant) {
      case AppCardVariant.soft:
        return AppColors.primary.withValues(alpha: 0.18);
      case AppCardVariant.elevated:
        return AppColors.borderNeutral.withValues(alpha: 0.75);
      case AppCardVariant.outlined:
        return AppColors.borderNeutral;
    }
  }

  List<BoxShadow> _shadowForVariant() {
    switch (variant) {
      case AppCardVariant.elevated:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ];
      case AppCardVariant.soft:
      case AppCardVariant.outlined:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ];
    }
  }
}
