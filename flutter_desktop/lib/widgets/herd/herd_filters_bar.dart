import 'package:flutter/material.dart';

import '../../utils/animal_display_utils.dart';

class HerdFiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final bool includeSold;
  final ValueChanged<bool> onIncludeSoldChanged;
  final String? statusFilter;
  final List<String> statusOptions;
  final ValueChanged<String?> onStatusChanged;
  final String? colorFilter;
  final List<String> colorOptions;
  final ValueChanged<String?> onColorChanged;
  final String? categoryFilter;
  final List<String> categoryOptions;
  final ValueChanged<String?> onCategoryChanged;

  const HerdFiltersBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.includeSold,
    required this.onIncludeSoldChanged,
    required this.statusFilter,
    required this.statusOptions,
    required this.onStatusChanged,
    required this.colorFilter,
    required this.colorOptions,
    required this.onColorChanged,
    required this.categoryFilter,
    required this.categoryOptions,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText:
                'Buscar por nome, código, categoria ou raça (filtra em tempo real)',
            border: const OutlineInputBorder(),
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
        const SizedBox(height: 24),
        FilterChip(
          label: const Text('Incluir vendidos'),
          selected: includeSold,
          onSelected: (value) => onIncludeSoldChanged(value),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: statusFilter == null,
              onSelected: (_) => onStatusChanged(null),
            ),
            ...statusOptions.map(
              (status) => ChoiceChip(
                label: Text(status == 'Saudável' ? 'Saudáveis' : status),
                selected: statusFilter == status,
                onSelected: (_) => onStatusChanged(status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Filtrar por Cor:', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todas'),
              selected: colorFilter == null,
              onSelected: (_) => onColorChanged(null),
            ),
            ...colorOptions.map(
              (color) {
                final colorName = AnimalDisplayUtils.getColorName(color);
                return ChoiceChip(
                  label: Text(colorName),
                  selected: colorFilter == color,
                  onSelected: (_) => onColorChanged(color),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Filtrar por Categoria:', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Todas'),
              selected: categoryFilter == null,
              onSelected: (_) => onCategoryChanged(null),
            ),
            ...categoryOptions.map(
              (category) => ChoiceChip(
                label: Text(category),
                selected: categoryFilter == category,
                onSelected: (_) => onCategoryChanged(category),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

