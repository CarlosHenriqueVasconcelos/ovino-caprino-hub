import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

class HerdSecondaryActionsRow extends StatelessWidget {
  final VoidCallback onOpenFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onToggleIncludeSold;
  final bool includeSold;
  final bool hasAnyFilter;

  const HerdSecondaryActionsRow({
    super.key,
    required this.onOpenFilters,
    required this.onClearFilters,
    required this.onToggleIncludeSold,
    required this.includeSold,
    required this.hasAnyFilter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 335;

        final filtersButton = SizedBox(
          height: 35,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onOpenFilters,
              child: Ink(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.borderNeutral.withValues(alpha: 0.62),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_alt_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Filtros',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        final compactActions = Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.borderNeutral.withValues(alpha: 0.62),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onToggleIncludeSold,
                tooltip: includeSold ? 'Ocultar vendidos' : 'Incluir vendidos',
                iconSize: 14,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  includeSold ? Icons.stars_rounded : Icons.stars_outlined,
                  color: includeSold
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              Container(
                width: 1,
                height: 14,
                color: AppColors.borderNeutral.withValues(alpha: 0.64),
              ),
              PopupMenuButton<String>(
                tooltip: 'Mais ações',
                onSelected: (value) {
                  switch (value) {
                    case 'filters':
                      onOpenFilters();
                      break;
                    case 'include_sold':
                      onToggleIncludeSold();
                      break;
                    case 'clear':
                      if (hasAnyFilter) onClearFilters();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'filters',
                    child: Text('Abrir filtros'),
                  ),
                  PopupMenuItem<String>(
                    value: 'include_sold',
                    child: Text(
                      includeSold ? 'Ocultar vendidos' : 'Incluir vendidos',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'clear',
                    enabled: hasAnyFilter,
                    child: const Text('Limpar filtros'),
                  ),
                ],
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              filtersButton,
              const SizedBox(height: AppSpacing.xs),
              Align(alignment: Alignment.centerRight, child: compactActions),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: filtersButton),
            const SizedBox(width: AppSpacing.xs),
            compactActions,
          ],
        );
      },
    );
  }
}
