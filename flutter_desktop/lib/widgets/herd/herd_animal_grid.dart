import 'package:flutter/material.dart';

import '../../data/animal_repository.dart';
import '../../models/animal.dart';
import '../../utils/responsive_utils.dart';
import '../animal_card.dart';

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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getAnimalGridCrossAxisCount(context),
        crossAxisSpacing: ResponsiveUtils.getSpacing(context),
        mainAxisSpacing: ResponsiveUtils.getSpacing(context),
        childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
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
