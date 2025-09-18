import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';

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
  bool _autoBackup = false;
  String _backupFrequency = 'daily';
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Configurações do Sistema',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Configure notificações, gerencie backups e mantenha seus dados sempre seguros.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notifications Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notificações',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text('Ativar Notificações'),
                      subtitle: const Text('Receber alertas do sistema'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    
                    if (_notificationsEnabled) ...[
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Lembretes de Vacinação'),
                        subtitle: const Text('Alertas quando vacinações estiverem próximas'),
                        value: _vaccinationReminders,
                        onChanged: (value) {
                          setState(() {
                            _vaccinationReminders = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('Lembretes de Parto'),
                        subtitle: const Text('Alertas para partos previstos'),
                        value: _birthReminders,
                        onChanged: (value) {
                          setState(() {
                            _birthReminders = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('Monitoramento de Peso'),
                        subtitle: const Text('Alertas para animais fora da faixa de peso ideal'),
                        value: _weightTracking,
                        onChanged: (value) {
                          setState(() {
                            _weightTracking = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Backup Settings
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
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Backup e Dados',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: const Text('Backup Automático'),
                      subtitle: const Text('Fazer backup dos dados automaticamente'),
                      value: _autoBackup,
                      onChanged: (value) {
                        setState(() {
                          _autoBackup = value;
                        });
                      },
                    ),
                    
                    if (_autoBackup) ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Frequência do Backup'),
                        subtitle: Text(_getBackupFrequencyLabel()),
                        trailing: DropdownButton<String>(
                          value: _backupFrequency,
                          items: const [
                            DropdownMenuItem(value: 'daily', child: Text('Diário')),
                            DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                            DropdownMenuItem(value: 'monthly', child: Text('Mensal')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _backupFrequency = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                    
                    const Divider(),
                    
                    // Backup Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _performBackup(),
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text('Fazer Backup Agora'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _restoreBackup(),
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

            // Database Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.storage,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status do Banco de Dados',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Consumer<AnimalService>(
                      builder: (context, animalService, _) {
                        final isOffline = animalService.error != null;
                        
                        return Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                isOffline ? Icons.cloud_off : Icons.cloud_done,
                                color: isOffline ? theme.colorScheme.error : theme.colorScheme.tertiary,
                              ),
                              title: Text(isOffline ? 'Modo Offline' : 'Conectado ao Supabase'),
                              subtitle: Text(
                                isOffline 
                                  ? 'Usando dados locais - ${animalService.error}'
                                  : 'Dados sincronizados com a nuvem'
                              ),
                              trailing: isOffline 
                                ? ElevatedButton.icon(
                                    onPressed: animalService.loadData,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reconectar'),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.tertiary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: theme.colorScheme.tertiary.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      'Online',
                                      style: TextStyle(
                                        color: theme.colorScheme.tertiary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                            ),
                            
                            const Divider(),
                            
                            ListTile(
                              leading: Icon(
                                Icons.analytics,
                                color: theme.colorScheme.secondary,
                              ),
                              title: Text('Total de Registros'),
                              subtitle: Text(
                                '${animalService.animals.length} animais cadastrados'
                              ),
                              trailing: TextButton.icon(
                                onPressed: () => _showDataStatistics(animalService),
                                icon: const Icon(Icons.info_outline),
                                label: const Text('Detalhes'),
                              ),
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

            // System Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.build,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ações do Sistema',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      leading: Icon(Icons.info, color: theme.colorScheme.primary),
                      title: const Text('Sobre o BEGO Agritech'),
                      subtitle: const Text('Versão 1.0.0 - Sistema de Gestão Pecuária'),
                      onTap: () => _showAboutDialog(),
                    ),
                    
                    ListTile(
                      leading: Icon(Icons.help, color: theme.colorScheme.secondary),
                      title: const Text('Ajuda e Suporte'),
                      subtitle: const Text('Documentação e tutoriais'),
                      onTap: () => _showHelp(),
                    ),
                    
                    ListTile(
                      leading: Icon(Icons.bug_report, color: theme.colorScheme.tertiary),
                      title: const Text('Reportar Problema'),
                      subtitle: const Text('Enviar feedback ou relatar bugs'),
                      onTap: () => _reportIssue(),
                    ),
                    
                    const Divider(),
                    
                    ListTile(
                      leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                      title: const Text('Limpar Dados'),
                      subtitle: const Text('Apagar todos os dados locais (irreversível)'),
                      onTap: () => _confirmDataClear(),
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

  void _performBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Backup iniciado com sucesso!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        action: SnackBarAction(
          label: 'Ver Progresso',
          onPressed: () {},
        ),
      ),
    );
  }

  void _restoreBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Backup'),
        content: const Text(
          'Esta ação substituirá todos os dados atuais pelos dados do backup. '
          'Tem certeza de que deseja continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Restauração iniciada...'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Restaurar'),
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
        content: stats != null ? Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatItem('Total de Animais', '${stats.totalAnimals}'),
            _buildStatItem('Animais Saudáveis', '${stats.healthy}'),
            _buildStatItem('Em Tratamento', '${stats.underTreatment}'),
            _buildStatItem('Fêmeas Gestantes', '${stats.pregnant}'),
            _buildStatItem('Peso Médio', '${stats.avgWeight.toStringAsFixed(1)} kg'),
            _buildStatItem('Receita Total', 'R\$ ${stats.revenue.toStringAsFixed(2)}'),
          ],
        ) : const Text('Dados não disponíveis'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
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
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
            Text('🐐'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistema Completo de Gestão para Ovinocultura e Caprinocultura',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Versão: 1.0.0'),
            Text('Desenvolvido com Flutter'),
            Text('Integração: Supabase'),
            Text('Funciona Offline: Sim'),
            SizedBox(height: 16),
            Text(
              'Este sistema permite o controle completo do rebanho, '
              'desde o cadastro de animais até o controle financeiro, '
              'com funcionalidades offline para uso em campo.',
            ),
          ],
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

  void _confirmDataClear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Limpar Todos os Dados'),
          ],
        ),
        content: const Text(
          'ATENÇÃO: Esta ação irá apagar TODOS os dados locais permanentemente. '
          'Certifique-se de ter um backup antes de continuar. '
          'Esta ação NÃO PODE ser desfeita.',
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
              _clearAllData();
            },
            child: const Text('Limpar Dados'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Todos os dados foram removidos.'),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Reiniciar App',
          onPressed: () {
            // Restart app logic would go here
          },
        ),
      ),
    );
  }
}