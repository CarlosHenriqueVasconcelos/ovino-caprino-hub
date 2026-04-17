import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/matrix_candidate_ranking.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/app_empty_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/animal_display_utils.dart';
import '../application/matrix_selection_service.dart';
import 'widgets/matrix_evaluation_form_dialog.dart';

const _kBeige = Color(0xFFF6F5F1);
const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kBrand50 = Color(0xFFE8F5EE);
const _kBrand100 = Color(0xFFC5E8D4);
const _kGold = Color(0xFFD9B15F);
const _kGold50 = Color(0xFFFBF4E6);
const _kErr50 = Color(0xFFFAEAEA);
const _kBlue = Color(0xFF3A7EC4);
const _kBlue50 = Color(0xFFEBF3FB);
const _kPurple = Color(0xFF7B5EA7);
const _kPurple50 = Color(0xFFF0EBFA);

class MatrixSelectionTab extends StatefulWidget {
  const MatrixSelectionTab({super.key});

  @override
  State<MatrixSelectionTab> createState() => _MatrixSelectionTabState();
}

enum _RowAction { edit, delete }

class _MatrixSelectionTabState extends State<MatrixSelectionTab> {
  final TextEditingController _loteFilterController = TextEditingController();

  List<MatrixCandidateRanking> _ranking = [];
  bool _loading = false;
  String? _error;
  bool _hasNextPage = false;

  String? _speciesFilter;
  String? _categoryFilter;
  String? _reproductiveStatusFilter;

  int _currentPage = 0;
  int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  @override
  void dispose() {
    _loteFilterController.dispose();
    super.dispose();
  }

  Future<void> _loadRanking() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<MatrixSelectionService>();
      final lote = _loteFilterController.text.trim();
      final rows = await service.getRanking(
        filters: MatrixRankingFilters(
          species: _speciesFilter,
          category: _categoryFilter,
          reproductiveStatus: _reproductiveStatusFilter,
          lote: lote.isEmpty ? null : lote,
          minScore: null,
          onlyFemales: true,
          limit: _itemsPerPage + 1,
          offset: _currentPage * _itemsPerPage,
        ),
      );

      if (!mounted) return;
      setState(() {
        _hasNextPage = rows.length > _itemsPerPage;
        _ranking = _hasNextPage ? rows.take(_itemsPerPage).toList() : rows;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openCreateEvaluation() async {
    await showDialog<void>(
      context: context,
      builder: (_) => MatrixEvaluationFormDialog(
        onSaved: () async {
          _currentPage = 0;
          await _loadRanking();
        },
      ),
    );
  }

  Future<void> _editLatestEvaluation(MatrixCandidateRanking row) async {
    final service = context.read<MatrixSelectionService>();
    final latest = await service.getLatestEvaluationByAnimal(row.animalId);
    if (latest == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma avaliação encontrada para edição.')),
      );
      return;
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => MatrixEvaluationFormDialog(
        initialEvaluation: latest,
        initialAnimalId: row.animalId,
        lockAnimalSelection: true,
        onSaved: () async {
          await _loadRanking();
        },
      ),
    );
  }

  Future<void> _deleteLatestEvaluation(MatrixCandidateRanking row) async {
    final service = context.read<MatrixSelectionService>();
    final latest = await service.getLatestEvaluationByAnimal(row.animalId);
    if (latest == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma avaliação encontrada para exclusão.')),
      );
      return;
    }
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir avaliação'),
        content: Text(
          'Deseja excluir a última avaliação de ${row.name} (${row.code})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await service.deleteEvaluation(latest.id);
    if (!mounted) return;
    await _loadRanking();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação excluída com sucesso.')),
    );
  }

  Future<void> _handleRowAction(
    _RowAction action,
    MatrixCandidateRanking row,
  ) async {
    switch (action) {
      case _RowAction.edit:
        await _editLatestEvaluation(row);
        break;
      case _RowAction.delete:
        await _deleteLatestEvaluation(row);
        break;
    }
  }

  void _applyFilters() {
    setState(() => _currentPage = 0);
    _loadRanking();
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) return;
    setState(() => _currentPage -= 1);
    _loadRanking();
  }

  void _goToNextPage() {
    if (!_hasNextPage) return;
    setState(() => _currentPage += 1);
    _loadRanking();
  }

  @override
  Widget build(BuildContext context) {
    final evaluatedCount = _ranking.length;
    final approveCount = _ranking
        .where((row) => _normalizeRecommendationLabel(row.recommendation) == 'Aprovar')
        .length;
    final discardCount = _ranking
        .where((row) => _normalizeRecommendationLabel(row.recommendation) == 'Descartar')
        .length;

    return Container(
      color: _kBeige,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          children: [
            _buildHeader(evaluatedCount),
            _buildKpiStrip(evaluatedCount, approveCount, discardCount),
            const SizedBox(height: AppSpacing.sm),
            _buildFiltersBar(),
            const SizedBox(height: AppSpacing.sm),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int total) {
    final subtitle = '$total ${total == 1 ? 'avaliada' : 'avaliadas'} nesta página';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Matrizes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ranking zootécnico · $subtitle',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kText3,
                    ),
                  ),
                ],
              ),
            ),
            PrimaryButton(
              label: 'Nova avaliação',
              icon: Icons.add,
              onPressed: _openCreateEvaluation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiStrip(int total, int approve, int discard) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _MatrixKpiTile(
              icon: Icons.group_outlined,
              iconBg: _kBrand50,
              iconColor: AppColors.primary,
              value: '$total',
              label: 'Avaliadas',
              valueColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _MatrixKpiTile(
              icon: Icons.check,
              iconBg: _kGold50,
              iconColor: _kGold,
              value: '$approve',
              label: 'Aprovar',
              valueColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _MatrixKpiTile(
              icon: Icons.close,
              iconBg: _kErr50,
              iconColor: AppColors.error,
              value: '$discard',
              label: 'Descartar',
              valueColor: discard > 0 ? AppColors.error : _kText3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border(
          top: BorderSide(color: _kBorder.withValues(alpha: 0.6)),
          bottom: BorderSide(color: _kBorder.withValues(alpha: 0.6)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            _CompactFilterDropdown<String>(
              label: 'Espécie',
              value: _speciesFilter,
              width: 150,
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('Todas')),
                DropdownMenuItem<String?>(value: 'Ovino', child: Text('Ovino')),
                DropdownMenuItem<String?>(value: 'Caprino', child: Text('Caprino')),
              ],
              onChanged: (value) {
                _speciesFilter = value;
                _applyFilters();
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            _CompactFilterDropdown<String>(
              label: 'Categoria',
              value: _categoryFilter,
              width: 165,
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('Todas')),
                DropdownMenuItem<String?>(value: 'Matriz', child: Text('Matriz')),
                DropdownMenuItem<String?>(
                  value: 'Reprodutor',
                  child: Text('Reprodutor'),
                ),
                DropdownMenuItem<String?>(value: 'Adulto', child: Text('Adulto')),
                DropdownMenuItem<String?>(value: 'Venda', child: Text('Venda')),
                DropdownMenuItem<String?>(
                  value: 'Não especificado',
                  child: Text('Não especificado'),
                ),
              ],
              onChanged: (value) {
                _categoryFilter = value;
                _applyFilters();
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            _CompactFilterDropdown<String>(
              label: 'Status',
              value: _reproductiveStatusFilter,
              width: 180,
              items: const [
                DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                DropdownMenuItem<String?>(value: 'Vazia', child: Text('Vazia')),
                DropdownMenuItem<String?>(value: 'Coberta', child: Text('Coberta')),
                DropdownMenuItem<String?>(
                  value: 'Gestante',
                  child: Text('Gestante'),
                ),
                DropdownMenuItem<String?>(
                  value: 'Lactação',
                  child: Text('Lactação'),
                ),
                DropdownMenuItem<String?>(value: 'Seca', child: Text('Seca')),
                DropdownMenuItem<String?>(
                  value: 'Não aplicável',
                  child: Text('Não aplicável'),
                ),
              ],
              onChanged: (value) {
                _reproductiveStatusFilter = value;
                _applyFilters();
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            _CompactLoteFilter(
              controller: _loteFilterController,
              onSubmitted: _applyFilters,
            ),
            const SizedBox(width: AppSpacing.xs),
            _CompactFilterDropdown<int>(
              label: 'Por página',
              value: _itemsPerPage,
              width: 130,
              items: const [
                DropdownMenuItem<int?>(value: 10, child: Text('10')),
                DropdownMenuItem<int?>(value: 20, child: Text('20')),
                DropdownMenuItem<int?>(value: 30, child: Text('30')),
                DropdownMenuItem<int?>(value: 50, child: Text('50')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _itemsPerPage = value;
                  _currentPage = 0;
                });
                _loadRanking();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppEmptyState(
          title: 'Erro ao carregar ranking',
          description: _error!,
          icon: Icons.error_outline,
          action: TextButton(
            onPressed: _loadRanking,
            child: const Text('Tentar novamente'),
          ),
        ),
      );
    }

    if (_ranking.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: AppEmptyState(
          title: 'Nenhuma matriz avaliada',
          description: 'Ajuste os filtros ou cadastre uma nova avaliação.',
          icon: Icons.workspace_premium_outlined,
          action: PrimaryButton(
            label: 'Nova avaliação',
            icon: Icons.add,
            onPressed: _openCreateEvaluation,
          ),
        ),
      );
    }

    final initialRank = _currentPage * _itemsPerPage;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Ranking de matrizes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                ),
              ),
              TextButton(
                onPressed: _applyFilters,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'atualizar',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          itemCount: _ranking.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final row = _ranking[index];
            return _MatrixRankingCard(
              rank: initialRank + index + 1,
              row: row,
              onSelectedAction: (action) => _handleRowAction(action, row),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Página ${_currentPage + 1}${_hasNextPage ? ' de ${_currentPage + 2}+' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kText2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _PageBtn(
                enabled: _currentPage > 0,
                icon: Icons.chevron_left,
                onTap: _goToPreviousPage,
              ),
              const SizedBox(width: AppSpacing.xs),
              _PageBtn(
                enabled: _hasNextPage,
                icon: Icons.chevron_right,
                onTap: _goToNextPage,
                active: _hasNextPage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _normalizeRecommendationLabel(String recommendation) {
    final normalized = recommendation.trim().toLowerCase();
    if (normalized == 'aprovada') return 'Aprovar';
    if (normalized == 'observação' || normalized == 'observacao') {
      return 'Observar';
    }
    if (normalized == 'aprovar') return 'Aprovar';
    if (normalized == 'observar') return 'Observar';
    if (normalized == 'descartar') return 'Descartar';
    return recommendation.trim().isEmpty ? 'Observar' : recommendation;
  }
}

class _MatrixRankingCard extends StatelessWidget {
  final int rank;
  final MatrixCandidateRanking row;
  final ValueChanged<_RowAction> onSelectedAction;

  const _MatrixRankingCard({
    required this.rank,
    required this.row,
    required this.onSelectedAction,
  });

  @override
  Widget build(BuildContext context) {
    final recommendation = _normalizeRecommendationLabel(row.recommendation);
    final style = _recommendationStyle(recommendation);
    final rawColor = (row.nameColor ?? '').trim();
    final colorLabel = rawColor.isEmpty ? '' : AnimalDisplayUtils.getColorName(rawColor);
    final gain = _gainValue(row.lambingWeight, row.weaningWeight);

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RankBadge(rank: rank),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${row.code} — ${row.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (colorLabel.isNotEmpty) 'Cor: $colorLabel',
                              'Lote: ${(row.lote ?? '').trim().isEmpty ? 'N/I' : row.lote!.trim()}',
                              row.species,
                              row.category,
                            ].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              color: _kText2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recommendation,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: style.fg,
                        ),
                      ),
                    ),
                    PopupMenuButton<_RowAction>(
                      icon: const Icon(Icons.more_vert, color: _kText3, size: 18),
                      onSelected: onSelectedAction,
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: _RowAction.edit,
                          child: Text('Editar avaliação'),
                        ),
                        PopupMenuItem(
                          value: _RowAction.delete,
                          child: Text('Excluir avaliação'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _StatusTag(
                      label: row.reproductiveStatus,
                      bg: _kPurple50,
                      fg: _kPurple,
                    ),
                    _statusByHoof(row.hoofCondition),
                    _statusByVerminosis(row.verminosisLevel),
                    _StatusTag(label: row.twinningHistory, bg: _kSurface2, fg: _kText2),
                    if (row.ageMonths != null)
                      _StatusTag(
                        label: 'Idade: ${row.ageMonths}m',
                        bg: _kSurface2,
                        fg: _kText2,
                      ),
                    _StatusTag(
                      label: 'Dentição: ${row.dentitionScore.toStringAsFixed(1)}',
                      bg: _kSurface2,
                      fg: _kText2,
                    ),
                    _StatusTag(
                      label: 'Lactação: ${row.lactationScore.toStringAsFixed(1)}',
                      bg: _kSurface2,
                      fg: _kText2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
          SizedBox(
            height: 58,
            child: Row(
              children: [
                Expanded(
                  child: _MetricCell(
                    title: 'Escore corporal',
                    value: row.bodyConditionScore.toStringAsFixed(1),
                    barPercent: (row.bodyConditionScore / 5).clamp(0, 1),
                    barColor: AppColors.primary,
                  ),
                ),
                _cellDivider(),
                Expanded(
                  child: _MetricCell(
                    title: 'Gemelaridade',
                    value: row.twinningHistory,
                    subtitle: 'histórico',
                  ),
                ),
                _cellDivider(),
                Expanded(
                  child: _MetricCell(
                    title: 'Avaliação',
                    value: _scoreLabel(row.finalScore),
                    valueColor: _scoreColor(row.finalScore),
                    subtitle: 'zootécnica',
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
          SizedBox(
            height: 54,
            child: Row(
              children: [
                Expanded(
                  child: _WeightCell(
                    label: 'Peso ao parir',
                    value: row.lambingWeight == null
                        ? 'N/I'
                        : '${row.lambingWeight!.toStringAsFixed(1)} kg',
                  ),
                ),
                _cellDivider(),
                Expanded(
                  child: _WeightCell(
                    label: 'Peso desmama',
                    value: row.weaningWeight == null
                        ? 'N/I'
                        : '${row.weaningWeight!.toStringAsFixed(1)} kg',
                  ),
                ),
                _cellDivider(),
                Expanded(
                  child: _WeightCell(
                    label: 'Ganho',
                    value: gain,
                    valueColor: gain.startsWith('-')
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if ((row.notes ?? '').trim().isNotEmpty) ...[
            Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kSurface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  row.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: _kText2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cellDivider() {
    return Container(
      width: 1,
      color: Colors.black.withValues(alpha: 0.05),
    );
  }

  String _gainValue(double? lambingWeight, double? weaningWeight) {
    if (lambingWeight == null || weaningWeight == null) return 'N/I';
    final gain = weaningWeight - lambingWeight;
    final signal = gain >= 0 ? '+' : '';
    return '$signal${gain.toStringAsFixed(1)} kg';
  }

  _StatusTag _statusByHoof(String hoof) {
    final n = hoof.trim().toLowerCase();
    if (n.contains('grave') || n.contains('severo')) {
      return const _StatusTag(label: 'Casco: Grave', bg: _kErr50, fg: AppColors.error);
    }
    if (n.contains('mod')) {
      return const _StatusTag(label: 'Casco: Moderado', bg: _kGold50, fg: _kGold);
    }
    if (n.contains('leve')) {
      return const _StatusTag(label: 'Casco: Leve', bg: _kBrand50, fg: AppColors.primary);
    }
    return _StatusTag(label: 'Casco: $hoof', bg: _kBrand50, fg: AppColors.primary);
  }

  _StatusTag _statusByVerminosis(String value) {
    final n = value.trim().toLowerCase();
    if (n.contains('severa') || n.contains('grave')) {
      return const _StatusTag(
        label: 'Verminose: Grave',
        bg: _kErr50,
        fg: AppColors.error,
      );
    }
    if (n.contains('mod')) {
      return const _StatusTag(label: 'Verminose: Mod.', bg: _kGold50, fg: _kGold);
    }
    if (n.contains('leve')) {
      return const _StatusTag(label: 'Verminose: Leve', bg: _kGold50, fg: _kGold);
    }
    return _StatusTag(label: 'Verminose: $value', bg: _kBlue50, fg: _kBlue);
  }

  Color _scoreColor(double score) {
    if (score >= 8) return AppColors.primary;
    if (score >= 6) return _kGold;
    return AppColors.error;
  }

  String _scoreLabel(double score) {
    if (score >= 8) return 'Boa';
    if (score >= 6) return 'Regular';
    return 'Crítica';
  }

  _SuggestionStyle _recommendationStyle(String recommendation) {
    final n = recommendation.toLowerCase();
    if (n.contains('aprovar')) {
      return const _SuggestionStyle(bg: _kBrand50, fg: AppColors.primary);
    }
    if (n.contains('descartar')) {
      return const _SuggestionStyle(bg: _kErr50, fg: AppColors.error);
    }
    return const _SuggestionStyle(bg: _kGold50, fg: Color(0xFF7A5C00));
  }

  String _normalizeRecommendationLabel(String recommendation) {
    final normalized = recommendation.trim().toLowerCase();
    if (normalized == 'aprovada' || normalized == 'aprovar') return 'Aprovar';
    if (normalized == 'observação' || normalized == 'observacao' || normalized == 'observar') {
      return 'Observar';
    }
    if (normalized == 'descartar') return 'Descartar';
    return recommendation.trim().isEmpty ? 'Observar' : recommendation.trim();
  }
}

class _MatrixKpiTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color valueColor;

  const _MatrixKpiTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 12, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: _kText2,
              height: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactFilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final double width;
  final List<DropdownMenuItem<T?>> items;
  final ValueChanged<T?> onChanged;

  const _CompactFilterDropdown({
    required this.label,
    required this.value,
    required this.width,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: value == null ? _kSurface2 : _kBrand50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value == null ? Colors.black.withValues(alpha: 0.08) : _kBrand100,
        ),
      ),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontSize: 10,
              color: value == null ? _kText2 : AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T?>(
                value: value,
                isDense: true,
                isExpanded: true,
                iconSize: 16,
                style: const TextStyle(
                  fontSize: 10,
                  color: _kText,
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: _kSurface,
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactLoteFilter extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const _CompactLoteFilter({
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: _kSurface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Text(
            'Lote ',
            style: TextStyle(
              fontSize: 10,
              color: _kText2,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSubmitted(),
              style: const TextStyle(fontSize: 10, color: _kText, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '—',
                hintStyle: TextStyle(fontSize: 10, color: _kText3),
              ),
            ),
          ),
          GestureDetector(
            onTap: onSubmitted,
            child: const Icon(Icons.search, size: 14, color: _kText3),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.primary;
    if (rank == 2) {
      bg = _kGold;
    } else if (rank == 3) {
      bg = _kText3;
    }

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _StatusTag({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double? barPercent;
  final Color? barColor;
  final Color? valueColor;

  const _MetricCell({
    required this.title,
    required this.value,
    this.subtitle,
    this.barPercent,
    this.barColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 8,
              color: _kText3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: valueColor ?? _kText,
            ),
          ),
          if (barPercent != null) ...[
            const SizedBox(height: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Container(
                height: 3,
                color: Colors.black.withValues(alpha: 0.07),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: barPercent,
                    child: Container(color: barColor ?? AppColors.primary),
                  ),
                ),
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 8,
                color: _kText2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _WeightCell({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: _kText3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: value == 'N/I' ? _kText3 : (valueColor ?? _kText),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final bool enabled;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _PageBtn({
    required this.enabled,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.primary : _kSurface2;
    final fg = active ? Colors.white : _kText3;

    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: enabled ? onTap : null,
      child: Ink(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: enabled ? bg : _kSurface2.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 16, color: enabled ? fg : _kText3),
      ),
    );
  }
}

class _SuggestionStyle {
  final Color bg;
  final Color fg;

  const _SuggestionStyle({
    required this.bg,
    required this.fg,
  });
}
