import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/weight_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/animal_record_display.dart';
import 'weight_tracking_filters_bar.dart';
import 'weight_tracking_pagination_bar.dart';

// ── Color palette (shared with screen) ───────────────────────────────────────

const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kGold = Color(0xFFD9B15F);
const _kGoldBg = Color(0xFFFBF4E6);

class AdultWeightTracking extends StatefulWidget {
  final bool embedInParentScroll;

  const AdultWeightTracking({
    super.key,
    this.embedInParentScroll = false,
  });

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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Context card
          _buildContextCard(),
          const SizedBox(height: AppSpacing.xs),

          // Search
          WeightTrackingFiltersBar(
            searchController: _searchController,
            searchLabel: 'Pesquisar animal',
            searchHint: 'Digite o nome ou código...',
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
          const SizedBox(height: AppSpacing.xs),

          // List
          FutureBuilder<WeightTrackingResult>(
            future: _future ??=
                context.read<AnimalService>().weightTrackingQuery(
                      category: WeightCategoryFilter.nonLambs,
                      searchQuery: _searchQuery,
                      page: _currentPage,
                      pageSize: _itemsPerPage,
                    ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final result = snapshot.data;
              final animals = result?.items ?? const <Animal>[];
              final total = result?.total ?? 0;
              final totalPages =
                  (total / _itemsPerPage).ceil().clamp(1, 9999);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Registros de Adultos · $total',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _kText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (animals.isEmpty)
                    _buildEmptyState()
                  else
                    ...animals.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: _buildAdultCard(a),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xs),
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
              );
            },
          ),
      ],
    );

    if (widget.embedInParentScroll) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: content,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: content,
    );
  }

  // ── Context card ────────────────────────────────────────────────────────────

  Widget _buildContextCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adultos e Reprodutores',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Pesagem mensal por até 24 meses',
            style: TextStyle(fontSize: 8, color: _kText2, height: 1.4),
          ),
          SizedBox(height: 6),
          Wrap(
            spacing: 5,
            children: [
              _CtxChip(label: 'Controle mensal', color: AppColors.primary),
              _CtxChip(label: 'Janela: 24 meses', color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  // ── Adult card ──────────────────────────────────────────────────────────────

  Widget _buildAdultCard(Animal adult) {
    final ageInMonths = DateTime.now()
        .difference(adult.birthDate)
        .inDays ~/
        30;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _kSurface2,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _kBorder.withValues(alpha: 0.6),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.pets,
                  size: 14,
                  color: _kText3,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimalName(adult),
                    const SizedBox(height: 1),
                    Text(
                      '${adult.breed} · ${adult.gender} · ${adult.category}',
                      style: const TextStyle(
                        fontSize: 8,
                        color: _kText2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Peso atual: ${adult.weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 9,
                        color: _kText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showMonthlyWeightDialog(adult),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _kSurface2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 10,
                    color: _kText2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Month grid label
          const Text(
            'Controle 24 meses',
            style: TextStyle(
              fontSize: 8,
              color: _kText3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          // Month grid (async)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getMonthlyWeights(adult.id),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const SizedBox(
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return _buildMonthGrid(snap.data!, ageInMonths, adult);
            },
          ),

          // Legend
          const SizedBox(height: 5),
          Row(
            children: [
              _LegendDot(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderColor: AppColors.primary.withValues(alpha: 0.30),
                label: 'Registrado',
              ),
              const SizedBox(width: 8),
              _LegendDot(
                color: _kGoldBg,
                borderColor: _kGold.withValues(alpha: 0.40),
                label: 'Pendente',
              ),
              const SizedBox(width: 8),
              _LegendDot(
                color: _kSurface2,
                borderColor: _kBorder.withValues(alpha: 0.5),
                label: 'Futuro',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(
    List<Map<String, dynamic>> weights,
    int ageInMonths,
    Animal animal,
  ) {
    const cols = 5;
    const totalMonths = 24;
    final rows = (totalMonths / cols).ceil();
    final cycleAgeInMonths = ageInMonths <= 0 ? 0 : (((ageInMonths - 1) % 24) + 1);
    final shouldResetCycleVisual = ageInMonths > 24 && _hasCompleteMonthlyCycle(weights);

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(cols, (col) {
              final month = row * cols + col + 1;
              if (month > totalMonths) {
                return const Expanded(child: SizedBox.shrink());
              }
              final hasWeight = shouldResetCycleVisual
                  ? false
                  : weights.any(
                      (w) => w['milestone']?.toString() == 'monthly_$month',
                    );
              final isPending = !hasWeight && month <= cycleAgeInMonths;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: col < cols - 1 ? 3 : 0),
                  child: _MonthCell(
                    label: 'M$month',
                    isDone: hasWeight,
                    isPending: isPending,
                    onTap: () => _showMonthlyWeightDialog(
                      animal,
                      presetMonth: month,
                      resetCycleOnSave: shouldResetCycleVisual && month == 1,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _kSurface2,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.scale_outlined, size: 22, color: _kText3),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhum adulto cadastrado'
                : 'Nenhum resultado para "$_searchQuery"',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kText,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _buildAnimalName(Animal animal) {
    final record = {
      'animal_name': animal.name,
      'animal_code': animal.code,
      'animal_color': animal.nameColor,
    };
    final label = AnimalRecordDisplay.labelFromRecord(record);
    final accent = AnimalRecordDisplay.colorFromDescriptor(animal.nameColor);
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: accent ?? AppColors.primary,
        letterSpacing: -0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<List<Map<String, dynamic>>> _getMonthlyWeights(
      String animalId) async {
    final weightService = Provider.of<WeightService>(context, listen: false);
    return await weightService.getMonthlyWeights(animalId);
  }

  bool _hasCompleteMonthlyCycle(List<Map<String, dynamic>> weights) {
    final completedMonths = weights
        .where((w) => w['milestone']?.toString().startsWith('monthly_') ?? false)
        .map((w) => int.tryParse(
              (w['milestone']?.toString() ?? '').replaceFirst('monthly_', ''),
            ))
        .whereType<int>()
        .toSet();
    return completedMonths.length >= 24;
  }

  void _showMonthlyWeightDialog(
    Animal animal, {
    int? presetMonth,
    bool resetCycleOnSave = false,
  }) async {
    final weightController = TextEditingController();
    final weightService = Provider.of<WeightService>(context, listen: false);
    final animalService = Provider.of<AnimalService>(context, listen: false);

    final existingWeights = await _getMonthlyWeights(animal.id);
    final existingMonths = existingWeights
        .where(
            (w) => w['milestone']?.toString().startsWith('monthly_') ?? false)
        .map((w) {
      final milestone = w['milestone']?.toString() ?? '';
      final monthStr = milestone.replaceFirst('monthly_', '');
      return int.tryParse(monthStr) ?? 0;
    }).toList();

    int? selectedMonth = presetMonth;
    var shouldResetCycle = resetCycleOnSave;
    if (selectedMonth == null) {
      if (existingMonths.isEmpty) {
        selectedMonth = 1;
      } else {
        existingMonths.sort();
        final lastMonth = existingMonths.last;
        if (lastMonth < 24) {
          selectedMonth = lastMonth + 1;
        } else {
          selectedMonth = 1;
          shouldResetCycle = true;
        }
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
                onChanged: (value) =>
                    setDialogState(() => selectedMonth = value),
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
                        content: Text('Preencha todos os campos')),
                  );
                  return;
                }
                final weight = double.tryParse(weightController.text);
                if (weight == null) return;
                try {
                  if (shouldResetCycle && selectedMonth == 1) {
                    await weightService.resetMonthlyCycle(animal.id);
                  }
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
                          content: Text('Pesagem registrada com sucesso!')),
                    );
                    setState(() => _future = null);
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

// ── Month cell ────────────────────────────────────────────────────────────────

class _MonthCell extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isPending;
  final VoidCallback? onTap;

  const _MonthCell({
    required this.label,
    required this.isDone,
    required this.isPending,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final Color borderColor;

    if (isDone) {
      bg = AppColors.primary.withValues(alpha: 0.12);
      textColor = AppColors.primary;
      borderColor = AppColors.primary.withValues(alpha: 0.30);
    } else if (isPending) {
      bg = _kGoldBg;
      textColor = const Color(0xFF7A5C00);
      borderColor = _kGold.withValues(alpha: 0.40);
    } else {
      bg = _kSurface2;
      textColor = _kText3;
      borderColor = _kBorder.withValues(alpha: 0.5);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Context chip ──────────────────────────────────────────────────────────────

class _CtxChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CtxChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border.all(color: color.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Legend dot ────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendDot({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 7, color: _kText3),
        ),
      ],
    );
  }
}
