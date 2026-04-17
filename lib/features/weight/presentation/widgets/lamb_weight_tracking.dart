import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/weight_service.dart';
import '../../../../shared/widgets/animal/animal_form.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/animal_record_display.dart';
import 'weight_tracking_filters_bar.dart';
import 'weight_tracking_pagination_bar.dart';

// ── Color palette ─────────────────────────────────────────────────────────────

const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kPurple = Color(0xFF7B5EA7);
const _kPurple08 = Color(0xFFF3EFFA);
const _kPurple20 = Color(0xFFE0D6F5);
const _kGreen = AppColors.primary;

class LambWeightTracking extends StatefulWidget {
  final bool embedInParentScroll;

  const LambWeightTracking({
    super.key,
    this.embedInParentScroll = false,
  });

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
    final content = Column(
      children: [
          _buildContextCard(),
          const SizedBox(height: AppSpacing.sm),
          _buildRefGrid(),
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
          FutureBuilder<HerdQueryResult>(
            future: _future ??= context.read<AnimalService>().herdQuery(
                  categoryFilter: 'Borrego',
                  searchQuery: _searchQuery,
                  page: _currentPage,
                  pageSize: _itemsPerPage,
                ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder.withValues(alpha: 0.7)),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final result = snapshot.data;
              final lambs = (result?.items ?? const <Animal>[]).toList();
              final total = result?.total ?? 0;
              final totalPages = (total / _itemsPerPage).ceil().clamp(1, 9999);

              return Column(
                children: [
                  // Animals list header
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 2,
                      bottom: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Registros de Borregos',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _kPurple08,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: _kPurple20),
                          ),
                          child: Text(
                            '$total animal${total == 1 ? '' : 'is'}',
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: _kPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (lambs.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lambs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) =>
                          _buildLambCard(lambs[index]),
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
              );
            },
          ),
      ],
    );

    if (widget.embedInParentScroll) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: content,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
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
        color: _kPurple08,
        border: Border.all(color: _kPurple20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Borregos',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Marcos de pesagem entre nascimento e 120 dias',
            style: TextStyle(fontSize: 8, color: _kText2, height: 1.4),
          ),
          SizedBox(height: 6),
          Wrap(
            spacing: 5,
            children: [
              _LambCtxChip(label: 'Marcos: 30/60/90/120d'),
              _LambCtxChip(label: 'Foco em ganho de peso'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Reference gain grid (2×2) ───────────────────────────────────────────────

  Widget _buildRefGrid() {
    const items = [
      _RefItem(
        label: 'Nascimento',
        range: '3,5 – 7 kg',
        icon: Icons.child_care_outlined,
      ),
      _RefItem(
        label: '30 dias',
        range: '10 – 15 kg',
        icon: Icons.trending_up,
      ),
      _RefItem(
        label: '60 dias',
        range: '15 – 20 kg',
        icon: Icons.trending_up,
      ),
      _RefItem(
        label: '90–120 dias',
        range: '20 – 40 kg',
        icon: Icons.trending_up,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: AppSpacing.xs),
          child: Text(
            'Referências de ganho',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.xs,
          mainAxisSpacing: AppSpacing.xs,
          childAspectRatio: 2.6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: _kBorder.withValues(alpha: 0.7)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _kPurple08,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        alignment: Alignment.center,
                        child: Icon(item.icon, size: 12, color: _kPurple),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: _kText2,
                              ),
                            ),
                            Text(
                              item.range,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _kText,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ── Lamb card ───────────────────────────────────────────────────────────────

  Widget _buildLambCard(Animal lamb) {
    final ageInDays = DateTime.now().difference(lamb.birthDate).inDays;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.7)),
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
          // ── Card header ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _kPurple08,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  lamb.speciesIcon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimalName(lamb),
                    Text(
                      '${lamb.breed} · ${lamb.gender} · $ageInDays dias',
                      style: const TextStyle(fontSize: 8, color: _kText2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showWeightEditDialog(lamb),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _kSurface2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorder),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.edit_outlined,
                      size: 13, color: _kText2),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Milestone rows ───────────────────────────────────────────────
          _buildMilestoneRow(
            label: 'Nasc.',
            targetDays: 0,
            ageInDays: ageInDays,
            weight: lamb.birthWeight,
            onTap: () => _showWeightEditDialog(lamb),
          ),
          _buildMilestoneRow(
            label: '30d',
            targetDays: 30,
            ageInDays: ageInDays,
            weight: lamb.weight30Days,
            onTap: () => _showWeightEditDialog(lamb),
          ),
          _buildMilestoneRow(
            label: '60d',
            targetDays: 60,
            ageInDays: ageInDays,
            weight: lamb.weight60Days,
            onTap: () => _showWeightEditDialog(lamb),
          ),
          _buildMilestoneRow(
            label: '90d',
            targetDays: 90,
            ageInDays: ageInDays,
            weight: lamb.weight90Days,
            onTap: () => _showWeightEditDialog(lamb),
          ),
          FutureBuilder<double?>(
            future: _getWeight120Days(lamb.id),
            builder: (context, snap) => _buildMilestoneRow(
              label: '120d',
              targetDays: 120,
              ageInDays: ageInDays,
              weight: snap.data,
              onTap: () => _showWeightEditDialog(lamb),
            ),
          ),

          // ── Promote button ───────────────────────────────────────────────
          if (ageInDays >= 120) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => _promoteToAdult(lamb),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upgrade, size: 13, color: _kGreen),
                    SizedBox(width: 5),
                    Text(
                      'Promover para Adulto',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _kGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestoneRow({
    required String label,
    required int targetDays,
    required int ageInDays,
    required double? weight,
    required VoidCallback onTap,
  }) {
    final isReached = ageInDays >= targetDays;
    final hasWeight = weight != null && weight > 0;

    Color badgeBg;
    Color badgeText;
    if (hasWeight) {
      badgeBg = AppColors.primary.withValues(alpha: 0.12);
      badgeText = AppColors.primary;
    } else if (isReached) {
      badgeBg = const Color(0xFFFAEAEA);
      badgeText = const Color(0xFFC94A4A);
    } else {
      badgeBg = _kSurface2;
      badgeText = _kText3;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          // Badge
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: badgeText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Weight value or placeholder
          Expanded(
            child: Text(
              hasWeight
                  ? '${weight.toStringAsFixed(1)} kg'
                  : 'Não registrado',
              style: TextStyle(
                fontSize: 10,
                fontWeight: hasWeight ? FontWeight.w600 : FontWeight.w400,
                color: hasWeight ? _kText : _kText3,
              ),
            ),
          ),
          // Register button (only if milestone reached and no weight yet)
          if (isReached && !hasWeight)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kPurple08,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kPurple20),
                ),
                child: const Text(
                  '+ Registrar',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: _kPurple,
                  ),
                ),
              ),
            ),
        ],
      ),
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
              color: _kPurple08,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.child_care_outlined,
                size: 22, color: _kPurple),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _searchQuery.isEmpty
                ? 'Nenhum borrego cadastrado'
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

  Widget _buildAnimalName(Animal lamb) {
    final record = {
      'animal_name': lamb.name,
      'animal_code': lamb.code,
      'animal_color': lamb.nameColor,
    };
    final label = AnimalRecordDisplay.labelFromRecord(record);
    final accent = AnimalRecordDisplay.colorFromDescriptor(lamb.nameColor);
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: accent ?? _kPurple,
        letterSpacing: -0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<double?> _getWeight120Days(String animalId) async {
    final weightService = Provider.of<WeightService>(context, listen: false);
    return await weightService.getWeight120Days(animalId);
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
            backgroundColor: AppColors.primary,
          ),
        );
        setState(() => _future = null);
      }
    }
  }

  void _showWeightEditDialog(Animal lamb) async {
    double? initialBirthWeight = lamb.birthWeight;
    if (initialBirthWeight == null || initialBirthWeight == 0) {
      final weightService = Provider.of<WeightService>(context, listen: false);
      final weightHistory = await weightService.getWeightHistory(lamb.id);
      final birthRecord = weightHistory
          .where((w) =>
              w['milestone']?.toString() == 'birth' ||
              w['milestone']?.toString() == 'nascimento')
          .toList();
      if (birthRecord.isNotEmpty) {
        initialBirthWeight = (birthRecord.first['weight'] as num?)?.toDouble();
      } else if (weightHistory.isNotEmpty) {
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
    final weight120 = await _getWeight120Days(lamb.id);
    final weight120Controller = TextEditingController(
      text: weight120?.toStringAsFixed(1) ?? '',
    );

    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar Pesos – ${lamb.name}'),
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
                await showDialog(
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
    if (mounted) setState(() => _future = null);
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

// ── Lamb context chip ─────────────────────────────────────────────────────────

class _LambCtxChip extends StatelessWidget {
  final String label;

  const _LambCtxChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border.all(color: _kPurple20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: _kPurple,
        ),
      ),
    );
  }
}

// ── Reference item data ───────────────────────────────────────────────────────

class _RefItem {
  final String label;
  final String range;
  final IconData icon;

  const _RefItem({
    required this.label,
    required this.range,
    required this.icon,
  });
}
