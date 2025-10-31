// lib/widgets/breeding_wizard_dialog.dart
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../models/breeding_record.dart';
import '../services/database_service.dart';

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
    _loadAnimals();
    _calculateMatingEndDate();
  }

  Future<void> _loadAnimals() async {
    try {
      final animals = await DatabaseService.getAnimals();
      
      // Filtrar: fêmeas e machos, excluindo categoria "Borrego"
      final females = animals
          .where((a) => a.gender == 'Fêmea' && a.category != 'Borrego')
          .toList();
      final males = animals
          .where((a) => a.gender == 'Macho' && a.category != 'Borrego')
          .toList();
      
      // Ordenar por cor e depois por número
      _sortAnimalsList(females);
      _sortAnimalsList(males);
      
      setState(() {
        _females = females;
        _males = males;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar animais: $e')),
        );
      }
    }
  }

  void _sortAnimalsList(List<Animal> animals) {
    animals.sort((a, b) {
      // Primeiro ordenar por cor
      final colorA = a.nameColor ?? '';
      final colorB = b.nameColor ?? '';
      final colorCompare = colorA.compareTo(colorB);
      
      if (colorCompare != 0) return colorCompare;
      
      // Depois ordenar por código numérico
      final numA = _extractNumber(a.code);
      final numB = _extractNumber(b.code);
      return numA.compareTo(numB);
    });
  }

  int _extractNumber(String code) {
    // Extrair número do código (ex: "123" de "OV123" ou "123")
    final match = RegExp(r'\d+').firstMatch(code);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  String _getAnimalDisplayText(Animal animal) {
    final colorKey = animal.nameColor ?? 'Sem cor';
    final colorName = _translateColor(colorKey);
    return '$colorName - ${animal.code} - ${animal.name}';
  }

  String _translateColor(String colorKey) {
    const colorTranslations = {
      'blue': 'Azul',
      'red': 'Vermelho',
      'green': 'Verde',
      'yellow': 'Amarelo',
      'orange': 'Laranja',
      'purple': 'Roxo',
      'pink': 'Rosa',
      'grey': 'Cinza',
      'white': 'Branca',
      'black': 'Preto',
    };
    return colorTranslations[colorKey] ?? colorKey;
  }

  void _calculateMatingEndDate() {
    setState(() {
      _matingEndDate = _matingStartDate.add(const Duration(days: 60));
    });
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
      // ⚠️ IMPORTANTE:
      // Não gravar expected_birth aqui. Ele será definido quando/SE a gestação for confirmada.
      await DatabaseService.createBreedingRecord({
        'female_animal_id': _selectedFemale!.id,
        'male_animal_id': _selectedMale!.id,
        'breeding_date': _matingStartDate,
        'mating_start_date': _matingStartDate,
        'mating_end_date': _matingEndDate,
        'stage': BreedingStage.encabritamento.value, // sempre começa em encabritamento
        'status': 'Cobertura', // o trigger também ajusta isso, mas não faz mal enviar
        'notes': _notes.isNotEmpty ? _notes : null,
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Encabritamento registrado com sucesso!')),
        );
        widget.onComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar: $e')),
        );
      }
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

                      // Female Selection with Integrated Search
                      Autocomplete<Animal>(
                        displayStringForOption: _getAnimalDisplayText,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _females;
                          }
                          return _females.where((animal) {
                            final searchText = textEditingValue.text.toLowerCase();
                            return animal.code.toLowerCase().contains(searchText) ||
                                   animal.name.toLowerCase().contains(searchText);
                          });
                        },
                        onSelected: (Animal animal) {
                          setState(() => _selectedFemale = animal);
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
                            validator: (value) => _selectedFemale == null ? 'Selecione uma fêmea' : null,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                width: 500,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final animal = options.elementAt(index);
                                    return ListTile(
                                      leading: const Icon(Icons.female, size: 20),
                                      title: Text(_getAnimalDisplayText(animal)),
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

                      // Male Selection with Integrated Search
                      Autocomplete<Animal>(
                        displayStringForOption: _getAnimalDisplayText,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _males;
                          }
                          return _males.where((animal) {
                            final searchText = textEditingValue.text.toLowerCase();
                            return animal.code.toLowerCase().contains(searchText) ||
                                   animal.name.toLowerCase().contains(searchText);
                          });
                        },
                        onSelected: (Animal animal) {
                          setState(() => _selectedMale = animal);
                        },
                        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
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
                            validator: (value) => _selectedMale == null ? 'Selecione um macho' : null,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                width: 500,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final animal = options.elementAt(index);
                                    return ListTile(
                                      leading: const Icon(Icons.male, size: 20),
                                      title: Text(_getAnimalDisplayText(animal)),
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

                      // Mating Start Date
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

                      // Calculated End Date
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
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
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

                      // Notes
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

                      // Action Buttons
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
