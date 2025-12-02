import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

class NotesFiltersBar extends StatelessWidget {
  final TextEditingController? searchController;
  final ValueChanged<String> onSearchChanged;
  final List<String> categoryOptions;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final List<String> priorityOptions;
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;
  final bool showOnlyUnread;
  final ValueChanged<bool> onShowOnlyUnreadChanged;

  const NotesFiltersBar({
    super.key,
    this.searchController,
    required this.onSearchChanged,
    required this.categoryOptions,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.priorityOptions,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.showOnlyUnread,
    required this.onShowOnlyUnreadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Material(
      elevation: 2,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getPadding(context),
          vertical: 8,
        ),
        child: Wrap(
          spacing: ResponsiveUtils.getSpacing(context),
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : 260,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar anotações',
                  hintText: isMobile ? 'Pesquisar...' : null,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: onSearchChanged,
              ),
            ),
            SizedBox(
              width: isMobile ? (MediaQuery.of(context).size.width - 48) / 2 : 180,
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: categoryOptions
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onCategoryChanged(value);
                },
              ),
            ),
            SizedBox(
              width: isMobile ? (MediaQuery.of(context).size.width - 48) / 2 : 160,
              child: DropdownButtonFormField<String>(
                value: selectedPriority,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                ),
                items: priorityOptions
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onPriorityChanged(value);
                },
              ),
            ),
            isMobile
                ? SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Switch(
                          value: showOnlyUnread,
                          onChanged: onShowOnlyUnreadChanged,
                        ),
                        Expanded(
                          child: Text(
                            'Apenas não lidas',
                            style: const TextStyle(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: showOnlyUnread,
                        onChanged: onShowOnlyUnreadChanged,
                      ),
                      const Text('Mostrar apenas não lidas'),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
