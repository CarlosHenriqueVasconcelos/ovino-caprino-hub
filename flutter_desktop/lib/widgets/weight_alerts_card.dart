import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../models/alert_item.dart';

class WeightAlertsCard extends StatelessWidget {
  const WeightAlertsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AnimalService>(
      builder: (context, animalService, _) {
        final weighingAlerts = animalService.alerts
            .where((a) => a.type == AlertType.weighing)
            .toList();

        if (weighingAlerts.isEmpty) {
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
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${weighingAlerts.length} pendente${weighingAlerts.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...weighingAlerts.take(5).map((alert) {
                  return _buildAlertItem(theme, alert);
                }),
                if (weighingAlerts.length > 5) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'e mais ${weighingAlerts.length - 5} alertas...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildAlertItem(ThemeData theme, AlertItem alert) {
    final isOverdue = alert.isOverdue;
    final daysUntil = alert.dueDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue
            ? theme.colorScheme.error.withOpacity(0.05)
            : theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue
              ? theme.colorScheme.error.withOpacity(0.3)
              : theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monitor_weight,
            color: isOverdue
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alert.animalName} (${alert.animalCode})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  alert.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      : '$daysUntil dias',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
