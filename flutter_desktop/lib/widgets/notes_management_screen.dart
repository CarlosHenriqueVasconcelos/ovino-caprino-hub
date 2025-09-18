import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../services/supabase_service.dart';
import 'notes_form.dart';

class NotesManagementScreen extends StatefulWidget {
  const NotesManagementScreen({super.key});

  @override
  State<NotesManagementScreen> createState() => _NotesManagementScreenState();
}

class _NotesManagementScreenState extends State<NotesManagementScreen> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todas';
  String _selectedPriority = 'Todas';

  final List<String> _categories = [
    'Todas',
    'Saúde',
    'Reprodução',
    'Alimentação',
    'Comportamento',
    'Geral'
  ];

  final List<String> _priorities = ['Todas', 'Alta', 'Média', 'Baixa'];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      _notes = await SupabaseService.getNotes();
    } catch (e) {
      print('Error loading notes: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredNotes {
    return _notes.where((note) {
      final categoryMatch = _selectedCategory == 'Todas' || 
                          note['category'] == _selectedCategory;
      final priorityMatch = _selectedPriority == 'Todas' || 
                          note['priority'] == _selectedPriority;
      return categoryMatch && priorityMatch;
    }).toList();
  }

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
                          Icons.note_alt,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Anotações e Observações',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _showNotesForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Nova Anotação'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Registre observações importantes sobre saúde, comportamento, alimentação e reprodução. '
                      'Organize por categoria e prioridade para um acompanhamento eficiente.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Filters Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtros',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Category Filter
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Categoria:',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: _categories.map((category) {
                              return FilterChip(
                                label: Text(category),
                                selected: category == _selectedCategory,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Priority Filter
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Prioridade:',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: _priorities.map((priority) {
                              return FilterChip(
                                label: Text(priority),
                                selected: priority == _selectedPriority,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedPriority = priority;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes List Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Anotações',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredNotes.length} de ${_notes.length} registros',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_filteredNotes.isEmpty)
                      _buildEmptyState(theme)
                    else
                      _buildNotesList(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _notes.isEmpty ? 'Nenhuma anotação registrada' : 'Nenhuma anotação encontrada',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _notes.isEmpty 
                ? 'Registre observações importantes sobre os animais'
                : 'Ajuste os filtros para encontrar anotações',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showNotesForm(),
              icon: const Icon(Icons.add),
              label: Text(_notes.isEmpty ? 'Primeira Anotação' : 'Nova Anotação'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(ThemeData theme) {
    // Sort notes by date (newest first) and priority
    final sortedNotes = List<Map<String, dynamic>>.from(_filteredNotes);
    sortedNotes.sort((a, b) {
      // First sort by priority
      final priorityOrder = {'Alta': 0, 'Média': 1, 'Baixa': 2};
      final aPriority = priorityOrder[a['priority']] ?? 3;
      final bPriority = priorityOrder[b['priority']] ?? 3;
      
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      
      // Then sort by date
      final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedNotes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        final animalService = Provider.of<AnimalService>(context, listen: false);

        // Find associated animal if exists
        final noteAnimalId = note['animal_id'];
        var animal;
        if (noteAnimalId != null) {
          final matches = animalService.animals.where(
            (a) => a.id == noteAnimalId,
          );
          animal = matches.isNotEmpty ? matches.first : null;
        }

        Color priorityColor;
        IconData priorityIcon;
        switch (note['priority']) {
          case 'Alta':
            priorityColor = theme.colorScheme.error;
            priorityIcon = Icons.priority_high;
            break;
          case 'Média':
            priorityColor = theme.colorScheme.tertiary;
            priorityIcon = Icons.remove;
            break;
          default:
            priorityColor = theme.colorScheme.primary;
            priorityIcon = Icons.low_priority;
        }

        Color categoryColor;
        IconData categoryIcon;
        switch (note['category']) {
          case 'Saúde':
            categoryColor = theme.colorScheme.error;
            categoryIcon = Icons.medical_services;
            break;
          case 'Reprodução':
            categoryColor = theme.colorScheme.tertiary;
            categoryIcon = Icons.favorite;
            break;
          case 'Alimentação':
            categoryColor = theme.colorScheme.secondary;
            categoryIcon = Icons.restaurant;
            break;
          case 'Comportamento':
            categoryColor = theme.colorScheme.primary;
            categoryIcon = Icons.psychology;
            break;
          default:
            categoryColor = theme.colorScheme.outline;
            categoryIcon = Icons.note;
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(priorityIcon, color: priorityColor),
            ),
            title: Text(
              note['title'] ?? 'Sem título',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(categoryIcon, size: 14, color: categoryColor),
                    const SizedBox(width: 4),
                    Text(
                      note['category'] ?? '-',
                      style: TextStyle(color: categoryColor, fontWeight: FontWeight.w600),
                    ),
                    if (animal != null) ...[
                      const SizedBox(width: 8),
                      Text('•'),
                      const SizedBox(width: 8),
                      Text('${animal.name} (${animal.code})'),
                    ],
                  ],
                ),
                Text('Data: ${note['date'] ?? '-'}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: priorityColor.withOpacity(0.3)),
              ),
              child: Text(
                note['priority'] ?? '-',
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            children: [
              if (note['content'] != null && note['content'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Observações:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note['content'],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotesForm() {
    showDialog(
      context: context,
      builder: (context) => const NotesFormDialog(),
    ).then((_) => _loadNotes());
  }
}