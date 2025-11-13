import '../data/deceased_repository.dart';
import '../models/animal.dart';

class DeceasedService {
  final DeceasedRepository _repository;
  DeceasedService(this._repository);

  Future<List<Animal>> getDeceasedAnimals() {
    return _repository.fetchAll();
  }
}
