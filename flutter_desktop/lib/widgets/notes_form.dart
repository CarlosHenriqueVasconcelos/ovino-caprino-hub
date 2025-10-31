import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/animal_service.dart';
import '../services/database_service.dart';
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
  
  String? _selectedAnimalId;
  String _category = 'Geral';
  String _priority = 'Média';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedAnimalId = widget.animalId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = Provider.of<AnimalService>(context);
    
    return AlertDialog(
      title: const Text('Nova Anotação'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animal Selection (if not specific animal)
                if (widget.animalId == null) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedAnimalId,
                    decoration: const InputDecoration(
                      labelText: 'Animal (Opcional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Anotação geral'),
                      ),
                      ...animalService.animals.map((animal) {
                        return DropdownMenuItem(
                          value: animal.id,
                          child: AnimalDisplayUtils.buildAnimalDropdownItem(animal),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAnimalId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Category and Priority
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Geral',
                          'Saúde',
                          'Reprodução', 
                          'Vacinação',
                          'Alimentação',
                          'Manejo',
                          'Financeiro',
                          'Veterinário',
                        ].map((category) {
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
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Prioridade',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Baixa', 'Média', 'Alta'].map((priority) {
                          Color color;
                          IconData icon;
                          switch (priority) {
                            case 'Alta':
                              color = theme.colorScheme.error;
                              icon = Icons.priority_high;
                              break;
                            case 'Média':
                              color = theme.colorScheme.tertiary;
                              icon = Icons.remove;
                              break;
                            default:
                              color = theme.colorScheme.primary;
                              icon = Icons.low_priority;
                          }
                          
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Icon(icon, color: color, size: 16),
                                const SizedBox(width: 8),
                                Text(priority),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _priority = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Date
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _date = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Content
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                
                // Created By
                TextFormField(
                  controller: _createdByController,
                  decoration: const InputDecoration(
                    labelText: 'Criado por',
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveNote,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final note = {
        'id': const Uuid().v4(),
        'animal_id': _selectedAnimalId,
        'title': _titleController.text,
        'content': _contentController.text.isEmpty ? null : _contentController.text,
        'category': _category,
        'priority': _priority,
        'date': _date.toIso8601String().split('T')[0],
        'created_by': _createdByController.text.isEmpty ? null : _createdByController.text,
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      await DatabaseService.createNote(note);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Anotação criada com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar anotação: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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