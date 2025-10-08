import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';

class VaccinationAlerts extends StatelessWidget {
  const VaccinationAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<DashboardAlerts>(
          future: context.read<AnimalService>().getDashboardAlerts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text('Carregando alertas...', style: theme.textTheme.bodyMedium),
                ],
              );
            }

            final alerts = snapshot.data ??
                DashboardAlerts(
                  totalVaccinations: 0,
                  totalMedications: 0,
                  vaccinations: const [],
                  medications: const [],
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Alertas de Vacinação e Medicação',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Chips de resumo
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _metricChip(Icons.vaccines, 'Vacinações: ${alerts.totalVaccinations}', theme),
                    _metricChip(Icons.medication, 'Medicações: ${alerts.totalMedications}', theme),
                  ],
                ),

                const SizedBox(height: 12),

                if (!alerts.hasAny)
                  Text('Sem alertas por enquanto.', style: theme.textTheme.bodyMedium),

                if (alerts.vaccinations.isNotEmpty) ...[
                  Text('Próximas vacinações', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...alerts.vaccinations.take(5).map((v) => _line(
                        context,
                        icon: Icons.vaccines,
                        title:
                            '${v['vaccine_name']} — ${v['animal_code'] ?? ''} ${v['animal_name'] ?? ''}'.trim(),
                        date: v['scheduled_date'],
                      )),
                  const SizedBox(height: 8),
                ],

                if (alerts.medications.isNotEmpty) ...[
                  Text('Próximas medicações', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...alerts.medications.take(5).map((m) => _line(
                        context,
                        icon: Icons.medication,
                        title:
                            '${m['medication_name']} — ${m['animal_code'] ?? ''} ${m['animal_name'] ?? ''}'.trim(),
                        date: m['next_date'],
                      )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metricChip(IconData icon, String text, ThemeData theme) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
    );
  }

  Widget _line(BuildContext context,
      {required IconData icon, required String title, String? date}) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: date != null ? Text(date) : null,
    );
  }
}
