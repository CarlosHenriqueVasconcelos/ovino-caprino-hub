import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/deceased_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'animal_history_dialog.dart';

class AnimalCard extends StatefulWidget {
  final Animal animal;
  final Function(Animal)? onEdit;
  final Animal? mother;
  final Animal? father;
  final List<Animal> offspring;
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
    _cache = _buildCache(widget.animal);
  }

  @override
  void didUpdateWidget(covariant AnimalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animal != widget.animal) {
      _cache = _buildCache(widget.animal);
    }
  }

  _DisplayCache _buildCache(Animal animal) {
    final genderLower = animal.gender.toLowerCase();
    final genderLabel = _genderLabel(genderLower);
    final code = animal.code.trim();
    final lote = (animal.lote ?? '').trim();

    final subtitleParts = <String>[
      if (code.isNotEmpty) code,
      genderLabel,
      if (lote.isNotEmpty) lote,
    ];
    final subtitle = subtitleParts.isEmpty
        ? '(Sem identificação)'
        : '(${subtitleParts.join(', ')})';

    return _DisplayCache(
      name: animal.name.trim().isEmpty ? 'Sem nome' : animal.name.trim(),
      subtitle: subtitle,
      breed: animal.breed.trim().isEmpty ? 'Raça não informada' : animal.breed,
      ageText: animal.ageText,
      weightText: _weightText(animal.weight),
      loteText: lote,
      locationText: animal.location.trim().isEmpty
          ? 'Aprisco não informado'
          : animal.location.trim(),
      status: animal.status,
      statusLower: animal.status.toLowerCase(),
      hasHealthIssue: (animal.healthIssue ?? '').trim().isNotEmpty,
      pregnant: animal.pregnant,
      nameColorLower: animal.nameColor.toLowerCase(),
    );
  }

  String _weightText(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}kg';
    }
    return '${value.toStringAsFixed(1)}kg';
  }

  String _genderLabel(String genderLower) {
    if (genderLower.contains('fêmea') ||
        genderLower.contains('femea') ||
        genderLower == 'f') {
      return 'Fêmea';
    }
    if (genderLower.contains('macho') || genderLower == 'm') {
      return 'Macho';
    }
    return 'Sexo N/I';
  }

  Color _parseColor(String colorNameLower) {
    return _colorMap[colorNameLower] ?? AppColors.textPrimary;
  }

  Color _statusColor(String statusLower) {
    switch (statusLower) {
      case 'saudável':
        return AppColors.primary;
      case 'em tratamento':
      case 'ferido':
        return AppColors.warning;
      case 'óbito':
        return AppColors.error;
      case 'vendido':
        return AppColors.primarySupport;
      default:
        return AppColors.textSecondary;
    }
  }

  List<_CompactChipData> _buildMainChips({required int maxCount}) {
    final chips = <_CompactChipData>[
      _CompactChipData(
        label: _cache.status,
        icon: Icons.flag_outlined,
        color: _statusColor(_cache.statusLower),
      ),
    ];

    if (_cache.hasHealthIssue) {
      chips.add(
        const _CompactChipData(
          label: 'Atenção',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
        ),
      );
    } else if (_cache.pregnant) {
      chips.add(
        const _CompactChipData(
          label: 'Gestante',
          icon: Icons.favorite_outline,
          color: AppColors.warning,
        ),
      );
    }

    return chips.take(maxCount).toList(growable: false);
  }

  String? _avatarAssetForBreed(String breedLower) {
    if (breedLower.contains('hampshire')) {
      return 'assets/icons/cards/Icone_hamp.png';
    }
    return null;
  }

  String? _illustrationAssetForBreed(String breedLower) {
    if (breedLower.contains('hampshire')) {
      return 'assets/images/cards/card_hamp.png';
    }
    return null;
  }

  Future<void> _openHistory() async {
    await AnimalHistoryDialog.showAdaptive(
      context,
      animal: widget.animal,
    );
  }

  Future<void> _handleMenuAction(String value) async {
    if (value == 'edit' && widget.onEdit != null) {
      widget.onEdit!(widget.animal);
      return;
    }

    if (value == 'deceased') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Registrar Óbito'),
          content: Text(
            'Marcar "${widget.animal.name}" como falecido?\n\n'
            'O animal será movido para a lista de óbitos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Registrar Óbito'),
            ),
          ],
        ),
      );

      if (!mounted || confirm != true) return;

      try {
        final deceasedService = context.read<DeceasedService>();
        final animalService = context.read<AnimalService>();
        await deceasedService.markAsDeceased(
          animalId: widget.animal.id,
          deathDate: DateTime.now(),
          causeOfDeath: widget.animal.healthIssue,
          notes: 'Registrado manualmente pelo usuário',
        );
        if (!mounted) return;

        await animalService.refreshAlerts();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Animal registrado como óbito'),
            backgroundColor: AppColors.error,
          ),
        );
        widget.onAnimalChanged?.call();
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (value == 'delete_all' && widget.onDeleteCascade != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: Text(
            'Apagar TUDO relacionado a "${widget.animal.name}"?\n\n'
            'Isso inclui pesos, vacinas, medicações, anotações, financeiro e reprodução.',
          ),
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

      if (!mounted || confirm != true) return;

      await widget.onDeleteCascade!(widget.animal);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal e registros excluídos')),
      );
    }
  }

  Widget _buildCompactCard(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final tiny = width < 300;
        final dense = width < 340;

        final padding = tiny ? 10.0 : 12.0;
        final illustrationWidth = tiny ? 88.0 : (dense ? 98.0 : 112.0);
        final illustrationHeight = tiny ? 68.0 : (dense ? 80.0 : 90.0);

        return RepaintBoundary(
          child: Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: AppColors.borderNeutral.withValues(alpha: 0.78),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimalCardHeader(
                    animal: widget.animal,
                    name: _cache.name,
                    subtitle: _cache.subtitle,
                    nameColor: _parseColor(_cache.nameColorLower),
                    avatarAssetPath: _avatarAssetForBreed(_cache.breed.toLowerCase()),
                    chips: _buildMainChips(maxCount: dense ? 1 : 2),
                    statusColor: _statusColor(_cache.statusLower),
                    offspringCount: widget.offspring.length,
                    onMenuSelected: _handleMenuAction,
                    canEdit: widget.onEdit != null,
                    canDeleteCascade: widget.onDeleteCascade != null,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _AnimalCardSummary(
                          breed: _cache.breed,
                          ageText: _cache.ageText,
                          metrics: _AnimalCardMetrics(
                            weightText: _cache.weightText,
                            loteText: _cache.loteText,
                            dense: dense,
                          ),
                          metaRow: _AnimalCardMetaRow(
                            location: _cache.locationText,
                            dense: dense,
                            onOpenHistory: _openHistory,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _AnimalCardIllustration(
                        width: illustrationWidth,
                        height: illustrationHeight,
                        assetPath: _illustrationAssetForBreed(_cache.breed.toLowerCase()),
                        speciesIcon: widget.animal.speciesIcon,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCompactCard(context);
  }
}

class _AnimalCardHeader extends StatelessWidget {
  final Animal animal;
  final String name;
  final String subtitle;
  final Color nameColor;
  final String? avatarAssetPath;
  final List<_CompactChipData> chips;
  final Color statusColor;
  final int offspringCount;
  final Future<void> Function(String value) onMenuSelected;
  final bool canEdit;
  final bool canDeleteCascade;

  const _AnimalCardHeader({
    required this.animal,
    required this.name,
    required this.subtitle,
    required this.nameColor,
    required this.avatarAssetPath,
    required this.chips,
    required this.statusColor,
    required this.offspringCount,
    required this.onMenuSelected,
    required this.canEdit,
    required this.canDeleteCascade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnimalCardAvatar(
          speciesIcon: animal.speciesIcon,
          assetPath: avatarAssetPath,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: nameColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 5),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: chips
                      .map((chip) => _CompactChip(data: chip))
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _HeaderStatusMeta(
              statusColor: statusColor,
              offspringCount: offspringCount,
            ),
            PopupMenuButton<String>(
              tooltip: 'Ações',
              icon: const Icon(Icons.more_vert_rounded, size: 18),
              onSelected: onMenuSelected,
              itemBuilder: (ctx) => [
                if (canEdit)
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                if (animal.status != 'Óbito' && animal.status != 'Vendido')
                  const PopupMenuItem<String>(
                    value: 'deceased',
                    child: Row(
                      children: [
                        Icon(Icons.heart_broken, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Registrar Óbito'),
                      ],
                    ),
                  ),
                if (canDeleteCascade)
                  const PopupMenuItem<String>(
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
      ],
    );
  }
}

class _HeaderStatusMeta extends StatelessWidget {
  final Color statusColor;
  final int offspringCount;

  const _HeaderStatusMeta({
    required this.statusColor,
    required this.offspringCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.borderNeutral.withValues(alpha: 0.85),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.health_and_safety_outlined, size: 12, color: statusColor),
          const SizedBox(width: 2),
          Icon(Icons.circle_outlined, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(
            '$offspringCount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _AnimalCardSummary extends StatelessWidget {
  final String breed;
  final String ageText;
  final Widget metrics;
  final Widget metaRow;

  const _AnimalCardSummary({
    required this.breed,
    required this.ageText,
    required this.metrics,
    required this.metaRow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          breed,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          ageText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        metrics,
        const SizedBox(height: 5),
        metaRow,
      ],
    );
  }
}

class _AnimalCardMetrics extends StatelessWidget {
  final String weightText;
  final String loteText;
  final bool dense;

  const _AnimalCardMetrics({
    required this.weightText,
    required this.loteText,
    required this.dense,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricLine(
          icon: Icons.monitor_weight_outlined,
          text: weightText,
          style: style,
          dense: dense,
        ),
        const SizedBox(height: 4),
        _MetricLine(
          icon: Icons.badge_outlined,
          text: loteText.isNotEmpty ? loteText : 'Sem lote',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
          dense: dense,
        ),
      ],
    );
  }
}

class _AnimalCardMetaRow extends StatelessWidget {
  final String location;
  final bool dense;
  final VoidCallback onOpenHistory;

  const _AnimalCardMetaRow({
    required this.location,
    required this.dense,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 210 && !dense;

        final locationChip = _AnimalCardLocationChip(location: location);
        final historyButton = dense
            ? IconButton(
                onPressed: onOpenHistory,
                icon: const Icon(Icons.history_rounded, size: 16),
                tooltip: 'Ver histórico',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              )
            : TextButton.icon(
                onPressed: onOpenHistory,
                icon: const Icon(Icons.history_rounded, size: 14),
                label: const Text('Ver Histórico'),
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  minimumSize: const Size(0, 28),
                ),
              );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              locationChip,
              const SizedBox(height: 2),
              historyButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: locationChip),
            const SizedBox(width: AppSpacing.xxs),
            historyButton,
          ],
        );
      },
    );
  }
}

class _AnimalCardLocationChip extends StatelessWidget {
  final String location;

  const _AnimalCardLocationChip({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.goldSoft.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.goldSoft.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, size: 13, color: AppColors.textPrimary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimalCardIllustration extends StatelessWidget {
  final double width;
  final double height;
  final String? assetPath;
  final String speciesIcon;

  const _AnimalCardIllustration({
    required this.width,
    required this.height,
    required this.assetPath,
    required this.speciesIcon,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = _FallbackAnimalArt(
      width: width,
      height: height,
      speciesIcon: speciesIcon,
    );

    if (assetPath == null) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          assetPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

class _FallbackAnimalArt extends StatelessWidget {
  final double width;
  final double height;
  final String speciesIcon;

  const _FallbackAnimalArt({
    required this.width,
    required this.height,
    required this.speciesIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderNeutral.withValues(alpha: 0.75),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surface,
            AppColors.primaryLight.withValues(alpha: 0.65),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        speciesIcon,
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}

class _AnimalCardAvatar extends StatelessWidget {
  final String speciesIcon;
  final String? assetPath;

  const _AnimalCardAvatar({
    required this.speciesIcon,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath == null) {
      return _AvatarFallback(speciesIcon: speciesIcon);
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderNeutral.withValues(alpha: 0.75),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AvatarFallback(speciesIcon: speciesIcon),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String speciesIcon;

  const _AvatarFallback({required this.speciesIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        speciesIcon,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextStyle? style;
  final bool dense;

  const _MetricLine({
    required this.icon,
    required this.text,
    required this.style,
    required this.dense,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: dense ? 14 : 15, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _CompactChipData {
  final String label;
  final IconData icon;
  final Color color;

  const _CompactChipData({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _CompactChip extends StatelessWidget {
  final _CompactChipData data;

  const _CompactChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: data.color.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 11, color: data.color),
          const SizedBox(width: 3),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: data.color,
                ),
          ),
        ],
      ),
    );
  }
}

class _DisplayCache {
  final String name;
  final String subtitle;
  final String breed;
  final String ageText;
  final String weightText;
  final String loteText;
  final String locationText;
  final String status;
  final String statusLower;
  final bool hasHealthIssue;
  final bool pregnant;
  final String nameColorLower;

  const _DisplayCache({
    required this.name,
    required this.subtitle,
    required this.breed,
    required this.ageText,
    required this.weightText,
    required this.loteText,
    required this.locationText,
    required this.status,
    required this.statusLower,
    required this.hasHealthIssue,
    required this.pregnant,
    required this.nameColorLower,
  });
}
