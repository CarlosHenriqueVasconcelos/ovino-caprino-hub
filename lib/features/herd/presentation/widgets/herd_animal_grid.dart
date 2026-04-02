import 'package:flutter/material.dart';

import '../../../../models/animal.dart';
import '../../../../utils/responsive_utils.dart';
import 'animal_card.dart';

class HerdAnimalGrid extends StatelessWidget {
  final List<Animal> animals;
  final Animal? Function(String?) resolveParent;
  final List<Animal> Function(String) resolveOffspring;
  final void Function(Animal)? onEdit;
  final Future<void> Function(Animal)? onDeleteCascade;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const HerdAnimalGrid({
    super.key,
    required this.animals,
    required this.resolveParent,
    required this.resolveOffspring,
    this.onEdit,
    this.onDeleteCascade,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final crossAxisCount =
            ResponsiveUtils.getAnimalGridCrossAxisCountForWidth(availableWidth);
        final spacing =
            ResponsiveUtils.getSpacing(context).clamp(8.0, 16.0).toDouble();
        final horizontalPadding = availableWidth < 420 ? 2.0 : 4.0;
        final gridPadding = EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 2,
        );

        final usableWidth = (availableWidth - gridPadding.horizontal)
            .clamp(0.0, availableWidth)
            .toDouble();
        final cellWidth = (usableWidth - (spacing * (crossAxisCount - 1))) /
            crossAxisCount;
        final safeCellWidth = cellWidth <= 0 ? 1.0 : cellWidth;
        final targetHeight = _targetHeightForGrid(
          availableWidth: availableWidth,
          crossAxisCount: crossAxisCount,
        );
        final childAspectRatio =
            (safeCellWidth / targetHeight).clamp(1.2, 2.2).toDouble();

        return GridView.builder(
          key: const PageStorageKey('herd_grid'),
          padding: gridPadding,
          controller: controller,
          primary: false,
          shrinkWrap: shrinkWrap,
          physics: physics,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          cacheExtent: 500,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: animals.length,
          itemBuilder: (context, index) {
            final animal = animals[index];
            return RepaintBoundary(
              key: ValueKey('animal_${animal.id}'),
              child: AnimalCard(
                animal: animal,
                onEdit: onEdit,
                onDeleteCascade: onDeleteCascade,
                mother: resolveParent(animal.motherId),
                father: resolveParent(animal.fatherId),
                offspring: resolveOffspring(animal.id),
              ),
            );
          },
        );
      },
    );
  }

  double _targetHeightForGrid({
    required double availableWidth,
    required int crossAxisCount,
  }) {
    if (crossAxisCount <= 1) {
      if (availableWidth < 360) return 190;
      if (availableWidth < 430) return 198;
      return 205;
    }

    if (crossAxisCount == 2) {
      if (availableWidth < 900) return 192;
      return 206;
    }

    if (crossAxisCount == 3) {
      if (availableWidth < 1200) return 200;
      return 212;
    }

    return 218;
  }
}
