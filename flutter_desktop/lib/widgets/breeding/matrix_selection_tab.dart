import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/matrix_candidate_ranking.dart';
import '../../services/matrix_selection_service.dart';
import '../../utils/animal_display_utils.dart';
import 'matrix_evaluation_form_dialog.dart';

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
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String?>(
                  initialValue: _speciesFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Espécie',
                    border: OutlineInputBorder(),
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
                width: 160,
                child: DropdownButtonFormField<String?>(
                  initialValue: _categoryFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
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
                width: 190,
                child: DropdownButtonFormField<String?>(
                  initialValue: _reproductiveStatusFilter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Status Reprodutivo',
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _applyFilters(),
                ),
              ),
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<int>(
                  initialValue: _itemsPerPage,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Por página',
                    border: OutlineInputBorder(),
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
              OutlinedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar'),
              ),
              FilledButton.icon(
                onPressed: _openCreateEvaluation,
                icon: const Icon(Icons.add),
                label: const Text('Nova Avaliação'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Erro ao carregar ranking: $_error'));
    }
    if (_ranking.isEmpty) {
      return const Center(
        child: Text('Nenhuma matriz avaliada para os filtros atuais.'),
      );
    }

    final initialRank = _currentPage * _itemsPerPage;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _ranking.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
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
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Página ${_currentPage + 1}'),
              Row(
                children: [
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
            ],
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
    final recommendationLabel =
        _normalizeRecommendationLabel(row.recommendation);
    final recommendationColor = _recommendationColor(recommendationLabel);
    final rawColor = (row.nameColor ?? '').trim();
    final colorLabel = rawColor.isEmpty
        ? ''
        : AnimalDisplayUtils.getColorName(rawColor);
    final loteLabel = (row.lote ?? '').trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        'Código: ${row.code}',
                        if (colorLabel.isNotEmpty) 'Cor: $colorLabel',
                        'Lote: ${loteLabel.isEmpty ? "N/I" : loteLabel}',
                      ].join('  •  '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                );

                final suggestionChip = Chip(
                  backgroundColor: recommendationColor.withValues(alpha: 0.14),
                  side: BorderSide(
                    color: recommendationColor.withValues(alpha: 0.3),
                  ),
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    'Sugestão: $recommendationLabel',
                    style: TextStyle(
                      color: recommendationColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor:
                                theme.colorScheme.primary.withValues(alpha: 0.12),
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: identity),
                          menu,
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: suggestionChip,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: identity),
                    suggestionChip,
                    menu,
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(context, 'Recomendação: $recommendationLabel',
                    color: recommendationColor),
                _infoChip(context, 'Espécie: ${row.species}'),
                _infoChip(context, 'Categoria: ${row.category}'),
                _infoChip(context, 'Status reprodutivo: ${row.reproductiveStatus}'),
                if (colorLabel.isNotEmpty)
                  _infoChip(context, 'Cor: $colorLabel',
                      color: AnimalDisplayUtils.getColorValue(rawColor)),
                _infoChip(context, 'Casco: ${row.hoofCondition}',
                    color: row.hoofCondition.toLowerCase().contains('problema')
                        ? Colors.deepOrange
                        : Colors.green),
                _infoChip(context, 'Verminose: ${row.verminosisLevel}'),
                _infoChip(context, 'Gemelaridade: ${row.twinningHistory}'),
                _infoChip(
                  context,
                  'Escore corporal: ${row.bodyConditionScore.toStringAsFixed(1)}',
                ),
                _infoChip(
                    context, 'Dentição: ${row.dentitionScore.toStringAsFixed(1)}'),
                _infoChip(
                    context, 'Lactação: ${row.lactationScore.toStringAsFixed(1)}'),
                if (row.ageMonths != null) _infoChip(context, 'Idade: ${row.ageMonths}m'),
                if (row.lambingWeight != null)
                  _infoChip(context,
                      'Peso ao parir: ${row.lambingWeight!.toStringAsFixed(1)}kg'),
                if (row.weaningWeight != null)
                  _infoChip(context,
                      'Peso desmama: ${row.weaningWeight!.toStringAsFixed(1)}kg'),
                if ((row.lote ?? '').trim().isNotEmpty)
                  _infoChip(context, 'Lote: ${row.lote}'),
              ],
            ),
            if ((row.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                row.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Chip _infoChip(
    BuildContext context,
    String text, {
    Color? color,
  }) {
    final base = color ?? Colors.blueGrey;
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: base.withValues(alpha: 0.1),
      side: BorderSide(color: base.withValues(alpha: 0.22)),
      label: Text(
        text,
        style: TextStyle(
          color: base.withValues(alpha: 0.95),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _recommendationColor(String recommendation) {
    final normalized = recommendation.trim().toLowerCase();
    if (normalized.contains('descartar')) return Colors.red;
    if (normalized.contains('aprovar') ||
        normalized.contains('aprovada') ||
        normalized.contains('apto') ||
        normalized.contains('selecionada')) {
      return Colors.green;
    }
    return Colors.deepOrange;
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
