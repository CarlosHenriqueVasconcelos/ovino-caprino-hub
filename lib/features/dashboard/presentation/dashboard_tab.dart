import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/animal.dart';
import '../../../shared/widgets/common/app_brand_header.dart';
import '../application/dashboard_controller.dart';
import '../data/dashboard_repository.dart';
import '../widgets/dashboard_alerts_compact.dart';
import '../widgets/dashboard_bottom_stats.dart';
import '../widgets/dashboard_greeting.dart';
import '../widgets/dashboard_hero_kpi.dart';
import '../widgets/dashboard_mini_stats.dart';
import '../widgets/dashboard_herd_insights.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../../../theme/app_spacing.dart';
import '../../../services/animal_service.dart';
import '../../../services/medication_service.dart';
import '../../../services/pharmacy_service.dart';
import '../../../services/sync_service.dart';
import '../../../utils/responsive_utils.dart';

class DashboardTab extends StatelessWidget {
  final void Function(int) onGoToTab;
  const DashboardTab({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DashboardRepository>(
          create: (context) => DashboardRepository(
            animalService: context.read<AnimalService>(),
            pharmacyService: context.read<PharmacyService>(),
            medicationService: context.read<MedicationService>(),
          ),
        ),
        ChangeNotifierProvider<DashboardController>(
          create: (context) => DashboardController(
            dashboardRepository: context.read<DashboardRepository>(),
          ),
        ),
      ],
      child: _SyncAwareDashboard(onGoToTab: onGoToTab),
    );
  }
}

/// Escuta o SyncService e recarrega o dashboard quando o sync termina com sucesso.
class _SyncAwareDashboard extends StatefulWidget {
  final void Function(int) onGoToTab;
  const _SyncAwareDashboard({required this.onGoToTab});

  @override
  State<_SyncAwareDashboard> createState() => _SyncAwareDashboardState();
}

class _SyncAwareDashboardState extends State<_SyncAwareDashboard> {
  late final SyncService _syncService;

  @override
  void initState() {
    super.initState();
    _syncService = context.read<SyncService>();
    _syncService.addListener(_onSyncChanged);
  }

  void _onSyncChanged() {
    if (!mounted) return;
    if (_syncService.status == SyncStatus.success) {
      context.read<DashboardController>().refresh();
    }
  }

  @override
  void dispose() {
    _syncService.removeListener(_onSyncChanged);
    super.dispose();
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

          final isLoading = context.select<DashboardController, bool>(
            (c) => c.isLoading,
          );
          final stats = context.select<DashboardController, AnimalStats?>(
            (c) => c.stats,
          );

          if (isLoading || stats == null) {
            return _DashboardLoading(
              horizontalPadding: horizontalPadding,
              maxContentWidth: maxContentWidth,
            );
          }

          return _DashboardContent(
            stats: stats,
            width: width,
            horizontalPadding: horizontalPadding,
            maxContentWidth: maxContentWidth,
            onGoToTab: widget.onGoToTab,
          );
        },
    );
  }
}

// ── Conteúdo principal ────────────────────────────────────────────────────────

class _DashboardContent extends StatelessWidget {
  final AnimalStats stats;
  final double width;
  final double horizontalPadding;
  final double maxContentWidth;
  final void Function(int) onGoToTab;

  const _DashboardContent({
    required this.stats,
    required this.width,
    required this.horizontalPadding,
    required this.maxContentWidth,
    required this.onGoToTab,
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
              // ── Header ─────────────────────────────────────────────
              const AppBrandHeader(
                title: 'Terra Tech',
                subtitle: 'Ovinos e Caprinos',
              ),

              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Saudação ──────────────────────────────────────
                    const DashboardGreeting(),

                    // ── Card hero: total de animais ───────────────────
                    DashboardHeroKpi(stats: stats),
                    const SizedBox(height: gap),

                    // ── Mini stats: saudáveis / tratamento / gestantes ─
                    DashboardMiniStats(stats: stats),
                    const SizedBox(height: gap),

                    // ── Alertas ativos (compacto) ─────────────────────
                    DashboardAlertsCompact(onGoToTab: onGoToTab),
                    const SizedBox(height: gap),

                    // ── Ações rápidas ─────────────────────────────────
                    const _SectionLabel(label: 'Ações Rápidas'),
                    const SizedBox(height: AppSpacing.xs),
                    DashboardQuickActions(onGoToTab: onGoToTab),
                    const SizedBox(height: gap),

                    // ── Reprodução + Peso médio ───────────────────────
                    DashboardBottomStats(stats: stats),
                    const SizedBox(height: gap),

                    // ── Insights do rebanho ───────────────────────────
                    const _SectionLabel(label: 'Rebanho'),
                    const SizedBox(height: AppSpacing.xs),
                    DashboardHerdInsights(
                      stats: stats,
                      onGoToHerd: () => onGoToTab(1),
                    ),
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

// ── Label de seção inline ─────────────────────────────────────────────────────

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

// ── Loading ───────────────────────────────────────────────────────────────────

class _DashboardLoading extends StatelessWidget {
  final double horizontalPadding;
  final double maxContentWidth;

  const _DashboardLoading({
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBrandHeader(
                title: 'Terra Tech',
                subtitle: 'Ovinos e Caprinos',
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
                      Text('Carregando painel...'),
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
