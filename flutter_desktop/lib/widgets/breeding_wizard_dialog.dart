// lib/widgets/breeding_wizard_dialog.dart
import 'dart:async';
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
  Timer? _femaleDebounce;
  Timer? _maleDebounce;

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
      final females = await animalService.searchAnimals(
        gender: 'Fêmea',
        excludeCategories: const ['borrego'],
        excludePregnant: true,
        limit: 50,
      );
      final males = await animalService.searchAnimals(
        gender: 'Macho',
        excludeCategories: const ['borrego'],
        limit: 50,
      );
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

  void _scheduleFemaleSearch(String query) {
    _femaleDebounce?.cancel();
    _femaleDebounce = Timer(const Duration(milliseconds: 250), () {
      _fetchFemales(query);
    });
  }

  void _scheduleMaleSearch(String query) {
    _maleDebounce?.cancel();
    _maleDebounce = Timer(const Duration(milliseconds: 250), () {
      _fetchMales(query);
    });
  }

  Future<void> _fetchFemales(String query) async {
    final animalService = context.read<AnimalService>();
    try {
      final females = await animalService.searchAnimals(
        gender: 'Fêmea',
        excludeCategories: const ['borrego'],
        excludePregnant: true,
        searchQuery: query,
        limit: 50,
      );
      AnimalDisplayUtils.sortAnimalsList(females);
      if (!mounted) return;
      setState(() => _females = females);
    } catch (_) {
      // mantém lista atual
    }
  }

  Future<void> _fetchMales(String query) async {
    final animalService = context.read<AnimalService>();
    try {
      final males = await animalService.searchAnimals(
        gender: 'Macho',
        excludeCategories: const ['borrego'],
        searchQuery: query,
        limit: 50,
      );
      AnimalDisplayUtils.sortAnimalsList(males);
      if (!mounted) return;
      setState(() => _males = males);
    } catch (_) {
      // mantém lista atual
    }
  }

  String _getAnimalDisplayText(Animal animal) {
    return AnimalDisplayUtils.getDisplayText(animal);
  }

  void _calculateMatingEndDate() {
    _matingEndDate = _matingStartDate.add(const Duration(days: 60));
  }

  @override
  void dispose() {
    _femaleDebounce?.cancel();
    _maleDebounce?.cancel();
    super.dispose();
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

    final breedingService = context.read<BreedingService>();
    final animalService = context.read<AnimalService>();

    try {
      // ✅ Usa o service de reprodução, que centraliza a regra
      await breedingService.novaCobertura(
        femaleId: _selectedFemale!.id,
        maleId: _selectedMale!.id,
        breedingDate: _matingStartDate,
        matingStartDate: _matingStartDate,
        matingEndDate: _matingEndDate,
        notes: _notes.isNotEmpty ? _notes : null,
      );
      // Opcional: atualizar KPIs/listas de animais
      await animalService.loadData();

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final dialogWidth = isMobile ? screenWidth * 0.95 : 600.0;
    final optionsWidth = isMobile ? screenWidth * 0.85 : 500.0;

    return Dialog(
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                          Icon(Icons.pets, color: Colors.green, size: isMobile ? 24 : 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isMobile ? 'Nova Cobertura' : 'Nova Cobertura - Encabritamento',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Etapa 1: Juntar macho e fêmea por 60 dias',
                        style: TextStyle(color: Colors.grey, fontSize: isMobile ? 12 : 14),
                      ),
                      const Divider(height: 32),

                      // Fêmea (Autocomplete)
                      Autocomplete<Animal>(
                        displayStringForOption: _getAnimalDisplayText,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          _scheduleFemaleSearch(textEditingValue.text);
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
                                width: optionsWidth,
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
                          _scheduleMaleSearch(textEditingValue.text);
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
                                width: optionsWidth,
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

                      // Botões - responsivo para mobile
                      if (isMobile)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Iniciar Encabritamento'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                          ],
                        )
                      else
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
