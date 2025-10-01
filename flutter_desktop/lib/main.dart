import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'screens/complete_dashboard_screen.dart';
import 'theme/app_theme.dart';
import 'services/animal_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar sqflite_ffi para Windows/Linux/macOS
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  await Supabase.initialize(
    url: 'https://heueripmlmuvqdbwyxxs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhldWVyaXBtbG11dnFkYnd5eHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MjU2NzEsImV4cCI6MjA3MzAwMTY3MX0.KWvjNAVqnjqFgjfOz95QU4gOEMxIBHD2yxaRMlgnxEw',
  );
  
  runApp(const FazendaSaoPetronioApp());
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