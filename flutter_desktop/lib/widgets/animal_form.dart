import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';
import '../utils/animal_display_utils.dart';

class AnimalFormDialog extends StatefulWidget {
  final Animal? animal;
  final String? motherId;
  final String? motherName;
  final String? motherColor;
  final String? motherCode;
  final String? motherBreed;
  final String? fatherId;
  final String? fatherName;
  final String? fatherColor;
  final String? fatherCode;
  final String? fatherBreed;
  final String? presetCategory;

  const AnimalFormDialog({
    super.key,
    this.animal,
    this.motherId,
    this.motherName,
    this.motherColor,
    this.motherCode,
    this.motherBreed,
    this.fatherId,
    this.fatherName,
    this.fatherColor,
    this.fatherCode,
    this.fatherBreed,
    this.presetCategory,
  });

  @override
  State<AnimalFormDialog> createState() => _AnimalFormDialogState();
}

class _AnimalFormDialogState extends State<AnimalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _locationController = TextEditingController();
  final _yearController = TextEditingController();
  final _loteController = TextEditingController();

  String _species = 'Ovino';
  String _gender = 'Fêmea';
  String _status = 'Saudável';
  String _category = 'Não especificado';
  String _nameColor = 'blue';
  DateTime _birthDate = DateTime.now();
  bool _pregnant = false;
  DateTime? _expectedDelivery;
  DateTime? _lastVaccination;
  String? _motherId;
  String? _fatherId;
  bool _motherFieldInitialized = false;
  bool _fatherFieldInitialized = false;
  String? _motherPrefillLabel;
  String? _fatherPrefillLabel;
  List<Animal> _availableMothers = [];
  List<Animal> _availableFathers = [];

  final List<String> _categories = [
    'Reprodutor',
    'Borrego',
    'Adulto',
    'Vazia',
    'Venda',
    'Não especificado',
  ];

  final List<String> _breeds = [
    'Hampshire Down',
    'Dorper',
    'Santa Inês',
    'Texel',
    'Suffolk',
    'Ile de France',
    'White Dorper',
    'Morada Nova',
    'Cariri',
    'Somalis Brasileira',
    'Outra',
  ];


  @override
  void initState() {
    super.initState();
    if (widget.animal != null) {
      _loadAnimalData();
    } else {
      // Pré-preencher campos quando vem do registro de nascimento
      if (widget.motherName != null) {
        _nameController.text = widget.motherName!;
        _motherPrefillLabel = _formatParentLabel(
          name: widget.motherName!,
          code: widget.motherCode,
          color: widget.motherColor,
        );
      }
      if (widget.motherColor != null) {
        _nameColor = widget.motherColor!;
      }
      if (widget.motherCode != null) {
        _codeController.text = widget.motherCode!;
      }
      if (widget.motherBreed != null) {
        _breedController.text = widget.motherBreed!;
      } else {
        _breedController.text = 'Hampshire Down'; // fallback
      }
      if (widget.motherId != null) {
        _motherId = widget.motherId;
      }
      if (widget.fatherId != null) {
        _fatherId = widget.fatherId;
        _fatherPrefillLabel = _formatParentLabel(
          name: widget.fatherName,
          code: widget.fatherCode,
          color: widget.fatherColor,
        );
      }
      if (widget.presetCategory != null) {
        _category = widget.presetCategory!;
      }
    }
    _loadAvailableMothers();
  }

  void _loadAvailableMothers() async {
    final animalService = Provider.of<AnimalService>(context, listen: false);
    final animals = await animalService.getAllAnimals();
    bool isEligible(
      Animal a, {
      required bool expectFemale,
    }) {
      final gender = a.gender.toLowerCase();
      final category = a.category.toLowerCase();
      final isBorrego = category.contains('borreg');
      if (isBorrego) return false;
      return expectFemale
          ? gender.contains('fêmea') || gender.contains('femea') || gender == 'f'
          : gender.contains('macho') || gender == 'm';
    }

    final mothers = animals.where((a) => isEligible(a, expectFemale: true)).toList();
    final fathers =
        animals.where((a) => isEligible(a, expectFemale: false)).toList();

    AnimalDisplayUtils.sortAnimalsList(mothers);
    AnimalDisplayUtils.sortAnimalsList(fathers);

    setState(() {
      _availableMothers = mothers;
      _availableFathers = fathers;
      _motherPrefillLabel ??= _labelFromParents(_motherId, mothers);
      _fatherPrefillLabel ??= _labelFromParents(_fatherId, fathers);
    });
  }

  void _loadAnimalData() {
    final animal = widget.animal!;
    _nameController.text = animal.name;
    _codeController.text = animal.code;
    _breedController.text = animal.breed;
    _weightController.text = animal.weight.toString();
    _locationController.text = animal.location;
    _yearController.text =
        animal.year?.toString() ?? animal.birthDate.year.toString();
    _loteController.text = animal.lote ?? '';
    _species = animal.species;
    _gender = animal.gender;
    _status = animal.status;
    _category = animal.category;
    _nameColor = animal.nameColor;
    _birthDate = animal.birthDate;
    _pregnant = animal.pregnant;
    _expectedDelivery = animal.expectedDelivery;
    _lastVaccination = animal.lastVaccination;
    _motherId = animal.motherId;
    _fatherId = animal.fatherId;
  }

  String? _formatParentLabel({
    String? name,
    String? code,
    String? color,
  }) {
    final normalizedName = name?.trim() ?? '';
    final normalizedCode = code?.trim() ?? '';

    if (normalizedName.isEmpty && normalizedCode.isEmpty) {
      return null;
    }

    final resolvedName =
        normalizedName.isEmpty ? 'Sem nome' : normalizedName;
    final resolvedCode =
        normalizedCode.isEmpty ? 'Sem código' : normalizedCode;
    final colorName = AnimalDisplayUtils.getColorName(color);

    return '$colorName - $resolvedName ($resolvedCode)';
  }

  String? _labelFromParents(String? parentId, List<Animal> parents) {
    if (parentId == null) return null;
    try {
      final parent = parents.firstWhere((animal) => animal.id == parentId);
      return _formatParentLabel(
        name: parent.name,
        code: parent.code,
        color: parent.nameColor,
      );
    } catch (_) {
      return null;
    }
  }

  void _seedParentField(
    TextEditingController controller, {
    required bool isMother,
  }) {
    final alreadyInitialized =
        isMother ? _motherFieldInitialized : _fatherFieldInitialized;
    final label =
        isMother ? _motherPrefillLabel : _fatherPrefillLabel;

    if (alreadyInitialized || label == null || label.isEmpty) {
      return;
    }

    controller.text = label;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    if (isMother) {
      _motherFieldInitialized = true;
    } else {
      _fatherFieldInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.animal == null ? 'Novo Animal' : 'Editar Animal'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome e Código
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome/Número *',
                          border: OutlineInputBorder(),
                          hintText: 'Ex: 18',
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _nameColor,
                        decoration: const InputDecoration(
                          labelText: 'Cor *',
                          border: OutlineInputBorder(),
                        ),
                        items: AnimalDisplayUtils.colorEntries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: entry.value,
                                    borderRadius: BorderRadius.circular(4),
                                    border: entry.key == 'white'
                                        ? Border.all(
                                            color: Colors.grey, width: 1)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    AnimalDisplayUtils.getColorName(entry.key),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _nameColor = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Código *',
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
                  ],
                ),
                const SizedBox(height: 16),
                // Ano e Lote
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(labelText: 'Ano *'),
                        keyboardType: TextInputType.number,
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
                      child: TextFormField(
                        controller: _loteController,
                        decoration: const InputDecoration(
                            labelText: 'Lote *', hintText: 'Ex: LT01'),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Seleção de mãe e pai (se for borrego)
                if (_category == 'Borrego')
                  Column(
                    children: [
                      Autocomplete<Animal>(
                        initialValue: TextEditingValue(
                          text: _motherPrefillLabel ??
                              _labelFromParents(
                                _motherId,
                                _availableMothers,
                              ) ??
                              '',
                        ),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _availableMothers;
                          }
                          final query = textEditingValue.text.toLowerCase();
                          return _availableMothers.where((mother) {
                            final name = mother.name.toLowerCase();
                            final code = mother.code.toLowerCase();
                            final colorName = AnimalDisplayUtils.getColorName(
                              mother.nameColor,
                            ).toLowerCase();
                            return name.contains(query) ||
                                code.contains(query) ||
                                colorName.contains(query);
                          });
                        },
                        displayStringForOption: (Animal option) =>
                            _formatParentLabel(
                              name: option.name,
                              code: option.code,
                              color: option.nameColor,
                            ) ??
                            option.name,
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          _seedParentField(
                            textEditingController,
                            isMother: true,
                          );
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Mãe',
                              border: OutlineInputBorder(),
                              hintText: 'Digite para buscar',
                              prefixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 260),
                                color: Colors.white,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final Animal option =
                                        options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                          horizontal: 12.0,
                                        ),
                                        child: AnimalDisplayUtils
                                            .buildDropdownItem(option),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        onSelected: (Animal mother) {
                          setState(() {
                            _motherId = mother.id;
                            _nameController.text = mother.name;
                            _nameColor = mother.nameColor;
                            _motherPrefillLabel = _formatParentLabel(
                              name: mother.name,
                              code: mother.code,
                              color: mother.nameColor,
                            );
                            _motherFieldInitialized = true;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Autocomplete<Animal>(
                        initialValue: TextEditingValue(
                          text: _fatherPrefillLabel ??
                              _labelFromParents(
                                _fatherId,
                                _availableFathers,
                              ) ??
                              '',
                        ),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _availableFathers;
                          }
                          final query = textEditingValue.text.toLowerCase();
                          return _availableFathers.where((father) {
                            final name = father.name.toLowerCase();
                            final code = father.code.toLowerCase();
                            final colorName = AnimalDisplayUtils.getColorName(
                              father.nameColor,
                            ).toLowerCase();
                            return name.contains(query) ||
                                code.contains(query) ||
                                colorName.contains(query);
                          });
                        },
                        displayStringForOption: (Animal option) =>
                            _formatParentLabel(
                              name: option.name,
                              code: option.code,
                              color: option.nameColor,
                            ) ??
                            option.name,
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          _seedParentField(
                            textEditingController,
                            isMother: false,
                          );
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Pai',
                              border: OutlineInputBorder(),
                              hintText: 'Digite para buscar',
                              prefixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 260),
                                color: Colors.white,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final Animal option =
                                        options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                          horizontal: 12.0,
                                        ),
                                        child: AnimalDisplayUtils
                                            .buildDropdownItem(option),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        onSelected: (Animal father) {
                          setState(() {
                            _fatherId = father.id;
                            _fatherPrefillLabel = _formatParentLabel(
                              name: father.name,
                              code: father.code,
                              color: father.nameColor,
                            );
                            _fatherFieldInitialized = true;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Categoria
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Espécie e Sexo
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _species,
                        decoration: const InputDecoration(
                          labelText: 'Espécie',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Ovino', 'Caprino'].map((species) {
                          return DropdownMenuItem(
                            value: species,
                            child: Text(species),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _species = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Sexo',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Macho', 'Fêmea'].map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _gender = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Raça
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _breeds.contains(_breedController.text)
                            ? _breedController.text
                            : 'Hampshire Down',
                        decoration: const InputDecoration(
                          labelText: 'Raça *',
                          border: OutlineInputBorder(),
                        ),
                        items: _breeds.map((breed) {
                          return DropdownMenuItem(
                            value: breed,
                            child: Text(breed),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value == 'Outra') {
                              _breedController.clear();
                            } else {
                              _breedController.text = value!;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Campo obrigatório';
                          }
                          if (double.tryParse(value!) == null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Campo de texto para raça personalizada
                if (!_breeds.contains(_breedController.text) ||
                    _breedController.text.isEmpty)
                  TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Raça *',
                      border: OutlineInputBorder(),
                      hintText: 'Digite o nome da raça',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Data de Nascimento
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      locale: const Locale('pt', 'BR'),
                      initialDate: _birthDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _birthDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Localização e Status
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Localização',
                          border: OutlineInputBorder(),
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
                        items: [
                          'Saudável',
                          'Em tratamento',
                          'Reprodutor',
                          'Vendido',
                          'Gestante'
                        ].map((status) {
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gestação
                if (_gender == 'Fêmea') ...[
                  CheckboxListTile(
                    title: const Text('Gestante'),
                    value: _pregnant,
                    onChanged: (value) {
                      setState(() {
                        _pregnant = value ?? false;
                        if (!_pregnant) {
                          _expectedDelivery = null;
                        }
                      });
                    },
                  ),
                  if (_pregnant) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          locale: const Locale('pt', 'BR'),
                          initialDate: _expectedDelivery ??
                              DateTime.now().add(const Duration(days: 150)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _expectedDelivery = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Previsão de Parto',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _expectedDelivery != null
                              ? '${_expectedDelivery!.day.toString().padLeft(2, '0')}/${_expectedDelivery!.month.toString().padLeft(2, '0')}/${_expectedDelivery!.year}'
                              : 'Selecionar data',
                        ),
                      ),
                    ),
                  ],
                ],
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
          onPressed: _saveAnimal,
          child: Text(widget.animal == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }

  void _saveAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    final animalService = Provider.of<AnimalService>(context, listen: false);

    final animal = Animal(
      id: widget.animal?.id ?? const Uuid().v4(),
      code: _codeController.text,
      name: _nameController.text,
      nameColor: _nameColor,
      category: _category,
      species: _species,
      breed: _breedController.text,
      gender: _gender,
      birthDate: _birthDate,
      weight: double.parse(_weightController.text),
      status: _status,
      location: _locationController.text,
      pregnant: _pregnant,
      expectedDelivery: _expectedDelivery,
      lastVaccination: _lastVaccination,
      year: int.tryParse(_yearController.text),
      lote: _loteController.text.isEmpty ? null : _loteController.text,
      motherId: _motherId,
      fatherId: _fatherId,
      createdAt: widget.animal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.animal == null) {
        await animalService.addAnimal(animal);
      } else {
        await animalService.updateAnimal(animal);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.animal == null
                  ? 'Animal criado com sucesso!'
                  : 'Animal atualizado com sucesso!',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar animal: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    _yearController.dispose();
    _loteController.dispose();
    super.dispose();
  }
}
