import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../shared/widgets/common/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'dashboard_visual_style.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onAddAnimal;
  final AnimalStats stats;

  const DashboardHeader({
    super.key,
    required this.onRefresh,
    required this.onAddAnimal,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 700;
    final panelPadding = DashboardVisualStyle.panelPadding(width);
    final sectionGap = DashboardVisualStyle.sectionGap(width);

    return AppCard(
      variant: AppCardVariant.outlined,
      backgroundColor: DashboardVisualStyle.panelBackground(),
      borderColor: DashboardVisualStyle.panelBorder(),
      padding: panelPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral',
            style: DashboardVisualStyle.eyebrowStyle(Theme.of(context)),
          ),
          const SizedBox(height: AppSpacing.xs),
          SectionHeader(
            title: 'Início',
            subtitle: 'Acompanhe o estado atual da operação diária',
            subtitleMaxLines: 1,
            action: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🐑'),
                  SizedBox(width: AppSpacing.xxs),
                  Text('🐐'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              StatusChip(
                label: '${stats.totalAnimals} animais ativos',
                variant: StatusChipVariant.success,
                icon: Icons.pets_outlined,
              ),
              StatusChip(
                label: '${stats.underTreatment} em atenção',
                variant: stats.underTreatment > 0
                    ? StatusChipVariant.warning
                    : StatusChipVariant.neutral,
                icon: Icons.medical_services_outlined,
              ),
              StatusChip(
                label: '${stats.vaccinesThisMonth} vacinas no mês',
                variant: StatusChipVariant.info,
                icon: Icons.vaccines_outlined,
              ),
            ],
          ),
          SizedBox(height: sectionGap),
          if (compact)
            Column(
              children: [
                PrimaryButton(
                  label: 'Novo Animal',
                  icon: Icons.add,
                  onPressed: onAddAnimal,
                  fullWidth: true,
                ),
                const SizedBox(height: AppSpacing.xs),
                SecondaryButton(
                  label: 'Atualizar painel',
                  icon: Icons.refresh,
                  onPressed: onRefresh,
                  fullWidth: true,
                ),
              ],
            )
          else
            Row(
              children: [
                PrimaryButton(
                  label: 'Novo Animal',
                  icon: Icons.add,
                  onPressed: onAddAnimal,
                ),
                const SizedBox(width: AppSpacing.xs),
                SecondaryButton(
                  label: 'Atualizar painel',
                  icon: Icons.refresh,
                  onPressed: onRefresh,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
