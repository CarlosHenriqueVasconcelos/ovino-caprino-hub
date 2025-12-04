import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/weight_alert.dart';
import '../../services/weight_alert_service.dart';
import '../../utils/animal_record_display.dart';

class WeightAlertsCard extends StatefulWidget {
  const WeightAlertsCard({super.key});

  @override
  State<WeightAlertsCard> createState() => _WeightAlertsCardState();
}

class _WeightAlertsCardState extends State<WeightAlertsCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeightAlertService>().loadPending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<WeightAlertService>(
      builder: (context, weightAlertService, _) {
        final alerts = weightAlertService.pendingAlerts;

        if (!weightAlertService.hasLoadedPending) {
          return _buildLoadingCard();
        }

        if (alerts.isEmpty) {
          return _buildEmptyState(theme);
        }

        final isMobile = MediaQuery.of(context).size.width < 600;
        
        return Card(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monitor_weight,
                      size: isMobile ? 20 : 28,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        isMobile ? 'Alertas Pesagem' : 'Alertas de Pesagem',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 8 : 12,
                        vertical: isMobile ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${alerts.length}',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...alerts.take(5).map(
                      (alert) => _buildAlertItem(theme, alert),
                    ),
                if (alerts.length > 5) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'e mais ${alerts.length - 5} alertas...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_weight,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Alertas de Pesagem',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todas as pesagens em dia!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(ThemeData theme, WeightAlert alert) {
    final isOverdue = alert.dueDate.isBefore(DateTime.now());
    final daysUntil = alert.dueDate.difference(DateTime.now()).inDays;
    final label = AnimalRecordDisplay.labelFromRecord(alert.extra);
    final color = AnimalRecordDisplay.colorFromRecord(alert.extra);
    final isMobile = MediaQuery.of(context).size.width < 600;

    String alertTitle;
    switch (alert.alertType) {
      case '30d':
        alertTitle = 'Pesagem 30 dias';
        break;
      case '60d':
        alertTitle = 'Pesagem 60 dias';
        break;
      case '90d':
        alertTitle = 'Pesagem 90 dias';
        break;
      case '120d':
        alertTitle = 'Pesagem 120 dias';
        break;
      case 'monthly':
        alertTitle = 'Pesagem mensal';
        break;
      default:
        alertTitle = 'Pesagem';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: isOverdue
            ? theme.colorScheme.error.withValues(alpha: 0.05)
            : theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monitor_weight,
            color:
                isOverdue ? theme.colorScheme.error : theme.colorScheme.primary,
            size: isMobile ? 18 : 20,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: isMobile ? 12 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  alertTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: isMobile ? 10 : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: isOverdue
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isOverdue
                  ? 'Vencido'
                  : daysUntil == 0
                      ? 'Hoje'
                      : '$daysUntil ${isMobile ? 'd' : 'dias'}',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
