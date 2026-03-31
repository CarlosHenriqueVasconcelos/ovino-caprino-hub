import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/breeding_service.dart';
import '../../../../services/events/app_events.dart';
import '../../../../services/events/event_bus.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

class ReproAlertsCard extends StatefulWidget {
  final int daysAhead;

  const ReproAlertsCard({super.key, this.daysAhead = 30});

  @override
  State<ReproAlertsCard> createState() => _ReproAlertsCardState();
}

class _ReproAlertsCardState extends State<ReproAlertsCard>
    with EventBusSubscriptions {
  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    _scheduleLoad();
  }

  void _setupEventListeners() {
    onEvent<BreedingRecordCreatedEvent>((_) => _scheduleLoad(force: true));
    onEvent<BreedingRecordUpdatedEvent>((_) => _scheduleLoad(force: true));
    onEvent<BreedingRecordDeletedEvent>((_) => _scheduleLoad(force: true));
    onEvent<AlertsRefreshRequestedEvent>((_) => _scheduleLoad(force: true));
  }

  @override
  void didUpdateWidget(covariant ReproAlertsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daysAhead != widget.daysAhead) {
      _scheduleLoad(force: true);
    }
  }

  void _scheduleLoad({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<BreedingService>()
          .loadBoardData(daysAhead: widget.daysAhead, force: force);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BreedingService>(
      builder: (context, service, _) {
        final data = service.boardData;
        final error = service.boardError;
        final isLoading = service.isBoardLoading && data == null;

        if (isLoading) {
          return const AppCard(
            variant: AppCardVariant.elevated,
            child: SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (error != null && data == null) {
          return AppCard(
            variant: AppCardVariant.elevated,
            child: SectionHeader(
              title: 'Alertas de Reprodução',
              subtitle: 'Erro ao carregar: $error',
              action: IconButton(
                tooltip: 'Tentar novamente',
                onPressed: () => _scheduleLoad(force: true),
                icon: const Icon(Icons.refresh),
              ),
            ),
          );
        }

        if (data == null) {
          return AppCard(
            variant: AppCardVariant.elevated,
            child: SectionHeader(
              title: 'Alertas de Reprodução',
              subtitle: 'Sem dados disponíveis',
              action: IconButton(
                tooltip: 'Atualizar',
                onPressed: () => _scheduleLoad(force: true),
                icon: const Icon(Icons.refresh),
              ),
            ),
          );
        }

        final none = data.separacoes.isEmpty &&
            data.ultrassons.isEmpty &&
            data.partos.isEmpty;

        return AppCard(
          variant: AppCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Alertas de Reprodução',
                subtitle: 'Próximos ${widget.daysAhead} dias',
                action: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.end,
                  children: [
                    if (data.overdueTotal > 0)
                      StatusChip(
                        label: '${data.overdueTotal} atrasado(s)',
                        variant: StatusChipVariant.danger,
                        icon: Icons.priority_high,
                      ),
                    IconButton(
                      tooltip: 'Atualizar',
                      onPressed: () => _scheduleLoad(force: true),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (none)
                AppCard(
                  variant: AppCardVariant.soft,
                  child: Text(
                    'Nenhum alerta de reprodução no período.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                )
              else ...[
                _Section(
                  title: 'Separações',
                  icon: Icons.transit_enterexit,
                  variant: StatusChipVariant.warning,
                  events: data.separacoes,
                ),
                const SizedBox(height: AppSpacing.sm),
                _Section(
                  title: 'Ultrassons',
                  icon: Icons.medical_services,
                  variant: StatusChipVariant.info,
                  events: data.ultrassons,
                ),
                const SizedBox(height: AppSpacing.sm),
                _Section(
                  title: 'Partos previstos',
                  icon: Icons.child_care,
                  variant: StatusChipVariant.success,
                  events: data.partos,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final StatusChipVariant variant;
  final List<BreedingEvent> events;

  const _Section({
    required this.title,
    required this.icon,
    required this.variant,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.soft,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(label: title, variant: variant, icon: icon),
              const Spacer(),
              StatusChip(
                label: '${events.length}',
                variant: StatusChipVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (events.isEmpty)
            Text(
              'Sem eventos neste período.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          else ...[
            ...events.take(5).map((e) => _EventRow(evt: e)),
            if (events.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  '+ ${events.length - 5} evento(s) adicional(is)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final BreedingEvent evt;

  const _EventRow({required this.evt});

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = evt.overdue ? AppColors.error : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 6, color: color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '${evt.label}: ${evt.femaleCode} — ${evt.femaleName}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _fmt(evt.date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
