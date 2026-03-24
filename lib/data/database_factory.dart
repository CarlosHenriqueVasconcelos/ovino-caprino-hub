import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide databaseFactory;

/// Retorna a factory de banco de dados adequada para a plataforma atual
/// - Mobile (Android/iOS): sqflite nativo
/// - Desktop (Windows/Linux/macOS): sqflite_common_ffi
Future<DatabaseFactory> getDatabaseFactory() async {
  if (kIsWeb) {
    throw UnsupportedError(
      'Web não é suportado nesta aplicação. '
      'Por favor, use a versão desktop ou mobile.',
    );
  }

  // Mobile: Android ou iOS
  if (Platform.isAndroid || Platform.isIOS) {
    // Usa sqflite nativo (já incluído no Flutter)
    return databaseFactory;
  }

  // Desktop: Windows, Linux ou macOS
  // Inicializa sqflite_common_ffi
  sqfliteFfiInit();
  return databaseFactoryFfi;
}
