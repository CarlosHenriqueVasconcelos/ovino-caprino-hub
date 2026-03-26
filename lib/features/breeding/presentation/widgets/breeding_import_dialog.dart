// lib/widgets/breeding/breeding_import_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../models/kinship_report.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/breeding_service.dart';
import '../../../../utils/animal_display_utils.dart';

class BreedingImportDialog extends StatefulWidget {
  const BreedingImportDialog({super.key});

  @override
  State<BreedingImportDialog> createState() => _BreedingImportDialogState();
}

class _BreedingImportDialogState extends State<BreedingImportDialog> {
  final _formKey = GlobalKey<FormState>();

  List<Animal> _femaleOptions = [];
  List<Animal> _maleOptions = [];
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
  bool _loadingAnimals = true;
  bool _checkingKinship = false;
  KinshipReport? _kinshipReport;

  @override
  void initState() {
    super.initState();
    _breedingStart = DateTime.now();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final animalService = context.read<AnimalService>();
    try {
      final females = await animalService.searchAnimals(
        gender: 'Fêmea',
        excludePregnant: true,
        excludeCategories: const ['borrego', 'borrega', 'venda'],
        limit: 2000,
      );
      final males = await animalService.searchAnimals(
        gender: 'Macho',
        excludeCategories: const ['borrego', 'venda'],
        limit: 2000,
      );
      AnimalDisplayUtils.sortAnimalsList(females);
      AnimalDisplayUtils.sortAnimalsList(males);
      if (!mounted) return;
      setState(() {
        _femaleOptions = females;
        _maleOptions = males;
        _loadingAnimals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAnimals = false);
    }
  }

  bool _isFemaleAllowed(Animal a) {
    final c = a.category.toLowerCase();
    return (c.contains('fêmea') || c.contains('femea')) &&
        (c.contains('reprodutor') ||
            c.contains('reprodutra') ||
            c.contains('reprodutora') ||
            c.contains('adulto'));
  }

  bool _isMaleAllowed(Animal a) {
    final c = a.category.toLowerCase();
    return c.contains('macho') &&
        (c.contains('reprodutor') || c.contains('adulto'));
  }

  List<Animal> _filterForFemale(String query) {
    final candidates = _femaleOptions.where(_isFemaleAllowed);
    return AnimalDisplayUtils.filterAndRankAnimals(candidates, query);
  }

  List<Animal> _filterForMale(String query) {
    final candidates = _maleOptions.where(_isMaleAllowed);
    return AnimalDisplayUtils.filterAndRankAnimals(candidates, query);
  }

  String _labelOf(Animal a) => AnimalDisplayUtils.getDisplayText(a);

  bool get _hasKinshipConflict => _kinshipReport?.isBlocking ?? false;
  bool get _hasKinshipWarning =>
      _kinshipReport != null && !_kinshipReport!.isBlocking;

  Future<void> _refreshKinshipValidation() async {
    final female = _female;
    final male = _male;

    if (female == null || male == null) {
      if (!mounted) return;
      setState(() {
        _checkingKinship = false;
        _kinshipReport = null;
      });
      return;
    }

    setState(() => _checkingKinship = true);

    final breedingService = context.read<BreedingService>();
    final report = await breedingService.getKinshipReport(
      femaleId: female.id,
      maleId: male.id,
    );

    if (!mounted) return;
    if (_female?.id != female.id || _male?.id != male.id) return;

    setState(() {
      _checkingKinship = false;
      _kinshipReport = report;
    });
  }

  // ----------- salvar (com cálculo de stage) -----------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_female == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a fêmea.')),
      );
      return;
    }
    if (_checkingKinship) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aguarde a validação de parentesco.')),
      );
      return;
    }
    if (_hasKinshipConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_kinshipReport!.buildMessage())),
      );
      return;
    }

    setState(() => _saving = true);

    final breedingService = context.read<BreedingService>();
    final animalService = context.read<AnimalService>();

    try {
      if (_female != null && _male != null) {
        final report = await breedingService.getKinshipReport(
          femaleId: _female!.id,
          maleId: _male!.id,
        );
        if (report != null && report.isBlocking) {
          if (!mounted) return;
          setState(() => _kinshipReport = report);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(report.buildMessage())),
          );
          return;
        }
      }

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
        final femaleId = _female!.id;

        // tenta achar a fêmea no service, se não achar usa a selecionada (_female)
        final female =
            await animalService.getAnimalById(femaleId) ?? _female;

        if (female != null) {
          final currentHealthStatus =
              (female.status == 'Gestante' || female.status == 'Reprodutor')
                  ? 'Saudável'
                  : female.status;
          final updatedFemale = female.copyWith(
            pregnant: true,
            expectedDelivery: expectedBirth,
            status: currentHealthStatus,
            reproductiveStatus: 'Gestante',
          );
          await animalService.updateAnimal(updatedFemale);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro importado com sucesso.')),
      );
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
    if (_loadingAnimals) {
      return const AlertDialog(
        title: Text('Adicionar registro existente'),
        content: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
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
                            decoration: InputDecoration(
                              labelText: 'Fêmea *',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _female != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _female = null;
                                          _femaleCtrl.clear();
                                        });
                                        controller.clear();
                                        state.didChange(null);
                                        _refreshKinshipValidation();
                                      },
                                    )
                                  : null,
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
                          _refreshKinshipValidation();
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
                            decoration: InputDecoration(
                              labelText: 'Macho (opcional)',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _male != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _male = null;
                                          _maleCtrl.clear();
                                        });
                                        controller.clear();
                                        state.didChange(null);
                                        _refreshKinshipValidation();
                                      },
                                    )
                                  : null,
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
                          _refreshKinshipValidation();
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              if (_checkingKinship)
                const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Validando parentesco...'),
                  ],
                )
              else if (_hasKinshipConflict || _hasKinshipWarning)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _hasKinshipConflict
                        ? Theme.of(context).colorScheme.errorContainer
                        : Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasKinshipConflict
                            ? 'Cruzamento bloqueado'
                            : 'Parentesco detectado (atenção)',
                        style: TextStyle(
                          color: _hasKinshipConflict
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              'Grau: ${_kinshipReport!.degreeLabel}',
                            ),
                          ),
                          Chip(
                            label: Text(
                              'Relação: ${_kinshipReport!.relationLabel}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Animais: ${_kinshipReport!.animalsLabel}',
                        style: TextStyle(
                          color: _hasKinshipConflict
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : Colors.amber.shade900,
                        ),
                      ),
                      if (_kinshipReport!.detail != null &&
                          _kinshipReport!.detail!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _kinshipReport!.detail!,
                            style: TextStyle(
                              color: _hasKinshipConflict
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                    ],
                  ),
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
                initialValue: _ultrasoundResult,
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
          onPressed: (_saving || _checkingKinship || _hasKinshipConflict)
              ? null
              : _save,
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
