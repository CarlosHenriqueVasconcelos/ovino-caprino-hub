import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/animal.dart';
import '../../../models/pharmacy_stock.dart';
import '../../../shared/widgets/animal/animal_form.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/animal_display_utils.dart';
import '../../../utils/responsive_utils.dart';
import '../../medication/presentation/widgets/vaccination_form.dart';
import '../../system/presentation/history_screen.dart';
import '../data/dashboard_repository.dart';
import 'dashboard_visual_style.dart';

class DashboardQuickActions extends StatelessWidget {
  final void Function(int) onGoToTab;
  const DashboardQuickActions({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final dashboardRepository = context.read<DashboardRepository>();

    void showAnimalForm({Animal? animal}) {
      showDialog(
        context: context,
        builder: (context) => AnimalFormDialog(animal: animal),
      );
    }

    void showVaccinationForm({Animal? animal}) {
      showDialog(
        context: context,
        builder: (context) => VaccinationFormDialog(animalId: animal?.id),
      );
    }

    void showMedicationDialog() {
      showDialog(
        context: context,
        builder: (context) => _MedicationFormDialog(
          onSaved: () => dashboardRepository.refreshDashboardData(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
        final layoutMetrics = _QuickActionsLayoutMetrics.fromWidth(availableWidth);
        final tileWidth = layoutMetrics.tileWidthFor(availableWidth);
        final panelPadding = DashboardVisualStyle.panelPadding(availableWidth);
        final sectionGap = DashboardVisualStyle.sectionGap(availableWidth);
        final cardStyle = _ActionCardStyle.fromTileWidth(
          tileWidth: tileWidth,
          singleColumn: layoutMetrics.columns == 1,
        );

        final actions = [
          _QuickActionData(
            title: 'Novo Animal',
            subtitle: 'Cadastro completo',
            icon: Icons.add,
            color: AppColors.primary,
            onTap: () => showAnimalForm(),
          ),
          _QuickActionData(
            title: 'Agendar Vacinação',
            subtitle: 'Planejar aplicação',
            icon: Icons.vaccines,
            color: const Color(0xFF4B73C7),
            onTap: () => showVaccinationForm(),
          ),
          _QuickActionData(
            title: 'Agendar Medicamento',
            subtitle: 'Controle sanitário',
            icon: Icons.medication,
            color: const Color(0xFF3D9E8D),
            onTap: showMedicationDialog,
          ),
          _QuickActionData(
            title: 'Registrar Pesagem',
            subtitle: 'Atualizar ganho',
            icon: Icons.monitor_weight_outlined,
            color: const Color(0xFF6A8D42),
            onTap: () => onGoToTab(3),
          ),
          _QuickActionData(
            title: 'Lançar Cobertura',
            subtitle: 'Fluxo reprodutivo',
            icon: Icons.favorite_outline,
            color: const Color(0xFFB06496),
            onTap: () => onGoToTab(4),
          ),
          _QuickActionData(
            title: 'Histórico Completo',
            subtitle: 'Auditoria do sistema',
            icon: Icons.history,
            color: AppColors.goldSoft,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const HistoryScreen(),
              ),
            ),
          ),
        ];

        return AppCard(
          variant: AppCardVariant.outlined,
          backgroundColor: DashboardVisualStyle.panelBackground(),
          borderColor: DashboardVisualStyle.panelBorder(),
          padding: panelPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Ações Rápidas',
                subtitle: 'Atalhos para os fluxos mais usados no dia',
              ),
              SizedBox(height: sectionGap),
              Wrap(
                spacing: layoutMetrics.spacing,
                runSpacing: layoutMetrics.spacing,
                children: actions
                    .map(
                      (action) => SizedBox(
                        width: tileWidth,
                        child: _ActionCard(
                          title: action.title,
                          subtitle: action.subtitle,
                          icon: action.icon,
                          color: action.color,
                          onTap: action.onTap,
                          style: cardStyle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.style,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final _ActionCardStyle style;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(style.radius),
        child: Container(
          constraints: BoxConstraints(minHeight: style.minHeight),
          padding: EdgeInsets.all(style.padding),
          decoration: BoxDecoration(
            color: DashboardVisualStyle.innerBackground(alpha: 0.95),
            borderRadius: BorderRadius.circular(style.radius),
            border: Border.all(color: color.withValues(alpha: 0.22)),
            boxShadow: DashboardVisualStyle.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(style.iconPadding),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(style.iconRadius),
                    ),
                    child: Icon(icon, color: color, size: style.iconSize),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: style.trailingIconSize,
                    color: color.withValues(alpha: 0.75),
                  ),
                ],
              ),
              SizedBox(height: style.titleTopGap),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: style.titleFontSize,
                  height: 1.2,
                ),
              ),
              SizedBox(height: style.subtitleTopGap),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: style.subtitleFontSize,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionsLayoutMetrics {
  final int columns;
  final double spacing;

  const _QuickActionsLayoutMetrics({
    required this.columns,
    required this.spacing,
  });

  factory _QuickActionsLayoutMetrics.fromWidth(double width) {
    if (width <= 390) {
      return const _QuickActionsLayoutMetrics(
        columns: 1,
        spacing: 10,
      );
    }
    if (width <= 760) {
      return const _QuickActionsLayoutMetrics(
        columns: 2,
        spacing: 10,
      );
    }
    if (width <= 1100) {
      return const _QuickActionsLayoutMetrics(
        columns: 3,
        spacing: AppSpacing.sm,
      );
    }
    return const _QuickActionsLayoutMetrics(
      columns: 4,
      spacing: AppSpacing.sm,
    );
  }

  double tileWidthFor(double availableWidth) {
    if (columns <= 1) return availableWidth;
    final widthWithoutSpacing = availableWidth - (spacing * (columns - 1));
    return widthWithoutSpacing / columns;
  }
}

class _ActionCardStyle {
  final double minHeight;
  final double padding;
  final double radius;
  final double iconPadding;
  final double iconRadius;
  final double iconSize;
  final double trailingIconSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final double titleTopGap;
  final double subtitleTopGap;

  const _ActionCardStyle({
    required this.minHeight,
    required this.padding,
    required this.radius,
    required this.iconPadding,
    required this.iconRadius,
    required this.iconSize,
    required this.trailingIconSize,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.titleTopGap,
    required this.subtitleTopGap,
  });

  factory _ActionCardStyle.fromTileWidth({
    required double tileWidth,
    required bool singleColumn,
  }) {
    if (singleColumn || tileWidth >= 260) {
      return const _ActionCardStyle(
        minHeight: 136,
        padding: AppSpacing.md,
        radius: DashboardVisualStyle.panelRadius,
        iconPadding: AppSpacing.xs,
        iconRadius: 12,
        iconSize: 18,
        trailingIconSize: 17,
        titleFontSize: 14,
        subtitleFontSize: 12,
        titleTopGap: 10,
        subtitleTopGap: 4,
      );
    }

    if (tileWidth >= 190) {
      return const _ActionCardStyle(
        minHeight: 132,
        padding: AppSpacing.sm,
        radius: DashboardVisualStyle.tileRadius,
        iconPadding: 7,
        iconRadius: 11,
        iconSize: 17,
        trailingIconSize: 16,
        titleFontSize: 13,
        subtitleFontSize: 11.5,
        titleTopGap: 9,
        subtitleTopGap: 3,
      );
    }

    return const _ActionCardStyle(
      minHeight: 128,
      padding: 10,
      radius: DashboardVisualStyle.tileRadius,
      iconPadding: 6,
      iconRadius: 10,
      iconSize: 16,
      trailingIconSize: 15,
      titleFontSize: 12.5,
      subtitleFontSize: 11,
      titleTopGap: 8,
      subtitleTopGap: 3,
    );
  }
}

class _MedicationFormDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const _MedicationFormDialog({required this.onSaved});

  @override
  State<_MedicationFormDialog> createState() => _MedicationFormDialogState();
}

class _MedicationFormDialogState extends State<_MedicationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _scheduledDate = DateTime.now();
  String? _selectedAnimalId;
  PharmacyStock? _selectedMedication;
  List<PharmacyStock> _pharmacyStock = [];
  bool _loadingStock = true;
  List<Animal> _animalOptions = [];
  bool _loadingAnimals = true;
  Timer? _animalDebounce;

  @override
  void dispose() {
    _animalDebounce?.cancel();
    _nameController.dispose();
    _dosageController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPharmacyStock);
    Future.microtask(_loadAnimals);
  }

  Future<void> _loadPharmacyStock() async {
    setState(() => _loadingStock = true);
    try {
      final dashboardRepository = context.read<DashboardRepository>();
      final stock = await dashboardRepository.getPharmacyStock();
      if (!mounted) return;
      final available = stock
          .where((s) =>
              !s.isExpired && (s.totalQuantity > 0 || s.openedQuantity > 0))
          .toList()
        ..sort((a, b) => a.medicationName.compareTo(b.medicationName));
      setState(() {
        _pharmacyStock = available;
        _loadingStock = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStock = false);
    }
  }

  Future<void> _loadAnimals([String query = '']) async {
    final dashboardRepository = context.read<DashboardRepository>();
    try {
      final animals = await dashboardRepository.searchAnimals(
        searchQuery: query,
        limit: 50,
      );
      AnimalDisplayUtils.sortAnimalsList(animals);
      if (!mounted) return;
      setState(() {
        _animalOptions = animals;
        _loadingAnimals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAnimals = false);
    }
  }

  void _scheduleAnimalSearch(String query) {
    _animalDebounce?.cancel();
    _animalDebounce = Timer(const Duration(milliseconds: 250), () {
      _loadAnimals(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Agendar Medicamento'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<Animal>(
                  displayStringForOption: AnimalDisplayUtils.getDisplayText,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    _scheduleAnimalSearch(textEditingValue.text);
                    if (_loadingAnimals) return const Iterable<Animal>.empty();
                    if (textEditingValue.text.isEmpty) {
                      return _animalOptions;
                    }
                    final search = textEditingValue.text.toLowerCase();
                    return _animalOptions.where((animal) {
                      return animal.code.toLowerCase().contains(search) ||
                          animal.name.toLowerCase().contains(search);
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Animal *',
                        hintText: 'Digite o nome ou código',
                        prefixIcon: const Icon(Icons.pets),
                        border: const OutlineInputBorder(),
                        suffixIcon: _selectedAnimalId != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _selectedAnimalId = null);
                                  controller.clear();
                                },
                              )
                            : null,
                      ),
                      validator: (_) => _selectedAnimalId == null
                          ? 'Selecione um animal'
                          : null,
                    );
                  },
                  onSelected: (animal) {
                    setState(() => _selectedAnimalId = animal.id);
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    final optionsWidth = ResponsiveUtils.isMobile(context)
                        ? MediaQuery.of(context).size.width - 48
                        : 468.0;
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        child: SizedBox(
                          width: optionsWidth,
                          height: 250,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (_, index) {
                              final animal = options.elementAt(index);
                              return ListTile(
                                onTap: () => onSelected(animal),
                                title: AnimalDisplayUtils.buildDropdownItem(
                                  animal,
                                  textStyle: theme.textTheme.bodyMedium,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildMedicationSelector(theme),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Medicamento *',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosagem',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: 5 ml, 2 comprimidos',
                  ).copyWith(
                    suffixText: _selectedMedication?.unitOfMeasure,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _scheduledDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data Agendada *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_scheduledDate.day.toString().padLeft(2, '0')}/${_scheduledDate.month.toString().padLeft(2, '0')}/${_scheduledDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _veterinarianController,
                  decoration: const InputDecoration(
                    labelText: 'Veterinário',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Agendar'),
        ),
      ],
    );
  }

  Widget _buildMedicationSelector(ThemeData theme) {
    if (_loadingStock) {
      return const Row(
        children: [
          SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
          SizedBox(width: 12),
          Expanded(child: Text('Carregando estoque da farmácia...')),
        ],
      );
    }

    if (_pharmacyStock.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: const Text(
          'Nenhum medicamento disponível na farmácia. Cadastre itens na aba Farmácia para agendar aplicações.',
        ),
      );
    }

    final available = _pharmacyStock.where(_hasStockAvailable).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<PharmacyStock>(
          displayStringForOption: (stock) => stock.medicationName,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return available;
            }
            final search = textEditingValue.text.toLowerCase();
            return available.where(
              (stock) => stock.medicationName.toLowerCase().contains(search),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Medicamento da Farmácia *',
                hintText: 'Digite para buscar (${available.length} itens)',
                prefixIcon: const Icon(Icons.local_pharmacy),
                border: const OutlineInputBorder(),
                suffixIcon: _selectedMedication != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedMedication = null;
                            _nameController.clear();
                          });
                          controller.clear();
                        },
                      )
                    : null,
              ),
              validator: (_) => _selectedMedication == null
                  ? 'Selecione um medicamento'
                  : null,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final optionsWidth = ResponsiveUtils.isMobile(context)
                ? MediaQuery.of(context).size.width - 48
                : 468.0;
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: SizedBox(
                  width: optionsWidth,
                  height: 250,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (_, index) {
                      final stock = options.elementAt(index);
                      return ListTile(
                        onTap: () => onSelected(stock),
                        title: _buildStockTile(stock, theme),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (stock) {
            setState(() {
              _selectedMedication = stock;
              _nameController.text = stock.medicationName;
            });
          },
        ),
        if (_selectedMedication != null && _selectedMedication!.isLowStock)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildLowStockMessage(_selectedMedication!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStockTile(PharmacyStock stock, ThemeData theme) {
    final unit = stock.unitOfMeasure.toLowerCase();
    final buffer =
        StringBuffer('${stock.medicationName} • ${stock.medicationType}');
    buffer.write(' • ${stock.totalQuantity.toStringAsFixed(1)} $unit');
    if (stock.isExpiringSoon) buffer.write(' • Vencendo');
    if (stock.isExpired) buffer.write(' • Vencido');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(stock.medicationName,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Text(
          '${stock.medicationType} • ${stock.totalQuantity.toStringAsFixed(1)} ${stock.unitOfMeasure}',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedAnimalId == null) {
      return;
    }

    if (_selectedMedication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um medicamento da farmácia'),
        ),
      );
      return;
    }

    final quantityUsed = _extractQuantityUsed();
    if (quantityUsed == null || quantityUsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a dosagem/quantidade a ser aplicada.'),
        ),
      );
      return;
    }

    if (!_hasSufficientStock(quantityUsed)) {
      final available = _availableStockDescription();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estoque insuficiente. Disponível: $available'),
        ),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final scheduledDateStr = _scheduledDate.toIso8601String().split('T')[0];

    final medication = <String, dynamic>{
      'id': const Uuid().v4(),
      'animal_id': _selectedAnimalId!,
      'medication_name': _nameController.text,
      'date': scheduledDateStr,
      'next_date': _scheduledDate
          .add(const Duration(days: 30))
          .toIso8601String()
          .split('T')[0],
      'dosage': _dosageController.text.isEmpty ? null : _dosageController.text,
      'veterinarian': _veterinarianController.text.isEmpty
          ? null
          : _veterinarianController.text,
      'notes': _notesController.text.isEmpty ? null : _notesController.text,
      'pharmacy_stock_id': _selectedMedication?.id,
      'quantity_used': quantityUsed,
      'created_at': now,
    };

    try {
      final dashboardRepository = context.read<DashboardRepository>();
      await dashboardRepository.createMedication(medication);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicação agendada com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar medicação: $e')),
      );
    }
  }

  double? _extractQuantityUsed() {
    final dosageText = _dosageController.text.trim();
    if (dosageText.isEmpty) return null;
    final match = RegExp(r'[\d.,]+').firstMatch(dosageText);
    if (match == null) return null;
    return double.tryParse(match.group(0)!.replaceAll(',', '.'));
  }

  bool _hasSufficientStock(double quantity) {
    final stock = _selectedMedication;
    if (stock == null) return false;
    final unit = stock.unitOfMeasure.toLowerCase();
    final useVolumeLogic = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        stock.quantityPerUnit != null &&
        stock.quantityPerUnit! > 0;

    final available = useVolumeLogic
        ? (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity
        : stock.totalQuantity;
    return quantity <= available;
  }

  bool _hasStockAvailable(PharmacyStock stock) {
    final unit = stock.unitOfMeasure.toLowerCase();
    final useVolumeLogic = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        stock.quantityPerUnit != null &&
        stock.quantityPerUnit! > 0;
    final available = useVolumeLogic
        ? (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity
        : stock.totalQuantity;
    return available > 0;
  }

  String _availableStockDescription() {
    final stock = _selectedMedication;
    if (stock == null) return '0';
    final unit = stock.unitOfMeasure.toLowerCase();
    final useVolumeLogic = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        stock.quantityPerUnit != null &&
        stock.quantityPerUnit! > 0;
    final available = useVolumeLogic
        ? (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity
        : stock.totalQuantity;
    return '${available.toStringAsFixed(1)} ${stock.unitOfMeasure}';
  }

  String _buildLowStockMessage(PharmacyStock stock) {
    final unit = stock.unitOfMeasure.toLowerCase();
    final useVolumeLogic = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        stock.quantityPerUnit != null &&
        stock.quantityPerUnit! > 0;

    if (useVolumeLogic) {
      final totalVolume =
          (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity;
      return 'Estoque baixo! Apenas ${totalVolume.toStringAsFixed(1)}${stock.unitOfMeasure} disponíveis (${stock.totalQuantity.toInt()} unidade${stock.totalQuantity > 1 ? 's' : ''}).';
    }

    return 'Estoque baixo! Apenas ${stock.totalQuantity.toInt()} unidade${stock.totalQuantity > 1 ? 's' : ''} disponíveis.';
  }
}
