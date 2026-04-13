import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/animal.dart';
import '../../../../services/animal_service.dart';
import '../../../../services/deceased_service.dart';
import '../../../../theme/app_colors.dart';
import 'animal_history_dialog.dart';

class AnimalCard extends StatefulWidget {
  final Animal animal;
  final Function(Animal)? onEdit;
  final Animal? mother;
  final Animal? father;
  final List<Animal> offspring;
  final int? offspringMaleCount;
  final int? offspringFemaleCount;
  final int? offspringTotalCount;
  final Future<void> Function(Animal)? onDeleteCascade;
  final VoidCallback? onAnimalChanged;

  const AnimalCard({
    super.key,
    required this.animal,
    this.onEdit,
    this.mother,
    this.father,
    this.offspring = const [],
    this.offspringMaleCount,
    this.offspringFemaleCount,
    this.offspringTotalCount,
    this.onDeleteCascade,
    this.onAnimalChanged,
  });

  @override
  State<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends State<AnimalCard> {
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
    final rawName = animal.name.trim();
    final rawColor = animal.nameColor.trim();

    final subtitleParts = <String>[
      if (code.isNotEmpty) code,
      genderLabel,
    ];
    final subtitle = subtitleParts.isEmpty
        ? 'Sem identificação'
        : subtitleParts.join(', ');

    final displayName = _buildDisplayName(
      rawName.isEmpty ? 'Sem nome' : rawName,
      rawColor,
    );

    return _DisplayCache(
      name: displayName,
      subtitle: subtitle,
      breed: animal.breed.trim().isEmpty ? 'Raça não informada' : animal.breed,
      ageText: animal.ageText,
      weightText: _weightText(animal.weight),
      footerLoteMeta: _buildFooterLoteMeta(lote),
      locationText: animal.location.trim().isEmpty
          ? 'Aprisco'
          : animal.location.trim(),
      statusLower: animal.status.toLowerCase(),
    );
  }

  String _buildDisplayName(String name, String color) {
    final cleanColor = color.trim();
    if (cleanColor.isEmpty) return name;

    final normalizedColor = _colorToPortuguese(cleanColor);
    final lowerName = name.toLowerCase();
    final lowerColor = normalizedColor.toLowerCase();

    if (lowerName.contains(lowerColor)) return name;
    return '$name - $normalizedColor';
  }

  String _colorToPortuguese(String value) {
    final normalized = value.trim().toLowerCase();

    const translations = <String, String>{
      'red': 'Vermelho',
      'blue': 'Azul',
      'green': 'Verde',
      'yellow': 'Amarelo',
      'orange': 'Laranja',
      'purple': 'Roxo',
      'pink': 'Rosa',
      'grey': 'Cinza',
      'gray': 'Cinza',
      'black': 'Preto',
      'white': 'Branco',
      'cyan': 'Ciano',
      'teal': 'Turquesa',
      'indigo': 'Índigo',
      'lime': 'Lima',
      'amber': 'Âmbar',
      'vermelho': 'Vermelho',
      'azul': 'Azul',
      'verde': 'Verde',
      'amarelo': 'Amarelo',
      'laranja': 'Laranja',
      'roxo': 'Roxo',
      'rosa': 'Rosa',
      'cinza': 'Cinza',
      'preto': 'Preto',
      'branco': 'Branco',
      'ciano': 'Ciano',
      'turquesa': 'Turquesa',
      'lima': 'Lima',
      'ambar': 'Âmbar',
    };

    return translations[normalized] ?? _capitalizeWords(value);
  }

  String _capitalizeWords(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  String _buildFooterLoteMeta(String lote) {
    if (lote.trim().isEmpty) return 'Lote N/I';

    final normalized = lote.trim();
    final upper = normalized.toUpperCase();
    if (upper == normalized) return normalized;
    return '$normalized   $upper';
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
        return AppColors.goldSoft;
      default:
        return AppColors.textSecondary;
    }
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
        final ultraCompact = width <= 340;
        final compact = width <= 380;

        final cardBackground = Color.alphaBlend(
          AppColors.beigeSoft.withValues(alpha: 0.03),
          AppColors.white,
        );
        final borderRadius = BorderRadius.circular(16);

        final padding = compact ? 10.0 : 11.0;
        const headerBodyGap = 8.0;
        final rightMetaWidth = ultraCompact ? 118.0 : (compact ? 126.0 : 136.0);
        final illustrationWidth = ultraCompact ? 252.0 : (compact ? 292.0 : 324.0);
        final illustrationHeight = ultraCompact ? 162.0 : (compact ? 190.0 : 210.0);
        final contentRightInset = ultraCompact ? 118.0 : (compact ? 138.0 : 156.0);
        final imageRight = ultraCompact ? -18.0 : (compact ? -22.0 : -26.0);
        final imageBottom = ultraCompact ? -40.0 : (compact ? -36.0 : -32.0);
        final maleCount = widget.offspringMaleCount ??
            widget.offspring
                .where((animal) =>
                    animal.gender.toLowerCase().trim().startsWith('m'))
                .length;
        final femaleCount = widget.offspringFemaleCount ??
            widget.offspring
                .where((animal) =>
                    animal.gender.toLowerCase().trim().startsWith('f'))
                .length;
        final totalCount = widget.offspringTotalCount ?? widget.offspring.length;

        return RepaintBoundary(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: borderRadius,
                border: Border.all(
                  color: AppColors.borderNeutral.withValues(alpha: 0.65),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openHistory,
                  borderRadius: borderRadius,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AnimalCardHeader(
                          animal: widget.animal,
                          name: _cache.name,
                          subtitle: _cache.subtitle,
                          nameColor: AppColors.textPrimary,
                          avatarAssetPath:
                              _avatarAssetForBreed(_cache.breed.toLowerCase()),
                          statusColor: _statusColor(_cache.statusLower),
                          statusLower: _cache.statusLower,
                          offspringMaleCount: maleCount,
                          offspringFemaleCount: femaleCount,
                          offspringTotalCount: totalCount,
                          onMenuSelected: _handleMenuAction,
                          canEdit: widget.onEdit != null,
                          canDeleteCascade: widget.onDeleteCascade != null,
                          rightMetaWidth: rightMetaWidth,
                          ultraCompact: ultraCompact,
                        ),
                        const SizedBox(height: headerBodyGap),
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              Positioned(
                                right: imageRight,
                                bottom: imageBottom,
                                child: IgnorePointer(
                                  child: _AnimalCardIllustration(
                                    width: illustrationWidth,
                                    height: illustrationHeight,
                                    scale: 1.06,
                                    assetPath: _illustrationAssetForBreed(
                                      _cache.breed.toLowerCase(),
                                    ),
                                    speciesIcon: widget.animal.speciesIcon,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.only(right: contentRightInset),
                                  child: _AnimalCardMainInfo(
                                    breed: _cache.breed,
                                    ageText: _cache.ageText,
                                    weightText: _cache.weightText,
                                    loteMetaText: _cache.footerLoteMeta,
                                    locationText: _cache.locationText,
                                    ultraCompact: ultraCompact,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
  final Color statusColor;
  final String statusLower;
  final int offspringMaleCount;
  final int offspringFemaleCount;
  final int offspringTotalCount;
  final Future<void> Function(String value) onMenuSelected;
  final bool canEdit;
  final bool canDeleteCascade;
  final double rightMetaWidth;
  final bool ultraCompact;

  const _AnimalCardHeader({
    required this.animal,
    required this.name,
    required this.subtitle,
    required this.nameColor,
    required this.avatarAssetPath,
    required this.statusColor,
    required this.statusLower,
    required this.offspringMaleCount,
    required this.offspringFemaleCount,
    required this.offspringTotalCount,
    required this.onMenuSelected,
    required this.canEdit,
    required this.canDeleteCascade,
    required this.rightMetaWidth,
    required this.ultraCompact,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = ultraCompact ? 30.0 : 32.0;
    final titleSize = ultraCompact ? 15.0 : 16.0;
    final subtitleStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: AppColors.textSecondary.withValues(alpha: 0.9),
          fontWeight: FontWeight.w400,
        );
    final nameStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: titleSize,
          color: nameColor,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: 1.1,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AnimalCardAvatar(
                speciesIcon: animal.speciesIcon,
                assetPath: avatarAssetPath,
                size: avatarSize,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: nameStyle,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: rightMetaWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _HeaderMetaIndicators(
                statusColor: statusColor,
                statusLower: statusLower,
                offspringMaleCount: offspringMaleCount,
                offspringFemaleCount: offspringFemaleCount,
                offspringTotalCount: offspringTotalCount,
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Ações',
                icon: const Icon(Icons.more_vert_rounded, size: 18),
                padding: EdgeInsets.zero,
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
        ),
      ],
    );
  }
}

class _HeaderMetaIndicators extends StatelessWidget {
  final Color statusColor;
  final String statusLower;
  final int offspringMaleCount;
  final int offspringFemaleCount;
  final int offspringTotalCount;

  const _HeaderMetaIndicators({
    required this.statusColor,
    required this.statusLower,
    required this.offspringMaleCount,
    required this.offspringFemaleCount,
    required this.offspringTotalCount,
  });

  IconData _statusIcon(String statusLower) {
    switch (statusLower) {
      case 'vendido':
        return Icons.sell_rounded;
      case 'óbito':
        return Icons.heart_broken_outlined;
      case 'em tratamento':
      case 'ferido':
        return Icons.warning_amber_rounded;
      default:
        return Icons.health_and_safety_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary.withValues(alpha: 0.9),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_statusIcon(statusLower), size: 12, color: statusColor),
        const SizedBox(width: 4),
        Icon(
          Icons.male_rounded,
          size: 11,
          color: AppColors.primary.withValues(alpha: 0.88),
        ),
        const SizedBox(width: 2),
        Text('$offspringMaleCount', style: textStyle),
        const SizedBox(width: 4),
        Icon(
          Icons.female_rounded,
          size: 11,
          color: AppColors.goldSoft.withValues(alpha: 0.92),
        ),
        const SizedBox(width: 2),
        Text('$offspringFemaleCount', style: textStyle),
        const SizedBox(width: 4),
        Icon(
          Icons.circle_outlined,
          size: 11,
          color: AppColors.textSecondary.withValues(alpha: 0.88),
        ),
        const SizedBox(width: 2),
        Text('$offspringTotalCount', style: textStyle),
      ],
    );
  }
}

class _AnimalCardMainInfo extends StatelessWidget {
  final String breed;
  final String ageText;
  final String weightText;
  final String loteMetaText;
  final String locationText;
  final bool ultraCompact;

  const _AnimalCardMainInfo({
    required this.breed,
    required this.ageText,
    required this.weightText,
    required this.loteMetaText,
    required this.locationText,
    required this.ultraCompact,
  });

  @override
  Widget build(BuildContext context) {
    final breedStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: ultraCompact ? 13 : 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.1,
        );

    final ageStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary.withValues(alpha: 0.88),
        );

    final weightStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: ultraCompact ? 14 : 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          breed,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: breedStyle,
        ),
        const SizedBox(height: 2),
        Text(
          ageText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ageStyle,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                weightText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: weightStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.badge_outlined,
              size: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.88),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                loteMetaText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: _FooterLocationChip(
            label: locationText,
          ),
        ),
      ],
    );
  }
}

class _FooterLocationChip extends StatelessWidget {
  final String label;

  const _FooterLocationChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final chipLabelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFB7953C),
        );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 96,
        minHeight: 24,
      ),
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E6BE),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.place_outlined,
              size: 10,
              color: Color(0xFFB7953C),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: chipLabelStyle,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              size: 11,
              color: Color(0xFFB7953C),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalCardIllustration extends StatelessWidget {
  final double width;
  final double height;
  final double scale;
  final String? assetPath;
  final String speciesIcon;

  const _AnimalCardIllustration({
    required this.width,
    required this.height,
    required this.scale,
    required this.assetPath,
    required this.speciesIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath == null) {
      return _FallbackAnimalArt(
        width: width,
        height: height,
        speciesIcon: speciesIcon,
      );
    }

    final safeScale = scale.clamp(1.0, 1.06);

    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomRight,
        child: SizedBox(
          width: width * safeScale,
          height: height * safeScale,
          child: Image.asset(
            assetPath!,
            fit: BoxFit.contain,
            alignment: Alignment.bottomRight,
            errorBuilder: (_, __, ___) => _FallbackAnimalArt(
              width: width,
              height: height,
              speciesIcon: speciesIcon,
            ),
          ),
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
    return Align(
      alignment: Alignment.bottomRight,
      child: Opacity(
        opacity: 0.86,
        child: Text(
          speciesIcon,
          style: TextStyle(fontSize: height * 0.58),
        ),
      ),
    );
  }
}

class _AnimalCardAvatar extends StatelessWidget {
  final String speciesIcon;
  final String? assetPath;
  final double size;

  const _AnimalCardAvatar({
    required this.speciesIcon,
    required this.assetPath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath == null) {
      return _AvatarFallback(
        speciesIcon: speciesIcon,
        size: size,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderNeutral.withValues(alpha: 0.78),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AvatarFallback(
          speciesIcon: speciesIcon,
          size: size,
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String speciesIcon;
  final double size;

  const _AvatarFallback({
    required this.speciesIcon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        speciesIcon,
        style: TextStyle(fontSize: size * 0.46),
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
  final String footerLoteMeta;
  final String locationText;
  final String statusLower;

  const _DisplayCache({
    required this.name,
    required this.subtitle,
    required this.breed,
    required this.ageText,
    required this.weightText,
    required this.footerLoteMeta,
    required this.locationText,
    required this.statusLower,
  });
}
