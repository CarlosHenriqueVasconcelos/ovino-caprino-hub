import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../utils/animal_display_utils.dart';

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
    return Column(
      children: [
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
                value: selectedColor,
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
  final List<Animal> availableMothers;
  final List<Animal> availableFathers;
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
    required this.availableMothers,
    required this.availableFathers,
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
          initialText: motherInitialText,
          animals: availableMothers,
          seedField: (controller) =>
              seedParentField(controller, isMother: true),
          formatParentLabel: formatParentLabel,
          onSelected: onMotherSelected,
        ),
        const SizedBox(height: 16),
        _ParentAutocomplete(
          label: 'Pai',
          initialText: fatherInitialText,
          animals: availableFathers,
          seedField: (controller) =>
              seedParentField(controller, isMother: false),
          formatParentLabel: formatParentLabel,
          onSelected: onFatherSelected,
        ),
      ],
    );
  }
}

class _ParentAutocomplete extends StatelessWidget {
  final String label;
  final String initialText;
  final List<Animal> animals;
  final ValueChanged<TextEditingController> seedField;
  final String? Function({
    String? name,
    String? code,
    String? color,
  }) formatParentLabel;
  final ValueChanged<Animal> onSelected;

  const _ParentAutocomplete({
    required this.label,
    required this.initialText,
    required this.animals,
    required this.seedField,
    required this.formatParentLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Animal>(
      initialValue: TextEditingValue(text: initialText),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return animals;
        }
        final query = textEditingValue.text.toLowerCase();
        return animals.where((animal) {
          final name = animal.name.toLowerCase();
          final code = animal.code.toLowerCase();
          final colorName = AnimalDisplayUtils.getColorName(
            animal.nameColor,
          ).toLowerCase();
          return name.contains(query) ||
              code.contains(query) ||
              colorName.contains(query);
        });
      },
      displayStringForOption: (Animal option) =>
          formatParentLabel(
            name: option.name,
            code: option.code,
            color: option.nameColor,
          ) ??
          option.name,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        seedField(textEditingController);
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
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
      onSelected: onSelected,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: category,
          decoration: const InputDecoration(
            labelText: 'Categoria *',
            border: OutlineInputBorder(),
          ),
          items: categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: species,
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
                value: gender,
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: breedDropdownValue,
                decoration: const InputDecoration(
                  labelText: 'Raça *',
                  border: OutlineInputBorder(),
                ),
                items: breedOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
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
  final String status;
  final List<String> statusOptions;
  final ValueChanged<String?> onStatusChanged;

  const AnimalNotesSection({
    super.key,
    required this.locationController,
    required this.status,
    required this.statusOptions,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            value: status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: statusOptions
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
            onChanged: onStatusChanged,
          ),
        ),
      ],
    );
  }
}

class AnimalReproductionSection extends StatelessWidget {
  final bool pregnant;
  final ValueChanged<bool?> onPregnantChanged;
  final String expectedDeliveryLabel;
  final VoidCallback onExpectedDeliveryTap;

  const AnimalReproductionSection({
    super.key,
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
