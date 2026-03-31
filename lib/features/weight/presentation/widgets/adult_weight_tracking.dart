import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/weight_service.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/app_empty_state.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/animal_record_display.dart';
import 'weight_tracking_filters_bar.dart';
import 'weight_tracking_pagination_bar.dart';
import 'weight_tracking_table.dart';

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
                  title: 'Adultos e Reprodutores',
                  subtitle:
                      'Acompanhe pesagens mensais de animais não borregos por até 24 meses',
                ),
                SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    StatusChip(
                      label: 'Controle mensal',
                      icon: Icons.calendar_month,
                      variant: StatusChipVariant.info,
                    ),
                    StatusChip(
                      label: 'Janela: 24 meses',
                      icon: Icons.timeline,
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
            searchLabel: 'Pesquisar animal',
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
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<WeightTrackingResult>(
            future: _future ??= context.read<AnimalService>().weightTrackingQuery(
                  category: WeightCategoryFilter.nonLambs,
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
              final nonLambAnimals = result?.items ?? const <Animal>[];
              final total = result?.total ?? 0;
              final totalPages = (total / _itemsPerPage).ceil().clamp(1, 9999);

              return AppCard(
                variant: AppCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Registros de Adultos',
                      subtitle: '$total ${total == 1 ? 'animal' : 'animais'}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    WeightTrackingTable<Animal>(
                      items: nonLambAnimals,
                      mode: WeightTrackingTableMode.list,
                      itemBuilder: (context, adult) => _buildAdultCard(context, adult),
                      emptyState: _buildEmptyState(context),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                    ),
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

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyState(
      title: 'Nenhum animal encontrado',
      description: _searchQuery.isEmpty
          ? 'Cadastre animais fora da categoria Borrego.'
          : 'Tente outra pesquisa.',
      icon: Icons.scale_outlined,
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

  Widget _buildAdultCard(BuildContext context, Animal adult) {
    final theme = Theme.of(context);
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildInitialMilestonesPanel(theme, adult),
          const SizedBox(height: 16),

          // Monthly Weight Control
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                        final isMobile = MediaQuery.of(context).size.width < 600;
                        final columns = isMobile ? 2 : 5;
                        final rowsPerColumn = isMobile ? 12 : 5;
                        
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(columns, (colIndex) {
                              return Container(
                                width: isMobile ? 120 : null,
                                padding: EdgeInsets.only(right: isMobile ? 8 : 0),
                                child: Column(
                                  children: List.generate(rowsPerColumn, (rowIndex) {
                                    final monthIndex = colIndex * rowsPerColumn + rowIndex;
                                    if (monthIndex >= 24) {
                                      return const SizedBox.shrink();
                                    }
                                    return _buildMonthField(
                                        theme, monthIndex + 1, weights);
                                  }),
                                ),
                              );
                            }),
                          ),
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
            child: PrimaryButton(
              onPressed: () => _showMonthlyWeightDialog(adult),
              fullWidth: true,
              icon: Icons.add,
              label: 'Registrar Pesagem Mensal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialMilestonesPanel(ThemeData theme, Animal adult) {
    final milestones = <({String label, double? weight})>[
      (label: 'Nascimento', weight: adult.birthWeight),
      (label: '30d', weight: adult.weight30Days),
      (label: '60d', weight: adult.weight60Days),
      (label: '90d', weight: adult.weight90Days),
      (label: '120d', weight: adult.weight120Days),
    ];
    final hasAny = milestones.any((m) => (m.weight ?? 0) > 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marcos Iniciais (Histórico)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          if (!hasAny)
            Text(
              'Nenhum marco inicial registrado.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: milestones
                  .map(
                    (m) => _buildInitialMilestoneChip(
                      theme,
                      m.label,
                      m.weight,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialMilestoneChip(
    ThemeData theme,
    String label,
    double? weight,
  ) {
    final hasValue = (weight ?? 0) > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: hasValue
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${hasValue ? '${weight!.toStringAsFixed(1)} kg' : '—'}',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
        ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'M$month',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            weight != null
                ? weight.toStringAsFixed(1)
                : '—',
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  weight != null ? FontWeight.bold : FontWeight.normal,
              color: weight != null
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                initialValue: selectedMonth,
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
