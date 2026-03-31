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
    final crossAxisCount = ResponsiveUtils.getAnimalGridCrossAxisCount(context);

    double aspectRatio;
    if (crossAxisCount == 1) {
      aspectRatio = 0.58;
    } else if (crossAxisCount == 2) {
      aspectRatio = 0.62;
    } else if (crossAxisCount == 3) {
      aspectRatio = 0.82;
    } else {
      aspectRatio = 0.9;
    }

    final spacing = ResponsiveUtils.getSpacing(context).clamp(12.0, 20.0);

    return GridView.builder(
      key: const PageStorageKey('herd_grid'),
      padding: const EdgeInsets.symmetric(vertical: 2),
      controller: controller,
      primary: false,
      shrinkWrap: shrinkWrap,
      physics: physics,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      addAutomaticKeepAlives: false, // Reduz memória
      addRepaintBoundaries: true,    // Evita repaint desnecessário
      cacheExtent: 500,              // Pre-carrega itens próximos
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
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
  }
}
