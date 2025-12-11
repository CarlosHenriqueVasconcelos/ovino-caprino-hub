import 'package:flutter/material.dart';

import '../medication_management_screen.dart'
    show MedicationTabType, VaccinationStatusFilter;
import 'medication_list_section.dart';
import 'vaccination_tab_view.dart';

class MedicationTabs extends StatelessWidget {
  final TabController controller;
  final List<MedicationTabConfig> configs;
  final List<Map<String, dynamic>> vaccinationItems;
  final VaccinationStatusFilter vaccinationFilter;
  final ValueChanged<VaccinationStatusFilter> onVaccinationFilterChanged;
  final VoidCallback onNewVaccination;
  final VoidCallback? onRegisterVaccinationDose;
  final VoidCallback? onRefreshVaccinations;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, MedicationTabType> selectedItems;
  final void Function(String id, MedicationTabType type, bool selected)
      onSelectionChanged;
  final void Function(Map<String, dynamic> data, bool isVaccination)
      onShowDetails;
  final void Function(Map<String, dynamic> data, bool isVaccination)
      onShowOptions;
  final void Function(String id, bool isVaccination) onApply;
  final void Function(String id, bool isVaccination) onCancel;
  final String Function(dynamic value) formatDate;

  const MedicationTabs({
    super.key,
    required this.controller,
    required this.configs,
    required this.vaccinationItems,
    required this.vaccinationFilter,
    required this.onVaccinationFilterChanged,
    required this.onNewVaccination,
    this.onRegisterVaccinationDose,
    this.onRefreshVaccinations,
    required this.isLoading,
    required this.errorMessage,
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
    final tabs = [
      ...configs.map(
        (config) => Tab(
          icon: Icon(config.icon),
          text: config.title,
        ),
      ),
      const Tab(icon: Icon(Icons.vaccines), text: 'Vacinações'),
    ];

    return Column(
      children: [
        TabBar(
          controller: controller,
          isScrollable: true,
          tabs: tabs,
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (errorMessage != null) {
                return Center(child: Text(errorMessage!));
              }

              return TabBarView(
                controller: controller,
                children: [
                  for (final config in configs)
                    MedicationListSection(
                      config: config,
                      selectedItems: selectedItems,
                      onSelectionChanged: (id, selected) =>
                          onSelectionChanged(id, config.type, selected),
                      onShowDetails: (record) =>
                          onShowDetails(record, config.isVaccination),
                      onShowOptions: (record) =>
                          onShowOptions(record, config.isVaccination),
                      onApply: config.allowActions
                          ? (id) => onApply(id, config.isVaccination)
                          : null,
                      onCancel: config.allowActions
                          ? (id) => onCancel(id, config.isVaccination)
                          : null,
                      formatDate: formatDate,
                    ),
                  VaccinationTabView(
                    items: vaccinationItems,
                    selectedFilter: vaccinationFilter,
                    onFilterChanged: onVaccinationFilterChanged,
                    onNewVaccination: onNewVaccination,
                    onRegisterDose: onRegisterVaccinationDose,
                    onRefresh: onRefreshVaccinations,
                    selectedItems: selectedItems,
                    onSelectionChanged: (id, selected) =>
                        onSelectionChanged(
                          id,
                          MedicationTabType.vaccinations,
                          selected,
                        ),
                    onShowDetails: (record) =>
                        onShowDetails(record, true),
                    onShowOptions: (record) =>
                        onShowOptions(record, true),
                    onApply: (id) => onApply(id, true),
                    onCancel: (id) => onCancel(id, true),
                    formatDate: formatDate,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
