# EventBus - Guia de Sistema Reativo

## Visão Geral

O EventBus é um sistema reativo de eventos tipados que permite sincronização automática de dados entre widgets sem necessidade de restart da aplicação. Implementado na FASE 3 da otimização de performance.

## Arquitetura

```
Service (CRUD) 
    ↓ emite evento
EventBus (singleton)
    ↓ propaga
Widgets (listeners)
    ↓ reagem
UI atualiza automaticamente
```

## Como Usar

### 1. Emitindo Eventos nos Services

```dart
import '../services/events/event_bus.dart';
import '../services/events/app_events.dart';

// Após criar um animal
await _repository.upsert(animal);
EventBus().emit(AnimalCreatedEvent(
  animalId: animal.id,
  name: animal.name,
  category: animal.category,
));

// Após atualizar
await _repository.upsert(updated);
EventBus().emit(AnimalUpdatedEvent(
  animalId: updated.id,
  changes: updated.toMap(),
));

// Após deletar
await _repository.delete(id);
EventBus().emit(AnimalDeletedEvent(animalId: id));
```

### 2. Escutando Eventos em Widgets

#### Opção A: Usando Mixin (Recomendado)

```dart
class MyWidgetState extends State<MyWidget> 
    with EventBusSubscriptions {
  
  @override
  void initState() {
    super.initState();
    
    // Escuta eventos específicos
    onEvent<AnimalCreatedEvent>((event) {
      print('Animal criado: ${event.name}');
      _refresh(); // Recarrega dados
    });
    
    onEvent<AnimalUpdatedEvent>((event) {
      if (event.animalId == _currentAnimalId) {
        _reloadAnimal(); // Recarrega apenas este animal
      }
    });
    
    onEvent<WeightAddedEvent>((event) {
      _refreshWeightChart(); // Atualiza gráfico
    });
  }
  
  // dispose() automático - subscriptions canceladas
}
```

#### Opção B: Manual (mais controle)

```dart
class MyWidgetState extends State<MyWidget> {
  StreamSubscription? _animalSub;
  StreamSubscription? _weightSub;
  
  @override
  void initState() {
    super.initState();
    
    _animalSub = EventBus().listen<AnimalUpdatedEvent>((event) {
      // Handler
    });
    
    _weightSub = EventBus().listen<WeightAddedEvent>((event) {
      // Handler
    });
  }
  
  @override
  void dispose() {
    _animalSub?.cancel();
    _weightSub?.cancel();
    super.dispose();
  }
}
```

#### Opção C: Extension Helper

```dart
class MyWidgetState extends State<MyWidget> {
  StreamSubscription? _sub;
  
  @override
  void initState() {
    super.initState();
    
    _sub = listenToEvent<AnimalCreatedEvent>((event) {
      // Handler
    });
  }
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
```

### 3. Eventos Disponíveis

#### Animais
- `AnimalCreatedEvent` - Quando animal é criado
- `AnimalUpdatedEvent` - Quando animal é atualizado
- `AnimalDeletedEvent` - Quando animal é deletado
- `AnimalMarkedAsSoldEvent` - Quando animal é vendido
- `AnimalMarkedAsDeceasedEvent` - Quando animal morre
- `AnimalPregnancyUpdatedEvent` - Quando status de gestação muda

#### Pesos
- `WeightAddedEvent` - Quando peso é adicionado
- `WeightAlertCompletedEvent` - Quando alerta de peso é completado

#### Reprodução
- `BreedingRecordCreatedEvent` - Quando registro de reprodução é criado
- `BreedingRecordUpdatedEvent` - Quando registro é atualizado
- `BreedingRecordDeletedEvent` - Quando registro é deletado

#### Vacinação
- `VaccinationCreatedEvent` - Quando vacinação é criada
- `VaccinationUpdatedEvent` - Quando vacinação é atualizada
- `VaccinationDeletedEvent` - Quando vacinação é deletada

#### Medicação
- `MedicationCreatedEvent` - Quando medicação é criada
- `MedicationUpdatedEvent` - Quando medicação é atualizada
- `MedicationDeletedEvent` - Quando medicação é deletada

#### Farmácia
- `PharmacyStockCreatedEvent` - Quando item é adicionado ao estoque
- `PharmacyStockUpdatedEvent` - Quando estoque é atualizado
- `PharmacyStockDeletedEvent` - Quando item é removido
- `PharmacyStockMovementEvent` - Quando há movimentação de estoque

#### Alimentação
- `FeedingPenCreatedEvent` - Quando baia é criada
- `FeedingPenUpdatedEvent` - Quando baia é atualizada
- `FeedingPenDeletedEvent` - Quando baia é deletada
- `FeedingScheduleCreatedEvent` - Quando trato é criado
- `FeedingScheduleUpdatedEvent` - Quando trato é atualizado
- `FeedingScheduleDeletedEvent` - Quando trato é deletado

#### Financeiro
- `FinancialAccountCreatedEvent` - Quando conta é criada
- `FinancialAccountUpdatedEvent` - Quando conta é atualizada
- `FinancialAccountDeletedEvent` - Quando conta é deletada

#### Notas
- `NoteCreatedEvent` - Quando nota é criada
- `NoteUpdatedEvent` - Quando nota é atualizada
- `NoteDeletedEvent` - Quando nota é deletada

#### Sistema
- `DataImportedEvent` - Quando dados são importados
- `DataExportedEvent` - Quando dados são exportados
- `DatabaseRestoredEvent` - Quando banco é restaurado
- `StatsRefreshRequestedEvent` - Quando estatísticas precisam ser recalculadas
- `AlertsRefreshRequestedEvent` - Quando alertas precisam ser recalculados

## Padrões de Uso

### Pattern 1: Atualização Granular (um item específico)

```dart
onEvent<AnimalUpdatedEvent>((event) {
  if (event.animalId == widget.currentAnimalId) {
    // Recarrega apenas este animal específico
    _reloadCurrentAnimal();
  }
});
```

### Pattern 2: Atualização de Lista (reload parcial)

```dart
onEvent<AnimalCreatedEvent>((event) {
  // Adiciona à lista local sem recarregar tudo
  final newAnimal = await _repository.getAnimalById(event.animalId);
  setState(() {
    _animals.insert(0, newAnimal);
  });
});

onEvent<AnimalDeletedEvent>((event) {
  // Remove da lista local
  setState(() {
    _animals.removeWhere((a) => a.id == event.animalId);
  });
});
```

### Pattern 3: Invalidação de Cache

```dart
onEvent<AnimalUpdatedEvent>((event) {
  // Invalida cache e força reload na próxima vez
  _cachedData.remove(event.animalId);
});
```

### Pattern 4: Refresh Completo (quando necessário)

```dart
onEvent<DatabaseRestoredEvent>((event) {
  // Reload completo necessário
  _loadAllData();
});
```

## Benefícios

1. **Sincronização Automática**: Widgets se atualizam quando dados mudam
2. **Desacoplamento**: Services não precisam conhecer widgets
3. **Performance**: Atualizações granulares evitam reloads desnecessários
4. **Debugging**: Logs automáticos de eventos facilitam troubleshooting
5. **Type Safety**: Eventos tipados previnem erros

## Migração do DataRefreshBus

O antigo `DataRefreshBus` ainda funciona mas está deprecated:

```dart
// ❌ Antigo (deprecated)
DataRefreshBus.emit('animals_changed');
DataRefreshBus.stream.listen((event) {
  if (event == 'animals_changed') _refresh();
});

// ✅ Novo (recomendado)
EventBus().emit(AnimalCreatedEvent(...));
EventBus().listen<AnimalCreatedEvent>((event) {
  _refresh();
});
```

## Exemplo Completo: Widget Reativo

```dart
import 'package:flutter/material.dart';
import '../services/events/event_bus.dart';
import '../services/events/app_events.dart';

class AnimalListWidget extends StatefulWidget {
  const AnimalListWidget({super.key});

  @override
  State<AnimalListWidget> createState() => _AnimalListWidgetState();
}

class _AnimalListWidgetState extends State<AnimalListWidget>
    with EventBusSubscriptions {
  List<Animal> _animals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
    _setupEventListeners();
  }

  void _setupEventListeners() {
    // Animal criado: adiciona à lista
    onEvent<AnimalCreatedEvent>((event) async {
      final newAnimal = await repository.getAnimalById(event.animalId);
      if (newAnimal != null && mounted) {
        setState(() {
          _animals.insert(0, newAnimal);
        });
      }
    });

    // Animal atualizado: atualiza na lista
    onEvent<AnimalUpdatedEvent>((event) async {
      final updated = await repository.getAnimalById(event.animalId);
      if (updated != null && mounted) {
        setState(() {
          final index = _animals.indexWhere((a) => a.id == event.animalId);
          if (index >= 0) {
            _animals[index] = updated;
          }
        });
      }
    });

    // Animal deletado: remove da lista
    onEvent<AnimalDeletedEvent>((event) {
      setState(() {
        _animals.removeWhere((a) => a.id == event.animalId);
      });
    });

    // Peso adicionado: atualiza animal afetado
    onEvent<WeightAddedEvent>((event) async {
      final updated = await repository.getAnimalById(event.animalId);
      if (updated != null && mounted) {
        setState(() {
          final index = _animals.indexWhere((a) => a.id == event.animalId);
          if (index >= 0) {
            _animals[index] = updated;
          }
        });
      }
    });
  }

  Future<void> _loadAnimals() async {
    setState(() => _loading = true);
    try {
      final animals = await repository.all(limit: 50);
      if (mounted) {
        setState(() {
          _animals = animals;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return CircularProgressIndicator();
    
    return ListView.builder(
      itemCount: _animals.length,
      itemBuilder: (context, index) {
        return AnimalCard(animal: _animals[index]);
      },
    );
  }
}
```

## Debugging

Todos os eventos emitidos geram logs automáticos:

```
🔔 Event emitted: AnimalCreatedEvent
🔔 Event emitted: WeightAddedEvent
🔔 Event emitted: AnimalUpdatedEvent
```

Para debug mais detalhado, adicione prints nos handlers:

```dart
onEvent<AnimalUpdatedEvent>((event) {
  print('📝 Animal ${event.animalId} atualizado: ${event.changes.keys}');
  _handleUpdate(event);
});
```

## Performance Tips

1. **Seja específico**: Escute apenas eventos relevantes para seu widget
2. **Atualizações granulares**: Prefira atualizar item específico ao invés de recarregar lista inteira
3. **Debounce quando necessário**: Use Timers para evitar múltiplas atualizações rápidas
4. **Dispose correto**: Sempre cancele subscriptions no dispose (automático com mixin)
5. **Check mounted**: Sempre verifique `mounted` antes de `setState`

## Próximos Passos

- FASE 4: Adicionar índices compostos ao banco de dados
- FASE 5: Implementar lazy loading verdadeiro nos widgets
- Considerar adicionar cache inteligente com invalidação via eventos
