import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/animal_service.dart';
import '../services/database_service.dart';
import '../models/animal.dart';
import '../utils/animal_display_utils.dart';

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
  
  List<Map<String, dynamic>> _breedingRecords = [];
  bool _loadingRecords = true;

  @override
  void initState() {
    super.initState();
    _loadBreedingRecords();
  }

  Future<void> _loadBreedingRecords() async {
    try {
      final records = await DatabaseService.getBreedingRecords();
      setState(() {
        _breedingRecords = records;
        _loadingRecords = false;
      });
    } catch (e) {
      print('Erro ao carregar registros de reprodução: $e');
      setState(() => _loadingRecords = false);
    }
  }
  
  String _getAnimalDisplayText(Animal animal) {
    return AnimalDisplayUtils.getDisplayText(animal);
  }
  
  bool _isFemaleInBreeding(String animalId) {
    // Verifica se a fêmea está em qualquer fase de reprodução ativa
    return _breedingRecords.any((record) {
      if (record['female_animal_id'] != animalId) return false;
      final stage = record['stage']?.toString() ?? '';
      // Considera ativa se estiver aguardando ultrassom ou em outras fases antes do nascimento
      return stage == 'Ultrassom agendado' || 
             stage == 'Ultrassom confirmado' ||
             stage == 'Gestante';
    });
  }
  
  bool _isMaleInBreeding(String animalId) {
    // Verifica se o macho está em fase de encabritamento
    return _breedingRecords.any((record) {
      if (record['male_animal_id'] != animalId) return false;
      final stage = record['stage']?.toString() ?? '';
      return stage == 'Encabritamento';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = Provider.of<AnimalService>(context);
    
    if (_loadingRecords) {
      return const AlertDialog(
        title: Text('Registrar Cobertura'),
        content: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Filtrar fêmeas: excluir borregas, gestantes e que estão aguardando ultrassom
    final femaleAnimals = animalService.animals
        .where((animal) => 
            animal.gender == 'Fêmea' && 
            animal.category != 'Borrego' &&
            animal.category != 'Borrega' &&
            animal.category != 'Venda' &&
            !animal.pregnant &&
            !_isFemaleInBreeding(animal.id))
        .toList();
    
    // Ordenar fêmeas
    AnimalDisplayUtils.sortAnimalsList(femaleAnimals);
    
    // Filtrar machos: excluir borregos e que estão em encabritamento
    final maleAnimals = animalService.animals
        .where((animal) => 
            animal.gender == 'Macho' && 
            animal.category != 'Borrego' &&
            animal.category != 'Venda' &&
            !_isMaleInBreeding(animal.id))
        .toList();
    
    // Ordenar machos
    AnimalDisplayUtils.sortAnimalsList(maleAnimals);

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
                // Female Selection with Search
                Autocomplete<Animal>(
                  displayStringForOption: _getAnimalDisplayText,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return femaleAnimals;
                    }
                    return femaleAnimals.where((animal) {
                      final searchText = textEditingValue.text.toLowerCase();
                      return animal.code.toLowerCase().contains(searchText) ||
                             animal.name.toLowerCase().contains(searchText);
                    });
                  },
                  onSelected: (Animal animal) {
                    setState(() => _femaleAnimalId = animal.id);
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Fêmea *',
                        hintText: 'Digite o número ou nome para buscar',
                        prefixIcon: const Icon(Icons.female),
                        border: const OutlineInputBorder(),
                        suffixIcon: _femaleAnimalId != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _femaleAnimalId = null);
                                  controller.clear();
                                },
                              )
                            : null,
                      ),
                      validator: (value) => _femaleAnimalId == null ? 'Selecione uma fêmea' : null,
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
                const SizedBox(height: 16),
                
                // Male Selection (Optional) with Search
                Autocomplete<Animal>(
                  displayStringForOption: _getAnimalDisplayText,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return maleAnimals;
                    }
                    return maleAnimals.where((animal) {
                      final searchText = textEditingValue.text.toLowerCase();
                      return animal.code.toLowerCase().contains(searchText) ||
                             animal.name.toLowerCase().contains(searchText);
                    });
                  },
                  onSelected: (Animal animal) {
                    setState(() => _maleAnimalId = animal.id);
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Macho (opcional)',
                        hintText: 'Digite o número ou nome para buscar',
                        prefixIcon: const Icon(Icons.male),
                        border: const OutlineInputBorder(),
                        suffixIcon: _maleAnimalId != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() => _maleAnimalId = null);
                                  controller.clear();
                                },
                              )
                            : null,
                      ),
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