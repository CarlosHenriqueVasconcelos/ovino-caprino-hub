import 'package:flutter/material.dart';

import '../../../../shared/widgets/common/app_card.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

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
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shouldStack = constraints.maxWidth < 560;
          final paginationControls = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
                ),
                Text(
                  'Página ${currentPage + 1} de $totalPages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages - 1
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                ),
              ],
            ),
          );

          final hasItemsPerPage =
              onItemsPerPageChanged != null &&
              itemsPerPageOptions != null &&
              itemsPerPageOptions!.isNotEmpty;
          final itemsPerPageDropdown = hasItemsPerPage
              ? DropdownButton<int>(
                  value: itemsPerPage,
                  items: itemsPerPageOptions!
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text('$value / pág.'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) onItemsPerPageChanged!(value);
                  },
                )
              : null;

          if (shouldStack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                paginationControls,
                if (itemsPerPageDropdown != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  itemsPerPageDropdown,
                ],
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: paginationControls),
              if (itemsPerPageDropdown != null) itemsPerPageDropdown,
            ],
          );
        },
      ),
    );
  }
}
