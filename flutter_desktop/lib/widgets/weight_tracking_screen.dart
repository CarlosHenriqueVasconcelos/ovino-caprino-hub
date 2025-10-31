import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../models/animal.dart';
import 'lamb_weight_tracking.dart';
import 'adult_weight_tracking.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'Todos',
    'Jovens (< 12 meses)',
    'Adultos',
    'Reprodutores'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Tab Bar
        Container(
          color: theme.scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor:
                theme.colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.monitor_weight), text: 'Geral'),
              Tab(icon: Icon(Icons.baby_changing_station), text: 'Borregos'),
              Tab(icon: Icon(Icons.scale), text: 'Adultos'),
            ],
          ),
        ),

        // Tab View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralWeightTracking(theme),
              const LambWeightTracking(),
              const AdultWeightTracking(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralWeightTracking(ThemeData theme) {
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
                        Icon(Icons.monitor_weight,
                            size: 28, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Controle de Peso e Desenvolvimento',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Monitore o desenvolvimento dos animais através do controle de peso. '
                      'Acompanhe o crescimento por categoria de idade e identifique animais com peso inadequado.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
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
                    labelText: 'Pesquisar animal',
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

            // Filters Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Text(
                      'Filtrar por categoria:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: _categories.map((category) {
                          final isSelected = category == _selectedCategory;
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            backgroundColor: theme.colorScheme.surface,
                            selectedColor: theme.colorScheme.primary
                                .withOpacity(0.2),
                            checkmarkColor: theme.colorScheme.primary,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Weight Statistics + List
            Consumer<AnimalService>(
              builder: (context, animalService, _) {
                // ⚠️ SEMPRE trabalhar com cópia mutável, nunca diretamente com animalService.animals
                final filteredAnimals =
                    _getFilteredAnimals(animalService.animals);

                return Column(
                  children: [
                    _buildWeightStats(theme, filteredAnimals),
                    const SizedBox(height: 24),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peso dos Animais',
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),

                            if (filteredAnimals.isEmpty)
                              _buildEmptyState(theme)
                            else
                              _buildAnimalWeightList(theme, filteredAnimals),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Animal> _getFilteredAnimals(List<Animal> animals) {
    // Ponto crítico: comece de uma CÓPIA mutável
    var filtered = animals.toList(growable: true);

    // Aplicar filtro de categoria
    switch (_selectedCategory) {
      case 'Jovens (< 12 meses)':
        filtered = filtered
            .where((a) => _getAgeInMonths(a.birthDate) < 12)
            .toList();
        break;
      case 'Adultos':
        filtered = filtered
            .where((a) =>
                _getAgeInMonths(a.birthDate) >= 12 &&
                !(a.category).contains('Reprodutor'))
            .toList();
        break;
      case 'Reprodutores':
        filtered = filtered
            .where((a) => (a.category).contains('Reprodutor'))
            .toList();
        break;
      default:
        // 'Todos' - mantém a lista filtrada
        break;
    }

    // Aplicar filtro de pesquisa
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((animal) {
        return animal.name.toLowerCase().contains(_searchQuery) ||
               animal.code.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  int _getAgeInMonths(DateTime birthDate) {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

  Widget _buildWeightStats(ThemeData theme, List<Animal> animals) {
    if (animals.isEmpty) return const SizedBox.shrink();

    final weights = animals.map((a) => a.weight).toList();
    final avgWeight =
        weights.reduce((a, b) => a + b) / weights.length;
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    final underweight = animals
        .where((a) => a.weight < _getIdealWeightRange(a)['min']!)
        .length;
    final overweight = animals
        .where((a) => a.weight > _getIdealWeightRange(a)['max']!)
        .length;
    final normalWeight = animals.length - underweight - overweight;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          theme,
          title: 'Peso Médio',
          value: '${avgWeight.toStringAsFixed(1)} kg',
          icon: Icons.bar_chart,
          color: theme.colorScheme.primary,
        ),
        _buildStatCard(
          theme,
          title: 'Peso Normal',
          value: '$normalWeight animais',
          icon: Icons.check_circle,
          color: theme.colorScheme.tertiary,
        ),
        _buildStatCard(
          theme,
          title: 'Abaixo do Peso',
          value: '$underweight animais',
          icon: Icons.trending_down,
          color: theme.colorScheme.error,
        ),
        _buildStatCard(
          theme,
          title: 'Acima do Peso',
          value: '$overweight animais',
          icon: Icons.trending_up,
          color: theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
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
            Icon(Icons.monitor_weight_outlined,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Nenhum animal encontrado',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Ajuste os filtros ou adicione animais ao rebanho',
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

  Widget _buildAnimalWeightList(ThemeData theme, List<Animal> animals) {
    // NUNCA ordene a lista recebida diretamente — crie uma cópia
    final sorted = [...animals];
    // Importar o utilitário no topo do arquivo
    // Ordenar por cor e depois por código numérico
    sorted.sort((a, b) {
      final colorA = a.nameColor ?? '';
      final colorB = b.nameColor ?? '';
      final colorCompare = colorA.compareTo(colorB);
      if (colorCompare != 0) return colorCompare;
      
      final numA = int.tryParse(RegExp(r'\d+').firstMatch(a.code)?.group(0) ?? '0') ?? 0;
      final numB = int.tryParse(RegExp(r'\d+').firstMatch(b.code)?.group(0) ?? '0') ?? 0;
      return numA.compareTo(numB);
    });

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final animal = sorted[index];
        final weightRange = _getIdealWeightRange(animal);
        final isUnderweight = animal.weight < weightRange['min']!;
        final isOverweight = animal.weight > weightRange['max']!;
        final ageInMonths = _getAgeInMonths(animal.birthDate);

        Color statusColor = theme.colorScheme.tertiary;
        IconData statusIcon = Icons.check_circle;
        String statusText = 'Normal';

        if (isUnderweight) {
          statusColor = theme.colorScheme.error;
          statusIcon = Icons.trending_down;
          statusText = 'Abaixo do peso';
        } else if (isOverweight) {
          statusColor = theme.colorScheme.secondary;
          statusIcon = Icons.trending_up;
          statusText = 'Acima do peso';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Animal Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  animal.speciesIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),

              // Animal Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${animal.name} (${animal.code})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${animal.breed} • ${animal.gender}'),
                    Text('Idade: ${ageInMonths} meses'),
                    Text(
                      'Faixa ideal: ${weightRange['min']!.toStringAsFixed(1)} - ${weightRange['max']!.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Button
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showWeightEditDialog(animal),
                tooltip: 'Editar peso',
              ),

              // Weight Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${animal.weight} kg',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, double> _getIdealWeightRange(Animal animal) {
    final ageInMonths = _getAgeInMonths(animal.birthDate);

    if (animal.species == 'Ovino') {
      if (ageInMonths < 6) {
        return {'min': 15.0, 'max': 25.0};
      } else if (ageInMonths < 12) {
        return {'min': 25.0, 'max': 40.0};
      } else if (animal.gender == 'Macho') {
        return {'min': 55.0, 'max': 80.0};
      } else {
        return {'min': 40.0, 'max': 65.0};
      }
    } else {
      // Caprino
      if (ageInMonths < 6) {
        return {'min': 10.0, 'max': 20.0};
      } else if (ageInMonths < 12) {
        return {'min': 20.0, 'max': 35.0};
      } else if (animal.gender == 'Macho') {
        return {'min': 50.0, 'max': 75.0};
      } else {
        return {'min': 35.0, 'max': 55.0};
      }
    }
  }

  void _showWeightEditDialog(Animal animal) {
    final weightController = TextEditingController(
      text: animal.weight.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Peso - ${animal.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Peso atual (kg)',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              final newWeight = double.tryParse(weightController.text);
              if (newWeight != null && newWeight > 0) {
                final updatedAnimal = animal.copyWith(
                  weight: newWeight,
                  updatedAt: DateTime.now(),
                );

                await Provider.of<AnimalService>(context, listen: false)
                    .updateAnimal(updatedAnimal);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Peso atualizado com sucesso!')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Peso inválido!')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
