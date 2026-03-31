import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/weight_service.dart';
import '../../../../shared/widgets/animal/animal_form.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/app_empty_state.dart';
import '../../../../shared/widgets/common/metric_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/animal_display_utils.dart';
import '../../../../utils/animal_record_display.dart';
import 'weight_tracking_filters_bar.dart';
import 'weight_tracking_pagination_bar.dart';

class LambWeightTracking extends StatefulWidget {
  const LambWeightTracking({super.key});

  @override
  State<LambWeightTracking> createState() => _LambWeightTrackingState();
}

class _LambWeightTrackingState extends State<LambWeightTracking> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _itemsPerPage = 25;
  Future<HerdQueryResult>? _future;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          const AppCard(
            variant: AppCardVariant.soft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Borregos',
                  subtitle:
                      'Acompanhe crescimento e marcos de pesagem entre nascimento e 120 dias',
                ),
                SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusChip(
                      label: 'Marcos: 30/60/90/120d',
                      icon: Icons.timeline,
                      variant: StatusChipVariant.info,
                    ),
                    StatusChip(
                      label: 'Foco em ganho de peso',
                      icon: Icons.trending_up,
                      variant: StatusChipVariant.neutral,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          WeightTrackingFiltersBar(
            searchController: _searchController,
            searchLabel: 'Pesquisar borrego',
            searchHint: 'Digite o nome ou código do borrego...',
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
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            variant: AppCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Referências de ganho',
                  subtitle: 'Faixas recomendadas por fase de crescimento',
                ),
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 860 ? 3 : (width >= 560 ? 2 : 1);
                    return GridView.count(
                      crossAxisCount: columns,
                      crossAxisSpacing: AppSpacing.xs,
                      mainAxisSpacing: AppSpacing.xs,
                      childAspectRatio: columns == 1 ? 2.9 : 2.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        MetricCard(
                          title: 'Nascimento',
                          value: '3,5 - 7 kg',
                          subtitle: 'Peso inicial saudável',
                          icon: Icons.monitor_weight_outlined,
                        ),
                        MetricCard(
                          title: '30 dias',
                          value: '10 - 15 kg',
                          subtitle: 'Ganho adequado',
                          icon: Icons.straighten,
                        ),
                        MetricCard(
                          title: '60 dias',
                          value: '15 - 20 kg',
                          subtitle: 'Desenvolvimento normal',
                          icon: Icons.straighten,
                        ),
                        MetricCard(
                          title: '90 dias',
                          value: '20 - 40 kg',
                          subtitle: 'Crescimento ideal',
                          icon: Icons.straighten,
                          accentColor: AppColors.primarySupport,
                        ),
                        MetricCard(
                          title: '120 dias',
                          value: '25 - 50 kg',
                          subtitle: 'Transição para fase adulta',
                          icon: Icons.straighten,
                          accentColor: AppColors.warning,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<HerdQueryResult>(
            future: _future ??= context.read<AnimalService>().herdQuery(
                  categoryFilter: 'Borrego',
                  searchQuery: _searchQuery,
                  page: _currentPage,
                  pageSize: _itemsPerPage,
                ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppCard(
                  variant: AppCardVariant.elevated,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final result = snapshot.data;
              final lambs = (result?.items ?? const <Animal>[]).toList();
              AnimalDisplayUtils.sortAnimalsList(lambs);
              final total = result?.total ?? 0;
              final totalPages = (total / _itemsPerPage).ceil().clamp(1, 9999);

              return AppCard(
                variant: AppCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Registros de Borregos',
                      subtitle: '$total ${total == 1 ? 'animal' : 'animais'}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (lambs.isEmpty) _buildEmptyState() else _buildLambsList(theme, lambs),
                    const SizedBox(height: AppSpacing.sm),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      title: _searchQuery.isEmpty
          ? 'Nenhum borrego cadastrado'
          : 'Nenhum borrego encontrado',
      description: _searchQuery.isEmpty
          ? 'Cadastre animais com categoria Borrego.'
          : 'Tente outra pesquisa.',
      icon: Icons.baby_changing_station_outlined,
      action: PrimaryButton(
        label: 'Limpar busca',
        icon: Icons.refresh,
        onPressed: _searchQuery.isEmpty
            ? null
            : () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _currentPage = 0;
                  _future = null;
                });
              },
      ),
    );
  }

  Widget _buildLambsList(ThemeData theme, List<Animal> lambs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: false, // Reduz memória
      addRepaintBoundaries: true,    // Evita repaint desnecessário
      cacheExtent: 500,              // Pre-carrega itens próximos
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

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorFromName(lamb.nameColor).withValues(alpha: 0.2),
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
                    _buildAnimalNameText(lamb, theme),
                    Text(
                      '${lamb.breed} • ${lamb.gender} • ${lamb.category}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Idade: $ageInDays dias',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildWeightField(
                    theme, 'Nascimento', lamb.birthWeight, Colors.blue),
                const SizedBox(height: 12),
                _buildWeightField(
                    theme, '30 dias', lamb.weight30Days, Colors.green),
                const SizedBox(height: 12),
                _buildWeightField(
                    theme, '60 dias', lamb.weight60Days, Colors.orange),
                const SizedBox(height: 12),
                _buildWeightField(
                    theme, '90 dias', lamb.weight90Days, Colors.purple),
                const SizedBox(height: 12),
                FutureBuilder<double?>(
                  future: _getWeight120Days(lamb.id),
                  builder: (context, snapshot) {
                    return _buildWeightField(
                        theme, '120 dias', snapshot.data, Colors.teal);
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
              color: weightStatus['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: weightStatus['color'].withValues(alpha: 0.3)),
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
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () => _promoteToAdult(lamb),
                  icon: Icons.upgrade,
                  label: 'Promover para Adulto',
                  fullWidth: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeightField(
      ThemeData theme, String period, double? weight, Color color) {
    return Row(
      children: [
        Container(
          width: 90,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
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
            weight != null
                ? '${weight.toStringAsFixed(1)} kg'
                : 'Não registrado',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: weight != null ? FontWeight.bold : FontWeight.normal,
              color: weight != null
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<double?> _getWeight120Days(String animalId) async {
    final weightService = Provider.of<WeightService>(context, listen: false);
    return await weightService.getWeight120Days(animalId);
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
          'A categoria será alterada para "Reprodutor".',
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

    const newCategory = 'Reprodutor';

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
      case 'cinza':
      case 'grey':
        return Colors.grey;
      case 'branca':
      case 'white':
        return Colors.white70;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAnimalNameText(Animal lamb, ThemeData theme) {
    final record = {
      'animal_name': lamb.name,
      'animal_code': lamb.code,
      'animal_color': lamb.nameColor,
    };
    final label = AnimalRecordDisplay.labelFromRecord(record);
    final accent = AnimalRecordDisplay.colorFromDescriptor(lamb.nameColor);

    return Text(
      label,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: accent ?? theme.colorScheme.onSurface,
      ),
    );
  }

  void _showWeightEditDialog(Animal lamb) async {
    // Buscar peso de nascimento do histórico se não houver no animal
    double? initialBirthWeight = lamb.birthWeight;
    if (initialBirthWeight == null || initialBirthWeight == 0) {
      // Tentar buscar do histórico de pesos
      final weightService = Provider.of<WeightService>(context, listen: false);
      final weightHistory = await weightService.getWeightHistory(lamb.id);

      // Procurar por peso de nascimento ou o primeiro peso registrado
      final birthRecord = weightHistory
          .where((w) =>
              w['milestone']?.toString() == 'birth' ||
              w['milestone']?.toString() == 'nascimento')
          .toList();

      if (birthRecord.isNotEmpty) {
        initialBirthWeight = (birthRecord.first['weight'] as num?)?.toDouble();
      } else if (weightHistory.isNotEmpty) {
        // Usar o primeiro peso registrado se não houver peso específico de nascimento
        initialBirthWeight = (weightHistory.last['weight'] as num?)?.toDouble();
      } else {
        initialBirthWeight = lamb.weight;
      }
    }

    final birthWeightController = TextEditingController(
      text: initialBirthWeight?.toStringAsFixed(1) ?? '',
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

    // Buscar peso de 120 dias existente
    final weight120 = await _getWeight120Days(lamb.id);
    final weight120Controller = TextEditingController(
      text: weight120?.toStringAsFixed(1) ?? '',
    );

    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar Pesos - ${lamb.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWeightInput(
                  'Peso ao Nascimento (kg)', birthWeightController),
              const SizedBox(height: 16),
              _buildWeightInput('Peso aos 30 dias (kg)', weight30Controller),
              const SizedBox(height: 16),
              _buildWeightInput('Peso aos 60 dias (kg)', weight60Controller),
              const SizedBox(height: 16),
              _buildWeightInput('Peso aos 90 dias (kg)', weight90Controller),
              const SizedBox(height: 16),
              _buildWeightInput('Peso aos 120 dias (kg)', weight120Controller),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final birthWeightValue =
                  double.tryParse(birthWeightController.text);
              final weight30Value = double.tryParse(weight30Controller.text);
              final weight60Value = double.tryParse(weight60Controller.text);
              final weight90Value = double.tryParse(weight90Controller.text);
              final weight120Value = double.tryParse(weight120Controller.text);

              double? determineWeight() {
                if (weight120Value != null && weight120Value > 0) {
                  return weight120Value;
                }
                if (weight90Value != null && weight90Value > 0) {
                  return weight90Value;
                }
                if (weight60Value != null && weight60Value > 0) {
                  return weight60Value;
                }
                if (weight30Value != null && weight30Value > 0) {
                  return weight30Value;
                }
                if (birthWeightValue != null && birthWeightValue > 0) {
                  return birthWeightValue;
                }
                return lamb.weight;
              }

              final updatedLamb = lamb.copyWith(
                birthWeight: birthWeightValue,
                weight30Days: weight30Value,
                weight60Days: weight60Value,
                weight90Days: weight90Value,
                weight: determineWeight(),
                updatedAt: DateTime.now(),
              );

              final animalService =
                  Provider.of<AnimalService>(context, listen: false);
              final weightService =
                  Provider.of<WeightService>(context, listen: false);
              await animalService.updateAnimal(updatedLamb);

              bool shouldShowEditDialog = false;
              if (weight120Value != null && weight120Value > 0) {
                await weightService.addWeight(
                  lamb.id,
                  DateTime.now(),
                  weight120Value,
                  milestone: '120d',
                );
                shouldShowEditDialog = true;
              }

              if (!mounted) return;
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Pesos atualizados com sucesso!')),
              );

              if (shouldShowEditDialog) {
                await Future.delayed(const Duration(milliseconds: 300));
                if (!mounted) return;
                final adultAnimal = updatedLamb.copyWith(category: 'Adulto');
                showDialog(
                  context: context,
                  builder: (context) => AnimalFormDialog(animal: adultAnimal),
                );
              }
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
