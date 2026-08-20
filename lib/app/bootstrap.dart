import 'dart:async';

import 'package:flutter/foundation.dart';
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
    final bootWatch = Stopwatch()..start();
    void bootLog(String message) {
      if (!kDebugMode) return;
      debugPrint('BOOT +${bootWatch.elapsedMilliseconds}ms $message');
    }

    WidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'pt_BR';
    bootLog('binding:ready');

    // Cria DB e serviços de forma síncrona (sem I/O).
    final driftDb = AppDriftDatabase();
    final authService = AuthService(driftDb);
    final syncService = SyncService(driftDb, authService);
    bootLog('core_services:created');

    final animalRepository = AnimalRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final pharmacyRepository = PharmacyRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final breedingRepository = BreedingRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final financeRepository = FinanceRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final feedingRepository = FeedingRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final vaccinationRepository = VaccinationRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final medicationRepository = MedicationRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final noteRepository = NoteRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final animalHistoryRepository = AnimalHistoryRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final deceasedRepository = DeceasedRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final soldAnimalsRepository = SoldAnimalsRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final weightAlertRepository = WeightAlertRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final animalCascadeRepository = AnimalCascadeRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final animalLifecycleRepository = AnimalLifecycleRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final maintenanceRepository = MaintenanceRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );
    final reportsRepository = ReportsRepository(
      driftDb,
      farmIdProvider: () => authService.currentFarmId,
    );

    // BackupRepository usa cliente Supabase de forma lazy — pode ser criado
    // antes de Supabase.initialize() pois o cliente só é acessado em operações
    // de backup, nunca durante o startup.
    final backupRepository = BackupRepository(
      database: driftDb,
      clientProvider: () => Supabase.instance.client,
      farmIdProvider: () => authService.currentFarmId,
    );
    final backupService = BackupService(repository: backupRepository);

    // runApp antes de toda inicialização pesada — o splash aparece imediatamente.
    runApp(
      TerraTechApp(
        deps: AppDependencies(
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
    bootLog('runApp:called');
    final infraReadyCompleter = Completer<void>();
    final infraReady = infraReadyCompleter.future;
    bootLog('infra:scheduled_after_first_frame');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bootLog('first_frame:rendered');
      unawaited(() async {
        try {
          // Infra de rede/i18n inicia só após o primeiro frame.
          bootLog('infra:start');
          await dotenv.load(fileName: '.env');
          bootLog('.env:loaded');
          AppConfig.validate();

          final supabaseUrl = AppConfig.supabaseUrl;
          final supabaseAnonKey = AppConfig.supabaseAnonKey;

          await Future.wait([
            logService.initialize().then((_) => bootLog('log_service:ready')),
            initializeDateFormatting(
              'pt_BR',
              null,
            ).then((_) => bootLog('intl:pt_BR_ready')),
            Supabase.initialize(
              url: supabaseUrl,
              anonKey: supabaseAnonKey,
            ).then((_) => bootLog('supabase:init_done')),
          ]);
          bootLog('infra:ready');
          if (!infraReadyCompleter.isCompleted) {
            infraReadyCompleter.complete();
          }
        } catch (e, st) {
          bootLog('infra:error:$e');
          if (!infraReadyCompleter.isCompleted) {
            infraReadyCompleter.complete();
          }
          unawaited(
            logService.logWarning(
              'Falha na infraestrutura de bootstrap: $e',
            ),
          );
          debugPrint('bootstrap infra error: $e\n$st');
        }
      }());
    });

    // Auth verifica cache local (Drift) imediatamente — o fast path não precisa
    // do Supabase. Em usuários já logados, o AuthGate abre em < 1 s.
    // O slow path (primeiro acesso) aguarda o infraReady internamente.
    await authService.initialize(supabaseReady: infraReady);
    bootLog('auth_initialize:done');
    // Sync inicializa em background para não competir com o primeiro frame.
    unawaited(
      syncService.initialize().catchError((Object error, StackTrace stackTrace) {
        unawaited(
          logService.logWarning(
            'Falha ao inicializar SyncService no bootstrap: $error',
          ),
        );
        debugPrint(
          'SyncService.initialize bootstrap error: $error\n$stackTrace',
        );
      }),
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
