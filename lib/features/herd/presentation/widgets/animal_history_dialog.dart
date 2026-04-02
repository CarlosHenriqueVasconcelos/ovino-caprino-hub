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
import '../../../../utils/responsive_utils.dart';

class AnimalHistoryDialog extends StatefulWidget {
  final Animal animal;
  final bool fullscreen;

  const AnimalHistoryDialog({
    super.key,
    required this.animal,
    this.fullscreen = false,
  });

  static Future<void> showAdaptive(
    BuildContext context, {
    required Animal animal,
  }) async {
    final isMobile = MediaQuery.sizeOf(context).width < ResponsiveUtils.mobile;

    if (isMobile) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => AnimalHistoryDialog(
            animal: animal,
            fullscreen: true,
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => AnimalHistoryDialog(animal: animal),
    );
  }

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
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar histórico do animal: $error')),
      );
    }
  }

  String _fmtDate(dynamic iso) {
    if (iso == null) return '-';
    try {
      final source = iso.toString();
      final parsed =
          DateTime.tryParse(source) ?? DateTime.tryParse('${source}T00:00:00');
      if (parsed == null) return source;
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return iso.toString();
    }
  }

  String _fmtNumber(dynamic value) {
    if (value == null) return '-';
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    if (parsed == parsed.roundToDouble()) return parsed.toInt().toString();
    return parsed.toStringAsFixed(1);
  }

  StatusChipVariant _statusVariant(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'saudável') return StatusChipVariant.success;
    if (normalized == 'em tratamento' || normalized == 'ferido') {
      return StatusChipVariant.warning;
    }
    if (normalized == 'vendido') return StatusChipVariant.info;
    if (normalized == 'óbito') return StatusChipVariant.danger;
    return StatusChipVariant.neutral;
  }

  Widget _chipMetric({
    required BuildContext context,
    required String label,
    required String value,
    IconData? icon,
  }) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 290),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderNeutral.withValues(alpha: 0.9),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Flexible(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: textStyle,
                  children: [
                    TextSpan(
                      text: '$label: ',
                      style: textStyle?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: value),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsSection({
    required BuildContext context,
    required String title,
    required Widget child,
    AppCardVariant variant = AppCardVariant.outlined,
    String? subtitle,
  }) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: variant,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }

  Widget _detailsTab(BuildContext context) {
    final animal = widget.animal;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _detailsSection(
          context: context,
          title: 'Resumo',
          variant: AppCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: animal.name,
                subtitle: 'Código ${animal.code} • ${animal.species} • ${animal.breed}',
                action: Text(
                  animal.speciesIcon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusChip(
                    label: animal.status,
                    variant: _statusVariant(animal.status),
                    icon: Icons.flag_outlined,
                  ),
                  StatusChip(
                    label: animal.gender,
                    variant: StatusChipVariant.neutral,
                    icon: animal.gender.toLowerCase().contains('f')
                        ? Icons.female
                        : Icons.male,
                  ),
                  StatusChip(
                    label: 'Rep.: ${animal.reproductiveStatus}',
                    variant: animal.pregnant
                        ? StatusChipVariant.warning
                        : StatusChipVariant.info,
                    icon: Icons.favorite_outline,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _chipMetric(
                    context: context,
                    label: 'Peso',
                    value: '${_fmtNumber(animal.weight)} kg',
                    icon: Icons.monitor_weight_outlined,
                  ),
                  _chipMetric(
                    context: context,
                    label: 'Idade',
                    value: animal.ageText,
                    icon: Icons.schedule,
                  ),
                  _chipMetric(
                    context: context,
                    label: 'Local',
                    value: animal.location.isEmpty ? '-' : animal.location,
                    icon: Icons.location_on_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
        _detailsSection(
          context: context,
          title: 'Identificação',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _chipMetric(
                context: context,
                label: 'Código',
                value: animal.code,
                icon: Icons.badge_outlined,
              ),
              _chipMetric(
                context: context,
                label: 'Espécie',
                value: animal.species,
                icon: Icons.pets_outlined,
              ),
              _chipMetric(
                context: context,
                label: 'Raça',
                value: animal.breed,
                icon: Icons.category_outlined,
              ),
              if (animal.category.trim().isNotEmpty)
                _chipMetric(
                  context: context,
                  label: 'Categoria',
                  value: animal.category,
                  icon: Icons.label_outline,
                ),
              _chipMetric(
                context: context,
                label: 'Nascimento',
                value: _fmtDate(animal.birthDate),
                icon: Icons.cake_outlined,
              ),
              if ((animal.lote ?? '').trim().isNotEmpty)
                _chipMetric(
                  context: context,
                  label: 'Lote',
                  value: animal.lote!,
                  icon: Icons.sell_outlined,
                ),
              if (animal.year != null)
                _chipMetric(
                  context: context,
                  label: 'Ano',
                  value: '${animal.year}',
                  icon: Icons.calendar_today_outlined,
                ),
            ],
          ),
        ),
        _detailsSection(
          context: context,
          title: 'Saúde e Reprodução',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _chipMetric(
                    context: context,
                    label: 'Status sanitário',
                    value: animal.status,
                    icon: Icons.health_and_safety_outlined,
                  ),
                  _chipMetric(
                    context: context,
                    label: 'Status reprodutivo',
                    value: animal.reproductiveStatus,
                    icon: Icons.favorite_border,
                  ),
                  _chipMetric(
                    context: context,
                    label: 'Gestação',
                    value: animal.pregnant ? 'Sim' : 'Não',
                    icon: Icons.pregnant_woman_outlined,
                  ),
                  if (animal.expectedDelivery != null)
                    _chipMetric(
                      context: context,
                      label: 'Parto previsto',
                      value: _fmtDate(animal.expectedDelivery),
                      icon: Icons.event_outlined,
                    ),
                  if (animal.lastVaccination != null)
                    _chipMetric(
                      context: context,
                      label: 'Última vacinação',
                      value: _fmtDate(animal.lastVaccination),
                      icon: Icons.vaccines_outlined,
                    ),
                ],
              ),
              if ((animal.healthIssue ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Observação de saúde',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(animal.healthIssue!.trim()),
              ],
            ],
          ),
        ),
        if (_mother != null || _father != null)
          _detailsSection(
            context: context,
            title: 'Parentesco',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_mother != null)
                  _historyItem(
                    context: context,
                    icon: Icons.female,
                    accent: const Color(0xFFD27CB3),
                    lines: [
                      Text(
                        'Mãe: ${_mother!.name}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          'Código: ${_mother!.code}',
                          if (_mother!.nameColor.isNotEmpty)
                            'Cor: ${_mother!.nameColor}',
                          if ((_mother!.lote ?? '').isNotEmpty)
                            'Lote: ${_mother!.lote}',
                        ].join(' • '),
                      ),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          'Código: ${_father!.code}',
                          if (_father!.nameColor.isNotEmpty)
                            'Cor: ${_father!.nameColor}',
                          if ((_father!.lote ?? '').isNotEmpty)
                            'Lote: ${_father!.lote}',
                        ].join(' • '),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        if (_offspring.isNotEmpty)
          _detailsSection(
            context: context,
            title: 'Filhotes',
            subtitle: '${_offspring.length} registro(s)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _offspring.map((child) {
                final status = child['status']?.toString() ?? 'ativo';
                var accent = AppColors.primary;
                if (status == 'vendido') accent = const Color(0xFF4B73C7);
                if (status == 'falecido') accent = AppColors.error;

                final color = child['name_color']?.toString();
                final lote = child['lote']?.toString();
                final label = AnimalRecordDisplay.labelFromRecord({
                  'animal_name': child['name'] ?? '',
                  'animal_code': child['code'] ?? '',
                  'animal_color': color ?? '',
                });
                final recordColor = AnimalRecordDisplay.colorFromDescriptor(color);

                return _historyItem(
                  context: context,
                  icon: Icons.child_care_outlined,
                  accent: accent,
                  lines: [
                    Text(
                      label,
                      style: recordColor != null
                          ? TextStyle(color: recordColor, fontWeight: FontWeight.w700)
                          : Theme.of(context)
                              .textTheme
                              .bodyMedium
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
              }).toList(growable: false),
            ),
          ),
        if (_weights.isNotEmpty)
          _detailsSection(
            context: context,
            title: 'Pesagens',
            subtitle: '${_weights.length} registro(s)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _weights.map(
                (weight) => _historyItem(
                  context: context,
                  icon: Icons.monitor_weight_outlined,
                  accent: AppColors.primarySupport,
                  lines: [
                    Text(
                      '${_fmtNumber(weight['weight'])} kg',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text('Data: ${_fmtDate(weight['date'])}'),
                    if ((weight['milestone'] ?? '').toString().isNotEmpty)
                      Text('Marco: ${weight['milestone']}'),
                  ],
                ),
              ).toList(growable: false),
            ),
          ),
        if ((animal.registrationNote ?? '').trim().isNotEmpty)
          _detailsSection(
            context: context,
            title: 'Observações Cadastrais',
            variant: AppCardVariant.soft,
            child: Text(animal.registrationNote!.trim()),
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
                (row) => _historyItem(
                  context: context,
                  icon: icon,
                  accent: AppColors.primary,
                  lines: lines(row),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrame(BuildContext context) {
    final theme = Theme.of(context);
    final animal = widget.animal;

    return Column(
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
              Tab(text: 'Detalhes'),
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
                    _detailsTab(context),
                    _listCard(
                      context: context,
                      title: 'Vacinas',
                      icon: Icons.vaccines_outlined,
                      items: _vaccinations,
                      lines: (row) => [
                        Text(
                          '${row['vaccine_name'] ?? ''} • ${row['vaccine_type'] ?? ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Agendada: ${_fmtDate(row['scheduled_date'])} • Aplicada: ${_fmtDate(row['applied_date'])}',
                        ),
                        if ((row['veterinarian'] ?? '').toString().isNotEmpty)
                          Text('Veterinário: ${row['veterinarian']}'),
                        if ((row['notes'] ?? '').toString().isNotEmpty)
                          Text('Obs: ${row['notes']}'),
                      ],
                    ),
                    _listCard(
                      context: context,
                      title: 'Medicações',
                      icon: Icons.medication_liquid_outlined,
                      items: _medications,
                      lines: (row) => [
                        Text(
                          '${row['medication_name'] ?? ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Data: ${_fmtDate(row['date'])} • Aplicada: ${_fmtDate(row['applied_date'])}',
                        ),
                        if ((row['dosage'] ?? '').toString().isNotEmpty)
                          Text('Dosagem: ${row['dosage']}'),
                        if ((row['veterinarian'] ?? '').toString().isNotEmpty)
                          Text('Veterinário: ${row['veterinarian']}'),
                        if ((row['notes'] ?? '').toString().isNotEmpty)
                          Text('Obs: ${row['notes']}'),
                      ],
                    ),
                    _listCard(
                      context: context,
                      title: 'Anotações',
                      icon: Icons.note_alt_outlined,
                      items: _notes,
                      lines: (row) => [
                        Text(
                          '${row['title'] ?? ''} • ${_fmtDate(row['date'])}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if ((row['content'] ?? '').toString().isNotEmpty)
                          Text('${row['content']}'),
                        if ((row['category'] ?? '').toString().isNotEmpty ||
                            (row['priority'] ?? '').toString().isNotEmpty)
                          Text(
                            'Categoria: ${row['category'] ?? '-'} • Prioridade: ${row['priority'] ?? '-'}',
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullscreen) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(child: _buildFrame(context)),
      );
    }

    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width * 0.95).clamp(320.0, 760.0).toDouble();
    final dialogHeight = (size.height * 0.9).clamp(360.0, 660.0).toDouble();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: _buildFrame(context),
      ),
    );
  }
}
