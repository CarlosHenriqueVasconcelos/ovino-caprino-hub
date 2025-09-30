import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../services/supabase_service.dart';
import '../widgets/vaccination_form.dart';

class VaccinationAlertsWidget extends StatefulWidget {
  const VaccinationAlertsWidget({super.key});

  @override
  State<VaccinationAlertsWidget> createState() => _VaccinationAlertsWidgetState();
}

class _VaccinationAlertsWidgetState extends State<VaccinationAlertsWidget> {
  List<Map<String, dynamic>> _upcomingVaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    setState(() => _isLoading = true);
    try {
      final vaccinations = await SupabaseService.getVaccinations();
      final now = DateTime.now();
      
      // Filtra vacinações agendadas nos próximos 7 dias
      final upcoming = vaccinations.where((vacc) {
        if (vacc['status'] != 'Agendada') return false;
        
        final scheduledDate = DateTime.parse(vacc['scheduled_date']);
        final daysUntil = scheduledDate.difference(now).inDays;
        
        return daysUntil >= 0 && daysUntil <= 7;
      }).toList();
      
      setState(() {
        _upcomingVaccinations = List<Map<String, dynamic>>.from(upcoming);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Consumer<AnimalService>(
      builder: (context, animalService, child) {
        final now = DateTime.now();
        
        // Alertas de vacinação vencida (mais de 90 dias)
        final overdueAnimals = animalService.animals
            .where((animal) => animal.lastVaccination != null)
            .where((animal) {
              final lastVacc = DateTime.parse(animal.lastVaccination!);
              final daysSince = now.difference(lastVacc).inDays;
              return daysSince > 90;
            })
            .take(3)
            .toList();

        final hasAlerts = overdueAnimals.isNotEmpty || _upcomingVaccinations.isNotEmpty;

        if (!hasAlerts) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vacinações e Medicamentos em Dia',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Todas as vacinações estão atualizadas! 🎉',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                      Icons.warning,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Alertas de Vacinação e Medicamentos',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${overdueAnimals.length + _upcomingVaccinations.length}',
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Vacinações vencidas
                if (overdueAnimals.isNotEmpty) ...[
                  Text(
                    'Vacinações Vencidas',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: overdueAnimals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final animal = overdueAnimals[index];
                      final daysSince = now.difference(DateTime.parse(animal.lastVaccination!)).inDays;
                      
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.error.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.vaccines,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${animal.code} - ${animal.name}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Última vacinação há $daysSince dias',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _scheduleVaccination(context, animal),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Aplicar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Vacinações agendadas
                if (_upcomingVaccinations.isNotEmpty) ...[
                  Text(
                    'Próximas Vacinações (7 dias)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _upcomingVaccinations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final vaccination = _upcomingVaccinations[index];
                      final scheduledDate = DateTime.parse(vaccination['scheduled_date']);
                      final daysUntil = scheduledDate.difference(now).inDays;
                      
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vaccination['vaccine_name'] ?? 'Vacina',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    daysUntil == 0 ? 'Hoje' : 'Em $daysUntil dias',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _scheduleVaccination(BuildContext context, animal) {
    showDialog(
      context: context,
      builder: (context) => VaccinationFormDialog(animalId: animal.id),
    ).then((_) => _loadVaccinations());
  }
}