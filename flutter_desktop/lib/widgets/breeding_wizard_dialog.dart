// lib/widgets/breeding_wizard_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../services/animal_service.dart';
import '../services/breeding_service.dart';
import '../utils/animal_display_utils.dart';

class BreedingWizardDialog extends StatefulWidget {
  final Function? onComplete;

  const BreedingWizardDialog({
    super.key,
    this.onComplete,
  });

  @override
  State<BreedingWizardDialog> createState() => _BreedingWizardDialogState();
}

class _BreedingWizardDialogState extends State<BreedingWizardDialog> {
  final _formKey = GlobalKey<FormState>();

  List<Animal> _females = [];
  List<Animal> _males = [];
  bool _isLoading = true;

  Animal? _selectedFemale;
  Animal? _selectedMale;
  DateTime _matingStartDate = DateTime.now();
  DateTime? _matingEndDate;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _calculateMatingEndDate();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    try {
      final animalService = context.read<AnimalService>();

      // Garante que a lista está carregada
      if (animalService.animals.isEmpty) {
        await animalService.loadData();
      }

      final animals = List<Animal>.from(animalService.animals);

      // Filtrar: fêmeas e machos, excluindo categoria "Borrego"
      final females = animals
          .where((a) => a.gender == 'Fêmea' && a.category != 'Borrego')
          .toList();
      final males = animals
          .where((a) => a.gender == 'Macho' && a.category != 'Borrego')
          .toList();

      // Ordenar por cor e depois por número
      AnimalDisplayUtils.sortAnimalsList(females);
      AnimalDisplayUtils.sortAnimalsList(males);

      if (!mounted) return;
      setState(() {
        _females = females;
        _males = males;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar animais: $e')),
      );
    }
  }

  String _getAnimalDisplayText(Animal animal) {
    return AnimalDisplayUtils.getDisplayText(animal);
  }

  void _calculateMatingEndDate() {
    _matingEndDate = _matingStartDate.add(const Duration(days: 60));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFemale == null || _selectedMale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a fêmea e o macho')),
      );
      return;
    }

    _formKey.currentState!.save();

    try {
      // ✅ Usa o service de reprodução, que centraliza a regra
      final breedingService = context.read<BreedingService>();

      await breedingService.novaCobertura(
        femaleId: _selectedFemale!.id,
        maleId: _selectedMale!.id,
        breedingDate: _matingStartDate,
        matingStartDate: _matingStartDate,
        matingEndDate: _matingEndDate,
        notes: _notes.isNotEmpty ? _notes : null,
      );
      // Opcional: atualizar KPIs/listas de animais
      await context.read<AnimalService>().loadData();

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encabritamento registrado com sucesso!')),
      );
      widget.onComplete?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pets, color: Colors.green, size: 32),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Nova Cobertura - Encabritamento',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Etapa 1: Juntar macho e fêmea por 60 dias',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Divider(height: 32),

                      // Fêmea (Autocomplete)
                      Autocomplete<Animal>(
                        displayStringForOption: _getAnimalDisplayText,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _females;
                          }
                          return _females.where((animal) {
                            final searchText =
                                textEditingValue.text.toLowerCase();
                            return animal.code
                                    .toLowerCase()
                                    .contains(searchText) ||
                                animal.name.toLowerCase().contains(searchText);
                          });
                        },
                        onSelected: (Animal animal) {
                          setState(() => _selectedFemale = animal);
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
                              suffixIcon: _selectedFemale != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() => _selectedFemale = null);
                                        controller.clear();
                                      },
                                    )
                                  : null,
                            ),
                            validator: (value) => _selectedFemale == null
                                ? 'Selecione uma fêmea'
                                : null,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                width: 500,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final animal = options.elementAt(index);
                                    return ListTile(
                                      title:
                                          AnimalDisplayUtils.buildDropdownItem(
                                              animal),
                                      onTap: () => onSelected(animal),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Macho (Autocomplete)
                      Autocomplete<Animal>(
                        displayStringForOption: _getAnimalDisplayText,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _males;
                          }
                          return _males.where((animal) {
                            final searchText =
                                textEditingValue.text.toLowerCase();
                            return animal.code
                                    .toLowerCase()
                                    .contains(searchText) ||
                                animal.name.toLowerCase().contains(searchText);
                          });
                        },
                        onSelected: (Animal animal) {
                          setState(() => _selectedMale = animal);
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Macho *',
                              hintText: 'Digite o número ou nome para buscar',
                              prefixIcon: const Icon(Icons.male),
                              border: const OutlineInputBorder(),
                              suffixIcon: _selectedMale != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() => _selectedMale = null);
                                        controller.clear();
                                      },
                                    )
                                  : null,
                            ),
                            validator: (value) => _selectedMale == null
                                ? 'Selecione um macho'
                                : null,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                width: 500,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final animal = options.elementAt(index);
                                    return ListTile(
                                      title:
                                          AnimalDisplayUtils.buildDropdownItem(
                                              animal),
                                      onTap: () => onSelected(animal),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Data de início
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Data de Entrada (Início)'),
                        subtitle: Text(
                          '${_matingStartDate.day.toString().padLeft(2, '0')}/${_matingStartDate.month.toString().padLeft(2, '0')}/${_matingStartDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              locale: const Locale('pt', 'BR'),
                              initialDate: _matingStartDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _matingStartDate = date;
                                _calculateMatingEndDate();
                              });
                            }
                          },
                          child: const Text('Alterar'),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Data de separação (calculada)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Data de Separação (60 dias):',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _matingEndDate != null
                                        ? '${_matingEndDate!.day.toString().padLeft(2, '0')}/${_matingEndDate!.month.toString().padLeft(2, '0')}/${_matingEndDate!.year}'
                                        : '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Observações
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onSaved: (value) => _notes = value ?? '',
                      ),
                      const SizedBox(height: 24),

                      // Botões
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.check),
                            label: const Text('Iniciar Encabritamento'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
