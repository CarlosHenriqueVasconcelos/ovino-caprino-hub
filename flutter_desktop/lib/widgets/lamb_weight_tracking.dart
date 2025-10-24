import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../models/animal.dart';
import '../data/local_db.dart';
import '../data/animal_repository.dart';

class LambWeightTracking extends StatefulWidget {
  const LambWeightTracking({super.key});

  @override
  State<LambWeightTracking> createState() => _LambWeightTrackingState();
}

class _LambWeightTrackingState extends State<LambWeightTracking> {
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
                          Icons.baby_changing_station,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Controle de Peso - Borregos',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Acompanhe o desenvolvimento dos borregos desde o nascimento até 120 dias. '
                      'Monitore o ganho de peso e identifique animais com crescimento inadequado.',
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
                    labelText: 'Pesquisar borrego',
                    hintText: 'Digite o nome/número do borrego...',
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

            // Weight Gain Metrics Card
            Card(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Métricas de Ganho de Peso Adequado',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMetricRow(theme, 'Nascimento', '3,5-7 kg', 'Peso inicial saudável'),
                    const Divider(),
                    _buildMetricRow(theme, '30 dias', '10-15 kg', 'Ganho adequado'),
                    const Divider(),
                    _buildMetricRow(theme, '60 dias', '15-20 kg', 'Desenvolvimento normal'),
                    const Divider(),
                    _buildMetricRow(theme, '90 dias', '20-40 kg', 'Crescimento ideal'),
                    const Divider(),
                    _buildMetricRow(theme, '120 dias', '25-50 kg', 'Próximo à idade adulta'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lambs Weight List
            Consumer<AnimalService>(
              builder: (context, animalService, _) {
                final lambs = _getFilteredLambs(animalService.animals);
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Borregos Cadastrados',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${lambs.length} borregos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        if (lambs.isEmpty)
                          _buildEmptyState(theme)
                        else
                          _buildLambsList(theme, lambs),
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

  Widget _buildMetricRow(ThemeData theme, String period, String weight, String gain) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              period,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weight,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  gain,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Animal> _getFilteredLambs(List<Animal> animals) {
    // Filtrar apenas borregos (machos e fêmeas)
    var lambs = animals.where((animal) {
      return animal.category == 'Macho Borrego' || 
             animal.category == 'Fêmea Borrega';
    }).toList();

    // Aplicar filtro de pesquisa
    if (_searchQuery.isNotEmpty) {
      lambs = lambs.where((animal) {
        return animal.name.toLowerCase().contains(_searchQuery) ||
               animal.code.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return lambs;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.baby_changing_station_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'Nenhum borrego cadastrado'
                  : 'Nenhum borrego encontrado',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Cadastre animais com categoria "Macho Borrego" ou "Fêmea Borrega"'
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

  Widget _buildLambsList(ThemeData theme, List<Animal> lambs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lambs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final lamb = lambs[index];
        return _buildLambCard(theme, lamb);
      },
    );
  }

  Widget _buildLambCard(ThemeData theme, Animal lamb) {
    // Calcular idade em dias
    final ageInDays = DateTime.now().difference(lamb.birthDate).inDays;
    
    // Verificar status do ganho de peso
    final weightStatus = _calculateWeightStatus(lamb, ageInDays);

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
                  color: _getColorFromName(lamb.nameColor).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lamb.speciesIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          lamb.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getColorFromName(lamb.nameColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${lamb.code})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${lamb.breed} • ${lamb.gender} • ${lamb.category}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Idade: $ageInDays dias',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showWeightEditDialog(lamb),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Weight Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildWeightField(theme, 'Nascimento', lamb.birthWeight, Colors.blue),
                const SizedBox(height: 12),
                _buildWeightField(theme, '30 dias', lamb.weight30Days, Colors.green),
                const SizedBox(height: 12),
                _buildWeightField(theme, '60 dias', lamb.weight60Days, Colors.orange),
                const SizedBox(height: 12),
                _buildWeightField(theme, '90 dias', lamb.weight90Days, Colors.purple),
                const SizedBox(height: 12),
                FutureBuilder<double?>(
                  future: _getWeight120Days(lamb.id),
                  builder: (context, snapshot) {
                    return _buildWeightField(theme, '120 dias', snapshot.data, Colors.teal);
                  },
                ),
              ],
            ),
          ),
          
          // Weight Status
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: weightStatus['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: weightStatus['color'].withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  weightStatus['icon'],
                  color: weightStatus['color'],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    weightStatus['message'],
                    style: TextStyle(
                      color: weightStatus['color'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Promote to Adult Button
          if (ageInDays >= 120)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _promoteToAdult(lamb),
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Promover para Adulto'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeightField(ThemeData theme, String period, double? weight, Color color) {
    return Row(
      children: [
        Container(
          width: 90,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            period,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            weight != null ? '${weight.toStringAsFixed(1)} kg' : 'Não registrado',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: weight != null ? FontWeight.bold : FontWeight.normal,
              color: weight != null 
                  ? theme.colorScheme.onSurface 
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<double?> _getWeight120Days(String animalId) async {
    final db = await LocalDatabase.instance.database;
    final repo = AnimalRepository(db);
    final weights = await repo.getWeightRecord(animalId, '120d');
    return weights.isNotEmpty ? weights.first['weight'] as double : null;
  }

  Map<String, dynamic> _calculateWeightStatus(Animal lamb, int ageInDays) {
    double? relevantWeight;
    double minExpected = 0;
    double maxExpected = 0;

    if (ageInDays < 30) {
      relevantWeight = lamb.birthWeight;
      minExpected = 3.5;
      maxExpected = 7.0;
    } else if (ageInDays < 60) {
      relevantWeight = lamb.weight30Days;
      minExpected = 10.0;
      maxExpected = 15.0;
    } else if (ageInDays < 90) {
      relevantWeight = lamb.weight60Days;
      minExpected = 15.0;
      maxExpected = 20.0;
    } else if (ageInDays < 120) {
      relevantWeight = lamb.weight90Days;
      minExpected = 20.0;
      maxExpected = 40.0;
    } else {
      // Buscar peso de 120 dias (será feito assincronamente)
      minExpected = 25.0;
      maxExpected = 50.0;
      // Usa o peso de 90 dias como fallback
      relevantWeight = lamb.weight90Days;
    }

    if (relevantWeight == null) {
      return {
        'color': Colors.grey,
        'icon': Icons.help_outline,
        'message': 'Peso não registrado para este período',
      };
    }

    if (relevantWeight < minExpected) {
      return {
        'color': Colors.red,
        'icon': Icons.trending_down,
        'message': 'Abaixo do peso esperado - Atenção necessária',
      };
    } else if (relevantWeight > maxExpected) {
      return {
        'color': Colors.orange,
        'icon': Icons.trending_up,
        'message': 'Acima do peso esperado',
      };
    } else {
      return {
        'color': Colors.green,
        'icon': Icons.check_circle,
        'message': 'Desenvolvimento adequado',
      };
    }
  }

  void _promoteToAdult(Animal lamb) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promover para Adulto'),
        content: Text(
          'Tem certeza que deseja promover ${lamb.name} para adulto?\n\n'
          'A categoria será alterada para "${lamb.gender == 'Macho' ? 'Macho Reprodutor' : 'Fêmea Reprodutora'}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Promover'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final newCategory = lamb.gender == 'Macho' 
        ? 'Macho Reprodutor' 
        : 'Fêmea Reprodutora';

    final updatedAnimal = Animal(
      id: lamb.id,
      code: lamb.code,
      name: lamb.name,
      nameColor: lamb.nameColor,
      category: newCategory,
      species: lamb.species,
      breed: lamb.breed,
      gender: lamb.gender,
      birthDate: lamb.birthDate,
      weight: lamb.weight,
      status: lamb.status,
      location: lamb.location,
      lastVaccination: lamb.lastVaccination,
      pregnant: lamb.pregnant,
      expectedDelivery: lamb.expectedDelivery,
      healthIssue: lamb.healthIssue,
      birthWeight: lamb.birthWeight,
      weight30Days: lamb.weight30Days,
      weight60Days: lamb.weight60Days,
      weight90Days: lamb.weight90Days,
      createdAt: lamb.createdAt,
      updatedAt: DateTime.now(),
    );

    if (mounted) {
      await Provider.of<AnimalService>(context, listen: false)
          .updateAnimal(updatedAnimal);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lamb.name} promovido para $newCategory!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Color _getColorFromName(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'vermelho':
      case 'red':
        return Colors.red;
      case 'azul':
      case 'blue':
        return Colors.blue;
      case 'verde':
      case 'green':
        return Colors.green;
      case 'amarelo':
      case 'yellow':
        return Colors.yellow;
      case 'laranja':
      case 'orange':
        return Colors.orange;
      case 'roxo':
      case 'purple':
        return Colors.purple;
      case 'rosa':
      case 'pink':
        return Colors.pink;
      case 'preto':
      case 'black':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  void _showWeightEditDialog(Animal lamb) {
    // Pega automaticamente o birthWeight do banco, ou usa o peso atual se não houver
    final initialBirthWeight = lamb.birthWeight ?? lamb.weight;
    final birthWeightController = TextEditingController(
      text: initialBirthWeight.toStringAsFixed(1),
    );
    final weight30Controller = TextEditingController(
      text: lamb.weight30Days?.toStringAsFixed(1) ?? '',
    );
    final weight60Controller = TextEditingController(
      text: lamb.weight60Days?.toStringAsFixed(1) ?? '',
    );
    final weight90Controller = TextEditingController(
      text: lamb.weight90Days?.toStringAsFixed(1) ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Pesos - ${lamb.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWeightInput('Peso ao Nascimento (kg)', birthWeightController),
              const SizedBox(height: 16),
              _buildWeightInput('Peso aos 30 dias (kg)', weight30Controller),
              const SizedBox(height: 16),
              _buildWeightInput('Peso aos 60 dias (kg)', weight60Controller),
              const SizedBox(height: 16),
              _buildWeightInput('Peso aos 90 dias (kg)', weight90Controller),
              const SizedBox(height: 16),
              const Text(
                'Para registrar peso de 120 dias, use o controle de peso geral.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedLamb = Animal(
                id: lamb.id,
                code: lamb.code,
                name: lamb.name,
                nameColor: lamb.nameColor,
                category: lamb.category,
                species: lamb.species,
                breed: lamb.breed,
                gender: lamb.gender,
                birthDate: lamb.birthDate,
                weight: lamb.weight,
                status: lamb.status,
                location: lamb.location,
                lastVaccination: lamb.lastVaccination,
                pregnant: lamb.pregnant,
                expectedDelivery: lamb.expectedDelivery,
                healthIssue: lamb.healthIssue,
                birthWeight: double.tryParse(birthWeightController.text),
                weight30Days: double.tryParse(weight30Controller.text),
                weight60Days: double.tryParse(weight60Controller.text),
                weight90Days: double.tryParse(weight90Controller.text),
                createdAt: lamb.createdAt,
                updatedAt: DateTime.now(),
              );

              Provider.of<AnimalService>(context, listen: false)
                  .updateAnimal(updatedLamb);
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pesos atualizados com sucesso!')),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: 'kg',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
    );
  }
}
