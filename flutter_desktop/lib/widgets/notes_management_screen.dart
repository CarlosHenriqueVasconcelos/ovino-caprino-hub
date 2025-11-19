import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/note_service.dart';
import 'notes/notes_dialogs.dart';
import 'notes/notes_filters_bar.dart';
import 'notes/notes_list_section.dart';

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
  late final TextEditingController _searchController;
  Timer? _searchDebounce;
  static const int _pageSize = 200;

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
    _searchController = TextEditingController();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final noteService = context.read<NoteService>();
      _notes = await noteService.getNotes(
        options: NoteQueryOptions(
          category: _selectedCategory == 'Todas' ? null : _selectedCategory,
          priority: _selectedPriority == 'Todas' ? null : _selectedPriority,
          unreadOnly: _showOnlyUnread ? true : null,
          searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
          limit: _pageSize,
          offset: 0,
        ),
      );
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() => _searchTerm = value.trim());
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _loadNotes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedNotes = [..._notes]
      ..sort((a, b) {
        final dateA = a['date'] ?? '';
        final dateB = b['date'] ?? '';
        return dateB.compareTo(dateA);
      });

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
            onPressed: () => _openAddNoteDialog(context),
            tooltip: 'Nova anotação',
          ),
        ],
      ),
      body: Column(
        children: [
          NotesFiltersBar(
            searchController: _searchController,
            onSearchChanged: _handleSearchChanged,
            categoryOptions: _categories,
            selectedCategory: _selectedCategory,
            onCategoryChanged: (value) {
              setState(() => _selectedCategory = value);
              _loadNotes();
            },
            priorityOptions: _priorities,
            selectedPriority: _selectedPriority,
            onPriorityChanged: (value) {
              setState(() => _selectedPriority = value);
              _loadNotes();
            },
            showOnlyUnread: _showOnlyUnread,
            onShowOnlyUnreadChanged: (value) {
              setState(() => _showOnlyUnread = value);
              _loadNotes();
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? _buildEmptyState(theme)
                    : NotesListSection(
                        notes: sortedNotes,
                        onViewDetails: _onNoteSelected,
                        onMarkAsRead: (note) =>
                            _markAsRead(note['id'].toString()),
                        onDelete: _deleteNote,
                      ),
          ),
        ],
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

  Future<void> _openAddNoteDialog(BuildContext context) async {
    final result = await showAddNoteDialog(context);
    if (result == true) {
      await _loadNotes();
    }
  }

  Future<void> _onNoteSelected(Map<String, dynamic> note) async {
    final shouldMark = await showNoteDetailsDialog(
      context,
      note: note,
    );
    if (shouldMark == true) {
      await _markAsRead(note['id'].toString());
    }
  }

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir anotação'),
        content: const Text(
            'Deseja realmente excluir esta anotação? A operação é irreversível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      final noteService = context.read<NoteService>();
      await noteService.deleteNote(note['id'].toString());
      await _loadNotes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anotação excluída')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir anotação: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
