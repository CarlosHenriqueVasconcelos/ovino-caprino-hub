import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../application/medication_management_controller.dart';
import '../../../services/animal_service.dart';
import '../../../services/medication_service.dart';
import '../../../services/vaccination_service.dart';
import '../../../services/pharmacy_service.dart';
import '../../../models/pharmacy_stock.dart';
import '../../../models/animal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/animal_display_utils.dart';
import '../../herd/presentation/widgets/animal_history_dialog.dart';

// ── Colors ────────────────────────────────────────────────────────────────────

const _kErrColor = Color(0xFFC94A4A);
const _kErrBg = Color(0xFFFAEAEA);
const _kGoldColor = Color(0xFFD9B15F);
const _kGoldBg = Color(0xFFFBF4E6);
const _kTextPrimary = Color(0xFF22313A);
const _kTextSecondary = Color(0xFF5A6E78);
const _kTextHint = Color(0xFF9AABB4);
const _kSurface = Color(0xFFFBFBF8);
const _kBeige = Color(0xFFF6F5F1);
const _kBorder = Color(0xFFE6E4DC);

String _fmtQty(dynamic v) {
  if (v == null) return 'N/A';
  final n = v is num ? v.toDouble() : double.tryParse(v.toString());
  if (n == null) return v.toString();
  return n == n.truncateToDouble() ? n.toInt().toString() : n.toStringAsFixed(1);
}

// ── Main screen ───────────────────────────────────────────────────────────────

class MedicationManagementScreen extends StatefulWidget {
  const MedicationManagementScreen({super.key});

  @override
  State<MedicationManagementScreen> createState() =>
      _MedicationManagementScreenState();
}

class _MedicationManagementScreenState
    extends State<MedicationManagementScreen>
    with AutomaticKeepAliveClientMixin {
  late final MedicationManagementController _controller;
  late final ScrollController _vaccScroll;
  late final ScrollController _medScroll;

  int _activeTab = 0; // 0 = Vacinações  1 = Medicamentos

  // KPI counts
  int _vaccOverdue = 0;
  int _vaccScheduled = 0;
  int _vaccApplied = 0;
  int _medOverdue = 0;
  int _medScheduled = 0;
  int _medApplied = 0;
  bool _kpiLoaded = false;

  @override
  void initState() {
    super.initState();
    _vaccScroll = ScrollController()..addListener(_handleVaccScroll);
    _medScroll = ScrollController()..addListener(_handleMedScroll);
    _controller = MedicationManagementController(
      context.read<VaccinationService>(),
      context.read<MedicationService>(),
    );
    _controller.initLoad();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadKpiCounts());
  }

  @override
  void dispose() {
    _vaccScroll.dispose();
    _medScroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  // ── KPI loading ─────────────────────────────────────────────────────────────

  Future<void> _loadKpiCounts() async {
    if (!mounted) return;
    final vaccService = context.read<VaccinationService>();
    final medService  = context.read<MedicationService>();
    try {
      // 2 queries COUNT(*) em paralelo — antes eram 6 queries de limit:999
      final fVacc = vaccService.getKpiCounts();
      final fMed  = medService.getKpiCounts();
      final vaccCounts = await fVacc;
      final medCounts  = await fMed;

      if (!mounted) return;
      setState(() {
        _vaccOverdue   = vaccCounts.overdue;
        _vaccScheduled = vaccCounts.scheduled;
        _vaccApplied   = vaccCounts.applied;
        _medOverdue    = medCounts.overdue;
        _medScheduled  = medCounts.scheduled;
        _medApplied    = medCounts.applied;
        _kpiLoaded     = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _kpiLoaded = true);
    }
  }

  // ── Pagination scroll ────────────────────────────────────────────────────────

  void _handleVaccScroll() {
    if (!_vaccScroll.hasClients) return;
    if (_controller.isLoadingMoreVacc || !_controller.hasMoreVacc) return;
    final pos = _vaccScroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) _controller.loadMoreVacc();
  }

  void _handleMedScroll() {
    if (!_medScroll.hasClients) return;
    if (_controller.isLoadingMoreMed || !_controller.hasMoreMed) return;
    final pos = _medScroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) _controller.loadMoreMed();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final activeScroll = _activeTab == 0 ? _vaccScroll : _medScroll;
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: _kBeige,
        floatingActionButton: _buildFab(),
        body: SafeArea(
          child: SingleChildScrollView(
            controller: activeScroll,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 96),
            child: Column(
              children: [
                _buildSubTabRow(),
                _buildKpiStrip(),
                _buildFilterChipsRow(),
                _activeTab == 0
                    ? _buildVaccinationsList()
                    : _buildMedicationsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-tab row ───────────────────────────────────────────────────────────

  Widget _buildSubTabRow() {
    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(
          bottom: BorderSide(color: _kBorder, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          _SubTab(
            icon: Icons.health_and_safety_outlined,
            label: 'Vacinações',
            isActive: _activeTab == 0,
            onTap: () => setState(() => _activeTab = 0),
          ),
          _SubTab(
            icon: Icons.medication_outlined,
            label: 'Medicamentos',
            isActive: _activeTab == 1,
            onTap: () => setState(() => _activeTab = 1),
          ),
        ],
      ),
    );
  }

  // ── KPI strip ─────────────────────────────────────────────────────────────

  Widget _buildKpiStrip() {
    final isVacc = _activeTab == 0;
    final overdue = isVacc ? _vaccOverdue : _medOverdue;
    final scheduled = isVacc ? _vaccScheduled : _medScheduled;
    final applied = isVacc ? _vaccApplied : _medApplied;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _KpiTile(
              icon: Icons.error_outline,
              iconBg: _kErrBg,
              iconColor: _kErrColor,
              value: _kpiLoaded ? '$overdue' : '–',
              label: 'Atrasadas',
              valueColor: overdue > 0 ? _kErrColor : _kTextHint,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _KpiTile(
              icon: Icons.calendar_month_outlined,
              iconBg: _kGoldBg,
              iconColor: _kGoldColor,
              value: _kpiLoaded ? '$scheduled' : '–',
              label: 'Agendadas',
              valueColor: scheduled > 0 ? _kGoldColor : _kTextHint,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _KpiTile(
              icon: Icons.check_circle_outline,
              iconBg: AppColors.primary.withValues(alpha: 0.10),
              iconColor: AppColors.primary,
              value: _kpiLoaded ? '$applied' : '–',
              label: 'Aplicadas',
              valueColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChipsRow() {
    final isVacc = _activeTab == 0;
    final filters = isVacc
        ? ['Atrasadas', 'Agendadas', 'Aplicadas', 'Canceladas']
        : ['Atrasados', 'Agendados', 'Aplicados', 'Cancelados'];
    return Consumer<MedicationManagementController>(
      builder: (context, controller, _) {
        final currentFilter =
            isVacc ? controller.vaccinationFilter : controller.medicationFilter;
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              0,
            ),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5),
            itemBuilder: (context, index) {
              final f = filters[index];
              final isActive = f == currentFilter;
              final color = _chipColor(f);
              return GestureDetector(
                onTap: () {
                  if (isVacc) {
                    controller.setVaccFilter(f);
                  } else {
                    controller.setMedFilter(f);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? color : _kSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? color : _kBorder,
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      color: isActive ? Colors.white : _kTextSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _chipColor(String filter) {
    if (filter.startsWith('Atrasad')) return _kErrColor;
    if (filter.startsWith('Agendad')) return _kGoldColor;
    if (filter.startsWith('Aplicad')) return AppColors.primary;
    return _kTextSecondary;
  }

  // ── Lists ─────────────────────────────────────────────────────────────────

  Widget _buildVaccinationsList() {
    return Selector<MedicationManagementController, _VaccinationListState>(
      selector: (_, c) => _VaccinationListState(
        isLoading: c.isLoading,
        isLoadingMore: c.isLoadingMoreVacc,
        hasMore: c.hasMoreVacc,
        filter: c.vaccinationFilter,
        items: c.vaccinations,
      ),
      builder: (context, state, _) {
        if (state.isLoading && state.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              count: state.items.length,
              filterLabel: state.filter.toLowerCase(),
              noun: 'vacinação',
              nounPlural: 'vacinações',
              hasMore: state.hasMore,
            ),
            if (state.items.isEmpty)
              _buildEmptyState(
                icon: Icons.health_and_safety_outlined,
                title: 'Nenhuma vacinação ${state.filter.toLowerCase()}',
                subtitle:
                    state.filter == 'Atrasadas' || state.filter == 'Agendadas'
                        ? 'Tudo em dia por aqui.\nAgende a próxima vacinação.'
                        : 'Nenhum registro encontrado.',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  0,
                ),
                itemCount:
                    state.items.length + ((state.isLoadingMore || state.hasMore) ? 1 : 0),
                itemBuilder: (context, index) {
                  if ((state.isLoadingMore || state.hasMore) &&
                      index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildVaccinationCard(state.items[index]);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildMedicationsList() {
    return Selector<MedicationManagementController, _MedicationListState>(
      selector: (_, c) => _MedicationListState(
        isLoading: c.isLoading,
        isLoadingMore: c.isLoadingMoreMed,
        hasMore: c.hasMoreMed,
        filter: c.medicationFilter,
        items: c.medications,
      ),
      builder: (context, state, _) {
        if (state.isLoading && state.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              count: state.items.length,
              filterLabel: state.filter.toLowerCase(),
              noun: 'medicamento',
              nounPlural: 'medicamentos',
              hasMore: state.hasMore,
            ),
            if (state.items.isEmpty)
              _buildEmptyState(
                icon: Icons.medication_outlined,
                title: 'Nenhum medicamento ${state.filter.toLowerCase()}',
                subtitle: 'Nenhum registro encontrado.',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  0,
                ),
                itemCount:
                    state.items.length + ((state.isLoadingMore || state.hasMore) ? 1 : 0),
                itemBuilder: (context, index) {
                  if ((state.isLoadingMore || state.hasMore) &&
                      index >= state.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildMedicationCard(state.items[index]);
                },
              ),
          ],
        );
      },
    );
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required int count,
    required String filterLabel,
    required String noun,
    required String nounPlural,
    required bool hasMore,
  }) {
    final label =
        '$count ${count == 1 ? noun : nounPlural} $filterLabel${hasMore ? '+' : ''}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ordenação em breve'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text(
              'ordenar',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F1ED),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: _kTextHint),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9, color: _kTextHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _showAddDialog,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add, size: 16),
      label: Text(
        _activeTab == 0 ? 'Agendar vacina' : 'Agendar medicamento',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Vaccination card ──────────────────────────────────────────────────────

  Widget _buildVaccinationCard(Map<String, dynamic> v) {
    final status = v['status'] ?? 'Agendada';
    final isOverdue = status == 'Atrasada' || status == 'Vencida';
    final isScheduled = status == 'Agendada';
    final icColor = isOverdue
        ? _kErrColor
        : isScheduled
        ? _kGoldColor
        : AppColors.primary;
    final icBg = isOverdue
        ? _kErrBg
        : isScheduled
        ? _kGoldBg
        : AppColors.primary.withValues(alpha: 0.10);
    final badgeText = _daysLabel(
      v['scheduled_date'],
      isOverdue: isOverdue,
      isScheduled: isScheduled,
    );
    final badgeColor = isOverdue ? _kErrColor : _kGoldColor;
    final badgeBg =
        isOverdue ? _kErrBg : isScheduled ? _kGoldBg : Colors.transparent;

    return GestureDetector(
      onTap: () => _showDetails(v, isVaccination: true),
      child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: icBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    size: 14,
                    color: icColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v['vaccine_name'] ?? 'Sem nome',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FutureBuilder<Animal?>(
                        future: _getAnimalById(v['animal_id']),
                        builder: (context, snap) {
                          final animal = snap.data;
                          final sub = animal != null
                              ? _animalSubtitle(animal)
                              : '–';
                          final text = Text(
                            sub,
                            style: TextStyle(
                              fontSize: 9,
                              color: _kTextSecondary,
                              decoration: animal != null
                                  ? TextDecoration.underline
                                  : null,
                            ),
                          );
                          if (animal == null) return text;
                          return GestureDetector(
                            onTap: () => _openAnimalHistory(animal),
                            child: text,
                          );
                        },
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: _kTextHint,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  onPressed: () => _showVaccinationOptions(v),
                ),
              ],
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Divider(height: 1, color: Color(0x14000000)),
            ),

            // Meta row
            Row(
              children: [
                _MetaItem(
                  label: 'Prevista',
                  value: _formatDate(v['scheduled_date']),
                ),
                const SizedBox(width: AppSpacing.md),
                _MetaItem(
                  label: 'Tipo',
                  value: v['vaccine_type'] ?? 'N/A',
                ),
              ],
            ),

            // Action buttons
            if (isScheduled || isOverdue) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: isOverdue ? 'Registrar aplicação' : 'Aplicar agora',
                      onPressed: () =>
                          _markAsApplied(v['id'], isVaccination: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _ActionButton(
                      label: 'Remarcar',
                      isSecondary: true,
                      onPressed: () => _reschedule(v['id'], isVaccination: true),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  // ── Medication card ───────────────────────────────────────────────────────

  Widget _buildMedicationCard(Map<String, dynamic> m) {
    final status = m['status'] ?? 'Agendado';
    final isOverdue = status == 'Atrasado' || status == 'Vencido';
    final isScheduled = status == 'Agendado';
    final icColor = isOverdue
        ? _kErrColor
        : isScheduled
        ? _kGoldColor
        : AppColors.primary;
    final icBg = isOverdue
        ? _kErrBg
        : isScheduled
        ? _kGoldBg
        : AppColors.primary.withValues(alpha: 0.10);
    final badgeText = _daysLabel(
      m['date'],
      isOverdue: isOverdue,
      isScheduled: isScheduled,
    );
    final badgeColor = isOverdue ? _kErrColor : _kGoldColor;
    final badgeBg = isOverdue ? _kErrBg : isScheduled ? _kGoldBg : Colors.transparent;

    return GestureDetector(
      onTap: () => _showDetails(m, isVaccination: false),
      child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: icBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.medication_outlined,
                    size: 14,
                    color: icColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['medication_name'] ?? 'Sem nome',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FutureBuilder<Animal?>(
                        future: _getAnimalById(m['animal_id']),
                        builder: (context, snap) {
                          final animal = snap.data;
                          final sub = animal != null ? _animalSubtitle(animal) : '–';
                          final text = Text(
                            sub,
                            style: TextStyle(
                              fontSize: 9,
                              color: _kTextSecondary,
                              decoration: animal != null
                                  ? TextDecoration.underline
                                  : null,
                            ),
                          );
                          if (animal == null) return text;
                          return GestureDetector(
                            onTap: () => _openAnimalHistory(animal),
                            child: text,
                          );
                        },
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: _kTextHint,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  onPressed: () => _showMedicationOptions(m),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Divider(height: 1, color: Color(0x14000000)),
            ),

            Row(
              children: [
                _MetaItem(
                  label: 'Data',
                  value: _formatDate(m['date']),
                ),
                if (m['quantity_used'] != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  _MetaItem(
                    label: 'Qtd',
                    value: _fmtQty(m['quantity_used']),
                  ),
                ],
                if (m['dosage'] != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  _MetaItem(
                    label: 'Dose',
                    value: m['dosage'].toString(),
                  ),
                ],
              ],
            ),

            if (isScheduled || isOverdue) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: isOverdue ? 'Registrar aplicação' : 'Aplicar agora',
                      onPressed: () =>
                          _markAsApplied(m['id'], isVaccination: false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: _ActionButton(
                      label: 'Remarcar',
                      isSecondary: true,
                      onPressed: () => _reschedule(m['id'], isVaccination: false),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _animalSubtitle(Animal animal) {
    final parts = <String>[];
    if (animal.name.isNotEmpty) {
      parts.add(animal.name);
    }
    if (animal.code.isNotEmpty) parts.add('#${animal.code}');
    if (animal.lote != null && animal.lote!.isNotEmpty) {
      parts.add(animal.lote!);
    } else if (animal.species.isNotEmpty) {
      parts.add(animal.species);
    }
    return parts.join(' · ');
  }

  String? _daysLabel(
    dynamic dateRaw, {
    required bool isOverdue,
    required bool isScheduled,
  }) {
    if (dateRaw == null) return null;
    final date = DateTime.tryParse(dateRaw.toString());
    if (date == null) return null;
    final now = DateTime.now();
    if (isOverdue) {
      final days = now.difference(date).inDays;
      if (days <= 0) return null;
      return '$days dia${days != 1 ? 's' : ''} de atraso';
    }
    if (isScheduled) {
      final days = date.difference(now).inDays;
      if (days < 0) return null;
      if (days == 0) return 'Hoje';
      return 'Em $days dia${days != 1 ? 's' : ''}';
    }
    return null;
  }

  Future<Animal?> _getAnimalById(String? id) async {
    if (id == null) return null;
    final svc = Provider.of<AnimalService>(context, listen: false);
    return svc.getAnimalById(id);
  }

  void _openAnimalHistory(Animal animal) {
    AnimalHistoryDialog.showAdaptive(context, animal: animal);
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      return '$d/$m/${dt.year}';
    } catch (_) {
      return date.toString();
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddMedicationDialog(
        onSaved: () {
          _controller.reload();
          _loadKpiCounts();
        },
      ),
    );
  }

  Future<void> _markAsApplied(String id, {required bool isVaccination}) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    try {
      final now = DateTime.now().toIso8601String().split('T')[0];
      if (isVaccination) {
        final svc = Provider.of<VaccinationService>(context, listen: false);
        await svc.updateVaccination(id, {
          'status': 'Aplicada',
          'applied_date': now,
        });
      } else {
        final medSvc = Provider.of<MedicationService>(context, listen: false);
        final pharmSvc = Provider.of<PharmacyService>(context, listen: false);
        final med = await medSvc.getMedicationById(id);
        if (med != null) {
          await medSvc.updateMedication(id, {
            'status': 'Aplicado',
            'applied_date': now,
          });
          final stockId = med['pharmacy_stock_id']?.toString();
          final qtyRaw = med['quantity_used'];
          final qty = qtyRaw is num ? qtyRaw.toDouble() : double.tryParse(qtyRaw?.toString() ?? '');
          if (stockId != null && qty != null && qty > 0) {
            await pharmSvc.deductFromStock(stockId, qty, id);
          }
        }
      }
      await _controller.reload();
      _loadKpiCounts();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isVaccination
                ? 'Vacinação aplicada com sucesso!'
                : 'Medicamento aplicado e estoque atualizado!',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao marcar como aplicado: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> _cancelItem(String id, {required bool isVaccination}) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    try {
      if (isVaccination) {
        final svc = Provider.of<VaccinationService>(context, listen: false);
        await svc.updateVaccination(id, {'status': 'Cancelada'});
      } else {
        final svc = Provider.of<MedicationService>(context, listen: false);
        await svc.updateMedication(id, {'status': 'Cancelado'});
      }
      await _controller.reload();
      _loadKpiCounts();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isVaccination ? 'Vacinação cancelada' : 'Medicamento cancelado',
          ),
          backgroundColor: _kGoldColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  Future<void> _reschedule(String id, {required bool isVaccination}) async {
    final date = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final dateStr = date.toIso8601String().split('T')[0];
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (isVaccination) {
        final svc = Provider.of<VaccinationService>(context, listen: false);
        await svc.updateVaccination(id, {
          'scheduled_date': dateStr,
          'status': 'Agendada',
        });
      } else {
        final svc = Provider.of<MedicationService>(context, listen: false);
        await svc.updateMedication(id, {
          'date': dateStr,
          'status': 'Agendado',
        });
      }
      await _controller.reload();
      _loadKpiCounts();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Remarcado com sucesso!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao remarcar: $e')),
      );
    }
  }

  void _showDetails(Map<String, dynamic> data, {required bool isVaccination}) async {
    final svc = Provider.of<AnimalService>(context, listen: false);
    final animal = await svc.getAnimalById(data['animal_id']);
    if (animal == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal não encontrado.')),
      );
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => _DetailsDialog(
        data: data,
        animal: animal,
        isVaccination: isVaccination,
      ),
    );
  }

  void _showVaccinationOptions(Map<String, dynamic> v) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xs),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Ver Detalhes'),
            onTap: () {
              Navigator.pop(context);
              _showDetails(v, isVaccination: true);
            },
          ),
          if (v['status'] == 'Agendada' || v['status'] == 'Atrasada') ...[
            ListTile(
              leading: const Icon(Icons.check, color: AppColors.primary),
              title: const Text('Marcar como aplicada'),
              onTap: () {
                Navigator.pop(context);
                _markAsApplied(v['id'], isVaccination: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_repeat, color: _kGoldColor),
              title: const Text('Remarcar'),
              onTap: () {
                Navigator.pop(context);
                _reschedule(v['id'], isVaccination: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: _kErrColor),
              title: const Text('Cancelar vacinação'),
              onTap: () {
                Navigator.pop(context);
                _cancelItem(v['id'], isVaccination: true);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  void _showMedicationOptions(Map<String, dynamic> m) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xs),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Ver Detalhes'),
            onTap: () {
              Navigator.pop(context);
              _showDetails(m, isVaccination: false);
            },
          ),
          if (m['status'] == 'Agendado' || m['status'] == 'Atrasado') ...[
            ListTile(
              leading: const Icon(Icons.check, color: AppColors.primary),
              title: const Text('Marcar como aplicado'),
              onTap: () {
                Navigator.pop(context);
                _markAsApplied(m['id'], isVaccination: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_repeat, color: _kGoldColor),
              title: const Text('Remarcar'),
              onTap: () {
                Navigator.pop(context);
                _reschedule(m['id'], isVaccination: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: _kErrColor),
              title: const Text('Cancelar medicamento'),
              onTap: () {
                Navigator.pop(context);
                _cancelItem(m['id'], isVaccination: false);
              },
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ── Sub-tab widget ────────────────────────────────────────────────────────────

class _SubTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
                child: Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : const Color(0xFFF2F1ED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 13,
                        color: isActive ? AppColors.primary : _kTextHint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.primary : _kTextHint,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Container(
                height: 2,
                color: isActive ? AppColors.primary : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── KPI tile ──────────────────────────────────────────────────────────────────

class _KpiTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color valueColor;

  const _KpiTile({
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
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
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
            child: Icon(icon, size: 11, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: _kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta item ─────────────────────────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;
  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 8, color: _kTextHint),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: _kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSecondary;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _kTextSecondary,
          side: const BorderSide(color: _kBorder),
          padding: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
          minimumSize: const Size(0, 30),
        ),
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
        minimumSize: const Size(0, 30),
        elevation: 0,
      ),
      child: Text(label),
    );
  }
}

// ── Selector state wrappers ───────────────────────────────────────────────────

class _VaccinationListState {
  const _VaccinationListState({
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.filter,
    required this.items,
  });
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String filter;
  final List<Map<String, dynamic>> items;
}

class _MedicationListState {
  const _MedicationListState({
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.filter,
    required this.items,
  });
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String filter;
  final List<Map<String, dynamic>> items;
}

// ── Add dialog (lógica intacta) ───────────────────────────────────────────────

class _AddMedicationDialog extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddMedicationDialog({required this.onSaved});

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();
  final _dosageController = TextEditingController();
  final _quantityController = TextEditingController();

  String _type = 'Vacinação';
  String _vaccineType = 'Obrigatória';
  DateTime _scheduledDate = DateTime.now();
  String? _selectedAnimalId;
  List<Animal> _animalOptions = [];
  bool _loadingAnimals = true;

  List<PharmacyStock> _pharmacyStock = [];
  PharmacyStock? _selectedMedication;

  bool get _isVolumeUnit {
    if (_selectedMedication == null) return false;
    final unit = _selectedMedication!.unitOfMeasure.toLowerCase();
    return (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        _selectedMedication!.quantityPerUnit != null &&
        _selectedMedication!.quantityPerUnit! > 0;
  }

  double get _availableVolume {
    if (_selectedMedication == null) return 0;
    final m = _selectedMedication!;
    return (m.totalQuantity * (m.quantityPerUnit ?? 0)) + m.openedQuantity;
  }

  @override
  void initState() {
    super.initState();
    _loadPharmacyStock();
    _loadAnimals();
  }

  Future<void> _loadPharmacyStock() async {
    try {
      final svc = Provider.of<PharmacyService>(context, listen: false);
      final stock = await svc.getPharmacyStock();
      final filtered = stock
          .where((s) => !s.isExpired && (s.totalQuantity > 0 || s.openedQuantity > 0))
          .toList();
      if (!mounted) return;
      setState(() => _pharmacyStock = filtered);
    } catch (e) {
      debugPrint('Falha ao carregar estoque: $e');
    }
  }

  Future<void> _loadAnimals() async {
    try {
      final svc = Provider.of<AnimalService>(context, listen: false);
      final animals = await svc.searchAnimals(limit: 2000);
      AnimalDisplayUtils.sortAnimalsList(animals);
      if (!mounted) return;
      setState(() {
        _animalOptions = animals;
        _loadingAnimals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAnimals = false);
    }
  }

  String _getAnimalDisplayText(Animal animal) =>
      AnimalDisplayUtils.getDisplayText(animal);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final dialogWidth =
        isMobile ? MediaQuery.of(context).size.width * 0.95 : 500.0;

    return AlertDialog(
      title: const Text('Agendar Vacinação/Medicamento'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Vacinação', 'Medicamento']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 16),
                Autocomplete<Animal>(
                  displayStringForOption: _getAnimalDisplayText,
                  optionsBuilder: (tv) {
                    if (_loadingAnimals) return const Iterable<Animal>.empty();
                    return AnimalDisplayUtils.filterAndRankAnimals(
                        _animalOptions, tv.text);
                  },
                  onSelected: (a) => setState(() => _selectedAnimalId = a.id),
                  fieldViewBuilder: (ctx, ctrl, focus, onSub) => TextFormField(
                    controller: ctrl,
                    focusNode: focus,
                    decoration: InputDecoration(
                      labelText: 'Animal *',
                      hintText: 'Digite o número ou nome para buscar',
                      prefixIcon: const Icon(Icons.pets),
                      border: const OutlineInputBorder(),
                      suffixIcon: _selectedAnimalId != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _selectedAnimalId = null);
                                ctrl.clear();
                              },
                            )
                          : null,
                    ),
                    validator: (_) => _selectedAnimalId == null
                        ? 'Selecione um animal'
                        : null,
                  ),
                  optionsViewBuilder: (ctx, onSel, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        width: 468,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (_, i) {
                            final a = options.elementAt(i);
                            return InkWell(
                              onTap: () => onSel(a),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: AnimalDisplayUtils.buildDropdownItem(a),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_type == 'Vacinação')
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Vacina *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                  )
                else ...[
                  Autocomplete<PharmacyStock>(
                    displayStringForOption: (s) {
                      final unit = s.unitOfMeasure.toLowerCase();
                      final useVol = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
                          s.quantityPerUnit != null &&
                          s.quantityPerUnit! > 0;
                      if (useVol) {
                        final total = (s.totalQuantity * s.quantityPerUnit!) +
                            s.openedQuantity;
                        if (total <= 0) return '';
                        return '${s.medicationName} (${total.toStringAsFixed(1)}${s.unitOfMeasure})';
                      }
                      return '${s.medicationName} (${s.totalQuantity.toInt()} unidades)';
                    },
                    optionsBuilder: (tv) {
                      final avail = _pharmacyStock.where((s) {
                        final unit = s.unitOfMeasure.toLowerCase();
                        final useVol =
                            (unit == 'ml' || unit == 'mg' || unit == 'g') &&
                                s.quantityPerUnit != null &&
                                s.quantityPerUnit! > 0;
                        if (useVol) {
                          final total = (s.totalQuantity * s.quantityPerUnit!) +
                              s.openedQuantity;
                          return total > 0;
                        }
                        return s.totalQuantity > 0;
                      }).toList();
                      if (tv.text.isEmpty) return avail;
                      return avail.where((s) => s.medicationName
                          .toLowerCase()
                          .contains(tv.text.toLowerCase()));
                    },
                    onSelected: (s) => setState(() {
                      _selectedMedication = s;
                      _nameController.text = s.medicationName;
                    }),
                    fieldViewBuilder: (ctx, ctrl, focus, onSub) => TextFormField(
                      controller: ctrl,
                      focusNode: focus,
                      decoration: InputDecoration(
                        labelText: 'Medicamento da Farmácia *',
                        hintText:
                            'Digite para buscar (${_pharmacyStock.length} disponíveis)',
                        prefixIcon: const Icon(Icons.local_pharmacy),
                        border: const OutlineInputBorder(),
                        suffixIcon: _selectedMedication != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedMedication = null;
                                    _nameController.clear();
                                    _quantityController.clear();
                                  });
                                  ctrl.clear();
                                },
                              )
                            : null,
                      ),
                      validator: (_) => _selectedMedication == null
                          ? 'Selecione um medicamento'
                          : null,
                    ),
                    optionsViewBuilder: (ctx, onSel, options) => Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          width: 468,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (_, i) {
                              final s = options.elementAt(i);
                              final unit = s.unitOfMeasure.toLowerCase();
                              final useVol = (unit == 'ml' ||
                                      unit == 'mg' ||
                                      unit == 'g') &&
                                  s.quantityPerUnit != null &&
                                  s.quantityPerUnit! > 0;
                              final subtitle = useVol
                                  ? '${((s.totalQuantity * s.quantityPerUnit!) + s.openedQuantity).toStringAsFixed(1)}${s.unitOfMeasure} disponível'
                                  : '${s.totalQuantity.toInt()} unidades';
                              return InkWell(
                                onTap: () => onSel(s),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(s.medicationName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(subtitle,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600])),
                                      if (s.isLowStock)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text('Estoque baixo!',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.orange[700],
                                                  fontWeight:
                                                      FontWeight.w500)),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedMedication != null &&
                      _selectedMedication!.isLowStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _buildLowStockMessage(_selectedMedication!),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                if (_type == 'Vacinação')
                  DropdownButtonFormField<String>(
                    initialValue: _vaccineType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Vacina',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Obrigatória', 'Preventiva', 'Tratamento', 'Emergencial']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _vaccineType = v!),
                  )
                else
                  Column(
                    children: [
                      // Campo de quantidade dedicado para medicamentos com unidade volumétrica
                      if (_isVolumeUnit) ...[
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Quantidade a aplicar *',
                            border: const OutlineInputBorder(),
                            suffixText: _selectedMedication!.unitOfMeasure,
                            helperText:
                                'Disponível: ${_availableVolume.toStringAsFixed(1)} ${_selectedMedication!.unitOfMeasure}'
                                '${_selectedMedication!.openedQuantity > 0 ? ' (${_selectedMedication!.openedQuantity.toStringAsFixed(1)} aberto + ${(_selectedMedication!.totalQuantity * (_selectedMedication!.quantityPerUnit ?? 0)).toStringAsFixed(1)} fechado)' : ''}',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Informe a quantidade';
                            final qty = double.tryParse(v.replaceAll(',', '.'));
                            if (qty == null || qty <= 0) return 'Quantidade inválida';
                            if (qty > _availableVolume) {
                              return 'Insuficiente! Disponível: ${_availableVolume.toStringAsFixed(1)} ${_selectedMedication!.unitOfMeasure}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _dosageController,
                        decoration: const InputDecoration(
                          labelText: 'Dosagem / Observação',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: via intramuscular, 2x ao dia',
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      locale: const Locale('pt', 'BR'),
                      initialDate: _scheduledDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _scheduledDate = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data Agendada *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_scheduledDate.day.toString().padLeft(2, '0')}/${_scheduledDate.month.toString().padLeft(2, '0')}/${_scheduledDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _veterinarianController,
                  decoration: const InputDecoration(
                    labelText: 'Veterinário',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Agendar'),
        ),
      ],
    );
  }

  String _buildLowStockMessage(PharmacyStock s) {
    final unit = s.unitOfMeasure.toLowerCase();
    final useVol = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        s.quantityPerUnit != null &&
        s.quantityPerUnit! > 0;
    if (useVol) {
      final total = (s.totalQuantity * s.quantityPerUnit!) + s.openedQuantity;
      return 'Estoque baixo! Apenas ${total.toStringAsFixed(1)}${s.unitOfMeasure} disponível (${s.totalQuantity.toInt()} unidade${s.totalQuantity > 1 ? 's' : ''})';
    }
    return 'Estoque baixo! Apenas ${s.totalQuantity.toInt()} unidade${s.totalQuantity > 1 ? 's' : ''} disponível';
  }

  void _save() async {
    if (!_formKey.currentState!.validate() || _selectedAnimalId == null) return;

    if (_type == 'Medicamento') {
      if (_selectedMedication == null) {
        await _showFormMessage(
          'Selecione um medicamento da farmácia',
          isError: true,
        );
        return;
      }
      // Validação de estoque para unidade volumétrica é feita pelo campo _quantityController.
      // Para unidades não-volumétricas, valida pelo campo dosagem.
      if (!_isVolumeUnit) {
        final dosageText = _dosageController.text.trim();
        final qtyMatch = RegExp(r'[\d.,]+').firstMatch(dosageText);
        if (qtyMatch != null) {
          final qty =
              double.tryParse(qtyMatch.group(0)!.replaceAll(',', '.')) ?? 0;
          final avail = _selectedMedication!.totalQuantity;
          if (qty > avail) {
            await _showFormMessage(
              'Estoque insuficiente! Disponível: ${avail.toStringAsFixed(0)} ${_selectedMedication!.unitOfMeasure}',
              isError: true,
            );
            return;
          }
        }
      }
    }

    try {
      final now = DateTime.now().toIso8601String();
      if (_type == 'Vacinação') {
        final svc = Provider.of<VaccinationService>(context, listen: false);
        await svc.createVaccination({
          'id': const Uuid().v4(),
          'animal_id': _selectedAnimalId!,
          'vaccine_name': _nameController.text,
          'vaccine_type': _vaccineType,
          'scheduled_date': _scheduledDate.toIso8601String().split('T')[0],
          'veterinarian': _veterinarianController.text.isEmpty
              ? null
              : _veterinarianController.text,
          'notes':
              _notesController.text.isEmpty ? null : _notesController.text,
          'status': 'Agendada',
          'created_at': now,
          'updated_at': now,
        });
      } else {
        final svc = Provider.of<MedicationService>(context, listen: false);
        final dosage = _dosageController.text.trim();
        // Para unidades volumétricas usa o campo dedicado; para demais, extrai da dosagem
        double? qty;
        if (_isVolumeUnit && _quantityController.text.trim().isNotEmpty) {
          qty = double.tryParse(_quantityController.text.trim().replaceAll(',', '.'));
        } else {
          final qtyMatch = RegExp(r'[\d.,]+').firstMatch(dosage);
          qty = qtyMatch != null
              ? double.tryParse(qtyMatch.group(0)!.replaceAll(',', '.'))
              : null;
        }
        await svc.createMedication({
          'id': const Uuid().v4(),
          'animal_id': _selectedAnimalId!,
          'medication_name': _nameController.text,
          'date': _scheduledDate.toIso8601String().split('T')[0],
          'next_date': _scheduledDate
              .add(const Duration(days: 30))
              .toIso8601String()
              .split('T')[0],
          'dosage': dosage.isEmpty ? null : dosage,
          'veterinarian': _veterinarianController.text.isEmpty
              ? null
              : _veterinarianController.text,
          'notes':
              _notesController.text.isEmpty ? null : _notesController.text,
          'status': 'Agendado',
          'pharmacy_stock_id': _selectedMedication?.id,
          'quantity_used': qty,
          'created_at': now,
        });
      }
      if (!mounted) return;
      widget.onSaved();
      await _showFormMessage('$_type agendada com sucesso!');
    } catch (e) {
      if (mounted) {
        await _showFormMessage(
          'Erro: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _showFormMessage(
    String message, {
    bool isError = false,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isError ? 'Erro' : 'Confirmação'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}

// ── Details dialog (intacto) ──────────────────────────────────────────────────

class _DetailsDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  final dynamic animal;
  final bool isVaccination;

  const _DetailsDialog({
    required this.data,
    required this.animal,
    required this.isVaccination,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isVaccination
        ? (data['status'] == 'Aplicada'
            ? Colors.green
            : data['status'] == 'Cancelada'
                ? Colors.red
                : Colors.orange)
        : const Color(0xFF6366F1);

    final isMobile = MediaQuery.of(context).size.width < 600;
    final dialogWidth =
        isMobile ? MediaQuery.of(context).size.width * 0.95 : 600.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isVaccination ? Icons.vaccines : Icons.medication,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVaccination
                              ? 'Detalhes da Vacinação'
                              : 'Detalhes do Medicamento',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVaccination
                              ? data['vaccine_name'] ?? 'Sem nome'
                              : data['medication_name'] ?? 'Sem nome',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      icon: Icons.pets,
                      title: 'Animal',
                      content: '${animal.name} (${animal.code})',
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      icon: isVaccination ? Icons.vaccines : Icons.medication,
                      title: isVaccination
                          ? 'Nome da Vacina'
                          : 'Nome do Medicamento',
                      content: isVaccination
                          ? data['vaccine_name'] ?? 'N/A'
                          : data['medication_name'] ?? 'N/A',
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),
                    if (isVaccination) ...[
                      _buildDetailSection(
                        icon: Icons.category,
                        title: 'Tipo de Vacina',
                        content: data['vaccine_type'] ?? 'N/A',
                        color: accentColor,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.info_outline,
                        title: 'Status',
                        content: data['status'] ?? 'N/A',
                        color: accentColor,
                      ),
                    ] else ...[
                      _buildDetailSection(
                        icon: Icons.medication_liquid,
                        title: 'Dosagem / Observação',
                        content: data['dosage'] ?? 'N/A',
                        color: accentColor,
                      ),
                      if (data['quantity_used'] != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailSection(
                          icon: Icons.science_outlined,
                          title: 'Quantidade a Aplicar',
                          content: _fmtQty(data['quantity_used']),
                          color: accentColor,
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      icon: Icons.calendar_today,
                      title: isVaccination
                          ? 'Data Agendada'
                          : 'Data de Aplicação',
                      content: _formatDate(isVaccination
                          ? data['scheduled_date']
                          : data['date']),
                      color: accentColor,
                    ),
                    if (isVaccination && data['applied_date'] != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.event_available,
                        title: 'Data de Aplicação',
                        content: _formatDate(data['applied_date']),
                        color: accentColor,
                      ),
                    ],
                    if (!isVaccination && data['next_date'] != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.event_repeat,
                        title: 'Próxima Aplicação',
                        content: _formatDate(data['next_date']),
                        color: accentColor,
                      ),
                    ],
                    if (data['veterinarian'] != null &&
                        data['veterinarian'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.person,
                        title: 'Veterinário',
                        content: data['veterinarian'],
                        color: accentColor,
                      ),
                    ],
                    if (data['notes'] != null &&
                        data['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.notes,
                        title: 'Observações',
                        content: data['notes'],
                        color: accentColor,
                        isMultiline: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return date.toString();
    }
  }
}
