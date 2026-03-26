import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../data/animal_cascade_repository.dart';
import '../data/animal_history_repository.dart';
import '../data/animal_lifecycle_repository.dart';
import '../data/animal_repository.dart';
import '../data/breeding_repository.dart';
import '../data/deceased_repository.dart';
import '../data/feeding_repository.dart';
import '../data/finance_repository.dart';
import '../data/local_db.dart';
import '../data/maintenance_repository.dart';
import '../data/medication_repository.dart';
import '../data/note_repository.dart';
import '../data/pharmacy_repository.dart';
import '../data/reports_repository.dart';
import '../data/sold_animals_repository.dart';
import '../data/vaccination_repository.dart';
import '../data/weight_alert_repository.dart';
import '../features/breeding/application/kinship_service.dart';
import '../features/breeding/application/matrix_selection_service.dart';
import '../features/breeding/data/kinship_repository.dart';
import '../features/breeding/data/matrix_evaluation_repository.dart';
import '../features/reports/application/reports_controller.dart';
import '../features/reports/application/reports_service.dart';
import '../features/reports/data/reports_repository.dart';
import '../services/animal_delete_cascade.dart';
import '../services/animal_history_service.dart';
import '../services/animal_service.dart';
import '../services/backup_service.dart';
import '../services/breeding_service.dart';
import '../services/deceased_service.dart';
import '../services/feeding_service.dart';
import '../services/financial_service.dart';
import '../services/medication_service.dart';
import '../services/note_service.dart';
import '../services/pharmacy_service.dart';
import '../services/sold_animals_service.dart';
import '../services/system_maintenance_service.dart';
import '../services/vaccination_service.dart';
import '../services/weight_alert_service.dart';
import '../services/weight_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_scroll_behavior.dart';
import 'presentation/complete_dashboard_screen.dart';

class AppDependencies {
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
  final ReportsRepository reportsRepository;

  const AppDependencies({
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
    required this.reportsRepository,
  });
}

class FazendaSaoPetronioApp extends StatelessWidget {
  final AppDependencies deps;

  const FazendaSaoPetronioApp({
    super.key,
    required this.deps,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: deps.db),
        Provider<BackupService>.value(value: deps.backup),

        Provider<AnimalRepository>.value(value: deps.animalRepository),
        Provider<KinshipRepository>(
          create: (context) => KinshipRepository(
            context.read<AppDatabase>(),
          ),
        ),
        Provider<MatrixEvaluationRepository>(
          create: (context) => MatrixEvaluationRepository(
            context.read<AppDatabase>(),
          ),
        ),
        Provider<AnimalCascadeRepository>.value(
          value: deps.animalCascadeRepository,
        ),
        Provider<AnimalLifecycleRepository>.value(
          value: deps.animalLifecycleRepository,
        ),
        Provider<MaintenanceRepository>.value(
          value: deps.maintenanceRepository,
        ),
        Provider<PharmacyRepository>.value(value: deps.pharmacyRepository),
        Provider<BreedingRepository>.value(value: deps.breedingRepository),
        Provider<FinanceRepository>.value(value: deps.financeRepository),
        Provider<FeedingRepository>.value(value: deps.feedingRepository),
        Provider<VaccinationRepository>.value(value: deps.vaccinationRepository),
        Provider<MedicationRepository>.value(value: deps.medicationRepository),
        Provider<NoteRepository>.value(value: deps.noteRepository),
        Provider<AnimalHistoryRepository>.value(
          value: deps.animalHistoryRepository,
        ),
        Provider<DeceasedRepository>.value(value: deps.deceasedRepository),
        Provider<SoldAnimalsRepository>.value(value: deps.soldAnimalsRepository),
        Provider<WeightAlertRepository>.value(value: deps.weightAlertRepository),
        Provider<ReportsRepository>.value(value: deps.reportsRepository),
        Provider<ReportsService>(
          create: (context) => ReportsService(
            context.read<ReportsRepository>(),
          ),
        ),
        Provider<ReportsFeatureRepository>(
          create: (context) => ReportsFeatureRepository(
            reportsService: context.read<ReportsService>(),
          ),
        ),
        Provider<KinshipService>(
          create: (context) => KinshipService(
            context.read<KinshipRepository>(),
          ),
        ),
        Provider<MatrixSelectionService>(
          create: (context) => MatrixSelectionService(
            context.read<MatrixEvaluationRepository>(),
          ),
        ),

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
        Provider<NoteService>(
          create: (context) => NoteService(
            context.read<NoteRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BreedingService(
            context.read<BreedingRepository>(),
            context.read<AnimalRepository>(),
            kinshipService: context.read<KinshipService>(),
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
            context.read<ReportsFeatureRepository>(),
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
        Provider<DeceasedService>(
          create: (context) => DeceasedService(
            context.read<DeceasedRepository>(),
            context.read<AnimalLifecycleRepository>(),
          ),
        ),
        Provider<SoldAnimalsService>(
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
        scrollBehavior: const AppScrollBehavior(),
        home: const CompleteDashboardScreen(),
      ),
    );
  }
}
