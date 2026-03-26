import 'package:flutter/material.dart';

class MedicationActionsBar extends StatelessWidget {
  final VoidCallback onAddMedication;
  final VoidCallback onAddVaccination;
  final VoidCallback onExport;
  final VoidCallback onViewHistory;
  final int selectionCount;
  final VoidCallback? onClearSelection;

  const MedicationActionsBar({
    super.key,
    required this.onAddMedication,
    required this.onAddVaccination,
    required this.onExport,
    required this.onViewHistory,
    required this.selectionCount,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onAddMedication,
            icon: const Icon(Icons.medication_outlined),
            label: const Text('Nova medicação'),
          ),
          ElevatedButton.icon(
            onPressed: onAddVaccination,
            icon: const Icon(Icons.vaccines_outlined),
            label: const Text('Nova vacinação'),
          ),
          OutlinedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.ios_share),
            label: const Text('Exportar'),
          ),
          OutlinedButton.icon(
            onPressed: onViewHistory,
            icon: const Icon(Icons.history),
            label: const Text('Histórico'),
          ),
          if (selectionCount > 0) ...[
            Chip(
              avatar: const Icon(Icons.check_box, size: 18),
              label: Text('$selectionCount selecionado(s)'),
            ),
            TextButton(
              onPressed: onClearSelection,
              child: const Text('Limpar seleção'),
            ),
          ],
        ],
      ),
    );
  }
}
