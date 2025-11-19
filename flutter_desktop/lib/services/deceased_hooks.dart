// lib/services/deceased_hooks.dart
// Atualiza automaticamente o animal para "Óbito" e move para deceased_animals
// quando o status do animal for alterado para "Óbito"
// + service para listar animais falecidos para o Dashboard

import '../data/animal_lifecycle_repository.dart';
import 'data_refresh_bus.dart';

// -----------------------------------------------------------------------------
// Hook: chamado pelo AnimalService quando o status muda para "Óbito"
// -----------------------------------------------------------------------------
Future<void> handleAnimalDeathIfApplicable(
  AnimalLifecycleRepository repository,
  String animalId,
  String newStatus,
) async {
  if (newStatus != 'Óbito') return;
  await repository.moveToDeceased(animalId);
  DataRefreshBus.emit('deceased');
}
