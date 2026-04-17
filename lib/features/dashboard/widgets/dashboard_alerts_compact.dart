import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/weight_alert.dart';
import '../../../services/animal_service.dart';
import '../../../services/medication_service.dart';
import '../../../services/vaccination_service.dart';
import '../../../services/breeding_service.dart';
import '../../../services/weight_alert_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardAlertsCompact extends StatefulWidget {
  final void Function(int) onGoToTab;

  const DashboardAlertsCompact({super.key, required this.onGoToTab});

  @override
  State<DashboardAlertsCompact> createState() =>
      _DashboardAlertsCompactState();
}

class _DashboardAlertsCompactState extends State<DashboardAlertsCompact> {
  bool _loading = true;
  final List<_AlertItem> _alerts = [];

  VaccinationService? _vacService;
  MedicationService? _medService;
  BreedingService? _breedingService;
  WeightAlertService? _weightService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final vacService = context.read<VaccinationService>();
    final medService = context.read<MedicationService>();
    final breedingService = context.read<BreedingService>();
    final weightService = context.read<WeightAlertService>();

    if (_vacService != vacService) {
      _vacService?.removeListener(_load);
      _vacService = vacService..addListener(_load);
    }
    if (_medService != medService) {
      _medService?.removeListener(_load);
      _medService = medService..addListener(_load);
    }
    if (_breedingService != breedingService) {
      _breedingService?.removeListener(_load);
      _breedingService = breedingService..addListener(_load);
    }
    if (_weightService != weightService) {
      _weightService?.removeListener(_load);
      _weightService = weightService..addListener(_load);
    }

    if (_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  @override
  void dispose() {
    _vacService?.removeListener(_load);
    _medService?.removeListener(_load);
    _breedingService?.removeListener(_load);
    _weightService?.removeListener(_load);
    super.dispose();
  }

  // Debounce: se já há um load em andamento, não enfileira outro
  bool _loadInProgress = false;

  Future<void> _load() async {
    if (!mounted) return;
    if (_loadInProgress) return;
    _loadInProgress = true;

    // Captura serviços antes de qualquer await
    final vacService = context.read<VaccinationService>();
    final medService = context.read<MedicationService>();
    final breedingService = context.read<BreedingService>();
    final weightService = context.read<WeightAlertService>();
    final animalService = context.read<AnimalService>();

    setState(() => _loading = true);

    // ── Dispara todas as futures em paralelo ──────────────────────
    final fVacKpi      = vacService.getKpiCounts();
    final fMedKpi      = medService.getKpiCounts();
    final fVacFirst    = vacService.getOverdueVaccinationsWithAnimalInfo(
      options: const VaccinationQueryOptions(limit: 1),
    );
    final fMedFirst    = medService.getOverdueMedicationsWithAnimalInfo(
      options: const MedicationQueryOptions(limit: 1),
    );
    final fBreeding    = breedingService.getBreedingRecords(limit: 100);
    final fWeight      = weightService.fetchPendingAlertsSnapshot(horizonDays: 0);

    ({int overdue, int scheduled, int applied})? vacKpi;
    ({int overdue, int scheduled, int applied})? medKpi;
    List<Map<String, dynamic>> vacFirst = const [];
    List<Map<String, dynamic>> medFirst = const [];
    List<Map<String, dynamic>> breedingRecords = const [];
    List<WeightAlert> pending = const [];

    try { vacKpi          = await fVacKpi;     } catch (_) {}
    try { medKpi          = await fMedKpi;     } catch (_) {}
    try { vacFirst        = await fVacFirst;   } catch (_) {}
    try { medFirst        = await fMedFirst;   } catch (_) {}
    try { breedingRecords = await fBreeding;   } catch (_) {}
    try { pending         = await fWeight;     } catch (_) {}

    if (!mounted) { _loadInProgress = false; return; }

    final alerts = <_AlertItem>[];

    // ── Vacinas atrasadas ─────────────────────────────────────────
    final overdueVacs = vacKpi?.overdue ?? 0;
    if (overdueVacs > 0) {
      final firstName = vacFirst.isNotEmpty
          ? (vacFirst.first['vaccine_name'] ?? 'Vacina').toString()
          : 'Vacina';
      alerts.add(_AlertItem(
        title: 'Vacinas atrasadas — $overdueVacs animal${overdueVacs > 1 ? 'is' : ''}',
        subtitle: '$firstName • Sanidade',
        icon: Icons.health_and_safety_outlined,
        accentColor: AppColors.error,
        badgeLabel: 'Urgente',
        badgeColor: AppColors.error,
        onTap: () => widget.onGoToTab(6),
      ));
    }

    // ── Medicações atrasadas ──────────────────────────────────────
    final overdueMeds = medKpi?.overdue ?? 0;
    if (overdueMeds > 0 && alerts.length < 3) {
      final firstName = medFirst.isNotEmpty
          ? (medFirst.first['medication_name'] ?? 'Medicação').toString()
          : 'Medicação';
      alerts.add(_AlertItem(
        title: 'Medicações atrasadas — $overdueMeds animal${overdueMeds > 1 ? 'is' : ''}',
        subtitle: '$firstName • Sanidade',
        icon: Icons.medication_outlined,
        accentColor: const Color(0xFFB04FAD),
        badgeLabel: 'Urgente',
        badgeColor: const Color(0xFFB04FAD),
        onTap: () => widget.onGoToTab(6),
      ));
    }

    // ── Partos previstos nos próximos 14 dias ─────────────────────
    if (alerts.length < 3) {
      try {
        final now = DateTime.now();
        final upcoming = breedingRecords.where((r) {
          final expectedStr = r['expected_birth'] as String?;
          if (expectedStr == null) return false;
          final expected = DateTime.tryParse(expectedStr);
          if (expected == null) return false;
          final diff = expected.difference(now).inDays;
          return diff >= 0 && diff <= 14;
        }).toList();

        if (upcoming.isNotEmpty) {
          final first = upcoming.first;
          final femaleId = first['female_animal_id']?.toString() ?? '';

          String femaleLabel = '';
          try {
            if (femaleId.isNotEmpty) {
              final animal = await animalService.getAnimalById(femaleId);
              if (animal != null) {
                femaleLabel = animal.name.isNotEmpty ? animal.name : animal.code;
              }
            }
          } catch (_) {}
          if (!mounted) { _loadInProgress = false; return; }

          final expectedStr = first['expected_birth'] as String?;
          String daysLabel = 'Reprodução';
          if (expectedStr != null) {
            final expected = DateTime.tryParse(expectedStr);
            if (expected != null) {
              final diff = expected.difference(now).inDays;
              final day = expected.day.toString().padLeft(2, '0');
              final month = expected.month.toString().padLeft(2, '0');
              daysLabel = '$day/$month • $diff dia${diff != 1 ? 's' : ''}';
            }
          }

          final title = femaleLabel.isNotEmpty
              ? 'Parto previsto • $femaleLabel'
              : 'Parto previsto • ${upcoming.length} fêmea${upcoming.length > 1 ? 's' : ''}';

          alerts.add(_AlertItem(
            title: title,
            subtitle: daysLabel,
            icon: Icons.favorite_outline,
            accentColor: const Color(0xFF4B73C7),
            badgeLabel: 'Parto',
            badgeColor: const Color(0xFF4B73C7),
            onTap: () => widget.onGoToTab(4),
          ));
        }
      } catch (_) {}
    }

    // ── Pesagens pendentes ────────────────────────────────────────
    if (alerts.length < 3) {
      try {
        if (pending.isNotEmpty) {
          final count = pending.length;
          final types = pending.map((a) => a.typeLabel).toSet().take(2).join(', ');
          final subtitle = types.isNotEmpty
              ? '$types • $count pendente${count > 1 ? 's' : ''}'
              : '$count animal${count > 1 ? 'is' : ''} pendente${count > 1 ? 's' : ''}';

          alerts.add(_AlertItem(
            title: 'Pesagem em atraso',
            subtitle: subtitle,
            icon: Icons.monitor_weight_outlined,
            accentColor: AppColors.goldSoft,
            badgeLabel: 'Pendente',
            badgeColor: AppColors.goldSoft,
            onTap: () => widget.onGoToTab(3),
          ));
        }
      } catch (_) {}
    }

    if (!mounted) { _loadInProgress = false; return; }
    _loadInProgress = false;
    setState(() {
      _alerts
        ..clear()
        ..addAll(alerts.take(3));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderNeutral.withValues(alpha: 0.8),
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
                  'Alertas ativos',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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

          // Conteúdo
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
          else if (_alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Nenhum alerta pendente',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              itemCount: _alerts.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
                color: AppColors.borderNeutral.withValues(alpha: 0.6),
              ),
              itemBuilder: (context, index) =>
                  _AlertRow(item: _alerts[index]),
            ),
        ],
      ),
    );
  }
}

class _AlertItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String badgeLabel;
  final Color badgeColor;
  final VoidCallback onTap;

  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.badgeLabel,
    required this.badgeColor,
    required this.onTap,
  });
}

class _AlertRow extends StatelessWidget {
  final _AlertItem item;

  const _AlertRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 18, color: item.accentColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: item.badgeColor.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                item.badgeLabel,
                style: TextStyle(
                  color: item.badgeColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
