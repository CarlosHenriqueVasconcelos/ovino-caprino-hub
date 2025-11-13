import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/feeding_service.dart';
import '../models/feeding_schedule.dart';

class FeedingFormDialog extends StatefulWidget {
  final String penId;
  final FeedingSchedule? schedule;

  const FeedingFormDialog({
    super.key,
    required this.penId,
    this.schedule,
  });

  @override
  State<FeedingFormDialog> createState() => _FeedingFormDialogState();
}

class _FeedingFormDialogState extends State<FeedingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _feedTypeController;
  late TextEditingController _quantityController;
  late TextEditingController _timesPerDayController;
  late TextEditingController _notesController;
  final List<TextEditingController> _timeControllers = [];

  @override
  void initState() {
    super.initState();
    _feedTypeController =
        TextEditingController(text: widget.schedule?.feedType ?? '');
    _quantityController =
        TextEditingController(text: widget.schedule?.quantity.toString() ?? '');
    _timesPerDayController = TextEditingController(
        text: widget.schedule?.timesPerDay.toString() ?? '1');
    _notesController =
        TextEditingController(text: widget.schedule?.notes ?? '');

    // Inicializar controladores de horários
    if (widget.schedule != null) {
      for (var time in widget.schedule!.feedingTimesList) {
        _timeControllers.add(TextEditingController(text: time));
      }
    } else {
      _timeControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _feedTypeController.dispose();
    _quantityController.dispose();
    _timesPerDayController.dispose();
    _notesController.dispose();
    for (var controller in _timeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTimeField() {
    setState(() {
      _timeControllers.add(TextEditingController());
    });
  }

  void _removeTimeField(int index) {
    if (_timeControllers.length > 1) {
      setState(() {
        _timeControllers[index].dispose();
        _timeControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _timeControllers[index].text = picked.format(context);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final feedingTimes = _timeControllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => c.text.trim())
        .join(', ');

    if (feedingTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um horário')),
      );
      return;
    }

    final feedingService = Provider.of<FeedingService>(context, listen: false);
    final now = DateTime.now().toIso8601String();

    final schedule = FeedingSchedule(
      id: widget.schedule?.id ?? const Uuid().v4(),
      penId: widget.penId,
      feedType: _feedTypeController.text.trim(),
      quantity: double.parse(_quantityController.text.trim()),
      timesPerDay: int.parse(_timesPerDayController.text.trim()),
      feedingTimes: feedingTimes,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.schedule?.createdAt ?? DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );

    if (widget.schedule == null) {
      await feedingService.addSchedule(schedule);
    } else {
      await feedingService.updateSchedule(schedule);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.schedule == null ? 'Informar Trato' : 'Editar Trato'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _feedTypeController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Trato/Alimento *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade (kg) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timesPerDayController,
                decoration: const InputDecoration(
                  labelText: 'Vezes por dia *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Horários:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: _addTimeField,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._timeControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Horário ${index + 1}',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () => _selectTime(context, index),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      if (_timeControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => _removeTimeField(index),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
