import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/breeding_record.dart';
import '../models/animal.dart';
import '../services/database_service.dart';
import '../services/animal_service.dart';
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
      final now = DateTime.now();
      final ultrasoundEta = now.add(const Duration(days: 30));

      await DatabaseService.updateBreedingRecord(widget.record.id, {
        'separation_date': now.toIso8601String(),
        'ultrasound_date': ultrasoundEta.toIso8601String(), // previsão automática
        'stage': BreedingStage.aguardandoUltrassom.value,
        'status': 'Aguardando Ultrassom',
      });

      // atualiza painel
      await context.read<AnimalService>().loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animais separados! Aguardando ultrassom.')),
        );
        widget.onUpdate?.call();
      }
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

    if (result == null) return;

    setState(() => _isProcessing = true);

    try {
      final isConfirmed = result == 'Confirmada';
      final now = DateTime.now();
      final birthEta = now.add(const Duration(days: 150)); // 150 dias a partir de HOJE

      final update = <String, dynamic>{
        'ultrasound_date':
            widget.record.ultrasoundDate?.toIso8601String() ?? now.toIso8601String(),
        'ultrasound_result': result,
        'stage': isConfirmed
            ? BreedingStage.gestacaoConfirmada.value
            : BreedingStage.falhou.value,
        'status': isConfirmed ? 'Gestação Confirmada' : 'Falhou',
        if (isConfirmed) 'expected_birth': birthEta.toIso8601String(),
        if (!isConfirmed) 'expected_birth': null,
      };

      await DatabaseService.updateBreedingRecord(widget.record.id, update);

      // Sincroniza o ANIMAL imediatamente (extra, além do service)
      final femaleId = widget.record.femaleAnimalId;
      if (femaleId != null && femaleId.isNotEmpty) {
        await DatabaseService.updateAnimal(femaleId, {
          'pregnant': isConfirmed ? 1 : 0,
          'expected_delivery': isConfirmed ? birthEta.toIso8601String() : null,
          'status': isConfirmed ? 'Gestante' : 'Saudável',
        });
      }

      // atualiza painel
      await context.read<AnimalService>().loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isConfirmed
                ? 'Gestação confirmada!'
                : 'Gestação não confirmada.'),
          ),
        );
        widget.onUpdate?.call();
      }
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Nascimento'),
        content: const Text('Confirma que o parto foi realizado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await DatabaseService.updateBreedingRecord(widget.record.id, {
        'birth_date': DateTime.now().toIso8601String(),
        'stage': BreedingStage.partoRealizado.value,
        'status': 'Parto Realizado',
      });

      // limpa marcação de gestante no animal
      final femaleId = widget.record.femaleAnimalId;
      if (femaleId != null && femaleId.isNotEmpty) {
        await DatabaseService.updateAnimal(femaleId, {
          'pregnant': 0,
          'expected_delivery': null,
          'status': 'Saudável',
        });
      }

      // atualiza painel
      await context.read<AnimalService>().loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nascimento registrado com sucesso!')),
        );
        widget.onUpdate?.call();
        
        // Buscar dados da mãe para pré-preencher o formulário
        final femaleId = widget.record.femaleAnimalId;
        print('🐑 DEBUG: femaleId = $femaleId');
        
        Animal? mother;
        if (femaleId != null && femaleId.isNotEmpty) {
          try {
            mother = await DatabaseService.getAnimalById(femaleId);
            print('🐑 DEBUG: Mother found - id: ${mother?.id}, code: ${mother?.code}, breed: ${mother?.breed}');
          } catch (e) {
            print('🐑 DEBUG ERROR: Failed to get mother data: $e');
          }
        }
        
        if (mounted) {
          // Abre formulário com dados da mãe pré-preenchidos (se disponível)
          showDialog(
            context: context,
            builder: (context) => AnimalFormDialog(
              motherId: mother?.id,
              motherCode: mother?.code,
              motherBreed: mother?.breed,
              presetCategory: 'Borrego',
            ),
          ).then((_) {
            // Recarrega dados após fechar o formulário
            widget.onUpdate?.call();
          });
        }
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
        return ElevatedButton.icon(
          onPressed: needsAction ? _separateAnimals : null,
          icon: const Icon(Icons.call_split),
          label: const Text('Separar Animais'),
          style: ElevatedButton.styleFrom(
            backgroundColor: needsAction ? Colors.orange : Colors.grey,
            foregroundColor: Colors.white,
          ),
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
