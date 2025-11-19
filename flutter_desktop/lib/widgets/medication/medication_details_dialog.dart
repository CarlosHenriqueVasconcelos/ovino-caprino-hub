import 'package:flutter/material.dart';

class MedicationDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  final String animalLabel;
  final bool isVaccination;

  const MedicationDetailsDialog({
    super.key,
    required this.data,
    required this.animalLabel,
    required this.isVaccination,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isVaccination
        ? (data['status'] == 'Aplicada'
            ? Colors.green
            : data['status'] == 'Cancelada'
                ? Colors.red
                : Colors.orange)
        : const Color(0xFF6366F1);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isVaccination ? Icons.vaccines : Icons.medication,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVaccination ? 'Detalhes da Vacina' : 'Detalhes do Medicamento',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVaccination
                              ? data['vaccine_name'] ?? 'Sem nome'
                              : data['medication_name'] ?? 'Sem nome',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      icon: Icons.pets,
                      title: 'Animal',
                      content: animalLabel,
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      icon: isVaccination ? Icons.vaccines : Icons.medication,
                      title: isVaccination
                          ? 'Nome da Vacina'
                          : 'Nome do Medicamento',
                      content: isVaccination
                          ? data['vaccine_name'] ?? 'N/A'
                          : data['medication_name'] ?? 'N/A',
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),
                    if (isVaccination) ...[
                      _buildDetailSection(
                        icon: Icons.category,
                        title: 'Tipo de Vacina',
                        content: data['vaccine_type'] ?? 'N/A',
                        color: accentColor,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.info_outline,
                        title: 'Status',
                        content: data['status'] ?? 'N/A',
                        color: accentColor,
                      ),
                    ] else ...[
                      _buildDetailSection(
                        icon: Icons.medication_liquid,
                        title: 'Dosagem',
                        content: data['dosage'] ?? 'N/A',
                        color: accentColor,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildDetailSection(
                      icon: Icons.calendar_today,
                      title:
                          isVaccination ? 'Data Agendada' : 'Data de Aplicação',
                      content: _formatDate(isVaccination
                          ? data['scheduled_date']
                          : data['date']),
                      color: accentColor,
                    ),
                    if (isVaccination && data['applied_date'] != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.event_available,
                        title: 'Data de Aplicação',
                        content: _formatDate(data['applied_date']),
                        color: accentColor,
                      ),
                    ],
                    if (!isVaccination && data['next_date'] != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.event_repeat,
                        title: 'Próxima Aplicação',
                        content: _formatDate(data['next_date']),
                        color: accentColor,
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (data['veterinarian'] != null &&
                        data['veterinarian'].toString().isNotEmpty)
                      _buildDetailSection(
                        icon: Icons.person,
                        title: 'Veterinário',
                        content: data['veterinarian'],
                        color: accentColor,
                      ),
                    if (data['veterinarian'] != null &&
                        data['veterinarian'].toString().isNotEmpty)
                      const SizedBox(height: 16),
                    if (data['notes'] != null &&
                        data['notes'].toString().isNotEmpty)
                      _buildDetailSection(
                        icon: Icons.notes,
                        title: 'Observações',
                        content: data['notes'],
                        color: accentColor,
                        isMultiline: true,
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return date.toString();
    }
  }
}
