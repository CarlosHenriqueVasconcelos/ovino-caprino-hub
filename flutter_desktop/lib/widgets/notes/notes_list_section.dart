import 'package:flutter/material.dart';

import '../../utils/animal_record_display.dart';
import 'notes_helpers.dart';

class NotesListSection extends StatelessWidget {
  final List<Map<String, dynamic>> notes;
  final ValueChanged<Map<String, dynamic>> onViewDetails;
  final ValueChanged<Map<String, dynamic>>? onMarkAsRead;
  final ValueChanged<Map<String, dynamic>>? onDelete;

  const NotesListSection({
    super.key,
    required this.notes,
    required this.onViewDetails,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _NoteCard(
          note: note,
          onTap: () => onViewDetails(note),
          onMarkAsRead: onMarkAsRead != null ? () => onMarkAsRead!(note) : null,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsRead;
  final ValueChanged<Map<String, dynamic>>? onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = note['is_read'] == 1;
    final dateStr = formatNoteDate(note['date']);
    final contentPreview = formatNoteContentPreview(note['content']);
    final hasLinkedAnimal = note['animal_id'] != null;
    final animalLabel =
        hasLinkedAnimal ? AnimalRecordDisplay.labelFromRecord(note) : null;
    final animalColor =
        hasLinkedAnimal ? AnimalRecordDisplay.colorFromRecord(note) : null;

    final (priorityColor, priorityIcon) = _priorityVisuals(
      note['priority'],
      theme,
    );

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
      color: isRead
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerHighest,
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    if (hasLinkedAnimal)
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
                              animalLabel!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: animalColor ?? theme.colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (hasLinkedAnimal) const SizedBox(height: 4),
                    Text(
                      contentPreview,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        if (!isRead && onMarkAsRead != null) ...[
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Marcar como lida'),
                            onPressed: onMarkAsRead,
                          ),
                        ],
                        if (onDelete != null) ...[
                          const SizedBox(width: 12),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Excluir'),
                            onPressed: () => onDelete!(note),
                          ),
                        ],
                        if (onDelete != null) ...[
                          const SizedBox(width: 12),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Excluir'),
                            onPressed: () => onDelete!(note),
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

  (Color, IconData) _priorityVisuals(
    String? priority,
    ThemeData theme,
  ) {
    switch (priority) {
      case 'Alta':
        return (theme.colorScheme.error, Icons.warning_amber_rounded);
      case 'Baixa':
        return (Colors.green.shade600, Icons.arrow_downward_rounded);
      default:
        return (Colors.orange.shade700, Icons.drag_handle_rounded);
    }
  }
}
