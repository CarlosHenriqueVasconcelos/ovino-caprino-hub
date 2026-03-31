import 'package:flutter/material.dart';

import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

class ManagementHeader extends StatelessWidget {
  const ManagementHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      variant: AppCardVariant.soft,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.agriculture,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Central de Manejo',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader(
            title: 'Manejo',
            subtitle:
                'Central operacional para alimentação, saúde, reprodução e evolução do rebanho',
          ),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusChip(
                label: 'Operações diárias',
                icon: Icons.task_alt,
                variant: StatusChipVariant.info,
              ),
              StatusChip(
                label: 'Acesso rápido',
                icon: Icons.flash_on,
                variant: StatusChipVariant.neutral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
