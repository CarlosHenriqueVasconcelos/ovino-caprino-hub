import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../services/weight_service.dart';
import '../models/animal.dart';
import '../utils/animal_record_display.dart';
import 'weight_tracking/weight_tracking_filters_bar.dart';
import 'weight_tracking/weight_tracking_pagination_bar.dart';
import 'weight_tracking/weight_tracking_table.dart';

class AdultWeightTracking extends StatefulWidget {
  const AdultWeightTracking({super.key});

  @override
  State<AdultWeightTracking> createState() => _AdultWeightTrackingState();
}

class _AdultWeightTrackingState extends State<AdultWeightTracking> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _itemsPerPage = 25;
  Future<WeightTrackingResult>? _future;

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
                      'Acompanhe o desenvolvimento dos animais adultos com controle de 24 meses (2 anos). '
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

            WeightTrackingFiltersBar(
              searchController: _searchController,
              searchLabel: 'Pesquisar animal adulto',
              searchHint: 'Digite o nome ou código do animal...',
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  _currentPage = 0;
                  _future = null;
                });
              },
              onClearSearch: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _currentPage = 0;
                  _future = null;
                });
              },
              dropdowns: const [],
            ),
            const SizedBox(height: 24),

            // Adult Animals List
            FutureBuilder<WeightTrackingResult>(
              future: _future ??= context
                  .read<AnimalService>()
                  .weightTrackingQuery(
                    category: WeightCategoryFilter.adults,
                    searchQuery: _searchQuery,
                    page: _currentPage,
                    pageSize: _itemsPerPage,
                  ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                final result = snapshot.data;
                final adults = result?.items ?? const <Animal>[];
                final total = result?.total ?? 0;
                final totalPages =
                    (total / _itemsPerPage).ceil().clamp(1, 9999);

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
                              '$total animais',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        WeightTrackingTable<Animal>(
                          items: adults,
                          mode: WeightTrackingTableMode.list,
                          itemBuilder: (context, adult) =>
                              _buildAdultCard(context, adult),
                          emptyState: _buildEmptyState(context),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                        ),
                        const SizedBox(height: 24),
                        WeightTrackingPaginationBar(
                          currentPage: _currentPage,
                          totalPages: totalPages,
                          itemsPerPage: _itemsPerPage,
                          onPageChanged: (page) {
                            setState(() {
                              _currentPage = page;
                              _future = null;
                            });
                          },
                        ),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
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

  Widget _buildAdultCard(BuildContext context, Animal adult) {
    final theme = Theme.of(context);
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
                    _buildAnimalNameText(adult, theme),
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
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Controle de 24 Meses (2 Anos)',
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
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(5, (colIndex) {
                        return Expanded(
                          child: Column(
                            children: List.generate(5, (rowIndex) {
                              final monthIndex = colIndex * 5 + rowIndex;
                              if (monthIndex >= 24) {
                                return const SizedBox.shrink();
                              }
                              return _buildMonthField(
                                  theme, monthIndex + 1, weights);
                            }),
                          ),
                        );
                      }),
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
                fontWeight:
                    weight != null ? FontWeight.bold : FontWeight.normal,
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
    final weightService = Provider.of<WeightService>(context, listen: false);
    return await weightService.getMonthlyWeights(animalId);
  }

  void _showMonthlyWeightDialog(Animal animal) async {
    final weightController = TextEditingController();
    final weightService = Provider.of<WeightService>(context, listen: false);
    final animalService = Provider.of<AnimalService>(context, listen: false);

    // Buscar pesos mensais existentes para determinar o próximo mês
    final existingWeights = await _getMonthlyWeights(animal.id);
    final existingMonths = existingWeights
        .where(
            (w) => w['milestone']?.toString().startsWith('monthly_') ?? false)
        .map((w) {
      final milestone = w['milestone']?.toString() ?? '';
      final monthStr = milestone.replaceFirst('monthly_', '');
      return int.tryParse(monthStr) ?? 0;
    }).toList();

    // Determinar próximo mês disponível
    int? selectedMonth;
    if (existingMonths.isEmpty) {
      selectedMonth = 1; // Primeiro registro
    } else {
      existingMonths.sort();
      final lastMonth = existingMonths.last;
      if (lastMonth < 24) {
        selectedMonth = lastMonth + 1; // Próximo mês
      } else {
        selectedMonth = null; // Todos os 24 meses já foram registrados
      }
    }

    if (!mounted) return;

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
                items: List.generate(24, (i) => i + 1).map((month) {
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                  await weightService.addWeight(
                    animal.id,
                    DateTime.now(),
                    weight,
                    milestone: 'monthly_$selectedMonth',
                  );
                  await animalService.updateAnimal(
                    animal.copyWith(
                      weight: weight,
                      updatedAt: DateTime.now(),
                    ),
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

  Widget _buildAnimalNameText(Animal animal, ThemeData theme) {
    final record = {
      'animal_name': animal.name,
      'animal_code': animal.code,
      'animal_color': animal.nameColor,
    };
    final label = AnimalRecordDisplay.labelFromRecord(record);
    final accent = AnimalRecordDisplay.colorFromDescriptor(animal.nameColor);

    return Text(
      label,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: accent ?? theme.colorScheme.onSurface,
      ),
    );
  }
}
