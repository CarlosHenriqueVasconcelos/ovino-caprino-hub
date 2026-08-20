import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/animal.dart';
import '../../../models/pharmacy_stock.dart';
import '../../../shared/widgets/animal/animal_form.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/animal_display_utils.dart';
import '../../../utils/responsive_utils.dart';
import '../../medication/presentation/widgets/vaccination_form.dart';
import '../data/dashboard_repository.dart';

class DashboardQuickActions extends StatelessWidget {
  final void Function(int) onGoToTab;

  const DashboardQuickActions({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final dashboardRepository = context.read<DashboardRepository>();

    void showAnimalForm() {
      showDialog(
        context: context,
        builder: (context) => const AnimalFormDialog(),
      );
    }

    void showVaccinationForm() {
      showDialog(
        context: context,
        builder: (context) => const VaccinationFormDialog(),
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

    final secondaryActions = [
      _SecondaryAction(
        title: 'Registrar peso',
        icon: Icons.monitor_weight_outlined,
        color: const Color(0xFF6A8D42),
        onTap: () => onGoToTab(3),
      ),
      _SecondaryAction(
        title: 'Vacinar',
        icon: Icons.vaccines_outlined,
        color: const Color(0xFF4B73C7),
        onTap: showVaccinationForm,
      ),
      _SecondaryAction(
        title: 'Nova cobertura',
        icon: Icons.favorite_outline,
        color: const Color(0xFFB06496),
        onTap: () => onGoToTab(4),
      ),
      _SecondaryAction(
        title: 'Medicamento',
        icon: Icons.medication_outlined,
        color: const Color(0xFF3D9E8D),
        onTap: showMedicationDialog,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botão primário
        _PrimaryActionButton(
          label: 'Cadastrar animal',
          icon: Icons.add,
          onTap: showAnimalForm,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Grid responsivo de ações secundárias
        LayoutBuilder(
          builder: (context, constraints) {
            // < 480 px → 2 colunas; >= 480 px → 4 colunas
            final columns = constraints.maxWidth < 480 ? 2 : 4;
            const gap = AppSpacing.xs;

            if (columns == 2) {
              // Constrói grade 2×2
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SecondaryActionCard(
                          action: secondaryActions[0],
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        child: _SecondaryActionCard(
                          action: secondaryActions[1],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: gap),
                  Row(
                    children: [
                      Expanded(
                        child: _SecondaryActionCard(
                          action: secondaryActions[2],
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        child: _SecondaryActionCard(
                          action: secondaryActions[3],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // 4 colunas em telas maiores
            return Row(
              children: [
                for (int i = 0; i < secondaryActions.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  Expanded(
                    child: _SecondaryActionCard(action: secondaryActions[i]),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Botão primário ────────────────────────────────────────────────────────────

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Card de ação secundária ───────────────────────────────────────────────────

class _SecondaryActionCard extends StatelessWidget {
  final _SecondaryAction action;

  const _SecondaryActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderNeutral.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Tela larga → ícone + texto em linha; estreita → coluna
              final wide = constraints.maxWidth >= 120;

              if (wide) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(action.icon, size: 16, color: action.color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Muito estreito → ícone acima, texto abaixo centralizado
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: action.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(action.icon, size: 18, color: action.color),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      height: 1.25,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SecondaryAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// ── Diálogo de medicação (mantido igual ao original) ─────────────────────────

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPharmacyStock();
      _loadAnimals();
    });
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
                    if (textEditingValue.text.isEmpty) return _animalOptions;
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
                  decoration: InputDecoration(
                    labelText: 'Dosagem',
                    border: const OutlineInputBorder(),
                    hintText: 'Ex: 5 ml, 2 comprimidos',
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
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _scheduledDate = date);
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
          SizedBox(
              width: 24, height: 24, child: CircularProgressIndicator()),
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
          color: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3)),
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
            if (textEditingValue.text.isEmpty) return available;
            final search = textEditingValue.text.toLowerCase();
            return available.where(
              (stock) =>
                  stock.medicationName.toLowerCase().contains(search),
            );
          },
          fieldViewBuilder:
              (context, controller, focusNode, onFieldSubmitted) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(stock.medicationName,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Text(
          '${stock.medicationType} • ${stock.totalQuantity.toStringAsFixed(1)} ${stock.unitOfMeasure}',
          style:
              theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
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
            content: Text('Selecione um medicamento da farmácia')),
      );
      return;
    }
    final quantityUsed = _extractQuantityUsed();
    if (quantityUsed == null || quantityUsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Informe a dosagem/quantidade a ser aplicada.')),
      );
      return;
    }
    if (!_hasSufficientStock(quantityUsed)) {
      final available = _availableStockDescription();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Estoque insuficiente. Disponível: $available')),
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
      'dosage':
          _dosageController.text.isEmpty ? null : _dosageController.text,
      'veterinarian': _veterinarianController.text.isEmpty
          ? null
          : _veterinarianController.text,
      'notes':
          _notesController.text.isEmpty ? null : _notesController.text,
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
        ? (stock.totalQuantity * stock.quantityPerUnit!) +
            stock.openedQuantity
        : stock.totalQuantity;
    return quantity <= available;
  }

  bool _hasStockAvailable(PharmacyStock stock) {
    final unit = stock.unitOfMeasure.toLowerCase();
    final useVolumeLogic = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        stock.quantityPerUnit != null &&
        stock.quantityPerUnit! > 0;
    final available = useVolumeLogic
        ? (stock.totalQuantity * stock.quantityPerUnit!) +
            stock.openedQuantity
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
        ? (stock.totalQuantity * stock.quantityPerUnit!) +
            stock.openedQuantity
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
          (stock.totalQuantity * stock.quantityPerUnit!) +
              stock.openedQuantity;
      return 'Estoque baixo! Apenas ${totalVolume.toStringAsFixed(1)}${stock.unitOfMeasure} disponíveis (${stock.totalQuantity.toInt()} unidade${stock.totalQuantity > 1 ? 's' : ''}).';
    }
    return 'Estoque baixo! Apenas ${stock.totalQuantity.toInt()} unidade${stock.totalQuantity > 1 ? 's' : ''} disponíveis.';
  }
}
