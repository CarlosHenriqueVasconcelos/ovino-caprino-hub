import 'package:flutter/material.dart';

import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

class MoreModuleItem {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final bool isPrimary;

  const MoreModuleItem({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isPrimary = false,
  });
}

class MoreModuleCard extends StatelessWidget {
  final MoreModuleItem module;
  final bool selected;
  final ValueChanged<String> onOpen;

  const MoreModuleCard({
    super.key,
    required this.module,
    required this.selected,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      variant: selected ? AppCardVariant.soft : AppCardVariant.elevated,
      borderColor: selected
          ? AppColors.primary.withValues(alpha: 0.38)
          : AppColors.borderNeutral,
      onTap: () => onOpen(module.key),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  module.icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (selected)
                const StatusChip(
                  label: 'Ativo',
                  variant: StatusChipVariant.info,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            module.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            module.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Abrir módulo',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
