import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../models/matrix_evaluation.dart';
import '../../../../services/animal_service.dart';
import '../../application/matrix_selection_service.dart';
import '../../../../utils/animal_display_utils.dart';

class MatrixEvaluationFormDialog extends StatefulWidget {
  final MatrixEvaluation? initialEvaluation;
  final String? initialAnimalId;
  final bool lockAnimalSelection;

  const MatrixEvaluationFormDialog({
    super.key,
    this.initialEvaluation,
    this.initialAnimalId,
    this.lockAnimalSelection = false,
  });

  @override
  State<MatrixEvaluationFormDialog> createState() =>
      _MatrixEvaluationFormDialogState();
}

class _MatrixEvaluationFormDialogState extends State<MatrixEvaluationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fertilityController = TextEditingController();
  final _maternalController = TextEditingController();
  final _lactationController = TextEditingController();
  final _bodyConditionController = TextEditingController();
  final _dentitionController = TextEditingController();
  final _lambingWeightController = TextEditingController();
  final _weaningWeightController = TextEditingController();
  final _notesController = TextEditingController();
  final _animalSearchController = TextEditingController();
  final _loteInfoController = TextEditingController();
  final _ageInfoController = TextEditingController();

  bool _saving = false;
  Animal? _selectedAnimal;
  String _recommendation = 'Automática';
  String _hoofCondition = 'Sem problema';
  String _verminosisLevel = 'Nenhuma';
  String _twinningHistory = 'Sem histórico';
  DateTime _evaluationDate = DateTime.now();
  late Future<List<Animal>> _candidatesFuture;

  String _normalizeRecommendation(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'aprovada' || normalized == 'aprovar') return 'Aprovar';
    if (normalized == 'observação' ||
        normalized == 'observacao' ||
        normalized == 'observar') {
      return 'Observar';
    }
    if (normalized == 'descartar') return 'Descartar';
    if (normalized == 'automática' || normalized == 'automatica') {
      return 'Automática';
    }
    return 'Automática';
  }

  @override
  void initState() {
    super.initState();
    final existing = widget.initialEvaluation;
    _evaluationDate = existing?.evaluationDate ?? DateTime.now();
    _loteInfoController.text = '-';
    _ageInfoController.text = '-';

    _fertilityController.text =
        (existing?.fertilityScore ?? 7.0).toStringAsFixed(1);
    _maternalController.text =
        (existing?.maternalScore ?? 7.0).toStringAsFixed(1);
    _lactationController.text =
        (existing?.lactationScore ?? 7.0).toStringAsFixed(1);
    _bodyConditionController.text =
        (existing?.bodyConditionScore ?? 3.0).toStringAsFixed(1);
    _dentitionController.text =
        (existing?.dentitionScore ?? 7.0).toStringAsFixed(1);
    _lambingWeightController.text = existing?.lambingWeight == null
        ? ''
        : existing!.lambingWeight!.toStringAsFixed(1);
    _weaningWeightController.text = existing?.weaningWeight == null
        ? ''
        : existing!.weaningWeight!.toStringAsFixed(1);
    _hoofCondition = existing?.hoofCondition ?? 'Sem problema';
    _verminosisLevel = existing?.verminosisLevel ?? 'Nenhuma';
    _twinningHistory = existing?.twinningHistory ?? 'Sem histórico';
    _notesController.text = existing?.notes ?? '';

    if (existing != null && existing.recommendation.trim().isNotEmpty) {
      _recommendation = _normalizeRecommendation(existing.recommendation);
    }
    _candidatesFuture = _loadCandidates();
  }

  @override
  void dispose() {
    _fertilityController.dispose();
    _maternalController.dispose();
    _lactationController.dispose();
    _bodyConditionController.dispose();
    _dentitionController.dispose();
    _lambingWeightController.dispose();
    _weaningWeightController.dispose();
    _notesController.dispose();
    _animalSearchController.dispose();
    _loteInfoController.dispose();
    _ageInfoController.dispose();
    super.dispose();
  }

  Future<List<Animal>> _loadCandidates() async {
    final animalService = context.read<AnimalService>();
    final items = await animalService.searchAnimals(
      gender: 'Fêmea',
      excludeCategories: const ['Borrego', 'Borrega', 'Venda'],
      limit: 2000,
    );
    AnimalDisplayUtils.sortAnimalsList(items);
    return items;
  }

  int? _computeAgeMonths(Animal? animal) {
    if (animal == null) return null;
    final birth = animal.birthDate;
    final months = ((_evaluationDate.year - birth.year) * 12) +
        (_evaluationDate.month - birth.month) -
        (_evaluationDate.day < birth.day ? 1 : 0);
    if (months < 0) return 0;
    return months;
  }

  void _refreshDerivedInfo() {
    final ageMonths = _computeAgeMonths(_selectedAnimal);
    _ageInfoController.text = ageMonths == null ? '-' : '$ageMonths meses';
    _loteInfoController.text = _selectedAnimal?.lote ?? '-';
  }

  double? _readScore(TextEditingController controller) {
    final value = double.tryParse(controller.text.replaceAll(',', '.'));
    if (value == null) return null;
    if (value < 0 || value > 10) return null;
    return value;
  }

  double? _readBodyCondition() {
    final value = double.tryParse(_bodyConditionController.text.replaceAll(',', '.'));
    if (value == null) return null;
    if (value < 1 || value > 5) return null;
    return value;
  }

  double? _readOptionalWeight(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value == null || value <= 0) return null;
    return value;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAnimal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma fêmea para avaliar.')),
      );
      return;
    }
    final fertility = _readScore(_fertilityController);
    final maternal = _readScore(_maternalController);
    final lactation = _readScore(_lactationController);
    final dentition = _readScore(_dentitionController);
    final bodyCondition = _readBodyCondition();
    final lambingWeight = _readOptionalWeight(_lambingWeightController);
    final weaningWeight = _readOptionalWeight(_weaningWeightController);

    if ([fertility, maternal, lactation, dentition].any((v) => v == null) ||
        bodyCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha corretamente os campos: scores 0-10 e escore corporal 1-5.',
          ),
        ),
      );
      return;
    }
    if (lambingWeight != null &&
        weaningWeight != null &&
        weaningWeight < lambingWeight) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peso na desmama não pode ser menor que peso ao parir.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final service = context.read<MatrixSelectionService>();
      await service.saveEvaluation(
        id: widget.initialEvaluation?.id,
        animalId: _selectedAnimal!.id,
        evaluationDate: _evaluationDate,
        fertilityScore: fertility!,
        maternalScore: maternal!,
        hoofCondition: _hoofCondition,
        verminosisLevel: _verminosisLevel,
        twinningHistory: _twinningHistory,
        lactationScore: lactation!,
        bodyConditionScore: bodyCondition,
        dentitionScore: dentition!,
        lambingWeight: lambingWeight,
        weaningWeight: weaningWeight,
        ageMonths: _computeAgeMonths(_selectedAnimal),
        recommendation: _recommendation == 'Automática' ? null : _recommendation,
        notes: _notesController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar avaliação: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildAnimalSelector(List<Animal> animals) {
    final locked = widget.lockAnimalSelection && _selectedAnimal != null;
    if (locked) {
      return TextFormField(
        initialValue: AnimalDisplayUtils.getDisplayText(_selectedAnimal!),
        readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Fêmea',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.female),
        ),
      );
    }

    return Autocomplete<Animal>(
      displayStringForOption: (a) => AnimalDisplayUtils.getDisplayText(a),
      optionsBuilder: (text) {
        return AnimalDisplayUtils.filterAndRankAnimals(
          animals,
          text.text,
        );
      },
      onSelected: (animal) {
        setState(() {
          _selectedAnimal = animal;
          _animalSearchController.text = AnimalDisplayUtils.getDisplayText(animal);
          _refreshDerivedInfo();
        });
      },
      fieldViewBuilder: (_, controller, focusNode, __) {
        if (_animalSearchController.text.isNotEmpty && controller.text.isEmpty) {
          controller.text = _animalSearchController.text;
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Fêmea',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.female),
          ),
          validator: (_) => _selectedAnimal == null ? 'Obrigatório' : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width < 700 ? 360.0 : 560.0;
    final isEditing = widget.initialEvaluation != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Avaliação de Matriz' : 'Nova Avaliação de Matriz'),
      content: SizedBox(
        width: width,
        child: FutureBuilder<List<Animal>>(
          future: _candidatesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final animals = snapshot.data!;
            final initialAnimalId =
                widget.initialAnimalId ?? widget.initialEvaluation?.animalId;
            if (_selectedAnimal == null && initialAnimalId != null) {
              for (final a in animals) {
                if (a.id == initialAnimalId) {
                  _selectedAnimal = a;
                  _animalSearchController.text = AnimalDisplayUtils.getDisplayText(a);
                  _refreshDerivedInfo();
                  break;
                }
              }
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimalSelector(animals),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _loteInfoController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Lote',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _ageInfoController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Idade na avaliação',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ScoreField(controller: _fertilityController, label: 'Fertilidade (0-10)'),
                    const SizedBox(height: 10),
                    _ScoreField(controller: _maternalController, label: 'Habilidade materna (0-10)'),
                    const SizedBox(height: 10),
                    _ScoreField(controller: _lactationController, label: 'Lactação (0-10)'),
                    const SizedBox(height: 10),
                    _ScoreField(controller: _dentitionController, label: 'Dentição (0-10)'),
                    const SizedBox(height: 10),
                    _BodyConditionField(controller: _bodyConditionController),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _hoofCondition,
                      decoration: const InputDecoration(
                        labelText: 'Problema de casco',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Sem problema', child: Text('Sem problema')),
                        DropdownMenuItem(value: 'Leve', child: Text('Leve')),
                        DropdownMenuItem(value: 'Moderado', child: Text('Moderado')),
                        DropdownMenuItem(value: 'Severo', child: Text('Severo')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _hoofCondition = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _verminosisLevel,
                      decoration: const InputDecoration(
                        labelText: 'Verminose',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Nenhuma', child: Text('Nenhuma')),
                        DropdownMenuItem(value: 'Leve', child: Text('Leve')),
                        DropdownMenuItem(value: 'Moderada', child: Text('Moderada')),
                        DropdownMenuItem(value: 'Severa', child: Text('Severa')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _verminosisLevel = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _twinningHistory,
                      decoration: const InputDecoration(
                        labelText: 'Gemelaridade',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Sem histórico', child: Text('Sem histórico')),
                        DropdownMenuItem(value: 'Parto simples', child: Text('Parto simples')),
                        DropdownMenuItem(value: 'Parto gemelar', child: Text('Parto gemelar')),
                        DropdownMenuItem(value: 'Parto múltiplo', child: Text('Parto múltiplo')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _twinningHistory = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _KgField(
                            controller: _lambingWeightController,
                            label: 'Peso ao parir (kg)',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _KgField(
                            controller: _weaningWeightController,
                            label: 'Peso na desmama (kg)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _recommendation,
                      decoration: const InputDecoration(
                        labelText: 'Recomendação',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Automática',
                          child: Text('Automática (por score)'),
                        ),
                        DropdownMenuItem(
                          value: 'Aprovar',
                          child: Text('Aprovar'),
                        ),
                        DropdownMenuItem(
                          value: 'Observar',
                          child: Text('Observar'),
                        ),
                        DropdownMenuItem(
                          value: 'Descartar',
                          child: Text('Descartar'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _recommendation = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _notesController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
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

class _ScoreField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _ScoreField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
        if (parsed == null) return 'Informe um número';
        if (parsed < 0 || parsed > 10) return 'Use valor entre 0 e 10';
        return null;
      },
    );
  }
}

class _BodyConditionField extends StatelessWidget {
  final TextEditingController controller;

  const _BodyConditionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Escore corporal (1-5)',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
        if (parsed == null) return 'Informe um número';
        if (parsed < 1 || parsed > 5) return 'Use valor entre 1 e 5';
        return null;
      },
    );
  }
}

class _KgField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _KgField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final text = (value ?? '').trim();
        if (text.isEmpty) return null;
        final parsed = double.tryParse(text.replaceAll(',', '.'));
        if (parsed == null || parsed <= 0) return 'Informe peso válido';
        return null;
      },
    );
  }
}
