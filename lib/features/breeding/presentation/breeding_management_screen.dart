import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/animal.dart';
import '../../../models/breeding_record.dart';
import '../../../services/animal_service.dart';
import '../../../services/breeding_service.dart';
import '../../../shared/widgets/buttons/ghost_button.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/app_empty_state.dart';
import '../../../shared/widgets/common/search_field.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/animal_display_utils.dart';
import '../../herd/presentation/widgets/animal_history_dialog.dart';
import 'widgets/breeding_import_dialog.dart';
import 'widgets/breeding_stage_actions.dart';
import 'widgets/breeding_wizard_dialog.dart';
import 'widgets/repro_alerts_card.dart';

const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kBorder = Color(0xFFE6E4DC);
const _kBrand50 = Color(0xFFE8F5EE);
const _kBrand100 = Color(0xFFC5E8D4);
const _kTextPrimary = Color(0xFF22313A);
const _kTextSecondary = Color(0xFF5A6E78);
const _kTextHint = Color(0xFF9AABB4);
const _kBlue = Color(0xFF3A7EC4);
const _kBlue50 = Color(0xFFEBF3FB);
const _kPurple = Color(0xFF7B5EA7);
const _kPurple50 = Color(0xFFF0EBFA);
const _kErr50 = Color(0xFFFAEAEA);
const _kTeal = Color(0xFF1E8080);
const _kTeal50 = Color(0xFFE3F4F4);

class BreedingManagementScreen extends StatefulWidget {
  const BreedingManagementScreen({super.key});

  @override
  State<BreedingManagementScreen> createState() =>
      _BreedingManagementScreenState();
}

class _BreedingManagementScreenState extends State<BreedingManagementScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;
  List<BreedingRecord> _breedingRecords = [];
  Map<String, Animal> _animalsMap = {};
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final breedingService = context.read<BreedingService>();
      final animalService = context.read<AnimalService>();

      final breedingData = await breedingService.getBreedingRecords();
      final records =
          breedingData.map((e) => BreedingRecord.fromMap(e)).toList();

      // Coleta IDs únicos de todos os animais envolvidos nos registros
      final ids = <String>{
        ...records
            .where((r) => (r.femaleAnimalId ?? '').isNotEmpty)
            .map((r) => r.femaleAnimalId!),
        ...records
            .where((r) => (r.maleAnimalId ?? '').isNotEmpty)
            .map((r) => r.maleAnimalId!),
      };

      // 1 query com WHERE id IN (...) — antes eram N queries individuais
      final animalsMap = await animalService.getAnimalsByIds(ids.toList());

      if (!mounted) return;
      setState(() {
        _breedingRecords = records;
        _animalsMap = animalsMap;
        _isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Erro ao carregar dados de reprodução: $e');
      debugPrint(stack.toString());
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    }
  }

  List<BreedingRecord> _filterByStage(BreedingStage stage) {
    var records = _breedingRecords.where((r) {
      if (stage == BreedingStage.aguardandoUltrassom) {
        return r.stage == BreedingStage.aguardandoUltrassom ||
            r.stage == BreedingStage.separacao;
      }
      return r.stage == stage;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      records = records.where((r) {
        final female = _animalsMap[r.femaleAnimalId];
        if (female == null) return false;

        final searchLower = _searchQuery.toLowerCase();
        final code = female.code.toLowerCase();
        final name = female.name.toLowerCase();
        return code.contains(searchLower) || name.contains(searchLower);
      }).toList();
    }

    records.sort((a, b) {
      DateTime? dateA;
      DateTime? dateB;

      switch (stage) {
        case BreedingStage.encabritamento:
          dateA = a.matingEndDate;
          dateB = b.matingEndDate;
          break;
        case BreedingStage.aguardandoUltrassom:
          dateA = a.ultrasoundDate;
          dateB = b.ultrasoundDate;
          break;
        case BreedingStage.gestacaoConfirmada:
          dateA = a.expectedBirth;
          dateB = b.expectedBirth;
          break;
        default:
          dateA = a.matingStartDate ?? a.breedingDate;
          dateB = b.matingStartDate ?? b.breedingDate;
      }

      if (dateA != null && dateB != null) {
        return dateA.compareTo(dateB);
      }
      if (dateA != null) return -1;
      if (dateB != null) return 1;
      return 0;
    });

    return records;
  }

  Future<void> _showBreedingWizard() async {
    await showDialog(
      context: context,
      builder: (context) => BreedingWizardDialog(onComplete: _loadData),
    );
  }

  Future<void> _showImportDialog() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const BreedingImportDialog(),
    );
    if (ok == true) {
      _loadData();
    }
  }

  Color _stageColor(BreedingStage stage) {
    switch (stage) {
      case BreedingStage.encabritamento:
        return const Color(0xFFB8791F);
      case BreedingStage.aguardandoUltrassom:
      case BreedingStage.separacao:
        return const Color(0xFF2E70C2);
      case BreedingStage.gestacaoConfirmada:
        return const Color(0xFF8B5BC7);
      case BreedingStage.partoRealizado:
        return AppColors.success;
      case BreedingStage.falhou:
        return AppColors.error;
    }
  }

  IconData _stageIcon(BreedingStage stage) {
    switch (stage) {
      case BreedingStage.encabritamento:
        return Icons.favorite;
      case BreedingStage.aguardandoUltrassom:
      case BreedingStage.separacao:
        return Icons.medical_services;
      case BreedingStage.gestacaoConfirmada:
        return Icons.pregnant_woman;
      case BreedingStage.partoRealizado:
        return Icons.check_circle;
      case BreedingStage.falhou:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tabEncabritamento = _filterByStage(BreedingStage.encabritamento);
    final tabUltrassom = _filterByStage(BreedingStage.aguardandoUltrassom);
    final tabGestantes = _filterByStage(BreedingStage.gestacaoConfirmada);
    final tabConcluidos = _filterByStage(BreedingStage.partoRealizado);
    final tabFalhados = _filterByStage(BreedingStage.falhou);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: _buildHeaderBlock(
                  tabEncabritamento: tabEncabritamento.length,
                  tabUltrassom: tabUltrassom.length,
                  tabGestantes: tabGestantes.length,
                  tabConcluidos: tabConcluidos.length,
                  tabFalhados: tabFalhados.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: ReproAlertsCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: AppCard(
                  variant: AppCardVariant.elevated,
                  child: SearchField(
                    controller: _searchController,
                    labelText: 'Buscar fêmea',
                    hintText: 'Buscar por número ou nome da mãe...',
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onClear: () {
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: AppCard(
                  variant: AppCardVariant.elevated,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: _kTextHint,
                    dividerColor: Colors.transparent,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(
                        child: Row(
                          children: [
                            Icon(Icons.favorite, size: 16),
                            SizedBox(width: 6),
                            Text('Encabritamento'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: [
                            Icon(Icons.medical_services, size: 16),
                            SizedBox(width: 6),
                            Text('Ultrassom'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: [
                            Icon(Icons.pregnant_woman, size: 16),
                            SizedBox(width: 6),
                            Text('Gestantes'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16),
                            SizedBox(width: 6),
                            Text('Concluídos'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 16),
                            SizedBox(width: 6),
                            Text('Falhados'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStageList(BreedingStage.encabritamento),
              _buildStageList(BreedingStage.aguardandoUltrassom),
              _buildStageList(BreedingStage.gestacaoConfirmada),
              _buildStageList(BreedingStage.partoRealizado),
              _buildStageList(BreedingStage.falhou),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageList(BreedingStage stage) {
    final records = _filterByStage(stage);

    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: AppEmptyState(
          title: 'Nenhum registro nesta etapa',
          description: 'Quando houver movimentação nesta fase, ela aparecerá aqui.',
          icon: Icons.inbox_outlined,
        ),
      );
    }

    return ListView.builder(
      key: PageStorageKey<String>('breeding_stage_${stage.name}'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: records.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Text(
                  '${_stageListLabel(stage)} · ${records.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Ordenado por prazo',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.primary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        return _buildBreedingCard(records[index - 1]);
      },
    );
  }

  Widget _buildHeaderBlock({
    required int tabEncabritamento,
    required int tabUltrassom,
    required int tabGestantes,
    required int tabConcluidos,
    required int tabFalhados,
  }) {
    final stageCounts = <BreedingStage, int>{
      BreedingStage.encabritamento: tabEncabritamento,
      BreedingStage.aguardandoUltrassom: tabUltrassom,
      BreedingStage.gestacaoConfirmada: tabGestantes,
      BreedingStage.partoRealizado: tabConcluidos,
      BreedingStage.falhou: tabFalhados,
    };

    return AppCard(
      variant: AppCardVariant.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reprodução',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ciclo reprodutivo completo',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kTextHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  GhostButton(
                    label: 'Importar',
                    icon: Icons.playlist_add,
                    onPressed: _showImportDialog,
                  ),
                  PrimaryButton(
                    label: 'Nova Cobertura',
                    icon: Icons.add,
                    onPressed: _showBreedingWizard,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedBuilder(
            animation: _tabController,
            builder: (_, __) => _buildPipeline(stageCounts),
          ),
        ],
      ),
    );
  }

  Widget _buildPipeline(Map<BreedingStage, int> stageCounts) {
    final order = [
      BreedingStage.encabritamento,
      BreedingStage.aguardandoUltrassom,
      BreedingStage.gestacaoConfirmada,
      BreedingStage.partoRealizado,
      BreedingStage.falhou,
    ];

    final activeTab = switch (_tabController.index) {
      0 => BreedingStage.encabritamento,
      1 => BreedingStage.aguardandoUltrassom,
      2 => BreedingStage.gestacaoConfirmada,
      3 => BreedingStage.partoRealizado,
      4 => BreedingStage.falhou,
      _ => BreedingStage.encabritamento,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pipeline · toque para filtrar',
            style: TextStyle(
              fontSize: 9,
              color: _kTextHint,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (var i = 0; i < order.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == order.length - 1 ? 0 : AppSpacing.xs,
                    ),
                    child: _buildPipelineTile(
                      stage: order[i],
                      count: stageCounts[order[i]] ?? 0,
                      isActive: order[i] == activeTab,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineTile({
    required BreedingStage stage,
    required int count,
    required bool isActive,
  }) {
    final hasItems = count > 0;
    final borderColor = isActive
        ? _kPurple
        : hasItems
            ? _kBrand100
            : _kBorder.withValues(alpha: 0.85);
    final background = isActive ? _kPurple50 : _kSurface;
    final numberColor = isActive
        ? _kPurple
        : hasItems
            ? AppColors.primary
            : _kTextHint;
    final labelColor = isActive
        ? _kPurple
        : hasItems
            ? AppColors.primary
            : _kTextHint;
    final iconColor = isActive ? Colors.white : _pipelineStageIconColor(stage);
    final iconBackground = isActive
        ? _kPurple
        : _pipelineStageIconBackground(stage, hasItems: hasItems);

    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: borderColor,
            width: isActive ? 1.4 : 1,
          ),
        ),
        color: background,
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _tabController.animateTo(_tabIndexForStage(stage)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 7, 4, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_stageIcon(stage), size: 12, color: iconColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: numberColor,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _pipelineShortLabel(stage),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreedingCard(BreedingRecord record) {
    final female = _animalsMap[record.femaleAnimalId];
    final male = _animalsMap[record.maleAnimalId];
    final progress = record.progressPercentage();
    final daysLeft = record.daysRemaining();
    final stageColor = _stageColor(record.stage);
    final stageIcon = _stageIcon(record.stage);
    final cycleLabel = record.id.length >= 6
        ? record.id.substring(0, 6).toUpperCase()
        : record.id.toUpperCase();
    final timeline = _timelineFor(record);
    final isDone = record.stage == BreedingStage.partoRealizado;
    final isFailed = record.stage == BreedingStage.falhou;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDone ? _kBrand50 : _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone
              ? _kBrand100
              : isFailed
                  ? AppColors.error.withValues(alpha: 0.25)
                  : _kBorder.withValues(alpha: 0.7),
        ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(stageIcon, color: stageColor, size: 16),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ciclo #$cycleLabel',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            record.stage.displayName,
                            style: const TextStyle(
                              fontSize: 9,
                              color: _kTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: stageColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        record.stage.displayName,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: stageColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: _animalPill(
                        label: female != null
                            ? AnimalDisplayUtils.getDisplayText(female)
                            : 'Fêmea não encontrada',
                        role: 'Fêmea',
                        onTap: female != null
                            ? () => AnimalHistoryDialog.showAdaptive(
                                  context,
                                  animal: female,
                                )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _animalPill(
                        label: male != null
                            ? AnimalDisplayUtils.getDisplayText(male)
                            : 'Macho não definido',
                        role: 'Macho',
                        onTap: male != null
                            ? () => AnimalHistoryDialog.showAdaptive(
                                  context,
                                  animal: male,
                                )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: _metaCell(
                        label: timeline.startLabel,
                        value: timeline.startDate != null
                            ? _formatDate(timeline.startDate!)
                            : 'N/I',
                      ),
                    ),
                    Expanded(
                      child: _metaCell(
                        label: timeline.forecastLabel,
                        value: timeline.forecastDate != null
                            ? _formatDate(timeline.forecastDate!)
                            : 'N/I',
                      ),
                    ),
                    Expanded(
                      child: _metaCell(
                        label: 'Próxima etapa',
                        value: timeline.nextStageLabel,
                        valueColor: _kBlue,
                      ),
                    ),
                  ],
                ),
                if (timeline.forecastDate != null &&
                    record.stage != BreedingStage.partoRealizado &&
                    record.stage != BreedingStage.falhou) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Previsão registrada em ${_formatDate(record.updatedAt)}',
                    style: const TextStyle(
                      fontSize: 8,
                      color: _kTextHint,
                    ),
                  ),
                ],
                if (daysLeft != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        daysLeft >= 0
                            ? '$daysLeft dias restantes'
                            : '${-daysLeft} dias atrasado',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: daysLeft >= 0 ? AppColors.primary : AppColors.error,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 9,
                          color: _kTextHint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: Colors.black.withValues(alpha: 0.07),
                      valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                    ),
                  ),
                ],
                if (record.notes != null && record.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: _kSurface2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      record.notes!,
                      style: const TextStyle(
                        fontSize: 9,
                        color: _kTextSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (record.stage != BreedingStage.partoRealizado &&
              record.stage != BreedingStage.falhou) ...[
            Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: BreedingStageActions(record: record, onUpdate: _loadData),
            ),
          ],
        ],
      ),
    );
  }

  Widget _animalPill({
    required String label,
    required String role,
    VoidCallback? onTap,
  }) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _kSurface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _kBrand50,
              borderRadius: BorderRadius.circular(99),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.pets, size: 10, color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    color: _kTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 7,
                    color: _kTextHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return pill;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: pill,
    );
  }

  Widget _metaCell({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: _kTextHint,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: valueColor ?? _kTextPrimary,
          ),
        ),
      ],
    );
  }

  _StageTimeline _timelineFor(BreedingRecord record) {
    switch (record.stage) {
      case BreedingStage.encabritamento:
        return _StageTimeline(
          startLabel: 'Cobertura iniciada',
          startDate: record.matingStartDate ?? record.breedingDate,
          forecastLabel: 'Previsão separação',
          forecastDate: record.matingEndDate,
          nextStageLabel: 'Ultrassom',
        );
      case BreedingStage.separacao:
      case BreedingStage.aguardandoUltrassom:
        final start = record.separationDate ??
            record.matingEndDate ??
            record.matingStartDate ??
            record.breedingDate;
        return _StageTimeline(
          startLabel: 'Separação registrada',
          startDate: start,
          forecastLabel: 'Previsão ultrassom',
          forecastDate:
              record.ultrasoundDate ?? start.add(const Duration(days: 30)),
          nextStageLabel: 'Gestação',
        );
      case BreedingStage.gestacaoConfirmada:
        return _StageTimeline(
          startLabel: 'Gestação confirmada',
          startDate: record.ultrasoundDate ?? record.updatedAt,
          forecastLabel: 'Previsão parto',
          forecastDate: record.expectedBirth,
          nextStageLabel: 'Parto',
        );
      case BreedingStage.partoRealizado:
        return _StageTimeline(
          startLabel: 'Cobertura iniciada',
          startDate: record.matingStartDate ?? record.breedingDate,
          forecastLabel: 'Parto realizado',
          forecastDate: record.birthDate ?? record.expectedBirth,
          nextStageLabel: 'Concluído',
        );
      case BreedingStage.falhou:
        return _StageTimeline(
          startLabel: 'Cobertura iniciada',
          startDate: record.matingStartDate ?? record.breedingDate,
          forecastLabel: 'Falha registrada',
          forecastDate: record.updatedAt,
          nextStageLabel: 'Falhou',
        );
    }
  }

  int _tabIndexForStage(BreedingStage stage) {
    switch (stage) {
      case BreedingStage.encabritamento:
        return 0;
      case BreedingStage.separacao:
      case BreedingStage.aguardandoUltrassom:
        return 1;
      case BreedingStage.gestacaoConfirmada:
        return 2;
      case BreedingStage.partoRealizado:
        return 3;
      case BreedingStage.falhou:
        return 4;
    }
  }

  Color _pipelineStageIconBackground(
    BreedingStage stage, {
    required bool hasItems,
  }) {
    if (hasItems && stage == BreedingStage.partoRealizado) return _kBrand50;
    switch (stage) {
      case BreedingStage.encabritamento:
        return _kPurple50;
      case BreedingStage.separacao:
      case BreedingStage.aguardandoUltrassom:
        return _kBlue50;
      case BreedingStage.gestacaoConfirmada:
        return _kTeal50;
      case BreedingStage.partoRealizado:
        return _kBrand50;
      case BreedingStage.falhou:
        return _kErr50;
    }
  }

  Color _pipelineStageIconColor(BreedingStage stage) {
    switch (stage) {
      case BreedingStage.encabritamento:
        return _kPurple;
      case BreedingStage.separacao:
      case BreedingStage.aguardandoUltrassom:
        return _kBlue;
      case BreedingStage.gestacaoConfirmada:
        return _kTeal;
      case BreedingStage.partoRealizado:
        return AppColors.primary;
      case BreedingStage.falhou:
        return AppColors.error;
    }
  }

  String _pipelineShortLabel(BreedingStage stage) {
    switch (stage) {
      case BreedingStage.encabritamento:
        return 'Encabrit.';
      case BreedingStage.aguardandoUltrassom:
      case BreedingStage.separacao:
        return 'Aguard. US';
      case BreedingStage.gestacaoConfirmada:
        return 'Gestantes';
      case BreedingStage.partoRealizado:
        return 'Concluídos';
      case BreedingStage.falhou:
        return 'Falhados';
    }
  }

  String _stageListLabel(BreedingStage stage) {
    switch (stage) {
      case BreedingStage.encabritamento:
        return 'Encabritamento';
      case BreedingStage.separacao:
      case BreedingStage.aguardandoUltrassom:
        return 'Ultrassom';
      case BreedingStage.gestacaoConfirmada:
        return 'Gestantes';
      case BreedingStage.partoRealizado:
        return 'Concluídos';
      case BreedingStage.falhou:
        return 'Falhados';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  bool get wantKeepAlive => true;
}

class _StageTimeline {
  final String startLabel;
  final DateTime? startDate;
  final String forecastLabel;
  final DateTime? forecastDate;
  final String nextStageLabel;

  const _StageTimeline({
    required this.startLabel,
    required this.startDate,
    required this.forecastLabel,
    required this.forecastDate,
    required this.nextStageLabel,
  });
}
