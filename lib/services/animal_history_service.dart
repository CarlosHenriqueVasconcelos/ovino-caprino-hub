import '../data/animal_history_repository.dart';
import '../models/animal.dart';

class AnimalHistoryService {
  final AnimalHistoryRepository _repository;

  AnimalHistoryService(this._repository);

  Future<AnimalHistoryData> loadHistory(Animal animal) {
    return _repository.loadHistory(animal);
  }
}
