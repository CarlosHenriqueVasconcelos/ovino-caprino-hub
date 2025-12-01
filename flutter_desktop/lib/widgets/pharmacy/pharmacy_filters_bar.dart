import 'package:flutter/material.dart';

import '../../utils/responsive_utils.dart';
import 'pharmacy_enums.dart';

class PharmacyFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final StockStatusFilter statusFilter;
  final ValueChanged<StockStatusFilter> onStatusChanged;

  const PharmacyFiltersBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.statusFilter,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar medicamento',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: onClearSearch,
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: categories
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onCategoryChanged(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: StockStatusFilter.values.map((filter) {
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: statusFilter == filter,
                  onSelected: (_) => onStatusChanged(filter),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
