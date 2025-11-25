import 'package:flutter/material.dart';

class WeightFilterDropdownConfig {
  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const WeightFilterDropdownConfig({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });
}

class WeightTrackingFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchLabel;
  final String? searchHint;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final DateTimeRange? dateRange;
  final VoidCallback? onSelectDateRange;
  final VoidCallback? onClearDateRange;
  final List<WeightFilterDropdownConfig> dropdowns;
  final List<Widget>? extraFilters;

  const WeightTrackingFiltersBar({
    super.key,
    required this.searchController,
    required this.searchLabel,
    this.searchHint,
    required this.onSearchChanged,
    required this.onClearSearch,
    this.dateRange,
    this.onSelectDateRange,
    this.onClearDateRange,
    this.dropdowns = const [],
    this.extraFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: searchLabel,
                      hintText: searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: onClearSearch,
                            )
                          : null,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                if (onSelectDateRange != null) ...[
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
              ],
            ),
            if (dropdowns.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: dropdowns.map((dropdown) {
                  return SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      value: dropdown.value,
                      decoration: InputDecoration(labelText: dropdown.label),
                      items: dropdown.options
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) dropdown.onChanged(value);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
            if (extraFilters != null && extraFilters!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...extraFilters!,
            ],
          ],
        ),
      ),
    );
  }

  String _formatDay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
