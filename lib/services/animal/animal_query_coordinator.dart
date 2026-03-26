import '../../data/animal_repository.dart';
import '../../models/animal.dart';
import '../../utils/animal_display_utils.dart';

class AnimalQueryCoordinator {
  AnimalQueryCoordinator(this._animalRepository);

  final AnimalRepository _animalRepository;

  Future<({List<Animal> items, int total})> weightTrackingQueryData({
    required String categoryKey,
    String? colorFilter,
    String searchQuery = '',
    int page = 0,
    int pageSize = 50,
  }) async {
    int? ageMinMonths;
    int? ageMaxMonths;
    bool? excludeReproducers;

    switch (categoryKey) {
      case 'juveniles':
        ageMaxMonths = 12;
        break;
      case 'nonLambs':
        break;
      case 'reproducers':
        final total = await _animalRepository.countFilteredAnimals(
          nameColor: colorFilter,
          searchQuery: searchQuery.trim(),
          onlyReproducers: true,
          excludeLambs: true,
        );
        final filtered = await _animalRepository.getFilteredAnimals(
          nameColor: colorFilter,
          searchQuery: searchQuery.trim(),
          onlyReproducers: true,
          excludeLambs: true,
          limit: pageSize,
          offset: page * pageSize,
        );
        AnimalDisplayUtils.sortAnimalsList(filtered);
        return (items: filtered, total: total);
      case 'all':
      default:
        break;
    }

    final total = await _animalRepository.countFilteredAnimals(
      ageMinMonths: ageMinMonths,
      ageMaxMonths: ageMaxMonths,
      excludeReproducers: excludeReproducers,
      excludeLambs: true,
      nameColor: colorFilter,
      searchQuery: searchQuery.trim(),
    );

    final items = await _animalRepository.getFilteredAnimals(
      ageMinMonths: ageMinMonths,
      ageMaxMonths: ageMaxMonths,
      excludeReproducers: excludeReproducers,
      excludeLambs: true,
      nameColor: colorFilter,
      searchQuery: searchQuery.trim(),
      limit: pageSize,
      offset: page * pageSize,
    );

    AnimalDisplayUtils.sortAnimalsList(items);
    return (items: items, total: total);
  }

  Future<List<String>> getAvailableColors() {
    return _animalRepository.getDistinctColors();
  }

  Future<List<String>> getAvailableCategories() {
    return _animalRepository.getDistinctCategories();
  }

  Future<({List<Animal> items, int total})> herdQueryData({
    bool includeSold = true,
    String? statusEquals,
    String? colorFilter,
    String? categoryFilter,
    String searchQuery = '',
    int page = 0,
    int pageSize = 50,
  }) async {
    final total = await _animalRepository.countFilteredAnimals(
      includeSold: includeSold,
      statusEquals: statusEquals,
      nameColor: colorFilter,
      categoryEquals: categoryFilter,
      searchQuery: searchQuery.trim(),
      onlyReproducers: false,
      excludeReproducers: false,
    );

    final items = await _animalRepository.getFilteredAnimals(
      includeSold: includeSold,
      statusEquals: statusEquals,
      nameColor: colorFilter,
      categoryEquals: categoryFilter,
      searchQuery: searchQuery.trim(),
      limit: pageSize,
      offset: page * pageSize,
    );

    AnimalDisplayUtils.sortAnimalsList(items);
    return (items: items, total: total);
  }

  Future<List<Animal>> searchAnimals({
    String? gender,
    bool excludePregnant = false,
    List<String> excludeCategories = const [],
    String? searchQuery,
    bool includeArchived = false,
    int limit = 50,
    int offset = 0,
  }) {
    return _animalRepository.searchAnimals(
      gender: gender,
      excludePregnant: excludePregnant,
      excludeCategories: excludeCategories,
      searchQuery: searchQuery,
      includeArchived: includeArchived,
      limit: limit,
      offset: offset,
    );
  }
}
