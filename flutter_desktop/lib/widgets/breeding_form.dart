import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/animal_service.dart';
import '../services/database_service.dart';

class BreedingFormDialog extends StatefulWidget {
  const BreedingFormDialog({super.key});

  @override
  State<BreedingFormDialog> createState() => _BreedingFormDialogState();
}

class _BreedingFormDialogState extends State<BreedingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  String? _femaleAnimalId;
  String? _maleAnimalId;
  String _status = 'Cobertura';
  DateTime _breedingDate = DateTime.now();
  DateTime? _expectedBirth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = Provider.of<AnimalService>(context);
    
    final femaleAnimals = animalService.animals
        .where((animal) => animal.gender == 'Fêmea')
        .toList();
    
    final maleAnimals = animalService.animals
        .where((animal) => animal.gender == 'Macho')
        .toList();

    return AlertDialog(
      title: const Text('Registrar Cobertura'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Female Selection
                DropdownButtonFormField<String>(
                  value: _femaleAnimalId,
                  decoration: const InputDecoration(
                    labelText: 'Fêmea *',
                    border: OutlineInputBorder(),
                  ),
                  items: femaleAnimals.map((animal) {
                    return DropdownMenuItem(
                      value: animal.id,
                      child: Text('${animal.name} (${animal.code})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _femaleAnimalId = value;
                    });
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Selecione uma fêmea';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Male Selection (Optional)
                DropdownButtonFormField<String>(
                  value: _maleAnimalId,
                  decoration: const InputDecoration(
                    labelText: 'Macho (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Não especificado'),
                    ),
                    ...maleAnimals.map((animal) {
                      return DropdownMenuItem(
                        value: animal.id,
                        child: Text('${animal.name} (${animal.code})'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _maleAnimalId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Breeding Date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _breedingDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _breedingDate = date;
                        // Calculate expected birth (approximately 150 days for sheep/goats)
                        _expectedBirth = date.add(const Duration(days: 150));
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data da Cobertura *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_breedingDate.day.toString().padLeft(2, '0')}/${_breedingDate.month.toString().padLeft(2, '0')}/${_breedingDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Expected Birth
                if (_expectedBirth != null) ...[
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _expectedBirth!,
                        firstDate: _breedingDate.add(const Duration(days: 120)),
                        lastDate: _breedingDate.add(const Duration(days: 180)),
                      );
                      if (date != null) {
                        setState(() {
                          _expectedBirth = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Previsão de Nascimento',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_expectedBirth!.day.toString().padLeft(2, '0')}/${_expectedBirth!.month.toString().padLeft(2, '0')}/${_expectedBirth!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Status
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Cobertura', 'Confirmada', 'Nasceu', 'Perdida'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
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
          onPressed: _saveBreeding,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _saveBreeding() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final breeding = {
        'id': const Uuid().v4(),
        'female_animal_id': _femaleAnimalId!,
        'male_animal_id': _maleAnimalId,
        'breeding_date': _breedingDate.toIso8601String().split('T')[0],
        'expected_birth': _expectedBirth?.toIso8601String().split('T')[0],
        'status': _status,
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'created_at': DateTime.now().toIso8601String(),
      };

      await DatabaseService.createBreedingRecord(breeding);
      
      // If status is "Confirmada", update the female animal as pregnant
      if (_status == 'Confirmada') {
        final animalService = Provider.of<AnimalService>(context, listen: false);
        final female = animalService.animals.firstWhere((a) => a.id == _femaleAnimalId);
        final updatedFemale = female.toJson();
        updatedFemale['pregnant'] = true;
        updatedFemale['expected_delivery'] = _expectedBirth?.toIso8601String().split('T')[0];
        
        await DatabaseService.updateAnimal(_femaleAnimalId!, updatedFemale);
        animalService.loadData(); // Refresh data
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cobertura registrada com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar cobertura: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}