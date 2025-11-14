import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/breeding_record.dart';
import '../models/animal.dart';
import '../services/animal_service.dart';
import '../services/breeding_service.dart';
import 'animal_form.dart';

class BreedingStageActions extends StatefulWidget {
  final BreedingRecord record;
  final Function? onUpdate;

  const BreedingStageActions({
    super.key,
    required this.record,
    this.onUpdate,
  });

  @override
  State<BreedingStageActions> createState() => _BreedingStageActionsState();
}

class _BreedingStageActionsState extends State<BreedingStageActions> {
  bool _isProcessing = false;

  Future<void> _separateAnimals() async {
    setState(() => _isProcessing = true);

    try {
      final breedingService = context.read<BreedingService>();
      final animalService = context.read<AnimalService>();

      await breedingService.separarAnimais(widget.record.id);
      await animalService.loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Animais separados! Aguardando ultrassom.'),
        ),
      );
      widget.onUpdate?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao separar animais: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _registerUltrasound() async {
    final breedingService = context.read<BreedingService>();
    final animalService = context.read<AnimalService>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultado do Ultrassom'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Gestação Confirmada'),
              leading: Radio<String>(
                value: 'Confirmada',
                groupValue: null,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
            ListTile(
              title: const Text('Não Confirmada'),
              leading: Radio<String>(
                value: 'Nao_Confirmada',
                groupValue: null,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
          ],
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() => _isProcessing = true);

    try {
      final isConfirmed = result == 'Confirmada';
      final now = DateTime.now();
      // mesmo comportamento antigo: parto previsto 150 dias a partir de HOJE
      final birthEta = now.add(const Duration(days: 150));

      await breedingService.registrarUltrassom(
        breedingId: widget.record.id,
        isConfirmada: isConfirmed,
        ultrasoundResult: result,
        nowOverride: now,
        expectedBirthOverride: isConfirmed ? birthEta : null,
      );

      // Atualiza estado da fêmea (gestante / saudável) via AnimalService
      final femaleId = widget.record.femaleAnimalId;
      if (femaleId != null && femaleId.isNotEmpty) {
        Animal? female;
        try {
          female = animalService.animals.firstWhere((a) => a.id == femaleId);
        } catch (_) {
          female = null;
        }

        if (female != null) {
          final updatedFemale = female.copyWith(
            pregnant: isConfirmed,
            expectedDelivery: isConfirmed ? birthEta : null,
            status: isConfirmed ? 'Gestante' : 'Saudável',
          );
          await animalService.updateAnimal(updatedFemale);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConfirmed ? 'Gestação confirmada!' : 'Gestação não confirmada.',
          ),
        ),
      );
      widget.onUpdate?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar ultrassom: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _registerBirth() async {
    final breedingService = context.read<BreedingService>();
    final animalService = context.read<AnimalService>();

    // Primeiro, perguntar quantas crias nasceram
    final numberOfOffspring = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Nascimento'),
        content: const Text('Quantas crias nasceram?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 1),
            child: const Text('1 Cria'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 2),
            child: const Text('2 Crias'),
          ),
        ],
      ),
    );

    if (!mounted || numberOfOffspring == null) return;

    setState(() => _isProcessing = true);

    try {
      final now = DateTime.now();

      // Atualiza registro de reprodução (parto realizado)
      await breedingService.registrarParto(
        breedingId: widget.record.id,
        birthDate: now,
      );

      // Limpa marcação de gestante no animal
      final femaleId = widget.record.femaleAnimalId;
      if (femaleId != null && femaleId.isNotEmpty) {
        Animal? mother;
        try {
          mother = animalService.animals.firstWhere((a) => a.id == femaleId);
        } catch (_) {
          mother = null;
        }

        if (mother != null) {
          final updatedMother = mother.copyWith(
            pregnant: false,
            expectedDelivery: null,
            status: 'Saudável',
          );
          await animalService.updateAnimal(updatedMother);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nascimento registrado com sucesso!'),
          ),
        );

        // Buscar dados da mãe e do pai a partir do AnimalService (já atualizado)
        final maleId = widget.record.maleAnimalId;

        Animal? mother;
        Animal? father;

        if (femaleId != null && femaleId.isNotEmpty) {
          try {
            mother = animalService.animals.firstWhere((a) => a.id == femaleId);
          } catch (_) {
            mother = null;
          }
        }

        if (maleId != null && maleId.isNotEmpty) {
          try {
            father = animalService.animals.firstWhere((a) => a.id == maleId);
          } catch (_) {
            father = null;
          }
        }

        // Libera processamento antes de abrir o(s) formulário(s)
        setState(() => _isProcessing = false);

        // Abre o formulário o número de vezes conforme a quantidade de crias
        for (int i = 0; i < numberOfOffspring; i++) {
          if (!mounted) break;

          await showDialog(
            context: context,
            builder: (context) => AnimalFormDialog(
              motherId: mother?.id,
              motherName: mother?.name,
              motherColor: mother?.nameColor,
              motherCode: mother?.code,
              motherBreed: mother?.breed,
              fatherId: father?.id,
              fatherName: father?.name,
              fatherColor: father?.nameColor,
              fatherCode: father?.code,
              fatherBreed: father?.breed,
              presetCategory: 'Borrego',
            ),
          );
        }

        // Recarrega dados após fechar todos os formulários
        widget.onUpdate?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar nascimento: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _cancelBreeding() async {
    final breedingService = context.read<BreedingService>();
    final animalService = context.read<AnimalService>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Encabritamento'),
        content: const Text('Deseja cancelar e apagar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() => _isProcessing = true);
    try {

      await breedingService.cancelarRegistro(widget.record.id);
      await animalService.loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encabritamento cancelado.')),
      );
      widget.onUpdate?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (widget.record.stage) {
      case BreedingStage.encabritamento:
        final needsAction = widget.record.needsAction();
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: needsAction ? _separateAnimals : null,
              icon: const Icon(Icons.call_split),
              label: const Text('Separar Animais'),
              style: ElevatedButton.styleFrom(
                backgroundColor: needsAction ? Colors.orange : Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _cancelBreeding,
              icon: const Icon(Icons.cancel),
              label: const Text('Cancelar'),
            ),
          ],
        );

      case BreedingStage.aguardandoUltrassom:
      case BreedingStage.separacao:
        return ElevatedButton.icon(
          onPressed: _registerUltrasound,
          icon: const Icon(Icons.medical_services),
          label: const Text('Registrar Ultrassom'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );

      case BreedingStage.gestacaoConfirmada:
        final needsAction = widget.record.needsAction();
        return ElevatedButton.icon(
          onPressed: needsAction ? _registerBirth : null,
          icon: const Icon(Icons.child_care),
          label: const Text('Registrar Nascimento'),
          style: ElevatedButton.styleFrom(
            backgroundColor: needsAction ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
