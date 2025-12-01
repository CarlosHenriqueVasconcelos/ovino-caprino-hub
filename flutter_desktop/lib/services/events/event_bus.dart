// lib/services/events/event_bus.dart
// Sistema reativo de eventos tipados

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'app_events.dart';

/// EventBus global singleton para comunicação reativa entre componentes
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();

  /// Stream principal de todos os eventos
  Stream<AppEvent> get stream => _controller.stream;

  /// Emite um evento para todos os listeners
  void emit(AppEvent event) {
    if (!_controller.isClosed) {
      debugPrint('🔔 Event emitted: ${event.runtimeType}');
      _controller.add(event);
    }
  }

  /// Stream filtrado por tipo de evento específico
  /// Exemplo: EventBus().on<AnimalCreatedEvent>().listen(...)
  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// Listener conveniente para um tipo específico
  StreamSubscription<T> listen<T extends AppEvent>(
    void Function(T event) onEvent,
  ) {
    return on<T>().listen(onEvent);
  }

  /// Dispose do EventBus (normalmente não usado, mas disponível se necessário)
  void dispose() {
    _controller.close();
  }
}

/// Extensão para facilitar uso em StatefulWidgets
extension EventBusWidget on State {
  /// Helper para criar subscription que se auto-cancela no dispose
  StreamSubscription<T> listenToEvent<T extends AppEvent>(
    void Function(T event) onEvent,
  ) {
    return EventBus().listen<T>(onEvent);
  }

  /// Helper para emitir eventos facilmente
  void emitEvent(AppEvent event) {
    EventBus().emit(event);
  }
}

/// Mixin para facilitar gerenciamento de múltiplas subscriptions
mixin EventBusSubscriptions<T extends StatefulWidget> on State<T> {
  final List<StreamSubscription> _subscriptions = [];

  /// Adiciona uma subscription que será automaticamente cancelada no dispose
  void addEventSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Escuta um evento específico
  void onEvent<E extends AppEvent>(void Function(E event) handler) {
    addEventSubscription(EventBus().listen<E>(handler));
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
