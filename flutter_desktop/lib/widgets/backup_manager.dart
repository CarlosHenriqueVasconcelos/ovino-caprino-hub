import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../services/supabase_service.dart';

class BackupManager extends StatefulWidget {
  const BackupManager({super.key});

  @override
  State<BackupManager> createState() => _BackupManagerState();
}

class _BackupManagerState extends State<BackupManager> {
  bool _isBackupRunning = false;
  bool _isRestoreRunning = false;
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
                  // Backup Actions Panel
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Manual Backup Card
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
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                Text(
                                  'Crie um backup completo de todos os dados da fazenda',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isBackupRunning ? null : _performManualBackup,
                                    icon: _isBackupRunning
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.cloud_upload),
                                    label: Text(_isBackupRunning ? 'Fazendo Backup...' : 'Criar Backup'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Restore Card
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
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                Text(
                                  'Restaure seus dados a partir de um backup anterior',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _isRestoreRunning ? null : _performRestore,
                                    icon: _isRestoreRunning
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.file_upload),
                                    label: Text(_isRestoreRunning ? 'Restaurando...' : 'Selecionar Arquivo'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Auto Backup Settings
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      color: theme.colorScheme.secondary,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Backup Automático',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                SwitchListTile(
                                  value: _autoBackupEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _autoBackupEnabled = value;
                                    });
                                  },
                                  title: const Text('Habilitar backup automático'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                
                                if (_autoBackupEnabled) ...[
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _autoBackupFrequency,
                                    decoration: const InputDecoration(
                                      labelText: 'Frequência',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'daily', child: Text('Diariamente')),
                                      DropdownMenuItem(value: 'weekly', child: Text('Semanalmente')),
                                      DropdownMenuItem(value: 'monthly', child: Text('Mensalmente')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _autoBackupFrequency = value!;
                                      });
                                    },
                                  ),
                                ],
                                
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _saveAutoBackupSettings,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Salvar Configurações'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Backup History Panel
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
                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            Expanded(
                              child: ListView.builder(
                                itemCount: _backupHistory.length,
                                itemBuilder: (context, index) {
                                  final backup = _backupHistory[index];
                                  final date = backup['date'] as DateTime;
                                  
                                  Color statusColor;
                                  IconData statusIcon;
                                  if (backup['status'] == 'Sucesso') {
                                    statusColor = theme.colorScheme.primary;
                                    statusIcon = Icons.check_circle;
                                  } else {
                                    statusColor = theme.colorScheme.error;
                                    statusIcon = Icons.error;
                                  }
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: statusColor.withOpacity(0.1),
                                        child: Icon(statusIcon, color: statusColor),
                                      ),
                                      title: Text(
                                        '${date.day}/${date.month}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Tipo: ${backup['type']}'),
                                          Text('Tamanho: ${backup['size']}'),
                                        ],
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'restore',
                                            child: Row(
                                              children: [
                                                Icon(Icons.restore),
                                                SizedBox(width: 8),
                                                Text('Restaurar'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'download',
                                            child: Row(
                                              children: [
                                                Icon(Icons.download),
                                                SizedBox(width: 8),
                                                Text('Download'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Excluir', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) => _handleBackupAction(value, index),
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

  Future<void> _performManualBackup() async {
    setState(() {
      _isBackupRunning = true;
    });

    try {
      // Simulate backup process
      await Future.delayed(const Duration(seconds: 3));
      
      // In a real implementation, you would:
      // 1. Fetch all data from Supabase
      // 2. Create JSON export
      // 3. Save to local file or cloud storage
      
      final backupData = await _createBackupData();
      await _saveBackupToFile(backupData);
      
      setState(() {
        _lastBackupDate = DateTime.now();
        _backupHistory.insert(0, {
          'date': DateTime.now(),
          'type': 'Manual',
          'size': '2.4 MB',
          'status': 'Sucesso',
        });
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Backup criado com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar backup: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackupRunning = false;
        });
      }
    }
  }

  Future<void> _performRestore() async {
    setState(() {
      _isRestoreRunning = true;
    });

    try {
      // Simulate file selection and restore
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real implementation, you would:
      // 1. Show file picker dialog
      // 2. Read backup file
      // 3. Validate data
      // 4. Restore to Supabase
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dados restaurados com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao restaurar dados: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoreRunning = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _createBackupData() async {
    // Fetch all data from Supabase
    final animals = await SupabaseService.getAnimals();
    final vaccinations = await SupabaseService.getVaccinations();
    final breedingRecords = await SupabaseService.getBreedingRecords();
    final notes = await SupabaseService.getNotes();
    final financialRecords = await SupabaseService.getFinancialRecords();
    
    return {
      'backup_date': DateTime.now().toIso8601String(),
      'version': '1.0',
      'data': {
        'animals': animals.map((a) => a.toJson()).toList(),
        'vaccinations': vaccinations,
        'breeding_records': breedingRecords,
        'notes': notes,
        'financial_records': financialRecords,
      },
    };
  }

  Future<void> _saveBackupToFile(Map<String, dynamic> backupData) async {
    // In a real implementation, save to file system
    final jsonString = jsonEncode(backupData);
    print('Backup size: ${jsonString.length} characters');
  }

  void _saveAutoBackupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configurações de backup automático salvas!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Restauração'),
        content: Text(
          'Deseja restaurar o backup de ${(backup['date'] as DateTime).day}/${(backup['date'] as DateTime).month}/${(backup['date'] as DateTime).year}?\n\nTodos os dados atuais serão substituídos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
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

  void _downloadBackup(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download do backup iniciado')),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja excluir este backup? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _backupHistory.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup excluído')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}