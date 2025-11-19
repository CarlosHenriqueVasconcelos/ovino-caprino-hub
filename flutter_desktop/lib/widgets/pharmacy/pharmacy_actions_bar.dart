import 'package:flutter/material.dart';

class PharmacyActionsBar extends StatelessWidget {
  final VoidCallback onNewMedication;
  final VoidCallback onRegisterEntry;
  final VoidCallback onRegisterExit;
  final VoidCallback onExport;

  const PharmacyActionsBar({
    super.key,
    required this.onNewMedication,
    required this.onRegisterEntry,
    required this.onRegisterExit,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: onNewMedication,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Novo medicamento'),
        ),
        OutlinedButton.icon(
          onPressed: onRegisterEntry,
          icon: const Icon(Icons.arrow_downward),
          label: const Text('Registrar entrada'),
        ),
        OutlinedButton.icon(
          onPressed: onRegisterExit,
          icon: const Icon(Icons.arrow_upward),
          label: const Text('Registrar saída'),
        ),
        TextButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.file_download),
          label: const Text('Exportar planilha'),
        ),
      ],
    );
  }
}
