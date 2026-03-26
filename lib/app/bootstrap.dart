import 'dart:async';

import 'package:flutter/material.dart';
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
import '../data/local_db.dart';
import '../data/maintenance_repository.dart';
import '../data/medication_repository.dart';
import '../data/note_repository.dart';
import '../data/pharmacy_repository.dart';
import '../data/reports_repository.dart';
import '../data/sold_animals_repository.dart';
import '../data/vaccination_repository.dart';
import '../data/weight_alert_repository.dart';
import '../services/backup_service.dart';
import 'app.dart';
import 'app_logging.dart';

Future<void> bootstrapApp() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('RenderFlex overflowed') ||
        details.exception.toString().contains('overflowed')) {
      logService.logOverflow(
        details.exception.toString(),
        stackTrace: details.stack,
      );
    } else {
      logService.logError(
        details.exception.toString(),
        stackTrace: details.stack,
        widget: details.context?.toDescription(),
      );
    }

    FlutterError.presentError(details);
    if (details.stack != null) {
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    } else {
      Zone.current.handleUncaughtError(details.exception, StackTrace.current);
    }
  };

  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'pt_BR';
    await initializeDateFormatting('pt_BR', null);
    await logService.initialize();

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    final appDb = await AppDatabase.open();

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
    final reportsRepository = ReportsRepository(appDb);

    final backupRepository = BackupRepository(
      database: appDb,
      client: Supabase.instance.client,
    );
    final backupService = BackupService(repository: backupRepository);

    runApp(
      FazendaSaoPetronioApp(
        deps: AppDependencies(
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
          reportsRepository: reportsRepository,
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
    debugPrintStack(stackTrace: stack);
  });
}
