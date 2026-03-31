import 'package:flutter/material.dart';

import '../../../../shared/widgets/buttons/ghost_button.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/search_field.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../utils/animal_display_utils.dart';

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
    return AppCard(
      variant: AppCardVariant.outlined,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      borderColor: AppColors.borderNeutral.withValues(alpha: 0.78),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Busca e Filtros',
            subtitle: 'Refine a listagem por status, cor e categoria',
            action: GhostButton(
              label: 'Limpar filtros',
              icon: Icons.cleaning_services_outlined,
              onPressed: _hasAnyFilter()
                  ? () {
                      onClearSearch();
                      onIncludeSoldChanged(false);
                      onStatusChanged(null);
                      onColorChanged(null);
                      onCategoryChanged(null);
                    }
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SearchField(
            controller: searchController,
            labelText: 'Buscar animal',
            hintText: 'Buscar por nome, código, categoria ou raça',
            onChanged: onSearchChanged,
            onClear: onClearSearch,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderNeutral.withValues(alpha: 0.8)),
            ),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                FilterChip(
                  label: const Text('Incluir vendidos'),
                  selected: includeSold,
                  onSelected: onIncludeSoldChanged,
                ),
                ..._activeFilterChips(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FilterGroup(
            title: 'Status',
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
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
                    avatar: Icon(_statusIcon(status), size: 16),
                    onSelected: (_) => onStatusChanged(status),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _FilterGroup(
            title: 'Cor',
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
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
          ),
          const SizedBox(height: AppSpacing.md),
          _FilterGroup(
            title: 'Categoria',
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
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
          ),
        ],
      ),
    );
  }

  bool _hasAnyFilter() {
    return searchController.text.trim().isNotEmpty ||
        includeSold ||
        statusFilter != null ||
        colorFilter != null ||
        categoryFilter != null;
  }

  List<Widget> _activeFilterChips() {
    final chips = <Widget>[];
    if (statusFilter != null) {
      chips.add(
        StatusChip(
          label: 'Status: ${statusFilter == 'Saudável' ? 'Saudáveis' : statusFilter}',
          variant: StatusChipVariant.info,
          icon: Icons.flag_outlined,
        ),
      );
    }
    if (colorFilter != null) {
      chips.add(
        StatusChip(
          label: 'Cor: ${AnimalDisplayUtils.getColorName(colorFilter!)}',
          variant: StatusChipVariant.neutral,
          icon: Icons.palette_outlined,
        ),
      );
    }
    if (categoryFilter != null) {
      chips.add(
        StatusChip(
          label: 'Categoria: $categoryFilter',
          variant: StatusChipVariant.success,
          icon: Icons.category_outlined,
        ),
      );
    }
    return chips;
  }

  IconData _statusIcon(String value) {
    switch (value) {
      case 'Saudável':
        return Icons.health_and_safety_outlined;
      case 'Em tratamento':
        return Icons.medical_services_outlined;
      case 'Ferido':
        return Icons.healing_outlined;
      case 'Vendido':
        return Icons.sell_outlined;
      case 'Óbito':
        return Icons.heart_broken_outlined;
      default:
        return Icons.flag_outlined;
    }
  }
}

class _FilterGroup extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterGroup({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderNeutral.withValues(alpha: 0.8)),
          ),
          child: child,
        ),
      ],
    );
  }
}
