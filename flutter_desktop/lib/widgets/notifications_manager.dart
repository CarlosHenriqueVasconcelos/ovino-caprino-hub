import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';

class NotificationsManager extends StatefulWidget {
  const NotificationsManager({super.key});

  @override
  State<NotificationsManager> createState() => _NotificationsManagerState();
}

class _NotificationsManagerState extends State<NotificationsManager> {
  bool _vaccinationAlerts = true;
  bool _birthAlerts = true;
  bool _healthAlerts = true;
  bool _financialAlerts = false;
  int _alertDaysBefore = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações de Notificações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Gerenciamento de Notificações',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure quando e como receber alertas sobre eventos importantes',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Configuration Panel
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipos de Alertas',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Vaccination Alerts
                            SwitchListTile(
                              value: _vaccinationAlerts,
                              onChanged: (value) {
                                setState(() {
                                  _vaccinationAlerts = value;
                                });
                              },
                              title: const Row(
                                children: [
                                  Icon(Icons.vaccines, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Alertas de Vacinação'),
                                ],
                              ),
                              subtitle: const Text('Notificações sobre vacinas pendentes'),
                            ),
                            
                            // Birth Alerts
                            SwitchListTile(
                              value: _birthAlerts,
                              onChanged: (value) {
                                setState(() {
                                  _birthAlerts = value;
                                });
                              },
                              title: const Row(
                                children: [
                                  Icon(Icons.child_care, color: Colors.pink),
                                  SizedBox(width: 8),
                                  Text('Alertas de Nascimento'),
                                ],
                              ),
                              subtitle: const Text('Notificações sobre partos previstos'),
                            ),
                            
                            // Health Alerts
                            SwitchListTile(
                              value: _healthAlerts,
                              onChanged: (value) {
                                setState(() {
                                  _healthAlerts = value;
                                });
                              },
                              title: const Row(
                                children: [
                                  Icon(Icons.health_and_safety, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Alertas de Saúde'),
                                ],
                              ),
                              subtitle: const Text('Notificações sobre problemas de saúde'),
                            ),
                            
                            // Financial Alerts
                            SwitchListTile(
                              value: _financialAlerts,
                              onChanged: (value) {
                                setState(() {
                                  _financialAlerts = value;
                                });
                              },
                              title: const Row(
                                children: [
                                  Icon(Icons.attach_money, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Alertas Financeiros'),
                                ],
                              ),
                              subtitle: const Text('Notificações sobre metas e gastos'),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Alert Timing
                            Text(
                              'Antecedência dos Alertas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            DropdownButtonFormField<int>(
                              value: _alertDaysBefore,
                              decoration: const InputDecoration(
                                labelText: 'Dias antes do evento',
                                border: OutlineInputBorder(),
                              ),
                              items: [1, 3, 7, 14, 30].map((days) {
                                return DropdownMenuItem(
                                  value: days,
                                  child: Text('$days dia${days > 1 ? 's' : ''}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _alertDaysBefore = value!;
                                });
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _saveSettings,
                                icon: const Icon(Icons.save),
                                label: const Text('Salvar Configurações'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Active Notifications Panel
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
                                  Icons.notifications_active,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Notificações Ativas',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            Expanded(
                              child: _buildActiveNotifications(),
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

  Widget _buildActiveNotifications() {
    return Consumer<AnimalService>(
      builder: (context, animalService, child) {
        final theme = Theme.of(context);
        final notifications = _generateNotifications(animalService);
        
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma notificação ativa',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure os alertas para receber notificações',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            
            Color backgroundColor;
            Color iconColor;
            IconData icon;
            
            switch (notification['priority']) {
              case 'high':
                backgroundColor = theme.colorScheme.error.withOpacity(0.1);
                iconColor = theme.colorScheme.error;
                icon = Icons.priority_high;
                break;
              case 'medium':
                backgroundColor = theme.colorScheme.tertiary.withOpacity(0.1);
                iconColor = theme.colorScheme.tertiary;
                icon = Icons.notifications;
                break;
              default:
                backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
                iconColor = theme.colorScheme.primary;
                icon = Icons.info;
            }
            
            return Card(
              color: backgroundColor,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.2),
                  child: Icon(icon, color: iconColor),
                ),
                title: Text(
                  notification['title'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(notification['message']),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'dismiss',
                      child: Row(
                        children: [
                          Icon(Icons.check),
                          SizedBox(width: 8),
                          Text('Marcar como lida'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'snooze',
                      child: Row(
                        children: [
                          Icon(Icons.snooze),
                          SizedBox(width: 8),
                          Text('Adiar por 1 dia'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle notification actions
                    switch (value) {
                      case 'dismiss':
                        _dismissNotification(index);
                        break;
                      case 'snooze':
                        _snoozeNotification(index);
                        break;
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateNotifications(AnimalService animalService) {
    final notifications = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final alertDate = now.add(Duration(days: _alertDaysBefore));
    
    // Vaccination alerts
    if (_vaccinationAlerts) {
      for (final animal in animalService.animals) {
        if (animal.lastVaccination != null) {
          final nextVaccination = animal.lastVaccination!.add(const Duration(days: 365));
          if (nextVaccination.isBefore(alertDate)) {
            notifications.add({
              'title': 'Vacinação Pendente',
              'message': '${animal.name} (${animal.code}) precisa de vacinação',
              'priority': 'high',
              'type': 'vaccination',
              'animal_id': animal.id,
            });
          }
        }
      }
    }
    
    // Birth alerts
    if (_birthAlerts) {
      for (final animal in animalService.animals) {
        if (animal.pregnant && animal.expectedDelivery != null) {
          final deliveryDate = animal.expectedDelivery!;
          if (deliveryDate.isBefore(alertDate) && deliveryDate.isAfter(now)) {
            notifications.add({
              'title': 'Parto Previsto',
              'message': '${animal.name} (${animal.code}) - Previsão: ${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}',
              'priority': 'medium',
              'type': 'birth',
              'animal_id': animal.id,
            });
          }
        }
      }
    }
    
    // Health alerts
    if (_healthAlerts) {
      for (final animal in animalService.animals) {
        if (animal.status == 'Em tratamento' || animal.healthIssue != null) {
          notifications.add({
            'title': 'Animal em Tratamento',
            'message': '${animal.name} (${animal.code}) - ${animal.healthIssue ?? 'Requer atenção'}',
            'priority': 'high',
            'type': 'health',
            'animal_id': animal.id,
          });
        }
      }
    }
    
    return notifications;
  }

  void _dismissNotification(int index) {
    // Implement notification dismissal logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificação marcada como lida')),
    );
  }

  void _snoozeNotification(int index) {
    // Implement notification snooze logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificação adiada por 1 dia')),
    );
  }

  void _saveSettings() {
    // Save notification settings to local storage or Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configurações de notificações salvas!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}