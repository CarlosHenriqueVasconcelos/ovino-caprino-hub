import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class AppSectionOption {
  final String key;
  final String label;
  final IconData icon;

  const AppSectionOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class AppSectionSwitcher extends StatelessWidget {
  final List<AppSectionOption> options;
  final String selectedKey;
  final ValueChanged<String> onChanged;
  final VoidCallback? onOpenMenu;
  final EdgeInsetsGeometry? padding;

  const AppSectionSwitcher({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.onChanged,
    this.onOpenMenu,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderNeutral.withValues(alpha: 0.82),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      selected: option.key == selectedKey,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(option.icon, size: 16),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(option.label),
                        ],
                      ),
                      onSelected: (_) => onChanged(option.key),
                    ),
                  ),
                ),
                if (onOpenMenu != null)
                  IconButton(
                    tooltip: 'Abrir menu completo',
                    onPressed: onOpenMenu,
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
