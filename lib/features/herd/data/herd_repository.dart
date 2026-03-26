import '../../../data/animal_repository.dart';
import '../../../models/animal.dart';
import '../../../services/animal_service.dart';
import '../../../services/deceased_service.dart';
import '../../../services/sold_animals_service.dart';
import '../../../utils/animal_display_utils.dart';

class HerdRepository {
  HerdRepository({
    required AnimalRepository animalRepository,
    required AnimalService animalService,
    required SoldAnimalsService soldAnimalsService,
    required DeceasedService deceasedService,
  })  : _animalRepository = animalRepository,
        _animalService = animalService,
        _soldAnimalsService = soldAnimalsService,
        _deceasedService = deceasedService;

  final AnimalRepository _animalRepository;
  final AnimalService _animalService;
  final SoldAnimalsService _soldAnimalsService;
  final DeceasedService _deceasedService;

  Future<List<Animal>> getFilteredAnimals({
    bool includeSold = true,
    String? statusEquals,
    String? nameColor,
    String? categoryEquals,
    String? searchQuery,
    int? limit,
    int? offset,
  }) {
    return _animalRepository.getFilteredAnimals(
      includeSold: includeSold,
      statusEquals: statusEquals,
      nameColor: nameColor,
      categoryEquals: categoryEquals,
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<String>> getAvailableColors() {
    return _animalService.getAvailableColors();
  }

  Future<List<String>> getAvailableCategories() {
    return _animalService.getAvailableCategories();
  }

  Future<List<Animal>> getSoldAnimals() async {
    final sorted = await _soldAnimalsService.getSoldAnimals();
    AnimalDisplayUtils.sortAnimalsList(sorted);
    return sorted;
  }

  Future<List<Animal>> getDeceasedAnimals() {
    return _deceasedService.getDeceasedAnimals();
  }
}
