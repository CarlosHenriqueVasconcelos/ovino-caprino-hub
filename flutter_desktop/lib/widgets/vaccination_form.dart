import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/animal_service.dart';
import '../services/database_service.dart';
import '../models/animal.dart';
import '../utils/animal_display_utils.dart';

class VaccinationFormDialog extends StatefulWidget {
  final String? animalId;
  
  const VaccinationFormDialog({super.key, this.animalId});

  @override
  State<VaccinationFormDialog> createState() => _VaccinationFormDialogState();
}

class _VaccinationFormDialogState extends State<VaccinationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _vaccineType = 'Obrigatória';
  String _status = 'Agendada';
  DateTime _scheduledDate = DateTime.now();
  DateTime? _appliedDate;
  String? _selectedAnimalId;

  @override
  void initState() {
    super.initState();
    _selectedAnimalId = widget.animalId;
  }

  String _getAnimalDisplayText(Animal animal) {
    return AnimalDisplayUtils.getDisplayText(animal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = Provider.of<AnimalService>(context);
    
    // Ordenar animais
    final sortedAnimals = [...animalService.animals];
    AnimalDisplayUtils.sortAnimalsList(sortedAnimals);
    
    return AlertDialog(
      title: const Text('Nova Vacinação'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animal Selection with Search
                if (widget.animalId == null)
                  Autocomplete<Animal>(
                    displayStringForOption: _getAnimalDisplayText,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return sortedAnimals;
                      }
                      return sortedAnimals.where((animal) {
                        final searchText = textEditingValue.text.toLowerCase();
                        return animal.code.toLowerCase().contains(searchText) ||
                               animal.name.toLowerCase().contains(searchText);
                      });
                    },
                    onSelected: (Animal animal) {
                      setState(() => _selectedAnimalId = animal.id);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Animal *',
                          hintText: 'Digite o número ou nome para buscar',
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
                        validator: (value) => _selectedAnimalId == null ? 'Selecione um animal' : null,
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            width: 468,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Animal animal = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(animal),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: AnimalDisplayUtils.buildDropdownItem(animal),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                
                if (widget.animalId == null) const SizedBox(height: 16),
                
                // Vaccine Info
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _vaccineNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Vacina *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _vaccineType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Obrigatória', 'Preventiva', 'Tratamento', 'Emergencial']
                            .map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _vaccineType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Dates
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            locale: const Locale('pt', 'BR'),
                            initialDate: _scheduledDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _scheduledDate = date;
                            });
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Agendada', 'Aplicada', 'Cancelada'].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                            if (_status == 'Aplicada' && _appliedDate == null) {
                              _appliedDate = DateTime.now();
                            } else if (_status != 'Aplicada') {
                              _appliedDate = null;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Applied Date (if status is Applied)
                if (_status == 'Aplicada') ...[
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        locale: const Locale('pt', 'BR'),
                        initialDate: _appliedDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _appliedDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Aplicação',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _appliedDate != null
                            ? '${_appliedDate!.day.toString().padLeft(2, '0')}/${_appliedDate!.month.toString().padLeft(2, '0')}/${_appliedDate!.year}'
                            : 'Selecionar data',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Veterinarian
                TextFormField(
                  controller: _veterinarianController,
                  decoration: const InputDecoration(
                    labelText: 'Veterinário',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Notes
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveVaccination,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _saveVaccination() async {
    if (!_formKey.currentState!.validate() || _selectedAnimalId == null) return;

    try {
      final vaccination = {
        'id': const Uuid().v4(),
        'animal_id': _selectedAnimalId!,
        'vaccine_name': _vaccineNameController.text,
        'vaccine_type': _vaccineType,
        'scheduled_date': _scheduledDate.toIso8601String().split('T')[0],
        'applied_date': _appliedDate?.toIso8601String().split('T')[0],
        'veterinarian': _veterinarianController.text.isEmpty ? null : _veterinarianController.text,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'status': _status,
        'created_at': DateTime.now().toIso8601String(),
      };

      await DatabaseService.createVaccination(vaccination);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vacinação registrada com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar vacinação: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}