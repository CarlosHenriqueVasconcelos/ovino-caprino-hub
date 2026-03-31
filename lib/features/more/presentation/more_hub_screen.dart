import 'package:flutter/material.dart';

import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/more_grid_section.dart';
import 'widgets/more_header.dart';
import 'widgets/more_module_card.dart';

class MoreHubScreen extends StatelessWidget {
  final List<MoreModuleItem> modules;
  final String selectedModuleKey;
  final ValueChanged<String> onOpenModule;

  const MoreHubScreen({
    super.key,
    required this.modules,
    required this.selectedModuleKey,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    final primaryModules =
        modules.where((module) => module.isPrimary).toList(growable: false);
    final secondaryModules =
        modules.where((module) => !module.isPrimary).toList(growable: false);
    final selected = modules
        .cast<MoreModuleItem?>()
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
          const MoreHeader(),
          const SizedBox(height: AppSpacing.md),
          MoreGridSection(
            title: 'Acesso Principal',
            subtitle: 'Módulos mais utilizados para análise e gestão geral',
            modules: primaryModules,
            selectedKey: selectedModuleKey,
            onOpenModule: onOpenModule,
          ),
          const SizedBox(height: AppSpacing.md),
          MoreGridSection(
            title: 'Configurações e Utilidades',
            subtitle: 'Ajustes do sistema e recursos de apoio',
            modules: secondaryModules,
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
                    Icons.open_in_new_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    selected == null
                        ? 'Selecione um módulo para continuar.'
                        : 'Próximo acesso: ${selected.title}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PrimaryButton(
                  label: selected == null ? 'Abrir Mais' : 'Continuar',
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
