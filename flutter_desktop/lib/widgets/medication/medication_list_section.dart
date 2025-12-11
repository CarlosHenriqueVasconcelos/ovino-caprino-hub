import 'package:flutter/material.dart';

import '../../utils/animal_record_display.dart';
import '../medication_management_screen.dart' show MedicationTabType;

class MedicationTabConfig {
  final MedicationTabType type;
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> items;
  final bool allowActions;
  final bool isVaccination;
  final String emptyMessage;

  const MedicationTabConfig({
    required this.type,
    required this.title,
    required this.icon,
    required this.items,
    required this.allowActions,
    required this.isVaccination,
    required this.emptyMessage,
  });
}

class MedicationListSection extends StatelessWidget {
  final MedicationTabConfig config;
  final Map<String, MedicationTabType> selectedItems;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(Map<String, dynamic> record) onShowDetails;
  final void Function(Map<String, dynamic> record) onShowOptions;
  final ValueChanged<String>? onApply;
  final ValueChanged<String>? onCancel;
  final String Function(dynamic value) formatDate;

  const MedicationListSection({
    super.key,
    required this.config,
    required this.selectedItems,
    required this.onSelectionChanged,
    required this.onShowDetails,
    required this.onShowOptions,
    this.onApply,
    this.onCancel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final items = config.items;
    if (items.isEmpty) {
      return _SectionEmptyState(message: config.emptyMessage);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = items[index];
        final id = record['id'] as String;
        final selected = selectedItems[id] == config.type;

        return _MedicationRowCard(
          record: record,
          isVaccination: config.isVaccination,
          selected: selected,
          onSelectedChanged: (value) => onSelectionChanged(id, value),
          onShowDetails: () => onShowDetails(record),
          onShowOptions: () => onShowOptions(record),
          onApply: onApply,
          onCancel: onCancel,
          formatDate: formatDate,
        );
      },
    );
  }
}

class _MedicationRowCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final bool isVaccination;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;
  final VoidCallback onShowDetails;
  final VoidCallback onShowOptions;
  final ValueChanged<String>? onApply;
  final ValueChanged<String>? onCancel;
  final String Function(dynamic value) formatDate;

  const _MedicationRowCard({
    required this.record,
    required this.isVaccination,
    required this.selected,
    required this.onSelectedChanged,
    required this.onShowDetails,
    required this.onShowOptions,
    required this.onApply,
    required this.onCancel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final id = record['id'] as String;
    final status = record['status']?.toString() ?? 'Desconhecido';
    final statusColor = _statusColor(status);
    final statusIcon = _statusIcon(status);

    return InkWell(
      onTap: () => onSelectedChanged(!selected),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) => onSelectedChanged(value ?? false),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AnimalRecordDisplay.labelFromRecord(record),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AnimalRecordDisplay.colorFromRecord(record) ??
                              Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isVaccination
                            ? 'Vacina: ${record['vaccine_name'] ?? 'Sem nome'}'
                            : 'Medicamento: ${record['medication_name'] ?? 'Sem nome'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: onShowOptions,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Data: ${formatDate(isVaccination ? record['scheduled_date'] : record['date'])}',
                ),
              ],
            ),
            if (isVaccination)
              Row(
                children: [
                  const Icon(Icons.category_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Tipo: ${record['vaccine_type'] ?? 'N/A'}'),
                ],
              )
            else if (record['next_date'] != null)
              Row(
                children: [
                  const Icon(Icons.event_repeat, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Próxima: ${formatDate(record['next_date'])}'),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShowDetails,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver detalhes'),
                  ),
                ),
                if (onApply != null && onCancel != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onApply!(id),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Aplicar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onCancel!(id),
                      icon: const Icon(Icons.cancel, size: 18),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'agendado':
      case 'agendada':
        return Colors.orange;
      case 'aplicado':
      case 'aplicada':
        return Colors.green;
      case 'cancelado':
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'agendado':
      case 'agendada':
        return Icons.schedule;
      case 'aplicado':
      case 'aplicada':
        return Icons.check_circle;
      case 'cancelado':
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }
}

class _SectionEmptyState extends StatelessWidget {
  final String message;

  const _SectionEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
