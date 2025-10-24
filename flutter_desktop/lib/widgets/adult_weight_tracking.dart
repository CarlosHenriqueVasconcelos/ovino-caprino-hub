import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../models/animal.dart';
import '../data/local_db.dart';
import '../data/animal_repository.dart';

class AdultWeightTracking extends StatefulWidget {
  const AdultWeightTracking({super.key});

  @override
  State<AdultWeightTracking> createState() => _AdultWeightTrackingState();
}

class _AdultWeightTrackingState extends State<AdultWeightTracking> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                          Icons.scale,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Controle de Peso - Animais Adultos',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Acompanhe o desenvolvimento dos animais adultos com controle de 5 meses. '
                      'Registre pesagens mensais e monitore a evolução de peso ao longo do tempo.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Search Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar animal adulto',
                    hintText: 'Digite o nome ou código do animal...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Adult Animals List
            Consumer<AnimalService>(
              builder: (context, animalService, _) {
                final adults = _getFilteredAdults(animalService.animals);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Animais Adultos',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${adults.length} animais',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (adults.isEmpty)
                          _buildEmptyState(theme)
                        else
                          _buildAdultsList(theme, adults),
                      ],
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

  List<Animal> _getFilteredAdults(List<Animal> animals) {
    // Filtrar apenas animais adultos (não borregos)
    var adults = animals.where((animal) {
      final isBorrego = animal.category == 'Macho Borrego' ||
          animal.category == 'Fêmea Borrega';
      return !isBorrego;
    }).toList();

    // Aplicar filtro de pesquisa
    if (_searchQuery.isNotEmpty) {
      adults = adults.where((animal) {
        return animal.name.toLowerCase().contains(_searchQuery) ||
            animal.code.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return adults;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.scale_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Nenhum animal adulto cadastrado'
                  : 'Nenhum animal encontrado',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Cadastre animais adultos ou promova borregos'
                  : 'Tente outra pesquisa',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdultsList(ThemeData theme, List<Animal> adults) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final adult = adults[index];
        return _buildAdultCard(theme, adult);
      },
    );
  }

  Widget _buildAdultCard(ThemeData theme, Animal adult) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  adult.speciesIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${adult.name} (${adult.code})',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${adult.breed} • ${adult.gender} • ${adult.category}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Peso atual: ${adult.weight.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Monthly Weight Control
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Controle de 5 Meses',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getMonthlyWeights(adult.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final weights = snapshot.data!;
                    return Column(
                      children: [
                        for (int i = 1; i <= 5; i++)
                          _buildMonthField(theme, i, weights),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showMonthlyWeightDialog(adult),
              icon: const Icon(Icons.add),
              label: const Text('Registrar Pesagem Mensal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthField(
      ThemeData theme, int month, List<Map<String, dynamic>> weights) {
    final monthWeight = weights.where((w) {
      final milestone = w['milestone']?.toString();
      return milestone == 'monthly_$month';
    }).toList();

    final weight = monthWeight.isNotEmpty
        ? (monthWeight.first['weight'] as num).toDouble()
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Mês $month',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              weight != null
                  ? '${weight.toStringAsFixed(1)} kg'
                  : 'Não registrado',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: weight != null ? FontWeight.bold : FontWeight.normal,
                color: weight != null
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getMonthlyWeights(String animalId) async {
    final db = await AppDatabase.open();
    final repo = AnimalRepository(db);
    return await repo.getMonthlyWeights(animalId);
  }

  void _showMonthlyWeightDialog(Animal animal) {
    final theme = Theme.of(context);
    final weightController = TextEditingController();
    int? selectedMonth;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Registrar Pesagem Mensal - ${animal.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Selecione o mês',
                  border: OutlineInputBorder(),
                ),
                items: [1, 2, 3, 4, 5].map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text('Mês $month'),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedMonth = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedMonth == null || weightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos'),
                    ),
                  );
                  return;
                }

                final weight = double.tryParse(weightController.text);
                if (weight == null) return;

                try {
                  final db = await AppDatabase.open();
                  final repo = AnimalRepository(db);
                  await repo.addWeight(
                    animal.id,
                    DateTime.now(),
                    weight,
                    milestone: 'monthly_$selectedMonth',
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pesagem registrada com sucesso!'),
                      ),
                    );
                    setState(() {}); // Refresh the list
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar: $e')),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
