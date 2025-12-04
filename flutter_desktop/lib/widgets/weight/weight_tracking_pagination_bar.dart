import 'package:flutter/material.dart';

class WeightTrackingPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  final List<int>? itemsPerPageOptions;

  const WeightTrackingPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.onItemsPerPageChanged,
    this.itemsPerPageOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            ),
            Text('Página ${currentPage + 1} de $totalPages'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: currentPage < totalPages - 1
                  ? () => onPageChanged(currentPage + 1)
                  : null,
            ),
          ],
        ),
        if (onItemsPerPageChanged != null &&
            itemsPerPageOptions != null &&
            itemsPerPageOptions!.isNotEmpty)
          DropdownButton<int>(
            value: itemsPerPage,
            items: itemsPerPageOptions!
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text('$value por página'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onItemsPerPageChanged!(value);
            },
          ),
      ],
    );
  }
}
