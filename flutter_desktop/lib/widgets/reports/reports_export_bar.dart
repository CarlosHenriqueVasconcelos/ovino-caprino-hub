import 'package:flutter/material.dart';

class ReportsExportBar extends StatelessWidget {
  final VoidCallback onExportCsv;
  final VoidCallback onSaveReport;

  const ReportsExportBar({
    super.key,
    required this.onExportCsv,
    required this.onSaveReport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: onExportCsv,
            icon: const Icon(Icons.file_download),
            label: const Text('Exportar CSV'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onSaveReport,
            icon: const Icon(Icons.save),
            label: const Text('Salvar relatório'),
          ),
        ],
      ),
    );
  }
}

