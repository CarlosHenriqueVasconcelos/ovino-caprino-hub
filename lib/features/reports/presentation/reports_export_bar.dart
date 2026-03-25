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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16, 
        vertical: 8,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: onExportCsv,
                  icon: const Icon(Icons.file_download, size: 18),
                  label: const Text('Exportar CSV'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onSaveReport,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Salvar relatório'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            )
          : Row(
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
