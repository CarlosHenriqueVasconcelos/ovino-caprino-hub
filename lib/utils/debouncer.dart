import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;
  Timer? _timer;

  void run(VoidCallback action, {Duration? delay}) {
    _timer?.cancel();
    _timer = Timer(delay ?? this.delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
