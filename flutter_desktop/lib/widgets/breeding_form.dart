// lib/widgets/breeding_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/animal_service.dart';
import '../services/breeding_service.dart';
import '../models/animal.dart';
import '../models/breeding_record.dart';
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
  String _status = 'Cobertura'; // ainda usado na UI; mapeamos para stage
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
      // Agora usamos o BreedingService (injeção via Provider)
      final svc = context.read<BreedingService>();
      final records = await svc.getBreedingRecords();
      if (!mounted) return;
      setState(() {
        _breedingRecords = records;
        _loadingRecords = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar registros de reprodução: $e');
      if (!mounted) return;
      setState(() => _loadingRecords = false);
    }
  }

  String _getAnimalDisplayText(Animal animal) {
    return AnimalDisplayUtils.getDisplayText(animal);
  }

  /// Verifica se a fêmea está em alguma fase reprodutiva ativa.
  /// Antes a checagem era por strings como "Ultrassom agendado", "Gestante".
  /// Agora usamos o enum BreedingStage + valores snake_case do DB.
  bool _isFemaleInBreeding(String animalId) {
    return _breedingRecords.any((record) {
      if (record['female_animal_id'] != animalId) return false;
      final stage = BreedingStage.fromString(record['stage'] as String?);

      // Mantém a lógica antiga:
      // - aguardando_ultrassom  ~ "Ultrassom agendado/confirmado"
      // - gestacao_confirmada   ~ "Gestante"
      return stage == BreedingStage.aguardandoUltrassom ||
          stage == BreedingStage.gestacaoConfirmada;
    });
  }

  /// Verifica se o macho está em encabritamento (usado para bloquear).
  bool _isMaleInBreeding(String animalId) {
    return _breedingRecords.any((record) {
      if (record['male_animal_id'] != animalId) return false;
      final stage = BreedingStage.fromString(record['stage'] as String?);
      return stage == BreedingStage.encabritamento;
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

    // Filtrar fêmeas: excluir borregas, venda, gestantes e que estão em reprodução ativa
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

    // Filtrar machos: excluir borregos, venda e que estão em encabritamento
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
                  fieldViewBuilder:
                      (context, controller, focusNode, onSubmitted) {
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
                      validator: (value) => _femaleAnimalId == null
                          ? 'Selecione uma fêmea'
                          : null,
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 8.0,
                        color: Theme.of(context).cardColor,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 240),
                          width: 468,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Animal animal = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(animal),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: AnimalDisplayUtils.buildDropdownItem(
                                    animal,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                  ),
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
                  fieldViewBuilder:
                      (context, controller, focusNode, onSubmitted) {
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
                        elevation: 8.0,
                        color: Theme.of(context).cardColor,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 240),
                          width: 468,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Animal animal = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(animal),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: AnimalDisplayUtils.buildDropdownItem(
                                    animal,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                  ),
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
                      locale: const Locale('pt', 'BR'),
                      initialDate: _breedingDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _breedingDate = date;
                        // Calcula uma previsão aproximada de parto (150 dias)
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
                      '${_breedingDate.day.toString().padLeft(2, '0')}/'
                      '${_breedingDate.month.toString().padLeft(2, '0')}/'
                      '${_breedingDate.year}',
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
                        locale: const Locale('pt', 'BR'),
                        initialDate: _expectedBirth!,
                        firstDate:
                            _breedingDate.add(const Duration(days: 120)),
                        lastDate:
                            _breedingDate.add(const Duration(days: 180)),
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
                        '${_expectedBirth!.day.toString().padLeft(2, '0')}/'
                        '${_expectedBirth!.month.toString().padLeft(2, '0')}/'
                        '${_expectedBirth!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Status (aqui ainda usamos os rótulos antigos; mapeamos para stage)
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Cobertura', 'Confirmada', 'Nasceu', 'Perdida']
                      .map((status) {
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

  /// Converte o "status" antigo de UI para o novo estágio canônico.
  BreedingStage _mapStatusToStage(String status) {
    switch (status) {
      case 'Confirmada':
        return BreedingStage.gestacaoConfirmada;
      case 'Nasceu':
        return BreedingStage.partoRealizado;
      case 'Perdida':
        return BreedingStage.falhou;
      case 'Cobertura':
      default:
        return BreedingStage.encabritamento;
    }
  }

  Future<void> _saveBreeding() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final breedingService = context.read<BreedingService>();
      final animalService =
          Provider.of<AnimalService>(context, listen: false);

      final stageEnum = _mapStatusToStage(_status);
      final notes = _notesController.text.trim();

      // Cria registro de reprodução via service (usa repositório/DB e gatilhos de status)
      await breedingService.createRecord(
        femaleId: _femaleAnimalId!,
        maleId: _maleAnimalId,
        stage: stageEnum.value,
        breedingDate: _breedingDate,
        expectedBirth: _expectedBirth,
        notes: notes.isEmpty ? null : notes,
      );

      // Se o estágio representar gestação confirmada, marcamos a fêmea como gestante
      if (stageEnum == BreedingStage.gestacaoConfirmada) {
        final female = animalService.animals
            .firstWhere((a) => a.id == _femaleAnimalId);

        final updatedFemale = female.copyWith(
          pregnant: true,
          expectedDelivery: _expectedBirth,
        );

        await animalService.updateAnimal(updatedFemale);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cobertura registrada com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar cobertura: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
