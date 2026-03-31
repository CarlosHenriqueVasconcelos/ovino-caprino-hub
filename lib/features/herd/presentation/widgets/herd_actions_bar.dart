import 'package:flutter/material.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/responsive_utils.dart';

class HerdActionsBar extends StatelessWidget {
  final VoidCallback onAddAnimal;

  const HerdActionsBar({
    super.key,
    required this.onAddAnimal,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return AppCard(
      variant: AppCardVariant.outlined,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      borderColor: AppColors.borderNeutral.withValues(alpha: 0.78),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Painel Operacional',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SectionHeader(
            title: 'Rebanho',
            subtitle: 'Gestão de animais, status sanitário e histórico',
            action: isMobile
                ? null
                : PrimaryButton(
                    label: 'Adicionar Animal',
                    icon: Icons.add,
                    onPressed: onAddAnimal,
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusChip(
                label: 'Busca rápida',
                variant: StatusChipVariant.info,
                icon: Icons.search,
              ),
              StatusChip(
                label: 'Filtros ativos',
                variant: StatusChipVariant.neutral,
                icon: Icons.tune,
              ),
              StatusChip(
                label: 'Controle por lote',
                variant: StatusChipVariant.success,
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
