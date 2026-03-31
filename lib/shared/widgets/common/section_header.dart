import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final VoidCallback? onActionTap;
  final String? actionLabel;
  final EdgeInsetsGeometry? padding;
  final int titleMaxLines;
  final int subtitleMaxLines;
  final double collapseBreakpoint;
  final bool forceVertical;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.onActionTap,
    this.actionLabel,
    this.padding,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 2,
    this.collapseBreakpoint = 560,
    this.forceVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? trailing = action;
    if (trailing == null && onActionTap != null && actionLabel != null) {
      trailing = TextButton(
        onPressed: onActionTap,
        child: Text(actionLabel!),
      );
    }

    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final headerText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: titleMaxLines,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasSubtitle) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle!,
            maxLines: subtitleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final shouldUseVertical = forceVertical || availableWidth < collapseBreakpoint;

          if (trailing == null) return headerText;

          if (shouldUseVertical) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerText,
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: trailing,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headerText),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Align(
                  alignment: Alignment.topRight,
                  child: trailing,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
