import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/medication_service.dart';
import '../../../services/vaccination_service.dart';
import '../../../services/weight_alert_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardAlertsCompact extends StatefulWidget {
  final void Function(int) onGoToTab;
  const DashboardAlertsCompact({super.key, required this.onGoToTab});

  @override
  State<DashboardAlertsCompact> createState() => _DashboardAlertsCompactState();
}

class _DashboardAlertsCompactState extends State<DashboardAlertsCompact> {
  bool _loading = true;
  List<_SectionItem> _vacItems = [];
  List<_SectionItem> _medItems = [];
  List<_SectionItem> _weightItems = [];

  VaccinationService? _vacService;
  MedicationService? _medService;
  WeightAlertService? _weightService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vacService = context.read<VaccinationService>();
    final medService = context.read<MedicationService>();
    final weightService = context.read<WeightAlertService>();

    if (_vacService != vacService) {
      _vacService?.removeListener(_load);
      _vacService = vacService..addListener(_load);
    }
    if (_medService != medService) {
      _medService?.removeListener(_load);
      _medService = medService..addListener(_load);
    }
    if (_weightService != weightService) {
      _weightService?.removeListener(_load);
      _weightService = weightService..addListener(_load);
    }
    if (_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 180), () {
          if (mounted) _load();
        });
      });
    }
  }

  @override
  void dispose() {
    _vacService?.removeListener(_load);
    _medService?.removeListener(_load);
    _weightService?.removeListener(_load);
    super.dispose();
  }

  bool _loadInProgress = false;

  Future<void> _load() async {
    if (!mounted || _loadInProgress) return;
    _loadInProgress = true;
    setState(() => _loading = true);

    final vacService = context.read<VaccinationService>();
    final medService = context.read<MedicationService>();
    final weightService = context.read<WeightAlertService>();

    final now = DateTime.now();
    final horizon = now.add(const Duration(days: 3));
    final horizonEnd = DateTime(horizon.year, horizon.month, horizon.day, 23, 59, 59);

    final fVacOverdue = vacService.getOverdueVaccinationsWithAnimalInfo(
      options: const VaccinationQueryOptions(limit: 20),
    );
    final fVacUpcoming = vacService.getScheduledVaccinationsWithAnimalInfo(
      options: VaccinationQueryOptions(endDate: horizonEnd, limit: 20),
    );
    final fMedOverdue = medService.getOverdueMedicationsWithAnimalInfo(
      options: const MedicationQueryOptions(limit: 20),
    );
    final fMedUpcoming = medService.getScheduledMedicationsWithAnimalInfo(
      options: MedicationQueryOptions(endDate: horizonEnd, limit: 20),
    );
    final fWeight = weightService.getPendingWeightAlerts(horizon);

    List<Map<String, dynamic>> vacOverdue = [];
    List<Map<String, dynamic>> vacUpcoming = [];
    List<Map<String, dynamic>> medOverdue = [];
    List<Map<String, dynamic>> medUpcoming = [];
    List<Map<String, dynamic>> weightRaw = [];

    try { vacOverdue  = await fVacOverdue;  } catch (_) {}
    try { vacUpcoming = await fVacUpcoming; } catch (_) {}
    try { medOverdue  = await fMedOverdue;  } catch (_) {}
    try { medUpcoming = await fMedUpcoming; } catch (_) {}
    try { weightRaw   = await fWeight;      } catch (_) {}

    if (!mounted) { _loadInProgress = false; return; }

    // Vaccinations: overdue first, then upcoming, dedup by id
    final vacSeen = <String>{};
    final vacItems = <_SectionItem>[];
    for (final row in [...vacOverdue, ...vacUpcoming]) {
      final id = row['id']?.toString() ?? '';
      if (!vacSeen.add(id)) continue;
      final date = _parseDate(row['scheduled_date']);
      if (date == null) continue;
      vacItems.add(_SectionItem(
        animalLabel: _animalLabel(row),
        description: row['vaccine_name']?.toString() ?? 'Vacina',
        dueDate: date,
      ));
    }

    // Medications: overdue first, then upcoming, dedup by id
    final medSeen = <String>{};
    final medItems = <_SectionItem>[];
    for (final row in [...medOverdue, ...medUpcoming]) {
      final id = row['id']?.toString() ?? '';
      if (!medSeen.add(id)) continue;
      final date = _parseDate(row['date']) ?? _parseDate(row['next_date']);
      if (date == null) continue;
      medItems.add(_SectionItem(
        animalLabel: _animalLabel(row),
        description: row['medication_name']?.toString() ?? 'Medicação',
        dueDate: date,
      ));
    }

    // Weight alerts
    final weightItems = <_SectionItem>[];
    for (final row in weightRaw) {
      final date = _parseDate(row['due_date']);
      if (date == null) continue;
      final animalName = row['animal_name']?.toString() ?? '';
      final animalCode = row['animal_code']?.toString() ?? '';
      weightItems.add(_SectionItem(
        animalLabel: animalName.isNotEmpty ? animalName : (animalCode.isNotEmpty ? animalCode : 'Animal'),
        description: _weightTypeLabel(row['alert_type']?.toString() ?? ''),
        dueDate: date,
      ));
    }

    _loadInProgress = false;
    if (!mounted) return;
    setState(() {
      _vacItems = vacItems;
      _medItems = medItems;
      _weightItems = weightItems;
      _loading = false;
    });
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  String _animalLabel(Map<String, dynamic> row) {
    final name = row['animal_name']?.toString() ?? '';
    final code = row['animal_code']?.toString() ?? '';
    return name.isNotEmpty ? name : (code.isNotEmpty ? code : 'Animal');
  }

  String _weightTypeLabel(String type) {
    switch (type) {
      case '30d':    return 'Pesagem 30 dias';
      case '60d':    return 'Pesagem 60 dias';
      case '90d':    return 'Pesagem 90 dias';
      case '120d':   return 'Pesagem 120 dias';
      case 'monthly': return 'Pesagem mensal';
      default:       return 'Pesagem';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAlerts = _vacItems.length + _medItems.length + _weightItems.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderNeutral.withValues(alpha: 0.8)),
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Text(
                  'Alertas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!_loading && totalAlerts > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$totalAlerts',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onTap: () => widget.onGoToTab(6),
                  child: Text(
                    'ver todos',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...[
            _AlertSection(
              icon: Icons.health_and_safety_outlined,
              title: 'Vacinação',
              color: AppColors.error,
              items: _vacItems,
              onTap: () => widget.onGoToTab(6),
            ),
            Divider(height: 1, color: AppColors.borderNeutral.withValues(alpha: 0.5)),
            _AlertSection(
              icon: Icons.medication_outlined,
              title: 'Medicação',
              color: const Color(0xFFB04FAD),
              items: _medItems,
              onTap: () => widget.onGoToTab(6),
            ),
            Divider(height: 1, color: AppColors.borderNeutral.withValues(alpha: 0.5)),
            _AlertSection(
              icon: Icons.monitor_weight_outlined,
              title: 'Pesagem',
              color: AppColors.goldSoft,
              items: _weightItems,
              onTap: () => widget.onGoToTab(3),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _SectionItem {
  final String animalLabel;
  final String description;
  final DateTime dueDate;

  const _SectionItem({
    required this.animalLabel,
    required this.description,
    required this.dueDate,
  });
}

// ── Section widget ─────────────────────────────────────────────────────────────

class _AlertSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<_SectionItem> items;
  final VoidCallback onTap;

  const _AlertSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
    required this.onTap,
  });

  static const double _rowHeight = 46.0;
  static const int _maxVisible = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  '(${items.length})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Nenhum alerta',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: _rowHeight * _maxVisible.clamp(1, items.length),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemExtent: _rowHeight,
                itemBuilder: (context, index) => _SectionRow(
                  item: items[index],
                  onTap: onTap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Row widget ────────────────────────────────────────────────────────────────

class _SectionRow extends StatelessWidget {
  final _SectionItem item;
  final VoidCallback onTap;

  const _SectionRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dueOnly = DateTime(item.dueDate.year, item.dueDate.month, item.dueDate.day);
    final diff = dueOnly.difference(todayOnly).inDays;

    final Color badgeColor;
    final String badgeLabel;
    if (diff < 0) {
      badgeLabel = 'Atrasado';
      badgeColor = AppColors.error;
    } else if (diff == 0) {
      badgeLabel = 'Hoje';
      badgeColor = Colors.orange;
    } else if (diff == 1) {
      badgeLabel = 'Amanhã';
      badgeColor = AppColors.warning;
    } else {
      badgeLabel = 'Em $diff dias';
      badgeColor = AppColors.primary;
    }

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: _AlertSection._rowHeight,
        child: Row(
          children: [
            // Time badge
            Container(
              constraints: const BoxConstraints(minWidth: 64),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: badgeColor.withValues(alpha: 0.28)),
              ),
              child: Text(
                badgeLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Animal + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.animalLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
