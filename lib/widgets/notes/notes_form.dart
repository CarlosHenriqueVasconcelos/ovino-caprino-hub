import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/animal.dart';
import '../../services/animal_service.dart';
import '../../services/note_service.dart';
import '../../utils/animal_display_utils.dart';
import '../../utils/responsive_utils.dart';

class NotesFormDialog extends StatefulWidget {
  final String? animalId;

  const NotesFormDialog({super.key, this.animalId});

  @override
  State<NotesFormDialog> createState() => _NotesFormDialogState();
}

class _NotesFormDialogState extends State<NotesFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _createdByController = TextEditingController();
  String _animalFieldText = '';

  String? _selectedAnimalId;
  String _category = 'Geral';
  String _priority = 'Média';
  DateTime _date = DateTime.now();
  List<Animal> _animalOptions = [];
  bool _loadingAnimals = true;
  Animal? _linkedAnimal;
  Animal? _selectedAnimal;

  @override
  void initState() {
    super.initState();
    _selectedAnimalId = widget.animalId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final animalService = context.read<AnimalService>();
    if (widget.animalId != null) {
      final animal = await animalService.getAnimalById(widget.animalId!);
      if (animal != null) {
        _linkedAnimal = animal;
        _selectedAnimal = animal;
        _animalFieldText = AnimalDisplayUtils.getDisplayText(animal);
      }
    }
    await _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    try {
      final animalService = context.read<AnimalService>();
      final animals = await animalService.searchAnimals(limit: 2000);
      AnimalDisplayUtils.sortAnimalsList(animals);
      if (!mounted) return;
      setState(() {
        _animalOptions = animals;
        _loadingAnimals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAnimals = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final optionsWidth = isMobile ? screenWidth * 0.9 : 520.0;
    return AlertDialog(
      title: const Text('Nova Anotação'),
      content: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: 520,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Seleção de animal (quando não vier fixo)
                  if (widget.animalId == null) ...[
                    Autocomplete<Animal>(
                      optionsBuilder: (textEditingValue) {
                        if (_loadingAnimals) return const Iterable<Animal>.empty();
                        return AnimalDisplayUtils.filterAndRankAnimals(
                          _animalOptions,
                          textEditingValue.text,
                        );
                      },
                      displayStringForOption: AnimalDisplayUtils.getDisplayText,
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) {
                        if (controller.text != _animalFieldText) {
                          controller.text = _animalFieldText;
                          controller.selection = TextSelection.collapsed(
                            offset: controller.text.length,
                          );
                        }
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Animal (opcional)',
                            border: const OutlineInputBorder(),
                            hintText: 'Digite nome ou código',
                            prefixIcon: _selectedAnimal != null
                                ? Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: AnimalDisplayUtils.getColorValue(
                                          _selectedAnimal!.nameColor,
                                        ),
                                        shape: BoxShape.circle,
                                        border: _selectedAnimal!.nameColor == 'white'
                                            ? Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              )
                                            : null,
                                      ),
                                    ),
                                  )
                                : null,
                            suffixIcon: _selectedAnimalId != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _selectedAnimalId = null;
                                        _animalFieldText = '';
                                        _selectedAnimal = null;
                                      });
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
                            elevation: 4,
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 240),
                              width: optionsWidth,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final Animal animal = options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(animal),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 12,
                                      ),
                                      child: AnimalDisplayUtils.buildDropdownItem(
                                        animal,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                          onSelected: (Animal animal) {
                            setState(() {
                              _selectedAnimalId = animal.id;
                              _animalFieldText =
                                  AnimalDisplayUtils.getDisplayText(animal);
                              _selectedAnimal = animal;
                            });
                          },
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // Quando vier animalId, só mostra info do animal
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Animal vinculado',
                          border: OutlineInputBorder(),
                        ),
                        child: _linkedAnimal == null
                            ? const Text('Animal não encontrado')
                            : Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AnimalDisplayUtils.getColorValue(
                                        _linkedAnimal!.nameColor,
                                      ),
                                      shape: BoxShape.circle,
                                      border: _linkedAnimal!.nameColor == 'white'
                                          ? Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AnimalDisplayUtils.getDisplayText(
                                        _linkedAnimal!,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe um título para a anotação';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Categoria + Prioridade
                  if (isMobile) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        'Geral',
                        'Saúde',
                        'Reprodução',
                        'Vacinação',
                        'Alimentação',
                        'Manejo',
                        'Financeiro',
                        'Veterinário',
                      ].map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _category = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _priority,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Prioridade',
                        border: OutlineInputBorder(),
                      ),
                      items: const ['Baixa', 'Média', 'Alta'].map((p) {
                        IconData icon;
                        Color color;
                        switch (p) {
                          case 'Baixa':
                            icon = Icons.arrow_downward;
                            color = Colors.green;
                            break;
                          case 'Alta':
                            icon = Icons.arrow_upward;
                            color = Colors.red;
                            break;
                          default:
                            icon = Icons.drag_handle;
                            color = Colors.orange;
                        }
                        return DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: color),
                              const SizedBox(width: 6),
                              Text(p),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _priority = value);
                      },
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _category,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Categoria',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              'Geral',
                              'Saúde',
                              'Reprodução',
                              'Vacinação',
                              'Alimentação',
                              'Manejo',
                              'Financeiro',
                              'Veterinário',
                            ].map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(c, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _category = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _priority,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Prioridade',
                              border: OutlineInputBorder(),
                            ),
                            items: const ['Baixa', 'Média', 'Alta'].map((p) {
                              IconData icon;
                              Color color;
                              switch (p) {
                                case 'Baixa':
                                  icon = Icons.arrow_downward;
                                  color = Colors.green;
                                  break;
                                case 'Alta':
                                  icon = Icons.arrow_upward;
                                  color = Colors.red;
                                  break;
                                default:
                                  icon = Icons.drag_handle;
                                  color = Colors.orange;
                              }
                              return DropdownMenuItem(
                                value: p,
                                child: Row(
                                  children: [
                                    Icon(icon, size: 18, color: color),
                                    const SizedBox(width: 6),
                                    Text(p),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _priority = value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Data
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _date = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_date.day.toString().padLeft(2, '0')}/'
                            '${_date.month.toString().padLeft(2, '0')}/'
                            '${_date.year}',
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conteúdo
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição / Detalhes',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),

                  // Criado por
                  TextFormField(
                    controller: _createdByController,
                    decoration: const InputDecoration(
                      labelText: 'Criado por (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveNote,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final noteService = context.read<NoteService>();

      final now = DateTime.now();
      final String isoDate = _date.toIso8601String().split('T')[0];

      final note = <String, dynamic>{
        'id': const Uuid().v4(),
        'animal_id': _selectedAnimalId,
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim().isEmpty
            ? null
            : _contentController.text.trim(),
        'category': _category,
        'priority': _priority,
        'date': isoDate,
        'created_by': _createdByController.text.trim().isEmpty
            ? null
            : _createdByController.text.trim(),
        // is_read, created_at e updated_at são tratados pelo NoteRepository/DB
        'created_at': now.toIso8601String(),
      };

      await noteService.createNote(note);

      if (!mounted) return;

      // avisa sucesso e fecha retornando true para a tela recarregar a lista
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação criada com sucesso!'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar anotação: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _createdByController.dispose();
    super.dispose();
  }
}
