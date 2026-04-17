import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/feeding_schedule.dart';
import '../../../../services/feeding_service.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kErr = Color(0xFFC94A4A);

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
    _quantityController = TextEditingController(
      text: widget.schedule?.quantity.toStringAsFixed(1).replaceAll('.', ',') ?? '',
    );
    _timesPerDayController =
        TextEditingController(text: widget.schedule?.timesPerDay.toString() ?? '1');
    _notesController = TextEditingController(text: widget.schedule?.notes ?? '');

    if (widget.schedule != null) {
      for (final time in widget.schedule!.feedingTimesList) {
        _timeControllers.add(TextEditingController(text: time));
      }
    }
    if (_timeControllers.isEmpty) {
      _timeControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _feedTypeController.dispose();
    _quantityController.dispose();
    _timesPerDayController.dispose();
    _notesController.dispose();
    for (final controller in _timeControllers) {
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
    if (_timeControllers.length <= 1) return;
    setState(() {
      _timeControllers[index].dispose();
      _timeControllers.removeAt(index);
    });
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final picked = await showTimePicker(
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

    final quantity = double.tryParse(
      _quantityController.text.trim().replaceAll(',', '.'),
    );
    final timesPerDay = int.tryParse(_timesPerDayController.text.trim());

    if (quantity == null || timesPerDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valores numéricos inválidos.')),
      );
      return;
    }

    final feedingService = context.read<FeedingService>();
    final now = DateTime.now();

    final schedule = FeedingSchedule(
      id: widget.schedule?.id ?? const Uuid().v4(),
      penId: widget.penId,
      feedType: _feedTypeController.text.trim(),
      quantity: quantity,
      timesPerDay: timesPerDay,
      feedingTimes: feedingTimes,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.schedule?.createdAt ?? now,
      updatedAt: now,
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
    final isEditing = widget.schedule != null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Editar trato' : 'Informar trato',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _kText,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Preencha as informações da ração desta baia',
                              style: TextStyle(fontSize: 10, color: _kText3),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Fechar',
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close, color: _kText3, size: 18),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0x14000000)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldShell(
                          child: TextFormField(
                            controller: _feedTypeController,
                            decoration: _decor('Tipo de trato/alimento *'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Campo obrigatório';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _FieldShell(
                                child: TextFormField(
                                  controller: _quantityController,
                                  decoration: _decor('Quantidade (kg) *'),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,.]'),
                                    ),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Obrigatório';
                                    }
                                    final parsed = double.tryParse(
                                      value.trim().replaceAll(',', '.'),
                                    );
                                    if (parsed == null || parsed <= 0) {
                                      return 'Valor inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _FieldShell(
                                child: TextFormField(
                                  controller: _timesPerDayController,
                                  decoration: _decor('Vezes por dia *'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Obrigatório';
                                    }
                                    final parsed = int.tryParse(value.trim());
                                    if (parsed == null || parsed < 1) {
                                      return 'Inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Horários',
                              style: TextStyle(
                                fontSize: 11,
                                color: _kText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _addTimeField,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Adicionar'),
                              style: TextButton.styleFrom(
                                foregroundColor: _kBrand,
                                minimumSize: const Size(0, 30),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ..._timeControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _FieldShell(
                                    child: TextFormField(
                                      controller: controller,
                                      readOnly: true,
                                      decoration: _decor(
                                        'Horário ${index + 1}',
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: _kText3,
                                          ),
                                          onPressed: () => _selectTime(context, index),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_timeControllers.length > 1) ...[
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _removeTimeField(index),
                                    borderRadius: BorderRadius.circular(7),
                                    child: Ink(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAEAEA),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        size: 14,
                                        color: _kErr,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        _FieldShell(
                          child: TextFormField(
                            controller: _notesController,
                            decoration: _decor('Observações'),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0x14000000)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kText2,
                            side: BorderSide(color: _kBorder.withValues(alpha: 0.95)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: _kBrand,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: const Text('Salvar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decor(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: _kText3),
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      isDense: true,
    );
  }
}

class _FieldShell extends StatelessWidget {
  final Widget child;

  const _FieldShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: _kSurface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder.withValues(alpha: 0.85)),
      ),
      child: child,
    );
  }
}
