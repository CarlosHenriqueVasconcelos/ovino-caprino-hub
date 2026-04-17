import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../data/animal_cascade_repository.dart';
import '../data/animal_history_repository.dart';
import '../data/animal_lifecycle_repository.dart';
import '../data/animal_repository.dart';
import '../data/backup_repository.dart';
import '../data/breeding_repository.dart';
import '../data/deceased_repository.dart';
import '../data/feeding_repository.dart';
import '../data/finance_repository.dart';
import '../data/drift/app_database.dart';
import '../data/local_db.dart';
import '../data/maintenance_repository.dart';
import '../data/medication_repository.dart';
import '../data/note_repository.dart';
import '../data/pharmacy_repository.dart';
import '../data/reports_repository.dart';
import '../data/sold_animals_repository.dart';
import '../data/vaccination_repository.dart';
import '../data/weight_alert_repository.dart';
import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../services/sync_service.dart';
import 'app.dart';
import 'app_logging.dart';

Future<void> bootstrapApp() async {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final message = details.exception.toString();
    final isOverflow =
        message.contains('RenderFlex overflowed') ||
        message.contains('overflowed');

    if (isOverflow) {
      logService.logOverflow(
        message,
        stackTrace: details.stack,
      );
    } else {
      logService.logError(
        message,
        stackTrace: details.stack,
        widget: details.context?.toDescription(),
      );
    }

    FlutterError.presentError(details);
    try {
      previousOnError?.call(details);
    } catch (_) {}

    if (isOverflow) return;
    if (details.stack != null) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    } else {
      Zone.current.handleUncaughtError(details.exception, StackTrace.current);
    }
  };

  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'pt_BR';

    // Carrega variáveis de ambiente antes de qualquer outra coisa.
    await dotenv.load(fileName: '.env');
    AppConfig.validate();

    // Inicializações independentes em paralelo — reduz o tempo de startup
    // colocando Supabase, DB local e formatação a correr ao mesmo tempo.
    late final AppDatabase appDb;
    await Future.wait([
      initializeDateFormatting('pt_BR', null),
      logService.initialize(),
      Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      ),
      AppDatabase.open().then((db) => appDb = db),
    ]);

    final driftDb = AppDriftDatabase();

    final authService = AuthService(driftDb);
    await authService.initialize();
    final syncService = SyncService(driftDb, authService, appDb);
    await syncService.initialize();

    final animalRepository = AnimalRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final pharmacyRepository = PharmacyRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final breedingRepository = BreedingRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final financeRepository = FinanceRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final feedingRepository = FeedingRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final vaccinationRepository = VaccinationRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final medicationRepository = MedicationRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final noteRepository = NoteRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final animalHistoryRepository = AnimalHistoryRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final deceasedRepository = DeceasedRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final soldAnimalsRepository = SoldAnimalsRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final weightAlertRepository = WeightAlertRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final animalCascadeRepository = AnimalCascadeRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final animalLifecycleRepository = AnimalLifecycleRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final maintenanceRepository = MaintenanceRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final reportsRepository = ReportsRepository(
      appDb,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );

    final backupRepository = BackupRepository(
      database: appDb,
      client: Supabase.instance.client,
      driftDb: driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final backupService = BackupService(repository: backupRepository);

    runApp(
      FazendaSaoPetronioApp(
        deps: AppDependencies(
          db: appDb,
          driftDb: driftDb,
          authService: authService,
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
          reportsRepository: reportsRepository,
          syncService: syncService,
        ),
      ),
    );
  }, (error, stack) {
    logService.logError(
      error.toString(),
      stackTrace: stack,
    );

    debugPrint('=== Uncaught error ===');
    debugPrint('$error');
    try {
      debugPrintStack(stackTrace: stack);
    } catch (_) {
      debugPrint(stack.toString());
    }
  });
}
