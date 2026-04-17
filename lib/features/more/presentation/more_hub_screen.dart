import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/auth_service.dart';
import '../../../services/sync_service.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/app_brand_header.dart';
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
          const AppBrandHeader(
            title: 'Fazenda São Petrônio',
            subtitle: 'Gestão de Ovinos e Caprinos',
            margin: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.xs),
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
          const SizedBox(height: AppSpacing.md),
          _SyncCard(),
          const SizedBox(height: AppSpacing.md),
          _LogoutCard(),
        ],
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.soft,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Sair da conta',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => _confirmLogout(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthService>().signOut();
    }
  }
}

class _SyncCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();
    final theme = Theme.of(context);

    final (icon, color, label) = switch (sync.status) {
      SyncStatus.syncing => (
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          AppColors.primary,
          'Sincronizando…',
        ),
      SyncStatus.success => (
          const Icon(Icons.cloud_done_outlined, color: AppColors.success, size: 20),
          AppColors.success,
          _formatLastSync(sync.lastSyncAt),
        ),
      SyncStatus.error => (
          const Icon(Icons.cloud_off_outlined, color: AppColors.error, size: 20),
          AppColors.error,
          'Erro na sincronização',
        ),
      SyncStatus.idle => (
          const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 20),
          AppColors.primary,
          'Nunca sincronizado',
        ),
    };

    return AppCard(
      variant: AppCardVariant.soft,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sincronizar dados',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: sync.isSyncing ? null : () => context.read<SyncService>().sync(),
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );
  }

  static String _formatLastSync(DateTime? dt) {
    if (dt == null) return 'Nunca sincronizado';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Sincronizado agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    return 'Há ${diff.inDays} dia(s)';
  }
}
