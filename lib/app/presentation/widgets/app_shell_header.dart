import 'package:flutter/material.dart';

import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class AppShellHeader extends StatelessWidget {
  final String farmName;
  final String subtitle;
  final String contextLabel;
  final VoidCallback onAddAnimal;
  final VoidCallback? onOpenSectionMenu;

  const AppShellHeader({
    super.key,
    required this.farmName,
    required this.subtitle,
    required this.contextLabel,
    required this.onAddAnimal,
    this.onOpenSectionMenu,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 860;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: AppCard(
        variant: AppCardVariant.elevated,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
                  child: const Text(
                    '🐑',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Painel da Fazenda',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        farmName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCompact)
                  PrimaryButton(
                    label: 'Novo Animal',
                    icon: Icons.add,
                    onPressed: onAddAnimal,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip(
                  label: contextLabel,
                  variant: StatusChipVariant.success,
                  icon: Icons.dashboard_customize,
                ),
                if (onOpenSectionMenu != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                    ),
                    onPressed: onOpenSectionMenu,
                    icon: const Icon(Icons.view_list, size: 16),
                    label: const Text('Módulos'),
                  ),
              ],
            ),
            if (isCompact) ...[
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Novo Animal',
                icon: Icons.add,
                onPressed: onAddAnimal,
                fullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
