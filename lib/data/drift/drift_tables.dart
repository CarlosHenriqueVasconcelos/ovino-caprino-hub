// lib/data/drift/drift_tables.dart
//
// Definições de tabelas para o Drift (type-safe SQLite).
// Coexiste com o sqflite em lib/data/local_db.dart durante a migração.
//
// Convenções:
//   - Getters camelCase → colunas snake_case automaticamente pelo Drift
//   - Datas armazenadas como TEXT ISO-8601 (store_date_time_values_as_text: true no build.yaml)
//   - @DataClassName evita conflito com os modelos em lib/models/
//   - CHECK constraints de enum são validados na camada de aplicação (DAOs/repositories)
//   - farm_id: UUID da fazenda ativa — base do isolamento multi-tenant offline-first
//     Nullable para compatibilidade durante a migração; será obrigatório após auth implementado.
import 'package:drift/drift.dart';

// ============================================================
// ANIMALS
// ============================================================
@DataClassName('AnimalRow')
class Animals extends Table {
  TextColumn get id => text()();
  /// Isolamento multi-tenant: UUID da fazenda dona deste registro.
  TextColumn get farmId => text().nullable()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  // 'Ovino' | 'Caprino'
  TextColumn get species => text()();
  TextColumn get breed => text()();
  // 'Macho' | 'Fêmea'
  TextColumn get gender => text()();
  TextColumn get birthDate => text()();
  RealColumn get weight => real()();
  TextColumn get status =>
      text().withDefault(const Constant('Saudável'))();
  TextColumn get reproductiveStatus =>
      text().withDefault(const Constant('Não aplicável'))();
  TextColumn get location => text()();
  TextColumn get lastVaccination => text().nullable()();
  BoolColumn get pregnant =>
      boolean().withDefault(const Constant(false))();
  TextColumn get expectedDelivery => text().nullable()();
  TextColumn get healthIssue => text().nullable()();
  TextColumn get registrationNote => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get nameColor => text().nullable()();
  TextColumn get category => text().nullable()();
  RealColumn get birthWeight => real().nullable()();
  RealColumn get weight30Days => real().nullable().named('weight_30_days')();
  RealColumn get weight60Days => real().nullable().named('weight_60_days')();
  RealColumn get weight90Days => real().nullable().named('weight_90_days')();
  RealColumn get weight120Days => real().nullable().named('weight_120_days')();
  IntColumn get year => integer().nullable()();
  TextColumn get lote => text().nullable()();
  TextColumn get motherId => text().nullable()();
  TextColumn get fatherId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// ANIMAL_WEIGHTS
// ============================================================
@DataClassName('AnimalWeightRow')
class AnimalWeights extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get animalId =>
      text().references(Animals, #id)();
  TextColumn get date => text()();
  RealColumn get weight => real()();
  // Ex.: '30d' | '60d' | '90d' | '120d' | null
  TextColumn get milestone => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// ANIMAL_LINEAGE  (fechamento ancestral — chave composta)
// ============================================================
@DataClassName('AnimalLineageRow')
class AnimalLineage extends Table {
  TextColumn get farmId => text().nullable()();
  TextColumn get descendantId => text()();
  TextColumn get ancestorId => text()();
  IntColumn get depth => integer()();
  // 'maternal' | 'paternal' | 'mixed' | 'unknown'
  TextColumn get lineType =>
      text().withDefault(const Constant('unknown'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {descendantId, ancestorId};
}

// ============================================================
// ANIMAL_LINEAGE_META
// ============================================================
@DataClassName('AnimalLineageMetaRow')
class AnimalLineageMeta extends Table {
  TextColumn get farmId => text().nullable()();
  TextColumn get metaKey => text()();
  TextColumn get metaValue => text()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {metaKey};
}

// ============================================================
// APP_SETTINGS  (configurações por fazenda)
// ============================================================
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  /// Chave composta (farm_id + setting_key) para isolamento por fazenda.
  /// farm_id é nullable para manter compatibilidade com registros migrados
  /// que ainda não têm fazenda associada (ex.: configurações globais).
  TextColumn get farmId => text().nullable()();
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {farmId, settingKey};
}

// ============================================================
// BREEDING_RECORDS
// ============================================================
@DataClassName('BreedingRecordRow')
class BreedingRecords extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get femaleAnimalId =>
      text().nullable().references(Animals, #id)();
  TextColumn get maleAnimalId =>
      text().nullable().references(Animals, #id)();
  TextColumn get breedingDate => text()();
  TextColumn get expectedBirth => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('Cobertura'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get matingStartDate => text().nullable()();
  TextColumn get matingEndDate => text().nullable()();
  TextColumn get separationDate => text().nullable()();
  TextColumn get ultrasoundDate => text().nullable()();
  TextColumn get ultrasoundResult => text().nullable()();
  TextColumn get birthDate => text().nullable()();
  // 'encabritamento'|'separacao'|'aguardando_ultrassom'|
  // 'gestacao_confirmada'|'parto_realizado'|'falhou'
  TextColumn get stage =>
      text().withDefault(const Constant('encabritamento'))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// MATRIX_EVALUATIONS
// ============================================================
@DataClassName('MatrixEvaluationRow')
class MatrixEvaluations extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get animalId =>
      text().references(Animals, #id)();
  TextColumn get evaluationDate => text()();
  RealColumn get fertilityScore => real()();
  RealColumn get maternalScore => real()();
  RealColumn get healthScore => real()();
  RealColumn get temperamentScore => real()();
  RealColumn get growthScore => real()();
  TextColumn get hoofCondition =>
      text().withDefault(const Constant('Sem problema'))();
  TextColumn get verminosisLevel =>
      text().withDefault(const Constant('Nenhuma'))();
  TextColumn get twinningHistory =>
      text().withDefault(const Constant('Sem histórico'))();
  RealColumn get lambingWeight => real().nullable()();
  RealColumn get weaningWeight => real().nullable()();
  RealColumn get lactationScore =>
      real().withDefault(const Constant(7.0))();
  RealColumn get bodyConditionScore =>
      real().withDefault(const Constant(3.0))();
  RealColumn get dentitionScore =>
      real().withDefault(const Constant(7.0))();
  IntColumn get ageMonths => integer().nullable()();
  RealColumn get finalScore => real()();
  TextColumn get recommendation =>
      text().withDefault(const Constant('Observação'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// FINANCIAL_ACCOUNTS
// ============================================================
@DataClassName('FinancialAccountRow')
class FinancialAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  // 'receita' | 'despesa'
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get dueDate => text()();
  TextColumn get paymentDate => text().nullable()();
  // 'Pendente'|'Pago'|'Vencido'|'Cancelado'
  TextColumn get status =>
      text().withDefault(const Constant('Pendente'))();
  TextColumn get paymentMethod => text().nullable()();
  IntColumn get installments => integer().nullable()();
  IntColumn get installmentNumber => integer().nullable()();
  // auto-referência: sem .references() para evitar dependência circular
  TextColumn get parentId => text().nullable()();
  TextColumn get animalId =>
      text().nullable().references(Animals, #id)();
  TextColumn get supplierCustomer => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  // 'Diária'|'Semanal'|'Mensal'|'Anual'
  TextColumn get recurrenceFrequency => text().nullable()();
  TextColumn get recurrenceEndDate => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// FINANCIAL_RECORDS
// ============================================================
@DataClassName('FinancialRecordRow')
class FinancialRecords extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  // 'receita' | 'despesa'
  TextColumn get type => text()();
  TextColumn get category => text()();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get date => text()();
  TextColumn get animalId =>
      text().nullable().references(Animals, #id)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// PHARMACY_STOCK
// ============================================================
@DataClassName('PharmacyStockRow')
class PharmacyStock extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get medicationName => text()();
  TextColumn get medicationType => text()();
  TextColumn get unitOfMeasure => text()();
  RealColumn get quantityPerUnit => real().nullable()();
  RealColumn get totalQuantity =>
      real().withDefault(const Constant(0.0))();
  RealColumn get minStockAlert => real().nullable()();
  TextColumn get expirationDate => text().nullable()();
  BoolColumn get isOpened =>
      boolean().withDefault(const Constant(false))();
  RealColumn get openedQuantity =>
      real().withDefault(const Constant(0.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// MEDICATIONS
// ============================================================
@DataClassName('MedicationRow')
class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get animalId =>
      text().references(Animals, #id)();
  TextColumn get medicationName => text()();
  TextColumn get date => text()();
  TextColumn get nextDate => text().nullable()();
  TextColumn get dosage => text().nullable()();
  TextColumn get veterinarian => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get status =>
      text().withDefault(const Constant('Agendado'))();
  TextColumn get appliedDate => text().nullable()();
  TextColumn get pharmacyStockId =>
      text().nullable().references(PharmacyStock, #id)();
  RealColumn get quantityUsed => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// PHARMACY_STOCK_MOVEMENTS
// ============================================================
@DataClassName('PharmacyMovementRow')
class PharmacyStockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get pharmacyStockId =>
      text().references(PharmacyStock, #id, onDelete: KeyAction.cascade)();
  TextColumn get medicationId =>
      text().nullable().references(Medications, #id)();
  TextColumn get movementType => text()();
  RealColumn get quantity => real()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// NOTES
// ============================================================
@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get animalId =>
      text().nullable().references(Animals, #id)();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  TextColumn get category => text()();
  TextColumn get priority =>
      text().withDefault(const Constant('Média'))();
  TextColumn get date => text()();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// REPORTS
// ============================================================
@DataClassName('ReportRow')
class Reports extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get title => text()();
  // 'Animais'|'Vacinações'|'Reprodução'|'Saúde'|'Financeiro'
  TextColumn get reportType => text()();
  TextColumn get parameters =>
      text().withDefault(const Constant('{}'))();
  DateTimeColumn get generatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get generatedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// PUSH_TOKENS
// ============================================================
@DataClassName('PushTokenRow')
class PushTokens extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get token => text().unique()();
  TextColumn get platform => text().nullable()();
  TextColumn get deviceInfo =>
      text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// FEEDING_PENS
// ============================================================
@DataClassName('FeedingPenRow')
class FeedingPens extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get number => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// FEEDING_SCHEDULES
// ============================================================
@DataClassName('FeedingScheduleRow')
class FeedingSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get penId =>
      text().references(FeedingPens, #id, onDelete: KeyAction.cascade)();
  TextColumn get feedType => text()();
  RealColumn get quantity => real()();
  IntColumn get timesPerDay =>
      integer().withDefault(const Constant(1))();
  // JSON array de horários, ex.: '["07:00","17:00"]'
  TextColumn get feedingTimes => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// VACCINATIONS
// ============================================================
@DataClassName('VaccinationRow')
class Vaccinations extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get animalId =>
      text().references(Animals, #id)();
  TextColumn get vaccineName => text()();
  TextColumn get vaccineType => text()();
  TextColumn get scheduledDate => text()();
  TextColumn get appliedDate => text().nullable()();
  TextColumn get veterinarian => text().nullable()();
  TextColumn get notes => text().nullable()();
  // 'Agendada' | 'Aplicada' | 'Cancelada'
  TextColumn get status =>
      text().withDefault(const Constant('Agendada'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// SOLD_ANIMALS
// ============================================================
@DataClassName('SoldAnimalRow')
class SoldAnimals extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get originalAnimalId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get species => text()();
  TextColumn get breed => text()();
  TextColumn get gender => text()();
  TextColumn get birthDate => text()();
  RealColumn get weight => real()();
  TextColumn get location => text()();
  TextColumn get reproductiveStatus =>
      text().withDefault(const Constant('Não aplicável'))();
  TextColumn get nameColor => text().nullable()();
  TextColumn get category => text().nullable()();
  RealColumn get birthWeight => real().nullable()();
  RealColumn get weight30Days => real().nullable().named('weight_30_days')();
  RealColumn get weight60Days => real().nullable().named('weight_60_days')();
  RealColumn get weight90Days => real().nullable().named('weight_90_days')();
  RealColumn get weight120Days => real().nullable().named('weight_120_days')();
  IntColumn get year => integer().nullable()();
  TextColumn get lote => text().nullable()();
  TextColumn get motherId => text().nullable()();
  TextColumn get fatherId => text().nullable()();
  TextColumn get registrationNote => text().nullable()();
  TextColumn get saleDate => text()();
  RealColumn get salePrice => real().nullable()();
  TextColumn get buyer => text().nullable()();
  TextColumn get saleNotes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// DECEASED_ANIMALS
// ============================================================
@DataClassName('DeceasedAnimalRow')
class DeceasedAnimals extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get originalAnimalId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get species => text()();
  TextColumn get breed => text()();
  TextColumn get gender => text()();
  TextColumn get birthDate => text()();
  RealColumn get weight => real()();
  TextColumn get location => text()();
  TextColumn get reproductiveStatus =>
      text().withDefault(const Constant('Não aplicável'))();
  TextColumn get nameColor => text().nullable()();
  TextColumn get category => text().nullable()();
  RealColumn get birthWeight => real().nullable()();
  RealColumn get weight30Days => real().nullable().named('weight_30_days')();
  RealColumn get weight60Days => real().nullable().named('weight_60_days')();
  RealColumn get weight90Days => real().nullable().named('weight_90_days')();
  RealColumn get weight120Days => real().nullable().named('weight_120_days')();
  IntColumn get year => integer().nullable()();
  TextColumn get lote => text().nullable()();
  TextColumn get motherId => text().nullable()();
  TextColumn get fatherId => text().nullable()();
  TextColumn get registrationNote => text().nullable()();
  TextColumn get deathDate => text()();
  TextColumn get causeOfDeath => text().nullable()();
  TextColumn get deathNotes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// WEIGHT_ALERTS
// ============================================================
@DataClassName('WeightAlertRow')
class WeightAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().nullable()();
  TextColumn get animalId =>
      text().references(Animals, #id, onDelete: KeyAction.cascade)();
  TextColumn get alertType => text()();
  TextColumn get dueDate => text()();
  BoolColumn get completed =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
