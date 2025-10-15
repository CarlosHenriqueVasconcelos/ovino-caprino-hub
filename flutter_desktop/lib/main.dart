// flutter_desktop/lib/main.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/complete_dashboard_screen.dart';
import 'theme/app_theme.dart';
import 'services/animal_service.dart';
import 'data/local_db.dart';
import 'services/backup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR', null);

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

  

  // ============ Inicialização sob runZonedGuarded ============
  await runZonedGuarded<Future<void>>(() async {
    // SQFLite FFI desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Supabase (somente para backup manual)
    const supabaseUrl = 'https://heueripmlmuvqdbwyxxs.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhldWVyaXBtbG11dnFkYnd5eHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MjU2NzEsImV4cCI6MjA3MzAwMTY3MX0.KWvjNAVqnjqFgjfOz95QU4gOEMxIBHD2yxaRMlgnxEw';
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    // Abrir banco local e injetar serviços
    final appDb = await AppDatabase.open();
    final backupService = BackupService(
      db: appDb,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );

    runApp(FazendaSaoPetronioApp(db: appDb, backup: backupService));
  }, (error, stack) {
    debugPrint('=== Uncaught error ===');
    debugPrint('$error');
    debugPrintStack(stackTrace: stack);
  });
}

class FazendaSaoPetronioApp extends StatelessWidget {
  final AppDatabase db;
  final BackupService backup;
  const FazendaSaoPetronioApp({super.key, required this.db, required this.backup});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<BackupService>.value(value: backup),
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
