import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/responsive_utils.dart';

class AppBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onNotificationsTap;
  final int? notificationCount;
  final EdgeInsetsGeometry? margin;

  const AppBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onNotificationsTap,
    this.notificationCount,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final widthTier = ResponsiveUtils.widthTier(context);
    final horizontalPadding = ResponsiveUtils.getPageHorizontalPadding(context);
    final topPadding = widthTier == ResponsiveWidthTier.small
        ? AppSpacing.sm
        : AppSpacing.md;
    final logoSize = widthTier == ResponsiveWidthTier.small ? 34.0 : 38.0;
    final logoIconSize = widthTier == ResponsiveWidthTier.small ? 17.0 : 18.0;
    final notificationSize =
        widthTier == ResponsiveWidthTier.small ? 36.0 : 40.0;
    final hasNotificationBadge =
        notificationCount != null && notificationCount! > 0;
    final resolvedMargin = margin ??
        EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          AppSpacing.xs,
        );

    return Padding(
      padding: resolvedMargin,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderNeutral.withValues(alpha: 0.85),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primarySupport,
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.agriculture_rounded,
                size: logoIconSize,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _NotificationButton(
              size: notificationSize,
              hasBadge: hasNotificationBadge,
              onTap: onNotificationsTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final double size;
  final bool hasBadge;
  final VoidCallback? onTap;

  const _NotificationButton({
    required this.size,
    required this.hasBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(
                    color: AppColors.borderNeutral.withValues(alpha: 0.95),
                  ),
                ),
                child: IconButton(
                  onPressed: onTap ?? () {},
                  splashRadius: size / 2,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                  ),
                  tooltip: 'Notificações',
                ),
              ),
            ),
          ),
          if (hasBadge)
            const Positioned(
              top: 8,
              right: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
        ],
      ),
    );
  }
}
