import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/animal_service.dart';
import '../models/alert_item.dart';

class VaccinationAlerts extends StatelessWidget {
  const VaccinationAlerts({super.key});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.watch<AnimalService>();
    final alerts = service.alerts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Alertas (Vacinas & Medicações)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Recarregar alertas',
                  onPressed: () => context.read<AnimalService>().refreshAlerts(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (alerts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Nenhum alerta para os próximos dias',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (_, i) {
                  final a = alerts[i];
                  final isOver = a.isOverdue;
                  final color = isOver
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(a.icon, color: color),
                    ),
                    title: Text(
                      a.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${a.animalName} (${a.animalCode}) • Para: ${_fmt(a.dueDate)}'
                      '${isOver ? ' • ATRASADO' : ''}',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(
                        a.type == AlertType.vaccination ? 'Vacina' : 'Medicação',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
