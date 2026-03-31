import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../services/animal_history_service.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/animal_record_display.dart';

class AnimalHistoryDialog extends StatefulWidget {
  final Animal animal;
  const AnimalHistoryDialog({super.key, required this.animal});

  @override
  State<AnimalHistoryDialog> createState() => _AnimalHistoryDialogState();
}

class _AnimalHistoryDialogState extends State<AnimalHistoryDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  List<Map<String, Object?>> _vaccinations = [];
  List<Map<String, Object?>> _medications = [];
  List<Map<String, Object?>> _notes = [];
  List<Map<String, Object?>> _weights = [];
  List<Map<String, Object?>> _offspring = [];
  Animal? _mother;
  Animal? _father;

  String _fmtDate(dynamic iso) {
    if (iso == null) return '-';
    try {
      final s = iso.toString();
      final d = DateTime.tryParse(s) ?? DateTime.tryParse('${s}T00:00:00');
      if (d == null) return s;
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return iso.toString();
    }
  }

  Future<void> _load() async {
    try {
      final historyService = context.read<AnimalHistoryService>();
      final result = await historyService.loadHistory(widget.animal);

      if (!mounted) return;
      setState(() {
        _vaccinations = result.vaccinations;
        _medications = result.medications;
        _notes = result.notes;
        _weights = result.weights;
        _offspring = result.offspring;
        _mother = result.mother;
        _father = result.father;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar histórico do animal: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  StatusChipVariant _statusVariant(String status) {
    final s = status.toLowerCase();
    if (s == 'saudável') return StatusChipVariant.success;
    if (s == 'em tratamento' || s == 'ferido') return StatusChipVariant.warning;
    if (s == 'vendido') return StatusChipVariant.info;
    if (s == 'óbito') return StatusChipVariant.danger;
    return StatusChipVariant.neutral;
  }

  Widget _infoText(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xxs),
        ],
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _historyItem({
    required BuildContext context,
    IconData? icon,
    Color? accent,
    required List<Widget> lines,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (accent ?? AppColors.borderNeutral).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: (accent ?? AppColors.primary).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: accent ?? AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dadosCard(BuildContext context) {
    final a = widget.animal;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppCard(
          variant: AppCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: a.name,
                subtitle: 'Código ${a.code} • ${a.species} • ${a.breed}',
                action: Text(
                  a.speciesIcon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusChip(
                    label: a.status,
                    variant: _statusVariant(a.status),
                    icon: Icons.flag_outlined,
                  ),
                  StatusChip(
                    label: 'Rep.: ${a.reproductiveStatus}',
                    variant: a.pregnant
                        ? StatusChipVariant.warning
                        : StatusChipVariant.info,
                    icon: Icons.favorite_outline,
                  ),
                  StatusChip(
                    label: a.gender,
                    variant: StatusChipVariant.neutral,
                    icon: a.gender.toLowerCase().contains('f')
                        ? Icons.female
                        : Icons.male,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  _infoText(context, label: 'Peso', value: '${a.weight} kg', icon: Icons.monitor_weight_outlined),
                  _infoText(context, label: 'Nascimento', value: _fmtDate(a.birthDate), icon: Icons.cake_outlined),
                  if (a.location.isNotEmpty)
                    _infoText(context, label: 'Local', value: a.location, icon: Icons.location_on_outlined),
                  if (a.lastVaccination != null)
                    _infoText(
                      context,
                      label: 'Última vacina',
                      value: DateFormat('dd/MM/yyyy').format(a.lastVaccination!),
                      icon: Icons.vaccines_outlined,
                    ),
                  if (a.expectedDelivery != null)
                    _infoText(
                      context,
                      label: 'Parto previsto',
                      value: DateFormat('dd/MM/yyyy').format(a.expectedDelivery!),
                      icon: Icons.event_outlined,
                    ),
                  if ((a.healthIssue ?? '').isNotEmpty)
                    _infoText(
                      context,
                      label: 'Saúde',
                      value: a.healthIssue!,
                      icon: Icons.warning_amber_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
        if ((a.registrationNote ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            variant: AppCardVariant.soft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anotação Cadastral',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(a.registrationNote!.trim()),
              ],
            ),
          ),
        ],
        if (_mother != null || _father != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            variant: AppCardVariant.outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parentesco',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_mother != null)
                  _historyItem(
                    context: context,
                    icon: Icons.female,
                    accent: const Color(0xFFD27CB3),
                    lines: [
                      Text(
                        'Mãe: ${_mother!.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text([
                        'Código: ${_mother!.code}',
                        if (_mother!.nameColor.isNotEmpty) 'Cor: ${_mother!.nameColor}',
                        if ((_mother!.lote ?? '').isNotEmpty) 'Lote: ${_mother!.lote}',
                      ].join(' • ')),
                    ],
                  ),
                if (_father != null)
                  _historyItem(
                    context: context,
                    icon: Icons.male,
                    accent: const Color(0xFF4B73C7),
                    lines: [
                      Text(
                        'Pai: ${_father!.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text([
                        'Código: ${_father!.code}',
                        if (_father!.nameColor.isNotEmpty) 'Cor: ${_father!.nameColor}',
                        if ((_father!.lote ?? '').isNotEmpty) 'Lote: ${_father!.lote}',
                      ].join(' • ')),
                    ],
                  ),
              ],
            ),
          ),
        ],
        if (_offspring.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            variant: AppCardVariant.outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filhotes (${_offspring.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._offspring.map((child) {
                  final status = child['status']?.toString() ?? 'ativo';
                  Color statusColor = AppColors.primary;
                  if (status == 'vendido') statusColor = const Color(0xFF4B73C7);
                  if (status == 'falecido') statusColor = AppColors.error;

                  final color = child['name_color']?.toString();
                  final lote = child['lote']?.toString();
                  final label = AnimalRecordDisplay.labelFromRecord({
                    'animal_name': child['name'] ?? '',
                    'animal_code': child['code'] ?? '',
                    'animal_color': color ?? '',
                  });
                  final accent = AnimalRecordDisplay.colorFromDescriptor(color);

                  return _historyItem(
                    context: context,
                    icon: Icons.child_care_outlined,
                    accent: statusColor,
                    lines: [
                      Text(
                        label,
                        style: accent != null
                            ? TextStyle(color: accent, fontWeight: FontWeight.w700)
                            : theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${child['category']} • Status: $status'
                        '${color != null ? ' • Cor: $color' : ''}'
                        '${lote != null ? ' • Lote: $lote' : ''}',
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
        if (_weights.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            variant: AppCardVariant.outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesagens',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._weights.map(
                  (w) => _historyItem(
                    context: context,
                    icon: Icons.monitor_weight_outlined,
                    accent: AppColors.primarySupport,
                    lines: [
                      Text(
                        '${(w['weight'] ?? '').toString()} kg',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text('Data: ${_fmtDate(w['date'])}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _listCard({
    required BuildContext context,
    required String title,
    required List<Map<String, Object?>> items,
    required List<Widget> Function(Map<String, Object?> row) lines,
    IconData? icon,
    Widget? empty,
  }) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return empty ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppCard(
                variant: AppCardVariant.soft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon ?? Icons.inbox_outlined,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sem registros',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppCard(
          variant: AppCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: title,
                subtitle: '${items.length} registro(s)',
                action: icon != null ? Icon(icon, color: AppColors.primary) : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              ...items.map(
                (r) => _historyItem(
                  context: context,
                  icon: icon,
                  accent: AppColors.primary,
                  lines: lines(r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final dialogWidth = (size.width * 0.95).clamp(320.0, 760.0).toDouble();
    final dialogHeight = (size.height * 0.9).clamp(320.0, 560.0).toDouble();
    final animal = widget.animal;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      animal.speciesIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico • ${animal.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Código ${animal.code} • ${animal.breed}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Dados'),
                  Tab(text: 'Vacinas'),
                  Tab(text: 'Medicações'),
                  Tab(text: 'Anotações'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabs,
                      children: [
                        _dadosCard(context),
                        _listCard(
                          context: context,
                          title: 'Vacinas',
                          icon: Icons.vaccines_outlined,
                          items: _vaccinations,
                          lines: (r) => [
                            Text(
                              '${r['vaccine_name'] ?? ''} • ${r['vaccine_type'] ?? ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Agendada: ${_fmtDate(r['scheduled_date'])} • Aplicada: ${_fmtDate(r['applied_date'])}',
                            ),
                            if ((r['veterinarian'] ?? '').toString().isNotEmpty)
                              Text('Veterinário: ${r['veterinarian']}'),
                            if ((r['notes'] ?? '').toString().isNotEmpty)
                              Text('Obs: ${r['notes']}'),
                          ],
                        ),
                        _listCard(
                          context: context,
                          title: 'Medicações',
                          icon: Icons.medication_liquid_outlined,
                          items: _medications,
                          lines: (r) => [
                            Text(
                              '${r['medication_name'] ?? ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Data: ${_fmtDate(r['date'])} • Aplicada: ${_fmtDate(r['applied_date'])}',
                            ),
                            if ((r['dosage'] ?? '').toString().isNotEmpty)
                              Text('Dosagem: ${r['dosage']}'),
                            if ((r['veterinarian'] ?? '').toString().isNotEmpty)
                              Text('Veterinário: ${r['veterinarian']}'),
                            if ((r['notes'] ?? '').toString().isNotEmpty)
                              Text('Obs: ${r['notes']}'),
                          ],
                        ),
                        _listCard(
                          context: context,
                          title: 'Anotações',
                          icon: Icons.note_alt_outlined,
                          items: _notes,
                          lines: (r) => [
                            Text(
                              '${r['title'] ?? ''} • ${_fmtDate(r['date'])}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if ((r['content'] ?? '').toString().isNotEmpty)
                              Text('${r['content']}'),
                            if ((r['category'] ?? '').toString().isNotEmpty ||
                                (r['priority'] ?? '').toString().isNotEmpty)
                              Text(
                                'Categoria: ${r['category'] ?? '-'} • Prioridade: ${r['priority'] ?? '-'}',
                              ),
                          ],
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
