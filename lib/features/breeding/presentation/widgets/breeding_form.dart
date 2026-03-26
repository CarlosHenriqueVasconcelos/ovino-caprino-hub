// lib/widgets/breeding/breeding_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/animal_service.dart';
import '../../../../services/breeding_service.dart';
import '../../../../models/animal.dart';
import '../../../../models/breeding_record.dart';
import '../../../../models/kinship_report.dart';
import '../../../../utils/animal_display_utils.dart';
import '../../../../utils/responsive_utils.dart';

class BreedingFormDialog extends StatefulWidget {
  const BreedingFormDialog({super.key});

  @override
  State<BreedingFormDialog> createState() => _BreedingFormDialogState();
}

class _BreedingFormDialogState extends State<BreedingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _femaleAnimalId;
  String? _maleAnimalId;
  String _status = 'Cobertura'; // ainda usado na UI; mapeamos para stage
  DateTime _breedingDate = DateTime.now();
  DateTime? _expectedBirth;

  List<Map<String, dynamic>> _breedingRecords = [];
  bool _loadingRecords = true;
  bool _loadingAnimals = true;
  List<Animal> _femaleOptions = [];
  List<Animal> _maleOptions = [];
  bool _checkingKinship = false;
  KinshipReport? _kinshipReport;

  @override
  void initState() {
    super.initState();
    _loadBreedingRecords();
    _loadInitialAnimals();
  }

  Future<void> _loadBreedingRecords() async {
    try {
      // Agora usamos o BreedingService (injeção via Provider)
      final svc = context.read<BreedingService>();
      final records = await svc.getBreedingRecords();
      if (!mounted) return;
      setState(() {
        _breedingRecords = records;
        _loadingRecords = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao carregar registros de reprodução: $e');
      if (!mounted) return;
      setState(() => _loadingRecords = false);
    }
  }

  Future<void> _loadInitialAnimals() async {
    final animalService = context.read<AnimalService>();
    try {
      final females = await animalService.searchAnimals(
        gender: 'Fêmea',
        excludePregnant: true,
        excludeCategories: const ['Borrego', 'Borrega', 'Venda'],
        limit: 2000,
      );
      final males = await animalService.searchAnimals(
        gender: 'Macho',
        excludeCategories: const ['Borrego', 'Venda'],
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

  String _getAnimalDisplayText(Animal animal) {
    return AnimalDisplayUtils.getDisplayText(animal);
  }

  /// Verifica se a fêmea está em alguma fase reprodutiva ativa.
  /// Antes a checagem era por strings como "Ultrassom agendado", "Gestante".
  /// Agora usamos o enum BreedingStage + valores snake_case do DB.
  bool _isFemaleInBreeding(String animalId) {
    return _breedingRecords.any((record) {
      if (record['female_animal_id'] != animalId) return false;
      final stage = BreedingStage.fromString(record['stage'] as String?);

      // Mantém a lógica antiga:
      // - aguardando_ultrassom  ~ "Ultrassom agendado/confirmado"
      // - gestacao_confirmada   ~ "Gestante"
      return stage == BreedingStage.aguardandoUltrassom ||
          stage == BreedingStage.gestacaoConfirmada;
    });
  }

  /// Verifica se o macho está em encabritamento (usado para bloquear).
  bool _isMaleInBreeding(String animalId) {
    return _breedingRecords.any((record) {
      if (record['male_animal_id'] != animalId) return false;
      final stage = BreedingStage.fromString(record['stage'] as String?);
      return stage == BreedingStage.encabritamento;
    });
  }

  bool get _hasKinshipConflict => _kinshipReport?.isBlocking ?? false;
  bool get _hasKinshipWarning =>
      _kinshipReport != null && !_kinshipReport!.isBlocking;

  Future<void> _refreshKinshipValidation() async {
    final femaleId = _femaleAnimalId;
    final maleId = _maleAnimalId;

    if (femaleId == null || maleId == null) {
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
      femaleId: femaleId,
      maleId: maleId,
    );

    if (!mounted) return;
    if (_femaleAnimalId != femaleId || _maleAnimalId != maleId) return;

    setState(() {
      _checkingKinship = false;
      _kinshipReport = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRecords || _loadingAnimals) {
      return const AlertDialog(
        title: Text('Registrar Cobertura'),
        content: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final femaleAnimals = _femaleOptions
        .where((animal) => !_isFemaleInBreeding(animal.id))
        .toList();
    final maleAnimals = _maleOptions
        .where((animal) => !_isMaleInBreeding(animal.id))
        .toList();

    return AlertDialog(
      title: const Text('Registrar Cobertura'),
      content: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          width: ResponsiveUtils.getDialogWidth(context),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Female Selection with Search
                  Autocomplete<Animal>(
                    displayStringForOption: _getAnimalDisplayText,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return AnimalDisplayUtils.filterAndRankAnimals(
                        femaleAnimals,
                        textEditingValue.text,
                      );
                    },
                    onSelected: (Animal animal) {
                      setState(() => _femaleAnimalId = animal.id);
                      _refreshKinshipValidation();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Fêmea *',
                          hintText: 'Digite o número ou nome para buscar',
                          prefixIcon: const Icon(Icons.female),
                          border: const OutlineInputBorder(),
                          suffixIcon: _femaleAnimalId != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() => _femaleAnimalId = null);
                                    controller.clear();
                                    _refreshKinshipValidation();
                                  },
                                )
                              : null,
                        ),
                        validator: (value) => _femaleAnimalId == null
                            ? 'Selecione uma fêmea'
                            : null,
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final optionsWidth = ResponsiveUtils.isMobile(context)
                          ? MediaQuery.of(context).size.width - 48
                          : 468.0;
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8.0,
                          color: Theme.of(context).cardColor,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 240),
                            width: optionsWidth,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Animal animal = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(animal),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: AnimalDisplayUtils.buildDropdownItem(
                                      animal,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Male Selection (Optional) with Search
                  Autocomplete<Animal>(
                    displayStringForOption: _getAnimalDisplayText,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      return AnimalDisplayUtils.filterAndRankAnimals(
                        maleAnimals,
                        textEditingValue.text,
                      );
                    },
                    onSelected: (Animal animal) {
                      setState(() => _maleAnimalId = animal.id);
                      _refreshKinshipValidation();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Macho (opcional)',
                          hintText: 'Digite o número ou nome para buscar',
                          prefixIcon: const Icon(Icons.male),
                          border: const OutlineInputBorder(),
                          suffixIcon: _maleAnimalId != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() => _maleAnimalId = null);
                                    controller.clear();
                                    _refreshKinshipValidation();
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final optionsWidth = ResponsiveUtils.isMobile(context)
                          ? MediaQuery.of(context).size.width - 48
                          : 468.0;
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8.0,
                          color: Theme.of(context).cardColor,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 240),
                            width: optionsWidth,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Animal animal = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(animal),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: AnimalDisplayUtils.buildDropdownItem(
                                      animal,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_checkingKinship) ...[
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
                    ),
                    const SizedBox(height: 12),
                  ] else if (_hasKinshipConflict || _hasKinshipWarning) ...[
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
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer
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
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer
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
                  ],

                  // Breeding Date
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        locale: const Locale('pt', 'BR'),
                        initialDate: _breedingDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _breedingDate = date;
                          // Calcula uma previsão aproximada de parto (150 dias)
                          _expectedBirth = date.add(const Duration(days: 150));
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data da Cobertura *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_breedingDate.day.toString().padLeft(2, '0')}/'
                        '${_breedingDate.month.toString().padLeft(2, '0')}/'
                        '${_breedingDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expected Birth
                  if (_expectedBirth != null) ...[
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          locale: const Locale('pt', 'BR'),
                          initialDate: _expectedBirth!,
                          firstDate: _breedingDate.add(const Duration(days: 120)),
                          lastDate: _breedingDate.add(const Duration(days: 180)),
                        );
                        if (date != null) {
                          setState(() {
                            _expectedBirth = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Previsão de Nascimento',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_expectedBirth!.day.toString().padLeft(2, '0')}/'
                          '${_expectedBirth!.month.toString().padLeft(2, '0')}/'
                          '${_expectedBirth!.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Status (aqui ainda usamos os rótulos antigos; mapeamos para stage)
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Cobertura', 'Confirmada', 'Nasceu', 'Perdida']
                        .map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: (_checkingKinship || _hasKinshipConflict)
              ? null
              : _saveBreeding,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  /// Converte o "status" antigo de UI para o novo estágio canônico.
  BreedingStage _mapStatusToStage(String status) {
    switch (status) {
      case 'Confirmada':
        return BreedingStage.gestacaoConfirmada;
      case 'Nasceu':
        return BreedingStage.partoRealizado;
      case 'Perdida':
        return BreedingStage.falhou;
      case 'Cobertura':
      default:
        return BreedingStage.encabritamento;
    }
  }

  Future<void> _saveBreeding() async {
    if (!_formKey.currentState!.validate()) return;
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

    try {
      final breedingService = context.read<BreedingService>();
      final animalService = Provider.of<AnimalService>(context, listen: false);
      final femaleId = _femaleAnimalId;
      final maleId = _maleAnimalId;

      if (femaleId != null && maleId != null) {
        final report = await breedingService.getKinshipReport(
          femaleId: femaleId,
          maleId: maleId,
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

      final stageEnum = _mapStatusToStage(_status);
      final notes = _notesController.text.trim();

      // Cria registro de reprodução via service (usa repositório/DB e gatilhos de status)
      await breedingService.createRecord(
        femaleId: _femaleAnimalId!,
        maleId: _maleAnimalId,
        stage: stageEnum.value,
        breedingDate: _breedingDate,
        expectedBirth: _expectedBirth,
        notes: notes.isEmpty ? null : notes,
      );

      // Se o estágio representar gestação confirmada, marcamos a fêmea como gestante
      if (stageEnum == BreedingStage.gestacaoConfirmada) {
        Animal? fallbackFemale;
        if (_femaleOptions.isNotEmpty) {
          fallbackFemale = _femaleOptions.firstWhere(
            (a) => a.id == _femaleAnimalId,
            orElse: () => _femaleOptions.first,
          );
        }
        final female =
            await animalService.getAnimalById(_femaleAnimalId!) ?? fallbackFemale;

        if (female != null) {
          final currentHealthStatus =
              (female.status == 'Gestante' || female.status == 'Reprodutor')
                  ? 'Saudável'
                  : female.status;
          final updatedFemale = female.copyWith(
            pregnant: true,
            expectedDelivery: _expectedBirth,
            status: currentHealthStatus,
            reproductiveStatus: 'Gestante',
          );

          await animalService.updateAnimal(updatedFemale);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cobertura registrada com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar cobertura: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
