import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/animal.dart';
import '../../../services/animal_service.dart';
import '../../../services/breeding_service.dart';
import '../../../services/feeding_service.dart';
import '../../../services/note_service.dart';
import '../../../services/pharmacy_service.dart';
import '../../../services/vaccination_service.dart';
import '../../../services/weight_alert_service.dart';
import '../../../shared/widgets/common/app_brand_header.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/responsive_utils.dart';
import 'widgets/management_module_card.dart';

// ── Data holder ───────────────────────────────────────────────────────────────

class _HubData {
  final AnimalStats stats;
  final int overdueVaccines;
  final int pendingWeights;
  final int upcomingBirths;
  final int totalProducts;
  final int expiringProducts;
  final int penCount;
  final int noteCount;

  const _HubData({
    required this.stats,
    required this.overdueVaccines,
    required this.pendingWeights,
    required this.upcomingBirths,
    required this.totalProducts,
    required this.expiringProducts,
    required this.penCount,
    required this.noteCount,
  });

  int get urgentCount => overdueVaccines;
  int get attentionCount => pendingWeights + upcomingBirths;
  int get totalPending => urgentCount + attentionCount;
}

// ── Main widget ───────────────────────────────────────────────────────────────

class ManagementHubScreen extends StatefulWidget {
  final List<ManagementModuleItem> modules;
  final String selectedModuleKey;
  final ValueChanged<String> onOpenModule;

  const ManagementHubScreen({
    super.key,
    required this.modules,
    required this.selectedModuleKey,
    required this.onOpenModule,
  });

  @override
  State<ManagementHubScreen> createState() => _ManagementHubScreenState();
}

class _ManagementHubScreenState extends State<ManagementHubScreen> {
  bool _loading = true;
  _HubData? _data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;

    // Captura serviços antes de qualquer await
    final animalService = context.read<AnimalService>();
    final vacService = context.read<VaccinationService>();
    final weightService = context.read<WeightAlertService>();
    final breedingService = context.read<BreedingService>();
    final pharmacyService = context.read<PharmacyService>();
    final feedingService = context.read<FeedingService>();
    final noteService = context.read<NoteService>();

    setState(() => _loading = true);

    AnimalStats? stats = animalService.stats;
    int overdueVaccines = 0;
    int pendingWeights = 0;
    int upcomingBirths = 0;
    int totalProducts = 0;
    int expiringProducts = 0;
    int penCount = 0;
    int noteCount = 0;

    // Vacinas / medicações atrasadas
    try {
      final vacData = await vacService.getVaccinationAlerts();
      overdueVaccines =
          vacData.vaccines
              .where(
                (v) => v['status'] == 'Atrasada' || v['status'] == 'Vencida',
              )
              .length +
          vacData.meds
              .where(
                (m) => m['status'] == 'Atrasada' || m['status'] == 'Vencida',
              )
              .length;
    } catch (_) {}

    // Pesagens pendentes
    try {
      final list = await weightService.fetchPendingAlertsSnapshot(
        horizonDays: 0,
      );
      pendingWeights = list.length;
    } catch (_) {}

    // Partos previstos nos próximos 14 dias
    try {
      final records = await breedingService.getBreedingRecords(limit: 100);
      final now = DateTime.now();
      upcomingBirths =
          records.where((r) {
            final expectedStr = r['expected_birth'] as String?;
            if (expectedStr == null) return false;
            final expected = DateTime.tryParse(expectedStr);
            if (expected == null) return false;
            final diff = expected.difference(now).inDays;
            return diff >= 0 && diff <= 14;
          }).length;
    } catch (_) {}

    // Farmácia — total e vencendo em 30 dias
    try {
      final stock = await pharmacyService.getPharmacyStock();
      totalProducts = stock.length;
    } catch (_) {}
    try {
      final expiring = await pharmacyService.getExpiringItems(30);
      expiringProducts = expiring.length;
    } catch (_) {}

    // Baias de alimentação
    try {
      await feedingService.loadPens();
      penCount = feedingService.pens.length;
    } catch (_) {}

    // Notas
    try {
      final notes = await noteService.getNotes();
      noteCount = notes.length;
    } catch (_) {}

    // Stats do rebanho (refaz leitura após carregamentos)
    stats ??= animalService.stats;
    stats ??= AnimalStats(
      totalAnimals: 0,
      healthy: 0,
      pregnant: 0,
      underTreatment: 0,
      vaccinesThisMonth: 0,
      birthsThisMonth: 0,
      avgWeight: 0.0,
      revenue: 0.0,
    );

    if (!mounted) return;
    setState(() {
      _data = _HubData(
        stats: stats!,
        overdueVaccines: overdueVaccines,
        pendingWeights: pendingWeights,
        upcomingBirths: upcomingBirths,
        totalProducts: totalProducts,
        expiringProducts: expiringProducts,
        penCount: penCount,
        noteCount: noteCount,
      );
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontalPadding =
            ResponsiveUtils.getPageHorizontalPaddingForWidth(width);
        final maxContentWidth =
            ResponsiveUtils.getCenteredMaxContentWidthForWidth(width);

        if (_loading || _data == null) {
          return _HubLoading(
            horizontalPadding: horizontalPadding,
            maxContentWidth: maxContentWidth,
          );
        }

        return _HubContent(
          data: _data!,
          modules: widget.modules,
          horizontalPadding: horizontalPadding,
          maxContentWidth: maxContentWidth,
          onOpenModule: widget.onOpenModule,
        );
      },
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _HubLoading extends StatelessWidget {
  final double horizontalPadding;
  final double maxContentWidth;

  const _HubLoading({
    required this.horizontalPadding,
    required this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
              const AppBrandHeader(
                title: 'Fazenda São Petrônio',
                subtitle: 'Gestão de Ovinos e Caprinos',
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Carregando manejo...'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _HubContent extends StatelessWidget {
  final _HubData data;
  final List<ManagementModuleItem> modules;
  final double horizontalPadding;
  final double maxContentWidth;
  final ValueChanged<String> onOpenModule;

  const _HubContent({
    required this.data,
    required this.modules,
    required this.horizontalPadding,
    required this.maxContentWidth,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    const gap = AppSpacing.sm;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBrandHeader(
                title: 'Fazenda São Petrônio',
                subtitle: 'Gestão de Ovinos e Caprinos',
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ManagementGreeting(moduleCount: modules.length),
                    _ManagementHeroCard(data: data),
                    const SizedBox(height: gap),
                    _ManagementKpiRow(data: data),
                    const SizedBox(height: gap),
                    const _SectionLabel(label: 'Módulos'),
                    const SizedBox(height: AppSpacing.xs),
                    _ModulesGrid(
                      modules: modules,
                      data: data,
                      onOpenModule: onOpenModule,
                    ),
                    const SizedBox(height: gap),
                    _ManagementBottomRow(data: data),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────────────────

class _ManagementGreeting extends StatelessWidget {
  final int moduleCount;
  const _ManagementGreeting({required this.moduleCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manejo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$moduleCount módulos ativos',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF22313A),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _ManagementHeroCard extends StatelessWidget {
  final _HubData data;
  const _ManagementHeroCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7D50), Color(0xFF2F8F5B), Color(0xFF3AA068)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F8F5B).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PENDÊNCIAS HOJE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 8,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.totalPending}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.totalPending == 0
                      ? 'tudo em dia'
                      : data.totalPending == 1
                      ? 'ação necessária'
                      : 'ações necessárias',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (data.urgentCount > 0)
                _HeroChip(label: 'Urgente · ${data.urgentCount}'),
              if (data.urgentCount > 0 && data.attentionCount > 0)
                const SizedBox(height: 4),
              if (data.attentionCount > 0)
                _HeroChip(label: 'Atenção · ${data.attentionCount}'),
              if (data.totalPending == 0)
                const _HeroChip(label: 'Sem pendências'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  const _HeroChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── KPI row ───────────────────────────────────────────────────────────────────

class _ManagementKpiRow extends StatelessWidget {
  final _HubData data;
  const _ManagementKpiRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiTile(
            icon: Icons.favorite_outline,
            iconBgColor: const Color(0xFFF0EBFA),
            iconColor: const Color(0xFF7B5EA7),
            value: '${data.stats.pregnant}',
            label: 'Gestantes',
            detail:
                '${data.upcomingBirths} parto${data.upcomingBirths != 1 ? 's' : ''}',
            detailColor: const Color(0xFF7B5EA7),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _KpiTile(
            icon: Icons.monitor_weight_outlined,
            iconBgColor: const Color(0xFFFBF4E6),
            iconColor: const Color(0xFFD9B15F),
            value: '${data.pendingWeights}',
            label: 'Pesagem',
            detail: 'em atraso',
            detailColor: const Color(0xFFD9B15F),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _KpiTile(
            icon: Icons.health_and_safety_outlined,
            iconBgColor: const Color(0xFFFAEAEA),
            iconColor: const Color(0xFFC94A4A),
            value: '${data.overdueVaccines}',
            label: 'Vacinas',
            detail: 'atrasadas',
            detailColor: const Color(0xFFC94A4A),
          ),
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String value;
  final String label;
  final String detail;
  final Color detailColor;

  const _KpiTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.detail,
    required this.detailColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderNeutral.withValues(alpha: 0.7),
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
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 11, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: TextStyle(
              color: detailColor,
              fontSize: 7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: const Color(0xFF22313A),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ── Module style helpers ──────────────────────────────────────────────────────

class _ModuleStyle {
  final Color iconColor;
  final Color iconBgColor;
  final String subtitle;

  const _ModuleStyle({
    required this.iconColor,
    required this.iconBgColor,
    required this.subtitle,
  });
}

_ModuleStyle _styleFor(String key) {
  switch (key) {
    case 'breeding':
      return const _ModuleStyle(
        iconColor: Color(0xFF7B5EA7),
        iconBgColor: Color(0xFFF0EBFA),
        subtitle: 'Cobertura · Gestação · Parto',
      );
    case 'weight':
      return const _ModuleStyle(
        iconColor: Color(0xFFD9B15F),
        iconBgColor: Color(0xFFFBF4E6),
        subtitle: 'Peso · GMD · Histórico',
      );
    case 'vaccines':
      return const _ModuleStyle(
        iconColor: Color(0xFFC94A4A),
        iconBgColor: Color(0xFFFAEAEA),
        subtitle: 'Vacinas · Medicamentos',
      );
    case 'pharmacy':
      return const _ModuleStyle(
        iconColor: Color(0xFF3A7EC4),
        iconBgColor: Color(0xFFEBF3FB),
        subtitle: 'Estoque · Validade',
      );
    case 'feeding':
      return const _ModuleStyle(
        iconColor: Color(0xFF1E8080),
        iconBgColor: Color(0xFFE3F4F4),
        subtitle: 'Rações · Baias · Lotes',
      );
    case 'notes':
      return const _ModuleStyle(
        iconColor: Color(0xFF5A6E78),
        iconBgColor: Color(0xFFF2F1ED),
        subtitle: 'Anotações · Lembretes',
      );
    case 'matrices':
      return const _ModuleStyle(
        iconColor: Color(0xFF4B73C7),
        iconBgColor: Color(0xFFEBF3FB),
        subtitle: 'Seleção · Avaliação',
      );
    default:
      return const _ModuleStyle(
        iconColor: Color(0xFF5A6E78),
        iconBgColor: Color(0xFFF2F1ED),
        subtitle: '',
      );
  }
}

// ── Badge data ────────────────────────────────────────────────────────────────

class _BadgeData {
  final String label;
  final Color color;
  const _BadgeData({required this.label, required this.color});
}

_BadgeData? _badgeFor(String key, _HubData data) {
  switch (key) {
    case 'breeding':
      if (data.upcomingBirths > 0) {
        return _BadgeData(
          label:
              '${data.upcomingBirths} parto${data.upcomingBirths != 1 ? 's' : ''}',
          color: const Color(0xFF7B5EA7),
        );
      }
      return null;
    case 'weight':
      if (data.pendingWeights > 0) {
        return _BadgeData(
          label:
              '${data.pendingWeights} pendente${data.pendingWeights != 1 ? 's' : ''}',
          color: const Color(0xFFD9B15F),
        );
      }
      return null;
    case 'vaccines':
      if (data.overdueVaccines > 0) {
        return const _BadgeData(
          label: 'Urgente',
          color: Color(0xFFC94A4A),
        );
      }
      return null;
    case 'pharmacy':
      if (data.expiringProducts > 0) {
        return _BadgeData(
          label:
              '${data.expiringProducts} crítico${data.expiringProducts != 1 ? 's' : ''}',
          color: const Color(0xFF3A7EC4),
        );
      }
      return const _BadgeData(label: 'OK', color: AppColors.primary);
    case 'feeding':
      return data.penCount > 0
          ? const _BadgeData(label: 'OK', color: AppColors.primary)
          : null;
    default:
      return null;
  }
}

double _progressFor(String key, _HubData data) {
  switch (key) {
    case 'breeding':
      return 1.0;
    case 'weight':
      if (data.pendingWeights == 0) return 1.0;
      return (1.0 - (data.pendingWeights / (data.pendingWeights + 5))).clamp(
        0.1,
        0.9,
      );
    case 'vaccines':
      return data.overdueVaccines == 0 ? 1.0 : 0.35;
    case 'pharmacy':
      return data.expiringProducts == 0 ? 0.85 : 0.6;
    case 'feeding':
      return data.penCount > 0 ? 1.0 : 0.1;
    case 'notes':
      return (data.noteCount * 0.2).clamp(0.1, 1.0);
    case 'matrices':
      return 0.8;
    default:
      return 0.5;
  }
}

String _statFor(String key, _HubData data) {
  switch (key) {
    case 'breeding':
      return '${data.stats.pregnant} gestante${data.stats.pregnant != 1 ? 's' : ''}';
    case 'weight':
      return data.pendingWeights == 0
          ? 'em dia'
          : '${data.pendingWeights} em atraso';
    case 'vaccines':
      return data.overdueVaccines == 0
          ? 'em dia'
          : '${data.overdueVaccines} atrasada${data.overdueVaccines != 1 ? 's' : ''}';
    case 'pharmacy':
      return '${data.totalProducts} produto${data.totalProducts != 1 ? 's' : ''}';
    case 'feeding':
      return '${data.penCount} baia${data.penCount != 1 ? 's' : ''}';
    case 'notes':
      return '${data.noteCount} nota${data.noteCount != 1 ? 's' : ''}';
    case 'matrices':
      return 'Seleção ativa';
    default:
      return '';
  }
}

// ── Modules grid ──────────────────────────────────────────────────────────────

class _ModulesGrid extends StatelessWidget {
  final List<ManagementModuleItem> modules;
  final _HubData data;
  final ValueChanged<String> onOpenModule;

  const _ModulesGrid({
    required this.modules,
    required this.data,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
        mainAxisExtent: 112,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final mod = modules[index];
        return _ModuleCard(
          module: mod,
          style: _styleFor(mod.key),
          stat: _statFor(mod.key, data),
          badge: _badgeFor(mod.key, data),
          progress: _progressFor(mod.key, data),
          onTap: () => onOpenModule(mod.key),
        );
      },
    );
  }
}

// ── Module card ───────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final ManagementModuleItem module;
  final _ModuleStyle style;
  final String stat;
  final _BadgeData? badge;
  final double progress;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.style,
    required this.stat,
    required this.badge,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone + Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: style.iconBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          module.icon,
                          size: 14,
                          color: style.iconColor,
                        ),
                      ),
                      const Spacer(),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badge!.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: badge!.color.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            badge!.label,
                            style: TextStyle(
                              color: badge!.color,
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Título
                  Text(
                    module.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),

                  // Subtítulo
                  Text(
                    style.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 8,
                    ),
                  ),

                  const Spacer(),

                  // Estatística
                  Text(
                    stat,
                    style: TextStyle(
                      color: style.iconColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),

                  // Barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: AppColors.borderNeutral.withValues(
                        alpha: 0.5,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        style.iconColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom row ────────────────────────────────────────────────────────────────

class _ManagementBottomRow extends StatelessWidget {
  final _HubData data;
  const _ManagementBottomRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _BottomCard(
            title: 'Reprodução',
            icon: Icons.favorite_outline,
            iconColor: const Color(0xFF7B5EA7),
            rows: [
              _BottomRow(
                label: 'Gestantes',
                value: '${data.stats.pregnant}',
                valueColor: const Color(0xFF7B5EA7),
              ),
              _BottomRow(
                label: 'Borregos',
                value:
                    '${data.stats.maleLambs + data.stats.femaleLambs}',
              ),
              _BottomRow(
                label: 'Reprodutores',
                value: '${data.stats.maleReproducers}',
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _BottomCard(
            title: 'Estoque',
            icon: Icons.local_pharmacy_outlined,
            iconColor: const Color(0xFF3A7EC4),
            rows: [
              _BottomRow(
                label: 'Produtos',
                value: '${data.totalProducts}',
              ),
              _BottomRow(
                label: 'Vencendo',
                value: '${data.expiringProducts}',
                valueColor: data.expiringProducts > 0
                    ? const Color(0xFFD9B15F)
                    : null,
              ),
              _BottomRow(
                label: 'Urgente',
                value: '${data.overdueVaccines}',
                valueColor: data.overdueVaccines > 0
                    ? const Color(0xFFC94A4A)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_BottomRow> rows;

  const _BottomCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    row.value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: row.valueColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomRow {
  final String label;
  final String value;
  final Color? valueColor;

  const _BottomRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
}