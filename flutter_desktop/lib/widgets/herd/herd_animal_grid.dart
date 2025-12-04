import 'package:flutter/material.dart';

import '../../data/animal_repository.dart';
import '../../models/animal.dart';
import '../../utils/responsive_utils.dart';
import '../animal/animal_card.dart';

class HerdAnimalGrid extends StatelessWidget {
  final List<Animal> animals;
  final AnimalRepository repository;
  final Animal? Function(String?) resolveParent;
  final List<Animal> Function(String) resolveOffspring;
  final void Function(Animal)? onEdit;
  final Future<void> Function(Animal)? onDeleteCascade;

  const HerdAnimalGrid({
    super.key,
    required this.animals,
    required this.repository,
    required this.resolveParent,
    required this.resolveOffspring,
    this.onEdit,
    this.onDeleteCascade,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getAnimalGridCrossAxisCount(context);
    
    // Ajustar aspect ratio para mobile: cards mais altos para acomodar conteúdo
    double aspectRatio;
    if (crossAxisCount == 1) {
      aspectRatio = 0.55; // Mobile: bem mais alto para acomodar todo conteúdo e botões
    } else if (crossAxisCount == 2) {
      aspectRatio = 0.50; // Tablet: ainda mais alto
    } else {
      aspectRatio = ResponsiveUtils.getCardAspectRatio(context);
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
        return AnimalCard(
          animal: animal,
          repository: repository,
          onEdit: onEdit,
          onDeleteCascade: onDeleteCascade,
          mother: resolveParent(animal.motherId),
          father: resolveParent(animal.fatherId),
          offspring: resolveOffspring(animal.id),
        );
      },
    );
  }
}
