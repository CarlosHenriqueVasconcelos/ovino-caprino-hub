// lib/widgets/repro_alerts_card.dart
// lib/widgets/repro_alerts_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/breeding_service.dart';

class ReproAlertsCard extends StatelessWidget {
  final int daysAhead;
  const ReproAlertsCard({super.key, this.daysAhead = 30});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<ReproBoardData>(
          future:
              context.read<BreedingService>().getBoard(daysAhead: daysAhead),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
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
            if (snap.hasError) {
              return _Header(
                title: 'Reprodução — Alertas',
                subtitle: 'Erro: ${snap.error}',
                icon: Icons.pets,
                color: theme.colorScheme.error,
              );
            }

            final data = snap.data!;
            final none = data.separacoes.isEmpty &&
                data.ultrassons.isEmpty &&
                data.partos.isEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  title: 'Reprodução — Alertas',
                  subtitle: 'Próximos $daysAhead dias',
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
              color: color.withOpacity(.15),
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
    final color =
        evt.overdue ? theme.colorScheme.error : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${evt.label}: ${evt.femaleCode} — ${evt.femaleName}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _fmt(evt.date),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
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
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (trailing != null) trailing!,
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
        border: Border.all(color: color.withOpacity(.35)),
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
