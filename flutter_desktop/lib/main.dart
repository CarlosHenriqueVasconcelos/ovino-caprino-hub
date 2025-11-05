// flutter_desktop/lib/main.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/complete_dashboard_screen.dart';
import 'theme/app_theme.dart';
import 'services/animal_service.dart';
import 'services/pharmacy_service.dart';
import 'services/feeding_service.dart';
import 'services/weight_service.dart';
import 'services/weight_alert_service.dart';
import 'services/medication_service.dart';
import 'services/vaccination_service.dart';
import 'data/local_db.dart';
import 'data/animal_repository.dart';
import 'data/pharmacy_repository.dart';
import 'data/breeding_repository.dart';
import 'data/finance_repository.dart';
import 'data/feeding_repository.dart';
import 'data/vaccination_repository.dart';
import 'data/medication_repository.dart';
import 'data/note_repository.dart';
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

    // Abrir banco local e criar repositórios
    final appDb = await AppDatabase.open();
    
    // Criar todos os repositórios
    final animalRepository = AnimalRepository(appDb);
    final pharmacyRepository = PharmacyRepository(appDb);
    final breedingRepository = BreedingRepository(appDb);
    final financeRepository = FinanceRepository(appDb);
    final feedingRepository = FeedingRepository(appDb);
    final vaccinationRepository = VaccinationRepository(appDb);
    final medicationRepository = MedicationRepository(appDb);
    final noteRepository = NoteRepository(appDb);
    
    final backupService = BackupService(
      db: appDb,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );

    runApp(FazendaSaoPetronioApp(
      db: appDb,
      animalRepository: animalRepository,
      pharmacyRepository: pharmacyRepository,
      breedingRepository: breedingRepository,
      financeRepository: financeRepository,
      feedingRepository: feedingRepository,
      vaccinationRepository: vaccinationRepository,
      medicationRepository: medicationRepository,
      noteRepository: noteRepository,
      backup: backupService,
    ));
  }, (error, stack) {
    debugPrint('=== Uncaught error ===');
    debugPrint('$error');
    debugPrintStack(stackTrace: stack);
  });
}

class FazendaSaoPetronioApp extends StatelessWidget {
  final AppDatabase db;
  final AnimalRepository animalRepository;
  final PharmacyRepository pharmacyRepository;
  final BreedingRepository breedingRepository;
  final FinanceRepository financeRepository;
  final FeedingRepository feedingRepository;
  final VaccinationRepository vaccinationRepository;
  final MedicationRepository medicationRepository;
  final NoteRepository noteRepository;
  final BackupService backup;
  
  const FazendaSaoPetronioApp({
    super.key,
    required this.db,
    required this.animalRepository,
    required this.pharmacyRepository,
    required this.breedingRepository,
    required this.financeRepository,
    required this.feedingRepository,
    required this.vaccinationRepository,
    required this.medicationRepository,
    required this.noteRepository,
    required this.backup,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Database e Backup
        Provider<AppDatabase>.value(value: db),
        Provider<BackupService>.value(value: backup),
        
        // Repositórios
        Provider<AnimalRepository>.value(value: animalRepository),
        Provider<PharmacyRepository>.value(value: pharmacyRepository),
        Provider<BreedingRepository>.value(value: breedingRepository),
        Provider<FinanceRepository>.value(value: financeRepository),
        Provider<FeedingRepository>.value(value: feedingRepository),
        Provider<VaccinationRepository>.value(value: vaccinationRepository),
        Provider<MedicationRepository>.value(value: medicationRepository),
        Provider<NoteRepository>.value(value: noteRepository),
        
        // Services (com injeção de dependência)
        ChangeNotifierProvider(create: (_) => AnimalService()),
        ChangeNotifierProvider(
          create: (context) => PharmacyService(
            context.read<PharmacyRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FeedingService(
            context.read<FeedingRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WeightService(
            context.read<AnimalRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WeightAlertService(
            context.read<AppDatabase>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MedicationService(
            context.read<MedicationRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => VaccinationService(
            context.read<VaccinationRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Fazenda São Petrônio - Sistema de Gestão Pecuária',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        locale: const Locale('pt', 'BR'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const CompleteDashboardScreen(),
      ),
    );
  }
}
