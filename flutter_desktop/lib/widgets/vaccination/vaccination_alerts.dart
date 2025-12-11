// lib/widgets/vaccination/vaccination_alerts.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/vaccination_service.dart';
import '../../services/events/event_bus.dart';
import '../../services/events/app_events.dart';
import '../../utils/animal_record_display.dart';

class VaccinationAlerts extends StatefulWidget {
  final VoidCallback onGoToVaccinations;
  const VaccinationAlerts({super.key, required this.onGoToVaccinations});

  @override
  State<VaccinationAlerts> createState() => _VaccinationAlertsState();
}

class _VaccinationAlertsState extends State<VaccinationAlerts> {
  bool _loading = true;
  String? _error;

  // Dados
  List<Map<String, dynamic>> _vaccines = [];
  List<Map<String, dynamic>> _meds = [];

  // Paginação
  static const int _pageSize = 4;
  int _vacPage = 0;
  int _medPage = 0;

  // EventBus subscriptions
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    _loadAlerts();
  }

  void _setupEventListeners() {
    // Recarrega quando vacinas são criadas/atualizadas/deletadas
    _subscriptions.add(EventBus().listen<VaccinationCreatedEvent>((_) => _loadAlerts()));
    _subscriptions.add(EventBus().listen<VaccinationUpdatedEvent>((_) => _loadAlerts()));
    _subscriptions.add(EventBus().listen<VaccinationDeletedEvent>((_) => _loadAlerts()));
    
    // Recarrega quando medicações são criadas/atualizadas/deletadas
    _subscriptions.add(EventBus().listen<MedicationCreatedEvent>((_) => _loadAlerts()));
    _subscriptions.add(EventBus().listen<MedicationUpdatedEvent>((_) => _loadAlerts()));
    _subscriptions.add(EventBus().listen<MedicationDeletedEvent>((_) => _loadAlerts()));
    
    // Refresh geral de alertas
    _subscriptions.add(EventBus().listen<AlertsRefreshRequestedEvent>((_) => _loadAlerts()));
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final vaccinationService = context.read<VaccinationService>();
      final data = await vaccinationService.getVaccinationAlerts();

      if (!mounted) return;
      setState(() {
        _vaccines = data.vaccines;
        _meds = data.meds;

        // Resetar páginas caso listas tenham mudado
        _vacPage = 0;
        _medPage = 0;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 12),
              Text('Carregando alertas...', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(Icons.error, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Erro ao carregar alertas: $_error',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
              TextButton.icon(
                onPressed: _loadAlerts,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Sempre mostrar o quadro, mesmo sem alertas
    final total = _vaccines.length + _meds.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Builder(
              builder: (context) {
                final isMobile = MediaQuery.of(context).size.width < 600;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: theme.colorScheme.primary,
                          size: isMobile ? 20 : 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isMobile ? 'Alertas Vacinação/Medicação' : 'Alertas de Vacinação e Medicação',
                            style: (isMobile ? theme.textTheme.titleMedium : theme.textTheme.headlineSmall)?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _counterChip(
                          theme,
                          label: 'Total',
                          value: total,
                          color: theme.colorScheme.primary,
                        ),
                        _counterChip(
                          theme,
                          label: 'Vacinas',
                          value: _vaccines.length,
                          color: Colors.orange,
                        ),
                        _counterChip(
                          theme,
                          label: 'Medicações',
                          value: _meds.length,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Vacinas (paginado 4 por vez)
            if (_vaccines.isNotEmpty) ...[
              _sectionHeaderWithPager(
                theme: theme,
                title: 'Vacinas Agendadas',
                total: _vaccines.length,
                page: _vacPage,
                onPrev: _vacPage > 0 ? () => setState(() => _vacPage--) : null,
                onNext: (_vacPage + 1) * _pageSize < _vaccines.length
                    ? () => setState(() => _vacPage++)
                    : null,
              ),
              const SizedBox(height: 8),
              ..._pagedSlice(_vaccines, _vacPage).map(
                (row) => _vaccineTile(context, theme, row),
              ),
              const SizedBox(height: 16),
            ],

            // Medicações (paginado 4 por vez)
            if (_meds.isNotEmpty) ...[
              _sectionHeaderWithPager(
                theme: theme,
                title: 'Medicações (próximas)',
                total: _meds.length,
                page: _medPage,
                onPrev: _medPage > 0 ? () => setState(() => _medPage--) : null,
                onNext: (_medPage + 1) * _pageSize < _meds.length
                    ? () => setState(() => _medPage++)
                    : null,
              ),
              const SizedBox(height: 8),
              ..._pagedSlice(_meds, _medPage).map(
                (row) => _medTile(context, theme, row),
              ),
            ],

            // Mensagem quando não há alertas
            if (_vaccines.isEmpty && _meds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum alerta no momento',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Todas as vacinações e medicações estão em dia',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- Paginação helpers ----------

  List<Map<String, dynamic>> _pagedSlice(
    List<Map<String, dynamic>> list,
    int page,
  ) {
    final start = page * _pageSize;
    if (start >= list.length) return const [];
    final end = ((page + 1) * _pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  Widget _sectionHeaderWithPager({
    required ThemeData theme,
    required String title,
    required int total,
    required int page,
    VoidCallback? onPrev,
    VoidCallback? onNext,
  }) {
    final start = total == 0 ? 0 : (page * _pageSize) + 1;
    final end = ((page + 1) * _pageSize).clamp(0, total);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;
        
        if (isMobile) {
          // Layout compacto para mobile
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$start–$end/$total',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Anterior',
                    onPressed: onPrev,
                    icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    tooltip: 'Próximo',
                    onPressed: onNext,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$start–$end de $total',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Anterior',
              onPressed: onPrev,
              icon: const Icon(Icons.keyboard_arrow_up),
            ),
            IconButton(
              tooltip: 'Próximo',
              onPressed: onNext,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        );
      },
    );
  }

  // ---------- Chips / UI pequenos ----------

  Widget _counterChip(
    ThemeData theme, {
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Renders das linhas ----------

  Widget _vaccineTile(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> row,
  ) {
    final vaccineName = (row['vaccine_name'] ?? '').toString();
    final isMobile = MediaQuery.of(context).size.width < 600;

    final scheduledStr = (row['scheduled_date'] ?? '').toString();
    final scheduled = _parseDate(scheduledStr);
    final days = _daysFromNow(scheduled);

    final overdue = scheduled != null && days < 0;
    final color = overdue ? theme.colorScheme.error : Colors.orange;
    final labelDate = scheduled != null ? _formatDate(scheduled) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vaccines, color: color, size: isMobile ? 20 : 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimalLabel(row, theme),
                    const SizedBox(height: 4),
                    Text(
                      'Vacina: $vaccineName',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: isMobile ? 13 : null,
                      ),
                    ),
                    if (labelDate != null)
                      Text(
                        overdue
                            ? 'ATRASADA há ${days.abs()} dia(s)'
                            : 'Agendada para $labelDate (em $days dia(s))',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 11 : null,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onGoToVaccinations,
              icon: const Icon(Icons.open_in_new, size: 14),
              label: Text(
                'Ver vacinas',
                style: TextStyle(fontSize: isMobile ? 12 : null),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medTile(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> row,
  ) {
    final medName = (row['medication_name'] ?? '').toString();
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Usa a primeira data disponível: date (agendada agora) ou next_date (próxima dose)
    final when = _parseDate(row['date']) ?? _parseDate(row['next_date']);
    final days = _daysFromNow(when);

    final status = (row['status'] ?? 'Agendado').toString();

    final overdue = when != null && days < 0;
    final color = overdue ? theme.colorScheme.error : Colors.teal;
    final labelDate = when != null ? _formatDate(when) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: color, size: isMobile ? 20 : 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimalLabel(row, theme),
                    const SizedBox(height: 4),
                    Text(
                      'Medicação: $medName',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: isMobile ? 13 : null,
                      ),
                    ),
                    if (labelDate != null)
                      Text(
                        overdue
                            ? 'ATRASADA há ${days.abs()} dia(s)'
                            : 'Agendada para $labelDate (em $days dia(s))',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 11 : null,
                        ),
                      ),
                    if (status != 'Agendado')
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Status: $status',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: isMobile ? 10 : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onGoToVaccinations,
              icon: const Icon(Icons.open_in_new, size: 14),
              label: Text(
                'Ver medicações',
                style: TextStyle(fontSize: isMobile ? 12 : null),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 6 : 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalLabel(Map<String, dynamic> row, ThemeData theme) {
    final label = AnimalRecordDisplay.labelFromRecord(row);
    final color = AnimalRecordDisplay.colorFromRecord(row);
    final translated = AnimalRecordDisplay.translateColor(row['animal_color']);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final parts = label.split(' - ');
    String text;
    if (parts.length >= 2) {
      text = '$translated - ${parts.sublist(1).join(' - ')}';
    } else {
      text = label;
    }
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: color ?? theme.colorScheme.onSurface,
        fontSize: isMobile ? 14 : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ---------- Ações ----------

  // ---------- Helpers de data ----------

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      if (v is DateTime) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }

  int _daysFromNow(DateTime? d) {
    if (d == null) return 0;
    final now = DateTime.now();
    return d.difference(DateTime(now.year, now.month, now.day)).inDays;
    // negativo = atrasado; positivo = faltam dias.
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
