import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<HistoryItem> _historyItems = [
    HistoryItem(
      id: '1',
      title: 'Animal OV001 cadastrado',
      description: 'Novo ovino Santa Inês adicionado ao rebanho',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: HistoryType.animalAdded,
      icon: Icons.add_circle,
      color: Colors.green,
    ),
    HistoryItem(
      id: '2',
      title: 'Vacinação aplicada em CAP002',
      description: 'Vacina V8 aplicada em Maria (Caprino Anglo-Nubiano)',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: HistoryType.vaccination,
      icon: Icons.vaccines,
      color: Colors.blue,
    ),
    HistoryItem(
      id: '3',
      title: 'Peso atualizado para OV003',
      description: 'Peso alterado de 45kg para 47kg - João (Ovino Morada Nova)',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      type: HistoryType.weightUpdate,
      icon: Icons.monitor_weight,
      color: Colors.orange,
    ),
    HistoryItem(
      id: '4',
      title: 'Relatório de saúde gerado',
      description: 'Relatório mensal de saúde do rebanho exportado',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      type: HistoryType.reportGenerated,
      icon: Icons.description,
      color: Colors.purple,
    ),
    HistoryItem(
      id: '5',
      title: 'Animal CAP001 marcado como prenhe',
      description: 'Beatriz confirmada gestante - previsão de parto em 03/2024',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: HistoryType.breeding,
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    HistoryItem(
      id: '6',
      title: 'Status alterado para Em Tratamento',
      description: 'OV002 - Pedro apresentou sintomas de verminose',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: HistoryType.statusChange,
      icon: Icons.medical_services,
      color: Colors.red,
    ),
    HistoryItem(
      id: '7',
      title: 'Backup automático realizado',
      description: 'Dados sincronizados com a nuvem com sucesso',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      type: HistoryType.systemAction,
      icon: Icons.cloud_upload,
      color: Colors.grey,
    ),
  ];

  String _selectedFilter = 'Todos';
  final List<String> _filterOptions = [
    'Todos',
    'Animais',
    'Vacinações',
    'Saúde',
    'Reprodução',
    'Sistema',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredItems = _getFilteredItems();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Histórico de Atividades',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                
                // Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    underline: const SizedBox.shrink(),
                    items: _filterOptions.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Clear All Button
                OutlinedButton.icon(
                  onPressed: _showClearHistoryDialog,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpar Histórico'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              'Acompanhe todas as atividades realizadas no sistema',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Activity Stats
            _buildActivityStats(theme),
            
            const SizedBox(height: 24),
            
            // History List
            Expanded(
              child: filteredItems.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildHistoryCard(item, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStats(ThemeData theme) {
    final today = _historyItems.where((item) => 
      DateTime.now().difference(item.timestamp).inDays == 0
    ).length;
    
    final thisWeek = _historyItems.where((item) => 
      DateTime.now().difference(item.timestamp).inDays <= 7
    ).length;
    
    final thisMonth = _historyItems.where((item) => 
      DateTime.now().difference(item.timestamp).inDays <= 30
    ).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Hoje',
            '$today',
            Icons.today,
            theme.colorScheme.primary,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Esta Semana',
            '$thisWeek',
            Icons.calendar_view_week,
            theme.colorScheme.secondary,
            theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Este Mês',
            '$thisMonth',
            Icons.calendar_month,
            theme.colorScheme.tertiary,
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItem item, ThemeData theme) {
    final timeAgo = _getTimeAgo(item.timestamp);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('Ver Detalhes'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remover', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'details') {
                  _showItemDetails(item);
                } else if (value == 'delete') {
                  _showDeleteItemDialog(item);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma atividade encontrada',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O histórico aparecerá aqui conforme você usar o sistema',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  List<HistoryItem> _getFilteredItems() {
    if (_selectedFilter == 'Todos') {
      return _historyItems;
    }
    
    return _historyItems.where((item) {
      switch (_selectedFilter) {
        case 'Animais':
          return item.type == HistoryType.animalAdded;
        case 'Vacinações':
          return item.type == HistoryType.vaccination;
        case 'Saúde':
          return item.type == HistoryType.statusChange || item.type == HistoryType.weightUpdate;
        case 'Reprodução':
          return item.type == HistoryType.breeding;
        case 'Sistema':
          return item.type == HistoryType.systemAction || item.type == HistoryType.reportGenerated;
        default:
          return true;
      }
    }).toList();
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} mês${difference.inDays > 60 ? 'es' : ''} atrás';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  void _showItemDetails(HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 16),
            Text(
              'Data: ${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} às ${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Tipo: ${item.type.name}',
              style: Theme.of(context).textTheme.bodySmall,
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

  void _showDeleteItemDialog(HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Atividade'),
        content: Text('Deseja remover "${item.title}" do histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _historyItems.remove(item);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Atividade removida do histórico')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text('Esta ação irá remover todas as atividades do histórico. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _historyItems.clear();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Histórico limpo com sucesso')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }
}

class HistoryItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final HistoryType type;
  final IconData icon;
  final Color color;

  HistoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.icon,
    required this.color,
  });
}

enum HistoryType {
  animalAdded,
  vaccination,
  weightUpdate,
  statusChange,
  breeding,
  reportGenerated,
  systemAction,
}