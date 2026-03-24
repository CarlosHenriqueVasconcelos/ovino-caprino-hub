import '../data/deceased_repository.dart';
import '../data/animal_lifecycle_repository.dart';
import '../models/animal.dart';
import 'events/event_bus.dart';
import 'events/app_events.dart';

class DeceasedService {
  final DeceasedRepository _repository;
  final AnimalLifecycleRepository _lifecycleRepository;

  DeceasedService(this._repository, this._lifecycleRepository);

  Future<List<Animal>> getDeceasedAnimals() {
    return _repository.fetchAll();
  }

  /// Marca um animal como falecido, movendo-o para a tabela de óbitos
  Future<void> markAsDeceased({
    required String animalId,
    required DateTime deathDate,
    String? causeOfDeath,
    String? notes,
  }) async {
    await _lifecycleRepository.moveToDeceased(
      animalId,
      deathDate: deathDate,
      causeOfDeath: causeOfDeath,
      notes: notes,
    );
    
    EventBus().emit(AnimalMarkedAsDeceasedEvent(
      animalId: animalId,
      deathDate: deathDate,
      causeOfDeath: causeOfDeath,
    ));
  }
}
