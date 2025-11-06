import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/animal_service.dart';
import '../services/breeding_service.dart';
import '../services/financial_service.dart';
import '../services/note_service.dart';
import '../services/vaccination_service.dart';
import '../services/medication_service.dart';
import '../models/animal.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  final List<String> _filterOptions = [
    'Todos',
    'Animais',
    'Vacinações',
    'Medicamentos',
    'Reprodução',
    'Financeiro',
    'Anotações',
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Helper para evitar o uso de `firstOrNull`
  Animal? _findAnimalById(List<Animal> animals, String? id) {
    if (id == null || id.isEmpty) return null;
    for (final animal in animals) {
      if (animal.id == id) return animal;
    }
    return null;
  }

Future<void> _loadHistory() async {
  setState(() => _isLoading = true);

  try {
    final List<HistoryItem> items = [];

    // 1) Animais cadastrados (via AnimalService)
    final animalService = context.read<AnimalService>();
    await animalService.loadData();
    final List<Animal> animals = animalService.animals.toList();

    for (final animal in animals) {
      items.add(
        HistoryItem(
          id: animal.id,
          title: 'Animal ${animal.code} cadastrado',
          description: '${animal.name} - ${animal.species} ${animal.breed}',
          timestamp: animal.createdAt,
          type: HistoryType.animalAdded,
          icon: Icons.pets,
          color: Colors.blue,
        ),
      );
    }

    // Helper interno usa essa lista de animais
    // (o _findAnimalById já existe no arquivo, não precisa mexer)

    // 2) Vacinações aplicadas
    final vaccinationService =
        context.read<VaccinationService>();
    final vaccinations = await vaccinationService.getVaccinations();

    for (final v
        in vaccinations.where((v) => v['status'] == 'Aplicada')) {
      final String? animalId = v['animal_id'] as String?;
      final animal = _findAnimalById(animals, animalId);
      final animalName =
          animal != null ? '${animal.name} (${animal.code})' : 'Animal desconhecido';

      final dynamic appliedRaw =
          v['applied_date'] ?? v['scheduled_date'] ?? v['created_at'];
      DateTime appliedDate;
      if (appliedRaw is DateTime) {
        appliedDate = appliedRaw;
      } else if (appliedRaw is String) {
        appliedDate = DateTime.tryParse(appliedRaw) ?? DateTime.now();
      } else {
        appliedDate = DateTime.now();
      }

      items.add(
        HistoryItem(
          id: v['id'] as String,
          title: 'Vacinação aplicada',
          description: '${v['vaccine_name']} - $animalName',
          timestamp: appliedDate,
          type: HistoryType.vaccination,
          icon: Icons.vaccines,
          color: Colors.green,
        ),
      );
    }

    // 3) Medicamentos aplicados
    final medicationService =
        context.read<MedicationService>();
    final medications = await medicationService.getMedications();

    for (final med in medications.where((m) => m['status'] == 'Aplicado')) {
      final String? animalId = med['animal_id'] as String?;
      final animal = _findAnimalById(animals, animalId);
      final animalName =
          animal != null ? '${animal.name} (${animal.code})' : 'Animal desconhecido';

      final dynamic appliedRaw =
          med['applied_date'] ?? med['scheduled_date'] ?? med['created_at'];
      DateTime appliedDate;
      if (appliedRaw is DateTime) {
        appliedDate = appliedRaw;
      } else if (appliedRaw is String) {
        appliedDate = DateTime.tryParse(appliedRaw) ?? DateTime.now();
      } else {
        appliedDate = DateTime.now();
      }

      items.add(
        HistoryItem(
          id: med['id'] as String,
          title: 'Medicamento aplicado',
          description: '${med['medication_name']} - $animalName',
          timestamp: appliedDate,
          type: HistoryType.medication,
          icon: Icons.medical_services,
          color: Colors.orange,
        ),
      );
    }

    // 4) Registros de reprodução (via BreedingService)
    final breedingService = context.read<BreedingService>();
    final breedingRecords = await breedingService.getBreedingRecords();

    for (final breeding in breedingRecords) {
      final String? femaleId = breeding['female_animal_id'] as String?;
      final female = _findAnimalById(animals, femaleId);
      final femaleName = female != null
          ? '${female.name} (${female.code})'
          : 'Fêmea desconhecida';

      final String? createdStr = breeding['created_at'] as String?;
      final createdAt =
          createdStr != null ? DateTime.tryParse(createdStr) ?? DateTime.now() : DateTime.now();

      items.add(
        HistoryItem(
          id: breeding['id'] as String,
          title: 'Cobertura registrada',
          description: 'Fêmea: $femaleName - Status: ${breeding['status']}',
          timestamp: createdAt,
          type: HistoryType.breeding,
          icon: Icons.favorite,
          color: Colors.pink,
        ),
      );
    }

    // 5) Registros financeiros (via FinancialService)
    final financialService = context.read<FinancialService>();
    final financialRecords = await financialService.getFinancialRecords();

    for (final record in financialRecords) {
      final bool isReceita = record['type'] == 'receita';
      final String? dateStr = record['date'] as String?;
      final DateTime date = dateStr != null
          ? DateTime.tryParse(dateStr) ?? DateTime.now()
          : DateTime.now();
      final num amount = record['amount'] as num? ?? 0;

      items.add(
        HistoryItem(
          id: record['id'] as String,
          title: isReceita ? 'Receita registrada' : 'Despesa registrada',
          description:
              '${record['category']} - R\$ ${amount.toStringAsFixed(2)}',
          timestamp: date,
          type: HistoryType.financial,
          icon: isReceita ? Icons.trending_up : Icons.trending_down,
          color: isReceita ? Colors.green : Colors.red,
        ),
      );
    }

    // 6) Anotações (via NoteService)
    final noteService = context.read<NoteService>();
    final notes = await noteService.getNotes();

    for (final note in notes) {
      final String? createdStr = note['created_at'] as String?;
      final DateTime createdAt = createdStr != null
          ? DateTime.tryParse(createdStr) ?? DateTime.now()
          : DateTime.now();

      items.add(
        HistoryItem(
          id: note['id'] as String,
          title: 'Anotação criada',
          description: '${note['title']} - ${note['category']}',
          timestamp: createdAt,
          type: HistoryType.note,
          icon: Icons.notes,
          color: Colors.purple,
        ),
      );
    }

    // Ordenar por data (mais recente primeiro)
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (!mounted) return;
    setState(() {
      _historyItems = items;
      _isLoading = false;
    });
  } catch (e, stack) {
    debugPrint('Erro ao carregar histórico: $e');
    debugPrint(stack.toString());
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar histórico: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredItems = _getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Atividades'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Filter Dropdown
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
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

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acompanhe todas as atividades realizadas no sistema',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Activity Stats
                  _buildActivityStats(theme),
                  const SizedBox(height: 24),

                  // History List
                  Expanded(
                    child: filteredItems.isEmpty
                        ? _buildEmptyState(theme)
                        : ListView.separated(
                            itemCount: filteredItems.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
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
    final now = DateTime.now();

    final today = _historyItems
        .where((item) => now.difference(item.timestamp).inDays == 0)
        .length;

    final thisWeek = _historyItems
        .where((item) => now.difference(item.timestamp).inDays <= 7)
        .length;

    final thisMonth = _historyItems
        .where((item) => now.difference(item.timestamp).inDays <= 30)
        .length;

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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
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
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('Ver Detalhes'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Remover',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'details') {
                  _showItemDetails(item);
                } else if (value == 'delete') {
                  _showDeleteItemDialog();
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
        case 'Medicamentos':
          return item.type == HistoryType.medication;
        case 'Reprodução':
          return item.type == HistoryType.breeding;
        case 'Financeiro':
          return item.type == HistoryType.financial;
        case 'Anotações':
          return item.type == HistoryType.note;
        default:
          return true;
      }
    }).toList();
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''} atrás';
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
              'Data: ${DateFormat('dd/MM/yyyy').format(item.timestamp)} às ${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Tipo: ${_getTypeLabel(item.type)}',
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

  void _showDeleteItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informação'),
        content: const Text(
          'Para remover um item do histórico, você precisa excluir o registro original (animal, vacinação, etc.) no módulo correspondente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(HistoryType type) {
    switch (type) {
      case HistoryType.animalAdded:
        return 'Animal';
      case HistoryType.vaccination:
        return 'Vacinação';
      case HistoryType.medication:
        return 'Medicamento';
      case HistoryType.breeding:
        return 'Reprodução';
      case HistoryType.financial:
        return 'Financeiro';
      case HistoryType.note:
        return 'Anotação';
      default:
        return 'Sistema';
    }
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informação'),
        content: const Text(
          'O histórico é gerado automaticamente a partir dos registros do sistema. '
          'Para limpar o histórico, você precisa excluir os registros originais nos módulos correspondentes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
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
  medication,
  breeding,
  financial,
  note,
  weightUpdate,
  statusChange,
  reportGenerated,
  systemAction,
}
