import 'package:flutter/material.dart';

import '../../breeding/presentation/widgets/repro_alerts_card.dart';
import '../../medication/presentation/widgets/vaccination_alerts.dart';
import '../../weight/presentation/widgets/weight_alerts_card.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../shared/widgets/common/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'dashboard_visual_style.dart';

class DashboardAlertsSection extends StatelessWidget {
  final void Function(int) onGoToTab;

  const DashboardAlertsSection({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final sectionPadding = DashboardVisualStyle.panelPadding(width);
        final blockGap = DashboardVisualStyle.blockGap(width);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              variant: AppCardVariant.outlined,
              backgroundColor: DashboardVisualStyle.panelBackground(),
              borderColor: DashboardVisualStyle.panelBorder(alpha: 0.8),
              padding: sectionPadding,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Central de Alertas',
                    subtitle:
                        'Priorize pendências de sanidade, reprodução e pesagem',
                    subtitleMaxLines: 2,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _AlertCategoryCard(
                        label: 'Sanidade',
                        description: 'Vacinas e medicações',
                        icon: Icons.health_and_safety_outlined,
                        variant: StatusChipVariant.warning,
                        statusLabel: 'Atenção',
                      ),
                      _AlertCategoryCard(
                        label: 'Reprodução',
                        description: 'Eventos do ciclo reprodutivo',
                        icon: Icons.favorite_outline,
                        variant: StatusChipVariant.info,
                        statusLabel: 'Monitorar',
                      ),
                      _AlertCategoryCard(
                        label: 'Pesagem',
                        description: 'Pendências de ganho de peso',
                        icon: Icons.monitor_weight_outlined,
                        variant: StatusChipVariant.neutral,
                        statusLabel: 'Rotina',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: blockGap),
            _AlertBlock(
              title: 'Sanidade',
              subtitle: 'Vacinações e medicações com prioridade diária',
              statusLabel: 'Atenção',
              statusVariant: StatusChipVariant.warning,
              icon: Icons.health_and_safety_outlined,
              child: VaccinationAlerts(onGoToVaccinations: () => onGoToTab(6)),
            ),
            SizedBox(height: blockGap),
            const _AlertBlock(
              title: 'Reprodução',
              subtitle: 'Próximos eventos e atrasos no ciclo reprodutivo',
              statusLabel: 'Monitorar',
              statusVariant: StatusChipVariant.info,
              icon: Icons.favorite_outline,
              child: ReproAlertsCard(daysAhead: 30),
            ),
            SizedBox(height: blockGap),
            const _AlertBlock(
              title: 'Pesagem',
              subtitle: 'Pendências para manter o acompanhamento em dia',
              statusLabel: 'Rotina',
              statusVariant: StatusChipVariant.neutral,
              icon: Icons.monitor_weight_outlined,
              child: WeightAlertsCard(),
            ),
          ],
        );
      },
    );
  }
}

class _AlertBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusLabel;
  final StatusChipVariant statusVariant;
  final IconData icon;
  final Widget child;

  const _AlertBlock({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusVariant,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.outlined,
      backgroundColor: DashboardVisualStyle.panelBackground(alpha: 0.94),
      borderColor: DashboardVisualStyle.panelBorder(alpha: 0.76),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            subtitle: subtitle,
            subtitleMaxLines: 2,
            collapseBreakpoint: 620,
            action: StatusChip(
              label: statusLabel,
              variant: statusVariant,
              icon: icon,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _AlertCategoryCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final StatusChipVariant variant;
  final String statusLabel;

  const _AlertCategoryCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.variant,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 170, maxWidth: 240),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: DashboardVisualStyle.innerBackground(alpha: 0.93),
        borderRadius: BorderRadius.circular(DashboardVisualStyle.tileRadius),
        border: Border.all(color: DashboardVisualStyle.innerBorder(alpha: 0.84)),
        boxShadow: DashboardVisualStyle.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.25,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          StatusChip(
            label: statusLabel,
            variant: variant,
          ),
        ],
      ),
    );
  }
}
