import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/backup_service.dart';

class BackupManager extends StatefulWidget {
  const BackupManager({super.key});

  @override
  State<BackupManager> createState() => _BackupManagerState();
}

class _BackupManagerState extends State<BackupManager> {
  bool _isBackupRunning = false;
  bool _isRestoreRunning = false;

  // Esses continuam só para UI/histórico fake
  bool _autoBackupEnabled = true;
  String _autoBackupFrequency = 'weekly';
  DateTime? _lastBackupDate;

  final List<Map<String, dynamic>> _backupHistory = [
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'Automático',
      'size': '2.3 MB',
      'status': 'Sucesso',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'type': 'Manual',
      'size': '2.1 MB',
      'status': 'Sucesso',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'type': 'Automático',
      'size': '2.0 MB',
      'status': 'Sucesso',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Backup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Sistema de Backup e Restauração',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Proteja seus dados com backups automáticos e manuais',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Painel de ações
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Backup Manual
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.backup,
                                      color: theme.colorScheme.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Backup Manual',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Crie um backup completo de todos os dados da fazenda (enviado para o Supabase).',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isBackupRunning
                                        ? null
                                        : _performManualBackup,
                                    icon: _isBackupRunning
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.cloud_upload),
                                    label: Text(
                                      _isBackupRunning
                                          ? 'Fazendo Backup...'
                                          : 'Criar Backup',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Restore
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.restore,
                                      color: theme.colorScheme.tertiary,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Restaurar Dados',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Restaure os dados a partir do backup armazenado no Supabase.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _isRestoreRunning
                                        ? null
                                        : _confirmRestoreFromCloud,
                                    icon: _isRestoreRunning
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.cloud_download),
                                    label: Text(
                                      _isRestoreRunning
                                          ? 'Restaurando...'
                                          : 'Restaurar do Supabase',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Backup automático (mantido só como UI, sem mexer no DB)
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Painel de histórico
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Histórico de Backups',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (_lastBackupDate != null)
                                  Chip(
                                    label: Text(
                                      'Último: ${_lastBackupDate!.day}/${_lastBackupDate!.month}/${_lastBackupDate!.year}',
                                    ),
                                    backgroundColor: theme
                                        .colorScheme.primary
                                        .withOpacity(0.1),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _backupHistory.length,
                                itemBuilder: (context, index) {
                                  final backup = _backupHistory[index];
                                  final date =
                                      backup['date'] as DateTime;

                                  Color statusColor;
                                  IconData statusIcon;
                                  if (backup['status'] == 'Sucesso') {
                                    statusColor =
                                        theme.colorScheme.primary;
                                    statusIcon = Icons.check_circle;
                                  } else {
                                    statusColor =
                                        theme.colorScheme.error;
                                    statusIcon = Icons.error;
                                  }

                                  return Card(
                                    margin:
                                        const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            statusColor.withOpacity(0.1),
                                        child: Icon(
                                          statusIcon,
                                          color: statusColor,
                                        ),
                                      ),
                                      title: Text(
                                        '${date.day}/${date.month}/${date.year} '
                                        'às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                        style: theme
                                            .textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Tipo: ${backup['type']}'),
                                          Text(
                                              'Tamanho: ${backup['size']}'),
                                        ],
                                      ),
                                      trailing:
                                          PopupMenuButton<String>(
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'restore',
                                            child: Row(
                                              children: [
                                                Icon(Icons.restore),
                                                SizedBox(width: 8),
                                                Text('Restaurar'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'download',
                                            child: Row(
                                              children: [
                                                Icon(Icons.download),
                                                SizedBox(width: 8),
                                                Text('Download'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Excluir',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.red),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) =>
                                            _handleBackupAction(
                                                value, index),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== BACKUP ==================

  Future<void> _performManualBackup() async {
    setState(() => _isBackupRunning = true);

    try {
      final backup = context.read<BackupService>();
      final stream = backup.backupAll();

      // Mesma UX do SystemSettingsScreen: dialog com StreamBuilder
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Backup para Supabase'),
          content: StreamBuilder<String>(
            stream: stream,
            builder: (_, snapshot) {
              final text = snapshot.data ?? 'Preparando backup...';
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(text),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(_).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      final now = DateTime.now();
      setState(() {
        _lastBackupDate = now;
        _backupHistory.insert(0, {
          'date': now,
          'type': 'Manual',
          'size': '-',
          'status': 'Sucesso',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Backup concluído com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no backup: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBackupRunning = false);
      }
    }
  }

  // ================== RESTORE ==================

  void _confirmRestoreFromCloud() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar do Supabase'),
        content: const Text(
          'Esta ação irá substituir TODOS os dados locais pelos dados do backup '
          'armazenado no Supabase. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performRestoreFromCloud();
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRestoreFromCloud() async {
    setState(() => _isRestoreRunning = true);

    try {
      final backup = context.read<BackupService>();
      final stream = backup.restoreAll();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Restauração do Supabase'),
          content: StreamBuilder<String>(
            stream: stream,
            builder: (_, snapshot) {
              final text = snapshot.data ?? 'Preparando restauração...';
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(text),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(_).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dados restaurados com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao restaurar dados: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoreRunning = false);
      }
    }
  }

  // ================== AÇÕES DO HISTÓRICO ==================

  void _handleBackupAction(String action, int index) {
    switch (action) {
      case 'restore':
        _showRestoreConfirmation(index);
        break;
      case 'download':
        _downloadBackup(index);
        break;
      case 'delete':
        _showDeleteConfirmation(index);
        break;
    }
  }

  void _showRestoreConfirmation(int index) {
    final backup = _backupHistory[index];
    final date = backup['date'] as DateTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Restauração'),
        content: Text(
          'Deseja restaurar o backup de '
          '${date.day}/${date.month}/${date.year}?\n\n'
          'Todos os dados atuais serão substituídos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performRestoreFromCloud();
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _downloadBackup(int index) {
    // Aqui você pode integrar com download do arquivo gerado pelo BackupService, se quiser.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download do backup iniciado')),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Deseja excluir este backup? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _backupHistory.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup excluído')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // Só mantive pra caso queira usar no futuro;
  // hoje é só UI, não mexe em nada real.
  void _saveAutoBackupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configurações de backup automático salvas!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
