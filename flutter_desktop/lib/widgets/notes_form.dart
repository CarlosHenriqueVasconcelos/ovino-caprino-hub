import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/animal.dart';
import '../services/animal_service.dart';
import '../services/note_service.dart';
import '../utils/animal_display_utils.dart';

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
  Timer? _animalDebounce;
  Animal? _linkedAnimal;

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
        _animalFieldText = '${animal.code} - ${animal.name}';
      }
    }
    await _loadAnimals();
  }

  Future<void> _loadAnimals([String query = '']) async {
    try {
      final animalService = context.read<AnimalService>();
      final animals =
          await animalService.searchAnimals(searchQuery: query, limit: 50);
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

  void _scheduleAnimalSearch(String query) {
    _animalDebounce?.cancel();
    _animalDebounce = Timer(const Duration(milliseconds: 250), () {
      _loadAnimals(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Anotação'),
      content: SingleChildScrollView(
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
                      _scheduleAnimalSearch(textEditingValue.text);
                      if (_loadingAnimals) return const Iterable<Animal>.empty();
                      final query = textEditingValue.text.toLowerCase();
                      return _animalOptions.where((animal) {
                        final name = animal.name.toLowerCase();
                        final code = animal.code.toLowerCase();
                        return name.contains(query) || code.contains(query);
                      });
                    },
                    displayStringForOption: (Animal option) =>
                        '${option.code} - ${option.name}',
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
                          suffixIcon: _selectedAnimalId != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _selectedAnimalId = null;
                                      _animalFieldText = '';
                                    });
                                    controller.clear();
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                    onSelected: (Animal animal) {
                      setState(() {
                        _selectedAnimalId = animal.id;
                        _animalFieldText = '${animal.code} - ${animal.name}';
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
                      child: Text(
                        _linkedAnimal != null
                            ? '${_linkedAnimal!.code} - ${_linkedAnimal!.name}'
                            : 'Animal não encontrado',
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
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
                            child: Text(c),
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
                        value: _priority,
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
    _animalDebounce?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _createdByController.dispose();
    super.dispose();
  }
}
