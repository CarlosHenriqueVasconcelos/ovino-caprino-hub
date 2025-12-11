import 'package:flutter/material.dart';

import '../medication_management_screen.dart'
    show VaccinationStatusFilter, MedicationTabType;
import 'medication_list_section.dart'
    show MedicationTabConfig, MedicationListSection;

class VaccinationTabView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VaccinationStatusFilter selectedFilter;
  final ValueChanged<VaccinationStatusFilter> onFilterChanged;
  final VoidCallback onNewVaccination;
  final VoidCallback? onRegisterDose;
  final VoidCallback? onRefresh;
  final Map<String, MedicationTabType> selectedItems;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(Map<String, dynamic> record) onShowDetails;
  final void Function(Map<String, dynamic> record) onShowOptions;
  final ValueChanged<String> onApply;
  final ValueChanged<String> onCancel;
  final String Function(dynamic value) formatDate;

  const VaccinationTabView({
    super.key,
    required this.items,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onNewVaccination,
    this.onRegisterDose,
    this.onRefresh,
    required this.selectedItems,
    required this.onSelectionChanged,
    required this.onShowDetails,
    required this.onShowOptions,
    required this.onApply,
    required this.onCancel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VaccinationFiltersBar(
          selectedFilter: selectedFilter,
          onChanged: onFilterChanged,
        ),
        VaccinationActionsBar(
          onNewVaccination: onNewVaccination,
          onRegisterDose: onRegisterDose,
          onRefresh: onRefresh,
        ),
        Expanded(
          child: VaccinationTable(
            items: items,
            filter: selectedFilter,
            selectedItems: selectedItems,
            onSelectionChanged: onSelectionChanged,
            onShowDetails: onShowDetails,
            onShowOptions: onShowOptions,
            onApply: onApply,
            onCancel: onCancel,
            formatDate: formatDate,
          ),
        ),
      ],
    );
  }
}

class VaccinationFiltersBar extends StatelessWidget {
  final VaccinationStatusFilter selectedFilter;
  final ValueChanged<VaccinationStatusFilter> onChanged;

  const VaccinationFiltersBar({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: VaccinationStatusFilter.values.map((filter) {
          return ChoiceChip(
            label: Text(vaccinationStatusLabel(filter)),
            selected: selectedFilter == filter,
            onSelected: (_) => onChanged(filter),
          );
        }).toList(),
      ),
    );
  }
}

class VaccinationActionsBar extends StatelessWidget {
  final VoidCallback onNewVaccination;
  final VoidCallback? onRegisterDose;
  final VoidCallback? onRefresh;

  const VaccinationActionsBar({
    super.key,
    required this.onNewVaccination,
    this.onRegisterDose,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onNewVaccination,
            icon: const Icon(Icons.add),
            label: const Text('Nova vacinação'),
          ),
          OutlinedButton.icon(
            onPressed: onRegisterDose,
            icon: const Icon(Icons.check),
            label: const Text('Registrar dose'),
          ),
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class VaccinationTable extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final VaccinationStatusFilter filter;
  final Map<String, MedicationTabType> selectedItems;
  final void Function(String id, bool selected) onSelectionChanged;
  final void Function(Map<String, dynamic> record) onShowDetails;
  final void Function(Map<String, dynamic> record) onShowOptions;
  final ValueChanged<String> onApply;
  final ValueChanged<String> onCancel;
  final String Function(dynamic value) formatDate;

  const VaccinationTable({
    super.key,
    required this.items,
    required this.filter,
    required this.selectedItems,
    required this.onSelectionChanged,
    required this.onShowDetails,
    required this.onShowOptions,
    required this.onApply,
    required this.onCancel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final config = MedicationTabConfig(
      type: MedicationTabType.vaccinations,
      title: vaccinationStatusLabel(filter),
      icon: Icons.vaccines,
      items: items,
      isVaccination: true,
      allowActions: true,
      emptyMessage:
          'Nenhuma vacinação ${vaccinationStatusLabel(filter).toLowerCase()}',
    );

    return MedicationListSection(
      config: config,
      selectedItems: selectedItems,
      onSelectionChanged: onSelectionChanged,
      onShowDetails: onShowDetails,
      onShowOptions: onShowOptions,
      onApply: onApply,
      onCancel: onCancel,
      formatDate: formatDate,
    );
  }
}

String vaccinationStatusLabel(VaccinationStatusFilter filter) {
  switch (filter) {
    case VaccinationStatusFilter.overdue:
      return 'Atrasadas';
    case VaccinationStatusFilter.scheduled:
      return 'Agendadas';
    case VaccinationStatusFilter.applied:
      return 'Aplicadas';
    case VaccinationStatusFilter.cancelled:
      return 'Canceladas';
  }
}
