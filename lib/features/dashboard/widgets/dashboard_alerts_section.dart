import 'package:flutter/material.dart';

import '../../breeding/presentation/widgets/repro_alerts_card.dart';
import '../../medication/presentation/widgets/vaccination_alerts.dart';
import '../../weight/presentation/widgets/weight_alerts_card.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../shared/widgets/common/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardAlertsSection extends StatelessWidget {
  final void Function(int) onGoToTab;

  const DashboardAlertsSection({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          variant: AppCardVariant.outlined,
          backgroundColor: AppColors.surface.withValues(alpha: 0.95),
          borderColor: AppColors.borderNeutral.withValues(alpha: 0.78),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Alertas do Dia',
                subtitle: 'Pendências e eventos que exigem atenção imediata',
              ),
              SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusChip(
                    label: 'Sanidade',
                    variant: StatusChipVariant.warning,
                    icon: Icons.health_and_safety_outlined,
                  ),
                  StatusChip(
                    label: 'Reprodução',
                    variant: StatusChipVariant.info,
                    icon: Icons.favorite_outline,
                  ),
                  StatusChip(
                    label: 'Pesagem',
                    variant: StatusChipVariant.neutral,
                    icon: Icons.monitor_weight_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        VaccinationAlerts(onGoToVaccinations: () => onGoToTab(6)),
        const SizedBox(height: AppSpacing.sm),
        const ReproAlertsCard(daysAhead: 30),
        const SizedBox(height: AppSpacing.sm),
        const WeightAlertsCard(),
      ],
    );
  }
}
