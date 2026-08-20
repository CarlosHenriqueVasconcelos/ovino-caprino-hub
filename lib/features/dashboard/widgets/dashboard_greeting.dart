import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({super.key});

  String _greeting(String? farmName) {
    final displayName = (farmName != null && farmName.trim().isNotEmpty)
        ? farmName.trim()
        : 'Fazenda';
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia, $displayName';
    if (hour < 18) return 'Boa tarde, $displayName';
    return 'Boa noite, $displayName';
  }

  String _formattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final raw = formatter.format(now);
    // Capitaliza primeira letra
    return raw[0].toUpperCase() + raw.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farmName = context.select<AuthService, String?>(
      (auth) => auth.currentFarmName,
    );
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
        top: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formattedDate(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                _greeting(farmName),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('👋', style: TextStyle(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
