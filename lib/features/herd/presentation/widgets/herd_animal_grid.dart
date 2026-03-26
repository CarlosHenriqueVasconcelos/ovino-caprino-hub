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

    // Cards do rebanho têm conteúdo variável (chips extras, pais, crias, ações).
    // Em telas menores, reservar mais altura evita RenderFlex overflow no eixo vertical.
    double aspectRatio;
    if (crossAxisCount == 1) {
      aspectRatio = 0.56;
    } else if (crossAxisCount == 2) {
      aspectRatio = 0.54;
    } else if (crossAxisCount == 3) {
      aspectRatio = 0.9;
    } else {
      aspectRatio = 0.95;
    }
    
    return GridView.builder(
      key: const PageStorageKey('herd_grid'),
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
        crossAxisSpacing: ResponsiveUtils.getSpacing(context),
        mainAxisSpacing: ResponsiveUtils.getSpacing(context),
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
