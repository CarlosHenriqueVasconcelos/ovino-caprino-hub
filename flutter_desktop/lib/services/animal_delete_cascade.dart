import '../data/animal_cascade_repository.dart';

class AnimalDeleteCascade {
  final AnimalCascadeRepository _repository;

  AnimalDeleteCascade(this._repository);

  /// Exclui o animal [animalId] e todos os registros relacionados.
  ///
  /// IMPORTANTE:
  /// - Essa operação é destrutiva e não pode ser desfeita.
  /// - Envolve múltiplas tabelas dentro de uma transação.
  Future<void> delete(String animalId) async {
    await _repository.deleteCascade(animalId);
  }
}
