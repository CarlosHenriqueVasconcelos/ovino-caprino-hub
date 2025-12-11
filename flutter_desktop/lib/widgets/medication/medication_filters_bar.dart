import 'package:flutter/material.dart';

import '../medication_management_screen.dart' show MedicationStatusFilter;

class MedicationFiltersBar extends StatelessWidget {
  final MedicationStatusFilter statusFilter;
  final String searchTerm;
  final ValueChanged<String> onSearchChanged;
  final List<String> speciesOptions;
  final String? selectedSpecies;
  final ValueChanged<String?> onSpeciesChanged;
  final List<String> categoryOptions;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final DateTimeRange? dateRange;
  final VoidCallback onSelectDateRange;
  final VoidCallback onClearDateRange;
  final ValueChanged<MedicationStatusFilter> onStatusChanged;

  const MedicationFiltersBar({
    super.key,
    required this.statusFilter,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.speciesOptions,
    required this.selectedSpecies,
    required this.onSpeciesChanged,
    required this.categoryOptions,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.dateRange,
    required this.onSelectDateRange,
    required this.onClearDateRange,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: searchTerm,
                  decoration: const InputDecoration(
                    labelText: 'Buscar (animal, medicamento, nota...)',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: dateRange == null
                      ? onSelectDateRange
                      : onClearDateRange,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    dateRange == null
                        ? 'Período'
                        : '${_formatDay(dateRange!.start)} - ${_formatDay(dateRange!.end)}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: selectedSpecies,
                  decoration: const InputDecoration(labelText: 'Espécie'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todas'),
                    ),
                    ...speciesOptions.map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    ),
                  ],
                  onChanged: onSpeciesChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todas'),
                    ),
                    ...categoryOptions.map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    ),
                  ],
                  onChanged: onCategoryChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: MedicationStatusFilter.values.map((filter) {
              return ChoiceChip(
                label: Text(_statusLabel(filter)),
                selected: statusFilter == filter,
                onSelected: (_) => onStatusChanged(filter),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _formatDay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _statusLabel(MedicationStatusFilter filter) {
    switch (filter) {
      case MedicationStatusFilter.overdue:
        return 'Atrasados';
      case MedicationStatusFilter.scheduled:
        return 'Agendados';
      case MedicationStatusFilter.completed:
        return 'Aplicados';
      case MedicationStatusFilter.cancelled:
        return 'Cancelados';
      case MedicationStatusFilter.vaccinations:
        return 'Vacinações';
    }
  }
}
