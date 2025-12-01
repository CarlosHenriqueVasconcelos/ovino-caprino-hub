// lib/widgets/reactive_animal_card.dart
// Exemplo de widget reativo que escuta eventos específicos

import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../data/animal_repository.dart';
import '../services/events/event_bus.dart';
import '../services/events/app_events.dart';

/// Card de animal que se atualiza automaticamente quando eventos relevantes ocorrem
class ReactiveAnimalCard extends StatefulWidget {
  final String animalId;
  final AnimalRepository repository;
  final VoidCallback? onTap;

  const ReactiveAnimalCard({
    super.key,
    required this.animalId,
    required this.repository,
    this.onTap,
  });

  @override
  State<ReactiveAnimalCard> createState() => _ReactiveAnimalCardState();
}

class _ReactiveAnimalCardState extends State<ReactiveAnimalCard>
    with EventBusSubscriptions {
  Animal? _animal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimal();
    _setupEventListeners();
  }

  void _setupEventListeners() {
    // Escuta quando o animal é atualizado
    onEvent<AnimalUpdatedEvent>((event) {
      if (event.animalId == widget.animalId) {
        debugPrint('🔄 Animal ${widget.animalId} atualizado, recarregando...');
        _loadAnimal();
      }
    });

    // Escuta quando um peso é adicionado
    onEvent<WeightAddedEvent>((event) {
      if (event.animalId == widget.animalId) {
        debugPrint('⚖️ Peso adicionado ao animal ${widget.animalId}, recarregando...');
        _loadAnimal();
      }
    });

    // Escuta quando gestação é atualizada
    onEvent<AnimalPregnancyUpdatedEvent>((event) {
      if (event.animalId == widget.animalId) {
        debugPrint('🤰 Gestação atualizada para animal ${widget.animalId}, recarregando...');
        _loadAnimal();
      }
    });

    // Escuta quando animal é deletado
    onEvent<AnimalDeletedEvent>((event) {
      if (event.animalId == widget.animalId && mounted) {
        // Card deve desaparecer ou mostrar estado "deletado"
        debugPrint('❌ Animal ${widget.animalId} deletado');
        setState(() {
          _animal = null;
        });
      }
    });

    // Escuta quando animal é vendido
    onEvent<AnimalMarkedAsSoldEvent>((event) {
      if (event.animalId == widget.animalId && mounted) {
        debugPrint('💰 Animal ${widget.animalId} vendido');
        _loadAnimal(); // Recarrega para mostrar novo status
      }
    });
  }

  Future<void> _loadAnimal() async {
    if (!mounted) return;
    
    setState(() => _loading = true);
    
    try {
      final animal = await widget.repository.getAnimalById(widget.animalId);
      if (mounted) {
        setState(() {
          _animal = animal;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar animal: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_animal == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text('Animal não encontrado'),
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _animal!.speciesIcon,
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _animal!.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${_animal!.code} • ${_animal!.nameColor}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(_animal!.category),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Chip(
                    label: Text('${_animal!.weight.toStringAsFixed(1)} kg'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  if (_animal!.pregnant == true)
                    Chip(
                      label: Text('🤰 Gestante'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
