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
  final _femaleSearchController = TextEditingController();
  final _maleSearchController = TextEditingController();

  List<Animal> _females = [];
  List<Animal> _males = [];
  List<Animal> _filteredFemales = [];
  List<Animal> _filteredMales = [];
  bool _isLoading = true;

  String? _selectedFemaleId;
  String? _selectedMaleId;
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
        _filteredFemales = females;
        _filteredMales = males;
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

  void _filterFemales(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFemales = _females;
      } else {
        _filteredFemales = _females.where((animal) {
          return animal.code.toLowerCase().contains(query.toLowerCase()) ||
                 animal.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterMales(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMales = _males;
      } else {
        _filteredMales = _males.where((animal) {
          return animal.code.toLowerCase().contains(query.toLowerCase()) ||
                 animal.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _femaleSearchController.dispose();
    _maleSearchController.dispose();
    super.dispose();
  }

  void _calculateMatingEndDate() {
    setState(() {
      _matingEndDate = _matingStartDate.add(const Duration(days: 60));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFemaleId == null || _selectedMaleId == null) {
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
        'female_animal_id': _selectedFemaleId,
        'male_animal_id': _selectedMaleId,
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

                      // Female Selection with Search
                      TextField(
                        controller: _femaleSearchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar Fêmea',
                          hintText: 'Digite o número ou nome',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _filterFemales,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _filteredFemales.any((a) => a.id == _selectedFemaleId) 
                            ? _selectedFemaleId 
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Fêmea *',
                          prefixIcon: Icon(Icons.female),
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        menuMaxHeight: 300,
                        items: _filteredFemales.map((animal) {
                          final color = animal.nameColor ?? 'Sem cor';
                          return DropdownMenuItem(
                            value: animal.id,
                            child: Text('$color - ${animal.code} - ${animal.name}'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedFemaleId = value),
                        validator: (value) => value == null ? 'Selecione uma fêmea' : null,
                      ),
                      const SizedBox(height: 16),

                      // Male Selection with Search
                      TextField(
                        controller: _maleSearchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar Macho',
                          hintText: 'Digite o número ou nome',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _filterMales,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _filteredMales.any((a) => a.id == _selectedMaleId) 
                            ? _selectedMaleId 
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Macho *',
                          prefixIcon: Icon(Icons.male),
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        menuMaxHeight: 300,
                        items: _filteredMales.map((animal) {
                          final color = animal.nameColor ?? 'Sem cor';
                          return DropdownMenuItem(
                            value: animal.id,
                            child: Text('$color - ${animal.code} - ${animal.name}'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedMaleId = value),
                        validator: (value) => value == null ? 'Selecione um macho' : null,
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
