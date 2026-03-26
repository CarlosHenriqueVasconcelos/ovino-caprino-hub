// lib/features/system/presentation/system_settings_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_logging.dart';
import '../../../devtools/devtools_screen.dart';
import '../../../models/animal.dart';
import '../../../services/animal_service.dart';
import '../../../services/backup_service.dart';
import '../../breeding/application/kinship_service.dart';
import '../../../services/system_maintenance_service.dart';

const bool _enableDevtools =
    kDebugMode || bool.fromEnvironment('ENABLE_DEVTOOLS');

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _vaccinationReminders = true;
  bool _birthReminders = true;
  bool _weightTracking = true;
  bool _loadingKinshipPolicy = true;
  bool _blockCousinBreeding = true;
  bool _autoBackup = false;
  String _backupFrequency = 'daily';

  @override
  void initState() {
    super.initState();
    _loadKinshipPolicy();
  }

  Future<void> _loadKinshipPolicy() async {
    try {
      final kinshipService = context.read<KinshipService>();
      final enabled = await kinshipService.getBlockCousinBreedingEnabled();
      if (!mounted) return;
      setState(() {
        _blockCousinBreeding = enabled;
        _loadingKinshipPolicy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingKinshipPolicy = false);
    }
  }

  Future<void> _setBlockCousinBreeding(bool enabled) async {
    final previous = _blockCousinBreeding;
    setState(() => _blockCousinBreeding = enabled);

    try {
      final kinshipService = context.read<KinshipService>();
      await kinshipService.setBlockCousinBreedingEnabled(enabled);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled
                ? 'Bloqueio entre primos ativado.'
                : 'Bloqueio entre primos desativado.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _blockCousinBreeding = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a regra de parentesco.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalService = context.read<AnimalService>();
    final AnimalStats? stats =
        context.select<AnimalService, AnimalStats?>((s) => s.stats);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Card
            Builder(
              builder: (context) {
                final isMobile = MediaQuery.of(context).size.width < 600;
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings,
                                size: isMobile ? 22 : 28, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isMobile ? 'Configurações' : 'Configurações do Sistema',
                                style: (isMobile ? theme.textTheme.titleLarge : theme.textTheme.headlineMedium)?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (!isMobile) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Configure notificações, gerencie backups e mantenha seus dados sempre seguros.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Notifications
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications,
                            color: theme.colorScheme.primary,
                            size: MediaQuery.of(context).size.width < 600 ? 20 : 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Notificações',
                              style: (MediaQuery.of(context).size.width < 600
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.titleLarge)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Ativar Notificações'),
                      subtitle: const Text('Receber alertas do sistema'),
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                    ),
                    if (_notificationsEnabled) ...[
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Lembretes de Vacinação'),
                        subtitle: const Text(
                            'Alertas quando vacinações estiverem próximas'),
                        value: _vaccinationReminders,
                        onChanged: (v) =>
                            setState(() => _vaccinationReminders = v),
                      ),
                      SwitchListTile(
                        title: const Text('Lembretes de Parto'),
                        subtitle: const Text('Alertas para partos previstos'),
                        value: _birthReminders,
                        onChanged: (v) => setState(() => _birthReminders = v),
                      ),
                      SwitchListTile(
                        title: const Text('Monitoramento de Peso'),
                        subtitle: const Text(
                            'Alertas para animais fora da faixa de peso ideal'),
                        value: _weightTracking,
                        onChanged: (v) => setState(() => _weightTracking = v),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Genética e Reprodução
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_tree,
                            color: theme.colorScheme.primary,
                            size: MediaQuery.of(context).size.width < 600 ? 20 : 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Genética e Reprodução',
                              style: (MediaQuery.of(context).size.width < 600
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.titleLarge)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_loadingKinshipPolicy)
                      const LinearProgressIndicator(minHeight: 2)
                    else
                      SwitchListTile(
                        title: const Text('Bloquear cruzamento entre primos'),
                        subtitle: const Text(
                          'Impede coberturas quando há avô/avó em comum.',
                        ),
                        value: _blockCousinBreeding,
                        onChanged: _setBlockCousinBreeding,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Backup & Dados
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.backup, color: theme.colorScheme.primary,
                            size: MediaQuery.of(context).size.width < 600 ? 20 : 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Backup e Dados',
                              style: (MediaQuery.of(context).size.width < 600
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.titleLarge)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Backup Automático'),
                      subtitle:
                          const Text('Fazer backup dos dados automaticamente'),
                      value: _autoBackup,
                      onChanged: (v) => setState(() => _autoBackup = v),
                    ),
                    if (_autoBackup) ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Frequência do Backup'),
                        subtitle: Text(_getBackupFrequencyLabel()),
                        trailing: DropdownButton<String>(
                          value: _backupFrequency,
                          items: const [
                            DropdownMenuItem(
                                value: 'daily', child: Text('Diário')),
                            DropdownMenuItem(
                                value: 'weekly', child: Text('Semanal')),
                            DropdownMenuItem(
                                value: 'monthly', child: Text('Mensal')),
                          ],
                          onChanged: (value) => setState(() =>
                              _backupFrequency = value ?? _backupFrequency),
                        ),
                      ),
                    ],
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _performBackup,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Fazer Backup Agora'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _restoreBackup,
                            icon: const Icon(Icons.cloud_download),
                            label: const Text('Restaurar Backup'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status do Banco
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage, color: theme.colorScheme.primary,
                            size: MediaQuery.of(context).size.width < 600 ? 20 : 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(MediaQuery.of(context).size.width < 600 ? 'Banco de Dados' : 'Status do Banco de Dados',
                              style: (MediaQuery.of(context).size.width < 600
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.titleLarge)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading:
                          Icon(Icons.storage, color: theme.colorScheme.primary),
                      title: const Text('Banco de Dados Local'),
                      subtitle: const Text(
                          'Todos os dados são armazenados localmente no dispositivo'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  theme.colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text('SQLite',
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ),
                    ),
                    const Divider(),
                    Builder(builder: (context) {
                      final totalAnimals = stats?.totalAnimals ?? 0;
                      return ListTile(
                        leading: Icon(Icons.analytics,
                            color: theme.colorScheme.secondary),
                        title: const Text('Total de Registros'),
                        subtitle: Text('$totalAnimals animais cadastrados'),
                        trailing: TextButton.icon(
                          onPressed: () => _showDataStatistics(animalService),
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Detalhes'),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logs de Erro
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: theme.colorScheme.primary,
                            size: MediaQuery.of(context).size.width < 600 ? 20 : 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(MediaQuery.of(context).size.width < 600 ? 'Logs de Erro' : 'Logs de Erro e Overflow',
                              style: (MediaQuery.of(context).size.width < 600
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.titleLarge)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, int>>(
                      future: Future.value(logService.getLogCounts()),
                      builder: (context, snapshot) {
                        final counts = snapshot.data ?? {};
                        final totalLogs = counts.values.fold(0, (a, b) => a + b);
                        
                        return Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.list_alt,
                                  color: theme.colorScheme.primary),
                              title: const Text('Total de Logs'),
                              subtitle: Text(
                                'Erros: ${counts['ERROR'] ?? 0} | '
                                'Overflows: ${counts['OVERFLOW'] ?? 0} | '
                                'Avisos: ${counts['WARNING'] ?? 0}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: totalLogs > 0
                                      ? theme.colorScheme.error.withValues(alpha: 0.1)
                                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: totalLogs > 0
                                        ? theme.colorScheme.error.withValues(alpha: 0.3)
                                        : theme.colorScheme.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '$totalLogs',
                                  style: TextStyle(
                                    color: totalLogs > 0
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(),
                            Builder(
                              builder: (ctx) {
                                final isMobile = MediaQuery.of(ctx).size.width < 600;
                                if (isMobile) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: _viewLogs,
                                        icon: const Icon(Icons.visibility, size: 18),
                                        label: const Text('Ver Logs'),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: totalLogs > 0 ? _exportLogs : null,
                                        icon: const Icon(Icons.share, size: 18),
                                        label: const Text('Exportar'),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: totalLogs > 0 ? _clearLogs : null,
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                        label: const Text('Limpar'),
                                      ),
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _viewLogs,
                                        icon: const Icon(Icons.visibility),
                                        label: const Text('Ver Logs'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: totalLogs > 0 ? _exportLogs : null,
                                        icon: const Icon(Icons.share),
                                        label: const Text('Exportar'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: totalLogs > 0 ? _clearLogs : null,
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('Limpar'),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ações do Sistema
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.build, color: theme.colorScheme.primary,
                            size: MediaQuery.of(context).size.width < 600 ? 20 : 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Ações do Sistema',
                              style: (MediaQuery.of(context).size.width < 600
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.titleLarge)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading:
                          Icon(Icons.info, color: theme.colorScheme.primary),
                      title: const Text('Sobre o BEGO Agritech'),
                      subtitle: const Text(
                          'Versão 1.0.0 - Sistema de Gestão Pecuária'),
                      onTap: _showAboutDialog,
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.help, color: theme.colorScheme.secondary),
                      title: const Text('Ajuda e Suporte'),
                      subtitle: const Text('Documentação e tutoriais'),
                      onTap: _showHelp,
                    ),
                    ListTile(
                      leading: Icon(Icons.bug_report,
                          color: theme.colorScheme.tertiary),
                      title: const Text('Reportar Problema'),
                      subtitle: const Text('Enviar feedback ou relatar bugs'),
                      onTap: _reportIssue,
                    ),
                    if (_enableDevtools)
                      ListTile(
                        leading:
                            Icon(Icons.biotech, color: theme.colorScheme.primary),
                        title: const Text('Ferramentas de Diagnóstico'),
                        subtitle:
                            const Text('Seed + cenários críticos (debug-only)'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DevToolsScreen(),
                            ),
                          );
                        },
                      ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.delete_forever,
                          color: theme.colorScheme.error),
                      title: const Text('Limpar Dados'),
                      subtitle: const Text(
                          'Apagar todos os dados locais (irreversível)'),
                      onTap: _confirmDataClear,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBackupFrequencyLabel() {
    switch (_backupFrequency) {
      case 'daily':
        return 'Todo dia às 02:00';
      case 'weekly':
        return 'Toda segunda-feira às 02:00';
      case 'monthly':
        return 'Todo dia 1º às 02:00';
      default:
        return 'Não configurado';
    }
  }

  Future<void> _performBackup() async {
    final backup = context.read<BackupService>();
    final stream = backup.backupAll();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Backup para Supabase'),
        content: StreamBuilder<String>(
          stream: stream,
          builder: (_, snap) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(snap.data ?? 'Preparando...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _restoreBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Backup'),
        content: const Text(
          'Esta ação substituirá todos os dados atuais pelos dados do backup do Supabase. '
          'Tem certeza de que deseja continuar?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performRestore();
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRestore() async {
    final backup = context.read<BackupService>();
    final stream = backup.restoreAll();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Restauração do Supabase'),
        content: StreamBuilder<String>(
          stream: stream,
          builder: (_, snap) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(snap.data ?? 'Preparando...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Atualiza UI recarregando dados
              context.read<AnimalService>().loadData();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showDataStatistics(AnimalService animalService) {
    final stats = animalService.stats;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas dos Dados'),
        content: stats != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem('Total de Animais', '${stats.totalAnimals}'),
                  _buildStatItem('Animais Saudáveis', '${stats.healthy}'),
                  _buildStatItem('Em Tratamento', '${stats.underTreatment}'),
                  _buildStatItem('Fêmeas Gestantes', '${stats.pregnant}'),
                  _buildStatItem(
                      'Peso Médio', '${stats.avgWeight.toStringAsFixed(1)} kg'),
                  _buildStatItem('Receita Total',
                      'R\$ ${stats.revenue.toStringAsFixed(2)}'),
                ],
              )
            : const Text('Dados não disponíveis'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🐑'),
            SizedBox(width: 8),
            Text('BEGO Agritech'),
            SizedBox(width: 8),
            Text('🐐')
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Sistema Completo de Gestão para Ovinocultura e Caprinocultura',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Versão: 1.0.0'),
            Text('Desenvolvido com Flutter'),
            Text('Integração: Supabase'),
            Text('Funciona Offline: Sim'),
            SizedBox(height: 16),
            Text(
              'Este sistema permite o controle completo do rebanho, desde o cadastro de animais até o controle financeiro, '
              'com funcionalidades offline para uso em campo.',
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'))
        ],
      ),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Abrindo documentação de ajuda...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _reportIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Abrindo formulário de feedback...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _viewLogs() {
    final logs = logService.getLogs();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logs de Erro e Overflow'),
        content: LayoutBuilder(
          builder: (context, constraints) {
            final media = MediaQuery.of(context).size;
            final maxHeight =
                (media.height * 0.7).clamp(320.0, 600.0).toDouble();
            final maxWidth =
                (media.width * 0.9).clamp(320.0, constraints.maxWidth).toDouble();

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
                maxWidth: maxWidth,
              ),
              child: SizedBox(
                width: double.maxFinite,
                child: logs.isEmpty
                    ? const Center(
                        child: Text('Nenhum log registrado'),
                      )
                    : ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          Color typeColor;
                          
                          switch (log.type) {
                            case 'ERROR':
                              typeColor = Theme.of(context).colorScheme.error;
                              break;
                            case 'OVERFLOW':
                              typeColor = Colors.orange;
                              break;
                            case 'WARNING':
                              typeColor = Colors.amber;
                              break;
                            default:
                              typeColor = Theme.of(context).colorScheme.primary;
                          }
                          
                          return ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                log.type,
                                style: TextStyle(
                                  color: typeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            title: Text(
                              log.message.split('\n').first,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              log.timestamp,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            onTap: () => _showLogDetails(log),
                          );
                        },
                      ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showLogDetails(dynamic log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${log.icon} Detalhes do Log'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tipo: ${log.type}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Data/Hora: ${log.timestamp}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mensagem:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                log.message,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportLogs() async {
    try {
      await logService.exportLogs();
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Logs exportados com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao exportar logs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Logs'),
        content: const Text('Deseja realmente limpar todos os logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await logService.clearLogs();
      if (!mounted) return;
      
      setState(() {}); // Atualizar contadores
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Logs limpos com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmDataClear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Limpar Todos os Dados')
          ],
        ),
        content: const Text(
          'ATENÇÃO: Esta ação irá apagar TODOS os dados locais permanentemente. '
          'Certifique-se de ter um backup antes de continuar. Esta ação NÃO PODE ser desfeita.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.of(context).pop();
              _clearAllData();
            },
            child: const Text('Limpar Dados'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    final maintenance = context.read<SystemMaintenanceService>();
    final animalService = context.read<AnimalService>();

    try {
      await maintenance.clearAllData();

      if (!mounted) return;

      // Atualiza a UI (recarrega animais, KPIs, etc.)
      await animalService.loadData();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Todos os dados locais foram removidos.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao limpar dados: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
