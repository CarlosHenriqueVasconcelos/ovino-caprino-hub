import 'package:flutter/material.dart';
import '../models/breeding_record.dart';
import '../services/database_service.dart';

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
      await DatabaseService.updateBreedingRecord(widget.record.id, {
        'separation_date': DateTime.now().toIso8601String(),
        'stage': BreedingStage.aguardandoUltrassom.value,
        'status': 'Aguardando Ultrassom',
      });

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
      await DatabaseService.updateBreedingRecord(widget.record.id, {
        'ultrasound_date': DateTime.now().toIso8601String(),
        'ultrasound_result': result,
        'stage': isConfirmed
            ? BreedingStage.gestacaoConfirmada.value
            : BreedingStage.falhou.value,
        'status': isConfirmed ? 'Gestante' : 'Falhou',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isConfirmed
                  ? 'Gestação confirmada!'
                  : 'Gestação não confirmada.',
            ),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nascimento registrado com sucesso!')),
        );
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
