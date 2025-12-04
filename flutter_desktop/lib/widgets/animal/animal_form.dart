import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/animal.dart';
import '../../services/animal_service.dart';
import '../../utils/animal_display_utils.dart';
import '../../utils/responsive_utils.dart';
import 'animal_form_sections.dart';

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

  final List<String> _statusOptions = [
    'Saudável',
    'Em tratamento',
    'Reprodutor',
    'Vendido',
    'Gestante',
  ];

  static const List<String> _speciesOptions = ['Ovino', 'Caprino'];
  static const List<String> _genderOptions = ['Macho', 'Fêmea'];

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
          ? gender.contains('fêmea') ||
              gender.contains('femea') ||
              gender == 'f'
          : gender.contains('macho') || gender == 'm';
    }

    final mothers =
        animals.where((a) => isEligible(a, expectFemale: true)).toList();
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

    final resolvedName = normalizedName.isEmpty ? 'Sem nome' : normalizedName;
    final resolvedCode = normalizedCode.isEmpty ? 'Sem código' : normalizedCode;
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
    final label = isMother ? _motherPrefillLabel : _fatherPrefillLabel;

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

  Future<void> _selectBirthDate() async {
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
  }

  Future<void> _selectExpectedDeliveryDate() async {
    final date = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate:
          _expectedDelivery ?? DateTime.now().add(const Duration(days: 150)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _expectedDelivery = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final motherInitialText = _motherPrefillLabel ??
        _labelFromParents(_motherId, _availableMothers) ??
        '';
    final fatherInitialText = _fatherPrefillLabel ??
        _labelFromParents(_fatherId, _availableFathers) ??
        '';
    final showCustomBreedField = !_breeds.contains(_breedController.text) ||
        _breedController.text.isEmpty;
    final breedDropdownValue = _breeds.contains(_breedController.text)
        ? _breedController.text
        : 'Hampshire Down';
    final birthDateLabel =
        '${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.year}';
    final expectedDeliveryLabel = _expectedDelivery != null
        ? '${_expectedDelivery!.day.toString().padLeft(2, '0')}/${_expectedDelivery!.month.toString().padLeft(2, '0')}/${_expectedDelivery!.year}'
        : 'Selecionar data';

    return AlertDialog(
      title: Text(widget.animal == null ? 'Novo Animal' : 'Editar Animal'),
      content: SizedBox(
        width: ResponsiveUtils.getDialogWidth(context),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimalBasicInfoSection(
                  nameController: _nameController,
                  codeController: _codeController,
                  yearController: _yearController,
                  loteController: _loteController,
                  selectedColor: _nameColor,
                  onColorChanged: (value) {
                    if (value == null) return;
                    setState(() => _nameColor = value);
                  },
                ),
                const SizedBox(height: 16),
                if (_category == 'Borrego') ...[
                  AnimalOriginSection(
                    availableMothers: _availableMothers,
                    availableFathers: _availableFathers,
                    motherInitialText: motherInitialText,
                    fatherInitialText: fatherInitialText,
                    seedParentField: _seedParentField,
                    formatParentLabel: _formatParentLabel,
                    onMotherSelected: (mother) {
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
                    onFatherSelected: (father) {
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
                AnimalCategorySection(
                  category: _category,
                  categories: _categories,
                  onCategoryChanged: (value) {
                    if (value == null) return;
                    setState(() => _category = value);
                  },
                  species: _species,
                  speciesOptions: _speciesOptions,
                  onSpeciesChanged: (value) {
                    if (value == null) return;
                    setState(() => _species = value);
                  },
                  gender: _gender,
                  genderOptions: _genderOptions,
                  onGenderChanged: (value) {
                    if (value == null) return;
                    setState(() => _gender = value);
                  },
                  breedController: _breedController,
                  breedOptions: _breeds,
                  breedDropdownValue: breedDropdownValue,
                  onBreedChanged: (value) {
                    setState(() {
                      if (value == 'Outra') {
                        _breedController.clear();
                      } else if (value != null) {
                        _breedController.text = value;
                      }
                    });
                  },
                  showCustomBreedField: showCustomBreedField,
                  weightController: _weightController,
                  birthDateLabel: birthDateLabel,
                  onBirthDateTap: () => _selectBirthDate(),
                ),
                const SizedBox(height: 16),
                AnimalNotesSection(
                  locationController: _locationController,
                  status: _status,
                  statusOptions: _statusOptions,
                  onStatusChanged: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
                ),
                if (_gender == 'Fêmea') ...[
                  const SizedBox(height: 16),
                  AnimalReproductionSection(
                    pregnant: _pregnant,
                    expectedDeliveryLabel: expectedDeliveryLabel,
                    onPregnantChanged: (value) {
                      setState(() {
                        _pregnant = value ?? false;
                        if (!_pregnant) {
                          _expectedDelivery = null;
                        }
                      });
                    },
                    onExpectedDeliveryTap: () => _selectExpectedDeliveryDate(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: ResponsiveUtils.isMobile(context) 
        ? [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _saveAnimal,
                  child: Text(widget.animal == null ? 'Criar' : 'Salvar'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ]
        : [
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
