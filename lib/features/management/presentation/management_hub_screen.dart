import 'package:flutter/material.dart';

import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/management_grid_section.dart';
import 'widgets/management_header.dart';
import 'widgets/management_module_card.dart';

class ManagementHubScreen extends StatelessWidget {
  final List<ManagementModuleItem> modules;
  final String selectedModuleKey;
  final ValueChanged<String> onOpenModule;

  const ManagementHubScreen({
    super.key,
    required this.modules,
    required this.selectedModuleKey,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    final primaryModules =
        modules.where((module) => module.isPrimary).toList(growable: false);
    final supportModules =
        modules.where((module) => !module.isPrimary).toList(growable: false);
    final selected = modules
        .cast<ManagementModuleItem?>()
        .firstWhere(
          (module) => module?.key == selectedModuleKey,
          orElse: () => null,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ManagementHeader(),
          const SizedBox(height: AppSpacing.md),
          ManagementGridSection(
            title: 'Operações Principais',
            subtitle: 'Módulos de uso diário para controle do rebanho',
            modules: primaryModules,
            selectedKey: selectedModuleKey,
            onOpenModule: onOpenModule,
          ),
          const SizedBox(height: AppSpacing.md),
          ManagementGridSection(
            title: 'Suporte Operacional',
            subtitle: 'Módulos complementares para registros e saúde',
            modules: supportModules,
            selectedKey: selectedModuleKey,
            onOpenModule: onOpenModule,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            variant: AppCardVariant.soft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    selected == null
                        ? 'Selecione um módulo para começar sua operação.'
                        : 'Próximo passo: ${selected.title}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PrimaryButton(
                  label: selected == null ? 'Abrir Manejo' : 'Continuar',
                  icon: Icons.arrow_forward,
                  onPressed: selected == null
                      ? null
                      : () => onOpenModule(selected.key),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
