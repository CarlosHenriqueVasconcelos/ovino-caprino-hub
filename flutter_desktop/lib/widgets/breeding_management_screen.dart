import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../services/supabase_service.dart';
import 'breeding_form.dart';

class BreedingManagementScreen extends StatefulWidget {
  const BreedingManagementScreen({super.key});

  @override
  State<BreedingManagementScreen> createState() => _BreedingManagementScreenState();
}

class _BreedingManagementScreenState extends State<BreedingManagementScreen> {
  List<Map<String, dynamic>> _breedingRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBreedingRecords();
  }

  Future<void> _loadBreedingRecords() async {
    setState(() => _isLoading = true);
    try {
      _breedingRecords = await SupabaseService.getBreedingRecords();
    } catch (e) {
      print('Error loading breeding records: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Manejo Reprodutivo',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _showBreedingForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Nova Cobertura'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Controle completo do ciclo reprodutivo, desde a cobertura até o nascimento dos filhotes. '
                      'Acompanhe fêmeas prenhes, calcule previsões de parto e registre nascimentos.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Breeding Records
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Registros Reprodutivos',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Consumer<AnimalService>(
                          builder: (context, animalService, _) {
                            final pregnantAnimals = animalService.animals
                                .where((animal) => animal.pregnant)
                                .length;
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.tertiary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.child_care,
                                    size: 16,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$pregnantAnimals Gestantes',
                                    style: TextStyle(
                                      color: theme.colorScheme.tertiary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_breedingRecords.isEmpty)
                      _buildEmptyState(theme)
                    else
                      _buildBreedingList(theme),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pregnant Animals Card
            _buildPregnantAnimalsCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro reprodutivo',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Registre coberturas e acompanhe a reprodução do rebanho',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showBreedingForm(),
              icon: const Icon(Icons.add),
              label: const Text('Primeira Cobertura'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedingList(ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _breedingRecords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final breeding = _breedingRecords[index];
        final animalService = Provider.of<AnimalService>(context, listen: false);

        // Find female animal
        final femaleMatches = animalService.animals.where(
          (a) => a.id == breeding['female_animal_id'],
        );
        final female = femaleMatches.isNotEmpty ? femaleMatches.first : null;

        // Find male animal if exists
        final maleId = breeding['male_animal_id'];
        var male;
        if (maleId != null) {
          final maleMatches = animalService.animals.where(
            (a) => a.id == maleId,
          );
          male = maleMatches.isNotEmpty ? maleMatches.first : null;
        }

        Color statusColor;
        IconData statusIcon;
        switch (breeding['status']) {
          case 'Nasceu':
            statusColor = theme.colorScheme.primary;
            statusIcon = Icons.child_care;
            break;
          case 'Confirmada':
            statusColor = theme.colorScheme.tertiary;
            statusIcon = Icons.check_circle;
            break;
          case 'Perdida':
            statusColor = theme.colorScheme.error;
            statusIcon = Icons.cancel;
            break;
          default:
            statusColor = theme.colorScheme.secondary;
            statusIcon = Icons.help_outline;
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(statusIcon, color: statusColor),
            ),
            title: Text(
              female?.name ?? 'Animal não encontrado',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (male != null)
                  Text('Macho: ${male.name} (${male.code})'),
                if (female != null)
                  Text('Fêmea: ${female.code} - ${female.breed}'),
                Text('Data da cobertura: ${breeding['breeding_date'] ?? '-'}'),
                if (breeding['expected_birth'] != null)
                  Text('Previsão de parto: ${breeding['expected_birth']}'),
                if (breeding['notes'] != null && breeding['notes'].toString().isNotEmpty)
                  Text('Observações: ${breeding['notes']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                breeding['status'] ?? '-',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPregnantAnimalsCard(ThemeData theme) {
    return Consumer<AnimalService>(
      builder: (context, animalService, _) {
        final pregnantAnimals = animalService.animals
            .where((animal) => animal.pregnant)
            .toList();

        if (pregnantAnimals.isEmpty) {
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
                      Icons.child_care,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fêmeas Gestantes',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pregnantAnimals.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final animal = pregnantAnimals[index];
                    final daysToDelivery = animal.expectedDelivery != null
                        ? animal.expectedDelivery!.difference(DateTime.now()).inDays
                        : null;

                    return ListTile(
                      leading: Text(
                        animal.speciesIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        '${animal.name} (${animal.code})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Raça: ${animal.breed}'),
                          if (animal.expectedDelivery != null) ...[
                            Text(
                              'Parto previsto: ${animal.expectedDelivery!.day.toString().padLeft(2, '0')}/${animal.expectedDelivery!.month.toString().padLeft(2, '0')}/${animal.expectedDelivery!.year}',
                            ),
                            if (daysToDelivery != null)
                              Text(
                                daysToDelivery > 0
                                    ? 'Em $daysToDelivery dias'
                                    : daysToDelivery == 0
                                        ? 'Hoje!'
                                        : 'Atrasado ${-daysToDelivery} dias',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: daysToDelivery <= 7
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.tertiary,
                                ),
                              ),
                          ],
                        ],
                      ),
                      trailing: daysToDelivery != null && daysToDelivery <= 7
                          ? Icon(
                              Icons.warning,
                              color: theme.colorScheme.error,
                            )
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBreedingForm() {
    showDialog(
      context: context,
      builder: (context) => const BreedingFormDialog(),
    ).then((_) => _loadBreedingRecords());
  }
}