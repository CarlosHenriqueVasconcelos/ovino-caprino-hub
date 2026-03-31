import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/weight_alert.dart';
import '../../../../services/events/app_events.dart';
import '../../../../services/events/event_bus.dart';
import '../../../../services/weight_alert_service.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/animal_record_display.dart';

class WeightAlertsCard extends StatefulWidget {
  const WeightAlertsCard({super.key});

  @override
  State<WeightAlertsCard> createState() => _WeightAlertsCardState();
}

class _WeightAlertsCardState extends State<WeightAlertsCard>
    with EventBusSubscriptions {
  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeightAlertService>().loadPending();
    });
  }

  void _setupEventListeners() {
    onEvent<WeightAddedEvent>((_) => _reload());
    onEvent<WeightAlertCompletedEvent>((_) => _reload());
    onEvent<AlertsRefreshRequestedEvent>((_) => _reload());
    onEvent<AnimalCreatedEvent>((_) => _reload());
  }

  void _reload() {
    if (!mounted) return;
    context.read<WeightAlertService>().loadPending();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightAlertService>(
      builder: (context, weightAlertService, _) {
        final alerts = weightAlertService.pendingAlerts;

        if (!weightAlertService.hasLoadedPending) {
          return const AppCard(
            variant: AppCardVariant.elevated,
            child: SizedBox(
              height: 92,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (alerts.isEmpty) {
          return const AppCard(
            variant: AppCardVariant.elevated,
            child: SectionHeader(
              title: 'Alertas de Pesagem',
              subtitle: 'Todas as pesagens estão em dia.',
              collapseBreakpoint: 520,
              action: StatusChip(
                label: 'Em dia',
                icon: Icons.check_circle,
                variant: StatusChipVariant.success,
              ),
            ),
          );
        }

        return AppCard(
          variant: AppCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Alertas de Pesagem',
                subtitle: 'Atenção para pesagens pendentes e vencidas',
                collapseBreakpoint: 560,
                action: StatusChip(
                  label: '${alerts.length} pendente(s)',
                  variant: StatusChipVariant.danger,
                  icon: Icons.monitor_weight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...alerts.take(5).map(_buildAlertItem),
              if (alerts.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'e mais ${alerts.length - 5} alerta(s)...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertItem(WeightAlert alert) {
    final isOverdue = alert.dueDate.isBefore(DateTime.now());
    final daysUntil = alert.dueDate.difference(DateTime.now()).inDays;
    final label = AnimalRecordDisplay.labelFromRecord(alert.extra);
    final color = AnimalRecordDisplay.colorFromRecord(alert.extra);

    final title = _alertTitle(alert.alertType);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      variant: AppCardVariant.soft,
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderColor: isOverdue
          ? AppColors.error.withValues(alpha: 0.35)
          : AppColors.primary.withValues(alpha: 0.25),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;
          final statusChip = StatusChip(
            label: isOverdue
                ? 'Vencido'
                : daysUntil == 0
                    ? 'Hoje'
                    : '$daysUntil dias',
            variant:
                isOverdue ? StatusChipVariant.danger : StatusChipVariant.info,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.monitor_weight,
                      size: 18,
                      color: isOverdue ? AppColors.error : AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            title,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                statusChip,
              ],
            );
          }

          return Row(
            children: [
              Icon(
                Icons.monitor_weight,
                size: 18,
                color: isOverdue ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              statusChip,
            ],
          );
        },
      ),
    );
  }

  String _alertTitle(String alertType) {
    switch (alertType) {
      case '30d':
        return 'Pesagem 30 dias';
      case '60d':
        return 'Pesagem 60 dias';
      case '90d':
        return 'Pesagem 90 dias';
      case '120d':
        return 'Pesagem 120 dias';
      case 'monthly':
        return 'Pesagem mensal';
      default:
        return 'Pesagem';
    }
  }
}
