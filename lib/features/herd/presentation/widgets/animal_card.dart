import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/buttons/secondary_button.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/deceased_service.dart';
import 'animal_history_dialog.dart';

class AnimalCard extends StatefulWidget {
  final Animal animal;
  final Function(Animal)? onEdit;
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
    this.mother,
    this.father,
    this.offspring = const [],
    this.onDeleteCascade,
    this.onAnimalChanged,
  });

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
  static final DateFormat _df = DateFormat('dd/MM/yyyy');
  static const Map<String, Color> _colorMap = {
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

  late _DisplayCache _cache;

  @override
  void initState() {
    super.initState();
    _cache = _buildCache(
      widget.animal,
      widget.mother,
      widget.father,
      widget.offspring,
    );
  }

  @override
  void didUpdateWidget(covariant AnimalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_needsCacheUpdate(oldWidget, widget)) {
      _cache = _buildCache(
        widget.animal,
        widget.mother,
        widget.father,
        widget.offspring,
      );
    }
  }

  bool _needsCacheUpdate(AnimalCard oldWidget, AnimalCard newWidget) {
    if (oldWidget.animal != newWidget.animal) return true;
    if (oldWidget.mother != newWidget.mother) return true;
    if (oldWidget.father != newWidget.father) return true;
    return !_sameOffspring(oldWidget.offspring, newWidget.offspring);
  }

  bool _sameOffspring(List<Animal> a, List<Animal> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    if (a.isEmpty) return true;
    return a.first.id == b.first.id && a.last.id == b.last.id;
  }

  _DisplayCache _buildCache(
    Animal animal,
    Animal? mother,
    Animal? father,
    List<Animal> offspring,
  ) {
    final statusLower = animal.status.toLowerCase();
    final genderLower = animal.gender.toLowerCase();
    final nameColorLower = animal.nameColor.toLowerCase();
    final hasHealthIssue = animal.healthIssue != null;
    final pregnant = animal.pregnant;
    final expectedDeliveryText = pregnant && animal.expectedDelivery != null
        ? 'Parto previsto: ${_df.format(animal.expectedDelivery!)}'
        : null;
    final lastVaccinationText = animal.lastVaccination != null
        ? 'Última vacinação: ${_df.format(animal.lastVaccination!)}'
        : null;

    final offspringLines = offspring
        .take(4)
        .map((child) =>
            '• ${child.name} (${child.category.isEmpty ? "Sem categoria" : child.category})')
        .toList(growable: false);
    final reproductiveStatus = animal.reproductiveStatus.trim().isEmpty
        ? 'Não aplicável'
        : animal.reproductiveStatus.trim();

    return _DisplayCache(
      name: animal.name,
      code: animal.code,
      status: animal.status,
      reproductiveStatus: reproductiveStatus,
      category: animal.category,
      breed: animal.breed,
      ageText: animal.ageText,
      weightText: '${animal.weight}kg',
      location: animal.location,
      yearText: animal.year != null ? 'Ano: ${animal.year}' : null,
      loteText: animal.lote != null ? 'Lote: ${animal.lote}' : null,
      motherText: mother != null ? 'Mãe: ${mother.name} (${mother.code})' : null,
      fatherText: father != null ? 'Pai: ${father.name} (${father.code})' : null,
      offspringTitle:
          offspring.isNotEmpty ? 'Crias (${offspring.length}):' : null,
      offspringLines: offspringLines,
      offspringMoreText: offspring.length > 4
          ? 'e mais ${offspring.length - 4} filhote(s)...'
          : null,
      expectedDeliveryText: expectedDeliveryText,
      lastVaccinationText: lastVaccinationText,
      healthIssueText: animal.healthIssue,
      statusLower: statusLower,
      genderLower: genderLower,
      nameColorLower: nameColorLower,
      hasHealthIssue: hasHealthIssue,
      pregnant: pregnant,
      hasParents: mother != null || father != null,
      hasOffspring: offspring.isNotEmpty,
      hasYear: animal.year != null,
      hasLote: animal.lote != null,
    );
  }

  Color _parseColor(String colorNameLower) {
    return _colorMap[colorNameLower] ?? Colors.black;
  }

  StatusChipVariant _statusVariant(String statusLower) {
    switch (statusLower) {
      case 'saudável':
        return StatusChipVariant.success;
      case 'em tratamento':
      case 'ferido':
        return StatusChipVariant.warning;
      case 'óbito':
        return StatusChipVariant.danger;
      case 'vendido':
        return StatusChipVariant.info;
      default:
        return StatusChipVariant.neutral;
    }
  }

  // Chip de sexo usando o campo gender
  Widget _sexChip(String genderLower) {
    late String label;
    late IconData icon;
    late StatusChipVariant variant;
    if (genderLower.contains('fêmea') ||
        genderLower.contains('femea') ||
        genderLower == 'f') {
      label = 'Fêmea';
      icon = Icons.female;
      variant = StatusChipVariant.warning;
    } else if (genderLower.contains('macho') || genderLower == 'm') {
      label = 'Macho';
      icon = Icons.male;
      variant = StatusChipVariant.info;
    } else {
      label = 'Sexo N/I';
      icon = Icons.help_outline;
      variant = StatusChipVariant.neutral;
    }

    return StatusChip(
      label: label,
      icon: icon,
      variant: variant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motherAnimal = widget.mother;
    final fatherAnimal = widget.father;

    return RepaintBoundary(
      child: Card(
        elevation: _cache.hasHealthIssue ? 2.5 : 1.0,
        margin: EdgeInsets.zero,
        shadowColor: _cache.hasHealthIssue
            ? theme.colorScheme.error.withValues(alpha: 0.18)
            : Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.borderNeutral.withValues(alpha: 0.75),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.animal.speciesIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cache.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _parseColor(_cache.nameColorLower),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: 2,
                          children: [
                            Text(
                              _cache.code,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.62),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_cache.loteText != null)
                              Text(
                                _cache.loteText!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
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
                                'Marcar "${widget.animal.name}" como falecido?\n\n'
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
                        if (!context.mounted) return;
                        if (ok == true) {
                          try {
                            final deceasedService =
                                context.read<DeceasedService>();
                            await deceasedService.markAsDeceased(
                              animalId: widget.animal.id,
                              deathDate: DateTime.now(),
                              causeOfDeath: widget.animal.healthIssue,
                              notes: 'Registrado manualmente pelo usuário',
                            );
                            if (!context.mounted) return;
                            await animalService.refreshAlerts();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Animal registrado como óbito'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            widget.onAnimalChanged?.call();
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
                          widget.onDeleteCascade != null) {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar exclusão'),
                            content: Text(
                                'Apagar TUDO relacionado a "${widget.animal.name}"?\n\n'
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
                        if (!context.mounted) return;
                        if (ok == true) {
                          await widget.onDeleteCascade!(widget.animal);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Animal e registros excluídos'),
                            ),
                          );
                        }
                      } else if (value == 'edit' && widget.onEdit != null) {
                        widget.onEdit!(widget.animal);
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (widget.onEdit != null)
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
                      if (widget.animal.status != 'Óbito' &&
                          widget.animal.status != 'Vendido')
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
                      if (widget.onDeleteCascade != null)
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
              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badges
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          StatusChip(
                            label: _cache.status,
                            variant: _statusVariant(_cache.statusLower),
                            icon: Icons.flag_outlined,
                          ),
                          _sexChip(_cache.genderLower),
                          if (_cache.category.isNotEmpty)
                            StatusChip(
                              label: _cache.category,
                              variant: StatusChipVariant.neutral,
                              icon: Icons.category_outlined,
                            ),
                          StatusChip(
                            label: 'Rep.: ${_cache.reproductiveStatus}',
                            variant: _cache.pregnant
                                ? StatusChipVariant.warning
                                : StatusChipVariant.info,
                            icon: Icons.favorite_outline,
                          ),
                          if (_cache.hasHealthIssue)
                            StatusChip(
                              label: _cache.healthIssueText ?? '',
                              variant: StatusChipVariant.danger,
                              icon: Icons.warning_amber_rounded,
                            ),
                        ],
              ),
              const SizedBox(height: 14),

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
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  _cache.breed,
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
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  _cache.ageText,
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
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    _cache.breed,
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
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    _cache.ageText,
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
              const SizedBox(height: 14),

              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monitor_weight, size: 17, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _cache.weightText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 17, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _cache.location,
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
              if (_cache.hasYear || _cache.hasLote)
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (_cache.yearText != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _cache.yearText!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    if (_cache.loteText != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.label, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _cache.loteText!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              if (_cache.hasYear || _cache.hasLote)
                const SizedBox(height: 12),

              // Informação sobre pais (mãe e pai)
              if (_cache.hasParents)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderNeutral.withValues(alpha: 0.8),
                    ),
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
                                _cache.motherText ?? '',
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
                                _cache.fatherText ?? '',
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
              if (_cache.hasOffspring)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderNeutral.withValues(alpha: 0.8),
                    ),
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
                            _cache.offspringTitle ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ..._cache.offspringLines.map(
                        (child) => Padding(
                          padding: const EdgeInsets.only(left: 24, top: 2),
                          child: Text(
                            child,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ),
                      if (_cache.offspringMoreText != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 24, top: 4),
                          child: Text(
                            _cache.offspringMoreText!,
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
              if (_cache.expectedDeliveryText != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderNeutral.withValues(alpha: 0.8),
                    ),
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
                        _cache.expectedDeliveryText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              if (_cache.expectedDeliveryText != null)
                const SizedBox(height: 8),

              // Last Vaccination
              if (_cache.lastVaccinationText != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _cache.lastVaccinationText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ] else
                const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Ações: usa linha única quando possível para reduzir altura total do card.
              LayoutBuilder(
                builder: (context, constraints) {
                  final stackActions = constraints.maxWidth < 230;

                  final historyButton = SecondaryButton(
                    label: 'Ver Histórico',
                    icon: Icons.history,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AnimalHistoryDialog(animal: widget.animal),
                      );
                    },
                  );

                  final editButton = PrimaryButton(
                    label: 'Editar',
                    icon: Icons.edit_outlined,
                    onPressed:
                        widget.onEdit != null ? () => widget.onEdit!(widget.animal) : null,
                  );

                  if (stackActions) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        historyButton,
                        const SizedBox(height: 6),
                        editButton,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: historyButton),
                      const SizedBox(width: 8),
                      Expanded(child: editButton),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisplayCache {
  final String name;
  final String code;
  final String status;
  final String reproductiveStatus;
  final String category;
  final String breed;
  final String ageText;
  final String weightText;
  final String location;
  final String? yearText;
  final String? loteText;
  final String? motherText;
  final String? fatherText;
  final String? offspringTitle;
  final List<String> offspringLines;
  final String? offspringMoreText;
  final String? expectedDeliveryText;
  final String? lastVaccinationText;
  final String? healthIssueText;
  final String statusLower;
  final String genderLower;
  final String nameColorLower;
  final bool hasHealthIssue;
  final bool pregnant;
  final bool hasParents;
  final bool hasOffspring;
  final bool hasYear;
  final bool hasLote;

  const _DisplayCache({
    required this.name,
    required this.code,
    required this.status,
    required this.reproductiveStatus,
    required this.category,
    required this.breed,
    required this.ageText,
    required this.weightText,
    required this.location,
    required this.yearText,
    required this.loteText,
    required this.motherText,
    required this.fatherText,
    required this.offspringTitle,
    required this.offspringLines,
    required this.offspringMoreText,
    required this.expectedDeliveryText,
    required this.lastVaccinationText,
    required this.healthIssueText,
    required this.statusLower,
    required this.genderLower,
    required this.nameColorLower,
    required this.hasHealthIssue,
    required this.pregnant,
    required this.hasParents,
    required this.hasOffspring,
    required this.hasYear,
    required this.hasLote,
  });
}
