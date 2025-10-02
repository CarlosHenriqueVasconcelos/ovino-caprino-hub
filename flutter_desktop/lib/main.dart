import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

import 'screens/complete_dashboard_screen.dart';
import 'theme/app_theme.dart';

// serviços/camada de dados (novos)
import 'data/local_db.dart';
import 'services/backup_service.dart';
import 'services/animal_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite FFI para desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // abre/cria o banco local (arquivo bego.db)
  final db = await AppDatabase.open();

  // Supabase (permite backup sob demanda)
  const supabaseUrl = 'https://heueripmlmuvqdbwyxxs.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhldWVyaXBtbG11dnFkYnd5eHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MjU2NzEsImV4cCI6MjA3MzAwMTY3MX0.KWvjNAVqnjqFgjfOz95QU4gOEMxIBHD2yxaRMlgnxEw';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Providers "de infraestrutura" (DB e Backup) no topo da árvore
  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<BackupService>(
          create: (_) => BackupService(
            db: db,
            supabaseUrl: supabaseUrl,
            supabaseAnonKey: supabaseAnonKey,
          ),
        ),
      ],
      child: const FazendaSaoPetronioApp(),
    ),
  );
}

class FazendaSaoPetronioApp extends StatelessWidget {
  const FazendaSaoPetronioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Aqui criamos o AnimalService com o DB que veio do Provider acima
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AnimalService(db: ctx.read<AppDatabase>()),
        ),
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
