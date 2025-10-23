// lib/services/data_refresh_bus.dart
// Barramento simples para notificar a UI quando dados no banco mudarem
import 'dart:async';

class DataRefreshBus {
  static final StreamController<String> _controller =
      StreamController<String>.broadcast();

  static Stream<String> get stream => _controller.stream;

  static void emit(String event) {
    // Eventos sugeridos: 'sold', 'deceased', 'animals_changed'
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }
}
