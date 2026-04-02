import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

class HerdPrimaryChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  const HerdPrimaryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  static const List<({String label, String? value})> _options = [
    (label: 'Todos', value: null),
    (label: 'Adulto', value: 'Adulto'),
    (label: 'Borrego', value: 'Borrego'),
    (label: 'Matriz', value: 'Matriz'),
  ];

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: _options.map((option) {
        final selected = selectedCategory == option.value;
        final isAll = option.value == null;
        return _CategoryChip(
          label: option.label,
          selected: isAll ? selectedCategory == null : selected,
          style: style,
          onTap: () => onSelected(option.value),
        );
      }).toList(growable: false),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final TextStyle? style;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.borderNeutral.withValues(alpha: 0.95),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: style?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
