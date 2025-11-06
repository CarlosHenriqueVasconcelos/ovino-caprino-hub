// lib/widgets/breeding_import_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../services/animal_service.dart';
import '../services/breeding_service.dart';

class BreedingImportDialog extends StatefulWidget {
  const BreedingImportDialog({super.key});

  @override
  State<BreedingImportDialog> createState() => _BreedingImportDialogState();
}

class _BreedingImportDialogState extends State<BreedingImportDialog> {
  final _formKey = GlobalKey<FormState>();

  List<Animal> _allAnimals = [];
  Animal? _female;
  Animal? _male;

  DateTime? _breedingStart; // obrigatório
  DateTime? _separationDate; // opcional
  DateTime? _ultrasoundDate; // opcional

  // confirmada | nao_confirmada | nao_informado
  String _ultrasoundResult = 'nao_informado';
  String? _notes;

  final _femaleCtrl = TextEditingController();
  final _maleCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _breedingStart = DateTime.now();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final animalService = context.read<AnimalService>();
    if (animalService.animals.isEmpty) {
      await animalService.loadData();
    }
    setState(() {
      _allAnimals = List<Animal>.from(animalService.animals);
    });
  }

  bool _isFemaleAllowed(Animal a) {
    final c = (a.category ?? '').toLowerCase();
    return (c.contains('fêmea') || c.contains('femea')) &&
        (c.contains('reprodutor') ||
            c.contains('reprodutra') ||
            c.contains('reprodutora') ||
            c.contains('adulto'));
  }

  bool _isMaleAllowed(Animal a) {
    final c = (a.category ?? '').toLowerCase();
    return c.contains('macho') &&
        (c.contains('reprodutor') || c.contains('adulto'));
  }

  List<Animal> _filterForFemale(String query) {
    final q = query.trim().toLowerCase();
    return _allAnimals.where((a) {
      if (!_isFemaleAllowed(a)) return false;
      if (q.isEmpty) return true;
      final code = (a.code ?? '').toLowerCase();
      final name = (a.name ?? '').toLowerCase();
      return code.contains(q) || name.contains(q);
    }).toList();
  }

  List<Animal> _filterForMale(String query) {
    final q = query.trim().toLowerCase();
    return _allAnimals.where((a) {
      if (!_isMaleAllowed(a)) return false;
      if (q.isEmpty) return true;
      final code = (a.code ?? '').toLowerCase();
      final name = (a.name ?? '').toLowerCase();
      return code.contains(q) || name.contains(q);
    }).toList();
  }

  String _labelOf(Animal a) => '${a.code ?? '-'} — ${a.name ?? '-'}';

  // ----------- salvar (com cálculo de stage) -----------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_female == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a fêmea.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // 1) Determinar stage coerente com os dados informados
      String stage;
      if (_ultrasoundResult == 'confirmada') {
        stage = 'gestacao_confirmada';
      } else if (_ultrasoundResult == 'nao_confirmada') {
        stage = 'falhou';
      } else if (_separationDate != null && _ultrasoundDate != null) {
        stage = 'aguardando_ultrassom';
      } else if (_separationDate != null) {
        stage = 'separacao';
      } else {
        stage = 'encabritamento';
      }

      // 2) Calcular data prevista de parto (se fizer sentido)
      DateTime? expectedBirth;
      if (stage == 'gestacao_confirmada' && _breedingStart != null) {
        expectedBirth = _breedingStart!.add(const Duration(days: 150));
      }

      final ultrasoundResultText = _ultrasoundResult == 'confirmada'
          ? 'Confirmada'
          : _ultrasoundResult == 'nao_confirmada'
              ? 'Nao_Confirmada'
              : null;

      // 3) Criar registro via BreedingService (gatilhos cuidam de status)
      final breedingService = context.read<BreedingService>();

      await breedingService.createRecord(
        femaleId: _female!.id,
        maleId: _male?.id,
        stage: stage,
        breedingDate: _breedingStart,
        matingStartDate: _breedingStart,
        matingEndDate: _separationDate,
        separationDate: _separationDate,
        ultrasoundDate: _ultrasoundDate,
        expectedBirth: expectedBirth,
        ultrasoundResult: ultrasoundResultText,
        notes: (_notes ?? '').isNotEmpty ? _notes : null,
      );

      // 4) Se for gestação confirmada, marcar a fêmea como gestante via AnimalService
      if (stage == 'gestacao_confirmada') {
        final animalService = context.read<AnimalService>();
        final femaleId = _female!.id;

        // tenta achar a fêmea no service, se não achar usa a selecionada (_female)
        Animal? female;
        try {
          female =
              animalService.animals.firstWhere((a) => a.id == femaleId);
        } catch (_) {
          female = _female;
        }

        if (female != null) {
          final updatedFemale = female.copyWith(
            pregnant: true,
            expectedDelivery: expectedBirth,
            status: 'Gestante',
          );
          await animalService.updateAnimal(updatedFemale);
        }
      }

      // Atualizar provider/UI (cards e lista)
      await context.read<AnimalService>().loadData();

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro importado com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao importar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _femaleCtrl.dispose();
    _maleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar registro existente'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Fêmea (com busca)
              FormField<Animal?>(
                validator: (_) => _female == null ? 'Obrigatório' : null,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Autocomplete<Animal>(
                        optionsBuilder: (text) => _filterForFemale(text.text),
                        displayStringForOption: _labelOf,
                        fieldViewBuilder: (
                          context,
                          controller,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          _femaleCtrl.value = controller.value;
                          if (_female != null) {
                            controller.text = _labelOf(_female!);
                          }
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Fêmea *',
                              prefixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Material(
                            elevation: 4,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, i) {
                                final a = options.elementAt(i);
                                return ListTile(
                                  title: Text(_labelOf(a)),
                                  onTap: () => onSelected(a),
                                );
                              },
                            ),
                          );
                        },
                        onSelected: (a) {
                          setState(() {
                            _female = a;
                            _femaleCtrl.text = _labelOf(a);
                          });
                          state.didChange(a);
                        },
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 8),
                          child: Text(
                            state.errorText!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),

              // Macho (com busca; opcional)
              FormField<Animal?>(
                validator: (_) => null,
                builder: (state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Autocomplete<Animal>(
                        optionsBuilder: (text) => _filterForMale(text.text),
                        displayStringForOption: _labelOf,
                        fieldViewBuilder: (
                          context,
                          controller,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          _maleCtrl.value = controller.value;
                          if (_male != null) {
                            controller.text = _labelOf(_male!);
                          }
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Macho (opcional)',
                              prefixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Material(
                            elevation: 4,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, i) {
                                final a = options.elementAt(i);
                                return ListTile(
                                  title: Text(_labelOf(a)),
                                  onTap: () => onSelected(a),
                                );
                              },
                            ),
                          );
                        },
                        onSelected: (a) {
                          setState(() {
                            _male = a;
                            _maleCtrl.text = _labelOf(a);
                          });
                          state.didChange(a);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),

              // Datas
              _DatePickerField(
                label: 'Início do Encabritamento *',
                initial: _breedingStart,
                required: true,
                onChanged: (d) => setState(() => _breedingStart = d),
              ),
              const SizedBox(height: 8),

              _DatePickerField(
                label: 'Data de Separação (opcional)',
                initial: _separationDate,
                required: false,
                onChanged: (d) => setState(() => _separationDate = d),
              ),
              const SizedBox(height: 8),

              _DatePickerField(
                label: 'Data de Ultrassom/Confirmação (opcional)',
                initial: _ultrasoundDate,
                required: false,
                onChanged: (d) => setState(() => _ultrasoundDate = d),
              ),
              const SizedBox(height: 8),

              // Resultado do US
              DropdownButtonFormField<String>(
                value: _ultrasoundResult,
                items: const [
                  DropdownMenuItem(
                    value: 'nao_informado',
                    child: Text('Não informado'),
                  ),
                  DropdownMenuItem(
                    value: 'confirmada',
                    child: Text('Gestação Confirmada'),
                  ),
                  DropdownMenuItem(
                    value: 'nao_confirmada',
                    child: Text('Não Confirmada'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _ultrasoundResult = v ?? 'nao_informado'),
                decoration: const InputDecoration(
                  labelText: 'Resultado do Ultrassom',
                ),
              ),
              const SizedBox(height: 8),

              // Observações
              TextFormField(
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                ),
                onChanged: (v) => _notes = v,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? initial;
  final ValueChanged<DateTime?> onChanged;
  final bool required;

  const _DatePickerField({
    required this.label,
    required this.initial,
    required this.onChanged,
    this.required = false,
  });

  String _fmt(DateTime? d) => d == null
      ? 'Selecionar'
      : '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime?>(
      initialValue: initial,
      validator: (_) => required && initial == null ? 'Obrigatório' : null,
      builder: (state) {
        final value = state.value ?? initial;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text('$label: ${_fmt(value)}'),
              onPressed: () async {
                final now = DateTime.now();
                final first = DateTime(now.year - 10, 1, 1);
                final last = DateTime(now.year + 1, 12, 31);
                final picked = await showDatePicker(
                  context: context,
                  locale: const Locale('pt', 'BR'),
                  initialDate: value ?? now,
                  firstDate: first,
                  lastDate: last,
                );
                if (picked != null) {
                  onChanged(picked);
                  state.didChange(picked);
                }
              },
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }
}
