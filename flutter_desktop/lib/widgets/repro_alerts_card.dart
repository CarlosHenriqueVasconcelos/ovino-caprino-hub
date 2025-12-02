// lib/widgets/repro_alerts_card.dart
// lib/widgets/repro_alerts_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/breeding_service.dart';

class ReproAlertsCard extends StatefulWidget {
  final int daysAhead;
  const ReproAlertsCard({super.key, this.daysAhead = 30});

  @override
  State<ReproAlertsCard> createState() => _ReproAlertsCardState();
}

class _ReproAlertsCardState extends State<ReproAlertsCard> {
  @override
  void initState() {
    super.initState();
    _scheduleLoad();
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
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<BreedingService>(
          builder: (context, service, _) {
            final data = service.boardData;
            final error = service.boardError;
            final isLoading = service.isBoardLoading && data == null;

            if (isLoading) {
              return _Header(
                title: 'Reprodução — Alertas',
                subtitle: 'Carregando…',
                icon: Icons.pets,
                color: theme.colorScheme.primary,
                trailing: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            if (error != null && data == null) {
              return _Header(
                title: 'Reprodução — Alertas',
                subtitle: 'Erro: $error',
                icon: Icons.pets,
                color: theme.colorScheme.error,
              );
            }

            if (data == null) {
              return _Header(
                title: 'Reprodução — Alertas',
                subtitle: 'Sem dados disponíveis',
                icon: Icons.pets,
                color: theme.colorScheme.primary,
              );
            }

            final none = data.separacoes.isEmpty &&
                data.ultrassons.isEmpty &&
                data.partos.isEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  title: 'Reprodução — Alertas',
                  subtitle: 'Próximos ${widget.daysAhead} dias',
                  icon: Icons.pets,
                  color: theme.colorScheme.primary,
                  trailing: data.overdueTotal > 0
                      ? _Badge(
                          text: '${data.overdueTotal} atrasado(s)',
                          color: theme.colorScheme.error)
                      : null,
                ),
                const SizedBox(height: 12),
                if (none)
                  const _Empty(text: 'Nenhum alerta de reprodução no período.')
                else ...[
                  _Section(
                    title: 'Separações',
                    icon: Icons.transit_enterexit,
                    color: Colors.orange,
                    events: data.separacoes,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Ultrassons',
                    icon: Icons.medical_services,
                    color: Colors.blue,
                    events: data.ultrassons,
                  ),
                  const SizedBox(height: 12),
                  _Section(
                    title: 'Partos previstos',
                    icon: Icons.baby_changing_station,
                    color: Colors.purple,
                    events: data.partos,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<BreedingEvent> events;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (events.isEmpty) {
      return _SubHeader(
        icon: icon,
        color: color,
        title: title,
        trailing: const Text('—'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubHeader(
          icon: icon,
          color: color,
          title: title,
          trailing: _Badge(
              text: '${events.length}',
              color: color.withValues(alpha: .15),
              textColor: color),
        ),
        const SizedBox(height: 6),
        ...events.take(5).map((e) => _EventRow(evt: e)),
        if (events.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${events.length - 5} mais…',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final BreedingEvent evt;
  const _EventRow({required this.evt});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final color =
        evt.overdue ? theme.colorScheme.error : theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: isMobile ? 6 : 8, color: color),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Text(
              '${evt.label}: ${evt.femaleCode} — ${evt.femaleName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isMobile ? 12 : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Text(
            _fmt(evt.date),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 10 : null,
              color: evt.overdue
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Widget? trailing;

  const _Header({
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: isMobile ? 20 : 24),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 14 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: isMobile ? 11 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? trailing;

  const _SubHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Row(
      children: [
        Icon(icon, color: color, size: isMobile ? 16 : 18),
        SizedBox(width: isMobile ? 6 : 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              fontSize: isMobile ? 12 : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing!,
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;

  const _Badge({required this.text, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = textColor ?? theme.colorScheme.onPrimaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Text(text,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(text,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}
