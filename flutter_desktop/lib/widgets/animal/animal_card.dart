import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/animal.dart';
import '../../utils/responsive_utils.dart';
import '../responsive/responsive_actions.dart';
import 'animal_history_dialog.dart';
import '../../data/animal_repository.dart';
import '../../services/animal_service.dart';
import '../../services/events/event_bus.dart';
import '../../services/events/app_events.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final Function(Animal)? onEdit;
  final AnimalRepository? repository;
  final Animal? mother;
  final Animal? father;
  final List<Animal> offspring;

  /// Novo: callback opcional para exclusão em cascata
  final Future<void> Function(Animal)? onDeleteCascade;
  final VoidCallback? onAnimalChanged;

  const AnimalCard({
    super.key,
    required this.animal,
    this.onEdit,
    this.repository,
    this.mother,
    this.father,
    this.offspring = const [],
    this.onDeleteCascade,
    this.onAnimalChanged,
  });

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (animal.status.toLowerCase()) {
      case 'saudável':
        return theme.colorScheme.primary;
      case 'em tratamento':
        return theme.colorScheme.error;
      case 'reprodutor':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.secondary;
    }
  }

  Color _parseColor(String colorName) {
    final colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'grey': Colors.grey,
      'black': Colors.black,
      'white': Colors.white,
      'cyan': Colors.cyan,
      'teal': Colors.teal,
      'indigo': Colors.indigo,
      'lime': Colors.lime,
      'amber': Colors.amber,
      // Português
      'vermelho': Colors.red,
      'azul': Colors.blue,
      'verde': Colors.green,
      'amarelo': Colors.yellow,
      'laranja': Colors.orange,
      'roxo': Colors.purple,
      'rosa': Colors.pink,
      'cinza': Colors.grey,
      'preto': Colors.black,
      'branco': Colors.white,
    };

    return colorMap[colorName.toLowerCase()] ?? Colors.black;
  }

  // Chip de sexo usando o campo gender
  Widget _sexChip(BuildContext context) {
    final gender = animal.gender.toLowerCase();

    late String label;
    late IconData icon;
    late Color color;

    if (gender.contains('fêmea') || gender.contains('femea') || gender == 'f') {
      label = 'Fêmea';
      icon = Icons.female;
      color = Colors.pinkAccent;
    } else if (gender.contains('macho') || gender == 'm') {
      label = 'Macho';
      icon = Icons.male;
      color = Colors.blueAccent;
    } else {
      label = 'Sexo N/I';
      icon = Icons.help_outline;
      color = Colors.grey;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context);
    final hasHealthIssue = animal.healthIssue != null;
    final motherAnimal = mother;
    final fatherAnimal = father;
    AnimalRepository? repo;
    try {
      repo = repository ?? context.read<AnimalRepository>();
    } catch (_) {
      repo = repository;
    }

    return Card(
      elevation: hasHealthIssue ? 4 : 2,
      shadowColor:
          hasHealthIssue ? theme.colorScheme.error.withValues(alpha: 0.3) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  animal.speciesIcon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _parseColor(animal.nameColor),
                        ),
                      ),
                      Text(
                        animal.code,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // 3 pontinhos — mantém o mesmo visual, só adiciona o menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    final animalService = context.read<AnimalService>();
                    if (value == 'deceased') {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Registrar Óbito'),
                          content: Text(
                              'Marcar "${animal.name}" como falecido?\n\n'
                              'O animal será movido para a lista de óbitos.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Registrar Óbito'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        try {
                          if (repo != null) {
                            await repo.markAsDeceased(
                              animalId: animal.id,
                              deathDate: DateTime.now(),
                              causeOfDeath: animal.healthIssue,
                              notes: 'Registrado manualmente pelo usuário',
                            );
                            if (!context.mounted) return;
                            await animalService.refreshAlerts();
                          } else {
                            await animalService
                                .updateAnimal(animal.copyWith(status: 'Óbito'));
                          }
                          if (!context.mounted) return;
                          EventBus().emit(AnimalMarkedAsDeceasedEvent(
                            animalId: animal.id,
                            deathDate: DateTime.now(),
                            causeOfDeath: animal.healthIssue,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Animal registrado como óbito'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          onAnimalChanged?.call();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    } else if (value == 'delete_all' &&
                        onDeleteCascade != null) {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirmar exclusão'),
                          content: Text(
                              'Apagar TUDO relacionado a "${animal.name}"?\n\n'
                              'Isso inclui pesos, vacinas, medicações, anotações, financeiro e reprodução.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await onDeleteCascade!(animal);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Animal e registros excluídos'),
                            ),
                          );
                        }
                      }
                    } else if (value == 'edit' && onEdit != null) {
                      onEdit!(animal);
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                    if (animal.status != 'Óbito')
                      const PopupMenuItem(
                        value: 'deceased',
                        child: Row(
                          children: [
                            Icon(Icons.heart_broken, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Registrar Óbito'),
                          ],
                        ),
                      ),
                    if (onDeleteCascade != null)
                      const PopupMenuItem(
                        value: 'delete_all',
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever),
                            SizedBox(width: 8),
                            Text('Excluir (apagar tudo)'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(animal.status),
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(color: statusColor.withValues(alpha: 0.2)),
                ),

                // 🔹 Novo: chip de sexo (inferido pela category)
                _sexChip(context),

                // 🔹 Chip de categoria
                if (animal.category.isNotEmpty)
                  Chip(
                    label: Text(animal.category),
                    backgroundColor:
                        theme.colorScheme.secondary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    ),
                  ),

                if (animal.pregnant)
                  Chip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.child_care, size: 16),
                        SizedBox(width: 4),
                        Text('Gestante'),
                      ],
                    ),
                    backgroundColor:
                        theme.colorScheme.tertiary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                    ),
                  ),
                if (hasHealthIssue)
                  Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, size: 16),
                        const SizedBox(width: 4),
                        Text(animal.healthIssue!),
                      ],
                    ),
                    backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Animal Info
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 300;
                return isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Raça',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                animal.breed,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Idade',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                animal.ageText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Raça',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  animal.breed,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Idade',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  animal.ageText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
              },
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monitor_weight, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${animal.weight}kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        animal.location,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ano e Lote
            if (animal.year != null || animal.lote != null)
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (animal.year != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Ano: ${animal.year}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  if (animal.lote != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.label, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Lote: ${animal.lote}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            if (animal.year != null || animal.lote != null)
              const SizedBox(height: 12),

            // Informação sobre pais (mãe e pai)
            if (motherAnimal != null || fatherAnimal != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (motherAnimal != null)
                      Row(
                        children: [
                          const Icon(Icons.female, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mãe: ${motherAnimal.name} (${motherAnimal.code})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (motherAnimal != null && fatherAnimal != null)
                      const SizedBox(height: 4),
                    if (fatherAnimal != null)
                      Row(
                        children: [
                          const Icon(Icons.male, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pai: ${fatherAnimal.name} (${fatherAnimal.code})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

            // Lista de crias (limitar a 4 no card, com indicador se houver mais)
            if (offspring.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.child_care,
                          size: 16,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Crias (${offspring.length}):',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...offspring.take(4).map(
                          (child) => Padding(
                            padding: const EdgeInsets.only(left: 24, top: 2),
                            child: Text(
                              '• ${child.name} (${child.category.isEmpty ? "Sem categoria" : child.category})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ),
                        ),
                    if (offspring.length > 4)
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 4),
                        child: Text(
                          'e mais ${offspring.length - 4} filhote(s)...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Expected Delivery
            if (animal.pregnant && animal.expectedDelivery != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Parto previsto: ${DateFormat('dd/MM/yyyy').format(animal.expectedDelivery!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            if (animal.pregnant && animal.expectedDelivery != null)
              const SizedBox(height: 8),

            // Last Vaccination
            if (animal.lastVaccination != null)
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Última vacinação: ${DateFormat('dd/MM/yyyy').format(animal.lastVaccination!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Actions - responsivas
            ResponsiveActions(
              actions: [
                if (ResponsiveUtils.isMobile(context)) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AnimalHistoryDialog(animal: animal),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('Ver Histórico'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onEdit != null ? () => onEdit!(animal) : null,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AnimalHistoryDialog(animal: animal),
                        );
                      },
                      child: const Text('Ver Histórico'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onEdit != null ? () => onEdit!(animal) : null,
                      child: const Text('Editar'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
