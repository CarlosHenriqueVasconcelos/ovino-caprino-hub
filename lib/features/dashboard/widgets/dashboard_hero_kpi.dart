import 'package:flutter/material.dart';

import '../../../models/animal.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardHeroKpi extends StatelessWidget {
  final AnimalStats stats;

  const DashboardHeroKpi({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final birthsThisMonth = stats.birthsThisMonth;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A7D50),
            Color(0xFF2F8F5B),
            Color(0xFF3AA068),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'TOTAL DE ANIMAIS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Total + espécies
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Número grande
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.totalAnimals}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (birthsThisMonth > 0)
                    Text(
                      '+$birthsThisMonth este mês',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      'animais ativos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              // Chips espécies
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (stats.ovinoCount > 0)
                    _SpeciesChip(
                      label: 'Ovinos ${stats.ovinoCount}',
                      icon: '🐑',
                    ),
                  if (stats.ovinoCount > 0 && stats.caprinoCount > 0)
                    const SizedBox(height: 6),
                  if (stats.caprinoCount > 0)
                    _SpeciesChip(
                      label: 'Caprinos ${stats.caprinoCount}',
                      icon: '🐐',
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeciesChip extends StatelessWidget {
  final String label;
  final String icon;

  const _SpeciesChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
