import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../services/animal_service.dart';
import '../../utils/animal_display_utils.dart';

class AnimalBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController yearController;
  final TextEditingController loteController;
  final String selectedColor;
  final ValueChanged<String?> onColorChanged;

  const AnimalBasicInfoSection({
    super.key,
    required this.nameController,
    required this.codeController,
    required this.yearController,
    required this.loteController,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      children: [
        if (isMobile) ...[
          // Mobile: Stack vertically
          TextFormField(
            controller: nameController,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedColor,
                  isExpanded: true,
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
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: entry.value,
                              borderRadius: BorderRadius.circular(4),
                              border: entry.key == 'white'
                                  ? Border.all(color: Colors.grey, width: 1)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              AnimalDisplayUtils.getColorName(entry.key),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onColorChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: codeController,
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
        ] else ...[
          // Desktop: Row layout
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: nameController,
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
                  initialValue: selectedColor,
                  isExpanded: true,
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
                                  ? Border.all(color: Colors.grey, width: 1)
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
                  onChanged: onColorChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: codeController,
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
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: yearController,
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
                controller: loteController,
                decoration: const InputDecoration(
                  labelText: 'Lote *',
                  hintText: 'Ex: LT01',
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
      ],
    );
  }
}

class AnimalOriginSection extends StatelessWidget {
  final String motherInitialText;
  final String fatherInitialText;
  final void Function(TextEditingController controller,
      {required bool isMother}) seedParentField;
  final ValueChanged<Animal> onMotherSelected;
  final ValueChanged<Animal> onFatherSelected;
  final String? Function({
    String? name,
    String? code,
    String? color,
  }) formatParentLabel;

  const AnimalOriginSection({
    super.key,
    required this.motherInitialText,
    required this.fatherInitialText,
    required this.seedParentField,
    required this.onMotherSelected,
    required this.onFatherSelected,
    required this.formatParentLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ParentAutocomplete(
          label: 'Mãe',
          isMother: true,
          initialText: motherInitialText,
          seedField: (controller) =>
              seedParentField(controller, isMother: true),
          formatParentLabel: formatParentLabel,
          onSelected: onMotherSelected,
        ),
        const SizedBox(height: 16),
        _ParentAutocomplete(
          label: 'Pai',
          isMother: false,
          initialText: fatherInitialText,
          seedField: (controller) =>
              seedParentField(controller, isMother: false),
          formatParentLabel: formatParentLabel,
          onSelected: onFatherSelected,
        ),
      ],
    );
  }
}

class _ParentAutocomplete extends StatefulWidget {
  final String label;
  final bool isMother;
  final String initialText;
  final ValueChanged<TextEditingController> seedField;
  final String? Function({
    String? name,
    String? code,
    String? color,
  }) formatParentLabel;
  final ValueChanged<Animal> onSelected;

  const _ParentAutocomplete({
    required this.label,
    required this.isMother,
    required this.initialText,
    required this.seedField,
    required this.formatParentLabel,
    required this.onSelected,
  });

  @override
  State<_ParentAutocomplete> createState() => _ParentAutocompleteState();
}

class _ParentAutocompleteState extends State<_ParentAutocomplete> {
  static const _debounceDuration = Duration(milliseconds: 250);
  static const _pageLimit = 50;
  static const _excludeCategories = ['Borrego'];

  final List<Animal> _options = [];
  bool _isLoading = false;
  Timer? _debounce;
  int _requestId = 0;
  String _currentQuery = '';
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchOptions('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller?.removeListener(_handleQueryChanged);
    super.dispose();
  }

  void _attachController(TextEditingController controller) {
    if (_controller != controller) {
      _controller?.removeListener(_handleQueryChanged);
      _controller = controller;
    }
    _controller?.removeListener(_handleQueryChanged);
    widget.seedField(controller);
    _currentQuery = controller.text;
    _controller?.addListener(_handleQueryChanged);
  }

  void _handleQueryChanged() {
    final query = _controller?.text ?? '';
    if (query == _currentQuery) return;
    _currentQuery = query;
    _debounce?.cancel();
    setState(() {
      _isLoading = true;
      _options.clear();
    });
    final requestId = ++_requestId;
    _debounce = Timer(_debounceDuration, () async {
      try {
        final animals = await _searchAnimals(query);
        if (!mounted || requestId != _requestId) return;
        setState(() {
          _options
            ..clear()
            ..addAll(animals);
          _isLoading = false;
        });
      } catch (_) {
        if (!mounted || requestId != _requestId) return;
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _fetchOptions(String query) async {
    final requestId = ++_requestId;
    try {
      final animals = await _searchAnimals(query);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _options
          ..clear()
          ..addAll(animals);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _isLoading = false);
    }
  }

  Future<List<Animal>> _searchAnimals(String query) async {
    final animalService = context.read<AnimalService>();
    final animals = await animalService.searchAnimals(
      gender: widget.isMother ? 'Fêmea' : 'Macho',
      excludeCategories: _excludeCategories,
      searchQuery: query.trim().isEmpty ? null : query.trim(),
      limit: _pageLimit,
    );
    AnimalDisplayUtils.sortAnimalsList(animals);
    return animals;
  }

  @override
  Widget build(BuildContext context) {
    final showStatus =
        _isLoading || (_currentQuery.isNotEmpty && _options.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<Animal>(
          initialValue: TextEditingValue(text: widget.initialText),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (_isLoading) return const Iterable<Animal>.empty();
            return _options;
          },
          displayStringForOption: (Animal option) =>
              widget.formatParentLabel(
                name: option.name,
                code: option.code,
                color: option.nameColor,
              ) ??
              option.name,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            _attachController(textEditingController);
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
                hintText: 'Digite para buscar',
                prefixIcon: const Icon(Icons.search),
              ),
            );
          },
          optionsViewBuilder: (context, onOptionSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  color: Colors.white,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final Animal option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onOptionSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          child: AnimalDisplayUtils.buildDropdownItem(option),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: widget.onSelected,
        ),
        if (showStatus)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              _isLoading ? 'Carregando...' : 'Nenhum resultado',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class AnimalCategorySection extends StatelessWidget {
  final String category;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final String species;
  final List<String> speciesOptions;
  final ValueChanged<String?> onSpeciesChanged;
  final String gender;
  final List<String> genderOptions;
  final ValueChanged<String?> onGenderChanged;
  final TextEditingController breedController;
  final List<String> breedOptions;
  final String breedDropdownValue;
  final ValueChanged<String?> onBreedChanged;
  final bool showCustomBreedField;
  final TextEditingController weightController;
  final String birthDateLabel;
  final VoidCallback onBirthDateTap;

  const AnimalCategorySection({
    super.key,
    required this.category,
    required this.categories,
    required this.onCategoryChanged,
    required this.species,
    required this.speciesOptions,
    required this.onSpeciesChanged,
    required this.gender,
    required this.genderOptions,
    required this.onGenderChanged,
    required this.breedController,
    required this.breedOptions,
    required this.breedDropdownValue,
    required this.onBreedChanged,
    required this.showCustomBreedField,
    required this.weightController,
    required this.birthDateLabel,
    required this.onBirthDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: category,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Categoria *',
            border: OutlineInputBorder(),
          ),
          items: categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 16),
        if (isMobile) ...[
          // Mobile: Stack vertically
          DropdownButtonFormField<String>(
            initialValue: species,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Espécie',
              border: OutlineInputBorder(),
            ),
            items: speciesOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
            onChanged: onSpeciesChanged,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: gender,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Sexo',
              border: OutlineInputBorder(),
            ),
            items: genderOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
            onChanged: onGenderChanged,
          ),
        ] else ...[
          // Desktop: Row layout
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: species,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Espécie',
                    border: OutlineInputBorder(),
                  ),
                  items: speciesOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: onSpeciesChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: gender,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Sexo',
                    border: OutlineInputBorder(),
                  ),
                  items: genderOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: onGenderChanged,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (isMobile) ...[
          // Mobile: Stack vertically
          DropdownButtonFormField<String>(
            initialValue: breedDropdownValue,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Raça *',
              border: OutlineInputBorder(),
            ),
            items: breedOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onBreedChanged,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: weightController,
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
        ] else ...[
          // Desktop: Row layout
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: breedDropdownValue,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Raça *',
                    border: OutlineInputBorder(),
                  ),
                  items: breedOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: onBreedChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: weightController,
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
        ],
        if (showCustomBreedField) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: breedController,
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
        ],
        const SizedBox(height: 16),
        InkWell(
          onTap: onBirthDateTap,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Data de Nascimento',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(birthDateLabel),
          ),
        ),
      ],
    );
  }
}

class AnimalNotesSection extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController registrationNoteController;
  final String status;
  final List<String> statusOptions;
  final ValueChanged<String?> onStatusChanged;

  const AnimalNotesSection({
    super.key,
    required this.locationController,
    required this.registrationNoteController,
    required this.status,
    required this.statusOptions,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      return Column(
        children: [
          TextFormField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: 'Localização',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: status,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: statusOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: registrationNoteController,
            decoration: const InputDecoration(
              labelText: 'Anotação Cadastral (opcional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              hintText: 'Informações de perfil/ficha do animal',
            ),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Localização',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: status,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: statusOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: onStatusChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: registrationNoteController,
          decoration: const InputDecoration(
            labelText: 'Anotação Cadastral (opcional)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            hintText: 'Informações de perfil/ficha do animal',
          ),
          minLines: 2,
          maxLines: 4,
        ),
      ],
    );
  }
}

class AnimalReproductionSection extends StatelessWidget {
  final String reproductiveStatus;
  final List<String> reproductiveStatusOptions;
  final ValueChanged<String?> onReproductiveStatusChanged;
  final bool pregnant;
  final ValueChanged<bool?> onPregnantChanged;
  final String expectedDeliveryLabel;
  final VoidCallback onExpectedDeliveryTap;

  const AnimalReproductionSection({
    super.key,
    required this.reproductiveStatus,
    required this.reproductiveStatusOptions,
    required this.onReproductiveStatusChanged,
    required this.pregnant,
    required this.onPregnantChanged,
    required this.expectedDeliveryLabel,
    required this.onExpectedDeliveryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: reproductiveStatus,
          decoration: const InputDecoration(
            labelText: 'Status Reprodutivo',
            border: OutlineInputBorder(),
          ),
          items: reproductiveStatusOptions
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onReproductiveStatusChanged,
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('Gestante'),
          value: pregnant,
          onChanged: onPregnantChanged,
        ),
        if (pregnant) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: onExpectedDeliveryTap,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Previsão de Parto',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(expectedDeliveryLabel),
            ),
          ),
        ],
      ],
    );
  }
}
