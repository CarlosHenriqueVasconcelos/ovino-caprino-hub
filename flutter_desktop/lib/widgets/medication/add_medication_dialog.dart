import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/animal.dart';
import '../../models/pharmacy_stock.dart';
import '../../services/animal_service.dart';
import '../../services/medication_service.dart';
import '../../services/pharmacy_service.dart';
import '../../services/vaccination_service.dart';
import '../../utils/animal_display_utils.dart';
import '../../utils/responsive_utils.dart';

class AddMedicationDialog extends StatefulWidget {
  final VoidCallback onSaved;
  final String initialType;

  const AddMedicationDialog({
    super.key,
    required this.onSaved,
    this.initialType = 'Vacinação',
  });

  @override
  State<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();
  final _dosageController = TextEditingController();

  late String _type = widget.initialType;
  String _vaccineType = 'Obrigatória';
  DateTime _scheduledDate = DateTime.now();
  String? _selectedAnimalId;

  List<PharmacyStock> _pharmacyStock = [];
  PharmacyStock? _selectedMedication;
  bool _isLoadingStock = false;
  
  List<Animal> _animals = [];
  bool _isLoadingAnimals = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingStock = true;
      _isLoadingAnimals = true;
    });

    try {
      final pharmacyService =
          Provider.of<PharmacyService>(context, listen: false);
      final animalService =
          Provider.of<AnimalService>(context, listen: false);
      
      final results = await Future.wait([
        pharmacyService.getPharmacyStock(),
        animalService.getAllAnimals(),
      ]);
      
      if (mounted) {
        setState(() {
          _pharmacyStock = results[0] as List<PharmacyStock>;
          _animals = results[1] as List<Animal>;
          _isLoadingStock = false;
          _isLoadingAnimals = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStock = false;
          _isLoadingAnimals = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text('Agendar Vacinação/Medicamento'),
      content: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Tipo *'),
                    items: const [
                      DropdownMenuItem(value: 'Vacinação', child: Text('Vacinação')),
                      DropdownMenuItem(value: 'Medicamento', child: Text('Medicamento')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                        _selectedMedication = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingAnimals && _animals.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (_animals.isEmpty)
                    const Text('Cadastre um animal antes de agendar a aplicação.')
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAnimalId,
                      decoration: const InputDecoration(labelText: 'Animal *'),
                      items: _animals
                          .map(
                            (animal) => DropdownMenuItem(
                              value: animal.id,
                              child: Text(
                                AnimalDisplayUtils.getDisplayText(animal),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedAnimalId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Selecione um animal' : null,
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: _type == 'Vacinação'
                          ? 'Nome da vacina *'
                          : 'Nome do medicamento *',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_type == 'Vacinação')
                    DropdownButtonFormField<String>(
                      initialValue: _vaccineType,
                      decoration: const InputDecoration(labelText: 'Tipo de vacina'),
                      items: const [
                        'Obrigatória',
                        'Preventiva',
                        'Tratamento',
                        'Emergencial'
                      ]
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _vaccineType = value!);
                      },
                    )
                  else
                    _MedicationPharmacyAutocomplete(
                      options: _pharmacyStock,
                      isLoading: _isLoadingStock,
                      onSelected: (stock) {
                        setState(() => _selectedMedication = stock);
                      },
                    ),
                  const SizedBox(height: 16),
                  if (_type == 'Medicamento')
                    TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Dosagem',
                        border: OutlineInputBorder(),
                        hintText: 'Ex: 5ml, 2 comprimidos',
                      ),
                    ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _scheduledDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _scheduledDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data agendada *',
                        border: OutlineInputBorder(),
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

  void _save() async {
    if (!_formKey.currentState!.validate() || _selectedAnimalId == null) return;

    if (_type == 'Medicamento') {
      if (_selectedMedication == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um medicamento da farmácia'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final now = DateTime.now().toIso8601String();

    try {
      if (_type == 'Vacinação') {
        final vaccinationService =
            Provider.of<VaccinationService>(context, listen: false);
        final vaccination = {
          'id': const Uuid().v4(),
          'animal_id': _selectedAnimalId!,
          'vaccine_name': _nameController.text,
          'vaccine_type': _vaccineType,
          'scheduled_date': _scheduledDate.toIso8601String().split('T')[0],
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
          'status': 'Agendada',
          'created_at': now,
          'updated_at': now,
        };
        await vaccinationService.createVaccination(vaccination);
      } else {
        final medicationService =
            Provider.of<MedicationService>(context, listen: false);
        final dosageText = _dosageController.text.trim();
        final quantityMatch = RegExp(r'[\d.,]+').firstMatch(dosageText);
        final quantityUsed = quantityMatch != null
            ? double.tryParse(quantityMatch.group(0)!.replaceAll(',', '.'))
            : null;

        final medication = {
          'id': const Uuid().v4(),
          'animal_id': _selectedAnimalId!,
          'medication_name': _nameController.text,
          'date': _scheduledDate.toIso8601String().split('T')[0],
          'next_date': _scheduledDate
              .add(const Duration(days: 30))
              .toIso8601String()
              .split('T')[0],
          'dosage':
              _dosageController.text.isEmpty ? null : _dosageController.text,
          'veterinarian': _veterinarianController.text.isEmpty
              ? null
              : _veterinarianController.text,
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
          'status': 'Agendado',
          'pharmacy_stock_id': _selectedMedication?.id,
          'quantity_used': quantityUsed,
          'created_at': now,
        };
        await medicationService.createMedication(medication);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_type agendada com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}

class _MedicationPharmacyAutocomplete extends StatelessWidget {
  final List<PharmacyStock> options;
  final bool isLoading;
  final ValueChanged<PharmacyStock> onSelected;

  const _MedicationPharmacyAutocomplete({
    required this.options,
    required this.isLoading,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Autocomplete<PharmacyStock>(
      displayStringForOption: (option) => option.medicationName,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        return options.where(
          (stock) => stock.medicationName.toLowerCase().contains(query),
        );
      },
      onSelected: onSelected,
      fieldViewBuilder: (
        context,
        controller,
        focusNode,
        onFieldSubmitted,
      ) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Medicamento (farmácia) *',
            border: OutlineInputBorder(),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, matches) {
        final optionsWidth = ResponsiveUtils.isMobile(context)
            ? MediaQuery.of(context).size.width - 48
            : 400.0;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: SizedBox(
              width: optionsWidth,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: matches.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final option = matches.elementAt(index);
                  return ListTile(
                    title: Text(option.medicationName),
                    subtitle: Text(
                      option.totalQuantity < 5
                          ? _lowStockLabel(option)
                          : 'Estoque: ${option.totalQuantity.toStringAsFixed(1)} ${option.unitOfMeasure}',
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _lowStockLabel(PharmacyStock stock) {
    final unit = stock.unitOfMeasure.toLowerCase();
    final useVolumeLogic = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        stock.quantityPerUnit != null &&
        stock.quantityPerUnit! > 0;
    if (useVolumeLogic) {
      final totalVolume =
          (stock.totalQuantity * stock.quantityPerUnit!) +
              stock.openedQuantity;
      return 'Estoque baixo: ${totalVolume.toStringAsFixed(1)}${stock.unitOfMeasure}';
    }
    return 'Estoque baixo: ${stock.totalQuantity.toStringAsFixed(1)} unidade(s)';
  }
}
