// flutter_desktop/lib/main.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;           // <— para logs
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/complete_dashboard_screen.dart';
import 'theme/app_theme.dart';
import 'services/animal_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============ Ganchos globais de erro ============
  FlutterError.onError = (FlutterErrorDetails details) {
    // Mostra o erro vermelho e também manda pro Zone
    FlutterError.presentError(details);
    if (details.stack != null) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    } else {
      Zone.current.handleUncaughtError(details.exception, StackTrace.current);
    }
  };

  // Log detalhado do sqflite (SQL/erros)
  sqflite.Sqflite.devSetDebugModeOn(true);

  // ============ Inicialização sob runZonedGuarded ============
  await runZonedGuarded<Future<void>>(() async {
    // SQFLite FFI desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Supabase (somente para backup manual)
    await Supabase.initialize(
      url: 'https://heueripmlmuvqdbwyxxs.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhldWVyaXBtbG11dnFkYnd5eHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MjU2NzEsImV4cCI6MjA3MzAwMTY3MX0.KWvjNAVqnjqFgjfOz95QU4gOEMxIBHD2yxaRMlgnxEw',
    );

    runApp(const FazendaSaoPetronioApp());
  }, (error, stack) {
    debugPrint('=== Uncaught error ===');
    debugPrint('$error');
    debugPrintStack(stackTrace: stack);
  });
}

class FazendaSaoPetronioApp extends StatelessWidget {
  const FazendaSaoPetronioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnimalService()),
      ],
      child: MaterialApp(
        title: 'Fazenda São Petrônio - Sistema de Gestão Pecuária',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const CompleteDashboardScreen(),
      ),
    );
  }
}
