import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/animal.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final Function(Animal)? onEdit;

  const AnimalCard({
    super.key, 
    required this.animal,
    this.onEdit,
  });

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (animal.status.toLowerCase()) {
      case 'saudável':
        return theme.colorScheme.primary;
      case 'em tratamento':
        return theme.colorScheme.error;
      case 'reprodutor':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context);
    final hasHealthIssue = animal.healthIssue != null;

    return Card(
      elevation: hasHealthIssue ? 4 : 2,
      shadowColor: hasHealthIssue 
          ? theme.colorScheme.error.withOpacity(0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  animal.speciesIcon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        animal.code,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(animal.status),
                  backgroundColor: statusColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(color: statusColor.withOpacity(0.2)),
                ),
                if (animal.pregnant)
                  Chip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.child_care, size: 16),
                        SizedBox(width: 4),
                        Text('Gestante'),
                      ],
                    ),
                    backgroundColor: theme.colorScheme.tertiary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.tertiary.withOpacity(0.2),
                    ),
                  ),
                if (hasHealthIssue)
                  Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, size: 16),
                        const SizedBox(width: 4),
                        Text(animal.healthIssue!),
                      ],
                    ),
                    backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.error.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Animal Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raça',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        animal.breed,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Idade',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        animal.ageText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.monitor_weight, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${animal.weight}kg',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 4),
                Text(
                  animal.location,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Expected Delivery
            if (animal.pregnant && animal.expectedDelivery != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Parto previsto: ${DateFormat('dd/MM/yyyy').format(animal.expectedDelivery!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            if (animal.pregnant && animal.expectedDelivery != null)
              const SizedBox(height: 8),

            // Last Vaccination
            if (animal.lastVaccination != null)
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Última vacinação: ${DateFormat('dd/MM/yyyy').format(animal.lastVaccination!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Ver Histórico'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEdit != null ? () => onEdit!(animal) : null,
                    child: const Text('Editar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}