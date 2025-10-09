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

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: priorityColor, width: 4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(categoryIcon, color: categoryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note['title'] ?? 'Sem título',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(categoryIcon, size: 14, color: categoryColor),
                                const SizedBox(width: 4),
                                Text(
                                  note['category'] ?? '-',
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Data: ${note['date'] ?? '-'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  if (animal != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.pets, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Animal: ${animal.name} (${animal.code})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showNoteDetails(note, animal),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Ver Detalhes'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  void _showNoteDetails(Map<String, dynamic> note, dynamic animal) {
    final animalService = Provider.of<AnimalService>(context, listen: false);
    
    Color priorityColor;
    switch (note['priority']) {
      case 'Alta':
        priorityColor = Theme.of(context).colorScheme.error;
        break;
      case 'Média':
        priorityColor = Theme.of(context).colorScheme.tertiary;
        break;
      default:
        priorityColor = Theme.of(context).colorScheme.primary;
    }

    Color categoryColor;
    IconData categoryIcon;
    switch (note['category']) {
      case 'Saúde':
        categoryColor = Theme.of(context).colorScheme.error;
        categoryIcon = Icons.medical_services;
        break;
      case 'Reprodução':
        categoryColor = Theme.of(context).colorScheme.tertiary;
        categoryIcon = Icons.favorite;
        break;
      case 'Alimentação':
        categoryColor = Theme.of(context).colorScheme.secondary;
        categoryIcon = Icons.restaurant;
        break;
      case 'Comportamento':
        categoryColor = Theme.of(context).colorScheme.primary;
        categoryIcon = Icons.psychology;
        break;
      default:
        categoryColor = Theme.of(context).colorScheme.outline;
        categoryIcon = Icons.note;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(categoryIcon, color: categoryColor, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        note['title'] ?? 'Detalhes da Anotação',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categoria e Prioridade
                      _buildDetailSection(
                        icon: categoryIcon,
                        title: 'Categoria',
                        content: note['category'] ?? 'N/A',
                        color: categoryColor,
                      ),
                      const SizedBox(height: 16),

                      _buildDetailSection(
                        icon: Icons.priority_high,
                        title: 'Prioridade',
                        content: note['priority'] ?? 'N/A',
                        color: priorityColor,
                      ),
                      const SizedBox(height: 16),

                      // Data
                      _buildDetailSection(
                        icon: Icons.calendar_today,
                        title: 'Data',
                        content: note['date'] ?? 'N/A',
                        color: categoryColor,
                      ),
                      const SizedBox(height: 16),

                      // Animal (se houver)
                      if (animal != null) ...[
                        _buildDetailSection(
                          icon: Icons.pets,
                          title: 'Animal',
                          content: '${animal.name} (${animal.code}) - ${animal.breed}',
                          color: categoryColor,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Criado por
                      if (note['created_by'] != null && note['created_by'].toString().isNotEmpty)
                        _buildDetailSection(
                          icon: Icons.person,
                          title: 'Criado por',
                          content: note['created_by'],
                          color: categoryColor,
                        ),
                      if (note['created_by'] != null && note['created_by'].toString().isNotEmpty)
                        const SizedBox(height: 16),

                      // Conteúdo/Observações
                      if (note['content'] != null && note['content'].toString().isNotEmpty)
                        _buildDetailSection(
                          icon: Icons.notes,
                          title: 'Observações',
                          content: note['content'],
                          color: categoryColor,
                          isMultiline: true,
                        ),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}