import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/animal_service.dart';
import '../services/note_service.dart';
import 'notes_form.dart';

/// Formata uma data do formato yyyy-MM-dd para dd/MM/yyyy
String _formatDateFromDb(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return dateStr;
  }
}

/// Formata o conteúdo da anotação para exibição da primeira linha, sem quebrar o layout
String _formatContentPreview(String? content) {
  if (content == null || content.isEmpty) return 'Sem descrição';
  const maxLength = 60;
  if (content.length <= maxLength) return content;
  return '${content.substring(0, maxLength)}...';
}

/// Tela de gerenciamento de anotações
class NotesManagementScreen extends StatefulWidget {
  const NotesManagementScreen({super.key});

  @override
  State<NotesManagementScreen> createState() => _NotesManagementScreenState();
}

class _NotesManagementScreenState extends State<NotesManagementScreen> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = false;
  String _searchTerm = '';
  String _selectedCategory = 'Todas';
  String _selectedPriority = 'Todas';
  bool _showOnlyUnread = false;

  final List<String> _categories = const [
    'Todas',
    'Geral',
    'Saúde',
    'Reprodução',
    'Vacinação',
    'Alimentação',
    'Manejo',
    'Financeiro',
    'Veterinário',
  ];

  final List<String> _priorities = const [
    'Todas',
    'Baixa',
    'Média',
    'Alta',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final noteService = context.read<NoteService>();
      _notes = await noteService.getNotes();
    } catch (e) {
      // ignore: avoid_print
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
      final readMatch =
          !_showOnlyUnread || (note['is_read'] == 0 || note['is_read'] == null);

      if (!categoryMatch || !priorityMatch || !readMatch) return false;

      if (_searchTerm.isEmpty) return true;

      final searchLower = _searchTerm.toLowerCase();
      final title = (note['title'] ?? '').toString().toLowerCase();
      final content = (note['content'] ?? '').toString().toLowerCase();
      final createdBy = (note['created_by'] ?? '').toString().toLowerCase();
      final category = (note['category'] ?? '').toString().toLowerCase();
      final priority = (note['priority'] ?? '').toString().toLowerCase();

      return title.contains(searchLower) ||
          content.contains(searchLower) ||
          createdBy.contains(searchLower) ||
          category.contains(searchLower) ||
          priority.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredNotes = _filteredNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotações da Propriedade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
            tooltip: 'Recarregar anotações',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddNoteDialog(context),
            tooltip: 'Nova anotação',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(theme),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotes.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildNotesList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Material(
      elevation: 2,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar anotações',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() => _searchTerm = value.trim());
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedCategory = value);
                },
              ),
            ),
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<String>(
                value: _selectedPriority,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedPriority = value);
                },
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _showOnlyUnread,
                  onChanged: (value) {
                    setState(() => _showOnlyUnread = value);
                  },
                ),
                const Text('Mostrar apenas não lidas'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma anotação encontrada',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Use o botão "+" para adicionar uma nova anotação, ou altere os filtros de busca.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(ThemeData theme) {
    final sortedNotes = [..._filteredNotes]
      ..sort((a, b) {
        final dateA = a['date'] ?? '';
        final dateB = b['date'] ?? '';
        return dateB.compareTo(dateA);
      });

    return Consumer<AnimalService>(
      builder: (context, animalService, _) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: sortedNotes.length,
          itemBuilder: (context, index) {
            final note = sortedNotes[index];
            final animalService =
                Provider.of<AnimalService>(context, listen: false);

            // Find associated animal if exists
            final noteAnimalId = note['animal_id'];
            dynamic animal;
            if (noteAnimalId != null) {
              try {
                // se não encontrar, firstWhere lança StateError e cai no catch
                animal = animalService.animals.firstWhere((a) => a.id == noteAnimalId);
              } on StateError {
                animal = null;
              }
            }


            return _buildNoteCard(theme, note, animal);
          },
        );
      },
    );
  }

  Widget _buildNoteCard(
      ThemeData theme, Map<String, dynamic> note, dynamic animal) {
    final isRead = note['is_read'] == 1;
    final dateStr = _formatDateFromDb(note['date']);
    final contentPreview = _formatContentPreview(note['content']);

    Color priorityColor;
    IconData priorityIcon;
    switch (note['priority']) {
      case 'Alta':
        priorityColor = theme.colorScheme.error;
        priorityIcon = Icons.warning_amber_rounded;
        break;
      case 'Baixa':
        priorityColor = Colors.green.shade600;
        priorityIcon = Icons.arrow_downward_rounded;
        break;
      default:
        priorityColor = Colors.orange.shade700;
        priorityIcon = Icons.drag_handle_rounded;
    }

    final categoryChip = Chip(
      label: Text(
        note['category'] ?? 'Sem categoria',
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 11,
        ),
      ),
      backgroundColor: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final priorityChip = Chip(
      avatar: Icon(priorityIcon, size: 16, color: priorityColor),
      label: Text(
        note['priority'] ?? 'Média',
        style: TextStyle(
          color: priorityColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      side: BorderSide(color: priorityColor.withOpacity(0.6)),
      backgroundColor: priorityColor.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final createdBy = (note['created_by'] ?? '').toString().trim();

    return Card(
      elevation: isRead ? 1 : 3,
      color:
          isRead ? theme.colorScheme.surface : theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead
              ? theme.dividerColor
              : theme.colorScheme.primary.withOpacity(0.5),
          width: isRead ? 0.5 : 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showNoteDetails(note, animal),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone principal
              Column(
                children: [
                  Icon(
                    isRead ? Icons.sticky_note_2_outlined : Icons.note_alt,
                    size: 30,
                    color: isRead
                        ? theme.colorScheme.onSurface.withOpacity(0.6)
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  if (!isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NOVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Conteúdo principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título + data
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            note['title'] ?? 'Sem título',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: isRead
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Animal vinculado (se houver)
                    if (animal != null)
                      Row(
                        children: [
                          Icon(
                            Icons.pets,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${animal.code} - ${animal.name}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    if (animal != null) const SizedBox(height: 4),

                    // Prévia do conteúdo
                    Text(
                      contentPreview,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rodapé com categoria, prioridade, criado por e botão de marcar como lida
                    Row(
                      children: [
                        categoryChip,
                        const SizedBox(width: 8),
                        priorityChip,
                        const Spacer(),
                        if (createdBy.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                createdBy,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        if (!isRead) ...[
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Marcar como lida'),
                            onPressed: () => _markAsRead(note['id'].toString()),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsRead(String noteId) async {
    try {
      final noteService = context.read<NoteService>();
      await noteService.markAsRead(noteId);
      await _loadNotes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anotação marcada como lida!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar como lida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddNoteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const NotesFormDialog(),
    );

    if (result == true) {
      await _loadNotes();
    }
  }

  void _showNoteDetails(Map<String, dynamic> note, dynamic animal) {
    final animalService = Provider.of<AnimalService>(context, listen: false);

    Color priorityColor;
    switch (note['priority']) {
      case 'Alta':
        priorityColor = Theme.of(context).colorScheme.error;
        break;
      case 'Baixa':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.orange;
    }

    final dateStr = _formatDateFromDb(note['date']);
    final content = (note['content'] ?? 'Sem descrição').toString();
    final createdBy = (note['created_by'] ?? '').toString().trim();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note['title'] ?? 'Detalhes da Anotação'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria e prioridade
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        label: Text(note['category'] ?? 'Sem categoria'),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      Chip(
                        avatar: Icon(
                          note['priority'] == 'Alta'
                              ? Icons.priority_high
                              : note['priority'] == 'Baixa'
                                  ? Icons.arrow_downward
                                  : Icons.drag_handle,
                          color: priorityColor,
                          size: 18,
                        ),
                        label: Text(
                          note['priority'] ?? 'Média',
                          style: TextStyle(color: priorityColor),
                        ),
                        side: BorderSide(color: priorityColor),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Data
                  _buildDetailSection(
                    icon: Icons.calendar_today,
                    title: 'Data',
                    content: dateStr,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),

                  // Animal vinculado
                  if (animal != null)
                    _buildDetailSection(
                      icon: Icons.pets,
                      title: 'Animal vinculado',
                      content: '${animal.code} - ${animal.name}',
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  if (animal == null)
                    _buildDetailSection(
                      icon: Icons.pets_outlined,
                      title: 'Animal vinculado',
                      content: 'Nenhum animal vinculado a esta anotação',
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  const SizedBox(height: 8),

                  // Criado por
                  if (createdBy.isNotEmpty)
                    _buildDetailSection(
                      icon: Icons.person_outline,
                      title: 'Criado por',
                      content: createdBy,
                      color:
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  if (createdBy.isEmpty)
                    _buildDetailSection(
                      icon: Icons.person_outline,
                      title: 'Criado por',
                      content: 'Autor não informado',
                      color:
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  const SizedBox(height: 16),

                  // Conteúdo
                  _buildDetailSection(
                    icon: Icons.description_outlined,
                    title: 'Descrição / Detalhes',
                    content: content,
                    color: Theme.of(context).colorScheme.primary,
                    isMultiline: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (note['is_read'] == 1) return;
                await _markAsRead(note['id'].toString());
              },
              child: Text(
                note['is_read'] == 1
                    ? 'Fechar'
                    : 'Marcar como lida e fechar',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
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
    );
  }
}
