import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/matrix_candidate_ranking.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/app_empty_state.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../shared/widgets/common/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/animal_display_utils.dart';
import '../application/matrix_selection_service.dart';
import 'widgets/matrix_evaluation_form_dialog.dart';

class MatrixSelectionTab extends StatefulWidget {
  const MatrixSelectionTab({super.key});

  @override
  State<MatrixSelectionTab> createState() => _MatrixSelectionTabState();
}

enum _RowAction { edit, delete }

class _MatrixSelectionTabState extends State<MatrixSelectionTab> {
  final TextEditingController _loteFilterController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const MatrixEvaluationFormDialog(),
    );
    if (!mounted || ok != true) return;
    _currentPage = 0;
    await _loadRanking();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação cadastrada com sucesso.')),
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

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => MatrixEvaluationFormDialog(
        initialEvaluation: latest,
        initialAnimalId: row.animalId,
        lockAnimalSelection: true,
      ),
    );
    if (!mounted || ok != true) return;
    await _loadRanking();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação atualizada com sucesso.')),
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
    final total = _ranking.length;
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: AppCard(
              variant: AppCardVariant.soft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Seleção de Matrizes',
                    subtitle:
                        'Ranking zootécnico com foco em tomada de decisão rápida',
                    action: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        SecondaryButton(
                          label: 'Atualizar',
                          icon: Icons.refresh,
                          onPressed: _applyFilters,
                        ),
                        PrimaryButton(
                          label: 'Nova avaliação',
                          icon: Icons.add,
                          onPressed: _openCreateEvaluation,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildFilters(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Exibindo $total ${total == 1 ? 'matriz avaliada' : 'matrizes avaliadas'} na página ${_currentPage + 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<String?>(
            initialValue: _speciesFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Espécie',
              isDense: true,
            ),
            items: const [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('Todas'),
              ),
              DropdownMenuItem<String?>(
                value: 'Ovino',
                child: Text('Ovino'),
              ),
              DropdownMenuItem<String?>(
                value: 'Caprino',
                child: Text('Caprino'),
              ),
            ],
            onChanged: (value) {
              _speciesFilter = value;
              _applyFilters();
            },
          ),
        ),
        SizedBox(
          width: 170,
          child: DropdownButtonFormField<String?>(
            initialValue: _categoryFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              isDense: true,
            ),
            items: const [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('Todas'),
              ),
              DropdownMenuItem<String?>(
                value: 'Matriz',
                child: Text('Matriz'),
              ),
              DropdownMenuItem<String?>(
                value: 'Reprodutor',
                child: Text('Reprodutor'),
              ),
              DropdownMenuItem<String?>(
                value: 'Adulto',
                child: Text('Adulto'),
              ),
              DropdownMenuItem<String?>(
                value: 'Venda',
                child: Text('Venda'),
              ),
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
        ),
        SizedBox(
          width: 210,
          child: DropdownButtonFormField<String?>(
            initialValue: _reproductiveStatusFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Status reprodutivo',
              isDense: true,
            ),
            items: const [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('Todos'),
              ),
              DropdownMenuItem<String?>(
                value: 'Vazia',
                child: Text('Vazia'),
              ),
              DropdownMenuItem<String?>(
                value: 'Coberta',
                child: Text('Coberta'),
              ),
              DropdownMenuItem<String?>(
                value: 'Gestante',
                child: Text('Gestante'),
              ),
              DropdownMenuItem<String?>(
                value: 'Lactação',
                child: Text('Lactação'),
              ),
              DropdownMenuItem<String?>(
                value: 'Seca',
                child: Text('Seca'),
              ),
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
        ),
        SizedBox(
          width: 130,
          child: TextField(
            controller: _loteFilterController,
            decoration: const InputDecoration(
              labelText: 'Lote',
              isDense: true,
            ),
            onSubmitted: (_) => _applyFilters(),
          ),
        ),
        SizedBox(
          width: 120,
          child: DropdownButtonFormField<int>(
            initialValue: _itemsPerPage,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Por página',
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 10, child: Text('10')),
              DropdownMenuItem(value: 20, child: Text('20')),
              DropdownMenuItem(value: 30, child: Text('30')),
              DropdownMenuItem(value: 50, child: Text('50')),
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
        ),
      ],
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
          action: SecondaryButton(
            label: 'Tentar novamente',
            onPressed: _loadRanking,
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
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            itemCount: _ranking.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final row = _ranking[index];
              return _MatrixRankingCard(
                rank: initialRank + index + 1,
                row: row,
                onSelectedAction: (action) => _handleRowAction(action, row),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: AppCard(
            variant: AppCardVariant.elevated,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Página ${_currentPage + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: _hasNextPage ? _goToNextPage : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
    final theme = Theme.of(context);
    final recommendationLabel = _normalizeRecommendationLabel(row.recommendation);
    final rawColor = (row.nameColor ?? '').trim();
    final colorLabel = rawColor.isEmpty ? '' : AnimalDisplayUtils.getColorName(rawColor);
    final loteLabel = (row.lote ?? '').trim();

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;
              final identity = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    [
                      'Código: ${row.code}',
                      if (colorLabel.isNotEmpty) 'Cor: $colorLabel',
                      'Lote: ${loteLabel.isEmpty ? 'N/I' : loteLabel}',
                    ].join('  •  '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );

              final menu = PopupMenuButton<_RowAction>(
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
              );

              final recommendation = StatusChip(
                label: 'Sugestão: $recommendationLabel',
                variant: _recommendationVariant(recommendationLabel),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _rankBubble(context),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: identity),
                        menu,
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    recommendation,
                  ],
                );
              }

              return Row(
                children: [
                  _rankBubble(context),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: identity),
                  recommendation,
                  menu,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _infoChip(context, 'Espécie: ${row.species}'),
              _infoChip(context, 'Categoria: ${row.category}'),
              _infoChip(context, 'Status: ${row.reproductiveStatus}'),
              if (colorLabel.isNotEmpty)
                _infoChip(
                  context,
                  'Cor: $colorLabel',
                  color: AnimalDisplayUtils.getColorValue(rawColor),
                ),
              _infoChip(
                context,
                'Casco: ${row.hoofCondition}',
                color: row.hoofCondition.toLowerCase().contains('problema')
                    ? AppColors.warning
                    : AppColors.success,
              ),
              _infoChip(context, 'Verminose: ${row.verminosisLevel}'),
              _infoChip(context, 'Gemelaridade: ${row.twinningHistory}'),
              _infoChip(
                context,
                'Escore corporal: ${row.bodyConditionScore.toStringAsFixed(1)}',
              ),
              _infoChip(
                context,
                'Dentição: ${row.dentitionScore.toStringAsFixed(1)}',
              ),
              _infoChip(
                context,
                'Lactação: ${row.lactationScore.toStringAsFixed(1)}',
              ),
              if (row.ageMonths != null) _infoChip(context, 'Idade: ${row.ageMonths}m'),
              if (row.lambingWeight != null)
                _infoChip(
                  context,
                  'Peso ao parir: ${row.lambingWeight!.toStringAsFixed(1)}kg',
                ),
              if (row.weaningWeight != null)
                _infoChip(
                  context,
                  'Peso desmama: ${row.weaningWeight!.toStringAsFixed(1)}kg',
                ),
            ],
          ),
          if ((row.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              variant: AppCardVariant.soft,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                row.notes!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rankBubble(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 14,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Text(
        '$rank',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoChip(
    BuildContext context,
    String text, {
    Color? color,
  }) {
    final base = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: base.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: base.withValues(alpha: 0.95),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _recommendationColor(String recommendation) {
    final normalized = recommendation.trim().toLowerCase();
    if (normalized.contains('descartar')) return AppColors.error;
    if (normalized.contains('aprovar') ||
        normalized.contains('aprovada') ||
        normalized.contains('apto') ||
        normalized.contains('selecionada')) {
      return AppColors.success;
    }
    return AppColors.warning;
  }

  StatusChipVariant _recommendationVariant(String recommendation) {
    final color = _recommendationColor(recommendation);
    if (color == AppColors.error) return StatusChipVariant.danger;
    if (color == AppColors.success) return StatusChipVariant.success;
    return StatusChipVariant.warning;
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
