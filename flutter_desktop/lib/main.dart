// flutter_desktop/lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/complete_dashboard_screen.dart';
import 'theme/app_theme.dart';

// Services
import 'services/animal_service.dart';
import 'services/pharmacy_service.dart';
import 'services/feeding_service.dart';
import 'services/weight_service.dart';
import 'services/weight_alert_service.dart';
import 'services/medication_service.dart';
import 'services/vaccination_service.dart';
import 'services/backup_service.dart';
import 'services/note_service.dart';
import 'services/animal_history_service.dart';
import 'services/system_maintenance_service.dart';
import 'services/breeding_service.dart'; // Reprodução
import 'services/financial_service.dart'; // Financeiro
import 'services/animal_delete_cascade.dart';
import 'services/deceased_service.dart';
import 'services/sold_animals_service.dart'; // ✅ novo service de vendidos
import 'services/reports_controller.dart';

// Data / DB
import 'data/local_db.dart';
import 'data/animal_cascade_repository.dart';
import 'data/animal_history_repository.dart';
import 'data/animal_lifecycle_repository.dart';
import 'data/animal_repository.dart';
import 'data/pharmacy_repository.dart';
import 'data/breeding_repository.dart';
import 'data/finance_repository.dart';
import 'data/feeding_repository.dart';
import 'data/vaccination_repository.dart';
import 'data/medication_repository.dart';
import 'data/note_repository.dart';
import 'data/deceased_repository.dart';
import 'data/sold_animals_repository.dart';
import 'data/weight_alert_repository.dart';
import 'data/maintenance_repository.dart';
import 'data/backup_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR', null);

  // ============ Ganchos globais de erro ============
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (details.stack != null) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    } else {
      Zone.current.handleUncaughtError(details.exception, StackTrace.current);
    }
  };

  // ============ Inicialização sob runZonedGuarded ============
  await runZonedGuarded<Future<void>>(() async {
    // Supabase (somente para backup manual)
    const supabaseUrl = 'https://heueripmlmuvqdbwyxxs.supabase.co';
    const supabaseAnonKey =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhldWVyaXBtbG11dnFkYnd5eHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MjU2NzEsImV4cCI6MjA3MzAwMTY3MX0.KWvjNAVqnjqFgjfOz95QU4gOEMxIBHD2yxaRMlgnxEw';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    // Abrir banco local (AppDatabase decide a factory correta: desktop/mobile)
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
    final animalHistoryRepository = AnimalHistoryRepository(appDb);
    final deceasedRepository = DeceasedRepository(appDb);
    final soldAnimalsRepository = SoldAnimalsRepository(appDb);
    final weightAlertRepository = WeightAlertRepository(appDb);
    final animalCascadeRepository = AnimalCascadeRepository(appDb);
    final animalLifecycleRepository = AnimalLifecycleRepository(appDb);
    final maintenanceRepository = MaintenanceRepository(appDb);

    // Backup (Supabase como espelho/backup)
    final backupRepository = BackupRepository(
      database: appDb,
      client: Supabase.instance.client,
    );
    final backupService = BackupService(
      repository: backupRepository,
    );

    runApp(
      FazendaSaoPetronioApp(
        db: appDb,
        animalRepository: animalRepository,
        animalCascadeRepository: animalCascadeRepository,
        animalLifecycleRepository: animalLifecycleRepository,
        maintenanceRepository: maintenanceRepository,
        pharmacyRepository: pharmacyRepository,
        breedingRepository: breedingRepository,
        financeRepository: financeRepository,
        feedingRepository: feedingRepository,
        vaccinationRepository: vaccinationRepository,
        medicationRepository: medicationRepository,
        noteRepository: noteRepository,
        animalHistoryRepository: animalHistoryRepository,
        deceasedRepository: deceasedRepository,
        soldAnimalsRepository: soldAnimalsRepository,
        weightAlertRepository: weightAlertRepository,
        backup: backupService,
      ),
    );
  }, (error, stack) {
    debugPrint('=== Uncaught error ===');
    debugPrint('$error');
    debugPrintStack(stackTrace: stack);
  });
}

class FazendaSaoPetronioApp extends StatelessWidget {
  final AppDatabase db;
  final AnimalRepository animalRepository;
  final AnimalCascadeRepository animalCascadeRepository;
  final AnimalLifecycleRepository animalLifecycleRepository;
  final MaintenanceRepository maintenanceRepository;
  final PharmacyRepository pharmacyRepository;
  final BreedingRepository breedingRepository;
  final FinanceRepository financeRepository;
  final FeedingRepository feedingRepository;
  final VaccinationRepository vaccinationRepository;
  final MedicationRepository medicationRepository;
  final NoteRepository noteRepository;
  final AnimalHistoryRepository animalHistoryRepository;
  final DeceasedRepository deceasedRepository;
  final SoldAnimalsRepository soldAnimalsRepository;
  final WeightAlertRepository weightAlertRepository;
  final BackupService backup;

  const FazendaSaoPetronioApp({
    super.key,
    required this.db,
    required this.animalRepository,
    required this.animalCascadeRepository,
    required this.animalLifecycleRepository,
    required this.maintenanceRepository,
    required this.pharmacyRepository,
    required this.breedingRepository,
    required this.financeRepository,
    required this.feedingRepository,
    required this.vaccinationRepository,
    required this.medicationRepository,
    required this.noteRepository,
    required this.animalHistoryRepository,
    required this.deceasedRepository,
    required this.soldAnimalsRepository,
    required this.weightAlertRepository,
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
        Provider<AnimalCascadeRepository>.value(
          value: animalCascadeRepository,
        ),
        Provider<AnimalLifecycleRepository>.value(
          value: animalLifecycleRepository,
        ),
        Provider<MaintenanceRepository>.value(
          value: maintenanceRepository,
        ),
        Provider<PharmacyRepository>.value(value: pharmacyRepository),
        Provider<BreedingRepository>.value(value: breedingRepository),
        Provider<FinanceRepository>.value(value: financeRepository),
        Provider<FeedingRepository>.value(value: feedingRepository),
        Provider<VaccinationRepository>.value(value: vaccinationRepository),
        Provider<MedicationRepository>.value(value: medicationRepository),
        Provider<NoteRepository>.value(value: noteRepository),
        Provider<AnimalHistoryRepository>.value(
          value: animalHistoryRepository,
        ),
        Provider<DeceasedRepository>.value(value: deceasedRepository),
        Provider<SoldAnimalsRepository>.value(value: soldAnimalsRepository),
        Provider<WeightAlertRepository>.value(value: weightAlertRepository),

        // Services
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
          create: (context) => WeightAlertService(
            context.read<WeightAlertRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AnimalService(
            context.read<AnimalRepository>(),
            context.read<AnimalLifecycleRepository>(),
            context.read<VaccinationRepository>(),
            context.read<MedicationRepository>(),
            context.read<WeightAlertService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WeightService(
            context.read<AnimalRepository>(),
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
            context.read<MedicationRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NoteService(
            context.read<NoteRepository>(),
          ),
        ),

        // BreedingService: usa BreedingRepository + AnimalRepository
        ChangeNotifierProvider(
          create: (context) => BreedingService(
            context.read<BreedingRepository>(),
            context.read<AnimalRepository>(),
          ),
        ),

        Provider<FinancialService>(
          create: (context) => FinancialService(
            context.read<FinanceRepository>(),
            context.read<AnimalLifecycleRepository>(),
          ),
        ),

        Provider<AnimalHistoryService>(
          create: (context) => AnimalHistoryService(
            context.read<AnimalHistoryRepository>(),
          ),
        ),
        Provider<ReportsController>(
          create: (context) => ReportsController(
            context.read<AppDatabase>(),
          ),
        ),
        Provider<SystemMaintenanceService>(
          create: (context) => SystemMaintenanceService(
            context.read<MaintenanceRepository>(),
          ),
        ),
        Provider<AnimalDeleteCascade>(
          create: (context) => AnimalDeleteCascade(
            context.read<AnimalCascadeRepository>(),
          ),
        ),

        // ✅ Óbitos (deceased_animals)
        Provider<DeceasedService>(
          create: (context) => DeceasedService(
            context.read<DeceasedRepository>(),
          ),
        ),

        // ✅ Vendidos (sold_animals)
        ChangeNotifierProvider(
          create: (context) => SoldAnimalsService(
            context.read<SoldAnimalsRepository>(),
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
