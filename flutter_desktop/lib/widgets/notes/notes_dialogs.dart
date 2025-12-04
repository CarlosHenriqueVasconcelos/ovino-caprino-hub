import 'package:flutter/material.dart';

import '../../utils/animal_record_display.dart';
import 'notes_form.dart';
import 'notes_helpers.dart';

Future<bool?> showAddNoteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const NotesFormDialog(),
  );
}

Future<bool?> showNoteDetailsDialog(
  BuildContext context, {
  required Map<String, dynamic> note,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _NoteDetailsDialog(note: note),
  );
}

class _NoteDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> note;

  const _NoteDetailsDialog({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLinkedAnimal = note['animal_id'] != null;
    final animalLabel =
        hasLinkedAnimal ? AnimalRecordDisplay.labelFromRecord(note) : null;
    final animalColor =
        hasLinkedAnimal ? AnimalRecordDisplay.colorFromRecord(note) : null;
    final createdBy = (note['created_by'] ?? '').toString().trim();
    final content = (note['content'] ?? 'Sem descrição').toString();
    final dateStr = formatNoteDate(note['date']);

    return AlertDialog(
      title: Text(note['title'] ?? 'Detalhes da Anotação'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    label: Text(note['category'] ?? 'Sem categoria'),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                  Chip(
                    avatar: Icon(
                      _priorityIcon(note['priority']),
                      color: _priorityColor(note['priority'], theme),
                      size: 18,
                    ),
                    label: Text(
                      note['priority'] ?? 'Média',
                      style: TextStyle(
                        color: _priorityColor(note['priority'], theme),
                      ),
                    ),
                    side: BorderSide(
                      color: _priorityColor(note['priority'], theme),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NoteDetailSection(
                icon: Icons.calendar_today,
                title: 'Data',
                content: dateStr,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              if (hasLinkedAnimal)
                _NoteDetailSection(
                  icon: Icons.pets,
                  title: 'Animal vinculado',
                  content: animalLabel!,
                  color: animalColor ?? theme.colorScheme.secondary,
                )
              else
                _NoteDetailSection(
                  icon: Icons.pets_outlined,
                  title: 'Animal vinculado',
                  content: 'Nenhum animal vinculado a esta anotação',
                  color: theme.colorScheme.onSurface,
                ),
              const SizedBox(height: 8),
              _NoteDetailSection(
                icon: Icons.person_outline,
                title: 'Criado por',
                content: createdBy.isEmpty ? 'Autor não informado' : createdBy,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              _NoteDetailSection(
                icon: Icons.description_outlined,
                title: 'Descrição / Detalhes',
                content: content,
                color: theme.colorScheme.primary,
                isMultiline: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final shouldMark = note['is_read'] != 1;
            Navigator.of(context).pop(shouldMark);
          },
          child: Text(
            note['is_read'] == 1 ? 'Fechar' : 'Marcar como lida e fechar',
          ),
        ),
      ],
    );
  }

  Color _priorityColor(String? priority, ThemeData theme) {
    switch (priority) {
      case 'Alta':
        return theme.colorScheme.error;
      case 'Baixa':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _priorityIcon(String? priority) {
    switch (priority) {
      case 'Alta':
        return Icons.priority_high;
      case 'Baixa':
        return Icons.arrow_downward;
      default:
        return Icons.drag_handle;
    }
  }
}

class _NoteDetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final bool isMultiline;

  const _NoteDetailSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
