import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/animal_service.dart';
import '../services/database_service.dart';

class MedicationManagementScreen extends StatefulWidget {
  const MedicationManagementScreen({super.key});

  @override
  State<MedicationManagementScreen> createState() => _MedicationManagementScreenState();
}

class _MedicationManagementScreenState extends State<MedicationManagementScreen> {
  List<Map<String, dynamic>> _vaccinations = [];
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final vaccinations = await DatabaseService.getVaccinations();
      final medications = await DatabaseService.getMedications();
      setState(() {
        _vaccinations = List<Map<String, dynamic>>.from(vaccinations);
        _medications = List<Map<String, dynamic>>.from(medications);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vacinações e Medicamentos'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.vaccines), text: 'Vacinações'),
              Tab(icon: Icon(Icons.medication), text: 'Medicamentos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVaccinationsList(),
            _buildMedicationsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Agendar'),
        ),
      ),
    );
  }

  Widget _buildVaccinationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vaccinations.isEmpty) {
      return const Center(
        child: Text('Nenhuma vacinação agendada'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = _vaccinations[index];
        return _buildVaccinationCard(vaccination);
      },
    );
  }

  Widget _buildMedicationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_medications.isEmpty) {
      return const Center(
        child: Text('Nenhum medicamento agendado'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final medication = _medications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> vaccination) {
    final status = vaccination['status'] ?? 'Agendada';
    Color statusColor = Colors.orange;
    if (status == 'Aplicada') statusColor = Colors.green;
    if (status == 'Cancelada') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.vaccines, color: statusColor),
        ),
        title: Text(vaccination['vaccine_name'] ?? 'Sem nome'),
        subtitle: Text(
          'Tipo: ${vaccination['vaccine_type']}\n'
          'Data: ${vaccination['scheduled_date']}\n'
          'Status: $status',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showVaccinationOptions(vaccination),
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.medication),
        ),
        title: Text(medication['name'] ?? 'Sem nome'),
        subtitle: Text(
          'Dosagem: ${medication['dosage']}\n'
          'Data: ${medication['scheduled_date']}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMedicationOptions(medication),
        ),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddMedicationDialog(
        onSaved: () {
          _loadData();
        },
      ),
    );
  }

  void _showVaccinationOptions(Map<String, dynamic> vaccination) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check),
            title: const Text('Marcar como aplicada'),
            onTap: () {
              Navigator.pop(context);
              // Implementar
            },
          ),
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Cancelar vacinação'),
            onTap: () {
              Navigator.pop(context);
              // Implementar
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Excluir'),
            onTap: () {
              Navigator.pop(context);
              // Implementar
            },
          ),
        ],
      ),
    );
  }

  void _showMedicationOptions(Map<String, dynamic> medication) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check),
            title: const Text('Marcar como aplicado'),
            onTap: () {
              Navigator.pop(context);
              // Implementar
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Excluir'),
            onTap: () {
              Navigator.pop(context);
              // Implementar
            },
          ),
        ],
      ),
    );
  }
}

class _AddMedicationDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const _AddMedicationDialog({required this.onSaved});

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();
  final _dosageController = TextEditingController();
  
  String _type = 'Vacinação';
  String _vaccineType = 'Obrigatória';
  DateTime _scheduledDate = DateTime.now();
  String? _selectedAnimalId;

  @override
  Widget build(BuildContext context) {
    final animalService = Provider.of<AnimalService>(context);
    
    return AlertDialog(
      title: const Text('Agendar Vacinação/Medicamento'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tipo
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Vacinação', 'Medicamento'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _type = value!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Animal
                DropdownButtonFormField<String>(
                  value: _selectedAnimalId,
                  decoration: const InputDecoration(
                    labelText: 'Animal *',
                    border: OutlineInputBorder(),
                  ),
                  items: animalService.animals.map((animal) {
                    return DropdownMenuItem(
                      value: animal.id,
                      child: Text('${animal.name} (${animal.code})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedAnimalId = value);
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Selecione um animal';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Nome
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: _type == 'Vacinação' ? 'Nome da Vacina *' : 'Nome do Medicamento *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo obrigatório';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Tipo de vacina ou dosagem
                if (_type == 'Vacinação')
                  DropdownButtonFormField<String>(
                    value: _vaccineType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Vacina',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Obrigatória', 'Preventiva', 'Tratamento', 'Emergencial']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _vaccineType = value!);
                    },
                  )
                else
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosagem',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 5ml, 2 comprimidos',
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Data
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _scheduledDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data Agendada *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_scheduledDate.day.toString().padLeft(2, '0')}/${_scheduledDate.month.toString().padLeft(2, '0')}/${_scheduledDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Veterinário
                TextFormField(
                  controller: _veterinarianController,
                  decoration: const InputDecoration(
                    labelText: 'Veterinário',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Observações
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Agendar'),
        ),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate() || _selectedAnimalId == null) return;

    try {
      final now = DateTime.now().toIso8601String();
      
      if (_type == 'Vacinação') {
        final vaccination = {
          'id': const Uuid().v4(),
          'animal_id': _selectedAnimalId!,
          'vaccine_name': _nameController.text,
          'vaccine_type': _vaccineType,
          'scheduled_date': _scheduledDate.toIso8601String().split('T')[0],
          'veterinarian': _veterinarianController.text.isEmpty ? null : _veterinarianController.text,
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
          'status': 'Agendada',
          'created_at': now,
          'updated_at': now,
        };
        await DatabaseService.createVaccination(vaccination);
      } else {
        // Medicamento
        final medication = {
          'id': const Uuid().v4(),
          'animal_id': _selectedAnimalId!,
          'medication_name': _nameController.text,
          'date': _scheduledDate.toIso8601String().split('T')[0],
          'next_date': _scheduledDate.add(const Duration(days: 30)).toIso8601String().split('T')[0],
          'dosage': _dosageController.text.isEmpty ? null : _dosageController.text,
          'veterinarian': _veterinarianController.text.isEmpty ? null : _veterinarianController.text,
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
          'created_at': now,
        };
        await DatabaseService.createMedication(medication);
      }
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_type} agendada com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}