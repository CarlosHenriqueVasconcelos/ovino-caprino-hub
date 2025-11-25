import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/animal.dart';
import '../../../models/pharmacy_stock.dart';
import '../../../services/animal_service.dart';
import '../../../services/medication_service.dart';
import '../../../services/pharmacy_service.dart';
import '../../../utils/animal_display_utils.dart';
import '../../../widgets/animal_form.dart';
import '../../../widgets/financial_complete_screen.dart';
import '../../../widgets/history_screen.dart';
import '../../../widgets/medication_management_screen.dart';
import '../../../widgets/notes_management_screen.dart';
import '../../../widgets/pharmacy_management_screen.dart';
import '../../../widgets/reports_hub_screen.dart';
import '../../../widgets/system_settings_screen.dart';
import '../../../widgets/vaccination_form.dart';

class DashboardQuickActions extends StatelessWidget {
  final void Function(int) onGoToTab;
  const DashboardQuickActions({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = context.read<AnimalService>();

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
          onSaved: () => animalService.loadData(),
        ),
      );
    }

    void openModal(Widget child) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          clipBehavior: Clip.hardEdge,
          child: SizedBox(width: 1200, height: 720, child: child),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final actions = [
                  _QuickActionData(
                    title: 'Novo Animal',
                    icon: Icons.add,
                    color: theme.colorScheme.primary,
                    onTap: () => showAnimalForm(),
                  ),
                  _QuickActionData(
                    title: 'Agendar Vacinação',
                    icon: Icons.vaccines,
                    color: Colors.blue,
                    onTap: () => showVaccinationForm(),
                  ),
                  _QuickActionData(
                    title: 'Agendar Medicamento',
                    icon: Icons.medication,
                    color: Colors.teal,
                    onTap: showMedicationDialog,
                  ),
                  _QuickActionData(
                    title: 'Gerar Relatório',
                    icon: Icons.description,
                    color: Colors.purple,
                    onTap: () => openModal(const ReportsHubScreen()),
                  ),
                  _QuickActionData(
                    title: 'Histórico Completo',
                    icon: Icons.history,
                    color: Colors.orange,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HistoryScreen(),
                      ),
                    ),
                  ),
                  _QuickActionData(
                    title: 'Financeiro',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    onTap: () => openModal(const FinancialCompleteScreen()),
                  ),
                  _QuickActionData(
                    title: 'Farmácia',
                    icon: Icons.local_pharmacy,
                    color: Colors.redAccent,
                    onTap: () => openModal(const PharmacyManagementScreen()),
                  ),
                  _QuickActionData(
                    title: 'Medicações',
                    icon: Icons.medical_services,
                    color: Colors.indigo,
                    onTap: () => openModal(const MedicationManagementScreen()),
                  ),
                  _QuickActionData(
                    title: 'Anotações',
                    icon: Icons.note_alt,
                    color: Colors.brown,
                    onTap: () => openModal(const NotesManagementScreen()),
                  ),
                  _QuickActionData(
                    title: 'Configurações',
                    icon: Icons.settings,
                    color: Colors.grey,
                    onTap: () => openModal(const SystemSettingsScreen()),
                  ),
                ];

                final width = constraints.maxWidth;
                const desiredWidth = 200.0;
                final crossAxisCount = width.isFinite && width > 0
                    ? (width / desiredWidth).floor().clamp(1, 5)
                    : 5;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: actions.length,
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return _ActionCard(
                      title: action.title,
                      icon: action.icon,
                      color: action.color,
                      onTap: action.onTap,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
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

  @override
  void dispose() {
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
  }

  Future<void> _loadPharmacyStock() async {
    setState(() => _loadingStock = true);
    try {
      final pharmacyService = context.read<PharmacyService>();
      final stock = await pharmacyService.getPharmacyStock();
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

  @override
  Widget build(BuildContext context) {
    final animalService = context.watch<AnimalService>();
    final theme = Theme.of(context);
    final animals = [...animalService.animals];
    AnimalDisplayUtils.sortAnimalsList(animals);

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
                    if (textEditingValue.text.isEmpty) {
                      return animals;
                    }
                    final search = textEditingValue.text.toLowerCase();
                    return animals.where((animal) {
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
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        child: SizedBox(
                          width: 468,
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
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
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
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: SizedBox(
                  width: 468,
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
                color: Colors.orange.withOpacity(0.1),
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
      final medicationService = context.read<MedicationService>();
      await medicationService.createMedication(medication);
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
