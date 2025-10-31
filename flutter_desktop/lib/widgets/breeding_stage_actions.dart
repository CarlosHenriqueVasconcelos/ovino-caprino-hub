import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/breeding_record.dart';
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
      final baseUltrasound = widget.record.ultrasoundDate ?? DateTime.now();
      final birthEta = baseUltrasound.add(const Duration(days: 150)); // ~5 meses

      final update = <String, dynamic>{
        'ultrasound_date':
            widget.record.ultrasoundDate?.toIso8601String() ?? baseUltrasound.toIso8601String(),
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
    final lambsCountController = TextEditingController();
    final lambsAliveController = TextEditingController();
    final lambsDeadController = TextEditingController();
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Nascimento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Informe os detalhes do parto:'),
              const SizedBox(height: 16),
              TextField(
                controller: lambsCountController,
                decoration: const InputDecoration(
                  labelText: 'Total de filhotes',
                  border: OutlineInputBorder(),
                  helperText: 'Total nascidos (vivos + natimortos)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lambsAliveController,
                decoration: const InputDecoration(
                  labelText: 'Filhotes vivos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lambsDeadController,
                decoration: const InputDecoration(
                  labelText: 'Natimortos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final lambsCount = int.tryParse(lambsCountController.text);
              final lambsAlive = int.tryParse(lambsAliveController.text) ?? 0;
              final lambsDead = int.tryParse(lambsDeadController.text) ?? 0;
              
              Navigator.pop(context, {
                'lambsCount': lambsCount,
                'lambsAlive': lambsAlive,
                'lambsDead': lambsDead,
              });
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (result == null) return;

    setState(() => _isProcessing = true);

    try {
      await DatabaseService.updateBreedingRecord(widget.record.id, {
        'birth_date': DateTime.now().toIso8601String(),
        'stage': BreedingStage.partoRealizado.value,
        'status': 'Parto Realizado',
        'lambs_count': result['lambsCount'],
        'lambs_alive': result['lambsAlive'],
        'lambs_dead': result['lambsDead'],
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
        
        // Abre automaticamente o formulário de novo animal
        showDialog(
          context: context,
          builder: (context) => const AnimalFormDialog(),
        ).then((_) {
          // Recarrega dados após fechar o formulário
          widget.onUpdate?.call();
        });
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
