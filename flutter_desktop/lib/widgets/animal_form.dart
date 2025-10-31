import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';

class AnimalFormDialog extends StatefulWidget {
  final Animal? animal;
  final String? motherId;
  final String? motherCode;
  final String? motherBreed;
  final String? presetCategory;
  
  const AnimalFormDialog({
    super.key, 
    this.animal,
    this.motherId,
    this.motherCode,
    this.motherBreed,
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

  final Map<String, Color> _colorOptions = {
    'blue': Colors.blue,
    'red': Colors.red,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'brown': Colors.brown,
  };

  @override
  void initState() {
    super.initState();
    print('🐑 DEBUG AnimalForm initState - motherId: ${widget.motherId}, motherCode: ${widget.motherCode}, motherBreed: ${widget.motherBreed}, presetCategory: ${widget.presetCategory}');
    
    if (widget.animal != null) {
      _loadAnimalData();
    } else {
      // Pré-preencher campos quando vem do registro de nascimento
      if (widget.motherCode != null) {
        _codeController.text = widget.motherCode!;
        print('🐑 DEBUG: Code preenchido com ${widget.motherCode}');
      }
      if (widget.motherBreed != null) {
        _breedController.text = widget.motherBreed!;
        print('🐑 DEBUG: Breed preenchido com ${widget.motherBreed}');
      } else {
        _breedController.text = 'Hampshire Down'; // fallback
      }
      if (widget.motherId != null) {
        _motherId = widget.motherId;
        print('🐑 DEBUG: Mother ID definido como ${widget.motherId}');
      }
      if (widget.presetCategory != null) {
        _category = widget.presetCategory!;
        print('🐑 DEBUG: Category definida como ${widget.presetCategory}');
      }
    }
    _loadAvailableMothers();
  }

  void _loadAvailableMothers() async {
    final animalService = Provider.of<AnimalService>(context, listen: false);
    final animals = await animalService.getAllAnimals();
    setState(() {
      _availableMothers = animals.where((a) => 
        a.gender == 'Fêmea' && 
        a.category != 'Borrego' &&
        a.category != 'Venda'
      ).toList();
      _availableFathers = animals.where((a) => 
        a.gender == 'Macho' && 
        a.category != 'Borrego' &&
        a.category != 'Venda'
      ).toList();
    });
  }

  void _loadAnimalData() {
    final animal = widget.animal!;
    _nameController.text = animal.name;
    _codeController.text = animal.code;
    _breedController.text = animal.breed;
    _weightController.text = animal.weight.toString();
    _locationController.text = animal.location;
    _yearController.text = animal.year?.toString() ?? animal.birthDate.year.toString();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                        items: _colorOptions.entries.map((entry) {
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
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    entry.key,
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
                        decoration: const InputDecoration(labelText: 'Lote *', hintText: 'Ex: LT01'),
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
                      DropdownButtonFormField<String>(
                        value: _availableMothers.any((m) => m.id == _motherId) ? _motherId : null,
                        decoration: const InputDecoration(
                          labelText: 'Mãe',
                          border: OutlineInputBorder(),
                          hintText: 'Selecione a mãe',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Nenhuma'),
                          ),
                          ..._availableMothers.map((mother) {
                            return DropdownMenuItem(
                              value: mother.id,
                              child: Text('${mother.name} (${mother.code})'),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _motherId = value;
                            // Auto-preencher nome e cor da mãe
                            if (value != null) {
                              final mother = _availableMothers.firstWhere((m) => m.id == value);
                              _nameController.text = mother.name;
                              _nameColor = mother.nameColor;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _availableFathers.any((f) => f.id == _fatherId) ? _fatherId : null,
                        decoration: const InputDecoration(
                          labelText: 'Pai',
                          border: OutlineInputBorder(),
                          hintText: 'Selecione o pai',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Nenhum'),
                          ),
                          ..._availableFathers.map((father) {
                            return DropdownMenuItem(
                              value: father.id,
                              child: Text('${father.name} (${father.code})'),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _fatherId = value;
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
                if (!_breeds.contains(_breedController.text) || _breedController.text.isEmpty)
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
                        items: ['Saudável', 'Em tratamento', 'Reprodutor', 'Vendido', 'Gestante']
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
                          initialDate: _expectedDelivery ?? DateTime.now().add(const Duration(days: 150)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
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