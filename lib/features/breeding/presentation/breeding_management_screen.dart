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
import '../../../shared/widgets/common/metric_card.dart';
import '../../../shared/widgets/common/search_field.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../shared/widgets/common/status_chip.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/animal_display_utils.dart';
import 'widgets/breeding_import_dialog.dart';
import 'widgets/breeding_stage_actions.dart';
import 'widgets/breeding_wizard_dialog.dart';
import 'widgets/repro_alerts_card.dart';

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

      final ids = <String>{
        ...records
            .where((r) => (r.femaleAnimalId ?? '').isNotEmpty)
            .map((r) => r.femaleAnimalId!),
        ...records
            .where((r) => (r.maleAnimalId ?? '').isNotEmpty)
            .map((r) => r.maleAnimalId!),
      };
      final idList = ids.toList();
      final animalsMap = <String, Animal>{};

      final fetched = await Future.wait(
        idList.map((id) => animalService.getAnimalById(id)),
      );
      for (var i = 0; i < idList.length; i++) {
        final animal = fetched[i];
        if (animal != null) animalsMap[idList[i]] = animal;
      }

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
    var records = _breedingRecords.where((r) => r.stage == stage).toList();

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

  StatusChipVariant _stageVariant(BreedingStage stage) {
    switch (stage) {
      case BreedingStage.partoRealizado:
        return StatusChipVariant.success;
      case BreedingStage.falhou:
        return StatusChipVariant.danger;
      case BreedingStage.encabritamento:
      case BreedingStage.aguardandoUltrassom:
      case BreedingStage.separacao:
      case BreedingStage.gestacaoConfirmada:
        return StatusChipVariant.info;
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

    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: AppCard(
                variant: AppCardVariant.soft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Gestão de Reprodução',
                      subtitle: 'Acompanhamento do ciclo reprodutivo completo',
                      action: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GhostButton(
                            label: 'Importar',
                            icon: Icons.playlist_add,
                            onPressed: _showImportDialog,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          PrimaryButton(
                            label: 'Nova Cobertura',
                            icon: Icons.add,
                            onPressed: _showBreedingWizard,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = width >= 1080 ? 5 : (width >= 760 ? 3 : 2);
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: columns,
                          crossAxisSpacing: AppSpacing.xs,
                          mainAxisSpacing: AppSpacing.xs,
                          childAspectRatio: columns <= 2 ? 2.2 : 2.4,
                          children: [
                            MetricCard(
                              title: 'Encabritamento',
                              value: '${tabEncabritamento.length}',
                              icon: Icons.favorite,
                              accentColor: _stageColor(BreedingStage.encabritamento),
                            ),
                            MetricCard(
                              title: 'Aguardando US',
                              value: '${tabUltrassom.length}',
                              icon: Icons.medical_services,
                              accentColor: _stageColor(BreedingStage.aguardandoUltrassom),
                            ),
                            MetricCard(
                              title: 'Gestantes',
                              value: '${tabGestantes.length}',
                              icon: Icons.pregnant_woman,
                              accentColor: _stageColor(BreedingStage.gestacaoConfirmada),
                            ),
                            MetricCard(
                              title: 'Concluídos',
                              value: '${tabConcluidos.length}',
                              icon: Icons.check_circle,
                              accentColor: _stageColor(BreedingStage.partoRealizado),
                            ),
                            MetricCard(
                              title: 'Falhados',
                              value: '${tabFalhados.length}',
                              icon: Icons.cancel,
                              accentColor: _stageColor(BreedingStage.falhou),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: ReproAlertsCard(),
            ),
            Padding(
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
            Padding(
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
                  tabs: [
                    Tab(
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, size: 16),
                          const SizedBox(width: 6),
                          Text('Encabritamento (${tabEncabritamento.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          const Icon(Icons.medical_services, size: 16),
                          const SizedBox(width: 6),
                          Text('Ultrassom (${tabUltrassom.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          const Icon(Icons.pregnant_woman, size: 16),
                          const SizedBox(width: 6),
                          Text('Gestantes (${tabGestantes.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16),
                          const SizedBox(width: 6),
                          Text('Concluídos (${tabConcluidos.length})'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          const Icon(Icons.cancel, size: 16),
                          const SizedBox(width: 6),
                          Text('Falhados (${tabFalhados.length})'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
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
          ],
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
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: records.length,
      itemBuilder: (context, index) => _buildBreedingCard(records[index]),
    );
  }

  Widget _buildBreedingCard(BreedingRecord record) {
    final female = _animalsMap[record.femaleAnimalId];
    final male = _animalsMap[record.maleAnimalId];
    final progress = record.progressPercentage();
    final daysLeft = record.daysRemaining();
    final stageColor = _stageColor(record.stage);
    final stageIcon = _stageIcon(record.stage);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: stageColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stageIcon, color: stageColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.stage.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: stageColor,
                          ),
                    ),
                    Text(
                      'Iniciado em ${_formatDate(record.matingStartDate ?? record.breedingDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: record.stage.displayName,
                variant: _stageVariant(record.stage),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            variant: AppCardVariant.soft,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: _animalInfoBlock(
                    title: 'Fêmea',
                    value: female != null
                        ? AnimalDisplayUtils.getDisplayText(female)
                        : 'N/A',
                    icon: Icons.female,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _animalInfoBlock(
                    title: 'Macho',
                    value:
                        male != null ? AnimalDisplayUtils.getDisplayText(male) : 'N/A',
                    icon: Icons.male,
                  ),
                ),
              ],
            ),
          ),
          if (daysLeft != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  'Progresso',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  daysLeft >= 0
                      ? '$daysLeft dias restantes'
                      : '${-daysLeft} dias atrasado',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: daysLeft >= 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: AppColors.borderNeutral.withValues(alpha: 0.55),
              valueColor: AlwaysStoppedAnimation<Color>(stageColor),
            ),
          ],
          if (record.stage == BreedingStage.encabritamento &&
              record.matingEndDate != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDateInfo('Data de Separação', record.matingEndDate!),
          ],
          if (record.stage == BreedingStage.gestacaoConfirmada &&
              record.expectedBirth != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDateInfo('Previsão de Parto', record.expectedBirth!),
          ],
          if (record.stage == BreedingStage.partoRealizado &&
              record.birthDate != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildDateInfo('Data do Parto', record.birthDate!),
          ],
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              variant: AppCardVariant.outlined,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      record.notes!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (record.stage != BreedingStage.partoRealizado &&
              record.stage != BreedingStage.falhou) ...[
            const SizedBox(height: AppSpacing.sm),
            BreedingStageActions(record: record, onUpdate: _loadData),
          ],
        ],
      ),
    );
  }

  Widget _animalInfoBlock({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return AppCard(
      variant: AppCardVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: AppColors.primarySupport,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            _formatDate(date),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  bool get wantKeepAlive => true;
}
