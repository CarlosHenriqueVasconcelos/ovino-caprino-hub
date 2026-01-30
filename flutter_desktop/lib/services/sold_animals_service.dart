import '../data/sold_animals_repository.dart';
import '../models/animal.dart';

class SoldAnimalsService {
  final SoldAnimalsRepository _repository;
  SoldAnimalsService(this._repository);

  Future<List<Animal>> getSoldAnimals() async {
    return _repository.fetchAll();
  }
}
