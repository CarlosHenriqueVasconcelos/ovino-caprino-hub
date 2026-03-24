import '../../data/animal_repository.dart';
import '../../models/animal.dart';

class AnimalStatsCalculator {
  final AnimalRepository _repository;

  AnimalStatsCalculator(this._repository);

  Future<AnimalStats> calculate() {
    return _repository.stats();
  }
}
