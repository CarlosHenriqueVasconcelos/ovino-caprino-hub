import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../services/database_service.dart';

class VaccinationAlerts extends StatefulWidget {
  const VaccinationAlerts({super.key});

  @override
  State<VaccinationAlerts> createState() => _VaccinationAlertsState();
}

class _VaccinationAlertsState extends State<VaccinationAlerts> {
  List<Map<String, dynamic>> _vaccinations = [];
  List<Map<String, dynamic>> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega quando retorna para a tela
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final vaccinations = await DatabaseService.getVaccinations();
      final medications = await DatabaseService.getMedications();
      if (mounted) {
        setState(() {
          _vaccinations = vaccinations;
          _medications = medications;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animals = Provider.of<AnimalService>(context).animals;

    // Find overdue vaccinations and medications
    final overdueVaccinations = _getOverdueVaccinations(animals);
    final overdueMedications = _getOverdueMedications(animals);
    final allAlerts = [...overdueVaccinations, ...overdueMedications];

    if (allAlerts.isEmpty) {
      return const SizedBox.shrink();
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
                  Icons.notifications_active,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  'Alertas de Vacinação e Medicamentos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${allAlerts.length} pendente${allAlerts.length > 1 ? 's' : ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allAlerts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final alert = allAlerts[index];
                  return _buildAlertCard(theme, alert);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(ThemeData theme, Map<String, dynamic> alert) {
    final isVaccination = alert['type'] == 'vaccination';
    final icon = isVaccination ? Icons.vaccines : Icons.medication;
    final typeLabel = isVaccination ? 'Vacinação' : 'Medicamento';
    
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert['animalName'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              typeLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${alert['description']}',
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            'Atrasado há ${alert['daysOverdue']} dias',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getOverdueVaccinations(List<dynamic> animals) {
    final now = DateTime.now();
    final alerts = <Map<String, dynamic>>[];

    // Check scheduled vaccinations
    for (var vaccination in _vaccinations) {
      if (vaccination['next_date'] != null) {
        final nextDate = DateTime.tryParse(vaccination['next_date']);
        if (nextDate != null && nextDate.isBefore(now)) {
          final daysOverdue = now.difference(nextDate).inDays;
          final animal = animals.firstWhere(
            (a) => a.id == vaccination['animal_id'],
            orElse: () => null,
          );
          
          if (animal != null) {
            alerts.add({
              'type': 'vaccination',
              'animalName': '${animal.name} (${animal.code})',
              'daysOverdue': daysOverdue,
              'description': vaccination['vaccine_name'] ?? 'Vacina não especificada',
            });
          }
        }
      }
    }

    // Check animals without recent vaccination
    for (var animal in animals) {
      if (animal.lastVaccination != null) {
        final daysSinceVaccination = now.difference(animal.lastVaccination!).inDays;
        
        // Alert if vaccination is overdue (assuming 180 days cycle)
        if (daysSinceVaccination > 180) {
          alerts.add({
            'type': 'vaccination',
            'animalName': '${animal.name} (${animal.code})',
            'daysOverdue': daysSinceVaccination - 180,
            'description': 'Vacinação de rotina atrasada',
          });
        }
      }
    }

    return alerts;
  }

  List<Map<String, dynamic>> _getOverdueMedications(List<dynamic> animals) {
    final now = DateTime.now();
    final alerts = <Map<String, dynamic>>[];

    for (var medication in _medications) {
      if (medication['next_date'] != null) {
        final nextDate = DateTime.tryParse(medication['next_date']);
        if (nextDate != null && nextDate.isBefore(now)) {
          final daysOverdue = now.difference(nextDate).inDays;
          final animal = animals.firstWhere(
            (a) => a.id == medication['animal_id'],
            orElse: () => null,
          );
          
          if (animal != null) {
            alerts.add({
              'type': 'medication',
              'animalName': '${animal.name} (${animal.code})',
              'daysOverdue': daysOverdue,
              'description': medication['medication_name'] ?? 'Medicamento não especificado',
            });
          }
        }
      }
    }

    return alerts;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
