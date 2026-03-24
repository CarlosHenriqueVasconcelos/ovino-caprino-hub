// lib/services/events/app_events.dart
// Eventos tipados para sistema reativo

/// Evento base para todos os eventos da aplicação
abstract class AppEvent {
  final DateTime timestamp;
  AppEvent() : timestamp = DateTime.now();
}

// ============== EVENTOS DE ANIMAIS ==============

class AnimalCreatedEvent extends AppEvent {
  final String animalId;
  final String name;
  final String category;
  AnimalCreatedEvent({
    required this.animalId,
    required this.name,
    required this.category,
  });
}

class AnimalUpdatedEvent extends AppEvent {
  final String animalId;
  final Map<String, dynamic> changes;
  AnimalUpdatedEvent({
    required this.animalId,
    required this.changes,
  });
}

class AnimalDeletedEvent extends AppEvent {
  final String animalId;
  AnimalDeletedEvent({required this.animalId});
}

class AnimalMarkedAsSoldEvent extends AppEvent {
  final String animalId;
  final DateTime saleDate;
  final double? salePrice;
  AnimalMarkedAsSoldEvent({
    required this.animalId,
    required this.saleDate,
    this.salePrice,
  });
}

class AnimalMarkedAsDeceasedEvent extends AppEvent {
  final String animalId;
  final DateTime deathDate;
  final String? causeOfDeath;
  AnimalMarkedAsDeceasedEvent({
    required this.animalId,
    required this.deathDate,
    this.causeOfDeath,
  });
}

class AnimalPregnancyUpdatedEvent extends AppEvent {
  final String animalId;
  final bool isPregnant;
  final DateTime? expectedDelivery;
  AnimalPregnancyUpdatedEvent({
    required this.animalId,
    required this.isPregnant,
    this.expectedDelivery,
  });
}

// ============== EVENTOS DE PESO ==============

class WeightAddedEvent extends AppEvent {
  final String animalId;
  final double weight;
  final DateTime date;
  final String? milestone;
  WeightAddedEvent({
    required this.animalId,
    required this.weight,
    required this.date,
    this.milestone,
  });
}

class WeightAlertCompletedEvent extends AppEvent {
  final String alertId;
  final String animalId;
  WeightAlertCompletedEvent({
    required this.alertId,
    required this.animalId,
  });
}

// ============== EVENTOS DE REPRODUÇÃO ==============

class BreedingRecordCreatedEvent extends AppEvent {
  final String recordId;
  final String? femaleAnimalId;
  final String? maleAnimalId;
  BreedingRecordCreatedEvent({
    required this.recordId,
    this.femaleAnimalId,
    this.maleAnimalId,
  });
}

class BreedingRecordUpdatedEvent extends AppEvent {
  final String recordId;
  final String? stage;
  final String? status;
  BreedingRecordUpdatedEvent({
    required this.recordId,
    this.stage,
    this.status,
  });
}

class BreedingRecordDeletedEvent extends AppEvent {
  final String recordId;
  BreedingRecordDeletedEvent({required this.recordId});
}

// ============== EVENTOS DE VACINAÇÃO ==============

class VaccinationCreatedEvent extends AppEvent {
  final String vaccinationId;
  final String animalId;
  final String vaccineName;
  VaccinationCreatedEvent({
    required this.vaccinationId,
    required this.animalId,
    required this.vaccineName,
  });
}

class VaccinationUpdatedEvent extends AppEvent {
  final String vaccinationId;
  final String animalId;
  final String status;
  VaccinationUpdatedEvent({
    required this.vaccinationId,
    required this.animalId,
    required this.status,
  });
}

class VaccinationDeletedEvent extends AppEvent {
  final String vaccinationId;
  final String animalId;
  VaccinationDeletedEvent({
    required this.vaccinationId,
    required this.animalId,
  });
}

// ============== EVENTOS DE MEDICAÇÃO ==============

class MedicationCreatedEvent extends AppEvent {
  final String medicationId;
  final String animalId;
  final String medicationName;
  MedicationCreatedEvent({
    required this.medicationId,
    required this.animalId,
    required this.medicationName,
  });
}

class MedicationUpdatedEvent extends AppEvent {
  final String medicationId;
  final String animalId;
  final String status;
  MedicationUpdatedEvent({
    required this.medicationId,
    required this.animalId,
    required this.status,
  });
}

class MedicationDeletedEvent extends AppEvent {
  final String medicationId;
  final String animalId;
  MedicationDeletedEvent({
    required this.medicationId,
    required this.animalId,
  });
}

// ============== EVENTOS DE FARMÁCIA ==============

class PharmacyStockCreatedEvent extends AppEvent {
  final String stockId;
  final String medicationName;
  PharmacyStockCreatedEvent({
    required this.stockId,
    required this.medicationName,
  });
}

class PharmacyStockUpdatedEvent extends AppEvent {
  final String stockId;
  final String medicationName;
  final double totalQuantity;
  PharmacyStockUpdatedEvent({
    required this.stockId,
    required this.medicationName,
    required this.totalQuantity,
  });
}

class PharmacyStockDeletedEvent extends AppEvent {
  final String stockId;
  PharmacyStockDeletedEvent({required this.stockId});
}

class PharmacyStockMovementEvent extends AppEvent {
  final String stockId;
  final String movementType;
  final double quantity;
  PharmacyStockMovementEvent({
    required this.stockId,
    required this.movementType,
    required this.quantity,
  });
}

// ============== EVENTOS DE ALIMENTAÇÃO ==============

class FeedingPenCreatedEvent extends AppEvent {
  final String penId;
  final String name;
  FeedingPenCreatedEvent({
    required this.penId,
    required this.name,
  });
}

class FeedingPenUpdatedEvent extends AppEvent {
  final String penId;
  FeedingPenUpdatedEvent({required this.penId});
}

class FeedingPenDeletedEvent extends AppEvent {
  final String penId;
  FeedingPenDeletedEvent({required this.penId});
}

class FeedingScheduleCreatedEvent extends AppEvent {
  final String scheduleId;
  final String penId;
  FeedingScheduleCreatedEvent({
    required this.scheduleId,
    required this.penId,
  });
}

class FeedingScheduleUpdatedEvent extends AppEvent {
  final String scheduleId;
  final String penId;
  FeedingScheduleUpdatedEvent({
    required this.scheduleId,
    required this.penId,
  });
}

class FeedingScheduleDeletedEvent extends AppEvent {
  final String scheduleId;
  final String penId;
  FeedingScheduleDeletedEvent({
    required this.scheduleId,
    required this.penId,
  });
}

// ============== EVENTOS DE FINANCEIRO ==============

class FinancialAccountCreatedEvent extends AppEvent {
  final String accountId;
  final String type;
  final double amount;
  FinancialAccountCreatedEvent({
    required this.accountId,
    required this.type,
    required this.amount,
  });
}

class FinancialAccountUpdatedEvent extends AppEvent {
  final String accountId;
  final String? status;
  FinancialAccountUpdatedEvent({
    required this.accountId,
    this.status,
  });
}

class FinancialAccountDeletedEvent extends AppEvent {
  final String accountId;
  FinancialAccountDeletedEvent({required this.accountId});
}

// ============== EVENTOS DE NOTAS ==============

class NoteCreatedEvent extends AppEvent {
  final String noteId;
  final String? animalId;
  final String category;
  NoteCreatedEvent({
    required this.noteId,
    this.animalId,
    required this.category,
  });
}

class NoteUpdatedEvent extends AppEvent {
  final String noteId;
  final bool? isRead;
  NoteUpdatedEvent({
    required this.noteId,
    this.isRead,
  });
}

class NoteDeletedEvent extends AppEvent {
  final String noteId;
  NoteDeletedEvent({required this.noteId});
}

// ============== EVENTOS DE SISTEMA ==============

class DataImportedEvent extends AppEvent {
  final String sourceType;
  final int itemsImported;
  DataImportedEvent({
    required this.sourceType,
    required this.itemsImported,
  });
}

class DataExportedEvent extends AppEvent {
  final String exportType;
  final int itemsExported;
  DataExportedEvent({
    required this.exportType,
    required this.itemsExported,
  });
}

class DatabaseRestoredEvent extends AppEvent {
  final String backupFile;
  DatabaseRestoredEvent({required this.backupFile});
}

class StatsRefreshRequestedEvent extends AppEvent {
  StatsRefreshRequestedEvent();
}

class AlertsRefreshRequestedEvent extends AppEvent {
  AlertsRefreshRequestedEvent();
}
