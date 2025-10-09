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
      setState(() {
        _females = animals.where((a) => a.gender == 'Fêmea').toList();
        _males = animals.where((a) => a.gender == 'Macho').toList();
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
      final expectedBirth = _matingStartDate.add(const Duration(days: 210)); // 60 dias + 150 dias (5 meses)
      
      await DatabaseService.createBreedingRecord({
        'female_animal_id': _selectedFemaleId,
        'male_animal_id': _selectedMaleId,
        'breeding_date': _matingStartDate.toIso8601String(),
        'mating_start_date': _matingStartDate.toIso8601String(),
        'mating_end_date': _matingEndDate?.toIso8601String(),
        'expected_birth': expectedBirth.toIso8601String(),
        'stage': BreedingStage.encabritamento.value,
        'status': 'Cobertura',
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
                      
                      // Female Selection
                      DropdownButtonFormField<String>(
                        value: _selectedFemaleId,
                        decoration: const InputDecoration(
                          labelText: 'Fêmea *',
                          prefixIcon: Icon(Icons.female),
                          border: OutlineInputBorder(),
                        ),
                        items: _females.map((animal) {
                          return DropdownMenuItem(
                            value: animal.id,
                            child: Text('${animal.code} - ${animal.name}'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedFemaleId = value),
                        validator: (value) => value == null ? 'Selecione uma fêmea' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Male Selection
                      DropdownButtonFormField<String>(
                        value: _selectedMaleId,
                        decoration: const InputDecoration(
                          labelText: 'Macho *',
                          prefixIcon: Icon(Icons.male),
                          border: OutlineInputBorder(),
                        ),
                        items: _males.map((animal) {
                          return DropdownMenuItem(
                            value: animal.id,
                            child: Text('${animal.code} - ${animal.name}'),
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
