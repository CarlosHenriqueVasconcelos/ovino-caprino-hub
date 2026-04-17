// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AnimalsTable extends Animals with TableInfo<$AnimalsTable, AnimalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Saudável'));
  static const VerificationMeta _reproductiveStatusMeta =
      const VerificationMeta('reproductiveStatus');
  @override
  late final GeneratedColumn<String> reproductiveStatus =
      GeneratedColumn<String>('reproductive_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('Não aplicável'));
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastVaccinationMeta =
      const VerificationMeta('lastVaccination');
  @override
  late final GeneratedColumn<String> lastVaccination = GeneratedColumn<String>(
      'last_vaccination', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pregnantMeta =
      const VerificationMeta('pregnant');
  @override
  late final GeneratedColumn<bool> pregnant = GeneratedColumn<bool>(
      'pregnant', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pregnant" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _expectedDeliveryMeta =
      const VerificationMeta('expectedDelivery');
  @override
  late final GeneratedColumn<String> expectedDelivery = GeneratedColumn<String>(
      'expected_delivery', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _healthIssueMeta =
      const VerificationMeta('healthIssue');
  @override
  late final GeneratedColumn<String> healthIssue = GeneratedColumn<String>(
      'health_issue', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _registrationNoteMeta =
      const VerificationMeta('registrationNote');
  @override
  late final GeneratedColumn<String> registrationNote = GeneratedColumn<String>(
      'registration_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _nameColorMeta =
      const VerificationMeta('nameColor');
  @override
  late final GeneratedColumn<String> nameColor = GeneratedColumn<String>(
      'name_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthWeightMeta =
      const VerificationMeta('birthWeight');
  @override
  late final GeneratedColumn<double> birthWeight = GeneratedColumn<double>(
      'birth_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight30DaysMeta =
      const VerificationMeta('weight30Days');
  @override
  late final GeneratedColumn<double> weight30Days = GeneratedColumn<double>(
      'weight_30_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight60DaysMeta =
      const VerificationMeta('weight60Days');
  @override
  late final GeneratedColumn<double> weight60Days = GeneratedColumn<double>(
      'weight_60_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight90DaysMeta =
      const VerificationMeta('weight90Days');
  @override
  late final GeneratedColumn<double> weight90Days = GeneratedColumn<double>(
      'weight_90_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight120DaysMeta =
      const VerificationMeta('weight120Days');
  @override
  late final GeneratedColumn<double> weight120Days = GeneratedColumn<double>(
      'weight_120_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _loteMeta = const VerificationMeta('lote');
  @override
  late final GeneratedColumn<String> lote = GeneratedColumn<String>(
      'lote', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _motherIdMeta =
      const VerificationMeta('motherId');
  @override
  late final GeneratedColumn<String> motherId = GeneratedColumn<String>(
      'mother_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fatherIdMeta =
      const VerificationMeta('fatherId');
  @override
  late final GeneratedColumn<String> fatherId = GeneratedColumn<String>(
      'father_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        code,
        name,
        species,
        breed,
        gender,
        birthDate,
        weight,
        status,
        reproductiveStatus,
        location,
        lastVaccination,
        pregnant,
        expectedDelivery,
        healthIssue,
        registrationNote,
        createdAt,
        updatedAt,
        nameColor,
        category,
        birthWeight,
        weight30Days,
        weight60Days,
        weight90Days,
        weight120Days,
        year,
        lote,
        motherId,
        fatherId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animals';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    } else if (isInserting) {
      context.missing(_breedMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('reproductive_status')) {
      context.handle(
          _reproductiveStatusMeta,
          reproductiveStatus.isAcceptableOrUnknown(
              data['reproductive_status']!, _reproductiveStatusMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('last_vaccination')) {
      context.handle(
          _lastVaccinationMeta,
          lastVaccination.isAcceptableOrUnknown(
              data['last_vaccination']!, _lastVaccinationMeta));
    }
    if (data.containsKey('pregnant')) {
      context.handle(_pregnantMeta,
          pregnant.isAcceptableOrUnknown(data['pregnant']!, _pregnantMeta));
    }
    if (data.containsKey('expected_delivery')) {
      context.handle(
          _expectedDeliveryMeta,
          expectedDelivery.isAcceptableOrUnknown(
              data['expected_delivery']!, _expectedDeliveryMeta));
    }
    if (data.containsKey('health_issue')) {
      context.handle(
          _healthIssueMeta,
          healthIssue.isAcceptableOrUnknown(
              data['health_issue']!, _healthIssueMeta));
    }
    if (data.containsKey('registration_note')) {
      context.handle(
          _registrationNoteMeta,
          registrationNote.isAcceptableOrUnknown(
              data['registration_note']!, _registrationNoteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('name_color')) {
      context.handle(_nameColorMeta,
          nameColor.isAcceptableOrUnknown(data['name_color']!, _nameColorMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('birth_weight')) {
      context.handle(
          _birthWeightMeta,
          birthWeight.isAcceptableOrUnknown(
              data['birth_weight']!, _birthWeightMeta));
    }
    if (data.containsKey('weight_30_days')) {
      context.handle(
          _weight30DaysMeta,
          weight30Days.isAcceptableOrUnknown(
              data['weight_30_days']!, _weight30DaysMeta));
    }
    if (data.containsKey('weight_60_days')) {
      context.handle(
          _weight60DaysMeta,
          weight60Days.isAcceptableOrUnknown(
              data['weight_60_days']!, _weight60DaysMeta));
    }
    if (data.containsKey('weight_90_days')) {
      context.handle(
          _weight90DaysMeta,
          weight90Days.isAcceptableOrUnknown(
              data['weight_90_days']!, _weight90DaysMeta));
    }
    if (data.containsKey('weight_120_days')) {
      context.handle(
          _weight120DaysMeta,
          weight120Days.isAcceptableOrUnknown(
              data['weight_120_days']!, _weight120DaysMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('lote')) {
      context.handle(
          _loteMeta, lote.isAcceptableOrUnknown(data['lote']!, _loteMeta));
    }
    if (data.containsKey('mother_id')) {
      context.handle(_motherIdMeta,
          motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta));
    }
    if (data.containsKey('father_id')) {
      context.handle(_fatherIdMeta,
          fatherId.isAcceptableOrUnknown(data['father_id']!, _fatherIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_date'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      reproductiveStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reproductive_status'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      lastVaccination: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_vaccination']),
      pregnant: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pregnant'])!,
      expectedDelivery: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}expected_delivery']),
      healthIssue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}health_issue']),
      registrationNote: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}registration_note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      nameColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_color']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      birthWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}birth_weight']),
      weight30Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_30_days']),
      weight60Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_60_days']),
      weight90Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_90_days']),
      weight120Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_120_days']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      lote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote']),
      motherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mother_id']),
      fatherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}father_id']),
    );
  }

  @override
  $AnimalsTable createAlias(String alias) {
    return $AnimalsTable(attachedDatabase, alias);
  }
}

class AnimalRow extends DataClass implements Insertable<AnimalRow> {
  final String id;

  /// Isolamento multi-tenant: UUID da fazenda dona deste registro.
  final String? farmId;
  final String code;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final String birthDate;
  final double weight;
  final String status;
  final String reproductiveStatus;
  final String location;
  final String? lastVaccination;
  final bool pregnant;
  final String? expectedDelivery;
  final String? healthIssue;
  final String? registrationNote;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? nameColor;
  final String? category;
  final double? birthWeight;
  final double? weight30Days;
  final double? weight60Days;
  final double? weight90Days;
  final double? weight120Days;
  final int? year;
  final String? lote;
  final String? motherId;
  final String? fatherId;
  const AnimalRow(
      {required this.id,
      this.farmId,
      required this.code,
      required this.name,
      required this.species,
      required this.breed,
      required this.gender,
      required this.birthDate,
      required this.weight,
      required this.status,
      required this.reproductiveStatus,
      required this.location,
      this.lastVaccination,
      required this.pregnant,
      this.expectedDelivery,
      this.healthIssue,
      this.registrationNote,
      required this.createdAt,
      required this.updatedAt,
      this.nameColor,
      this.category,
      this.birthWeight,
      this.weight30Days,
      this.weight60Days,
      this.weight90Days,
      this.weight120Days,
      this.year,
      this.lote,
      this.motherId,
      this.fatherId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['species'] = Variable<String>(species);
    map['breed'] = Variable<String>(breed);
    map['gender'] = Variable<String>(gender);
    map['birth_date'] = Variable<String>(birthDate);
    map['weight'] = Variable<double>(weight);
    map['status'] = Variable<String>(status);
    map['reproductive_status'] = Variable<String>(reproductiveStatus);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || lastVaccination != null) {
      map['last_vaccination'] = Variable<String>(lastVaccination);
    }
    map['pregnant'] = Variable<bool>(pregnant);
    if (!nullToAbsent || expectedDelivery != null) {
      map['expected_delivery'] = Variable<String>(expectedDelivery);
    }
    if (!nullToAbsent || healthIssue != null) {
      map['health_issue'] = Variable<String>(healthIssue);
    }
    if (!nullToAbsent || registrationNote != null) {
      map['registration_note'] = Variable<String>(registrationNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || nameColor != null) {
      map['name_color'] = Variable<String>(nameColor);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || birthWeight != null) {
      map['birth_weight'] = Variable<double>(birthWeight);
    }
    if (!nullToAbsent || weight30Days != null) {
      map['weight_30_days'] = Variable<double>(weight30Days);
    }
    if (!nullToAbsent || weight60Days != null) {
      map['weight_60_days'] = Variable<double>(weight60Days);
    }
    if (!nullToAbsent || weight90Days != null) {
      map['weight_90_days'] = Variable<double>(weight90Days);
    }
    if (!nullToAbsent || weight120Days != null) {
      map['weight_120_days'] = Variable<double>(weight120Days);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || lote != null) {
      map['lote'] = Variable<String>(lote);
    }
    if (!nullToAbsent || motherId != null) {
      map['mother_id'] = Variable<String>(motherId);
    }
    if (!nullToAbsent || fatherId != null) {
      map['father_id'] = Variable<String>(fatherId);
    }
    return map;
  }

  AnimalsCompanion toCompanion(bool nullToAbsent) {
    return AnimalsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      code: Value(code),
      name: Value(name),
      species: Value(species),
      breed: Value(breed),
      gender: Value(gender),
      birthDate: Value(birthDate),
      weight: Value(weight),
      status: Value(status),
      reproductiveStatus: Value(reproductiveStatus),
      location: Value(location),
      lastVaccination: lastVaccination == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVaccination),
      pregnant: Value(pregnant),
      expectedDelivery: expectedDelivery == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedDelivery),
      healthIssue: healthIssue == null && nullToAbsent
          ? const Value.absent()
          : Value(healthIssue),
      registrationNote: registrationNote == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNote),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      nameColor: nameColor == null && nullToAbsent
          ? const Value.absent()
          : Value(nameColor),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      birthWeight: birthWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(birthWeight),
      weight30Days: weight30Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight30Days),
      weight60Days: weight60Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight60Days),
      weight90Days: weight90Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight90Days),
      weight120Days: weight120Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight120Days),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      lote: lote == null && nullToAbsent ? const Value.absent() : Value(lote),
      motherId: motherId == null && nullToAbsent
          ? const Value.absent()
          : Value(motherId),
      fatherId: fatherId == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherId),
    );
  }

  factory AnimalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String>(json['breed']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<String>(json['birthDate']),
      weight: serializer.fromJson<double>(json['weight']),
      status: serializer.fromJson<String>(json['status']),
      reproductiveStatus:
          serializer.fromJson<String>(json['reproductiveStatus']),
      location: serializer.fromJson<String>(json['location']),
      lastVaccination: serializer.fromJson<String?>(json['lastVaccination']),
      pregnant: serializer.fromJson<bool>(json['pregnant']),
      expectedDelivery: serializer.fromJson<String?>(json['expectedDelivery']),
      healthIssue: serializer.fromJson<String?>(json['healthIssue']),
      registrationNote: serializer.fromJson<String?>(json['registrationNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      nameColor: serializer.fromJson<String?>(json['nameColor']),
      category: serializer.fromJson<String?>(json['category']),
      birthWeight: serializer.fromJson<double?>(json['birthWeight']),
      weight30Days: serializer.fromJson<double?>(json['weight30Days']),
      weight60Days: serializer.fromJson<double?>(json['weight60Days']),
      weight90Days: serializer.fromJson<double?>(json['weight90Days']),
      weight120Days: serializer.fromJson<double?>(json['weight120Days']),
      year: serializer.fromJson<int?>(json['year']),
      lote: serializer.fromJson<String?>(json['lote']),
      motherId: serializer.fromJson<String?>(json['motherId']),
      fatherId: serializer.fromJson<String?>(json['fatherId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String>(breed),
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<String>(birthDate),
      'weight': serializer.toJson<double>(weight),
      'status': serializer.toJson<String>(status),
      'reproductiveStatus': serializer.toJson<String>(reproductiveStatus),
      'location': serializer.toJson<String>(location),
      'lastVaccination': serializer.toJson<String?>(lastVaccination),
      'pregnant': serializer.toJson<bool>(pregnant),
      'expectedDelivery': serializer.toJson<String?>(expectedDelivery),
      'healthIssue': serializer.toJson<String?>(healthIssue),
      'registrationNote': serializer.toJson<String?>(registrationNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'nameColor': serializer.toJson<String?>(nameColor),
      'category': serializer.toJson<String?>(category),
      'birthWeight': serializer.toJson<double?>(birthWeight),
      'weight30Days': serializer.toJson<double?>(weight30Days),
      'weight60Days': serializer.toJson<double?>(weight60Days),
      'weight90Days': serializer.toJson<double?>(weight90Days),
      'weight120Days': serializer.toJson<double?>(weight120Days),
      'year': serializer.toJson<int?>(year),
      'lote': serializer.toJson<String?>(lote),
      'motherId': serializer.toJson<String?>(motherId),
      'fatherId': serializer.toJson<String?>(fatherId),
    };
  }

  AnimalRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? code,
          String? name,
          String? species,
          String? breed,
          String? gender,
          String? birthDate,
          double? weight,
          String? status,
          String? reproductiveStatus,
          String? location,
          Value<String?> lastVaccination = const Value.absent(),
          bool? pregnant,
          Value<String?> expectedDelivery = const Value.absent(),
          Value<String?> healthIssue = const Value.absent(),
          Value<String?> registrationNote = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<String?> nameColor = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<double?> birthWeight = const Value.absent(),
          Value<double?> weight30Days = const Value.absent(),
          Value<double?> weight60Days = const Value.absent(),
          Value<double?> weight90Days = const Value.absent(),
          Value<double?> weight120Days = const Value.absent(),
          Value<int?> year = const Value.absent(),
          Value<String?> lote = const Value.absent(),
          Value<String?> motherId = const Value.absent(),
          Value<String?> fatherId = const Value.absent()}) =>
      AnimalRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        code: code ?? this.code,
        name: name ?? this.name,
        species: species ?? this.species,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        weight: weight ?? this.weight,
        status: status ?? this.status,
        reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
        location: location ?? this.location,
        lastVaccination: lastVaccination.present
            ? lastVaccination.value
            : this.lastVaccination,
        pregnant: pregnant ?? this.pregnant,
        expectedDelivery: expectedDelivery.present
            ? expectedDelivery.value
            : this.expectedDelivery,
        healthIssue: healthIssue.present ? healthIssue.value : this.healthIssue,
        registrationNote: registrationNote.present
            ? registrationNote.value
            : this.registrationNote,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        nameColor: nameColor.present ? nameColor.value : this.nameColor,
        category: category.present ? category.value : this.category,
        birthWeight: birthWeight.present ? birthWeight.value : this.birthWeight,
        weight30Days:
            weight30Days.present ? weight30Days.value : this.weight30Days,
        weight60Days:
            weight60Days.present ? weight60Days.value : this.weight60Days,
        weight90Days:
            weight90Days.present ? weight90Days.value : this.weight90Days,
        weight120Days:
            weight120Days.present ? weight120Days.value : this.weight120Days,
        year: year.present ? year.value : this.year,
        lote: lote.present ? lote.value : this.lote,
        motherId: motherId.present ? motherId.value : this.motherId,
        fatherId: fatherId.present ? fatherId.value : this.fatherId,
      );
  AnimalRow copyWithCompanion(AnimalsCompanion data) {
    return AnimalRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      weight: data.weight.present ? data.weight.value : this.weight,
      status: data.status.present ? data.status.value : this.status,
      reproductiveStatus: data.reproductiveStatus.present
          ? data.reproductiveStatus.value
          : this.reproductiveStatus,
      location: data.location.present ? data.location.value : this.location,
      lastVaccination: data.lastVaccination.present
          ? data.lastVaccination.value
          : this.lastVaccination,
      pregnant: data.pregnant.present ? data.pregnant.value : this.pregnant,
      expectedDelivery: data.expectedDelivery.present
          ? data.expectedDelivery.value
          : this.expectedDelivery,
      healthIssue:
          data.healthIssue.present ? data.healthIssue.value : this.healthIssue,
      registrationNote: data.registrationNote.present
          ? data.registrationNote.value
          : this.registrationNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      nameColor: data.nameColor.present ? data.nameColor.value : this.nameColor,
      category: data.category.present ? data.category.value : this.category,
      birthWeight:
          data.birthWeight.present ? data.birthWeight.value : this.birthWeight,
      weight30Days: data.weight30Days.present
          ? data.weight30Days.value
          : this.weight30Days,
      weight60Days: data.weight60Days.present
          ? data.weight60Days.value
          : this.weight60Days,
      weight90Days: data.weight90Days.present
          ? data.weight90Days.value
          : this.weight90Days,
      weight120Days: data.weight120Days.present
          ? data.weight120Days.value
          : this.weight120Days,
      year: data.year.present ? data.year.value : this.year,
      lote: data.lote.present ? data.lote.value : this.lote,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      fatherId: data.fatherId.present ? data.fatherId.value : this.fatherId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('weight: $weight, ')
          ..write('status: $status, ')
          ..write('reproductiveStatus: $reproductiveStatus, ')
          ..write('location: $location, ')
          ..write('lastVaccination: $lastVaccination, ')
          ..write('pregnant: $pregnant, ')
          ..write('expectedDelivery: $expectedDelivery, ')
          ..write('healthIssue: $healthIssue, ')
          ..write('registrationNote: $registrationNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nameColor: $nameColor, ')
          ..write('category: $category, ')
          ..write('birthWeight: $birthWeight, ')
          ..write('weight30Days: $weight30Days, ')
          ..write('weight60Days: $weight60Days, ')
          ..write('weight90Days: $weight90Days, ')
          ..write('weight120Days: $weight120Days, ')
          ..write('year: $year, ')
          ..write('lote: $lote, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        farmId,
        code,
        name,
        species,
        breed,
        gender,
        birthDate,
        weight,
        status,
        reproductiveStatus,
        location,
        lastVaccination,
        pregnant,
        expectedDelivery,
        healthIssue,
        registrationNote,
        createdAt,
        updatedAt,
        nameColor,
        category,
        birthWeight,
        weight30Days,
        weight60Days,
        weight90Days,
        weight120Days,
        year,
        lote,
        motherId,
        fatherId
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.code == this.code &&
          other.name == this.name &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.weight == this.weight &&
          other.status == this.status &&
          other.reproductiveStatus == this.reproductiveStatus &&
          other.location == this.location &&
          other.lastVaccination == this.lastVaccination &&
          other.pregnant == this.pregnant &&
          other.expectedDelivery == this.expectedDelivery &&
          other.healthIssue == this.healthIssue &&
          other.registrationNote == this.registrationNote &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.nameColor == this.nameColor &&
          other.category == this.category &&
          other.birthWeight == this.birthWeight &&
          other.weight30Days == this.weight30Days &&
          other.weight60Days == this.weight60Days &&
          other.weight90Days == this.weight90Days &&
          other.weight120Days == this.weight120Days &&
          other.year == this.year &&
          other.lote == this.lote &&
          other.motherId == this.motherId &&
          other.fatherId == this.fatherId);
}

class AnimalsCompanion extends UpdateCompanion<AnimalRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> code;
  final Value<String> name;
  final Value<String> species;
  final Value<String> breed;
  final Value<String> gender;
  final Value<String> birthDate;
  final Value<double> weight;
  final Value<String> status;
  final Value<String> reproductiveStatus;
  final Value<String> location;
  final Value<String?> lastVaccination;
  final Value<bool> pregnant;
  final Value<String?> expectedDelivery;
  final Value<String?> healthIssue;
  final Value<String?> registrationNote;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> nameColor;
  final Value<String?> category;
  final Value<double?> birthWeight;
  final Value<double?> weight30Days;
  final Value<double?> weight60Days;
  final Value<double?> weight90Days;
  final Value<double?> weight120Days;
  final Value<int?> year;
  final Value<String?> lote;
  final Value<String?> motherId;
  final Value<String?> fatherId;
  final Value<int> rowid;
  const AnimalsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.weight = const Value.absent(),
    this.status = const Value.absent(),
    this.reproductiveStatus = const Value.absent(),
    this.location = const Value.absent(),
    this.lastVaccination = const Value.absent(),
    this.pregnant = const Value.absent(),
    this.expectedDelivery = const Value.absent(),
    this.healthIssue = const Value.absent(),
    this.registrationNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.nameColor = const Value.absent(),
    this.category = const Value.absent(),
    this.birthWeight = const Value.absent(),
    this.weight30Days = const Value.absent(),
    this.weight60Days = const Value.absent(),
    this.weight90Days = const Value.absent(),
    this.weight120Days = const Value.absent(),
    this.year = const Value.absent(),
    this.lote = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String code,
    required String name,
    required String species,
    required String breed,
    required String gender,
    required String birthDate,
    required double weight,
    this.status = const Value.absent(),
    this.reproductiveStatus = const Value.absent(),
    required String location,
    this.lastVaccination = const Value.absent(),
    this.pregnant = const Value.absent(),
    this.expectedDelivery = const Value.absent(),
    this.healthIssue = const Value.absent(),
    this.registrationNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.nameColor = const Value.absent(),
    this.category = const Value.absent(),
    this.birthWeight = const Value.absent(),
    this.weight30Days = const Value.absent(),
    this.weight60Days = const Value.absent(),
    this.weight90Days = const Value.absent(),
    this.weight120Days = const Value.absent(),
    this.year = const Value.absent(),
    this.lote = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        name = Value(name),
        species = Value(species),
        breed = Value(breed),
        gender = Value(gender),
        birthDate = Value(birthDate),
        weight = Value(weight),
        location = Value(location);
  static Insertable<AnimalRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? gender,
    Expression<String>? birthDate,
    Expression<double>? weight,
    Expression<String>? status,
    Expression<String>? reproductiveStatus,
    Expression<String>? location,
    Expression<String>? lastVaccination,
    Expression<bool>? pregnant,
    Expression<String>? expectedDelivery,
    Expression<String>? healthIssue,
    Expression<String>? registrationNote,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? nameColor,
    Expression<String>? category,
    Expression<double>? birthWeight,
    Expression<double>? weight30Days,
    Expression<double>? weight60Days,
    Expression<double>? weight90Days,
    Expression<double>? weight120Days,
    Expression<int>? year,
    Expression<String>? lote,
    Expression<String>? motherId,
    Expression<String>? fatherId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (weight != null) 'weight': weight,
      if (status != null) 'status': status,
      if (reproductiveStatus != null) 'reproductive_status': reproductiveStatus,
      if (location != null) 'location': location,
      if (lastVaccination != null) 'last_vaccination': lastVaccination,
      if (pregnant != null) 'pregnant': pregnant,
      if (expectedDelivery != null) 'expected_delivery': expectedDelivery,
      if (healthIssue != null) 'health_issue': healthIssue,
      if (registrationNote != null) 'registration_note': registrationNote,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (nameColor != null) 'name_color': nameColor,
      if (category != null) 'category': category,
      if (birthWeight != null) 'birth_weight': birthWeight,
      if (weight30Days != null) 'weight_30_days': weight30Days,
      if (weight60Days != null) 'weight_60_days': weight60Days,
      if (weight90Days != null) 'weight_90_days': weight90Days,
      if (weight120Days != null) 'weight_120_days': weight120Days,
      if (year != null) 'year': year,
      if (lote != null) 'lote': lote,
      if (motherId != null) 'mother_id': motherId,
      if (fatherId != null) 'father_id': fatherId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? code,
      Value<String>? name,
      Value<String>? species,
      Value<String>? breed,
      Value<String>? gender,
      Value<String>? birthDate,
      Value<double>? weight,
      Value<String>? status,
      Value<String>? reproductiveStatus,
      Value<String>? location,
      Value<String?>? lastVaccination,
      Value<bool>? pregnant,
      Value<String?>? expectedDelivery,
      Value<String?>? healthIssue,
      Value<String?>? registrationNote,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String?>? nameColor,
      Value<String?>? category,
      Value<double?>? birthWeight,
      Value<double?>? weight30Days,
      Value<double?>? weight60Days,
      Value<double?>? weight90Days,
      Value<double?>? weight120Days,
      Value<int?>? year,
      Value<String?>? lote,
      Value<String?>? motherId,
      Value<String?>? fatherId,
      Value<int>? rowid}) {
    return AnimalsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      code: code ?? this.code,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
      location: location ?? this.location,
      lastVaccination: lastVaccination ?? this.lastVaccination,
      pregnant: pregnant ?? this.pregnant,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      healthIssue: healthIssue ?? this.healthIssue,
      registrationNote: registrationNote ?? this.registrationNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nameColor: nameColor ?? this.nameColor,
      category: category ?? this.category,
      birthWeight: birthWeight ?? this.birthWeight,
      weight30Days: weight30Days ?? this.weight30Days,
      weight60Days: weight60Days ?? this.weight60Days,
      weight90Days: weight90Days ?? this.weight90Days,
      weight120Days: weight120Days ?? this.weight120Days,
      year: year ?? this.year,
      lote: lote ?? this.lote,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reproductiveStatus.present) {
      map['reproductive_status'] = Variable<String>(reproductiveStatus.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (lastVaccination.present) {
      map['last_vaccination'] = Variable<String>(lastVaccination.value);
    }
    if (pregnant.present) {
      map['pregnant'] = Variable<bool>(pregnant.value);
    }
    if (expectedDelivery.present) {
      map['expected_delivery'] = Variable<String>(expectedDelivery.value);
    }
    if (healthIssue.present) {
      map['health_issue'] = Variable<String>(healthIssue.value);
    }
    if (registrationNote.present) {
      map['registration_note'] = Variable<String>(registrationNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (nameColor.present) {
      map['name_color'] = Variable<String>(nameColor.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (birthWeight.present) {
      map['birth_weight'] = Variable<double>(birthWeight.value);
    }
    if (weight30Days.present) {
      map['weight_30_days'] = Variable<double>(weight30Days.value);
    }
    if (weight60Days.present) {
      map['weight_60_days'] = Variable<double>(weight60Days.value);
    }
    if (weight90Days.present) {
      map['weight_90_days'] = Variable<double>(weight90Days.value);
    }
    if (weight120Days.present) {
      map['weight_120_days'] = Variable<double>(weight120Days.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (lote.present) {
      map['lote'] = Variable<String>(lote.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<String>(motherId.value);
    }
    if (fatherId.present) {
      map['father_id'] = Variable<String>(fatherId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('weight: $weight, ')
          ..write('status: $status, ')
          ..write('reproductiveStatus: $reproductiveStatus, ')
          ..write('location: $location, ')
          ..write('lastVaccination: $lastVaccination, ')
          ..write('pregnant: $pregnant, ')
          ..write('expectedDelivery: $expectedDelivery, ')
          ..write('healthIssue: $healthIssue, ')
          ..write('registrationNote: $registrationNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nameColor: $nameColor, ')
          ..write('category: $category, ')
          ..write('birthWeight: $birthWeight, ')
          ..write('weight30Days: $weight30Days, ')
          ..write('weight60Days: $weight60Days, ')
          ..write('weight90Days: $weight90Days, ')
          ..write('weight120Days: $weight120Days, ')
          ..write('year: $year, ')
          ..write('lote: $lote, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalWeightsTable extends AnimalWeights
    with TableInfo<$AnimalWeightsTable, AnimalWeightRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _milestoneMeta =
      const VerificationMeta('milestone');
  @override
  late final GeneratedColumn<String> milestone = GeneratedColumn<String>(
      'milestone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, farmId, animalId, date, weight, milestone, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_weights';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalWeightRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('milestone')) {
      context.handle(_milestoneMeta,
          milestone.isAcceptableOrUnknown(data['milestone']!, _milestoneMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnimalWeightRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalWeightRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      milestone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}milestone']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AnimalWeightsTable createAlias(String alias) {
    return $AnimalWeightsTable(attachedDatabase, alias);
  }
}

class AnimalWeightRow extends DataClass implements Insertable<AnimalWeightRow> {
  final String id;
  final String? farmId;
  final String animalId;
  final String date;
  final double weight;
  final String? milestone;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AnimalWeightRow(
      {required this.id,
      this.farmId,
      required this.animalId,
      required this.date,
      required this.weight,
      this.milestone,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['animal_id'] = Variable<String>(animalId);
    map['date'] = Variable<String>(date);
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || milestone != null) {
      map['milestone'] = Variable<String>(milestone);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AnimalWeightsCompanion toCompanion(bool nullToAbsent) {
    return AnimalWeightsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      animalId: Value(animalId),
      date: Value(date),
      weight: Value(weight),
      milestone: milestone == null && nullToAbsent
          ? const Value.absent()
          : Value(milestone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnimalWeightRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalWeightRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      date: serializer.fromJson<String>(json['date']),
      weight: serializer.fromJson<double>(json['weight']),
      milestone: serializer.fromJson<String?>(json['milestone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'animalId': serializer.toJson<String>(animalId),
      'date': serializer.toJson<String>(date),
      'weight': serializer.toJson<double>(weight),
      'milestone': serializer.toJson<String?>(milestone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AnimalWeightRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? animalId,
          String? date,
          double? weight,
          Value<String?> milestone = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AnimalWeightRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        animalId: animalId ?? this.animalId,
        date: date ?? this.date,
        weight: weight ?? this.weight,
        milestone: milestone.present ? milestone.value : this.milestone,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AnimalWeightRow copyWithCompanion(AnimalWeightsCompanion data) {
    return AnimalWeightRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      date: data.date.present ? data.date.value : this.date,
      weight: data.weight.present ? data.weight.value : this.weight,
      milestone: data.milestone.present ? data.milestone.value : this.milestone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalWeightRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('milestone: $milestone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, farmId, animalId, date, weight, milestone, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalWeightRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.animalId == this.animalId &&
          other.date == this.date &&
          other.weight == this.weight &&
          other.milestone == this.milestone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AnimalWeightsCompanion extends UpdateCompanion<AnimalWeightRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> animalId;
  final Value<String> date;
  final Value<double> weight;
  final Value<String?> milestone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnimalWeightsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.date = const Value.absent(),
    this.weight = const Value.absent(),
    this.milestone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalWeightsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String animalId,
    required String date,
    required double weight,
    this.milestone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        date = Value(date),
        weight = Value(weight);
  static Insertable<AnimalWeightRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? animalId,
    Expression<String>? date,
    Expression<double>? weight,
    Expression<String>? milestone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (animalId != null) 'animal_id': animalId,
      if (date != null) 'date': date,
      if (weight != null) 'weight': weight,
      if (milestone != null) 'milestone': milestone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalWeightsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? animalId,
      Value<String>? date,
      Value<double>? weight,
      Value<String?>? milestone,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AnimalWeightsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      animalId: animalId ?? this.animalId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      milestone: milestone ?? this.milestone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (milestone.present) {
      map['milestone'] = Variable<String>(milestone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalWeightsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('date: $date, ')
          ..write('weight: $weight, ')
          ..write('milestone: $milestone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalLineageTable extends AnimalLineage
    with TableInfo<$AnimalLineageTable, AnimalLineageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalLineageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descendantIdMeta =
      const VerificationMeta('descendantId');
  @override
  late final GeneratedColumn<String> descendantId = GeneratedColumn<String>(
      'descendant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ancestorIdMeta =
      const VerificationMeta('ancestorId');
  @override
  late final GeneratedColumn<String> ancestorId = GeneratedColumn<String>(
      'ancestor_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<int> depth = GeneratedColumn<int>(
      'depth', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineTypeMeta =
      const VerificationMeta('lineType');
  @override
  late final GeneratedColumn<String> lineType = GeneratedColumn<String>(
      'line_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unknown'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [farmId, descendantId, ancestorId, depth, lineType, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_lineage';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalLineageRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('descendant_id')) {
      context.handle(
          _descendantIdMeta,
          descendantId.isAcceptableOrUnknown(
              data['descendant_id']!, _descendantIdMeta));
    } else if (isInserting) {
      context.missing(_descendantIdMeta);
    }
    if (data.containsKey('ancestor_id')) {
      context.handle(
          _ancestorIdMeta,
          ancestorId.isAcceptableOrUnknown(
              data['ancestor_id']!, _ancestorIdMeta));
    } else if (isInserting) {
      context.missing(_ancestorIdMeta);
    }
    if (data.containsKey('depth')) {
      context.handle(
          _depthMeta, depth.isAcceptableOrUnknown(data['depth']!, _depthMeta));
    } else if (isInserting) {
      context.missing(_depthMeta);
    }
    if (data.containsKey('line_type')) {
      context.handle(_lineTypeMeta,
          lineType.isAcceptableOrUnknown(data['line_type']!, _lineTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {descendantId, ancestorId};
  @override
  AnimalLineageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalLineageRow(
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      descendantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descendant_id'])!,
      ancestorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ancestor_id'])!,
      depth: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}depth'])!,
      lineType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AnimalLineageTable createAlias(String alias) {
    return $AnimalLineageTable(attachedDatabase, alias);
  }
}

class AnimalLineageRow extends DataClass
    implements Insertable<AnimalLineageRow> {
  final String? farmId;
  final String descendantId;
  final String ancestorId;
  final int depth;
  final String lineType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AnimalLineageRow(
      {this.farmId,
      required this.descendantId,
      required this.ancestorId,
      required this.depth,
      required this.lineType,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['descendant_id'] = Variable<String>(descendantId);
    map['ancestor_id'] = Variable<String>(ancestorId);
    map['depth'] = Variable<int>(depth);
    map['line_type'] = Variable<String>(lineType);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AnimalLineageCompanion toCompanion(bool nullToAbsent) {
    return AnimalLineageCompanion(
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      descendantId: Value(descendantId),
      ancestorId: Value(ancestorId),
      depth: Value(depth),
      lineType: Value(lineType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnimalLineageRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalLineageRow(
      farmId: serializer.fromJson<String?>(json['farmId']),
      descendantId: serializer.fromJson<String>(json['descendantId']),
      ancestorId: serializer.fromJson<String>(json['ancestorId']),
      depth: serializer.fromJson<int>(json['depth']),
      lineType: serializer.fromJson<String>(json['lineType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'farmId': serializer.toJson<String?>(farmId),
      'descendantId': serializer.toJson<String>(descendantId),
      'ancestorId': serializer.toJson<String>(ancestorId),
      'depth': serializer.toJson<int>(depth),
      'lineType': serializer.toJson<String>(lineType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AnimalLineageRow copyWith(
          {Value<String?> farmId = const Value.absent(),
          String? descendantId,
          String? ancestorId,
          int? depth,
          String? lineType,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AnimalLineageRow(
        farmId: farmId.present ? farmId.value : this.farmId,
        descendantId: descendantId ?? this.descendantId,
        ancestorId: ancestorId ?? this.ancestorId,
        depth: depth ?? this.depth,
        lineType: lineType ?? this.lineType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AnimalLineageRow copyWithCompanion(AnimalLineageCompanion data) {
    return AnimalLineageRow(
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      descendantId: data.descendantId.present
          ? data.descendantId.value
          : this.descendantId,
      ancestorId:
          data.ancestorId.present ? data.ancestorId.value : this.ancestorId,
      depth: data.depth.present ? data.depth.value : this.depth,
      lineType: data.lineType.present ? data.lineType.value : this.lineType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalLineageRow(')
          ..write('farmId: $farmId, ')
          ..write('descendantId: $descendantId, ')
          ..write('ancestorId: $ancestorId, ')
          ..write('depth: $depth, ')
          ..write('lineType: $lineType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      farmId, descendantId, ancestorId, depth, lineType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalLineageRow &&
          other.farmId == this.farmId &&
          other.descendantId == this.descendantId &&
          other.ancestorId == this.ancestorId &&
          other.depth == this.depth &&
          other.lineType == this.lineType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AnimalLineageCompanion extends UpdateCompanion<AnimalLineageRow> {
  final Value<String?> farmId;
  final Value<String> descendantId;
  final Value<String> ancestorId;
  final Value<int> depth;
  final Value<String> lineType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnimalLineageCompanion({
    this.farmId = const Value.absent(),
    this.descendantId = const Value.absent(),
    this.ancestorId = const Value.absent(),
    this.depth = const Value.absent(),
    this.lineType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalLineageCompanion.insert({
    this.farmId = const Value.absent(),
    required String descendantId,
    required String ancestorId,
    required int depth,
    this.lineType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : descendantId = Value(descendantId),
        ancestorId = Value(ancestorId),
        depth = Value(depth);
  static Insertable<AnimalLineageRow> custom({
    Expression<String>? farmId,
    Expression<String>? descendantId,
    Expression<String>? ancestorId,
    Expression<int>? depth,
    Expression<String>? lineType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (farmId != null) 'farm_id': farmId,
      if (descendantId != null) 'descendant_id': descendantId,
      if (ancestorId != null) 'ancestor_id': ancestorId,
      if (depth != null) 'depth': depth,
      if (lineType != null) 'line_type': lineType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalLineageCompanion copyWith(
      {Value<String?>? farmId,
      Value<String>? descendantId,
      Value<String>? ancestorId,
      Value<int>? depth,
      Value<String>? lineType,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AnimalLineageCompanion(
      farmId: farmId ?? this.farmId,
      descendantId: descendantId ?? this.descendantId,
      ancestorId: ancestorId ?? this.ancestorId,
      depth: depth ?? this.depth,
      lineType: lineType ?? this.lineType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (descendantId.present) {
      map['descendant_id'] = Variable<String>(descendantId.value);
    }
    if (ancestorId.present) {
      map['ancestor_id'] = Variable<String>(ancestorId.value);
    }
    if (depth.present) {
      map['depth'] = Variable<int>(depth.value);
    }
    if (lineType.present) {
      map['line_type'] = Variable<String>(lineType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalLineageCompanion(')
          ..write('farmId: $farmId, ')
          ..write('descendantId: $descendantId, ')
          ..write('ancestorId: $ancestorId, ')
          ..write('depth: $depth, ')
          ..write('lineType: $lineType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnimalLineageMetaTable extends AnimalLineageMeta
    with TableInfo<$AnimalLineageMetaTable, AnimalLineageMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalLineageMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metaKeyMeta =
      const VerificationMeta('metaKey');
  @override
  late final GeneratedColumn<String> metaKey = GeneratedColumn<String>(
      'meta_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metaValueMeta =
      const VerificationMeta('metaValue');
  @override
  late final GeneratedColumn<String> metaValue = GeneratedColumn<String>(
      'meta_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [farmId, metaKey, metaValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'animal_lineage_meta';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnimalLineageMetaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('meta_key')) {
      context.handle(_metaKeyMeta,
          metaKey.isAcceptableOrUnknown(data['meta_key']!, _metaKeyMeta));
    } else if (isInserting) {
      context.missing(_metaKeyMeta);
    }
    if (data.containsKey('meta_value')) {
      context.handle(_metaValueMeta,
          metaValue.isAcceptableOrUnknown(data['meta_value']!, _metaValueMeta));
    } else if (isInserting) {
      context.missing(_metaValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metaKey};
  @override
  AnimalLineageMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalLineageMetaRow(
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      metaKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meta_key'])!,
      metaValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meta_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AnimalLineageMetaTable createAlias(String alias) {
    return $AnimalLineageMetaTable(attachedDatabase, alias);
  }
}

class AnimalLineageMetaRow extends DataClass
    implements Insertable<AnimalLineageMetaRow> {
  final String? farmId;
  final String metaKey;
  final String metaValue;
  final DateTime updatedAt;
  const AnimalLineageMetaRow(
      {this.farmId,
      required this.metaKey,
      required this.metaValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['meta_key'] = Variable<String>(metaKey);
    map['meta_value'] = Variable<String>(metaValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AnimalLineageMetaCompanion toCompanion(bool nullToAbsent) {
    return AnimalLineageMetaCompanion(
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      metaKey: Value(metaKey),
      metaValue: Value(metaValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory AnimalLineageMetaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalLineageMetaRow(
      farmId: serializer.fromJson<String?>(json['farmId']),
      metaKey: serializer.fromJson<String>(json['metaKey']),
      metaValue: serializer.fromJson<String>(json['metaValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'farmId': serializer.toJson<String?>(farmId),
      'metaKey': serializer.toJson<String>(metaKey),
      'metaValue': serializer.toJson<String>(metaValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AnimalLineageMetaRow copyWith(
          {Value<String?> farmId = const Value.absent(),
          String? metaKey,
          String? metaValue,
          DateTime? updatedAt}) =>
      AnimalLineageMetaRow(
        farmId: farmId.present ? farmId.value : this.farmId,
        metaKey: metaKey ?? this.metaKey,
        metaValue: metaValue ?? this.metaValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AnimalLineageMetaRow copyWithCompanion(AnimalLineageMetaCompanion data) {
    return AnimalLineageMetaRow(
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      metaKey: data.metaKey.present ? data.metaKey.value : this.metaKey,
      metaValue: data.metaValue.present ? data.metaValue.value : this.metaValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalLineageMetaRow(')
          ..write('farmId: $farmId, ')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(farmId, metaKey, metaValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalLineageMetaRow &&
          other.farmId == this.farmId &&
          other.metaKey == this.metaKey &&
          other.metaValue == this.metaValue &&
          other.updatedAt == this.updatedAt);
}

class AnimalLineageMetaCompanion extends UpdateCompanion<AnimalLineageMetaRow> {
  final Value<String?> farmId;
  final Value<String> metaKey;
  final Value<String> metaValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AnimalLineageMetaCompanion({
    this.farmId = const Value.absent(),
    this.metaKey = const Value.absent(),
    this.metaValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalLineageMetaCompanion.insert({
    this.farmId = const Value.absent(),
    required String metaKey,
    required String metaValue,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : metaKey = Value(metaKey),
        metaValue = Value(metaValue);
  static Insertable<AnimalLineageMetaRow> custom({
    Expression<String>? farmId,
    Expression<String>? metaKey,
    Expression<String>? metaValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (farmId != null) 'farm_id': farmId,
      if (metaKey != null) 'meta_key': metaKey,
      if (metaValue != null) 'meta_value': metaValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalLineageMetaCompanion copyWith(
      {Value<String?>? farmId,
      Value<String>? metaKey,
      Value<String>? metaValue,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AnimalLineageMetaCompanion(
      farmId: farmId ?? this.farmId,
      metaKey: metaKey ?? this.metaKey,
      metaValue: metaValue ?? this.metaValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (metaKey.present) {
      map['meta_key'] = Variable<String>(metaKey.value);
    }
    if (metaValue.present) {
      map['meta_value'] = Variable<String>(metaValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalLineageMetaCompanion(')
          ..write('farmId: $farmId, ')
          ..write('metaKey: $metaKey, ')
          ..write('metaValue: $metaValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _settingKeyMeta =
      const VerificationMeta('settingKey');
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
      'setting_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _settingValueMeta =
      const VerificationMeta('settingValue');
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
      'setting_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [farmId, settingKey, settingValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('setting_key')) {
      context.handle(
          _settingKeyMeta,
          settingKey.isAcceptableOrUnknown(
              data['setting_key']!, _settingKeyMeta));
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
          _settingValueMeta,
          settingValue.isAcceptableOrUnknown(
              data['setting_value']!, _settingValueMeta));
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {farmId, settingKey};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      settingKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_key'])!,
      settingValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  /// Chave composta (farm_id + setting_key) para isolamento por fazenda.
  /// farm_id é nullable para manter compatibilidade com registros migrados
  /// que ainda não têm fazenda associada (ex.: configurações globais).
  final String? farmId;
  final String settingKey;
  final String settingValue;
  final DateTime updatedAt;
  const AppSettingRow(
      {this.farmId,
      required this.settingKey,
      required this.settingValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      farmId: serializer.fromJson<String?>(json['farmId']),
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'farmId': serializer.toJson<String?>(farmId),
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith(
          {Value<String?> farmId = const Value.absent(),
          String? settingKey,
          String? settingValue,
          DateTime? updatedAt}) =>
      AppSettingRow(
        farmId: farmId.present ? farmId.value : this.farmId,
        settingKey: settingKey ?? this.settingKey,
        settingValue: settingValue ?? this.settingValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      settingKey:
          data.settingKey.present ? data.settingKey.value : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('farmId: $farmId, ')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(farmId, settingKey, settingValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.farmId == this.farmId &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String?> farmId;
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.farmId = const Value.absent(),
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.farmId = const Value.absent(),
    required String settingKey,
    required String settingValue,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : settingKey = Value(settingKey),
        settingValue = Value(settingValue);
  static Insertable<AppSettingRow> custom({
    Expression<String>? farmId,
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (farmId != null) 'farm_id': farmId,
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String?>? farmId,
      Value<String>? settingKey,
      Value<String>? settingValue,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsCompanion(
      farmId: farmId ?? this.farmId,
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('farmId: $farmId, ')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BreedingRecordsTable extends BreedingRecords
    with TableInfo<$BreedingRecordsTable, BreedingRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BreedingRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _femaleAnimalIdMeta =
      const VerificationMeta('femaleAnimalId');
  @override
  late final GeneratedColumn<String> femaleAnimalId = GeneratedColumn<String>(
      'female_animal_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _maleAnimalIdMeta =
      const VerificationMeta('maleAnimalId');
  @override
  late final GeneratedColumn<String> maleAnimalId = GeneratedColumn<String>(
      'male_animal_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _breedingDateMeta =
      const VerificationMeta('breedingDate');
  @override
  late final GeneratedColumn<String> breedingDate = GeneratedColumn<String>(
      'breeding_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expectedBirthMeta =
      const VerificationMeta('expectedBirth');
  @override
  late final GeneratedColumn<String> expectedBirth = GeneratedColumn<String>(
      'expected_birth', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Cobertura'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _matingStartDateMeta =
      const VerificationMeta('matingStartDate');
  @override
  late final GeneratedColumn<String> matingStartDate = GeneratedColumn<String>(
      'mating_start_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _matingEndDateMeta =
      const VerificationMeta('matingEndDate');
  @override
  late final GeneratedColumn<String> matingEndDate = GeneratedColumn<String>(
      'mating_end_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _separationDateMeta =
      const VerificationMeta('separationDate');
  @override
  late final GeneratedColumn<String> separationDate = GeneratedColumn<String>(
      'separation_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ultrasoundDateMeta =
      const VerificationMeta('ultrasoundDate');
  @override
  late final GeneratedColumn<String> ultrasoundDate = GeneratedColumn<String>(
      'ultrasound_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ultrasoundResultMeta =
      const VerificationMeta('ultrasoundResult');
  @override
  late final GeneratedColumn<String> ultrasoundResult = GeneratedColumn<String>(
      'ultrasound_result', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
      'stage', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('encabritamento'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        femaleAnimalId,
        maleAnimalId,
        breedingDate,
        expectedBirth,
        status,
        notes,
        createdAt,
        updatedAt,
        matingStartDate,
        matingEndDate,
        separationDate,
        ultrasoundDate,
        ultrasoundResult,
        birthDate,
        stage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'breeding_records';
  @override
  VerificationContext validateIntegrity(Insertable<BreedingRecordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('female_animal_id')) {
      context.handle(
          _femaleAnimalIdMeta,
          femaleAnimalId.isAcceptableOrUnknown(
              data['female_animal_id']!, _femaleAnimalIdMeta));
    }
    if (data.containsKey('male_animal_id')) {
      context.handle(
          _maleAnimalIdMeta,
          maleAnimalId.isAcceptableOrUnknown(
              data['male_animal_id']!, _maleAnimalIdMeta));
    }
    if (data.containsKey('breeding_date')) {
      context.handle(
          _breedingDateMeta,
          breedingDate.isAcceptableOrUnknown(
              data['breeding_date']!, _breedingDateMeta));
    } else if (isInserting) {
      context.missing(_breedingDateMeta);
    }
    if (data.containsKey('expected_birth')) {
      context.handle(
          _expectedBirthMeta,
          expectedBirth.isAcceptableOrUnknown(
              data['expected_birth']!, _expectedBirthMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('mating_start_date')) {
      context.handle(
          _matingStartDateMeta,
          matingStartDate.isAcceptableOrUnknown(
              data['mating_start_date']!, _matingStartDateMeta));
    }
    if (data.containsKey('mating_end_date')) {
      context.handle(
          _matingEndDateMeta,
          matingEndDate.isAcceptableOrUnknown(
              data['mating_end_date']!, _matingEndDateMeta));
    }
    if (data.containsKey('separation_date')) {
      context.handle(
          _separationDateMeta,
          separationDate.isAcceptableOrUnknown(
              data['separation_date']!, _separationDateMeta));
    }
    if (data.containsKey('ultrasound_date')) {
      context.handle(
          _ultrasoundDateMeta,
          ultrasoundDate.isAcceptableOrUnknown(
              data['ultrasound_date']!, _ultrasoundDateMeta));
    }
    if (data.containsKey('ultrasound_result')) {
      context.handle(
          _ultrasoundResultMeta,
          ultrasoundResult.isAcceptableOrUnknown(
              data['ultrasound_result']!, _ultrasoundResultMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('stage')) {
      context.handle(
          _stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BreedingRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BreedingRecordRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      femaleAnimalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}female_animal_id']),
      maleAnimalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}male_animal_id']),
      breedingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breeding_date'])!,
      expectedBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expected_birth']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      matingStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}mating_start_date']),
      matingEndDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mating_end_date']),
      separationDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}separation_date']),
      ultrasoundDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ultrasound_date']),
      ultrasoundResult: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ultrasound_result']),
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_date']),
      stage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stage'])!,
    );
  }

  @override
  $BreedingRecordsTable createAlias(String alias) {
    return $BreedingRecordsTable(attachedDatabase, alias);
  }
}

class BreedingRecordRow extends DataClass
    implements Insertable<BreedingRecordRow> {
  final String id;
  final String? farmId;
  final String? femaleAnimalId;
  final String? maleAnimalId;
  final String breedingDate;
  final String? expectedBirth;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? matingStartDate;
  final String? matingEndDate;
  final String? separationDate;
  final String? ultrasoundDate;
  final String? ultrasoundResult;
  final String? birthDate;
  final String stage;
  const BreedingRecordRow(
      {required this.id,
      this.farmId,
      this.femaleAnimalId,
      this.maleAnimalId,
      required this.breedingDate,
      this.expectedBirth,
      required this.status,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.matingStartDate,
      this.matingEndDate,
      this.separationDate,
      this.ultrasoundDate,
      this.ultrasoundResult,
      this.birthDate,
      required this.stage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    if (!nullToAbsent || femaleAnimalId != null) {
      map['female_animal_id'] = Variable<String>(femaleAnimalId);
    }
    if (!nullToAbsent || maleAnimalId != null) {
      map['male_animal_id'] = Variable<String>(maleAnimalId);
    }
    map['breeding_date'] = Variable<String>(breedingDate);
    if (!nullToAbsent || expectedBirth != null) {
      map['expected_birth'] = Variable<String>(expectedBirth);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || matingStartDate != null) {
      map['mating_start_date'] = Variable<String>(matingStartDate);
    }
    if (!nullToAbsent || matingEndDate != null) {
      map['mating_end_date'] = Variable<String>(matingEndDate);
    }
    if (!nullToAbsent || separationDate != null) {
      map['separation_date'] = Variable<String>(separationDate);
    }
    if (!nullToAbsent || ultrasoundDate != null) {
      map['ultrasound_date'] = Variable<String>(ultrasoundDate);
    }
    if (!nullToAbsent || ultrasoundResult != null) {
      map['ultrasound_result'] = Variable<String>(ultrasoundResult);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    map['stage'] = Variable<String>(stage);
    return map;
  }

  BreedingRecordsCompanion toCompanion(bool nullToAbsent) {
    return BreedingRecordsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      femaleAnimalId: femaleAnimalId == null && nullToAbsent
          ? const Value.absent()
          : Value(femaleAnimalId),
      maleAnimalId: maleAnimalId == null && nullToAbsent
          ? const Value.absent()
          : Value(maleAnimalId),
      breedingDate: Value(breedingDate),
      expectedBirth: expectedBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedBirth),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      matingStartDate: matingStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(matingStartDate),
      matingEndDate: matingEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(matingEndDate),
      separationDate: separationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(separationDate),
      ultrasoundDate: ultrasoundDate == null && nullToAbsent
          ? const Value.absent()
          : Value(ultrasoundDate),
      ultrasoundResult: ultrasoundResult == null && nullToAbsent
          ? const Value.absent()
          : Value(ultrasoundResult),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      stage: Value(stage),
    );
  }

  factory BreedingRecordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BreedingRecordRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      femaleAnimalId: serializer.fromJson<String?>(json['femaleAnimalId']),
      maleAnimalId: serializer.fromJson<String?>(json['maleAnimalId']),
      breedingDate: serializer.fromJson<String>(json['breedingDate']),
      expectedBirth: serializer.fromJson<String?>(json['expectedBirth']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      matingStartDate: serializer.fromJson<String?>(json['matingStartDate']),
      matingEndDate: serializer.fromJson<String?>(json['matingEndDate']),
      separationDate: serializer.fromJson<String?>(json['separationDate']),
      ultrasoundDate: serializer.fromJson<String?>(json['ultrasoundDate']),
      ultrasoundResult: serializer.fromJson<String?>(json['ultrasoundResult']),
      birthDate: serializer.fromJson<String?>(json['birthDate']),
      stage: serializer.fromJson<String>(json['stage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'femaleAnimalId': serializer.toJson<String?>(femaleAnimalId),
      'maleAnimalId': serializer.toJson<String?>(maleAnimalId),
      'breedingDate': serializer.toJson<String>(breedingDate),
      'expectedBirth': serializer.toJson<String?>(expectedBirth),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'matingStartDate': serializer.toJson<String?>(matingStartDate),
      'matingEndDate': serializer.toJson<String?>(matingEndDate),
      'separationDate': serializer.toJson<String?>(separationDate),
      'ultrasoundDate': serializer.toJson<String?>(ultrasoundDate),
      'ultrasoundResult': serializer.toJson<String?>(ultrasoundResult),
      'birthDate': serializer.toJson<String?>(birthDate),
      'stage': serializer.toJson<String>(stage),
    };
  }

  BreedingRecordRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          Value<String?> femaleAnimalId = const Value.absent(),
          Value<String?> maleAnimalId = const Value.absent(),
          String? breedingDate,
          Value<String?> expectedBirth = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<String?> matingStartDate = const Value.absent(),
          Value<String?> matingEndDate = const Value.absent(),
          Value<String?> separationDate = const Value.absent(),
          Value<String?> ultrasoundDate = const Value.absent(),
          Value<String?> ultrasoundResult = const Value.absent(),
          Value<String?> birthDate = const Value.absent(),
          String? stage}) =>
      BreedingRecordRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        femaleAnimalId:
            femaleAnimalId.present ? femaleAnimalId.value : this.femaleAnimalId,
        maleAnimalId:
            maleAnimalId.present ? maleAnimalId.value : this.maleAnimalId,
        breedingDate: breedingDate ?? this.breedingDate,
        expectedBirth:
            expectedBirth.present ? expectedBirth.value : this.expectedBirth,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        matingStartDate: matingStartDate.present
            ? matingStartDate.value
            : this.matingStartDate,
        matingEndDate:
            matingEndDate.present ? matingEndDate.value : this.matingEndDate,
        separationDate:
            separationDate.present ? separationDate.value : this.separationDate,
        ultrasoundDate:
            ultrasoundDate.present ? ultrasoundDate.value : this.ultrasoundDate,
        ultrasoundResult: ultrasoundResult.present
            ? ultrasoundResult.value
            : this.ultrasoundResult,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        stage: stage ?? this.stage,
      );
  BreedingRecordRow copyWithCompanion(BreedingRecordsCompanion data) {
    return BreedingRecordRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      femaleAnimalId: data.femaleAnimalId.present
          ? data.femaleAnimalId.value
          : this.femaleAnimalId,
      maleAnimalId: data.maleAnimalId.present
          ? data.maleAnimalId.value
          : this.maleAnimalId,
      breedingDate: data.breedingDate.present
          ? data.breedingDate.value
          : this.breedingDate,
      expectedBirth: data.expectedBirth.present
          ? data.expectedBirth.value
          : this.expectedBirth,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      matingStartDate: data.matingStartDate.present
          ? data.matingStartDate.value
          : this.matingStartDate,
      matingEndDate: data.matingEndDate.present
          ? data.matingEndDate.value
          : this.matingEndDate,
      separationDate: data.separationDate.present
          ? data.separationDate.value
          : this.separationDate,
      ultrasoundDate: data.ultrasoundDate.present
          ? data.ultrasoundDate.value
          : this.ultrasoundDate,
      ultrasoundResult: data.ultrasoundResult.present
          ? data.ultrasoundResult.value
          : this.ultrasoundResult,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      stage: data.stage.present ? data.stage.value : this.stage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BreedingRecordRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('femaleAnimalId: $femaleAnimalId, ')
          ..write('maleAnimalId: $maleAnimalId, ')
          ..write('breedingDate: $breedingDate, ')
          ..write('expectedBirth: $expectedBirth, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('matingStartDate: $matingStartDate, ')
          ..write('matingEndDate: $matingEndDate, ')
          ..write('separationDate: $separationDate, ')
          ..write('ultrasoundDate: $ultrasoundDate, ')
          ..write('ultrasoundResult: $ultrasoundResult, ')
          ..write('birthDate: $birthDate, ')
          ..write('stage: $stage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      farmId,
      femaleAnimalId,
      maleAnimalId,
      breedingDate,
      expectedBirth,
      status,
      notes,
      createdAt,
      updatedAt,
      matingStartDate,
      matingEndDate,
      separationDate,
      ultrasoundDate,
      ultrasoundResult,
      birthDate,
      stage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BreedingRecordRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.femaleAnimalId == this.femaleAnimalId &&
          other.maleAnimalId == this.maleAnimalId &&
          other.breedingDate == this.breedingDate &&
          other.expectedBirth == this.expectedBirth &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.matingStartDate == this.matingStartDate &&
          other.matingEndDate == this.matingEndDate &&
          other.separationDate == this.separationDate &&
          other.ultrasoundDate == this.ultrasoundDate &&
          other.ultrasoundResult == this.ultrasoundResult &&
          other.birthDate == this.birthDate &&
          other.stage == this.stage);
}

class BreedingRecordsCompanion extends UpdateCompanion<BreedingRecordRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String?> femaleAnimalId;
  final Value<String?> maleAnimalId;
  final Value<String> breedingDate;
  final Value<String?> expectedBirth;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> matingStartDate;
  final Value<String?> matingEndDate;
  final Value<String?> separationDate;
  final Value<String?> ultrasoundDate;
  final Value<String?> ultrasoundResult;
  final Value<String?> birthDate;
  final Value<String> stage;
  final Value<int> rowid;
  const BreedingRecordsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.femaleAnimalId = const Value.absent(),
    this.maleAnimalId = const Value.absent(),
    this.breedingDate = const Value.absent(),
    this.expectedBirth = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.matingStartDate = const Value.absent(),
    this.matingEndDate = const Value.absent(),
    this.separationDate = const Value.absent(),
    this.ultrasoundDate = const Value.absent(),
    this.ultrasoundResult = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.stage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BreedingRecordsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    this.femaleAnimalId = const Value.absent(),
    this.maleAnimalId = const Value.absent(),
    required String breedingDate,
    this.expectedBirth = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.matingStartDate = const Value.absent(),
    this.matingEndDate = const Value.absent(),
    this.separationDate = const Value.absent(),
    this.ultrasoundDate = const Value.absent(),
    this.ultrasoundResult = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.stage = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        breedingDate = Value(breedingDate);
  static Insertable<BreedingRecordRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? femaleAnimalId,
    Expression<String>? maleAnimalId,
    Expression<String>? breedingDate,
    Expression<String>? expectedBirth,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? matingStartDate,
    Expression<String>? matingEndDate,
    Expression<String>? separationDate,
    Expression<String>? ultrasoundDate,
    Expression<String>? ultrasoundResult,
    Expression<String>? birthDate,
    Expression<String>? stage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (femaleAnimalId != null) 'female_animal_id': femaleAnimalId,
      if (maleAnimalId != null) 'male_animal_id': maleAnimalId,
      if (breedingDate != null) 'breeding_date': breedingDate,
      if (expectedBirth != null) 'expected_birth': expectedBirth,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (matingStartDate != null) 'mating_start_date': matingStartDate,
      if (matingEndDate != null) 'mating_end_date': matingEndDate,
      if (separationDate != null) 'separation_date': separationDate,
      if (ultrasoundDate != null) 'ultrasound_date': ultrasoundDate,
      if (ultrasoundResult != null) 'ultrasound_result': ultrasoundResult,
      if (birthDate != null) 'birth_date': birthDate,
      if (stage != null) 'stage': stage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BreedingRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String?>? femaleAnimalId,
      Value<String?>? maleAnimalId,
      Value<String>? breedingDate,
      Value<String?>? expectedBirth,
      Value<String>? status,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String?>? matingStartDate,
      Value<String?>? matingEndDate,
      Value<String?>? separationDate,
      Value<String?>? ultrasoundDate,
      Value<String?>? ultrasoundResult,
      Value<String?>? birthDate,
      Value<String>? stage,
      Value<int>? rowid}) {
    return BreedingRecordsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      femaleAnimalId: femaleAnimalId ?? this.femaleAnimalId,
      maleAnimalId: maleAnimalId ?? this.maleAnimalId,
      breedingDate: breedingDate ?? this.breedingDate,
      expectedBirth: expectedBirth ?? this.expectedBirth,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      matingStartDate: matingStartDate ?? this.matingStartDate,
      matingEndDate: matingEndDate ?? this.matingEndDate,
      separationDate: separationDate ?? this.separationDate,
      ultrasoundDate: ultrasoundDate ?? this.ultrasoundDate,
      ultrasoundResult: ultrasoundResult ?? this.ultrasoundResult,
      birthDate: birthDate ?? this.birthDate,
      stage: stage ?? this.stage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (femaleAnimalId.present) {
      map['female_animal_id'] = Variable<String>(femaleAnimalId.value);
    }
    if (maleAnimalId.present) {
      map['male_animal_id'] = Variable<String>(maleAnimalId.value);
    }
    if (breedingDate.present) {
      map['breeding_date'] = Variable<String>(breedingDate.value);
    }
    if (expectedBirth.present) {
      map['expected_birth'] = Variable<String>(expectedBirth.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (matingStartDate.present) {
      map['mating_start_date'] = Variable<String>(matingStartDate.value);
    }
    if (matingEndDate.present) {
      map['mating_end_date'] = Variable<String>(matingEndDate.value);
    }
    if (separationDate.present) {
      map['separation_date'] = Variable<String>(separationDate.value);
    }
    if (ultrasoundDate.present) {
      map['ultrasound_date'] = Variable<String>(ultrasoundDate.value);
    }
    if (ultrasoundResult.present) {
      map['ultrasound_result'] = Variable<String>(ultrasoundResult.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BreedingRecordsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('femaleAnimalId: $femaleAnimalId, ')
          ..write('maleAnimalId: $maleAnimalId, ')
          ..write('breedingDate: $breedingDate, ')
          ..write('expectedBirth: $expectedBirth, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('matingStartDate: $matingStartDate, ')
          ..write('matingEndDate: $matingEndDate, ')
          ..write('separationDate: $separationDate, ')
          ..write('ultrasoundDate: $ultrasoundDate, ')
          ..write('ultrasoundResult: $ultrasoundResult, ')
          ..write('birthDate: $birthDate, ')
          ..write('stage: $stage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatrixEvaluationsTable extends MatrixEvaluations
    with TableInfo<$MatrixEvaluationsTable, MatrixEvaluationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatrixEvaluationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _evaluationDateMeta =
      const VerificationMeta('evaluationDate');
  @override
  late final GeneratedColumn<String> evaluationDate = GeneratedColumn<String>(
      'evaluation_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fertilityScoreMeta =
      const VerificationMeta('fertilityScore');
  @override
  late final GeneratedColumn<double> fertilityScore = GeneratedColumn<double>(
      'fertility_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _maternalScoreMeta =
      const VerificationMeta('maternalScore');
  @override
  late final GeneratedColumn<double> maternalScore = GeneratedColumn<double>(
      'maternal_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _healthScoreMeta =
      const VerificationMeta('healthScore');
  @override
  late final GeneratedColumn<double> healthScore = GeneratedColumn<double>(
      'health_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _temperamentScoreMeta =
      const VerificationMeta('temperamentScore');
  @override
  late final GeneratedColumn<double> temperamentScore = GeneratedColumn<double>(
      'temperament_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _growthScoreMeta =
      const VerificationMeta('growthScore');
  @override
  late final GeneratedColumn<double> growthScore = GeneratedColumn<double>(
      'growth_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _hoofConditionMeta =
      const VerificationMeta('hoofCondition');
  @override
  late final GeneratedColumn<String> hoofCondition = GeneratedColumn<String>(
      'hoof_condition', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Sem problema'));
  static const VerificationMeta _verminosisLevelMeta =
      const VerificationMeta('verminosisLevel');
  @override
  late final GeneratedColumn<String> verminosisLevel = GeneratedColumn<String>(
      'verminosis_level', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Nenhuma'));
  static const VerificationMeta _twinningHistoryMeta =
      const VerificationMeta('twinningHistory');
  @override
  late final GeneratedColumn<String> twinningHistory = GeneratedColumn<String>(
      'twinning_history', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Sem histórico'));
  static const VerificationMeta _lambingWeightMeta =
      const VerificationMeta('lambingWeight');
  @override
  late final GeneratedColumn<double> lambingWeight = GeneratedColumn<double>(
      'lambing_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weaningWeightMeta =
      const VerificationMeta('weaningWeight');
  @override
  late final GeneratedColumn<double> weaningWeight = GeneratedColumn<double>(
      'weaning_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lactationScoreMeta =
      const VerificationMeta('lactationScore');
  @override
  late final GeneratedColumn<double> lactationScore = GeneratedColumn<double>(
      'lactation_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(7.0));
  static const VerificationMeta _bodyConditionScoreMeta =
      const VerificationMeta('bodyConditionScore');
  @override
  late final GeneratedColumn<double> bodyConditionScore =
      GeneratedColumn<double>('body_condition_score', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(3.0));
  static const VerificationMeta _dentitionScoreMeta =
      const VerificationMeta('dentitionScore');
  @override
  late final GeneratedColumn<double> dentitionScore = GeneratedColumn<double>(
      'dentition_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(7.0));
  static const VerificationMeta _ageMonthsMeta =
      const VerificationMeta('ageMonths');
  @override
  late final GeneratedColumn<int> ageMonths = GeneratedColumn<int>(
      'age_months', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _finalScoreMeta =
      const VerificationMeta('finalScore');
  @override
  late final GeneratedColumn<double> finalScore = GeneratedColumn<double>(
      'final_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _recommendationMeta =
      const VerificationMeta('recommendation');
  @override
  late final GeneratedColumn<String> recommendation = GeneratedColumn<String>(
      'recommendation', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Observação'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        animalId,
        evaluationDate,
        fertilityScore,
        maternalScore,
        healthScore,
        temperamentScore,
        growthScore,
        hoofCondition,
        verminosisLevel,
        twinningHistory,
        lambingWeight,
        weaningWeight,
        lactationScore,
        bodyConditionScore,
        dentitionScore,
        ageMonths,
        finalScore,
        recommendation,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matrix_evaluations';
  @override
  VerificationContext validateIntegrity(
      Insertable<MatrixEvaluationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('evaluation_date')) {
      context.handle(
          _evaluationDateMeta,
          evaluationDate.isAcceptableOrUnknown(
              data['evaluation_date']!, _evaluationDateMeta));
    } else if (isInserting) {
      context.missing(_evaluationDateMeta);
    }
    if (data.containsKey('fertility_score')) {
      context.handle(
          _fertilityScoreMeta,
          fertilityScore.isAcceptableOrUnknown(
              data['fertility_score']!, _fertilityScoreMeta));
    } else if (isInserting) {
      context.missing(_fertilityScoreMeta);
    }
    if (data.containsKey('maternal_score')) {
      context.handle(
          _maternalScoreMeta,
          maternalScore.isAcceptableOrUnknown(
              data['maternal_score']!, _maternalScoreMeta));
    } else if (isInserting) {
      context.missing(_maternalScoreMeta);
    }
    if (data.containsKey('health_score')) {
      context.handle(
          _healthScoreMeta,
          healthScore.isAcceptableOrUnknown(
              data['health_score']!, _healthScoreMeta));
    } else if (isInserting) {
      context.missing(_healthScoreMeta);
    }
    if (data.containsKey('temperament_score')) {
      context.handle(
          _temperamentScoreMeta,
          temperamentScore.isAcceptableOrUnknown(
              data['temperament_score']!, _temperamentScoreMeta));
    } else if (isInserting) {
      context.missing(_temperamentScoreMeta);
    }
    if (data.containsKey('growth_score')) {
      context.handle(
          _growthScoreMeta,
          growthScore.isAcceptableOrUnknown(
              data['growth_score']!, _growthScoreMeta));
    } else if (isInserting) {
      context.missing(_growthScoreMeta);
    }
    if (data.containsKey('hoof_condition')) {
      context.handle(
          _hoofConditionMeta,
          hoofCondition.isAcceptableOrUnknown(
              data['hoof_condition']!, _hoofConditionMeta));
    }
    if (data.containsKey('verminosis_level')) {
      context.handle(
          _verminosisLevelMeta,
          verminosisLevel.isAcceptableOrUnknown(
              data['verminosis_level']!, _verminosisLevelMeta));
    }
    if (data.containsKey('twinning_history')) {
      context.handle(
          _twinningHistoryMeta,
          twinningHistory.isAcceptableOrUnknown(
              data['twinning_history']!, _twinningHistoryMeta));
    }
    if (data.containsKey('lambing_weight')) {
      context.handle(
          _lambingWeightMeta,
          lambingWeight.isAcceptableOrUnknown(
              data['lambing_weight']!, _lambingWeightMeta));
    }
    if (data.containsKey('weaning_weight')) {
      context.handle(
          _weaningWeightMeta,
          weaningWeight.isAcceptableOrUnknown(
              data['weaning_weight']!, _weaningWeightMeta));
    }
    if (data.containsKey('lactation_score')) {
      context.handle(
          _lactationScoreMeta,
          lactationScore.isAcceptableOrUnknown(
              data['lactation_score']!, _lactationScoreMeta));
    }
    if (data.containsKey('body_condition_score')) {
      context.handle(
          _bodyConditionScoreMeta,
          bodyConditionScore.isAcceptableOrUnknown(
              data['body_condition_score']!, _bodyConditionScoreMeta));
    }
    if (data.containsKey('dentition_score')) {
      context.handle(
          _dentitionScoreMeta,
          dentitionScore.isAcceptableOrUnknown(
              data['dentition_score']!, _dentitionScoreMeta));
    }
    if (data.containsKey('age_months')) {
      context.handle(_ageMonthsMeta,
          ageMonths.isAcceptableOrUnknown(data['age_months']!, _ageMonthsMeta));
    }
    if (data.containsKey('final_score')) {
      context.handle(
          _finalScoreMeta,
          finalScore.isAcceptableOrUnknown(
              data['final_score']!, _finalScoreMeta));
    } else if (isInserting) {
      context.missing(_finalScoreMeta);
    }
    if (data.containsKey('recommendation')) {
      context.handle(
          _recommendationMeta,
          recommendation.isAcceptableOrUnknown(
              data['recommendation']!, _recommendationMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatrixEvaluationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatrixEvaluationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      evaluationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}evaluation_date'])!,
      fertilityScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}fertility_score'])!,
      maternalScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}maternal_score'])!,
      healthScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}health_score'])!,
      temperamentScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}temperament_score'])!,
      growthScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}growth_score'])!,
      hoofCondition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hoof_condition'])!,
      verminosisLevel: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}verminosis_level'])!,
      twinningHistory: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}twinning_history'])!,
      lambingWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lambing_weight']),
      weaningWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weaning_weight']),
      lactationScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}lactation_score'])!,
      bodyConditionScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}body_condition_score'])!,
      dentitionScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}dentition_score'])!,
      ageMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age_months']),
      finalScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}final_score'])!,
      recommendation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recommendation'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MatrixEvaluationsTable createAlias(String alias) {
    return $MatrixEvaluationsTable(attachedDatabase, alias);
  }
}

class MatrixEvaluationRow extends DataClass
    implements Insertable<MatrixEvaluationRow> {
  final String id;
  final String? farmId;
  final String animalId;
  final String evaluationDate;
  final double fertilityScore;
  final double maternalScore;
  final double healthScore;
  final double temperamentScore;
  final double growthScore;
  final String hoofCondition;
  final String verminosisLevel;
  final String twinningHistory;
  final double? lambingWeight;
  final double? weaningWeight;
  final double lactationScore;
  final double bodyConditionScore;
  final double dentitionScore;
  final int? ageMonths;
  final double finalScore;
  final String recommendation;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MatrixEvaluationRow(
      {required this.id,
      this.farmId,
      required this.animalId,
      required this.evaluationDate,
      required this.fertilityScore,
      required this.maternalScore,
      required this.healthScore,
      required this.temperamentScore,
      required this.growthScore,
      required this.hoofCondition,
      required this.verminosisLevel,
      required this.twinningHistory,
      this.lambingWeight,
      this.weaningWeight,
      required this.lactationScore,
      required this.bodyConditionScore,
      required this.dentitionScore,
      this.ageMonths,
      required this.finalScore,
      required this.recommendation,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['animal_id'] = Variable<String>(animalId);
    map['evaluation_date'] = Variable<String>(evaluationDate);
    map['fertility_score'] = Variable<double>(fertilityScore);
    map['maternal_score'] = Variable<double>(maternalScore);
    map['health_score'] = Variable<double>(healthScore);
    map['temperament_score'] = Variable<double>(temperamentScore);
    map['growth_score'] = Variable<double>(growthScore);
    map['hoof_condition'] = Variable<String>(hoofCondition);
    map['verminosis_level'] = Variable<String>(verminosisLevel);
    map['twinning_history'] = Variable<String>(twinningHistory);
    if (!nullToAbsent || lambingWeight != null) {
      map['lambing_weight'] = Variable<double>(lambingWeight);
    }
    if (!nullToAbsent || weaningWeight != null) {
      map['weaning_weight'] = Variable<double>(weaningWeight);
    }
    map['lactation_score'] = Variable<double>(lactationScore);
    map['body_condition_score'] = Variable<double>(bodyConditionScore);
    map['dentition_score'] = Variable<double>(dentitionScore);
    if (!nullToAbsent || ageMonths != null) {
      map['age_months'] = Variable<int>(ageMonths);
    }
    map['final_score'] = Variable<double>(finalScore);
    map['recommendation'] = Variable<String>(recommendation);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MatrixEvaluationsCompanion toCompanion(bool nullToAbsent) {
    return MatrixEvaluationsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      animalId: Value(animalId),
      evaluationDate: Value(evaluationDate),
      fertilityScore: Value(fertilityScore),
      maternalScore: Value(maternalScore),
      healthScore: Value(healthScore),
      temperamentScore: Value(temperamentScore),
      growthScore: Value(growthScore),
      hoofCondition: Value(hoofCondition),
      verminosisLevel: Value(verminosisLevel),
      twinningHistory: Value(twinningHistory),
      lambingWeight: lambingWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(lambingWeight),
      weaningWeight: weaningWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(weaningWeight),
      lactationScore: Value(lactationScore),
      bodyConditionScore: Value(bodyConditionScore),
      dentitionScore: Value(dentitionScore),
      ageMonths: ageMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(ageMonths),
      finalScore: Value(finalScore),
      recommendation: Value(recommendation),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MatrixEvaluationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatrixEvaluationRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      evaluationDate: serializer.fromJson<String>(json['evaluationDate']),
      fertilityScore: serializer.fromJson<double>(json['fertilityScore']),
      maternalScore: serializer.fromJson<double>(json['maternalScore']),
      healthScore: serializer.fromJson<double>(json['healthScore']),
      temperamentScore: serializer.fromJson<double>(json['temperamentScore']),
      growthScore: serializer.fromJson<double>(json['growthScore']),
      hoofCondition: serializer.fromJson<String>(json['hoofCondition']),
      verminosisLevel: serializer.fromJson<String>(json['verminosisLevel']),
      twinningHistory: serializer.fromJson<String>(json['twinningHistory']),
      lambingWeight: serializer.fromJson<double?>(json['lambingWeight']),
      weaningWeight: serializer.fromJson<double?>(json['weaningWeight']),
      lactationScore: serializer.fromJson<double>(json['lactationScore']),
      bodyConditionScore:
          serializer.fromJson<double>(json['bodyConditionScore']),
      dentitionScore: serializer.fromJson<double>(json['dentitionScore']),
      ageMonths: serializer.fromJson<int?>(json['ageMonths']),
      finalScore: serializer.fromJson<double>(json['finalScore']),
      recommendation: serializer.fromJson<String>(json['recommendation']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'animalId': serializer.toJson<String>(animalId),
      'evaluationDate': serializer.toJson<String>(evaluationDate),
      'fertilityScore': serializer.toJson<double>(fertilityScore),
      'maternalScore': serializer.toJson<double>(maternalScore),
      'healthScore': serializer.toJson<double>(healthScore),
      'temperamentScore': serializer.toJson<double>(temperamentScore),
      'growthScore': serializer.toJson<double>(growthScore),
      'hoofCondition': serializer.toJson<String>(hoofCondition),
      'verminosisLevel': serializer.toJson<String>(verminosisLevel),
      'twinningHistory': serializer.toJson<String>(twinningHistory),
      'lambingWeight': serializer.toJson<double?>(lambingWeight),
      'weaningWeight': serializer.toJson<double?>(weaningWeight),
      'lactationScore': serializer.toJson<double>(lactationScore),
      'bodyConditionScore': serializer.toJson<double>(bodyConditionScore),
      'dentitionScore': serializer.toJson<double>(dentitionScore),
      'ageMonths': serializer.toJson<int?>(ageMonths),
      'finalScore': serializer.toJson<double>(finalScore),
      'recommendation': serializer.toJson<String>(recommendation),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MatrixEvaluationRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? animalId,
          String? evaluationDate,
          double? fertilityScore,
          double? maternalScore,
          double? healthScore,
          double? temperamentScore,
          double? growthScore,
          String? hoofCondition,
          String? verminosisLevel,
          String? twinningHistory,
          Value<double?> lambingWeight = const Value.absent(),
          Value<double?> weaningWeight = const Value.absent(),
          double? lactationScore,
          double? bodyConditionScore,
          double? dentitionScore,
          Value<int?> ageMonths = const Value.absent(),
          double? finalScore,
          String? recommendation,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      MatrixEvaluationRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        animalId: animalId ?? this.animalId,
        evaluationDate: evaluationDate ?? this.evaluationDate,
        fertilityScore: fertilityScore ?? this.fertilityScore,
        maternalScore: maternalScore ?? this.maternalScore,
        healthScore: healthScore ?? this.healthScore,
        temperamentScore: temperamentScore ?? this.temperamentScore,
        growthScore: growthScore ?? this.growthScore,
        hoofCondition: hoofCondition ?? this.hoofCondition,
        verminosisLevel: verminosisLevel ?? this.verminosisLevel,
        twinningHistory: twinningHistory ?? this.twinningHistory,
        lambingWeight:
            lambingWeight.present ? lambingWeight.value : this.lambingWeight,
        weaningWeight:
            weaningWeight.present ? weaningWeight.value : this.weaningWeight,
        lactationScore: lactationScore ?? this.lactationScore,
        bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
        dentitionScore: dentitionScore ?? this.dentitionScore,
        ageMonths: ageMonths.present ? ageMonths.value : this.ageMonths,
        finalScore: finalScore ?? this.finalScore,
        recommendation: recommendation ?? this.recommendation,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MatrixEvaluationRow copyWithCompanion(MatrixEvaluationsCompanion data) {
    return MatrixEvaluationRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      evaluationDate: data.evaluationDate.present
          ? data.evaluationDate.value
          : this.evaluationDate,
      fertilityScore: data.fertilityScore.present
          ? data.fertilityScore.value
          : this.fertilityScore,
      maternalScore: data.maternalScore.present
          ? data.maternalScore.value
          : this.maternalScore,
      healthScore:
          data.healthScore.present ? data.healthScore.value : this.healthScore,
      temperamentScore: data.temperamentScore.present
          ? data.temperamentScore.value
          : this.temperamentScore,
      growthScore:
          data.growthScore.present ? data.growthScore.value : this.growthScore,
      hoofCondition: data.hoofCondition.present
          ? data.hoofCondition.value
          : this.hoofCondition,
      verminosisLevel: data.verminosisLevel.present
          ? data.verminosisLevel.value
          : this.verminosisLevel,
      twinningHistory: data.twinningHistory.present
          ? data.twinningHistory.value
          : this.twinningHistory,
      lambingWeight: data.lambingWeight.present
          ? data.lambingWeight.value
          : this.lambingWeight,
      weaningWeight: data.weaningWeight.present
          ? data.weaningWeight.value
          : this.weaningWeight,
      lactationScore: data.lactationScore.present
          ? data.lactationScore.value
          : this.lactationScore,
      bodyConditionScore: data.bodyConditionScore.present
          ? data.bodyConditionScore.value
          : this.bodyConditionScore,
      dentitionScore: data.dentitionScore.present
          ? data.dentitionScore.value
          : this.dentitionScore,
      ageMonths: data.ageMonths.present ? data.ageMonths.value : this.ageMonths,
      finalScore:
          data.finalScore.present ? data.finalScore.value : this.finalScore,
      recommendation: data.recommendation.present
          ? data.recommendation.value
          : this.recommendation,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatrixEvaluationRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('evaluationDate: $evaluationDate, ')
          ..write('fertilityScore: $fertilityScore, ')
          ..write('maternalScore: $maternalScore, ')
          ..write('healthScore: $healthScore, ')
          ..write('temperamentScore: $temperamentScore, ')
          ..write('growthScore: $growthScore, ')
          ..write('hoofCondition: $hoofCondition, ')
          ..write('verminosisLevel: $verminosisLevel, ')
          ..write('twinningHistory: $twinningHistory, ')
          ..write('lambingWeight: $lambingWeight, ')
          ..write('weaningWeight: $weaningWeight, ')
          ..write('lactationScore: $lactationScore, ')
          ..write('bodyConditionScore: $bodyConditionScore, ')
          ..write('dentitionScore: $dentitionScore, ')
          ..write('ageMonths: $ageMonths, ')
          ..write('finalScore: $finalScore, ')
          ..write('recommendation: $recommendation, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        farmId,
        animalId,
        evaluationDate,
        fertilityScore,
        maternalScore,
        healthScore,
        temperamentScore,
        growthScore,
        hoofCondition,
        verminosisLevel,
        twinningHistory,
        lambingWeight,
        weaningWeight,
        lactationScore,
        bodyConditionScore,
        dentitionScore,
        ageMonths,
        finalScore,
        recommendation,
        notes,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatrixEvaluationRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.animalId == this.animalId &&
          other.evaluationDate == this.evaluationDate &&
          other.fertilityScore == this.fertilityScore &&
          other.maternalScore == this.maternalScore &&
          other.healthScore == this.healthScore &&
          other.temperamentScore == this.temperamentScore &&
          other.growthScore == this.growthScore &&
          other.hoofCondition == this.hoofCondition &&
          other.verminosisLevel == this.verminosisLevel &&
          other.twinningHistory == this.twinningHistory &&
          other.lambingWeight == this.lambingWeight &&
          other.weaningWeight == this.weaningWeight &&
          other.lactationScore == this.lactationScore &&
          other.bodyConditionScore == this.bodyConditionScore &&
          other.dentitionScore == this.dentitionScore &&
          other.ageMonths == this.ageMonths &&
          other.finalScore == this.finalScore &&
          other.recommendation == this.recommendation &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MatrixEvaluationsCompanion extends UpdateCompanion<MatrixEvaluationRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> animalId;
  final Value<String> evaluationDate;
  final Value<double> fertilityScore;
  final Value<double> maternalScore;
  final Value<double> healthScore;
  final Value<double> temperamentScore;
  final Value<double> growthScore;
  final Value<String> hoofCondition;
  final Value<String> verminosisLevel;
  final Value<String> twinningHistory;
  final Value<double?> lambingWeight;
  final Value<double?> weaningWeight;
  final Value<double> lactationScore;
  final Value<double> bodyConditionScore;
  final Value<double> dentitionScore;
  final Value<int?> ageMonths;
  final Value<double> finalScore;
  final Value<String> recommendation;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MatrixEvaluationsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.evaluationDate = const Value.absent(),
    this.fertilityScore = const Value.absent(),
    this.maternalScore = const Value.absent(),
    this.healthScore = const Value.absent(),
    this.temperamentScore = const Value.absent(),
    this.growthScore = const Value.absent(),
    this.hoofCondition = const Value.absent(),
    this.verminosisLevel = const Value.absent(),
    this.twinningHistory = const Value.absent(),
    this.lambingWeight = const Value.absent(),
    this.weaningWeight = const Value.absent(),
    this.lactationScore = const Value.absent(),
    this.bodyConditionScore = const Value.absent(),
    this.dentitionScore = const Value.absent(),
    this.ageMonths = const Value.absent(),
    this.finalScore = const Value.absent(),
    this.recommendation = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatrixEvaluationsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String animalId,
    required String evaluationDate,
    required double fertilityScore,
    required double maternalScore,
    required double healthScore,
    required double temperamentScore,
    required double growthScore,
    this.hoofCondition = const Value.absent(),
    this.verminosisLevel = const Value.absent(),
    this.twinningHistory = const Value.absent(),
    this.lambingWeight = const Value.absent(),
    this.weaningWeight = const Value.absent(),
    this.lactationScore = const Value.absent(),
    this.bodyConditionScore = const Value.absent(),
    this.dentitionScore = const Value.absent(),
    this.ageMonths = const Value.absent(),
    required double finalScore,
    this.recommendation = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        evaluationDate = Value(evaluationDate),
        fertilityScore = Value(fertilityScore),
        maternalScore = Value(maternalScore),
        healthScore = Value(healthScore),
        temperamentScore = Value(temperamentScore),
        growthScore = Value(growthScore),
        finalScore = Value(finalScore);
  static Insertable<MatrixEvaluationRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? animalId,
    Expression<String>? evaluationDate,
    Expression<double>? fertilityScore,
    Expression<double>? maternalScore,
    Expression<double>? healthScore,
    Expression<double>? temperamentScore,
    Expression<double>? growthScore,
    Expression<String>? hoofCondition,
    Expression<String>? verminosisLevel,
    Expression<String>? twinningHistory,
    Expression<double>? lambingWeight,
    Expression<double>? weaningWeight,
    Expression<double>? lactationScore,
    Expression<double>? bodyConditionScore,
    Expression<double>? dentitionScore,
    Expression<int>? ageMonths,
    Expression<double>? finalScore,
    Expression<String>? recommendation,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (animalId != null) 'animal_id': animalId,
      if (evaluationDate != null) 'evaluation_date': evaluationDate,
      if (fertilityScore != null) 'fertility_score': fertilityScore,
      if (maternalScore != null) 'maternal_score': maternalScore,
      if (healthScore != null) 'health_score': healthScore,
      if (temperamentScore != null) 'temperament_score': temperamentScore,
      if (growthScore != null) 'growth_score': growthScore,
      if (hoofCondition != null) 'hoof_condition': hoofCondition,
      if (verminosisLevel != null) 'verminosis_level': verminosisLevel,
      if (twinningHistory != null) 'twinning_history': twinningHistory,
      if (lambingWeight != null) 'lambing_weight': lambingWeight,
      if (weaningWeight != null) 'weaning_weight': weaningWeight,
      if (lactationScore != null) 'lactation_score': lactationScore,
      if (bodyConditionScore != null)
        'body_condition_score': bodyConditionScore,
      if (dentitionScore != null) 'dentition_score': dentitionScore,
      if (ageMonths != null) 'age_months': ageMonths,
      if (finalScore != null) 'final_score': finalScore,
      if (recommendation != null) 'recommendation': recommendation,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatrixEvaluationsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? animalId,
      Value<String>? evaluationDate,
      Value<double>? fertilityScore,
      Value<double>? maternalScore,
      Value<double>? healthScore,
      Value<double>? temperamentScore,
      Value<double>? growthScore,
      Value<String>? hoofCondition,
      Value<String>? verminosisLevel,
      Value<String>? twinningHistory,
      Value<double?>? lambingWeight,
      Value<double?>? weaningWeight,
      Value<double>? lactationScore,
      Value<double>? bodyConditionScore,
      Value<double>? dentitionScore,
      Value<int?>? ageMonths,
      Value<double>? finalScore,
      Value<String>? recommendation,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MatrixEvaluationsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      animalId: animalId ?? this.animalId,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      fertilityScore: fertilityScore ?? this.fertilityScore,
      maternalScore: maternalScore ?? this.maternalScore,
      healthScore: healthScore ?? this.healthScore,
      temperamentScore: temperamentScore ?? this.temperamentScore,
      growthScore: growthScore ?? this.growthScore,
      hoofCondition: hoofCondition ?? this.hoofCondition,
      verminosisLevel: verminosisLevel ?? this.verminosisLevel,
      twinningHistory: twinningHistory ?? this.twinningHistory,
      lambingWeight: lambingWeight ?? this.lambingWeight,
      weaningWeight: weaningWeight ?? this.weaningWeight,
      lactationScore: lactationScore ?? this.lactationScore,
      bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
      dentitionScore: dentitionScore ?? this.dentitionScore,
      ageMonths: ageMonths ?? this.ageMonths,
      finalScore: finalScore ?? this.finalScore,
      recommendation: recommendation ?? this.recommendation,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (evaluationDate.present) {
      map['evaluation_date'] = Variable<String>(evaluationDate.value);
    }
    if (fertilityScore.present) {
      map['fertility_score'] = Variable<double>(fertilityScore.value);
    }
    if (maternalScore.present) {
      map['maternal_score'] = Variable<double>(maternalScore.value);
    }
    if (healthScore.present) {
      map['health_score'] = Variable<double>(healthScore.value);
    }
    if (temperamentScore.present) {
      map['temperament_score'] = Variable<double>(temperamentScore.value);
    }
    if (growthScore.present) {
      map['growth_score'] = Variable<double>(growthScore.value);
    }
    if (hoofCondition.present) {
      map['hoof_condition'] = Variable<String>(hoofCondition.value);
    }
    if (verminosisLevel.present) {
      map['verminosis_level'] = Variable<String>(verminosisLevel.value);
    }
    if (twinningHistory.present) {
      map['twinning_history'] = Variable<String>(twinningHistory.value);
    }
    if (lambingWeight.present) {
      map['lambing_weight'] = Variable<double>(lambingWeight.value);
    }
    if (weaningWeight.present) {
      map['weaning_weight'] = Variable<double>(weaningWeight.value);
    }
    if (lactationScore.present) {
      map['lactation_score'] = Variable<double>(lactationScore.value);
    }
    if (bodyConditionScore.present) {
      map['body_condition_score'] = Variable<double>(bodyConditionScore.value);
    }
    if (dentitionScore.present) {
      map['dentition_score'] = Variable<double>(dentitionScore.value);
    }
    if (ageMonths.present) {
      map['age_months'] = Variable<int>(ageMonths.value);
    }
    if (finalScore.present) {
      map['final_score'] = Variable<double>(finalScore.value);
    }
    if (recommendation.present) {
      map['recommendation'] = Variable<String>(recommendation.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatrixEvaluationsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('evaluationDate: $evaluationDate, ')
          ..write('fertilityScore: $fertilityScore, ')
          ..write('maternalScore: $maternalScore, ')
          ..write('healthScore: $healthScore, ')
          ..write('temperamentScore: $temperamentScore, ')
          ..write('growthScore: $growthScore, ')
          ..write('hoofCondition: $hoofCondition, ')
          ..write('verminosisLevel: $verminosisLevel, ')
          ..write('twinningHistory: $twinningHistory, ')
          ..write('lambingWeight: $lambingWeight, ')
          ..write('weaningWeight: $weaningWeight, ')
          ..write('lactationScore: $lactationScore, ')
          ..write('bodyConditionScore: $bodyConditionScore, ')
          ..write('dentitionScore: $dentitionScore, ')
          ..write('ageMonths: $ageMonths, ')
          ..write('finalScore: $finalScore, ')
          ..write('recommendation: $recommendation, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialAccountsTable extends FinancialAccounts
    with TableInfo<$FinancialAccountsTable, FinancialAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<String> paymentDate = GeneratedColumn<String>(
      'payment_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Pendente'));
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _installmentsMeta =
      const VerificationMeta('installments');
  @override
  late final GeneratedColumn<int> installments = GeneratedColumn<int>(
      'installments', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _installmentNumberMeta =
      const VerificationMeta('installmentNumber');
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
      'installment_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _supplierCustomerMeta =
      const VerificationMeta('supplierCustomer');
  @override
  late final GeneratedColumn<String> supplierCustomer = GeneratedColumn<String>(
      'supplier_customer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurrenceFrequencyMeta =
      const VerificationMeta('recurrenceFrequency');
  @override
  late final GeneratedColumn<String> recurrenceFrequency =
      GeneratedColumn<String>('recurrence_frequency', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurrenceEndDateMeta =
      const VerificationMeta('recurrenceEndDate');
  @override
  late final GeneratedColumn<String> recurrenceEndDate =
      GeneratedColumn<String>('recurrence_end_date', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        type,
        category,
        description,
        amount,
        dueDate,
        paymentDate,
        status,
        paymentMethod,
        installments,
        installmentNumber,
        parentId,
        animalId,
        supplierCustomer,
        notes,
        isRecurring,
        recurrenceFrequency,
        recurrenceEndDate,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_accounts';
  @override
  VerificationContext validateIntegrity(
      Insertable<FinancialAccountRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('installments')) {
      context.handle(
          _installmentsMeta,
          installments.isAcceptableOrUnknown(
              data['installments']!, _installmentsMeta));
    }
    if (data.containsKey('installment_number')) {
      context.handle(
          _installmentNumberMeta,
          installmentNumber.isAcceptableOrUnknown(
              data['installment_number']!, _installmentNumberMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    }
    if (data.containsKey('supplier_customer')) {
      context.handle(
          _supplierCustomerMeta,
          supplierCustomer.isAcceptableOrUnknown(
              data['supplier_customer']!, _supplierCustomerMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurrence_frequency')) {
      context.handle(
          _recurrenceFrequencyMeta,
          recurrenceFrequency.isAcceptableOrUnknown(
              data['recurrence_frequency']!, _recurrenceFrequencyMeta));
    }
    if (data.containsKey('recurrence_end_date')) {
      context.handle(
          _recurrenceEndDateMeta,
          recurrenceEndDate.isAcceptableOrUnknown(
              data['recurrence_end_date']!, _recurrenceEndDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialAccountRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date'])!,
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_date']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method']),
      installments: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}installments']),
      installmentNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}installment_number']),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id']),
      supplierCustomer: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}supplier_customer']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurrenceFrequency: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurrence_frequency']),
      recurrenceEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurrence_end_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FinancialAccountsTable createAlias(String alias) {
    return $FinancialAccountsTable(attachedDatabase, alias);
  }
}

class FinancialAccountRow extends DataClass
    implements Insertable<FinancialAccountRow> {
  final String id;
  final String? farmId;
  final String type;
  final String category;
  final String? description;
  final double amount;
  final String dueDate;
  final String? paymentDate;
  final String status;
  final String? paymentMethod;
  final int? installments;
  final int? installmentNumber;
  final String? parentId;
  final String? animalId;
  final String? supplierCustomer;
  final String? notes;
  final bool isRecurring;
  final String? recurrenceFrequency;
  final String? recurrenceEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FinancialAccountRow(
      {required this.id,
      this.farmId,
      required this.type,
      required this.category,
      this.description,
      required this.amount,
      required this.dueDate,
      this.paymentDate,
      required this.status,
      this.paymentMethod,
      this.installments,
      this.installmentNumber,
      this.parentId,
      this.animalId,
      this.supplierCustomer,
      this.notes,
      required this.isRecurring,
      this.recurrenceFrequency,
      this.recurrenceEndDate,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['amount'] = Variable<double>(amount);
    map['due_date'] = Variable<String>(dueDate);
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<String>(paymentDate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || installments != null) {
      map['installments'] = Variable<int>(installments);
    }
    if (!nullToAbsent || installmentNumber != null) {
      map['installment_number'] = Variable<int>(installmentNumber);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || animalId != null) {
      map['animal_id'] = Variable<String>(animalId);
    }
    if (!nullToAbsent || supplierCustomer != null) {
      map['supplier_customer'] = Variable<String>(supplierCustomer);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurrenceFrequency != null) {
      map['recurrence_frequency'] = Variable<String>(recurrenceFrequency);
    }
    if (!nullToAbsent || recurrenceEndDate != null) {
      map['recurrence_end_date'] = Variable<String>(recurrenceEndDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FinancialAccountsCompanion toCompanion(bool nullToAbsent) {
    return FinancialAccountsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      type: Value(type),
      category: Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      amount: Value(amount),
      dueDate: Value(dueDate),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      status: Value(status),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      installments: installments == null && nullToAbsent
          ? const Value.absent()
          : Value(installments),
      installmentNumber: installmentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentNumber),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      animalId: animalId == null && nullToAbsent
          ? const Value.absent()
          : Value(animalId),
      supplierCustomer: supplierCustomer == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierCustomer),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isRecurring: Value(isRecurring),
      recurrenceFrequency: recurrenceFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceFrequency),
      recurrenceEndDate: recurrenceEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceEndDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FinancialAccountRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialAccountRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      paymentDate: serializer.fromJson<String?>(json['paymentDate']),
      status: serializer.fromJson<String>(json['status']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      installments: serializer.fromJson<int?>(json['installments']),
      installmentNumber: serializer.fromJson<int?>(json['installmentNumber']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      animalId: serializer.fromJson<String?>(json['animalId']),
      supplierCustomer: serializer.fromJson<String?>(json['supplierCustomer']),
      notes: serializer.fromJson<String?>(json['notes']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurrenceFrequency:
          serializer.fromJson<String?>(json['recurrenceFrequency']),
      recurrenceEndDate:
          serializer.fromJson<String?>(json['recurrenceEndDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String?>(description),
      'amount': serializer.toJson<double>(amount),
      'dueDate': serializer.toJson<String>(dueDate),
      'paymentDate': serializer.toJson<String?>(paymentDate),
      'status': serializer.toJson<String>(status),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'installments': serializer.toJson<int?>(installments),
      'installmentNumber': serializer.toJson<int?>(installmentNumber),
      'parentId': serializer.toJson<String?>(parentId),
      'animalId': serializer.toJson<String?>(animalId),
      'supplierCustomer': serializer.toJson<String?>(supplierCustomer),
      'notes': serializer.toJson<String?>(notes),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurrenceFrequency': serializer.toJson<String?>(recurrenceFrequency),
      'recurrenceEndDate': serializer.toJson<String?>(recurrenceEndDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FinancialAccountRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? type,
          String? category,
          Value<String?> description = const Value.absent(),
          double? amount,
          String? dueDate,
          Value<String?> paymentDate = const Value.absent(),
          String? status,
          Value<String?> paymentMethod = const Value.absent(),
          Value<int?> installments = const Value.absent(),
          Value<int?> installmentNumber = const Value.absent(),
          Value<String?> parentId = const Value.absent(),
          Value<String?> animalId = const Value.absent(),
          Value<String?> supplierCustomer = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? isRecurring,
          Value<String?> recurrenceFrequency = const Value.absent(),
          Value<String?> recurrenceEndDate = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FinancialAccountRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        type: type ?? this.type,
        category: category ?? this.category,
        description: description.present ? description.value : this.description,
        amount: amount ?? this.amount,
        dueDate: dueDate ?? this.dueDate,
        paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
        status: status ?? this.status,
        paymentMethod:
            paymentMethod.present ? paymentMethod.value : this.paymentMethod,
        installments:
            installments.present ? installments.value : this.installments,
        installmentNumber: installmentNumber.present
            ? installmentNumber.value
            : this.installmentNumber,
        parentId: parentId.present ? parentId.value : this.parentId,
        animalId: animalId.present ? animalId.value : this.animalId,
        supplierCustomer: supplierCustomer.present
            ? supplierCustomer.value
            : this.supplierCustomer,
        notes: notes.present ? notes.value : this.notes,
        isRecurring: isRecurring ?? this.isRecurring,
        recurrenceFrequency: recurrenceFrequency.present
            ? recurrenceFrequency.value
            : this.recurrenceFrequency,
        recurrenceEndDate: recurrenceEndDate.present
            ? recurrenceEndDate.value
            : this.recurrenceEndDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FinancialAccountRow copyWithCompanion(FinancialAccountsCompanion data) {
    return FinancialAccountRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      status: data.status.present ? data.status.value : this.status,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      installments: data.installments.present
          ? data.installments.value
          : this.installments,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      supplierCustomer: data.supplierCustomer.present
          ? data.supplierCustomer.value
          : this.supplierCustomer,
      notes: data.notes.present ? data.notes.value : this.notes,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurrenceFrequency: data.recurrenceFrequency.present
          ? data.recurrenceFrequency.value
          : this.recurrenceFrequency,
      recurrenceEndDate: data.recurrenceEndDate.present
          ? data.recurrenceEndDate.value
          : this.recurrenceEndDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialAccountRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('status: $status, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('installments: $installments, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('parentId: $parentId, ')
          ..write('animalId: $animalId, ')
          ..write('supplierCustomer: $supplierCustomer, ')
          ..write('notes: $notes, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceFrequency: $recurrenceFrequency, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        farmId,
        type,
        category,
        description,
        amount,
        dueDate,
        paymentDate,
        status,
        paymentMethod,
        installments,
        installmentNumber,
        parentId,
        animalId,
        supplierCustomer,
        notes,
        isRecurring,
        recurrenceFrequency,
        recurrenceEndDate,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialAccountRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.type == this.type &&
          other.category == this.category &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.dueDate == this.dueDate &&
          other.paymentDate == this.paymentDate &&
          other.status == this.status &&
          other.paymentMethod == this.paymentMethod &&
          other.installments == this.installments &&
          other.installmentNumber == this.installmentNumber &&
          other.parentId == this.parentId &&
          other.animalId == this.animalId &&
          other.supplierCustomer == this.supplierCustomer &&
          other.notes == this.notes &&
          other.isRecurring == this.isRecurring &&
          other.recurrenceFrequency == this.recurrenceFrequency &&
          other.recurrenceEndDate == this.recurrenceEndDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FinancialAccountsCompanion extends UpdateCompanion<FinancialAccountRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> type;
  final Value<String> category;
  final Value<String?> description;
  final Value<double> amount;
  final Value<String> dueDate;
  final Value<String?> paymentDate;
  final Value<String> status;
  final Value<String?> paymentMethod;
  final Value<int?> installments;
  final Value<int?> installmentNumber;
  final Value<String?> parentId;
  final Value<String?> animalId;
  final Value<String?> supplierCustomer;
  final Value<String?> notes;
  final Value<bool> isRecurring;
  final Value<String?> recurrenceFrequency;
  final Value<String?> recurrenceEndDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FinancialAccountsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.status = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.installments = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.parentId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.supplierCustomer = const Value.absent(),
    this.notes = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceFrequency = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialAccountsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String type,
    required String category,
    this.description = const Value.absent(),
    required double amount,
    required String dueDate,
    this.paymentDate = const Value.absent(),
    this.status = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.installments = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.parentId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.supplierCustomer = const Value.absent(),
    this.notes = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurrenceFrequency = const Value.absent(),
    this.recurrenceEndDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        category = Value(category),
        amount = Value(amount),
        dueDate = Value(dueDate);
  static Insertable<FinancialAccountRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? dueDate,
    Expression<String>? paymentDate,
    Expression<String>? status,
    Expression<String>? paymentMethod,
    Expression<int>? installments,
    Expression<int>? installmentNumber,
    Expression<String>? parentId,
    Expression<String>? animalId,
    Expression<String>? supplierCustomer,
    Expression<String>? notes,
    Expression<bool>? isRecurring,
    Expression<String>? recurrenceFrequency,
    Expression<String>? recurrenceEndDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (dueDate != null) 'due_date': dueDate,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (status != null) 'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (installments != null) 'installments': installments,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (parentId != null) 'parent_id': parentId,
      if (animalId != null) 'animal_id': animalId,
      if (supplierCustomer != null) 'supplier_customer': supplierCustomer,
      if (notes != null) 'notes': notes,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurrenceFrequency != null)
        'recurrence_frequency': recurrenceFrequency,
      if (recurrenceEndDate != null) 'recurrence_end_date': recurrenceEndDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialAccountsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? type,
      Value<String>? category,
      Value<String?>? description,
      Value<double>? amount,
      Value<String>? dueDate,
      Value<String?>? paymentDate,
      Value<String>? status,
      Value<String?>? paymentMethod,
      Value<int?>? installments,
      Value<int?>? installmentNumber,
      Value<String?>? parentId,
      Value<String?>? animalId,
      Value<String?>? supplierCustomer,
      Value<String?>? notes,
      Value<bool>? isRecurring,
      Value<String?>? recurrenceFrequency,
      Value<String?>? recurrenceEndDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FinancialAccountsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      installments: installments ?? this.installments,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      parentId: parentId ?? this.parentId,
      animalId: animalId ?? this.animalId,
      supplierCustomer: supplierCustomer ?? this.supplierCustomer,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<String>(paymentDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (installments.present) {
      map['installments'] = Variable<int>(installments.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (supplierCustomer.present) {
      map['supplier_customer'] = Variable<String>(supplierCustomer.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurrenceFrequency.present) {
      map['recurrence_frequency'] = Variable<String>(recurrenceFrequency.value);
    }
    if (recurrenceEndDate.present) {
      map['recurrence_end_date'] = Variable<String>(recurrenceEndDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialAccountsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('dueDate: $dueDate, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('status: $status, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('installments: $installments, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('parentId: $parentId, ')
          ..write('animalId: $animalId, ')
          ..write('supplierCustomer: $supplierCustomer, ')
          ..write('notes: $notes, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurrenceFrequency: $recurrenceFrequency, ')
          ..write('recurrenceEndDate: $recurrenceEndDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialRecordsTable extends FinancialRecords
    with TableInfo<$FinancialRecordsTable, FinancialRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        type,
        category,
        description,
        amount,
        date,
        animalId,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_records';
  @override
  VerificationContext validateIntegrity(Insertable<FinancialRecordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialRecordRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FinancialRecordsTable createAlias(String alias) {
    return $FinancialRecordsTable(attachedDatabase, alias);
  }
}

class FinancialRecordRow extends DataClass
    implements Insertable<FinancialRecordRow> {
  final String id;
  final String? farmId;
  final String type;
  final String category;
  final String? description;
  final double amount;
  final String date;
  final String? animalId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FinancialRecordRow(
      {required this.id,
      this.farmId,
      required this.type,
      required this.category,
      this.description,
      required this.amount,
      required this.date,
      this.animalId,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || animalId != null) {
      map['animal_id'] = Variable<String>(animalId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FinancialRecordsCompanion toCompanion(bool nullToAbsent) {
    return FinancialRecordsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      type: Value(type),
      category: Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      amount: Value(amount),
      date: Value(date),
      animalId: animalId == null && nullToAbsent
          ? const Value.absent()
          : Value(animalId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FinancialRecordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialRecordRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<String>(json['date']),
      animalId: serializer.fromJson<String?>(json['animalId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String?>(description),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<String>(date),
      'animalId': serializer.toJson<String?>(animalId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FinancialRecordRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? type,
          String? category,
          Value<String?> description = const Value.absent(),
          double? amount,
          String? date,
          Value<String?> animalId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FinancialRecordRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        type: type ?? this.type,
        category: category ?? this.category,
        description: description.present ? description.value : this.description,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        animalId: animalId.present ? animalId.value : this.animalId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FinancialRecordRow copyWithCompanion(FinancialRecordsCompanion data) {
    return FinancialRecordRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialRecordRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('animalId: $animalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, type, category, description,
      amount, date, animalId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialRecordRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.type == this.type &&
          other.category == this.category &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.animalId == this.animalId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FinancialRecordsCompanion extends UpdateCompanion<FinancialRecordRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> type;
  final Value<String> category;
  final Value<String?> description;
  final Value<double> amount;
  final Value<String> date;
  final Value<String?> animalId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FinancialRecordsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.animalId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialRecordsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String type,
    required String category,
    this.description = const Value.absent(),
    required double amount,
    required String date,
    this.animalId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        category = Value(category),
        amount = Value(amount),
        date = Value(date);
  static Insertable<FinancialRecordRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? date,
    Expression<String>? animalId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (animalId != null) 'animal_id': animalId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? type,
      Value<String>? category,
      Value<String?>? description,
      Value<double>? amount,
      Value<String>? date,
      Value<String?>? animalId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FinancialRecordsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      animalId: animalId ?? this.animalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialRecordsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('animalId: $animalId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PharmacyStockTable extends PharmacyStock
    with TableInfo<$PharmacyStockTable, PharmacyStockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PharmacyStockTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _medicationNameMeta =
      const VerificationMeta('medicationName');
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
      'medication_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medicationTypeMeta =
      const VerificationMeta('medicationType');
  @override
  late final GeneratedColumn<String> medicationType = GeneratedColumn<String>(
      'medication_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitOfMeasureMeta =
      const VerificationMeta('unitOfMeasure');
  @override
  late final GeneratedColumn<String> unitOfMeasure = GeneratedColumn<String>(
      'unit_of_measure', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityPerUnitMeta =
      const VerificationMeta('quantityPerUnit');
  @override
  late final GeneratedColumn<double> quantityPerUnit = GeneratedColumn<double>(
      'quantity_per_unit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalQuantityMeta =
      const VerificationMeta('totalQuantity');
  @override
  late final GeneratedColumn<double> totalQuantity = GeneratedColumn<double>(
      'total_quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _minStockAlertMeta =
      const VerificationMeta('minStockAlert');
  @override
  late final GeneratedColumn<double> minStockAlert = GeneratedColumn<double>(
      'min_stock_alert', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _expirationDateMeta =
      const VerificationMeta('expirationDate');
  @override
  late final GeneratedColumn<String> expirationDate = GeneratedColumn<String>(
      'expiration_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isOpenedMeta =
      const VerificationMeta('isOpened');
  @override
  late final GeneratedColumn<bool> isOpened = GeneratedColumn<bool>(
      'is_opened', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_opened" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _openedQuantityMeta =
      const VerificationMeta('openedQuantity');
  @override
  late final GeneratedColumn<double> openedQuantity = GeneratedColumn<double>(
      'opened_quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        medicationName,
        medicationType,
        unitOfMeasure,
        quantityPerUnit,
        totalQuantity,
        minStockAlert,
        expirationDate,
        isOpened,
        openedQuantity,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pharmacy_stock';
  @override
  VerificationContext validateIntegrity(Insertable<PharmacyStockRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('medication_name')) {
      context.handle(
          _medicationNameMeta,
          medicationName.isAcceptableOrUnknown(
              data['medication_name']!, _medicationNameMeta));
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('medication_type')) {
      context.handle(
          _medicationTypeMeta,
          medicationType.isAcceptableOrUnknown(
              data['medication_type']!, _medicationTypeMeta));
    } else if (isInserting) {
      context.missing(_medicationTypeMeta);
    }
    if (data.containsKey('unit_of_measure')) {
      context.handle(
          _unitOfMeasureMeta,
          unitOfMeasure.isAcceptableOrUnknown(
              data['unit_of_measure']!, _unitOfMeasureMeta));
    } else if (isInserting) {
      context.missing(_unitOfMeasureMeta);
    }
    if (data.containsKey('quantity_per_unit')) {
      context.handle(
          _quantityPerUnitMeta,
          quantityPerUnit.isAcceptableOrUnknown(
              data['quantity_per_unit']!, _quantityPerUnitMeta));
    }
    if (data.containsKey('total_quantity')) {
      context.handle(
          _totalQuantityMeta,
          totalQuantity.isAcceptableOrUnknown(
              data['total_quantity']!, _totalQuantityMeta));
    }
    if (data.containsKey('min_stock_alert')) {
      context.handle(
          _minStockAlertMeta,
          minStockAlert.isAcceptableOrUnknown(
              data['min_stock_alert']!, _minStockAlertMeta));
    }
    if (data.containsKey('expiration_date')) {
      context.handle(
          _expirationDateMeta,
          expirationDate.isAcceptableOrUnknown(
              data['expiration_date']!, _expirationDateMeta));
    }
    if (data.containsKey('is_opened')) {
      context.handle(_isOpenedMeta,
          isOpened.isAcceptableOrUnknown(data['is_opened']!, _isOpenedMeta));
    }
    if (data.containsKey('opened_quantity')) {
      context.handle(
          _openedQuantityMeta,
          openedQuantity.isAcceptableOrUnknown(
              data['opened_quantity']!, _openedQuantityMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PharmacyStockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PharmacyStockRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      medicationName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}medication_name'])!,
      medicationType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}medication_type'])!,
      unitOfMeasure: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}unit_of_measure'])!,
      quantityPerUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantity_per_unit']),
      totalQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_quantity'])!,
      minStockAlert: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_stock_alert']),
      expirationDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expiration_date']),
      isOpened: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_opened'])!,
      openedQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opened_quantity'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PharmacyStockTable createAlias(String alias) {
    return $PharmacyStockTable(attachedDatabase, alias);
  }
}

class PharmacyStockRow extends DataClass
    implements Insertable<PharmacyStockRow> {
  final String id;
  final String? farmId;
  final String medicationName;
  final String medicationType;
  final String unitOfMeasure;
  final double? quantityPerUnit;
  final double totalQuantity;
  final double? minStockAlert;
  final String? expirationDate;
  final bool isOpened;
  final double openedQuantity;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PharmacyStockRow(
      {required this.id,
      this.farmId,
      required this.medicationName,
      required this.medicationType,
      required this.unitOfMeasure,
      this.quantityPerUnit,
      required this.totalQuantity,
      this.minStockAlert,
      this.expirationDate,
      required this.isOpened,
      required this.openedQuantity,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['medication_name'] = Variable<String>(medicationName);
    map['medication_type'] = Variable<String>(medicationType);
    map['unit_of_measure'] = Variable<String>(unitOfMeasure);
    if (!nullToAbsent || quantityPerUnit != null) {
      map['quantity_per_unit'] = Variable<double>(quantityPerUnit);
    }
    map['total_quantity'] = Variable<double>(totalQuantity);
    if (!nullToAbsent || minStockAlert != null) {
      map['min_stock_alert'] = Variable<double>(minStockAlert);
    }
    if (!nullToAbsent || expirationDate != null) {
      map['expiration_date'] = Variable<String>(expirationDate);
    }
    map['is_opened'] = Variable<bool>(isOpened);
    map['opened_quantity'] = Variable<double>(openedQuantity);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PharmacyStockCompanion toCompanion(bool nullToAbsent) {
    return PharmacyStockCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      medicationName: Value(medicationName),
      medicationType: Value(medicationType),
      unitOfMeasure: Value(unitOfMeasure),
      quantityPerUnit: quantityPerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityPerUnit),
      totalQuantity: Value(totalQuantity),
      minStockAlert: minStockAlert == null && nullToAbsent
          ? const Value.absent()
          : Value(minStockAlert),
      expirationDate: expirationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expirationDate),
      isOpened: Value(isOpened),
      openedQuantity: Value(openedQuantity),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PharmacyStockRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PharmacyStockRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      medicationType: serializer.fromJson<String>(json['medicationType']),
      unitOfMeasure: serializer.fromJson<String>(json['unitOfMeasure']),
      quantityPerUnit: serializer.fromJson<double?>(json['quantityPerUnit']),
      totalQuantity: serializer.fromJson<double>(json['totalQuantity']),
      minStockAlert: serializer.fromJson<double?>(json['minStockAlert']),
      expirationDate: serializer.fromJson<String?>(json['expirationDate']),
      isOpened: serializer.fromJson<bool>(json['isOpened']),
      openedQuantity: serializer.fromJson<double>(json['openedQuantity']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'medicationName': serializer.toJson<String>(medicationName),
      'medicationType': serializer.toJson<String>(medicationType),
      'unitOfMeasure': serializer.toJson<String>(unitOfMeasure),
      'quantityPerUnit': serializer.toJson<double?>(quantityPerUnit),
      'totalQuantity': serializer.toJson<double>(totalQuantity),
      'minStockAlert': serializer.toJson<double?>(minStockAlert),
      'expirationDate': serializer.toJson<String?>(expirationDate),
      'isOpened': serializer.toJson<bool>(isOpened),
      'openedQuantity': serializer.toJson<double>(openedQuantity),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PharmacyStockRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? medicationName,
          String? medicationType,
          String? unitOfMeasure,
          Value<double?> quantityPerUnit = const Value.absent(),
          double? totalQuantity,
          Value<double?> minStockAlert = const Value.absent(),
          Value<String?> expirationDate = const Value.absent(),
          bool? isOpened,
          double? openedQuantity,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PharmacyStockRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        medicationName: medicationName ?? this.medicationName,
        medicationType: medicationType ?? this.medicationType,
        unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
        quantityPerUnit: quantityPerUnit.present
            ? quantityPerUnit.value
            : this.quantityPerUnit,
        totalQuantity: totalQuantity ?? this.totalQuantity,
        minStockAlert:
            minStockAlert.present ? minStockAlert.value : this.minStockAlert,
        expirationDate:
            expirationDate.present ? expirationDate.value : this.expirationDate,
        isOpened: isOpened ?? this.isOpened,
        openedQuantity: openedQuantity ?? this.openedQuantity,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PharmacyStockRow copyWithCompanion(PharmacyStockCompanion data) {
    return PharmacyStockRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      medicationType: data.medicationType.present
          ? data.medicationType.value
          : this.medicationType,
      unitOfMeasure: data.unitOfMeasure.present
          ? data.unitOfMeasure.value
          : this.unitOfMeasure,
      quantityPerUnit: data.quantityPerUnit.present
          ? data.quantityPerUnit.value
          : this.quantityPerUnit,
      totalQuantity: data.totalQuantity.present
          ? data.totalQuantity.value
          : this.totalQuantity,
      minStockAlert: data.minStockAlert.present
          ? data.minStockAlert.value
          : this.minStockAlert,
      expirationDate: data.expirationDate.present
          ? data.expirationDate.value
          : this.expirationDate,
      isOpened: data.isOpened.present ? data.isOpened.value : this.isOpened,
      openedQuantity: data.openedQuantity.present
          ? data.openedQuantity.value
          : this.openedQuantity,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PharmacyStockRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('medicationName: $medicationName, ')
          ..write('medicationType: $medicationType, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('quantityPerUnit: $quantityPerUnit, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('minStockAlert: $minStockAlert, ')
          ..write('expirationDate: $expirationDate, ')
          ..write('isOpened: $isOpened, ')
          ..write('openedQuantity: $openedQuantity, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      farmId,
      medicationName,
      medicationType,
      unitOfMeasure,
      quantityPerUnit,
      totalQuantity,
      minStockAlert,
      expirationDate,
      isOpened,
      openedQuantity,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PharmacyStockRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.medicationName == this.medicationName &&
          other.medicationType == this.medicationType &&
          other.unitOfMeasure == this.unitOfMeasure &&
          other.quantityPerUnit == this.quantityPerUnit &&
          other.totalQuantity == this.totalQuantity &&
          other.minStockAlert == this.minStockAlert &&
          other.expirationDate == this.expirationDate &&
          other.isOpened == this.isOpened &&
          other.openedQuantity == this.openedQuantity &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PharmacyStockCompanion extends UpdateCompanion<PharmacyStockRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> medicationName;
  final Value<String> medicationType;
  final Value<String> unitOfMeasure;
  final Value<double?> quantityPerUnit;
  final Value<double> totalQuantity;
  final Value<double?> minStockAlert;
  final Value<String?> expirationDate;
  final Value<bool> isOpened;
  final Value<double> openedQuantity;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PharmacyStockCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.medicationType = const Value.absent(),
    this.unitOfMeasure = const Value.absent(),
    this.quantityPerUnit = const Value.absent(),
    this.totalQuantity = const Value.absent(),
    this.minStockAlert = const Value.absent(),
    this.expirationDate = const Value.absent(),
    this.isOpened = const Value.absent(),
    this.openedQuantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PharmacyStockCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String medicationName,
    required String medicationType,
    required String unitOfMeasure,
    this.quantityPerUnit = const Value.absent(),
    this.totalQuantity = const Value.absent(),
    this.minStockAlert = const Value.absent(),
    this.expirationDate = const Value.absent(),
    this.isOpened = const Value.absent(),
    this.openedQuantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        medicationName = Value(medicationName),
        medicationType = Value(medicationType),
        unitOfMeasure = Value(unitOfMeasure);
  static Insertable<PharmacyStockRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? medicationName,
    Expression<String>? medicationType,
    Expression<String>? unitOfMeasure,
    Expression<double>? quantityPerUnit,
    Expression<double>? totalQuantity,
    Expression<double>? minStockAlert,
    Expression<String>? expirationDate,
    Expression<bool>? isOpened,
    Expression<double>? openedQuantity,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (medicationName != null) 'medication_name': medicationName,
      if (medicationType != null) 'medication_type': medicationType,
      if (unitOfMeasure != null) 'unit_of_measure': unitOfMeasure,
      if (quantityPerUnit != null) 'quantity_per_unit': quantityPerUnit,
      if (totalQuantity != null) 'total_quantity': totalQuantity,
      if (minStockAlert != null) 'min_stock_alert': minStockAlert,
      if (expirationDate != null) 'expiration_date': expirationDate,
      if (isOpened != null) 'is_opened': isOpened,
      if (openedQuantity != null) 'opened_quantity': openedQuantity,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PharmacyStockCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? medicationName,
      Value<String>? medicationType,
      Value<String>? unitOfMeasure,
      Value<double?>? quantityPerUnit,
      Value<double>? totalQuantity,
      Value<double?>? minStockAlert,
      Value<String?>? expirationDate,
      Value<bool>? isOpened,
      Value<double>? openedQuantity,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PharmacyStockCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      medicationName: medicationName ?? this.medicationName,
      medicationType: medicationType ?? this.medicationType,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      quantityPerUnit: quantityPerUnit ?? this.quantityPerUnit,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      expirationDate: expirationDate ?? this.expirationDate,
      isOpened: isOpened ?? this.isOpened,
      openedQuantity: openedQuantity ?? this.openedQuantity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (medicationType.present) {
      map['medication_type'] = Variable<String>(medicationType.value);
    }
    if (unitOfMeasure.present) {
      map['unit_of_measure'] = Variable<String>(unitOfMeasure.value);
    }
    if (quantityPerUnit.present) {
      map['quantity_per_unit'] = Variable<double>(quantityPerUnit.value);
    }
    if (totalQuantity.present) {
      map['total_quantity'] = Variable<double>(totalQuantity.value);
    }
    if (minStockAlert.present) {
      map['min_stock_alert'] = Variable<double>(minStockAlert.value);
    }
    if (expirationDate.present) {
      map['expiration_date'] = Variable<String>(expirationDate.value);
    }
    if (isOpened.present) {
      map['is_opened'] = Variable<bool>(isOpened.value);
    }
    if (openedQuantity.present) {
      map['opened_quantity'] = Variable<double>(openedQuantity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PharmacyStockCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('medicationName: $medicationName, ')
          ..write('medicationType: $medicationType, ')
          ..write('unitOfMeasure: $unitOfMeasure, ')
          ..write('quantityPerUnit: $quantityPerUnit, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('minStockAlert: $minStockAlert, ')
          ..write('expirationDate: $expirationDate, ')
          ..write('isOpened: $isOpened, ')
          ..write('openedQuantity: $openedQuantity, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, MedicationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _medicationNameMeta =
      const VerificationMeta('medicationName');
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
      'medication_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextDateMeta =
      const VerificationMeta('nextDate');
  @override
  late final GeneratedColumn<String> nextDate = GeneratedColumn<String>(
      'next_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _veterinarianMeta =
      const VerificationMeta('veterinarian');
  @override
  late final GeneratedColumn<String> veterinarian = GeneratedColumn<String>(
      'veterinarian', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Agendado'));
  static const VerificationMeta _appliedDateMeta =
      const VerificationMeta('appliedDate');
  @override
  late final GeneratedColumn<String> appliedDate = GeneratedColumn<String>(
      'applied_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pharmacyStockIdMeta =
      const VerificationMeta('pharmacyStockId');
  @override
  late final GeneratedColumn<String> pharmacyStockId = GeneratedColumn<String>(
      'pharmacy_stock_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES pharmacy_stock (id)'));
  static const VerificationMeta _quantityUsedMeta =
      const VerificationMeta('quantityUsed');
  @override
  late final GeneratedColumn<double> quantityUsed = GeneratedColumn<double>(
      'quantity_used', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        animalId,
        medicationName,
        date,
        nextDate,
        dosage,
        veterinarian,
        notes,
        createdAt,
        updatedAt,
        status,
        appliedDate,
        pharmacyStockId,
        quantityUsed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(Insertable<MedicationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('medication_name')) {
      context.handle(
          _medicationNameMeta,
          medicationName.isAcceptableOrUnknown(
              data['medication_name']!, _medicationNameMeta));
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('next_date')) {
      context.handle(_nextDateMeta,
          nextDate.isAcceptableOrUnknown(data['next_date']!, _nextDateMeta));
    }
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    }
    if (data.containsKey('veterinarian')) {
      context.handle(
          _veterinarianMeta,
          veterinarian.isAcceptableOrUnknown(
              data['veterinarian']!, _veterinarianMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('applied_date')) {
      context.handle(
          _appliedDateMeta,
          appliedDate.isAcceptableOrUnknown(
              data['applied_date']!, _appliedDateMeta));
    }
    if (data.containsKey('pharmacy_stock_id')) {
      context.handle(
          _pharmacyStockIdMeta,
          pharmacyStockId.isAcceptableOrUnknown(
              data['pharmacy_stock_id']!, _pharmacyStockIdMeta));
    }
    if (data.containsKey('quantity_used')) {
      context.handle(
          _quantityUsedMeta,
          quantityUsed.isAcceptableOrUnknown(
              data['quantity_used']!, _quantityUsedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      medicationName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}medication_name'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      nextDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}next_date']),
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage']),
      veterinarian: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}veterinarian']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      appliedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}applied_date']),
      pharmacyStockId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pharmacy_stock_id']),
      quantityUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity_used']),
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class MedicationRow extends DataClass implements Insertable<MedicationRow> {
  final String id;
  final String? farmId;
  final String animalId;
  final String medicationName;
  final String date;
  final String? nextDate;
  final String? dosage;
  final String? veterinarian;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String? appliedDate;
  final String? pharmacyStockId;
  final double? quantityUsed;
  const MedicationRow(
      {required this.id,
      this.farmId,
      required this.animalId,
      required this.medicationName,
      required this.date,
      this.nextDate,
      this.dosage,
      this.veterinarian,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.status,
      this.appliedDate,
      this.pharmacyStockId,
      this.quantityUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['animal_id'] = Variable<String>(animalId);
    map['medication_name'] = Variable<String>(medicationName);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || nextDate != null) {
      map['next_date'] = Variable<String>(nextDate);
    }
    if (!nullToAbsent || dosage != null) {
      map['dosage'] = Variable<String>(dosage);
    }
    if (!nullToAbsent || veterinarian != null) {
      map['veterinarian'] = Variable<String>(veterinarian);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || appliedDate != null) {
      map['applied_date'] = Variable<String>(appliedDate);
    }
    if (!nullToAbsent || pharmacyStockId != null) {
      map['pharmacy_stock_id'] = Variable<String>(pharmacyStockId);
    }
    if (!nullToAbsent || quantityUsed != null) {
      map['quantity_used'] = Variable<double>(quantityUsed);
    }
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      animalId: Value(animalId),
      medicationName: Value(medicationName),
      date: Value(date),
      nextDate: nextDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDate),
      dosage:
          dosage == null && nullToAbsent ? const Value.absent() : Value(dosage),
      veterinarian: veterinarian == null && nullToAbsent
          ? const Value.absent()
          : Value(veterinarian),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      status: Value(status),
      appliedDate: appliedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedDate),
      pharmacyStockId: pharmacyStockId == null && nullToAbsent
          ? const Value.absent()
          : Value(pharmacyStockId),
      quantityUsed: quantityUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityUsed),
    );
  }

  factory MedicationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      date: serializer.fromJson<String>(json['date']),
      nextDate: serializer.fromJson<String?>(json['nextDate']),
      dosage: serializer.fromJson<String?>(json['dosage']),
      veterinarian: serializer.fromJson<String?>(json['veterinarian']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      status: serializer.fromJson<String>(json['status']),
      appliedDate: serializer.fromJson<String?>(json['appliedDate']),
      pharmacyStockId: serializer.fromJson<String?>(json['pharmacyStockId']),
      quantityUsed: serializer.fromJson<double?>(json['quantityUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'animalId': serializer.toJson<String>(animalId),
      'medicationName': serializer.toJson<String>(medicationName),
      'date': serializer.toJson<String>(date),
      'nextDate': serializer.toJson<String?>(nextDate),
      'dosage': serializer.toJson<String?>(dosage),
      'veterinarian': serializer.toJson<String?>(veterinarian),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'status': serializer.toJson<String>(status),
      'appliedDate': serializer.toJson<String?>(appliedDate),
      'pharmacyStockId': serializer.toJson<String?>(pharmacyStockId),
      'quantityUsed': serializer.toJson<double?>(quantityUsed),
    };
  }

  MedicationRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? animalId,
          String? medicationName,
          String? date,
          Value<String?> nextDate = const Value.absent(),
          Value<String?> dosage = const Value.absent(),
          Value<String?> veterinarian = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? status,
          Value<String?> appliedDate = const Value.absent(),
          Value<String?> pharmacyStockId = const Value.absent(),
          Value<double?> quantityUsed = const Value.absent()}) =>
      MedicationRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        animalId: animalId ?? this.animalId,
        medicationName: medicationName ?? this.medicationName,
        date: date ?? this.date,
        nextDate: nextDate.present ? nextDate.value : this.nextDate,
        dosage: dosage.present ? dosage.value : this.dosage,
        veterinarian:
            veterinarian.present ? veterinarian.value : this.veterinarian,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        status: status ?? this.status,
        appliedDate: appliedDate.present ? appliedDate.value : this.appliedDate,
        pharmacyStockId: pharmacyStockId.present
            ? pharmacyStockId.value
            : this.pharmacyStockId,
        quantityUsed:
            quantityUsed.present ? quantityUsed.value : this.quantityUsed,
      );
  MedicationRow copyWithCompanion(MedicationsCompanion data) {
    return MedicationRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      date: data.date.present ? data.date.value : this.date,
      nextDate: data.nextDate.present ? data.nextDate.value : this.nextDate,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      veterinarian: data.veterinarian.present
          ? data.veterinarian.value
          : this.veterinarian,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      status: data.status.present ? data.status.value : this.status,
      appliedDate:
          data.appliedDate.present ? data.appliedDate.value : this.appliedDate,
      pharmacyStockId: data.pharmacyStockId.present
          ? data.pharmacyStockId.value
          : this.pharmacyStockId,
      quantityUsed: data.quantityUsed.present
          ? data.quantityUsed.value
          : this.quantityUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('medicationName: $medicationName, ')
          ..write('date: $date, ')
          ..write('nextDate: $nextDate, ')
          ..write('dosage: $dosage, ')
          ..write('veterinarian: $veterinarian, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('status: $status, ')
          ..write('appliedDate: $appliedDate, ')
          ..write('pharmacyStockId: $pharmacyStockId, ')
          ..write('quantityUsed: $quantityUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      farmId,
      animalId,
      medicationName,
      date,
      nextDate,
      dosage,
      veterinarian,
      notes,
      createdAt,
      updatedAt,
      status,
      appliedDate,
      pharmacyStockId,
      quantityUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.animalId == this.animalId &&
          other.medicationName == this.medicationName &&
          other.date == this.date &&
          other.nextDate == this.nextDate &&
          other.dosage == this.dosage &&
          other.veterinarian == this.veterinarian &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.status == this.status &&
          other.appliedDate == this.appliedDate &&
          other.pharmacyStockId == this.pharmacyStockId &&
          other.quantityUsed == this.quantityUsed);
}

class MedicationsCompanion extends UpdateCompanion<MedicationRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> animalId;
  final Value<String> medicationName;
  final Value<String> date;
  final Value<String?> nextDate;
  final Value<String?> dosage;
  final Value<String?> veterinarian;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> status;
  final Value<String?> appliedDate;
  final Value<String?> pharmacyStockId;
  final Value<double?> quantityUsed;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.date = const Value.absent(),
    this.nextDate = const Value.absent(),
    this.dosage = const Value.absent(),
    this.veterinarian = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.appliedDate = const Value.absent(),
    this.pharmacyStockId = const Value.absent(),
    this.quantityUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String animalId,
    required String medicationName,
    required String date,
    this.nextDate = const Value.absent(),
    this.dosage = const Value.absent(),
    this.veterinarian = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.appliedDate = const Value.absent(),
    this.pharmacyStockId = const Value.absent(),
    this.quantityUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        medicationName = Value(medicationName),
        date = Value(date);
  static Insertable<MedicationRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? animalId,
    Expression<String>? medicationName,
    Expression<String>? date,
    Expression<String>? nextDate,
    Expression<String>? dosage,
    Expression<String>? veterinarian,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? status,
    Expression<String>? appliedDate,
    Expression<String>? pharmacyStockId,
    Expression<double>? quantityUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (animalId != null) 'animal_id': animalId,
      if (medicationName != null) 'medication_name': medicationName,
      if (date != null) 'date': date,
      if (nextDate != null) 'next_date': nextDate,
      if (dosage != null) 'dosage': dosage,
      if (veterinarian != null) 'veterinarian': veterinarian,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (status != null) 'status': status,
      if (appliedDate != null) 'applied_date': appliedDate,
      if (pharmacyStockId != null) 'pharmacy_stock_id': pharmacyStockId,
      if (quantityUsed != null) 'quantity_used': quantityUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? animalId,
      Value<String>? medicationName,
      Value<String>? date,
      Value<String?>? nextDate,
      Value<String?>? dosage,
      Value<String?>? veterinarian,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? status,
      Value<String?>? appliedDate,
      Value<String?>? pharmacyStockId,
      Value<double?>? quantityUsed,
      Value<int>? rowid}) {
    return MedicationsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      animalId: animalId ?? this.animalId,
      medicationName: medicationName ?? this.medicationName,
      date: date ?? this.date,
      nextDate: nextDate ?? this.nextDate,
      dosage: dosage ?? this.dosage,
      veterinarian: veterinarian ?? this.veterinarian,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      pharmacyStockId: pharmacyStockId ?? this.pharmacyStockId,
      quantityUsed: quantityUsed ?? this.quantityUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (nextDate.present) {
      map['next_date'] = Variable<String>(nextDate.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (veterinarian.present) {
      map['veterinarian'] = Variable<String>(veterinarian.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (appliedDate.present) {
      map['applied_date'] = Variable<String>(appliedDate.value);
    }
    if (pharmacyStockId.present) {
      map['pharmacy_stock_id'] = Variable<String>(pharmacyStockId.value);
    }
    if (quantityUsed.present) {
      map['quantity_used'] = Variable<double>(quantityUsed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('medicationName: $medicationName, ')
          ..write('date: $date, ')
          ..write('nextDate: $nextDate, ')
          ..write('dosage: $dosage, ')
          ..write('veterinarian: $veterinarian, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('status: $status, ')
          ..write('appliedDate: $appliedDate, ')
          ..write('pharmacyStockId: $pharmacyStockId, ')
          ..write('quantityUsed: $quantityUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PharmacyStockMovementsTable extends PharmacyStockMovements
    with TableInfo<$PharmacyStockMovementsTable, PharmacyMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PharmacyStockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pharmacyStockIdMeta =
      const VerificationMeta('pharmacyStockId');
  @override
  late final GeneratedColumn<String> pharmacyStockId = GeneratedColumn<String>(
      'pharmacy_stock_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES pharmacy_stock (id) ON DELETE CASCADE'));
  static const VerificationMeta _medicationIdMeta =
      const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
      'medication_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES medications (id)'));
  static const VerificationMeta _movementTypeMeta =
      const VerificationMeta('movementType');
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
      'movement_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        pharmacyStockId,
        medicationId,
        movementType,
        quantity,
        reason,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pharmacy_stock_movements';
  @override
  VerificationContext validateIntegrity(
      Insertable<PharmacyMovementRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('pharmacy_stock_id')) {
      context.handle(
          _pharmacyStockIdMeta,
          pharmacyStockId.isAcceptableOrUnknown(
              data['pharmacy_stock_id']!, _pharmacyStockIdMeta));
    } else if (isInserting) {
      context.missing(_pharmacyStockIdMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
          _medicationIdMeta,
          medicationId.isAcceptableOrUnknown(
              data['medication_id']!, _medicationIdMeta));
    }
    if (data.containsKey('movement_type')) {
      context.handle(
          _movementTypeMeta,
          movementType.isAcceptableOrUnknown(
              data['movement_type']!, _movementTypeMeta));
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PharmacyMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PharmacyMovementRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      pharmacyStockId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pharmacy_stock_id'])!,
      medicationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medication_id']),
      movementType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}movement_type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PharmacyStockMovementsTable createAlias(String alias) {
    return $PharmacyStockMovementsTable(attachedDatabase, alias);
  }
}

class PharmacyMovementRow extends DataClass
    implements Insertable<PharmacyMovementRow> {
  final String id;
  final String? farmId;
  final String pharmacyStockId;
  final String? medicationId;
  final String movementType;
  final double quantity;
  final String? reason;
  final DateTime createdAt;
  const PharmacyMovementRow(
      {required this.id,
      this.farmId,
      required this.pharmacyStockId,
      this.medicationId,
      required this.movementType,
      required this.quantity,
      this.reason,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['pharmacy_stock_id'] = Variable<String>(pharmacyStockId);
    if (!nullToAbsent || medicationId != null) {
      map['medication_id'] = Variable<String>(medicationId);
    }
    map['movement_type'] = Variable<String>(movementType);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PharmacyStockMovementsCompanion toCompanion(bool nullToAbsent) {
    return PharmacyStockMovementsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      pharmacyStockId: Value(pharmacyStockId),
      medicationId: medicationId == null && nullToAbsent
          ? const Value.absent()
          : Value(medicationId),
      movementType: Value(movementType),
      quantity: Value(quantity),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory PharmacyMovementRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PharmacyMovementRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      pharmacyStockId: serializer.fromJson<String>(json['pharmacyStockId']),
      medicationId: serializer.fromJson<String?>(json['medicationId']),
      movementType: serializer.fromJson<String>(json['movementType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'pharmacyStockId': serializer.toJson<String>(pharmacyStockId),
      'medicationId': serializer.toJson<String?>(medicationId),
      'movementType': serializer.toJson<String>(movementType),
      'quantity': serializer.toJson<double>(quantity),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PharmacyMovementRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? pharmacyStockId,
          Value<String?> medicationId = const Value.absent(),
          String? movementType,
          double? quantity,
          Value<String?> reason = const Value.absent(),
          DateTime? createdAt}) =>
      PharmacyMovementRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        pharmacyStockId: pharmacyStockId ?? this.pharmacyStockId,
        medicationId:
            medicationId.present ? medicationId.value : this.medicationId,
        movementType: movementType ?? this.movementType,
        quantity: quantity ?? this.quantity,
        reason: reason.present ? reason.value : this.reason,
        createdAt: createdAt ?? this.createdAt,
      );
  PharmacyMovementRow copyWithCompanion(PharmacyStockMovementsCompanion data) {
    return PharmacyMovementRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      pharmacyStockId: data.pharmacyStockId.present
          ? data.pharmacyStockId.value
          : this.pharmacyStockId,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PharmacyMovementRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('pharmacyStockId: $pharmacyStockId, ')
          ..write('medicationId: $medicationId, ')
          ..write('movementType: $movementType, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, pharmacyStockId, medicationId,
      movementType, quantity, reason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PharmacyMovementRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.pharmacyStockId == this.pharmacyStockId &&
          other.medicationId == this.medicationId &&
          other.movementType == this.movementType &&
          other.quantity == this.quantity &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class PharmacyStockMovementsCompanion
    extends UpdateCompanion<PharmacyMovementRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> pharmacyStockId;
  final Value<String?> medicationId;
  final Value<String> movementType;
  final Value<double> quantity;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PharmacyStockMovementsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.pharmacyStockId = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.movementType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PharmacyStockMovementsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String pharmacyStockId,
    this.medicationId = const Value.absent(),
    required String movementType,
    required double quantity,
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        pharmacyStockId = Value(pharmacyStockId),
        movementType = Value(movementType),
        quantity = Value(quantity);
  static Insertable<PharmacyMovementRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? pharmacyStockId,
    Expression<String>? medicationId,
    Expression<String>? movementType,
    Expression<double>? quantity,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (pharmacyStockId != null) 'pharmacy_stock_id': pharmacyStockId,
      if (medicationId != null) 'medication_id': medicationId,
      if (movementType != null) 'movement_type': movementType,
      if (quantity != null) 'quantity': quantity,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PharmacyStockMovementsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? pharmacyStockId,
      Value<String?>? medicationId,
      Value<String>? movementType,
      Value<double>? quantity,
      Value<String?>? reason,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PharmacyStockMovementsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      pharmacyStockId: pharmacyStockId ?? this.pharmacyStockId,
      medicationId: medicationId ?? this.medicationId,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (pharmacyStockId.present) {
      map['pharmacy_stock_id'] = Variable<String>(pharmacyStockId.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PharmacyStockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('pharmacyStockId: $pharmacyStockId, ')
          ..write('medicationId: $medicationId, ')
          ..write('movementType: $movementType, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Média'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        animalId,
        title,
        content,
        category,
        priority,
        date,
        createdBy,
        createdAt,
        updatedAt,
        isRead
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String? farmId;
  final String? animalId;
  final String title;
  final String? content;
  final String category;
  final String priority;
  final String date;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;
  const NoteRow(
      {required this.id,
      this.farmId,
      this.animalId,
      required this.title,
      this.content,
      required this.category,
      required this.priority,
      required this.date,
      this.createdBy,
      required this.createdAt,
      required this.updatedAt,
      required this.isRead});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    if (!nullToAbsent || animalId != null) {
      map['animal_id'] = Variable<String>(animalId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['category'] = Variable<String>(category);
    map['priority'] = Variable<String>(priority);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      animalId: animalId == null && nullToAbsent
          ? const Value.absent()
          : Value(animalId),
      title: Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      category: Value(category),
      priority: Value(priority),
      date: Value(date),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isRead: Value(isRead),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      animalId: serializer.fromJson<String?>(json['animalId']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      category: serializer.fromJson<String>(json['category']),
      priority: serializer.fromJson<String>(json['priority']),
      date: serializer.fromJson<String>(json['date']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'animalId': serializer.toJson<String?>(animalId),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String?>(content),
      'category': serializer.toJson<String>(category),
      'priority': serializer.toJson<String>(priority),
      'date': serializer.toJson<String>(date),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  NoteRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          Value<String?> animalId = const Value.absent(),
          String? title,
          Value<String?> content = const Value.absent(),
          String? category,
          String? priority,
          String? date,
          Value<String?> createdBy = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isRead}) =>
      NoteRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        animalId: animalId.present ? animalId.value : this.animalId,
        title: title ?? this.title,
        content: content.present ? content.value : this.content,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        date: date ?? this.date,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isRead: isRead ?? this.isRead,
      );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      category: data.category.present ? data.category.value : this.category,
      priority: data.priority.present ? data.priority.value : this.priority,
      date: data.date.present ? data.date.value : this.date,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('date: $date, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, animalId, title, content,
      category, priority, date, createdBy, createdAt, updatedAt, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.animalId == this.animalId &&
          other.title == this.title &&
          other.content == this.content &&
          other.category == this.category &&
          other.priority == this.priority &&
          other.date == this.date &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isRead == this.isRead);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String?> animalId;
  final Value<String> title;
  final Value<String?> content;
  final Value<String> category;
  final Value<String> priority;
  final Value<String> date;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isRead;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.date = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    this.animalId = const Value.absent(),
    required String title,
    this.content = const Value.absent(),
    required String category,
    this.priority = const Value.absent(),
    required String date,
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        category = Value(category),
        date = Value(date);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? animalId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? category,
    Expression<String>? priority,
    Expression<String>? date,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (animalId != null) 'animal_id': animalId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
      if (date != null) 'date': date,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String?>? animalId,
      Value<String>? title,
      Value<String?>? content,
      Value<String>? category,
      Value<String>? priority,
      Value<String>? date,
      Value<String?>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isRead,
      Value<int>? rowid}) {
    return NotesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      animalId: animalId ?? this.animalId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('date: $date, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportsTable extends Reports with TableInfo<$ReportsTable, ReportRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reportTypeMeta =
      const VerificationMeta('reportType');
  @override
  late final GeneratedColumn<String> reportType = GeneratedColumn<String>(
      'report_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parametersMeta =
      const VerificationMeta('parameters');
  @override
  late final GeneratedColumn<String> parameters = GeneratedColumn<String>(
      'parameters', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _generatedAtMeta =
      const VerificationMeta('generatedAt');
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
      'generated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _generatedByMeta =
      const VerificationMeta('generatedBy');
  @override
  late final GeneratedColumn<String> generatedBy = GeneratedColumn<String>(
      'generated_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, farmId, title, reportType, parameters, generatedAt, generatedBy];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(Insertable<ReportRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('report_type')) {
      context.handle(
          _reportTypeMeta,
          reportType.isAcceptableOrUnknown(
              data['report_type']!, _reportTypeMeta));
    } else if (isInserting) {
      context.missing(_reportTypeMeta);
    }
    if (data.containsKey('parameters')) {
      context.handle(
          _parametersMeta,
          parameters.isAcceptableOrUnknown(
              data['parameters']!, _parametersMeta));
    }
    if (data.containsKey('generated_at')) {
      context.handle(
          _generatedAtMeta,
          generatedAt.isAcceptableOrUnknown(
              data['generated_at']!, _generatedAtMeta));
    }
    if (data.containsKey('generated_by')) {
      context.handle(
          _generatedByMeta,
          generatedBy.isAcceptableOrUnknown(
              data['generated_by']!, _generatedByMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReportRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      reportType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}report_type'])!,
      parameters: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parameters'])!,
      generatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}generated_at'])!,
      generatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}generated_by']),
    );
  }

  @override
  $ReportsTable createAlias(String alias) {
    return $ReportsTable(attachedDatabase, alias);
  }
}

class ReportRow extends DataClass implements Insertable<ReportRow> {
  final String id;
  final String? farmId;
  final String title;
  final String reportType;
  final String parameters;
  final DateTime generatedAt;
  final String? generatedBy;
  const ReportRow(
      {required this.id,
      this.farmId,
      required this.title,
      required this.reportType,
      required this.parameters,
      required this.generatedAt,
      this.generatedBy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['title'] = Variable<String>(title);
    map['report_type'] = Variable<String>(reportType);
    map['parameters'] = Variable<String>(parameters);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    if (!nullToAbsent || generatedBy != null) {
      map['generated_by'] = Variable<String>(generatedBy);
    }
    return map;
  }

  ReportsCompanion toCompanion(bool nullToAbsent) {
    return ReportsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      title: Value(title),
      reportType: Value(reportType),
      parameters: Value(parameters),
      generatedAt: Value(generatedAt),
      generatedBy: generatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(generatedBy),
    );
  }

  factory ReportRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      title: serializer.fromJson<String>(json['title']),
      reportType: serializer.fromJson<String>(json['reportType']),
      parameters: serializer.fromJson<String>(json['parameters']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      generatedBy: serializer.fromJson<String?>(json['generatedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'title': serializer.toJson<String>(title),
      'reportType': serializer.toJson<String>(reportType),
      'parameters': serializer.toJson<String>(parameters),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'generatedBy': serializer.toJson<String?>(generatedBy),
    };
  }

  ReportRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? title,
          String? reportType,
          String? parameters,
          DateTime? generatedAt,
          Value<String?> generatedBy = const Value.absent()}) =>
      ReportRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        title: title ?? this.title,
        reportType: reportType ?? this.reportType,
        parameters: parameters ?? this.parameters,
        generatedAt: generatedAt ?? this.generatedAt,
        generatedBy: generatedBy.present ? generatedBy.value : this.generatedBy,
      );
  ReportRow copyWithCompanion(ReportsCompanion data) {
    return ReportRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      title: data.title.present ? data.title.value : this.title,
      reportType:
          data.reportType.present ? data.reportType.value : this.reportType,
      parameters:
          data.parameters.present ? data.parameters.value : this.parameters,
      generatedAt:
          data.generatedAt.present ? data.generatedAt.value : this.generatedAt,
      generatedBy:
          data.generatedBy.present ? data.generatedBy.value : this.generatedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('title: $title, ')
          ..write('reportType: $reportType, ')
          ..write('parameters: $parameters, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('generatedBy: $generatedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, farmId, title, reportType, parameters, generatedAt, generatedBy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.title == this.title &&
          other.reportType == this.reportType &&
          other.parameters == this.parameters &&
          other.generatedAt == this.generatedAt &&
          other.generatedBy == this.generatedBy);
}

class ReportsCompanion extends UpdateCompanion<ReportRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> title;
  final Value<String> reportType;
  final Value<String> parameters;
  final Value<DateTime> generatedAt;
  final Value<String?> generatedBy;
  final Value<int> rowid;
  const ReportsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.title = const Value.absent(),
    this.reportType = const Value.absent(),
    this.parameters = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.generatedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String title,
    required String reportType,
    this.parameters = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.generatedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        reportType = Value(reportType);
  static Insertable<ReportRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? title,
    Expression<String>? reportType,
    Expression<String>? parameters,
    Expression<DateTime>? generatedAt,
    Expression<String>? generatedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (title != null) 'title': title,
      if (reportType != null) 'report_type': reportType,
      if (parameters != null) 'parameters': parameters,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (generatedBy != null) 'generated_by': generatedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? title,
      Value<String>? reportType,
      Value<String>? parameters,
      Value<DateTime>? generatedAt,
      Value<String?>? generatedBy,
      Value<int>? rowid}) {
    return ReportsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      title: title ?? this.title,
      reportType: reportType ?? this.reportType,
      parameters: parameters ?? this.parameters,
      generatedAt: generatedAt ?? this.generatedAt,
      generatedBy: generatedBy ?? this.generatedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (reportType.present) {
      map['report_type'] = Variable<String>(reportType.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(parameters.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (generatedBy.present) {
      map['generated_by'] = Variable<String>(generatedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('title: $title, ')
          ..write('reportType: $reportType, ')
          ..write('parameters: $parameters, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('generatedBy: $generatedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PushTokensTable extends PushTokens
    with TableInfo<$PushTokensTable, PushTokenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PushTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceInfoMeta =
      const VerificationMeta('deviceInfo');
  @override
  late final GeneratedColumn<String> deviceInfo = GeneratedColumn<String>(
      'device_info', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, farmId, token, platform, deviceInfo, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'push_tokens';
  @override
  VerificationContext validateIntegrity(Insertable<PushTokenRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    }
    if (data.containsKey('device_info')) {
      context.handle(
          _deviceInfoMeta,
          deviceInfo.isAcceptableOrUnknown(
              data['device_info']!, _deviceInfoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PushTokenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PushTokenRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform']),
      deviceInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_info'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PushTokensTable createAlias(String alias) {
    return $PushTokensTable(attachedDatabase, alias);
  }
}

class PushTokenRow extends DataClass implements Insertable<PushTokenRow> {
  final String id;
  final String? farmId;
  final String token;
  final String? platform;
  final String deviceInfo;
  final DateTime createdAt;
  const PushTokenRow(
      {required this.id,
      this.farmId,
      required this.token,
      this.platform,
      required this.deviceInfo,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['token'] = Variable<String>(token);
    if (!nullToAbsent || platform != null) {
      map['platform'] = Variable<String>(platform);
    }
    map['device_info'] = Variable<String>(deviceInfo);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PushTokensCompanion toCompanion(bool nullToAbsent) {
    return PushTokensCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      token: Value(token),
      platform: platform == null && nullToAbsent
          ? const Value.absent()
          : Value(platform),
      deviceInfo: Value(deviceInfo),
      createdAt: Value(createdAt),
    );
  }

  factory PushTokenRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PushTokenRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      token: serializer.fromJson<String>(json['token']),
      platform: serializer.fromJson<String?>(json['platform']),
      deviceInfo: serializer.fromJson<String>(json['deviceInfo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'token': serializer.toJson<String>(token),
      'platform': serializer.toJson<String?>(platform),
      'deviceInfo': serializer.toJson<String>(deviceInfo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PushTokenRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? token,
          Value<String?> platform = const Value.absent(),
          String? deviceInfo,
          DateTime? createdAt}) =>
      PushTokenRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        token: token ?? this.token,
        platform: platform.present ? platform.value : this.platform,
        deviceInfo: deviceInfo ?? this.deviceInfo,
        createdAt: createdAt ?? this.createdAt,
      );
  PushTokenRow copyWithCompanion(PushTokensCompanion data) {
    return PushTokenRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      token: data.token.present ? data.token.value : this.token,
      platform: data.platform.present ? data.platform.value : this.platform,
      deviceInfo:
          data.deviceInfo.present ? data.deviceInfo.value : this.deviceInfo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PushTokenRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('token: $token, ')
          ..write('platform: $platform, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, farmId, token, platform, deviceInfo, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PushTokenRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.token == this.token &&
          other.platform == this.platform &&
          other.deviceInfo == this.deviceInfo &&
          other.createdAt == this.createdAt);
}

class PushTokensCompanion extends UpdateCompanion<PushTokenRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> token;
  final Value<String?> platform;
  final Value<String> deviceInfo;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PushTokensCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.token = const Value.absent(),
    this.platform = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PushTokensCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String token,
    this.platform = const Value.absent(),
    this.deviceInfo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        token = Value(token);
  static Insertable<PushTokenRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? token,
    Expression<String>? platform,
    Expression<String>? deviceInfo,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (token != null) 'token': token,
      if (platform != null) 'platform': platform,
      if (deviceInfo != null) 'device_info': deviceInfo,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PushTokensCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? token,
      Value<String?>? platform,
      Value<String>? deviceInfo,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PushTokensCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (deviceInfo.present) {
      map['device_info'] = Variable<String>(deviceInfo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PushTokensCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('token: $token, ')
          ..write('platform: $platform, ')
          ..write('deviceInfo: $deviceInfo, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedingPensTable extends FeedingPens
    with TableInfo<$FeedingPensTable, FeedingPenRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedingPensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, farmId, name, number, notes, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeding_pens';
  @override
  VerificationContext validateIntegrity(Insertable<FeedingPenRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedingPenRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedingPenRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FeedingPensTable createAlias(String alias) {
    return $FeedingPensTable(attachedDatabase, alias);
  }
}

class FeedingPenRow extends DataClass implements Insertable<FeedingPenRow> {
  final String id;
  final String? farmId;
  final String name;
  final String? number;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FeedingPenRow(
      {required this.id,
      this.farmId,
      required this.name,
      this.number,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<String>(number);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FeedingPensCompanion toCompanion(bool nullToAbsent) {
    return FeedingPensCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      name: Value(name),
      number:
          number == null && nullToAbsent ? const Value.absent() : Value(number),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeedingPenRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedingPenRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      number: serializer.fromJson<String?>(json['number']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'name': serializer.toJson<String>(name),
      'number': serializer.toJson<String?>(number),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FeedingPenRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? name,
          Value<String?> number = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FeedingPenRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        name: name ?? this.name,
        number: number.present ? number.value : this.number,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FeedingPenRow copyWithCompanion(FeedingPensCompanion data) {
    return FeedingPenRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      number: data.number.present ? data.number.value : this.number,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedingPenRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, farmId, name, number, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedingPenRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.number == this.number &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeedingPensCompanion extends UpdateCompanion<FeedingPenRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> name;
  final Value<String?> number;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FeedingPensCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.number = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedingPensCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String name,
    this.number = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<FeedingPenRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? name,
    Expression<String>? number,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (number != null) 'number': number,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedingPensCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? name,
      Value<String?>? number,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FeedingPensCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      number: number ?? this.number,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedingPensCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedingSchedulesTable extends FeedingSchedules
    with TableInfo<$FeedingSchedulesTable, FeedingScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedingSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _penIdMeta = const VerificationMeta('penId');
  @override
  late final GeneratedColumn<String> penId = GeneratedColumn<String>(
      'pen_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES feeding_pens (id) ON DELETE CASCADE'));
  static const VerificationMeta _feedTypeMeta =
      const VerificationMeta('feedType');
  @override
  late final GeneratedColumn<String> feedType = GeneratedColumn<String>(
      'feed_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timesPerDayMeta =
      const VerificationMeta('timesPerDay');
  @override
  late final GeneratedColumn<int> timesPerDay = GeneratedColumn<int>(
      'times_per_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _feedingTimesMeta =
      const VerificationMeta('feedingTimes');
  @override
  late final GeneratedColumn<String> feedingTimes = GeneratedColumn<String>(
      'feeding_times', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        penId,
        feedType,
        quantity,
        timesPerDay,
        feedingTimes,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeding_schedules';
  @override
  VerificationContext validateIntegrity(Insertable<FeedingScheduleRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('pen_id')) {
      context.handle(
          _penIdMeta, penId.isAcceptableOrUnknown(data['pen_id']!, _penIdMeta));
    } else if (isInserting) {
      context.missing(_penIdMeta);
    }
    if (data.containsKey('feed_type')) {
      context.handle(_feedTypeMeta,
          feedType.isAcceptableOrUnknown(data['feed_type']!, _feedTypeMeta));
    } else if (isInserting) {
      context.missing(_feedTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('times_per_day')) {
      context.handle(
          _timesPerDayMeta,
          timesPerDay.isAcceptableOrUnknown(
              data['times_per_day']!, _timesPerDayMeta));
    }
    if (data.containsKey('feeding_times')) {
      context.handle(
          _feedingTimesMeta,
          feedingTimes.isAcceptableOrUnknown(
              data['feeding_times']!, _feedingTimesMeta));
    } else if (isInserting) {
      context.missing(_feedingTimesMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedingScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedingScheduleRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      penId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pen_id'])!,
      feedType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feed_type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      timesPerDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}times_per_day'])!,
      feedingTimes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feeding_times'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FeedingSchedulesTable createAlias(String alias) {
    return $FeedingSchedulesTable(attachedDatabase, alias);
  }
}

class FeedingScheduleRow extends DataClass
    implements Insertable<FeedingScheduleRow> {
  final String id;
  final String? farmId;
  final String penId;
  final String feedType;
  final double quantity;
  final int timesPerDay;
  final String feedingTimes;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FeedingScheduleRow(
      {required this.id,
      this.farmId,
      required this.penId,
      required this.feedType,
      required this.quantity,
      required this.timesPerDay,
      required this.feedingTimes,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['pen_id'] = Variable<String>(penId);
    map['feed_type'] = Variable<String>(feedType);
    map['quantity'] = Variable<double>(quantity);
    map['times_per_day'] = Variable<int>(timesPerDay);
    map['feeding_times'] = Variable<String>(feedingTimes);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FeedingSchedulesCompanion toCompanion(bool nullToAbsent) {
    return FeedingSchedulesCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      penId: Value(penId),
      feedType: Value(feedType),
      quantity: Value(quantity),
      timesPerDay: Value(timesPerDay),
      feedingTimes: Value(feedingTimes),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FeedingScheduleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedingScheduleRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      penId: serializer.fromJson<String>(json['penId']),
      feedType: serializer.fromJson<String>(json['feedType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      timesPerDay: serializer.fromJson<int>(json['timesPerDay']),
      feedingTimes: serializer.fromJson<String>(json['feedingTimes']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'penId': serializer.toJson<String>(penId),
      'feedType': serializer.toJson<String>(feedType),
      'quantity': serializer.toJson<double>(quantity),
      'timesPerDay': serializer.toJson<int>(timesPerDay),
      'feedingTimes': serializer.toJson<String>(feedingTimes),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FeedingScheduleRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? penId,
          String? feedType,
          double? quantity,
          int? timesPerDay,
          String? feedingTimes,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FeedingScheduleRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        penId: penId ?? this.penId,
        feedType: feedType ?? this.feedType,
        quantity: quantity ?? this.quantity,
        timesPerDay: timesPerDay ?? this.timesPerDay,
        feedingTimes: feedingTimes ?? this.feedingTimes,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FeedingScheduleRow copyWithCompanion(FeedingSchedulesCompanion data) {
    return FeedingScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      penId: data.penId.present ? data.penId.value : this.penId,
      feedType: data.feedType.present ? data.feedType.value : this.feedType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      timesPerDay:
          data.timesPerDay.present ? data.timesPerDay.value : this.timesPerDay,
      feedingTimes: data.feedingTimes.present
          ? data.feedingTimes.value
          : this.feedingTimes,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedingScheduleRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('penId: $penId, ')
          ..write('feedType: $feedType, ')
          ..write('quantity: $quantity, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('feedingTimes: $feedingTimes, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, penId, feedType, quantity,
      timesPerDay, feedingTimes, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedingScheduleRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.penId == this.penId &&
          other.feedType == this.feedType &&
          other.quantity == this.quantity &&
          other.timesPerDay == this.timesPerDay &&
          other.feedingTimes == this.feedingTimes &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FeedingSchedulesCompanion extends UpdateCompanion<FeedingScheduleRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> penId;
  final Value<String> feedType;
  final Value<double> quantity;
  final Value<int> timesPerDay;
  final Value<String> feedingTimes;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FeedingSchedulesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.penId = const Value.absent(),
    this.feedType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.timesPerDay = const Value.absent(),
    this.feedingTimes = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedingSchedulesCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String penId,
    required String feedType,
    required double quantity,
    this.timesPerDay = const Value.absent(),
    required String feedingTimes,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        penId = Value(penId),
        feedType = Value(feedType),
        quantity = Value(quantity),
        feedingTimes = Value(feedingTimes);
  static Insertable<FeedingScheduleRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? penId,
    Expression<String>? feedType,
    Expression<double>? quantity,
    Expression<int>? timesPerDay,
    Expression<String>? feedingTimes,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (penId != null) 'pen_id': penId,
      if (feedType != null) 'feed_type': feedType,
      if (quantity != null) 'quantity': quantity,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (feedingTimes != null) 'feeding_times': feedingTimes,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedingSchedulesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? penId,
      Value<String>? feedType,
      Value<double>? quantity,
      Value<int>? timesPerDay,
      Value<String>? feedingTimes,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FeedingSchedulesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      penId: penId ?? this.penId,
      feedType: feedType ?? this.feedType,
      quantity: quantity ?? this.quantity,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      feedingTimes: feedingTimes ?? this.feedingTimes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (penId.present) {
      map['pen_id'] = Variable<String>(penId.value);
    }
    if (feedType.present) {
      map['feed_type'] = Variable<String>(feedType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (timesPerDay.present) {
      map['times_per_day'] = Variable<int>(timesPerDay.value);
    }
    if (feedingTimes.present) {
      map['feeding_times'] = Variable<String>(feedingTimes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedingSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('penId: $penId, ')
          ..write('feedType: $feedType, ')
          ..write('quantity: $quantity, ')
          ..write('timesPerDay: $timesPerDay, ')
          ..write('feedingTimes: $feedingTimes, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaccinationsTable extends Vaccinations
    with TableInfo<$VaccinationsTable, VaccinationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES animals (id)'));
  static const VerificationMeta _vaccineNameMeta =
      const VerificationMeta('vaccineName');
  @override
  late final GeneratedColumn<String> vaccineName = GeneratedColumn<String>(
      'vaccine_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vaccineTypeMeta =
      const VerificationMeta('vaccineType');
  @override
  late final GeneratedColumn<String> vaccineType = GeneratedColumn<String>(
      'vaccine_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduledDateMeta =
      const VerificationMeta('scheduledDate');
  @override
  late final GeneratedColumn<String> scheduledDate = GeneratedColumn<String>(
      'scheduled_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appliedDateMeta =
      const VerificationMeta('appliedDate');
  @override
  late final GeneratedColumn<String> appliedDate = GeneratedColumn<String>(
      'applied_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _veterinarianMeta =
      const VerificationMeta('veterinarian');
  @override
  late final GeneratedColumn<String> veterinarian = GeneratedColumn<String>(
      'veterinarian', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Agendada'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        animalId,
        vaccineName,
        vaccineType,
        scheduledDate,
        appliedDate,
        veterinarian,
        notes,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccinations';
  @override
  VerificationContext validateIntegrity(Insertable<VaccinationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('vaccine_name')) {
      context.handle(
          _vaccineNameMeta,
          vaccineName.isAcceptableOrUnknown(
              data['vaccine_name']!, _vaccineNameMeta));
    } else if (isInserting) {
      context.missing(_vaccineNameMeta);
    }
    if (data.containsKey('vaccine_type')) {
      context.handle(
          _vaccineTypeMeta,
          vaccineType.isAcceptableOrUnknown(
              data['vaccine_type']!, _vaccineTypeMeta));
    } else if (isInserting) {
      context.missing(_vaccineTypeMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
          _scheduledDateMeta,
          scheduledDate.isAcceptableOrUnknown(
              data['scheduled_date']!, _scheduledDateMeta));
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('applied_date')) {
      context.handle(
          _appliedDateMeta,
          appliedDate.isAcceptableOrUnknown(
              data['applied_date']!, _appliedDateMeta));
    }
    if (data.containsKey('veterinarian')) {
      context.handle(
          _veterinarianMeta,
          veterinarian.isAcceptableOrUnknown(
              data['veterinarian']!, _veterinarianMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VaccinationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VaccinationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      vaccineName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vaccine_name'])!,
      vaccineType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vaccine_type'])!,
      scheduledDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scheduled_date'])!,
      appliedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}applied_date']),
      veterinarian: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}veterinarian']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $VaccinationsTable createAlias(String alias) {
    return $VaccinationsTable(attachedDatabase, alias);
  }
}

class VaccinationRow extends DataClass implements Insertable<VaccinationRow> {
  final String id;
  final String? farmId;
  final String animalId;
  final String vaccineName;
  final String vaccineType;
  final String scheduledDate;
  final String? appliedDate;
  final String? veterinarian;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VaccinationRow(
      {required this.id,
      this.farmId,
      required this.animalId,
      required this.vaccineName,
      required this.vaccineType,
      required this.scheduledDate,
      this.appliedDate,
      this.veterinarian,
      this.notes,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['animal_id'] = Variable<String>(animalId);
    map['vaccine_name'] = Variable<String>(vaccineName);
    map['vaccine_type'] = Variable<String>(vaccineType);
    map['scheduled_date'] = Variable<String>(scheduledDate);
    if (!nullToAbsent || appliedDate != null) {
      map['applied_date'] = Variable<String>(appliedDate);
    }
    if (!nullToAbsent || veterinarian != null) {
      map['veterinarian'] = Variable<String>(veterinarian);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VaccinationsCompanion toCompanion(bool nullToAbsent) {
    return VaccinationsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      animalId: Value(animalId),
      vaccineName: Value(vaccineName),
      vaccineType: Value(vaccineType),
      scheduledDate: Value(scheduledDate),
      appliedDate: appliedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedDate),
      veterinarian: veterinarian == null && nullToAbsent
          ? const Value.absent()
          : Value(veterinarian),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VaccinationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VaccinationRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      vaccineName: serializer.fromJson<String>(json['vaccineName']),
      vaccineType: serializer.fromJson<String>(json['vaccineType']),
      scheduledDate: serializer.fromJson<String>(json['scheduledDate']),
      appliedDate: serializer.fromJson<String?>(json['appliedDate']),
      veterinarian: serializer.fromJson<String?>(json['veterinarian']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'animalId': serializer.toJson<String>(animalId),
      'vaccineName': serializer.toJson<String>(vaccineName),
      'vaccineType': serializer.toJson<String>(vaccineType),
      'scheduledDate': serializer.toJson<String>(scheduledDate),
      'appliedDate': serializer.toJson<String?>(appliedDate),
      'veterinarian': serializer.toJson<String?>(veterinarian),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VaccinationRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? animalId,
          String? vaccineName,
          String? vaccineType,
          String? scheduledDate,
          Value<String?> appliedDate = const Value.absent(),
          Value<String?> veterinarian = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      VaccinationRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        animalId: animalId ?? this.animalId,
        vaccineName: vaccineName ?? this.vaccineName,
        vaccineType: vaccineType ?? this.vaccineType,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        appliedDate: appliedDate.present ? appliedDate.value : this.appliedDate,
        veterinarian:
            veterinarian.present ? veterinarian.value : this.veterinarian,
        notes: notes.present ? notes.value : this.notes,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  VaccinationRow copyWithCompanion(VaccinationsCompanion data) {
    return VaccinationRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      vaccineName:
          data.vaccineName.present ? data.vaccineName.value : this.vaccineName,
      vaccineType:
          data.vaccineType.present ? data.vaccineType.value : this.vaccineType,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      appliedDate:
          data.appliedDate.present ? data.appliedDate.value : this.appliedDate,
      veterinarian: data.veterinarian.present
          ? data.veterinarian.value
          : this.veterinarian,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('vaccineType: $vaccineType, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('appliedDate: $appliedDate, ')
          ..write('veterinarian: $veterinarian, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      farmId,
      animalId,
      vaccineName,
      vaccineType,
      scheduledDate,
      appliedDate,
      veterinarian,
      notes,
      status,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VaccinationRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.animalId == this.animalId &&
          other.vaccineName == this.vaccineName &&
          other.vaccineType == this.vaccineType &&
          other.scheduledDate == this.scheduledDate &&
          other.appliedDate == this.appliedDate &&
          other.veterinarian == this.veterinarian &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VaccinationsCompanion extends UpdateCompanion<VaccinationRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> animalId;
  final Value<String> vaccineName;
  final Value<String> vaccineType;
  final Value<String> scheduledDate;
  final Value<String?> appliedDate;
  final Value<String?> veterinarian;
  final Value<String?> notes;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VaccinationsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.vaccineType = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.appliedDate = const Value.absent(),
    this.veterinarian = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaccinationsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String animalId,
    required String vaccineName,
    required String vaccineType,
    required String scheduledDate,
    this.appliedDate = const Value.absent(),
    this.veterinarian = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        vaccineName = Value(vaccineName),
        vaccineType = Value(vaccineType),
        scheduledDate = Value(scheduledDate);
  static Insertable<VaccinationRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? animalId,
    Expression<String>? vaccineName,
    Expression<String>? vaccineType,
    Expression<String>? scheduledDate,
    Expression<String>? appliedDate,
    Expression<String>? veterinarian,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (animalId != null) 'animal_id': animalId,
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (vaccineType != null) 'vaccine_type': vaccineType,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (appliedDate != null) 'applied_date': appliedDate,
      if (veterinarian != null) 'veterinarian': veterinarian,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaccinationsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? animalId,
      Value<String>? vaccineName,
      Value<String>? vaccineType,
      Value<String>? scheduledDate,
      Value<String?>? appliedDate,
      Value<String?>? veterinarian,
      Value<String?>? notes,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return VaccinationsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      animalId: animalId ?? this.animalId,
      vaccineName: vaccineName ?? this.vaccineName,
      vaccineType: vaccineType ?? this.vaccineType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      appliedDate: appliedDate ?? this.appliedDate,
      veterinarian: veterinarian ?? this.veterinarian,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (vaccineName.present) {
      map['vaccine_name'] = Variable<String>(vaccineName.value);
    }
    if (vaccineType.present) {
      map['vaccine_type'] = Variable<String>(vaccineType.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<String>(scheduledDate.value);
    }
    if (appliedDate.present) {
      map['applied_date'] = Variable<String>(appliedDate.value);
    }
    if (veterinarian.present) {
      map['veterinarian'] = Variable<String>(veterinarian.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('vaccineType: $vaccineType, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('appliedDate: $appliedDate, ')
          ..write('veterinarian: $veterinarian, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SoldAnimalsTable extends SoldAnimals
    with TableInfo<$SoldAnimalsTable, SoldAnimalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SoldAnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalAnimalIdMeta =
      const VerificationMeta('originalAnimalId');
  @override
  late final GeneratedColumn<String> originalAnimalId = GeneratedColumn<String>(
      'original_animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reproductiveStatusMeta =
      const VerificationMeta('reproductiveStatus');
  @override
  late final GeneratedColumn<String> reproductiveStatus =
      GeneratedColumn<String>('reproductive_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('Não aplicável'));
  static const VerificationMeta _nameColorMeta =
      const VerificationMeta('nameColor');
  @override
  late final GeneratedColumn<String> nameColor = GeneratedColumn<String>(
      'name_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthWeightMeta =
      const VerificationMeta('birthWeight');
  @override
  late final GeneratedColumn<double> birthWeight = GeneratedColumn<double>(
      'birth_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight30DaysMeta =
      const VerificationMeta('weight30Days');
  @override
  late final GeneratedColumn<double> weight30Days = GeneratedColumn<double>(
      'weight_30_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight60DaysMeta =
      const VerificationMeta('weight60Days');
  @override
  late final GeneratedColumn<double> weight60Days = GeneratedColumn<double>(
      'weight_60_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight90DaysMeta =
      const VerificationMeta('weight90Days');
  @override
  late final GeneratedColumn<double> weight90Days = GeneratedColumn<double>(
      'weight_90_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight120DaysMeta =
      const VerificationMeta('weight120Days');
  @override
  late final GeneratedColumn<double> weight120Days = GeneratedColumn<double>(
      'weight_120_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _loteMeta = const VerificationMeta('lote');
  @override
  late final GeneratedColumn<String> lote = GeneratedColumn<String>(
      'lote', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _motherIdMeta =
      const VerificationMeta('motherId');
  @override
  late final GeneratedColumn<String> motherId = GeneratedColumn<String>(
      'mother_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fatherIdMeta =
      const VerificationMeta('fatherId');
  @override
  late final GeneratedColumn<String> fatherId = GeneratedColumn<String>(
      'father_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _registrationNoteMeta =
      const VerificationMeta('registrationNote');
  @override
  late final GeneratedColumn<String> registrationNote = GeneratedColumn<String>(
      'registration_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _saleDateMeta =
      const VerificationMeta('saleDate');
  @override
  late final GeneratedColumn<String> saleDate = GeneratedColumn<String>(
      'sale_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _salePriceMeta =
      const VerificationMeta('salePrice');
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
      'sale_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _buyerMeta = const VerificationMeta('buyer');
  @override
  late final GeneratedColumn<String> buyer = GeneratedColumn<String>(
      'buyer', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _saleNotesMeta =
      const VerificationMeta('saleNotes');
  @override
  late final GeneratedColumn<String> saleNotes = GeneratedColumn<String>(
      'sale_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        originalAnimalId,
        code,
        name,
        species,
        breed,
        gender,
        birthDate,
        weight,
        location,
        reproductiveStatus,
        nameColor,
        category,
        birthWeight,
        weight30Days,
        weight60Days,
        weight90Days,
        weight120Days,
        year,
        lote,
        motherId,
        fatherId,
        registrationNote,
        saleDate,
        salePrice,
        buyer,
        saleNotes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sold_animals';
  @override
  VerificationContext validateIntegrity(Insertable<SoldAnimalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('original_animal_id')) {
      context.handle(
          _originalAnimalIdMeta,
          originalAnimalId.isAcceptableOrUnknown(
              data['original_animal_id']!, _originalAnimalIdMeta));
    } else if (isInserting) {
      context.missing(_originalAnimalIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    } else if (isInserting) {
      context.missing(_breedMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('reproductive_status')) {
      context.handle(
          _reproductiveStatusMeta,
          reproductiveStatus.isAcceptableOrUnknown(
              data['reproductive_status']!, _reproductiveStatusMeta));
    }
    if (data.containsKey('name_color')) {
      context.handle(_nameColorMeta,
          nameColor.isAcceptableOrUnknown(data['name_color']!, _nameColorMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('birth_weight')) {
      context.handle(
          _birthWeightMeta,
          birthWeight.isAcceptableOrUnknown(
              data['birth_weight']!, _birthWeightMeta));
    }
    if (data.containsKey('weight_30_days')) {
      context.handle(
          _weight30DaysMeta,
          weight30Days.isAcceptableOrUnknown(
              data['weight_30_days']!, _weight30DaysMeta));
    }
    if (data.containsKey('weight_60_days')) {
      context.handle(
          _weight60DaysMeta,
          weight60Days.isAcceptableOrUnknown(
              data['weight_60_days']!, _weight60DaysMeta));
    }
    if (data.containsKey('weight_90_days')) {
      context.handle(
          _weight90DaysMeta,
          weight90Days.isAcceptableOrUnknown(
              data['weight_90_days']!, _weight90DaysMeta));
    }
    if (data.containsKey('weight_120_days')) {
      context.handle(
          _weight120DaysMeta,
          weight120Days.isAcceptableOrUnknown(
              data['weight_120_days']!, _weight120DaysMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('lote')) {
      context.handle(
          _loteMeta, lote.isAcceptableOrUnknown(data['lote']!, _loteMeta));
    }
    if (data.containsKey('mother_id')) {
      context.handle(_motherIdMeta,
          motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta));
    }
    if (data.containsKey('father_id')) {
      context.handle(_fatherIdMeta,
          fatherId.isAcceptableOrUnknown(data['father_id']!, _fatherIdMeta));
    }
    if (data.containsKey('registration_note')) {
      context.handle(
          _registrationNoteMeta,
          registrationNote.isAcceptableOrUnknown(
              data['registration_note']!, _registrationNoteMeta));
    }
    if (data.containsKey('sale_date')) {
      context.handle(_saleDateMeta,
          saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta));
    } else if (isInserting) {
      context.missing(_saleDateMeta);
    }
    if (data.containsKey('sale_price')) {
      context.handle(_salePriceMeta,
          salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta));
    }
    if (data.containsKey('buyer')) {
      context.handle(
          _buyerMeta, buyer.isAcceptableOrUnknown(data['buyer']!, _buyerMeta));
    }
    if (data.containsKey('sale_notes')) {
      context.handle(_saleNotesMeta,
          saleNotes.isAcceptableOrUnknown(data['sale_notes']!, _saleNotesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SoldAnimalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SoldAnimalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      originalAnimalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_animal_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_date'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      reproductiveStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reproductive_status'])!,
      nameColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_color']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      birthWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}birth_weight']),
      weight30Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_30_days']),
      weight60Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_60_days']),
      weight90Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_90_days']),
      weight120Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_120_days']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      lote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote']),
      motherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mother_id']),
      fatherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}father_id']),
      registrationNote: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}registration_note']),
      saleDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_date'])!,
      salePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sale_price']),
      buyer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer']),
      saleNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SoldAnimalsTable createAlias(String alias) {
    return $SoldAnimalsTable(attachedDatabase, alias);
  }
}

class SoldAnimalRow extends DataClass implements Insertable<SoldAnimalRow> {
  final String id;
  final String? farmId;
  final String originalAnimalId;
  final String code;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final String birthDate;
  final double weight;
  final String location;
  final String reproductiveStatus;
  final String? nameColor;
  final String? category;
  final double? birthWeight;
  final double? weight30Days;
  final double? weight60Days;
  final double? weight90Days;
  final double? weight120Days;
  final int? year;
  final String? lote;
  final String? motherId;
  final String? fatherId;
  final String? registrationNote;
  final String saleDate;
  final double? salePrice;
  final String? buyer;
  final String? saleNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SoldAnimalRow(
      {required this.id,
      this.farmId,
      required this.originalAnimalId,
      required this.code,
      required this.name,
      required this.species,
      required this.breed,
      required this.gender,
      required this.birthDate,
      required this.weight,
      required this.location,
      required this.reproductiveStatus,
      this.nameColor,
      this.category,
      this.birthWeight,
      this.weight30Days,
      this.weight60Days,
      this.weight90Days,
      this.weight120Days,
      this.year,
      this.lote,
      this.motherId,
      this.fatherId,
      this.registrationNote,
      required this.saleDate,
      this.salePrice,
      this.buyer,
      this.saleNotes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['original_animal_id'] = Variable<String>(originalAnimalId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['species'] = Variable<String>(species);
    map['breed'] = Variable<String>(breed);
    map['gender'] = Variable<String>(gender);
    map['birth_date'] = Variable<String>(birthDate);
    map['weight'] = Variable<double>(weight);
    map['location'] = Variable<String>(location);
    map['reproductive_status'] = Variable<String>(reproductiveStatus);
    if (!nullToAbsent || nameColor != null) {
      map['name_color'] = Variable<String>(nameColor);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || birthWeight != null) {
      map['birth_weight'] = Variable<double>(birthWeight);
    }
    if (!nullToAbsent || weight30Days != null) {
      map['weight_30_days'] = Variable<double>(weight30Days);
    }
    if (!nullToAbsent || weight60Days != null) {
      map['weight_60_days'] = Variable<double>(weight60Days);
    }
    if (!nullToAbsent || weight90Days != null) {
      map['weight_90_days'] = Variable<double>(weight90Days);
    }
    if (!nullToAbsent || weight120Days != null) {
      map['weight_120_days'] = Variable<double>(weight120Days);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || lote != null) {
      map['lote'] = Variable<String>(lote);
    }
    if (!nullToAbsent || motherId != null) {
      map['mother_id'] = Variable<String>(motherId);
    }
    if (!nullToAbsent || fatherId != null) {
      map['father_id'] = Variable<String>(fatherId);
    }
    if (!nullToAbsent || registrationNote != null) {
      map['registration_note'] = Variable<String>(registrationNote);
    }
    map['sale_date'] = Variable<String>(saleDate);
    if (!nullToAbsent || salePrice != null) {
      map['sale_price'] = Variable<double>(salePrice);
    }
    if (!nullToAbsent || buyer != null) {
      map['buyer'] = Variable<String>(buyer);
    }
    if (!nullToAbsent || saleNotes != null) {
      map['sale_notes'] = Variable<String>(saleNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SoldAnimalsCompanion toCompanion(bool nullToAbsent) {
    return SoldAnimalsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      originalAnimalId: Value(originalAnimalId),
      code: Value(code),
      name: Value(name),
      species: Value(species),
      breed: Value(breed),
      gender: Value(gender),
      birthDate: Value(birthDate),
      weight: Value(weight),
      location: Value(location),
      reproductiveStatus: Value(reproductiveStatus),
      nameColor: nameColor == null && nullToAbsent
          ? const Value.absent()
          : Value(nameColor),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      birthWeight: birthWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(birthWeight),
      weight30Days: weight30Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight30Days),
      weight60Days: weight60Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight60Days),
      weight90Days: weight90Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight90Days),
      weight120Days: weight120Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight120Days),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      lote: lote == null && nullToAbsent ? const Value.absent() : Value(lote),
      motherId: motherId == null && nullToAbsent
          ? const Value.absent()
          : Value(motherId),
      fatherId: fatherId == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherId),
      registrationNote: registrationNote == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNote),
      saleDate: Value(saleDate),
      salePrice: salePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(salePrice),
      buyer:
          buyer == null && nullToAbsent ? const Value.absent() : Value(buyer),
      saleNotes: saleNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(saleNotes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SoldAnimalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SoldAnimalRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      originalAnimalId: serializer.fromJson<String>(json['originalAnimalId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String>(json['breed']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<String>(json['birthDate']),
      weight: serializer.fromJson<double>(json['weight']),
      location: serializer.fromJson<String>(json['location']),
      reproductiveStatus:
          serializer.fromJson<String>(json['reproductiveStatus']),
      nameColor: serializer.fromJson<String?>(json['nameColor']),
      category: serializer.fromJson<String?>(json['category']),
      birthWeight: serializer.fromJson<double?>(json['birthWeight']),
      weight30Days: serializer.fromJson<double?>(json['weight30Days']),
      weight60Days: serializer.fromJson<double?>(json['weight60Days']),
      weight90Days: serializer.fromJson<double?>(json['weight90Days']),
      weight120Days: serializer.fromJson<double?>(json['weight120Days']),
      year: serializer.fromJson<int?>(json['year']),
      lote: serializer.fromJson<String?>(json['lote']),
      motherId: serializer.fromJson<String?>(json['motherId']),
      fatherId: serializer.fromJson<String?>(json['fatherId']),
      registrationNote: serializer.fromJson<String?>(json['registrationNote']),
      saleDate: serializer.fromJson<String>(json['saleDate']),
      salePrice: serializer.fromJson<double?>(json['salePrice']),
      buyer: serializer.fromJson<String?>(json['buyer']),
      saleNotes: serializer.fromJson<String?>(json['saleNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'originalAnimalId': serializer.toJson<String>(originalAnimalId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String>(breed),
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<String>(birthDate),
      'weight': serializer.toJson<double>(weight),
      'location': serializer.toJson<String>(location),
      'reproductiveStatus': serializer.toJson<String>(reproductiveStatus),
      'nameColor': serializer.toJson<String?>(nameColor),
      'category': serializer.toJson<String?>(category),
      'birthWeight': serializer.toJson<double?>(birthWeight),
      'weight30Days': serializer.toJson<double?>(weight30Days),
      'weight60Days': serializer.toJson<double?>(weight60Days),
      'weight90Days': serializer.toJson<double?>(weight90Days),
      'weight120Days': serializer.toJson<double?>(weight120Days),
      'year': serializer.toJson<int?>(year),
      'lote': serializer.toJson<String?>(lote),
      'motherId': serializer.toJson<String?>(motherId),
      'fatherId': serializer.toJson<String?>(fatherId),
      'registrationNote': serializer.toJson<String?>(registrationNote),
      'saleDate': serializer.toJson<String>(saleDate),
      'salePrice': serializer.toJson<double?>(salePrice),
      'buyer': serializer.toJson<String?>(buyer),
      'saleNotes': serializer.toJson<String?>(saleNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SoldAnimalRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? originalAnimalId,
          String? code,
          String? name,
          String? species,
          String? breed,
          String? gender,
          String? birthDate,
          double? weight,
          String? location,
          String? reproductiveStatus,
          Value<String?> nameColor = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<double?> birthWeight = const Value.absent(),
          Value<double?> weight30Days = const Value.absent(),
          Value<double?> weight60Days = const Value.absent(),
          Value<double?> weight90Days = const Value.absent(),
          Value<double?> weight120Days = const Value.absent(),
          Value<int?> year = const Value.absent(),
          Value<String?> lote = const Value.absent(),
          Value<String?> motherId = const Value.absent(),
          Value<String?> fatherId = const Value.absent(),
          Value<String?> registrationNote = const Value.absent(),
          String? saleDate,
          Value<double?> salePrice = const Value.absent(),
          Value<String?> buyer = const Value.absent(),
          Value<String?> saleNotes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SoldAnimalRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        originalAnimalId: originalAnimalId ?? this.originalAnimalId,
        code: code ?? this.code,
        name: name ?? this.name,
        species: species ?? this.species,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        weight: weight ?? this.weight,
        location: location ?? this.location,
        reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
        nameColor: nameColor.present ? nameColor.value : this.nameColor,
        category: category.present ? category.value : this.category,
        birthWeight: birthWeight.present ? birthWeight.value : this.birthWeight,
        weight30Days:
            weight30Days.present ? weight30Days.value : this.weight30Days,
        weight60Days:
            weight60Days.present ? weight60Days.value : this.weight60Days,
        weight90Days:
            weight90Days.present ? weight90Days.value : this.weight90Days,
        weight120Days:
            weight120Days.present ? weight120Days.value : this.weight120Days,
        year: year.present ? year.value : this.year,
        lote: lote.present ? lote.value : this.lote,
        motherId: motherId.present ? motherId.value : this.motherId,
        fatherId: fatherId.present ? fatherId.value : this.fatherId,
        registrationNote: registrationNote.present
            ? registrationNote.value
            : this.registrationNote,
        saleDate: saleDate ?? this.saleDate,
        salePrice: salePrice.present ? salePrice.value : this.salePrice,
        buyer: buyer.present ? buyer.value : this.buyer,
        saleNotes: saleNotes.present ? saleNotes.value : this.saleNotes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SoldAnimalRow copyWithCompanion(SoldAnimalsCompanion data) {
    return SoldAnimalRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      originalAnimalId: data.originalAnimalId.present
          ? data.originalAnimalId.value
          : this.originalAnimalId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      weight: data.weight.present ? data.weight.value : this.weight,
      location: data.location.present ? data.location.value : this.location,
      reproductiveStatus: data.reproductiveStatus.present
          ? data.reproductiveStatus.value
          : this.reproductiveStatus,
      nameColor: data.nameColor.present ? data.nameColor.value : this.nameColor,
      category: data.category.present ? data.category.value : this.category,
      birthWeight:
          data.birthWeight.present ? data.birthWeight.value : this.birthWeight,
      weight30Days: data.weight30Days.present
          ? data.weight30Days.value
          : this.weight30Days,
      weight60Days: data.weight60Days.present
          ? data.weight60Days.value
          : this.weight60Days,
      weight90Days: data.weight90Days.present
          ? data.weight90Days.value
          : this.weight90Days,
      weight120Days: data.weight120Days.present
          ? data.weight120Days.value
          : this.weight120Days,
      year: data.year.present ? data.year.value : this.year,
      lote: data.lote.present ? data.lote.value : this.lote,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      fatherId: data.fatherId.present ? data.fatherId.value : this.fatherId,
      registrationNote: data.registrationNote.present
          ? data.registrationNote.value
          : this.registrationNote,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      buyer: data.buyer.present ? data.buyer.value : this.buyer,
      saleNotes: data.saleNotes.present ? data.saleNotes.value : this.saleNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SoldAnimalRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('originalAnimalId: $originalAnimalId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('weight: $weight, ')
          ..write('location: $location, ')
          ..write('reproductiveStatus: $reproductiveStatus, ')
          ..write('nameColor: $nameColor, ')
          ..write('category: $category, ')
          ..write('birthWeight: $birthWeight, ')
          ..write('weight30Days: $weight30Days, ')
          ..write('weight60Days: $weight60Days, ')
          ..write('weight90Days: $weight90Days, ')
          ..write('weight120Days: $weight120Days, ')
          ..write('year: $year, ')
          ..write('lote: $lote, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('registrationNote: $registrationNote, ')
          ..write('saleDate: $saleDate, ')
          ..write('salePrice: $salePrice, ')
          ..write('buyer: $buyer, ')
          ..write('saleNotes: $saleNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        farmId,
        originalAnimalId,
        code,
        name,
        species,
        breed,
        gender,
        birthDate,
        weight,
        location,
        reproductiveStatus,
        nameColor,
        category,
        birthWeight,
        weight30Days,
        weight60Days,
        weight90Days,
        weight120Days,
        year,
        lote,
        motherId,
        fatherId,
        registrationNote,
        saleDate,
        salePrice,
        buyer,
        saleNotes,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SoldAnimalRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.originalAnimalId == this.originalAnimalId &&
          other.code == this.code &&
          other.name == this.name &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.weight == this.weight &&
          other.location == this.location &&
          other.reproductiveStatus == this.reproductiveStatus &&
          other.nameColor == this.nameColor &&
          other.category == this.category &&
          other.birthWeight == this.birthWeight &&
          other.weight30Days == this.weight30Days &&
          other.weight60Days == this.weight60Days &&
          other.weight90Days == this.weight90Days &&
          other.weight120Days == this.weight120Days &&
          other.year == this.year &&
          other.lote == this.lote &&
          other.motherId == this.motherId &&
          other.fatherId == this.fatherId &&
          other.registrationNote == this.registrationNote &&
          other.saleDate == this.saleDate &&
          other.salePrice == this.salePrice &&
          other.buyer == this.buyer &&
          other.saleNotes == this.saleNotes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SoldAnimalsCompanion extends UpdateCompanion<SoldAnimalRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> originalAnimalId;
  final Value<String> code;
  final Value<String> name;
  final Value<String> species;
  final Value<String> breed;
  final Value<String> gender;
  final Value<String> birthDate;
  final Value<double> weight;
  final Value<String> location;
  final Value<String> reproductiveStatus;
  final Value<String?> nameColor;
  final Value<String?> category;
  final Value<double?> birthWeight;
  final Value<double?> weight30Days;
  final Value<double?> weight60Days;
  final Value<double?> weight90Days;
  final Value<double?> weight120Days;
  final Value<int?> year;
  final Value<String?> lote;
  final Value<String?> motherId;
  final Value<String?> fatherId;
  final Value<String?> registrationNote;
  final Value<String> saleDate;
  final Value<double?> salePrice;
  final Value<String?> buyer;
  final Value<String?> saleNotes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SoldAnimalsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.originalAnimalId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.weight = const Value.absent(),
    this.location = const Value.absent(),
    this.reproductiveStatus = const Value.absent(),
    this.nameColor = const Value.absent(),
    this.category = const Value.absent(),
    this.birthWeight = const Value.absent(),
    this.weight30Days = const Value.absent(),
    this.weight60Days = const Value.absent(),
    this.weight90Days = const Value.absent(),
    this.weight120Days = const Value.absent(),
    this.year = const Value.absent(),
    this.lote = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.registrationNote = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.buyer = const Value.absent(),
    this.saleNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SoldAnimalsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String originalAnimalId,
    required String code,
    required String name,
    required String species,
    required String breed,
    required String gender,
    required String birthDate,
    required double weight,
    required String location,
    this.reproductiveStatus = const Value.absent(),
    this.nameColor = const Value.absent(),
    this.category = const Value.absent(),
    this.birthWeight = const Value.absent(),
    this.weight30Days = const Value.absent(),
    this.weight60Days = const Value.absent(),
    this.weight90Days = const Value.absent(),
    this.weight120Days = const Value.absent(),
    this.year = const Value.absent(),
    this.lote = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.registrationNote = const Value.absent(),
    required String saleDate,
    this.salePrice = const Value.absent(),
    this.buyer = const Value.absent(),
    this.saleNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        originalAnimalId = Value(originalAnimalId),
        code = Value(code),
        name = Value(name),
        species = Value(species),
        breed = Value(breed),
        gender = Value(gender),
        birthDate = Value(birthDate),
        weight = Value(weight),
        location = Value(location),
        saleDate = Value(saleDate);
  static Insertable<SoldAnimalRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? originalAnimalId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? gender,
    Expression<String>? birthDate,
    Expression<double>? weight,
    Expression<String>? location,
    Expression<String>? reproductiveStatus,
    Expression<String>? nameColor,
    Expression<String>? category,
    Expression<double>? birthWeight,
    Expression<double>? weight30Days,
    Expression<double>? weight60Days,
    Expression<double>? weight90Days,
    Expression<double>? weight120Days,
    Expression<int>? year,
    Expression<String>? lote,
    Expression<String>? motherId,
    Expression<String>? fatherId,
    Expression<String>? registrationNote,
    Expression<String>? saleDate,
    Expression<double>? salePrice,
    Expression<String>? buyer,
    Expression<String>? saleNotes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (originalAnimalId != null) 'original_animal_id': originalAnimalId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (weight != null) 'weight': weight,
      if (location != null) 'location': location,
      if (reproductiveStatus != null) 'reproductive_status': reproductiveStatus,
      if (nameColor != null) 'name_color': nameColor,
      if (category != null) 'category': category,
      if (birthWeight != null) 'birth_weight': birthWeight,
      if (weight30Days != null) 'weight_30_days': weight30Days,
      if (weight60Days != null) 'weight_60_days': weight60Days,
      if (weight90Days != null) 'weight_90_days': weight90Days,
      if (weight120Days != null) 'weight_120_days': weight120Days,
      if (year != null) 'year': year,
      if (lote != null) 'lote': lote,
      if (motherId != null) 'mother_id': motherId,
      if (fatherId != null) 'father_id': fatherId,
      if (registrationNote != null) 'registration_note': registrationNote,
      if (saleDate != null) 'sale_date': saleDate,
      if (salePrice != null) 'sale_price': salePrice,
      if (buyer != null) 'buyer': buyer,
      if (saleNotes != null) 'sale_notes': saleNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SoldAnimalsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? originalAnimalId,
      Value<String>? code,
      Value<String>? name,
      Value<String>? species,
      Value<String>? breed,
      Value<String>? gender,
      Value<String>? birthDate,
      Value<double>? weight,
      Value<String>? location,
      Value<String>? reproductiveStatus,
      Value<String?>? nameColor,
      Value<String?>? category,
      Value<double?>? birthWeight,
      Value<double?>? weight30Days,
      Value<double?>? weight60Days,
      Value<double?>? weight90Days,
      Value<double?>? weight120Days,
      Value<int?>? year,
      Value<String?>? lote,
      Value<String?>? motherId,
      Value<String?>? fatherId,
      Value<String?>? registrationNote,
      Value<String>? saleDate,
      Value<double?>? salePrice,
      Value<String?>? buyer,
      Value<String?>? saleNotes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SoldAnimalsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      originalAnimalId: originalAnimalId ?? this.originalAnimalId,
      code: code ?? this.code,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      location: location ?? this.location,
      reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
      nameColor: nameColor ?? this.nameColor,
      category: category ?? this.category,
      birthWeight: birthWeight ?? this.birthWeight,
      weight30Days: weight30Days ?? this.weight30Days,
      weight60Days: weight60Days ?? this.weight60Days,
      weight90Days: weight90Days ?? this.weight90Days,
      weight120Days: weight120Days ?? this.weight120Days,
      year: year ?? this.year,
      lote: lote ?? this.lote,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
      registrationNote: registrationNote ?? this.registrationNote,
      saleDate: saleDate ?? this.saleDate,
      salePrice: salePrice ?? this.salePrice,
      buyer: buyer ?? this.buyer,
      saleNotes: saleNotes ?? this.saleNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (originalAnimalId.present) {
      map['original_animal_id'] = Variable<String>(originalAnimalId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (reproductiveStatus.present) {
      map['reproductive_status'] = Variable<String>(reproductiveStatus.value);
    }
    if (nameColor.present) {
      map['name_color'] = Variable<String>(nameColor.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (birthWeight.present) {
      map['birth_weight'] = Variable<double>(birthWeight.value);
    }
    if (weight30Days.present) {
      map['weight_30_days'] = Variable<double>(weight30Days.value);
    }
    if (weight60Days.present) {
      map['weight_60_days'] = Variable<double>(weight60Days.value);
    }
    if (weight90Days.present) {
      map['weight_90_days'] = Variable<double>(weight90Days.value);
    }
    if (weight120Days.present) {
      map['weight_120_days'] = Variable<double>(weight120Days.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (lote.present) {
      map['lote'] = Variable<String>(lote.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<String>(motherId.value);
    }
    if (fatherId.present) {
      map['father_id'] = Variable<String>(fatherId.value);
    }
    if (registrationNote.present) {
      map['registration_note'] = Variable<String>(registrationNote.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<String>(saleDate.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (buyer.present) {
      map['buyer'] = Variable<String>(buyer.value);
    }
    if (saleNotes.present) {
      map['sale_notes'] = Variable<String>(saleNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SoldAnimalsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('originalAnimalId: $originalAnimalId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('weight: $weight, ')
          ..write('location: $location, ')
          ..write('reproductiveStatus: $reproductiveStatus, ')
          ..write('nameColor: $nameColor, ')
          ..write('category: $category, ')
          ..write('birthWeight: $birthWeight, ')
          ..write('weight30Days: $weight30Days, ')
          ..write('weight60Days: $weight60Days, ')
          ..write('weight90Days: $weight90Days, ')
          ..write('weight120Days: $weight120Days, ')
          ..write('year: $year, ')
          ..write('lote: $lote, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('registrationNote: $registrationNote, ')
          ..write('saleDate: $saleDate, ')
          ..write('salePrice: $salePrice, ')
          ..write('buyer: $buyer, ')
          ..write('saleNotes: $saleNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeceasedAnimalsTable extends DeceasedAnimals
    with TableInfo<$DeceasedAnimalsTable, DeceasedAnimalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeceasedAnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _originalAnimalIdMeta =
      const VerificationMeta('originalAnimalId');
  @override
  late final GeneratedColumn<String> originalAnimalId = GeneratedColumn<String>(
      'original_animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reproductiveStatusMeta =
      const VerificationMeta('reproductiveStatus');
  @override
  late final GeneratedColumn<String> reproductiveStatus =
      GeneratedColumn<String>('reproductive_status', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('Não aplicável'));
  static const VerificationMeta _nameColorMeta =
      const VerificationMeta('nameColor');
  @override
  late final GeneratedColumn<String> nameColor = GeneratedColumn<String>(
      'name_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthWeightMeta =
      const VerificationMeta('birthWeight');
  @override
  late final GeneratedColumn<double> birthWeight = GeneratedColumn<double>(
      'birth_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight30DaysMeta =
      const VerificationMeta('weight30Days');
  @override
  late final GeneratedColumn<double> weight30Days = GeneratedColumn<double>(
      'weight_30_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight60DaysMeta =
      const VerificationMeta('weight60Days');
  @override
  late final GeneratedColumn<double> weight60Days = GeneratedColumn<double>(
      'weight_60_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight90DaysMeta =
      const VerificationMeta('weight90Days');
  @override
  late final GeneratedColumn<double> weight90Days = GeneratedColumn<double>(
      'weight_90_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weight120DaysMeta =
      const VerificationMeta('weight120Days');
  @override
  late final GeneratedColumn<double> weight120Days = GeneratedColumn<double>(
      'weight_120_days', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _loteMeta = const VerificationMeta('lote');
  @override
  late final GeneratedColumn<String> lote = GeneratedColumn<String>(
      'lote', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _motherIdMeta =
      const VerificationMeta('motherId');
  @override
  late final GeneratedColumn<String> motherId = GeneratedColumn<String>(
      'mother_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fatherIdMeta =
      const VerificationMeta('fatherId');
  @override
  late final GeneratedColumn<String> fatherId = GeneratedColumn<String>(
      'father_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _registrationNoteMeta =
      const VerificationMeta('registrationNote');
  @override
  late final GeneratedColumn<String> registrationNote = GeneratedColumn<String>(
      'registration_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deathDateMeta =
      const VerificationMeta('deathDate');
  @override
  late final GeneratedColumn<String> deathDate = GeneratedColumn<String>(
      'death_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _causeOfDeathMeta =
      const VerificationMeta('causeOfDeath');
  @override
  late final GeneratedColumn<String> causeOfDeath = GeneratedColumn<String>(
      'cause_of_death', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deathNotesMeta =
      const VerificationMeta('deathNotes');
  @override
  late final GeneratedColumn<String> deathNotes = GeneratedColumn<String>(
      'death_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        originalAnimalId,
        code,
        name,
        species,
        breed,
        gender,
        birthDate,
        weight,
        location,
        reproductiveStatus,
        nameColor,
        category,
        birthWeight,
        weight30Days,
        weight60Days,
        weight90Days,
        weight120Days,
        year,
        lote,
        motherId,
        fatherId,
        registrationNote,
        deathDate,
        causeOfDeath,
        deathNotes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deceased_animals';
  @override
  VerificationContext validateIntegrity(Insertable<DeceasedAnimalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('original_animal_id')) {
      context.handle(
          _originalAnimalIdMeta,
          originalAnimalId.isAcceptableOrUnknown(
              data['original_animal_id']!, _originalAnimalIdMeta));
    } else if (isInserting) {
      context.missing(_originalAnimalIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    } else if (isInserting) {
      context.missing(_breedMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('reproductive_status')) {
      context.handle(
          _reproductiveStatusMeta,
          reproductiveStatus.isAcceptableOrUnknown(
              data['reproductive_status']!, _reproductiveStatusMeta));
    }
    if (data.containsKey('name_color')) {
      context.handle(_nameColorMeta,
          nameColor.isAcceptableOrUnknown(data['name_color']!, _nameColorMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('birth_weight')) {
      context.handle(
          _birthWeightMeta,
          birthWeight.isAcceptableOrUnknown(
              data['birth_weight']!, _birthWeightMeta));
    }
    if (data.containsKey('weight_30_days')) {
      context.handle(
          _weight30DaysMeta,
          weight30Days.isAcceptableOrUnknown(
              data['weight_30_days']!, _weight30DaysMeta));
    }
    if (data.containsKey('weight_60_days')) {
      context.handle(
          _weight60DaysMeta,
          weight60Days.isAcceptableOrUnknown(
              data['weight_60_days']!, _weight60DaysMeta));
    }
    if (data.containsKey('weight_90_days')) {
      context.handle(
          _weight90DaysMeta,
          weight90Days.isAcceptableOrUnknown(
              data['weight_90_days']!, _weight90DaysMeta));
    }
    if (data.containsKey('weight_120_days')) {
      context.handle(
          _weight120DaysMeta,
          weight120Days.isAcceptableOrUnknown(
              data['weight_120_days']!, _weight120DaysMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('lote')) {
      context.handle(
          _loteMeta, lote.isAcceptableOrUnknown(data['lote']!, _loteMeta));
    }
    if (data.containsKey('mother_id')) {
      context.handle(_motherIdMeta,
          motherId.isAcceptableOrUnknown(data['mother_id']!, _motherIdMeta));
    }
    if (data.containsKey('father_id')) {
      context.handle(_fatherIdMeta,
          fatherId.isAcceptableOrUnknown(data['father_id']!, _fatherIdMeta));
    }
    if (data.containsKey('registration_note')) {
      context.handle(
          _registrationNoteMeta,
          registrationNote.isAcceptableOrUnknown(
              data['registration_note']!, _registrationNoteMeta));
    }
    if (data.containsKey('death_date')) {
      context.handle(_deathDateMeta,
          deathDate.isAcceptableOrUnknown(data['death_date']!, _deathDateMeta));
    } else if (isInserting) {
      context.missing(_deathDateMeta);
    }
    if (data.containsKey('cause_of_death')) {
      context.handle(
          _causeOfDeathMeta,
          causeOfDeath.isAcceptableOrUnknown(
              data['cause_of_death']!, _causeOfDeathMeta));
    }
    if (data.containsKey('death_notes')) {
      context.handle(
          _deathNotesMeta,
          deathNotes.isAcceptableOrUnknown(
              data['death_notes']!, _deathNotesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeceasedAnimalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeceasedAnimalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      originalAnimalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_animal_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_date'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      reproductiveStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reproductive_status'])!,
      nameColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_color']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      birthWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}birth_weight']),
      weight30Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_30_days']),
      weight60Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_60_days']),
      weight90Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_90_days']),
      weight120Days: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_120_days']),
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      lote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lote']),
      motherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mother_id']),
      fatherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}father_id']),
      registrationNote: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}registration_note']),
      deathDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}death_date'])!,
      causeOfDeath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cause_of_death']),
      deathNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}death_notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DeceasedAnimalsTable createAlias(String alias) {
    return $DeceasedAnimalsTable(attachedDatabase, alias);
  }
}

class DeceasedAnimalRow extends DataClass
    implements Insertable<DeceasedAnimalRow> {
  final String id;
  final String? farmId;
  final String originalAnimalId;
  final String code;
  final String name;
  final String species;
  final String breed;
  final String gender;
  final String birthDate;
  final double weight;
  final String location;
  final String reproductiveStatus;
  final String? nameColor;
  final String? category;
  final double? birthWeight;
  final double? weight30Days;
  final double? weight60Days;
  final double? weight90Days;
  final double? weight120Days;
  final int? year;
  final String? lote;
  final String? motherId;
  final String? fatherId;
  final String? registrationNote;
  final String deathDate;
  final String? causeOfDeath;
  final String? deathNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DeceasedAnimalRow(
      {required this.id,
      this.farmId,
      required this.originalAnimalId,
      required this.code,
      required this.name,
      required this.species,
      required this.breed,
      required this.gender,
      required this.birthDate,
      required this.weight,
      required this.location,
      required this.reproductiveStatus,
      this.nameColor,
      this.category,
      this.birthWeight,
      this.weight30Days,
      this.weight60Days,
      this.weight90Days,
      this.weight120Days,
      this.year,
      this.lote,
      this.motherId,
      this.fatherId,
      this.registrationNote,
      required this.deathDate,
      this.causeOfDeath,
      this.deathNotes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['original_animal_id'] = Variable<String>(originalAnimalId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['species'] = Variable<String>(species);
    map['breed'] = Variable<String>(breed);
    map['gender'] = Variable<String>(gender);
    map['birth_date'] = Variable<String>(birthDate);
    map['weight'] = Variable<double>(weight);
    map['location'] = Variable<String>(location);
    map['reproductive_status'] = Variable<String>(reproductiveStatus);
    if (!nullToAbsent || nameColor != null) {
      map['name_color'] = Variable<String>(nameColor);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || birthWeight != null) {
      map['birth_weight'] = Variable<double>(birthWeight);
    }
    if (!nullToAbsent || weight30Days != null) {
      map['weight_30_days'] = Variable<double>(weight30Days);
    }
    if (!nullToAbsent || weight60Days != null) {
      map['weight_60_days'] = Variable<double>(weight60Days);
    }
    if (!nullToAbsent || weight90Days != null) {
      map['weight_90_days'] = Variable<double>(weight90Days);
    }
    if (!nullToAbsent || weight120Days != null) {
      map['weight_120_days'] = Variable<double>(weight120Days);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || lote != null) {
      map['lote'] = Variable<String>(lote);
    }
    if (!nullToAbsent || motherId != null) {
      map['mother_id'] = Variable<String>(motherId);
    }
    if (!nullToAbsent || fatherId != null) {
      map['father_id'] = Variable<String>(fatherId);
    }
    if (!nullToAbsent || registrationNote != null) {
      map['registration_note'] = Variable<String>(registrationNote);
    }
    map['death_date'] = Variable<String>(deathDate);
    if (!nullToAbsent || causeOfDeath != null) {
      map['cause_of_death'] = Variable<String>(causeOfDeath);
    }
    if (!nullToAbsent || deathNotes != null) {
      map['death_notes'] = Variable<String>(deathNotes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DeceasedAnimalsCompanion toCompanion(bool nullToAbsent) {
    return DeceasedAnimalsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      originalAnimalId: Value(originalAnimalId),
      code: Value(code),
      name: Value(name),
      species: Value(species),
      breed: Value(breed),
      gender: Value(gender),
      birthDate: Value(birthDate),
      weight: Value(weight),
      location: Value(location),
      reproductiveStatus: Value(reproductiveStatus),
      nameColor: nameColor == null && nullToAbsent
          ? const Value.absent()
          : Value(nameColor),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      birthWeight: birthWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(birthWeight),
      weight30Days: weight30Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight30Days),
      weight60Days: weight60Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight60Days),
      weight90Days: weight90Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight90Days),
      weight120Days: weight120Days == null && nullToAbsent
          ? const Value.absent()
          : Value(weight120Days),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      lote: lote == null && nullToAbsent ? const Value.absent() : Value(lote),
      motherId: motherId == null && nullToAbsent
          ? const Value.absent()
          : Value(motherId),
      fatherId: fatherId == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherId),
      registrationNote: registrationNote == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationNote),
      deathDate: Value(deathDate),
      causeOfDeath: causeOfDeath == null && nullToAbsent
          ? const Value.absent()
          : Value(causeOfDeath),
      deathNotes: deathNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(deathNotes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeceasedAnimalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeceasedAnimalRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      originalAnimalId: serializer.fromJson<String>(json['originalAnimalId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String>(json['breed']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<String>(json['birthDate']),
      weight: serializer.fromJson<double>(json['weight']),
      location: serializer.fromJson<String>(json['location']),
      reproductiveStatus:
          serializer.fromJson<String>(json['reproductiveStatus']),
      nameColor: serializer.fromJson<String?>(json['nameColor']),
      category: serializer.fromJson<String?>(json['category']),
      birthWeight: serializer.fromJson<double?>(json['birthWeight']),
      weight30Days: serializer.fromJson<double?>(json['weight30Days']),
      weight60Days: serializer.fromJson<double?>(json['weight60Days']),
      weight90Days: serializer.fromJson<double?>(json['weight90Days']),
      weight120Days: serializer.fromJson<double?>(json['weight120Days']),
      year: serializer.fromJson<int?>(json['year']),
      lote: serializer.fromJson<String?>(json['lote']),
      motherId: serializer.fromJson<String?>(json['motherId']),
      fatherId: serializer.fromJson<String?>(json['fatherId']),
      registrationNote: serializer.fromJson<String?>(json['registrationNote']),
      deathDate: serializer.fromJson<String>(json['deathDate']),
      causeOfDeath: serializer.fromJson<String?>(json['causeOfDeath']),
      deathNotes: serializer.fromJson<String?>(json['deathNotes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'originalAnimalId': serializer.toJson<String>(originalAnimalId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String>(breed),
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<String>(birthDate),
      'weight': serializer.toJson<double>(weight),
      'location': serializer.toJson<String>(location),
      'reproductiveStatus': serializer.toJson<String>(reproductiveStatus),
      'nameColor': serializer.toJson<String?>(nameColor),
      'category': serializer.toJson<String?>(category),
      'birthWeight': serializer.toJson<double?>(birthWeight),
      'weight30Days': serializer.toJson<double?>(weight30Days),
      'weight60Days': serializer.toJson<double?>(weight60Days),
      'weight90Days': serializer.toJson<double?>(weight90Days),
      'weight120Days': serializer.toJson<double?>(weight120Days),
      'year': serializer.toJson<int?>(year),
      'lote': serializer.toJson<String?>(lote),
      'motherId': serializer.toJson<String?>(motherId),
      'fatherId': serializer.toJson<String?>(fatherId),
      'registrationNote': serializer.toJson<String?>(registrationNote),
      'deathDate': serializer.toJson<String>(deathDate),
      'causeOfDeath': serializer.toJson<String?>(causeOfDeath),
      'deathNotes': serializer.toJson<String?>(deathNotes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeceasedAnimalRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? originalAnimalId,
          String? code,
          String? name,
          String? species,
          String? breed,
          String? gender,
          String? birthDate,
          double? weight,
          String? location,
          String? reproductiveStatus,
          Value<String?> nameColor = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<double?> birthWeight = const Value.absent(),
          Value<double?> weight30Days = const Value.absent(),
          Value<double?> weight60Days = const Value.absent(),
          Value<double?> weight90Days = const Value.absent(),
          Value<double?> weight120Days = const Value.absent(),
          Value<int?> year = const Value.absent(),
          Value<String?> lote = const Value.absent(),
          Value<String?> motherId = const Value.absent(),
          Value<String?> fatherId = const Value.absent(),
          Value<String?> registrationNote = const Value.absent(),
          String? deathDate,
          Value<String?> causeOfDeath = const Value.absent(),
          Value<String?> deathNotes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DeceasedAnimalRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        originalAnimalId: originalAnimalId ?? this.originalAnimalId,
        code: code ?? this.code,
        name: name ?? this.name,
        species: species ?? this.species,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        weight: weight ?? this.weight,
        location: location ?? this.location,
        reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
        nameColor: nameColor.present ? nameColor.value : this.nameColor,
        category: category.present ? category.value : this.category,
        birthWeight: birthWeight.present ? birthWeight.value : this.birthWeight,
        weight30Days:
            weight30Days.present ? weight30Days.value : this.weight30Days,
        weight60Days:
            weight60Days.present ? weight60Days.value : this.weight60Days,
        weight90Days:
            weight90Days.present ? weight90Days.value : this.weight90Days,
        weight120Days:
            weight120Days.present ? weight120Days.value : this.weight120Days,
        year: year.present ? year.value : this.year,
        lote: lote.present ? lote.value : this.lote,
        motherId: motherId.present ? motherId.value : this.motherId,
        fatherId: fatherId.present ? fatherId.value : this.fatherId,
        registrationNote: registrationNote.present
            ? registrationNote.value
            : this.registrationNote,
        deathDate: deathDate ?? this.deathDate,
        causeOfDeath:
            causeOfDeath.present ? causeOfDeath.value : this.causeOfDeath,
        deathNotes: deathNotes.present ? deathNotes.value : this.deathNotes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DeceasedAnimalRow copyWithCompanion(DeceasedAnimalsCompanion data) {
    return DeceasedAnimalRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      originalAnimalId: data.originalAnimalId.present
          ? data.originalAnimalId.value
          : this.originalAnimalId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      weight: data.weight.present ? data.weight.value : this.weight,
      location: data.location.present ? data.location.value : this.location,
      reproductiveStatus: data.reproductiveStatus.present
          ? data.reproductiveStatus.value
          : this.reproductiveStatus,
      nameColor: data.nameColor.present ? data.nameColor.value : this.nameColor,
      category: data.category.present ? data.category.value : this.category,
      birthWeight:
          data.birthWeight.present ? data.birthWeight.value : this.birthWeight,
      weight30Days: data.weight30Days.present
          ? data.weight30Days.value
          : this.weight30Days,
      weight60Days: data.weight60Days.present
          ? data.weight60Days.value
          : this.weight60Days,
      weight90Days: data.weight90Days.present
          ? data.weight90Days.value
          : this.weight90Days,
      weight120Days: data.weight120Days.present
          ? data.weight120Days.value
          : this.weight120Days,
      year: data.year.present ? data.year.value : this.year,
      lote: data.lote.present ? data.lote.value : this.lote,
      motherId: data.motherId.present ? data.motherId.value : this.motherId,
      fatherId: data.fatherId.present ? data.fatherId.value : this.fatherId,
      registrationNote: data.registrationNote.present
          ? data.registrationNote.value
          : this.registrationNote,
      deathDate: data.deathDate.present ? data.deathDate.value : this.deathDate,
      causeOfDeath: data.causeOfDeath.present
          ? data.causeOfDeath.value
          : this.causeOfDeath,
      deathNotes:
          data.deathNotes.present ? data.deathNotes.value : this.deathNotes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeceasedAnimalRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('originalAnimalId: $originalAnimalId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('weight: $weight, ')
          ..write('location: $location, ')
          ..write('reproductiveStatus: $reproductiveStatus, ')
          ..write('nameColor: $nameColor, ')
          ..write('category: $category, ')
          ..write('birthWeight: $birthWeight, ')
          ..write('weight30Days: $weight30Days, ')
          ..write('weight60Days: $weight60Days, ')
          ..write('weight90Days: $weight90Days, ')
          ..write('weight120Days: $weight120Days, ')
          ..write('year: $year, ')
          ..write('lote: $lote, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('registrationNote: $registrationNote, ')
          ..write('deathDate: $deathDate, ')
          ..write('causeOfDeath: $causeOfDeath, ')
          ..write('deathNotes: $deathNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        farmId,
        originalAnimalId,
        code,
        name,
        species,
        breed,
        gender,
        birthDate,
        weight,
        location,
        reproductiveStatus,
        nameColor,
        category,
        birthWeight,
        weight30Days,
        weight60Days,
        weight90Days,
        weight120Days,
        year,
        lote,
        motherId,
        fatherId,
        registrationNote,
        deathDate,
        causeOfDeath,
        deathNotes,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeceasedAnimalRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.originalAnimalId == this.originalAnimalId &&
          other.code == this.code &&
          other.name == this.name &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.weight == this.weight &&
          other.location == this.location &&
          other.reproductiveStatus == this.reproductiveStatus &&
          other.nameColor == this.nameColor &&
          other.category == this.category &&
          other.birthWeight == this.birthWeight &&
          other.weight30Days == this.weight30Days &&
          other.weight60Days == this.weight60Days &&
          other.weight90Days == this.weight90Days &&
          other.weight120Days == this.weight120Days &&
          other.year == this.year &&
          other.lote == this.lote &&
          other.motherId == this.motherId &&
          other.fatherId == this.fatherId &&
          other.registrationNote == this.registrationNote &&
          other.deathDate == this.deathDate &&
          other.causeOfDeath == this.causeOfDeath &&
          other.deathNotes == this.deathNotes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DeceasedAnimalsCompanion extends UpdateCompanion<DeceasedAnimalRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> originalAnimalId;
  final Value<String> code;
  final Value<String> name;
  final Value<String> species;
  final Value<String> breed;
  final Value<String> gender;
  final Value<String> birthDate;
  final Value<double> weight;
  final Value<String> location;
  final Value<String> reproductiveStatus;
  final Value<String?> nameColor;
  final Value<String?> category;
  final Value<double?> birthWeight;
  final Value<double?> weight30Days;
  final Value<double?> weight60Days;
  final Value<double?> weight90Days;
  final Value<double?> weight120Days;
  final Value<int?> year;
  final Value<String?> lote;
  final Value<String?> motherId;
  final Value<String?> fatherId;
  final Value<String?> registrationNote;
  final Value<String> deathDate;
  final Value<String?> causeOfDeath;
  final Value<String?> deathNotes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DeceasedAnimalsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.originalAnimalId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.weight = const Value.absent(),
    this.location = const Value.absent(),
    this.reproductiveStatus = const Value.absent(),
    this.nameColor = const Value.absent(),
    this.category = const Value.absent(),
    this.birthWeight = const Value.absent(),
    this.weight30Days = const Value.absent(),
    this.weight60Days = const Value.absent(),
    this.weight90Days = const Value.absent(),
    this.weight120Days = const Value.absent(),
    this.year = const Value.absent(),
    this.lote = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.registrationNote = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.causeOfDeath = const Value.absent(),
    this.deathNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeceasedAnimalsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String originalAnimalId,
    required String code,
    required String name,
    required String species,
    required String breed,
    required String gender,
    required String birthDate,
    required double weight,
    required String location,
    this.reproductiveStatus = const Value.absent(),
    this.nameColor = const Value.absent(),
    this.category = const Value.absent(),
    this.birthWeight = const Value.absent(),
    this.weight30Days = const Value.absent(),
    this.weight60Days = const Value.absent(),
    this.weight90Days = const Value.absent(),
    this.weight120Days = const Value.absent(),
    this.year = const Value.absent(),
    this.lote = const Value.absent(),
    this.motherId = const Value.absent(),
    this.fatherId = const Value.absent(),
    this.registrationNote = const Value.absent(),
    required String deathDate,
    this.causeOfDeath = const Value.absent(),
    this.deathNotes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        originalAnimalId = Value(originalAnimalId),
        code = Value(code),
        name = Value(name),
        species = Value(species),
        breed = Value(breed),
        gender = Value(gender),
        birthDate = Value(birthDate),
        weight = Value(weight),
        location = Value(location),
        deathDate = Value(deathDate);
  static Insertable<DeceasedAnimalRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? originalAnimalId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? gender,
    Expression<String>? birthDate,
    Expression<double>? weight,
    Expression<String>? location,
    Expression<String>? reproductiveStatus,
    Expression<String>? nameColor,
    Expression<String>? category,
    Expression<double>? birthWeight,
    Expression<double>? weight30Days,
    Expression<double>? weight60Days,
    Expression<double>? weight90Days,
    Expression<double>? weight120Days,
    Expression<int>? year,
    Expression<String>? lote,
    Expression<String>? motherId,
    Expression<String>? fatherId,
    Expression<String>? registrationNote,
    Expression<String>? deathDate,
    Expression<String>? causeOfDeath,
    Expression<String>? deathNotes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (originalAnimalId != null) 'original_animal_id': originalAnimalId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (weight != null) 'weight': weight,
      if (location != null) 'location': location,
      if (reproductiveStatus != null) 'reproductive_status': reproductiveStatus,
      if (nameColor != null) 'name_color': nameColor,
      if (category != null) 'category': category,
      if (birthWeight != null) 'birth_weight': birthWeight,
      if (weight30Days != null) 'weight_30_days': weight30Days,
      if (weight60Days != null) 'weight_60_days': weight60Days,
      if (weight90Days != null) 'weight_90_days': weight90Days,
      if (weight120Days != null) 'weight_120_days': weight120Days,
      if (year != null) 'year': year,
      if (lote != null) 'lote': lote,
      if (motherId != null) 'mother_id': motherId,
      if (fatherId != null) 'father_id': fatherId,
      if (registrationNote != null) 'registration_note': registrationNote,
      if (deathDate != null) 'death_date': deathDate,
      if (causeOfDeath != null) 'cause_of_death': causeOfDeath,
      if (deathNotes != null) 'death_notes': deathNotes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeceasedAnimalsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? originalAnimalId,
      Value<String>? code,
      Value<String>? name,
      Value<String>? species,
      Value<String>? breed,
      Value<String>? gender,
      Value<String>? birthDate,
      Value<double>? weight,
      Value<String>? location,
      Value<String>? reproductiveStatus,
      Value<String?>? nameColor,
      Value<String?>? category,
      Value<double?>? birthWeight,
      Value<double?>? weight30Days,
      Value<double?>? weight60Days,
      Value<double?>? weight90Days,
      Value<double?>? weight120Days,
      Value<int?>? year,
      Value<String?>? lote,
      Value<String?>? motherId,
      Value<String?>? fatherId,
      Value<String?>? registrationNote,
      Value<String>? deathDate,
      Value<String?>? causeOfDeath,
      Value<String?>? deathNotes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DeceasedAnimalsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      originalAnimalId: originalAnimalId ?? this.originalAnimalId,
      code: code ?? this.code,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      location: location ?? this.location,
      reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
      nameColor: nameColor ?? this.nameColor,
      category: category ?? this.category,
      birthWeight: birthWeight ?? this.birthWeight,
      weight30Days: weight30Days ?? this.weight30Days,
      weight60Days: weight60Days ?? this.weight60Days,
      weight90Days: weight90Days ?? this.weight90Days,
      weight120Days: weight120Days ?? this.weight120Days,
      year: year ?? this.year,
      lote: lote ?? this.lote,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
      registrationNote: registrationNote ?? this.registrationNote,
      deathDate: deathDate ?? this.deathDate,
      causeOfDeath: causeOfDeath ?? this.causeOfDeath,
      deathNotes: deathNotes ?? this.deathNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (originalAnimalId.present) {
      map['original_animal_id'] = Variable<String>(originalAnimalId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (reproductiveStatus.present) {
      map['reproductive_status'] = Variable<String>(reproductiveStatus.value);
    }
    if (nameColor.present) {
      map['name_color'] = Variable<String>(nameColor.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (birthWeight.present) {
      map['birth_weight'] = Variable<double>(birthWeight.value);
    }
    if (weight30Days.present) {
      map['weight_30_days'] = Variable<double>(weight30Days.value);
    }
    if (weight60Days.present) {
      map['weight_60_days'] = Variable<double>(weight60Days.value);
    }
    if (weight90Days.present) {
      map['weight_90_days'] = Variable<double>(weight90Days.value);
    }
    if (weight120Days.present) {
      map['weight_120_days'] = Variable<double>(weight120Days.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (lote.present) {
      map['lote'] = Variable<String>(lote.value);
    }
    if (motherId.present) {
      map['mother_id'] = Variable<String>(motherId.value);
    }
    if (fatherId.present) {
      map['father_id'] = Variable<String>(fatherId.value);
    }
    if (registrationNote.present) {
      map['registration_note'] = Variable<String>(registrationNote.value);
    }
    if (deathDate.present) {
      map['death_date'] = Variable<String>(deathDate.value);
    }
    if (causeOfDeath.present) {
      map['cause_of_death'] = Variable<String>(causeOfDeath.value);
    }
    if (deathNotes.present) {
      map['death_notes'] = Variable<String>(deathNotes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeceasedAnimalsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('originalAnimalId: $originalAnimalId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('weight: $weight, ')
          ..write('location: $location, ')
          ..write('reproductiveStatus: $reproductiveStatus, ')
          ..write('nameColor: $nameColor, ')
          ..write('category: $category, ')
          ..write('birthWeight: $birthWeight, ')
          ..write('weight30Days: $weight30Days, ')
          ..write('weight60Days: $weight60Days, ')
          ..write('weight90Days: $weight90Days, ')
          ..write('weight120Days: $weight120Days, ')
          ..write('year: $year, ')
          ..write('lote: $lote, ')
          ..write('motherId: $motherId, ')
          ..write('fatherId: $fatherId, ')
          ..write('registrationNote: $registrationNote, ')
          ..write('deathDate: $deathDate, ')
          ..write('causeOfDeath: $causeOfDeath, ')
          ..write('deathNotes: $deathNotes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightAlertsTable extends WeightAlerts
    with TableInfo<$WeightAlertsTable, WeightAlertRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES animals (id) ON DELETE CASCADE'));
  static const VerificationMeta _alertTypeMeta =
      const VerificationMeta('alertType');
  @override
  late final GeneratedColumn<String> alertType = GeneratedColumn<String>(
      'alert_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        animalId,
        alertType,
        dueDate,
        completed,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_alerts';
  @override
  VerificationContext validateIntegrity(Insertable<WeightAlertRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('alert_type')) {
      context.handle(_alertTypeMeta,
          alertType.isAcceptableOrUnknown(data['alert_type']!, _alertTypeMeta));
    } else if (isInserting) {
      context.missing(_alertTypeMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightAlertRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightAlertRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id']),
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      alertType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alert_type'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WeightAlertsTable createAlias(String alias) {
    return $WeightAlertsTable(attachedDatabase, alias);
  }
}

class WeightAlertRow extends DataClass implements Insertable<WeightAlertRow> {
  final String id;
  final String? farmId;
  final String animalId;
  final String alertType;
  final String dueDate;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WeightAlertRow(
      {required this.id,
      this.farmId,
      required this.animalId,
      required this.alertType,
      required this.dueDate,
      required this.completed,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || farmId != null) {
      map['farm_id'] = Variable<String>(farmId);
    }
    map['animal_id'] = Variable<String>(animalId);
    map['alert_type'] = Variable<String>(alertType);
    map['due_date'] = Variable<String>(dueDate);
    map['completed'] = Variable<bool>(completed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeightAlertsCompanion toCompanion(bool nullToAbsent) {
    return WeightAlertsCompanion(
      id: Value(id),
      farmId:
          farmId == null && nullToAbsent ? const Value.absent() : Value(farmId),
      animalId: Value(animalId),
      alertType: Value(alertType),
      dueDate: Value(dueDate),
      completed: Value(completed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeightAlertRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightAlertRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String?>(json['farmId']),
      animalId: serializer.fromJson<String>(json['animalId']),
      alertType: serializer.fromJson<String>(json['alertType']),
      dueDate: serializer.fromJson<String>(json['dueDate']),
      completed: serializer.fromJson<bool>(json['completed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String?>(farmId),
      'animalId': serializer.toJson<String>(animalId),
      'alertType': serializer.toJson<String>(alertType),
      'dueDate': serializer.toJson<String>(dueDate),
      'completed': serializer.toJson<bool>(completed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeightAlertRow copyWith(
          {String? id,
          Value<String?> farmId = const Value.absent(),
          String? animalId,
          String? alertType,
          String? dueDate,
          bool? completed,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      WeightAlertRow(
        id: id ?? this.id,
        farmId: farmId.present ? farmId.value : this.farmId,
        animalId: animalId ?? this.animalId,
        alertType: alertType ?? this.alertType,
        dueDate: dueDate ?? this.dueDate,
        completed: completed ?? this.completed,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WeightAlertRow copyWithCompanion(WeightAlertsCompanion data) {
    return WeightAlertRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      alertType: data.alertType.present ? data.alertType.value : this.alertType,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      completed: data.completed.present ? data.completed.value : this.completed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightAlertRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('alertType: $alertType, ')
          ..write('dueDate: $dueDate, ')
          ..write('completed: $completed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmId, animalId, alertType, dueDate,
      completed, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightAlertRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.animalId == this.animalId &&
          other.alertType == this.alertType &&
          other.dueDate == this.dueDate &&
          other.completed == this.completed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeightAlertsCompanion extends UpdateCompanion<WeightAlertRow> {
  final Value<String> id;
  final Value<String?> farmId;
  final Value<String> animalId;
  final Value<String> alertType;
  final Value<String> dueDate;
  final Value<bool> completed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WeightAlertsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.animalId = const Value.absent(),
    this.alertType = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightAlertsCompanion.insert({
    required String id,
    this.farmId = const Value.absent(),
    required String animalId,
    required String alertType,
    required String dueDate,
    this.completed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        alertType = Value(alertType),
        dueDate = Value(dueDate);
  static Insertable<WeightAlertRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? animalId,
    Expression<String>? alertType,
    Expression<String>? dueDate,
    Expression<bool>? completed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (animalId != null) 'animal_id': animalId,
      if (alertType != null) 'alert_type': alertType,
      if (dueDate != null) 'due_date': dueDate,
      if (completed != null) 'completed': completed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightAlertsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? farmId,
      Value<String>? animalId,
      Value<String>? alertType,
      Value<String>? dueDate,
      Value<bool>? completed,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return WeightAlertsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      animalId: animalId ?? this.animalId,
      alertType: alertType ?? this.alertType,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (alertType.present) {
      map['alert_type'] = Variable<String>(alertType.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightAlertsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('animalId: $animalId, ')
          ..write('alertType: $alertType, ')
          ..write('dueDate: $dueDate, ')
          ..write('completed: $completed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDriftDatabase extends GeneratedDatabase {
  _$AppDriftDatabase(QueryExecutor e) : super(e);
  $AppDriftDatabaseManager get managers => $AppDriftDatabaseManager(this);
  late final $AnimalsTable animals = $AnimalsTable(this);
  late final $AnimalWeightsTable animalWeights = $AnimalWeightsTable(this);
  late final $AnimalLineageTable animalLineage = $AnimalLineageTable(this);
  late final $AnimalLineageMetaTable animalLineageMeta =
      $AnimalLineageMetaTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $BreedingRecordsTable breedingRecords =
      $BreedingRecordsTable(this);
  late final $MatrixEvaluationsTable matrixEvaluations =
      $MatrixEvaluationsTable(this);
  late final $FinancialAccountsTable financialAccounts =
      $FinancialAccountsTable(this);
  late final $FinancialRecordsTable financialRecords =
      $FinancialRecordsTable(this);
  late final $PharmacyStockTable pharmacyStock = $PharmacyStockTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $PharmacyStockMovementsTable pharmacyStockMovements =
      $PharmacyStockMovementsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $ReportsTable reports = $ReportsTable(this);
  late final $PushTokensTable pushTokens = $PushTokensTable(this);
  late final $FeedingPensTable feedingPens = $FeedingPensTable(this);
  late final $FeedingSchedulesTable feedingSchedules =
      $FeedingSchedulesTable(this);
  late final $VaccinationsTable vaccinations = $VaccinationsTable(this);
  late final $SoldAnimalsTable soldAnimals = $SoldAnimalsTable(this);
  late final $DeceasedAnimalsTable deceasedAnimals =
      $DeceasedAnimalsTable(this);
  late final $WeightAlertsTable weightAlerts = $WeightAlertsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        animals,
        animalWeights,
        animalLineage,
        animalLineageMeta,
        appSettings,
        breedingRecords,
        matrixEvaluations,
        financialAccounts,
        financialRecords,
        pharmacyStock,
        medications,
        pharmacyStockMovements,
        notes,
        reports,
        pushTokens,
        feedingPens,
        feedingSchedules,
        vaccinations,
        soldAnimals,
        deceasedAnimals,
        weightAlerts
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('pharmacy_stock',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('pharmacy_stock_movements', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('feeding_pens',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('feeding_schedules', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('animals',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('weight_alerts', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$AnimalsTableCreateCompanionBuilder = AnimalsCompanion Function({
  required String id,
  Value<String?> farmId,
  required String code,
  required String name,
  required String species,
  required String breed,
  required String gender,
  required String birthDate,
  required double weight,
  Value<String> status,
  Value<String> reproductiveStatus,
  required String location,
  Value<String?> lastVaccination,
  Value<bool> pregnant,
  Value<String?> expectedDelivery,
  Value<String?> healthIssue,
  Value<String?> registrationNote,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> nameColor,
  Value<String?> category,
  Value<double?> birthWeight,
  Value<double?> weight30Days,
  Value<double?> weight60Days,
  Value<double?> weight90Days,
  Value<double?> weight120Days,
  Value<int?> year,
  Value<String?> lote,
  Value<String?> motherId,
  Value<String?> fatherId,
  Value<int> rowid,
});
typedef $$AnimalsTableUpdateCompanionBuilder = AnimalsCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> code,
  Value<String> name,
  Value<String> species,
  Value<String> breed,
  Value<String> gender,
  Value<String> birthDate,
  Value<double> weight,
  Value<String> status,
  Value<String> reproductiveStatus,
  Value<String> location,
  Value<String?> lastVaccination,
  Value<bool> pregnant,
  Value<String?> expectedDelivery,
  Value<String?> healthIssue,
  Value<String?> registrationNote,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> nameColor,
  Value<String?> category,
  Value<double?> birthWeight,
  Value<double?> weight30Days,
  Value<double?> weight60Days,
  Value<double?> weight90Days,
  Value<double?> weight120Days,
  Value<int?> year,
  Value<String?> lote,
  Value<String?> motherId,
  Value<String?> fatherId,
  Value<int> rowid,
});

final class $$AnimalsTableReferences
    extends BaseReferences<_$AppDriftDatabase, $AnimalsTable, AnimalRow> {
  $$AnimalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AnimalWeightsTable, List<AnimalWeightRow>>
      _animalWeightsRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.animalWeights,
              aliasName: $_aliasNameGenerator(
                  db.animals.id, db.animalWeights.animalId));

  $$AnimalWeightsTableProcessedTableManager get animalWeightsRefs {
    final manager = $$AnimalWeightsTableTableManager($_db, $_db.animalWeights)
        .filter((f) => f.animalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_animalWeightsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MatrixEvaluationsTable, List<MatrixEvaluationRow>>
      _matrixEvaluationsRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.matrixEvaluations,
              aliasName: $_aliasNameGenerator(
                  db.animals.id, db.matrixEvaluations.animalId));

  $$MatrixEvaluationsTableProcessedTableManager get matrixEvaluationsRefs {
    final manager = $$MatrixEvaluationsTableTableManager(
            $_db, $_db.matrixEvaluations)
        .filter((f) => f.animalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_matrixEvaluationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FinancialAccountsTable, List<FinancialAccountRow>>
      _financialAccountsRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.financialAccounts,
              aliasName: $_aliasNameGenerator(
                  db.animals.id, db.financialAccounts.animalId));

  $$FinancialAccountsTableProcessedTableManager get financialAccountsRefs {
    final manager = $$FinancialAccountsTableTableManager(
            $_db, $_db.financialAccounts)
        .filter((f) => f.animalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_financialAccountsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FinancialRecordsTable, List<FinancialRecordRow>>
      _financialRecordsRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.financialRecords,
              aliasName: $_aliasNameGenerator(
                  db.animals.id, db.financialRecords.animalId));

  $$FinancialRecordsTableProcessedTableManager get financialRecordsRefs {
    final manager = $$FinancialRecordsTableTableManager(
            $_db, $_db.financialRecords)
        .filter((f) => f.animalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_financialRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MedicationsTable, List<MedicationRow>>
      _medicationsRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.medications,
              aliasName:
                  $_aliasNameGenerator(db.animals.id, db.medications.animalId));

  $$MedicationsTableProcessedTableManager get medicationsRefs {
    final manager = $$MedicationsTableTableManager($_db, $_db.medications)
        .filter((f) => f.animalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotesTable, List<NoteRow>> _notesRefsTable(
          _$AppDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.notes,
          aliasName: $_aliasNameGenerator(db.animals.id, db.notes.animalId));

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager($_db, $_db.notes)
        .filter((f) => f.animalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$VaccinationsTable, List<VaccinationRow>>
      _vaccinationsRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.vaccinations,
              aliasName: $_aliasNameGenerator(
                  db.animals.id, db.vaccinations.animalId));

  $$VaccinationsTableProcessedTableManager get vaccinationsRefs {
    final manager = $$VaccinationsTableTableManager($_db, $_db.vaccinations)
        .filter((f) => f.animalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vaccinationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WeightAlertsTable, List<WeightAlertRow>>
      _weightAlertsRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.weightAlerts,
              aliasName: $_aliasNameGenerator(
                  db.animals.id, db.weightAlerts.animalId));

  $$WeightAlertsTableProcessedTableManager get weightAlertsRefs {
    final manager = $$WeightAlertsTableTableManager($_db, $_db.weightAlerts)
        .filter((f) => f.animalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_weightAlertsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AnimalsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $AnimalsTable> {
  $$AnimalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastVaccination => $composableBuilder(
      column: $table.lastVaccination,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pregnant => $composableBuilder(
      column: $table.pregnant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expectedDelivery => $composableBuilder(
      column: $table.expectedDelivery,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get healthIssue => $composableBuilder(
      column: $table.healthIssue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameColor => $composableBuilder(
      column: $table.nameColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motherId => $composableBuilder(
      column: $table.motherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fatherId => $composableBuilder(
      column: $table.fatherId, builder: (column) => ColumnFilters(column));

  Expression<bool> animalWeightsRefs(
      Expression<bool> Function($$AnimalWeightsTableFilterComposer f) f) {
    final $$AnimalWeightsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.animalWeights,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalWeightsTableFilterComposer(
              $db: $db,
              $table: $db.animalWeights,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> matrixEvaluationsRefs(
      Expression<bool> Function($$MatrixEvaluationsTableFilterComposer f) f) {
    final $$MatrixEvaluationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.matrixEvaluations,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MatrixEvaluationsTableFilterComposer(
              $db: $db,
              $table: $db.matrixEvaluations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> financialAccountsRefs(
      Expression<bool> Function($$FinancialAccountsTableFilterComposer f) f) {
    final $$FinancialAccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.financialAccounts,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinancialAccountsTableFilterComposer(
              $db: $db,
              $table: $db.financialAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> financialRecordsRefs(
      Expression<bool> Function($$FinancialRecordsTableFilterComposer f) f) {
    final $$FinancialRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.financialRecords,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinancialRecordsTableFilterComposer(
              $db: $db,
              $table: $db.financialRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> medicationsRefs(
      Expression<bool> Function($$MedicationsTableFilterComposer f) f) {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableFilterComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notesRefs(
      Expression<bool> Function($$NotesTableFilterComposer f) f) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableFilterComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> vaccinationsRefs(
      Expression<bool> Function($$VaccinationsTableFilterComposer f) f) {
    final $$VaccinationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vaccinations,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaccinationsTableFilterComposer(
              $db: $db,
              $table: $db.vaccinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> weightAlertsRefs(
      Expression<bool> Function($$WeightAlertsTableFilterComposer f) f) {
    final $$WeightAlertsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.weightAlerts,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WeightAlertsTableFilterComposer(
              $db: $db,
              $table: $db.weightAlerts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AnimalsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $AnimalsTable> {
  $$AnimalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastVaccination => $composableBuilder(
      column: $table.lastVaccination,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pregnant => $composableBuilder(
      column: $table.pregnant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expectedDelivery => $composableBuilder(
      column: $table.expectedDelivery,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get healthIssue => $composableBuilder(
      column: $table.healthIssue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameColor => $composableBuilder(
      column: $table.nameColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motherId => $composableBuilder(
      column: $table.motherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fatherId => $composableBuilder(
      column: $table.fatherId, builder: (column) => ColumnOrderings(column));
}

class $$AnimalsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $AnimalsTable> {
  $$AnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get lastVaccination => $composableBuilder(
      column: $table.lastVaccination, builder: (column) => column);

  GeneratedColumn<bool> get pregnant =>
      $composableBuilder(column: $table.pregnant, builder: (column) => column);

  GeneratedColumn<String> get expectedDelivery => $composableBuilder(
      column: $table.expectedDelivery, builder: (column) => column);

  GeneratedColumn<String> get healthIssue => $composableBuilder(
      column: $table.healthIssue, builder: (column) => column);

  GeneratedColumn<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get nameColor =>
      $composableBuilder(column: $table.nameColor, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => column);

  GeneratedColumn<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days, builder: (column) => column);

  GeneratedColumn<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days, builder: (column) => column);

  GeneratedColumn<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days, builder: (column) => column);

  GeneratedColumn<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get lote =>
      $composableBuilder(column: $table.lote, builder: (column) => column);

  GeneratedColumn<String> get motherId =>
      $composableBuilder(column: $table.motherId, builder: (column) => column);

  GeneratedColumn<String> get fatherId =>
      $composableBuilder(column: $table.fatherId, builder: (column) => column);

  Expression<T> animalWeightsRefs<T extends Object>(
      Expression<T> Function($$AnimalWeightsTableAnnotationComposer a) f) {
    final $$AnimalWeightsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.animalWeights,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalWeightsTableAnnotationComposer(
              $db: $db,
              $table: $db.animalWeights,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> matrixEvaluationsRefs<T extends Object>(
      Expression<T> Function($$MatrixEvaluationsTableAnnotationComposer a) f) {
    final $$MatrixEvaluationsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.matrixEvaluations,
            getReferencedColumn: (t) => t.animalId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MatrixEvaluationsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.matrixEvaluations,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> financialAccountsRefs<T extends Object>(
      Expression<T> Function($$FinancialAccountsTableAnnotationComposer a) f) {
    final $$FinancialAccountsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.financialAccounts,
            getReferencedColumn: (t) => t.animalId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$FinancialAccountsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.financialAccounts,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> financialRecordsRefs<T extends Object>(
      Expression<T> Function($$FinancialRecordsTableAnnotationComposer a) f) {
    final $$FinancialRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.financialRecords,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FinancialRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.financialRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> medicationsRefs<T extends Object>(
      Expression<T> Function($$MedicationsTableAnnotationComposer a) f) {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableAnnotationComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
      Expression<T> Function($$NotesTableAnnotationComposer a) f) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableAnnotationComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> vaccinationsRefs<T extends Object>(
      Expression<T> Function($$VaccinationsTableAnnotationComposer a) f) {
    final $$VaccinationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.vaccinations,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VaccinationsTableAnnotationComposer(
              $db: $db,
              $table: $db.vaccinations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> weightAlertsRefs<T extends Object>(
      Expression<T> Function($$WeightAlertsTableAnnotationComposer a) f) {
    final $$WeightAlertsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.weightAlerts,
        getReferencedColumn: (t) => t.animalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WeightAlertsTableAnnotationComposer(
              $db: $db,
              $table: $db.weightAlerts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AnimalsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $AnimalsTable,
    AnimalRow,
    $$AnimalsTableFilterComposer,
    $$AnimalsTableOrderingComposer,
    $$AnimalsTableAnnotationComposer,
    $$AnimalsTableCreateCompanionBuilder,
    $$AnimalsTableUpdateCompanionBuilder,
    (AnimalRow, $$AnimalsTableReferences),
    AnimalRow,
    PrefetchHooks Function(
        {bool animalWeightsRefs,
        bool matrixEvaluationsRefs,
        bool financialAccountsRefs,
        bool financialRecordsRefs,
        bool medicationsRefs,
        bool notesRefs,
        bool vaccinationsRefs,
        bool weightAlertsRefs})> {
  $$AnimalsTableTableManager(_$AppDriftDatabase db, $AnimalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<String> breed = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String> birthDate = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> reproductiveStatus = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String?> lastVaccination = const Value.absent(),
            Value<bool> pregnant = const Value.absent(),
            Value<String?> expectedDelivery = const Value.absent(),
            Value<String?> healthIssue = const Value.absent(),
            Value<String?> registrationNote = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> nameColor = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<double?> birthWeight = const Value.absent(),
            Value<double?> weight30Days = const Value.absent(),
            Value<double?> weight60Days = const Value.absent(),
            Value<double?> weight90Days = const Value.absent(),
            Value<double?> weight120Days = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> lote = const Value.absent(),
            Value<String?> motherId = const Value.absent(),
            Value<String?> fatherId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalsCompanion(
            id: id,
            farmId: farmId,
            code: code,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            weight: weight,
            status: status,
            reproductiveStatus: reproductiveStatus,
            location: location,
            lastVaccination: lastVaccination,
            pregnant: pregnant,
            expectedDelivery: expectedDelivery,
            healthIssue: healthIssue,
            registrationNote: registrationNote,
            createdAt: createdAt,
            updatedAt: updatedAt,
            nameColor: nameColor,
            category: category,
            birthWeight: birthWeight,
            weight30Days: weight30Days,
            weight60Days: weight60Days,
            weight90Days: weight90Days,
            weight120Days: weight120Days,
            year: year,
            lote: lote,
            motherId: motherId,
            fatherId: fatherId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String code,
            required String name,
            required String species,
            required String breed,
            required String gender,
            required String birthDate,
            required double weight,
            Value<String> status = const Value.absent(),
            Value<String> reproductiveStatus = const Value.absent(),
            required String location,
            Value<String?> lastVaccination = const Value.absent(),
            Value<bool> pregnant = const Value.absent(),
            Value<String?> expectedDelivery = const Value.absent(),
            Value<String?> healthIssue = const Value.absent(),
            Value<String?> registrationNote = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> nameColor = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<double?> birthWeight = const Value.absent(),
            Value<double?> weight30Days = const Value.absent(),
            Value<double?> weight60Days = const Value.absent(),
            Value<double?> weight90Days = const Value.absent(),
            Value<double?> weight120Days = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> lote = const Value.absent(),
            Value<String?> motherId = const Value.absent(),
            Value<String?> fatherId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalsCompanion.insert(
            id: id,
            farmId: farmId,
            code: code,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            weight: weight,
            status: status,
            reproductiveStatus: reproductiveStatus,
            location: location,
            lastVaccination: lastVaccination,
            pregnant: pregnant,
            expectedDelivery: expectedDelivery,
            healthIssue: healthIssue,
            registrationNote: registrationNote,
            createdAt: createdAt,
            updatedAt: updatedAt,
            nameColor: nameColor,
            category: category,
            birthWeight: birthWeight,
            weight30Days: weight30Days,
            weight60Days: weight60Days,
            weight90Days: weight90Days,
            weight120Days: weight120Days,
            year: year,
            lote: lote,
            motherId: motherId,
            fatherId: fatherId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AnimalsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {animalWeightsRefs = false,
              matrixEvaluationsRefs = false,
              financialAccountsRefs = false,
              financialRecordsRefs = false,
              medicationsRefs = false,
              notesRefs = false,
              vaccinationsRefs = false,
              weightAlertsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (animalWeightsRefs) db.animalWeights,
                if (matrixEvaluationsRefs) db.matrixEvaluations,
                if (financialAccountsRefs) db.financialAccounts,
                if (financialRecordsRefs) db.financialRecords,
                if (medicationsRefs) db.medications,
                if (notesRefs) db.notes,
                if (vaccinationsRefs) db.vaccinations,
                if (weightAlertsRefs) db.weightAlerts
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (animalWeightsRefs)
                    await $_getPrefetchedData<AnimalRow, $AnimalsTable,
                            AnimalWeightRow>(
                        currentTable: table,
                        referencedTable: $$AnimalsTableReferences
                            ._animalWeightsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnimalsTableReferences(db, table, p0)
                                .animalWeightsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.animalId == item.id),
                        typedResults: items),
                  if (matrixEvaluationsRefs)
                    await $_getPrefetchedData<AnimalRow, $AnimalsTable,
                            MatrixEvaluationRow>(
                        currentTable: table,
                        referencedTable: $$AnimalsTableReferences
                            ._matrixEvaluationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnimalsTableReferences(db, table, p0)
                                .matrixEvaluationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.animalId == item.id),
                        typedResults: items),
                  if (financialAccountsRefs)
                    await $_getPrefetchedData<AnimalRow, $AnimalsTable,
                            FinancialAccountRow>(
                        currentTable: table,
                        referencedTable: $$AnimalsTableReferences
                            ._financialAccountsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnimalsTableReferences(db, table, p0)
                                .financialAccountsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.animalId == item.id),
                        typedResults: items),
                  if (financialRecordsRefs)
                    await $_getPrefetchedData<AnimalRow, $AnimalsTable,
                            FinancialRecordRow>(
                        currentTable: table,
                        referencedTable: $$AnimalsTableReferences
                            ._financialRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnimalsTableReferences(db, table, p0)
                                .financialRecordsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.animalId == item.id),
                        typedResults: items),
                  if (medicationsRefs)
                    await $_getPrefetchedData<AnimalRow, $AnimalsTable,
                            MedicationRow>(
                        currentTable: table,
                        referencedTable:
                            $$AnimalsTableReferences._medicationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnimalsTableReferences(db, table, p0)
                                .medicationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.animalId == item.id),
                        typedResults: items),
                  if (notesRefs)
                    await $_getPrefetchedData<AnimalRow, $AnimalsTable,
                            NoteRow>(
                        currentTable: table,
                        referencedTable:
                            $$AnimalsTableReferences._notesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnimalsTableReferences(db, table, p0).notesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.animalId == item.id),
                        typedResults: items),
                  if (vaccinationsRefs)
                    await $_getPrefetchedData<AnimalRow, $AnimalsTable,
                            VaccinationRow>(
                        currentTable: table,
                        referencedTable:
                            $$AnimalsTableReferences._vaccinationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnimalsTableReferences(db, table, p0)
                                .vaccinationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.animalId == item.id),
                        typedResults: items),
                  if (weightAlertsRefs)
                    await $_getPrefetchedData<AnimalRow, $AnimalsTable,
                            WeightAlertRow>(
                        currentTable: table,
                        referencedTable:
                            $$AnimalsTableReferences._weightAlertsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AnimalsTableReferences(db, table, p0)
                                .weightAlertsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.animalId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AnimalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $AnimalsTable,
    AnimalRow,
    $$AnimalsTableFilterComposer,
    $$AnimalsTableOrderingComposer,
    $$AnimalsTableAnnotationComposer,
    $$AnimalsTableCreateCompanionBuilder,
    $$AnimalsTableUpdateCompanionBuilder,
    (AnimalRow, $$AnimalsTableReferences),
    AnimalRow,
    PrefetchHooks Function(
        {bool animalWeightsRefs,
        bool matrixEvaluationsRefs,
        bool financialAccountsRefs,
        bool financialRecordsRefs,
        bool medicationsRefs,
        bool notesRefs,
        bool vaccinationsRefs,
        bool weightAlertsRefs})>;
typedef $$AnimalWeightsTableCreateCompanionBuilder = AnimalWeightsCompanion
    Function({
  required String id,
  Value<String?> farmId,
  required String animalId,
  required String date,
  required double weight,
  Value<String?> milestone,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AnimalWeightsTableUpdateCompanionBuilder = AnimalWeightsCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> animalId,
  Value<String> date,
  Value<double> weight,
  Value<String?> milestone,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$AnimalWeightsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $AnimalWeightsTable, AnimalWeightRow> {
  $$AnimalWeightsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _animalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias(
          $_aliasNameGenerator(db.animalWeights.animalId, db.animals.id));

  $$AnimalsTableProcessedTableManager get animalId {
    final $_column = $_itemColumn<String>('animal_id')!;

    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AnimalWeightsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $AnimalWeightsTable> {
  $$AnimalWeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get milestone => $composableBuilder(
      column: $table.milestone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get animalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnimalWeightsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $AnimalWeightsTable> {
  $$AnimalWeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get milestone => $composableBuilder(
      column: $table.milestone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get animalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnimalWeightsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $AnimalWeightsTable> {
  $$AnimalWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get milestone =>
      $composableBuilder(column: $table.milestone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get animalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnimalWeightsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $AnimalWeightsTable,
    AnimalWeightRow,
    $$AnimalWeightsTableFilterComposer,
    $$AnimalWeightsTableOrderingComposer,
    $$AnimalWeightsTableAnnotationComposer,
    $$AnimalWeightsTableCreateCompanionBuilder,
    $$AnimalWeightsTableUpdateCompanionBuilder,
    (AnimalWeightRow, $$AnimalWeightsTableReferences),
    AnimalWeightRow,
    PrefetchHooks Function({bool animalId})> {
  $$AnimalWeightsTableTableManager(
      _$AppDriftDatabase db, $AnimalWeightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalWeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalWeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalWeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String?> milestone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalWeightsCompanion(
            id: id,
            farmId: farmId,
            animalId: animalId,
            date: date,
            weight: weight,
            milestone: milestone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String animalId,
            required String date,
            required double weight,
            Value<String?> milestone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalWeightsCompanion.insert(
            id: id,
            farmId: farmId,
            animalId: animalId,
            date: date,
            weight: weight,
            milestone: milestone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AnimalWeightsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({animalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (animalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.animalId,
                    referencedTable:
                        $$AnimalWeightsTableReferences._animalIdTable(db),
                    referencedColumn:
                        $$AnimalWeightsTableReferences._animalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AnimalWeightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $AnimalWeightsTable,
    AnimalWeightRow,
    $$AnimalWeightsTableFilterComposer,
    $$AnimalWeightsTableOrderingComposer,
    $$AnimalWeightsTableAnnotationComposer,
    $$AnimalWeightsTableCreateCompanionBuilder,
    $$AnimalWeightsTableUpdateCompanionBuilder,
    (AnimalWeightRow, $$AnimalWeightsTableReferences),
    AnimalWeightRow,
    PrefetchHooks Function({bool animalId})>;
typedef $$AnimalLineageTableCreateCompanionBuilder = AnimalLineageCompanion
    Function({
  Value<String?> farmId,
  required String descendantId,
  required String ancestorId,
  required int depth,
  Value<String> lineType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AnimalLineageTableUpdateCompanionBuilder = AnimalLineageCompanion
    Function({
  Value<String?> farmId,
  Value<String> descendantId,
  Value<String> ancestorId,
  Value<int> depth,
  Value<String> lineType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AnimalLineageTableFilterComposer
    extends Composer<_$AppDriftDatabase, $AnimalLineageTable> {
  $$AnimalLineageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descendantId => $composableBuilder(
      column: $table.descendantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ancestorId => $composableBuilder(
      column: $table.ancestorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get depth => $composableBuilder(
      column: $table.depth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lineType => $composableBuilder(
      column: $table.lineType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AnimalLineageTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $AnimalLineageTable> {
  $$AnimalLineageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descendantId => $composableBuilder(
      column: $table.descendantId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ancestorId => $composableBuilder(
      column: $table.ancestorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get depth => $composableBuilder(
      column: $table.depth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lineType => $composableBuilder(
      column: $table.lineType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AnimalLineageTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $AnimalLineageTable> {
  $$AnimalLineageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get descendantId => $composableBuilder(
      column: $table.descendantId, builder: (column) => column);

  GeneratedColumn<String> get ancestorId => $composableBuilder(
      column: $table.ancestorId, builder: (column) => column);

  GeneratedColumn<int> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<String> get lineType =>
      $composableBuilder(column: $table.lineType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AnimalLineageTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $AnimalLineageTable,
    AnimalLineageRow,
    $$AnimalLineageTableFilterComposer,
    $$AnimalLineageTableOrderingComposer,
    $$AnimalLineageTableAnnotationComposer,
    $$AnimalLineageTableCreateCompanionBuilder,
    $$AnimalLineageTableUpdateCompanionBuilder,
    (
      AnimalLineageRow,
      BaseReferences<_$AppDriftDatabase, $AnimalLineageTable, AnimalLineageRow>
    ),
    AnimalLineageRow,
    PrefetchHooks Function()> {
  $$AnimalLineageTableTableManager(
      _$AppDriftDatabase db, $AnimalLineageTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalLineageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalLineageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalLineageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> farmId = const Value.absent(),
            Value<String> descendantId = const Value.absent(),
            Value<String> ancestorId = const Value.absent(),
            Value<int> depth = const Value.absent(),
            Value<String> lineType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalLineageCompanion(
            farmId: farmId,
            descendantId: descendantId,
            ancestorId: ancestorId,
            depth: depth,
            lineType: lineType,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> farmId = const Value.absent(),
            required String descendantId,
            required String ancestorId,
            required int depth,
            Value<String> lineType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalLineageCompanion.insert(
            farmId: farmId,
            descendantId: descendantId,
            ancestorId: ancestorId,
            depth: depth,
            lineType: lineType,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalLineageTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $AnimalLineageTable,
    AnimalLineageRow,
    $$AnimalLineageTableFilterComposer,
    $$AnimalLineageTableOrderingComposer,
    $$AnimalLineageTableAnnotationComposer,
    $$AnimalLineageTableCreateCompanionBuilder,
    $$AnimalLineageTableUpdateCompanionBuilder,
    (
      AnimalLineageRow,
      BaseReferences<_$AppDriftDatabase, $AnimalLineageTable, AnimalLineageRow>
    ),
    AnimalLineageRow,
    PrefetchHooks Function()>;
typedef $$AnimalLineageMetaTableCreateCompanionBuilder
    = AnimalLineageMetaCompanion Function({
  Value<String?> farmId,
  required String metaKey,
  required String metaValue,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AnimalLineageMetaTableUpdateCompanionBuilder
    = AnimalLineageMetaCompanion Function({
  Value<String?> farmId,
  Value<String> metaKey,
  Value<String> metaValue,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AnimalLineageMetaTableFilterComposer
    extends Composer<_$AppDriftDatabase, $AnimalLineageMetaTable> {
  $$AnimalLineageMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metaKey => $composableBuilder(
      column: $table.metaKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metaValue => $composableBuilder(
      column: $table.metaValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AnimalLineageMetaTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $AnimalLineageMetaTable> {
  $$AnimalLineageMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metaKey => $composableBuilder(
      column: $table.metaKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metaValue => $composableBuilder(
      column: $table.metaValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AnimalLineageMetaTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $AnimalLineageMetaTable> {
  $$AnimalLineageMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get metaKey =>
      $composableBuilder(column: $table.metaKey, builder: (column) => column);

  GeneratedColumn<String> get metaValue =>
      $composableBuilder(column: $table.metaValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AnimalLineageMetaTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $AnimalLineageMetaTable,
    AnimalLineageMetaRow,
    $$AnimalLineageMetaTableFilterComposer,
    $$AnimalLineageMetaTableOrderingComposer,
    $$AnimalLineageMetaTableAnnotationComposer,
    $$AnimalLineageMetaTableCreateCompanionBuilder,
    $$AnimalLineageMetaTableUpdateCompanionBuilder,
    (
      AnimalLineageMetaRow,
      BaseReferences<_$AppDriftDatabase, $AnimalLineageMetaTable,
          AnimalLineageMetaRow>
    ),
    AnimalLineageMetaRow,
    PrefetchHooks Function()> {
  $$AnimalLineageMetaTableTableManager(
      _$AppDriftDatabase db, $AnimalLineageMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalLineageMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalLineageMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalLineageMetaTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> farmId = const Value.absent(),
            Value<String> metaKey = const Value.absent(),
            Value<String> metaValue = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalLineageMetaCompanion(
            farmId: farmId,
            metaKey: metaKey,
            metaValue: metaValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> farmId = const Value.absent(),
            required String metaKey,
            required String metaValue,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalLineageMetaCompanion.insert(
            farmId: farmId,
            metaKey: metaKey,
            metaValue: metaValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalLineageMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $AnimalLineageMetaTable,
    AnimalLineageMetaRow,
    $$AnimalLineageMetaTableFilterComposer,
    $$AnimalLineageMetaTableOrderingComposer,
    $$AnimalLineageMetaTableAnnotationComposer,
    $$AnimalLineageMetaTableCreateCompanionBuilder,
    $$AnimalLineageMetaTableUpdateCompanionBuilder,
    (
      AnimalLineageMetaRow,
      BaseReferences<_$AppDriftDatabase, $AnimalLineageMetaTable,
          AnimalLineageMetaRow>
    ),
    AnimalLineageMetaRow,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String?> farmId,
  required String settingKey,
  required String settingValue,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String?> farmId,
  Value<String> settingKey,
  Value<String> settingValue,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingValue => $composableBuilder(
      column: $table.settingValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingValue => $composableBuilder(
      column: $table.settingValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => column);

  GeneratedColumn<String> get settingValue => $composableBuilder(
      column: $table.settingValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $AppSettingsTable,
    AppSettingRow,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDriftDatabase, $AppSettingsTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDriftDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> farmId = const Value.absent(),
            Value<String> settingKey = const Value.absent(),
            Value<String> settingValue = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            farmId: farmId,
            settingKey: settingKey,
            settingValue: settingValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> farmId = const Value.absent(),
            required String settingKey,
            required String settingValue,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            farmId: farmId,
            settingKey: settingKey,
            settingValue: settingValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $AppSettingsTable,
    AppSettingRow,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDriftDatabase, $AppSettingsTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()>;
typedef $$BreedingRecordsTableCreateCompanionBuilder = BreedingRecordsCompanion
    Function({
  required String id,
  Value<String?> farmId,
  Value<String?> femaleAnimalId,
  Value<String?> maleAnimalId,
  required String breedingDate,
  Value<String?> expectedBirth,
  Value<String> status,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> matingStartDate,
  Value<String?> matingEndDate,
  Value<String?> separationDate,
  Value<String?> ultrasoundDate,
  Value<String?> ultrasoundResult,
  Value<String?> birthDate,
  Value<String> stage,
  Value<int> rowid,
});
typedef $$BreedingRecordsTableUpdateCompanionBuilder = BreedingRecordsCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String?> femaleAnimalId,
  Value<String?> maleAnimalId,
  Value<String> breedingDate,
  Value<String?> expectedBirth,
  Value<String> status,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String?> matingStartDate,
  Value<String?> matingEndDate,
  Value<String?> separationDate,
  Value<String?> ultrasoundDate,
  Value<String?> ultrasoundResult,
  Value<String?> birthDate,
  Value<String> stage,
  Value<int> rowid,
});

final class $$BreedingRecordsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $BreedingRecordsTable, BreedingRecordRow> {
  $$BreedingRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _femaleAnimalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias($_aliasNameGenerator(
          db.breedingRecords.femaleAnimalId, db.animals.id));

  $$AnimalsTableProcessedTableManager? get femaleAnimalId {
    final $_column = $_itemColumn<String>('female_animal_id');
    if ($_column == null) return null;
    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_femaleAnimalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AnimalsTable _maleAnimalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias(
          $_aliasNameGenerator(db.breedingRecords.maleAnimalId, db.animals.id));

  $$AnimalsTableProcessedTableManager? get maleAnimalId {
    final $_column = $_itemColumn<String>('male_animal_id');
    if ($_column == null) return null;
    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_maleAnimalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BreedingRecordsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $BreedingRecordsTable> {
  $$BreedingRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breedingDate => $composableBuilder(
      column: $table.breedingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expectedBirth => $composableBuilder(
      column: $table.expectedBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matingStartDate => $composableBuilder(
      column: $table.matingStartDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matingEndDate => $composableBuilder(
      column: $table.matingEndDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get separationDate => $composableBuilder(
      column: $table.separationDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ultrasoundDate => $composableBuilder(
      column: $table.ultrasoundDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ultrasoundResult => $composableBuilder(
      column: $table.ultrasoundResult,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get femaleAnimalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.femaleAnimalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AnimalsTableFilterComposer get maleAnimalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.maleAnimalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BreedingRecordsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $BreedingRecordsTable> {
  $$BreedingRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breedingDate => $composableBuilder(
      column: $table.breedingDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expectedBirth => $composableBuilder(
      column: $table.expectedBirth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matingStartDate => $composableBuilder(
      column: $table.matingStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matingEndDate => $composableBuilder(
      column: $table.matingEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get separationDate => $composableBuilder(
      column: $table.separationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ultrasoundDate => $composableBuilder(
      column: $table.ultrasoundDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ultrasoundResult => $composableBuilder(
      column: $table.ultrasoundResult,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stage => $composableBuilder(
      column: $table.stage, builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get femaleAnimalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.femaleAnimalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AnimalsTableOrderingComposer get maleAnimalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.maleAnimalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BreedingRecordsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $BreedingRecordsTable> {
  $$BreedingRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get breedingDate => $composableBuilder(
      column: $table.breedingDate, builder: (column) => column);

  GeneratedColumn<String> get expectedBirth => $composableBuilder(
      column: $table.expectedBirth, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get matingStartDate => $composableBuilder(
      column: $table.matingStartDate, builder: (column) => column);

  GeneratedColumn<String> get matingEndDate => $composableBuilder(
      column: $table.matingEndDate, builder: (column) => column);

  GeneratedColumn<String> get separationDate => $composableBuilder(
      column: $table.separationDate, builder: (column) => column);

  GeneratedColumn<String> get ultrasoundDate => $composableBuilder(
      column: $table.ultrasoundDate, builder: (column) => column);

  GeneratedColumn<String> get ultrasoundResult => $composableBuilder(
      column: $table.ultrasoundResult, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get femaleAnimalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.femaleAnimalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AnimalsTableAnnotationComposer get maleAnimalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.maleAnimalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BreedingRecordsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $BreedingRecordsTable,
    BreedingRecordRow,
    $$BreedingRecordsTableFilterComposer,
    $$BreedingRecordsTableOrderingComposer,
    $$BreedingRecordsTableAnnotationComposer,
    $$BreedingRecordsTableCreateCompanionBuilder,
    $$BreedingRecordsTableUpdateCompanionBuilder,
    (BreedingRecordRow, $$BreedingRecordsTableReferences),
    BreedingRecordRow,
    PrefetchHooks Function({bool femaleAnimalId, bool maleAnimalId})> {
  $$BreedingRecordsTableTableManager(
      _$AppDriftDatabase db, $BreedingRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BreedingRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BreedingRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BreedingRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String?> femaleAnimalId = const Value.absent(),
            Value<String?> maleAnimalId = const Value.absent(),
            Value<String> breedingDate = const Value.absent(),
            Value<String?> expectedBirth = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> matingStartDate = const Value.absent(),
            Value<String?> matingEndDate = const Value.absent(),
            Value<String?> separationDate = const Value.absent(),
            Value<String?> ultrasoundDate = const Value.absent(),
            Value<String?> ultrasoundResult = const Value.absent(),
            Value<String?> birthDate = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BreedingRecordsCompanion(
            id: id,
            farmId: farmId,
            femaleAnimalId: femaleAnimalId,
            maleAnimalId: maleAnimalId,
            breedingDate: breedingDate,
            expectedBirth: expectedBirth,
            status: status,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            matingStartDate: matingStartDate,
            matingEndDate: matingEndDate,
            separationDate: separationDate,
            ultrasoundDate: ultrasoundDate,
            ultrasoundResult: ultrasoundResult,
            birthDate: birthDate,
            stage: stage,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            Value<String?> femaleAnimalId = const Value.absent(),
            Value<String?> maleAnimalId = const Value.absent(),
            required String breedingDate,
            Value<String?> expectedBirth = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String?> matingStartDate = const Value.absent(),
            Value<String?> matingEndDate = const Value.absent(),
            Value<String?> separationDate = const Value.absent(),
            Value<String?> ultrasoundDate = const Value.absent(),
            Value<String?> ultrasoundResult = const Value.absent(),
            Value<String?> birthDate = const Value.absent(),
            Value<String> stage = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BreedingRecordsCompanion.insert(
            id: id,
            farmId: farmId,
            femaleAnimalId: femaleAnimalId,
            maleAnimalId: maleAnimalId,
            breedingDate: breedingDate,
            expectedBirth: expectedBirth,
            status: status,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            matingStartDate: matingStartDate,
            matingEndDate: matingEndDate,
            separationDate: separationDate,
            ultrasoundDate: ultrasoundDate,
            ultrasoundResult: ultrasoundResult,
            birthDate: birthDate,
            stage: stage,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BreedingRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {femaleAnimalId = false, maleAnimalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (femaleAnimalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.femaleAnimalId,
                    referencedTable: $$BreedingRecordsTableReferences
                        ._femaleAnimalIdTable(db),
                    referencedColumn: $$BreedingRecordsTableReferences
                        ._femaleAnimalIdTable(db)
                        .id,
                  ) as T;
                }
                if (maleAnimalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.maleAnimalId,
                    referencedTable:
                        $$BreedingRecordsTableReferences._maleAnimalIdTable(db),
                    referencedColumn: $$BreedingRecordsTableReferences
                        ._maleAnimalIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BreedingRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $BreedingRecordsTable,
    BreedingRecordRow,
    $$BreedingRecordsTableFilterComposer,
    $$BreedingRecordsTableOrderingComposer,
    $$BreedingRecordsTableAnnotationComposer,
    $$BreedingRecordsTableCreateCompanionBuilder,
    $$BreedingRecordsTableUpdateCompanionBuilder,
    (BreedingRecordRow, $$BreedingRecordsTableReferences),
    BreedingRecordRow,
    PrefetchHooks Function({bool femaleAnimalId, bool maleAnimalId})>;
typedef $$MatrixEvaluationsTableCreateCompanionBuilder
    = MatrixEvaluationsCompanion Function({
  required String id,
  Value<String?> farmId,
  required String animalId,
  required String evaluationDate,
  required double fertilityScore,
  required double maternalScore,
  required double healthScore,
  required double temperamentScore,
  required double growthScore,
  Value<String> hoofCondition,
  Value<String> verminosisLevel,
  Value<String> twinningHistory,
  Value<double?> lambingWeight,
  Value<double?> weaningWeight,
  Value<double> lactationScore,
  Value<double> bodyConditionScore,
  Value<double> dentitionScore,
  Value<int?> ageMonths,
  required double finalScore,
  Value<String> recommendation,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$MatrixEvaluationsTableUpdateCompanionBuilder
    = MatrixEvaluationsCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> animalId,
  Value<String> evaluationDate,
  Value<double> fertilityScore,
  Value<double> maternalScore,
  Value<double> healthScore,
  Value<double> temperamentScore,
  Value<double> growthScore,
  Value<String> hoofCondition,
  Value<String> verminosisLevel,
  Value<String> twinningHistory,
  Value<double?> lambingWeight,
  Value<double?> weaningWeight,
  Value<double> lactationScore,
  Value<double> bodyConditionScore,
  Value<double> dentitionScore,
  Value<int?> ageMonths,
  Value<double> finalScore,
  Value<String> recommendation,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$MatrixEvaluationsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $MatrixEvaluationsTable, MatrixEvaluationRow> {
  $$MatrixEvaluationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _animalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias(
          $_aliasNameGenerator(db.matrixEvaluations.animalId, db.animals.id));

  $$AnimalsTableProcessedTableManager get animalId {
    final $_column = $_itemColumn<String>('animal_id')!;

    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MatrixEvaluationsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $MatrixEvaluationsTable> {
  $$MatrixEvaluationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get evaluationDate => $composableBuilder(
      column: $table.evaluationDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fertilityScore => $composableBuilder(
      column: $table.fertilityScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maternalScore => $composableBuilder(
      column: $table.maternalScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get healthScore => $composableBuilder(
      column: $table.healthScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperamentScore => $composableBuilder(
      column: $table.temperamentScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get growthScore => $composableBuilder(
      column: $table.growthScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hoofCondition => $composableBuilder(
      column: $table.hoofCondition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verminosisLevel => $composableBuilder(
      column: $table.verminosisLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get twinningHistory => $composableBuilder(
      column: $table.twinningHistory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lambingWeight => $composableBuilder(
      column: $table.lambingWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weaningWeight => $composableBuilder(
      column: $table.weaningWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lactationScore => $composableBuilder(
      column: $table.lactationScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bodyConditionScore => $composableBuilder(
      column: $table.bodyConditionScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dentitionScore => $composableBuilder(
      column: $table.dentitionScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ageMonths => $composableBuilder(
      column: $table.ageMonths, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recommendation => $composableBuilder(
      column: $table.recommendation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get animalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MatrixEvaluationsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $MatrixEvaluationsTable> {
  $$MatrixEvaluationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get evaluationDate => $composableBuilder(
      column: $table.evaluationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fertilityScore => $composableBuilder(
      column: $table.fertilityScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maternalScore => $composableBuilder(
      column: $table.maternalScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get healthScore => $composableBuilder(
      column: $table.healthScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperamentScore => $composableBuilder(
      column: $table.temperamentScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get growthScore => $composableBuilder(
      column: $table.growthScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hoofCondition => $composableBuilder(
      column: $table.hoofCondition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verminosisLevel => $composableBuilder(
      column: $table.verminosisLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get twinningHistory => $composableBuilder(
      column: $table.twinningHistory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lambingWeight => $composableBuilder(
      column: $table.lambingWeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weaningWeight => $composableBuilder(
      column: $table.weaningWeight,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lactationScore => $composableBuilder(
      column: $table.lactationScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bodyConditionScore => $composableBuilder(
      column: $table.bodyConditionScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dentitionScore => $composableBuilder(
      column: $table.dentitionScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ageMonths => $composableBuilder(
      column: $table.ageMonths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recommendation => $composableBuilder(
      column: $table.recommendation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get animalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MatrixEvaluationsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $MatrixEvaluationsTable> {
  $$MatrixEvaluationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get evaluationDate => $composableBuilder(
      column: $table.evaluationDate, builder: (column) => column);

  GeneratedColumn<double> get fertilityScore => $composableBuilder(
      column: $table.fertilityScore, builder: (column) => column);

  GeneratedColumn<double> get maternalScore => $composableBuilder(
      column: $table.maternalScore, builder: (column) => column);

  GeneratedColumn<double> get healthScore => $composableBuilder(
      column: $table.healthScore, builder: (column) => column);

  GeneratedColumn<double> get temperamentScore => $composableBuilder(
      column: $table.temperamentScore, builder: (column) => column);

  GeneratedColumn<double> get growthScore => $composableBuilder(
      column: $table.growthScore, builder: (column) => column);

  GeneratedColumn<String> get hoofCondition => $composableBuilder(
      column: $table.hoofCondition, builder: (column) => column);

  GeneratedColumn<String> get verminosisLevel => $composableBuilder(
      column: $table.verminosisLevel, builder: (column) => column);

  GeneratedColumn<String> get twinningHistory => $composableBuilder(
      column: $table.twinningHistory, builder: (column) => column);

  GeneratedColumn<double> get lambingWeight => $composableBuilder(
      column: $table.lambingWeight, builder: (column) => column);

  GeneratedColumn<double> get weaningWeight => $composableBuilder(
      column: $table.weaningWeight, builder: (column) => column);

  GeneratedColumn<double> get lactationScore => $composableBuilder(
      column: $table.lactationScore, builder: (column) => column);

  GeneratedColumn<double> get bodyConditionScore => $composableBuilder(
      column: $table.bodyConditionScore, builder: (column) => column);

  GeneratedColumn<double> get dentitionScore => $composableBuilder(
      column: $table.dentitionScore, builder: (column) => column);

  GeneratedColumn<int> get ageMonths =>
      $composableBuilder(column: $table.ageMonths, builder: (column) => column);

  GeneratedColumn<double> get finalScore => $composableBuilder(
      column: $table.finalScore, builder: (column) => column);

  GeneratedColumn<String> get recommendation => $composableBuilder(
      column: $table.recommendation, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get animalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MatrixEvaluationsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $MatrixEvaluationsTable,
    MatrixEvaluationRow,
    $$MatrixEvaluationsTableFilterComposer,
    $$MatrixEvaluationsTableOrderingComposer,
    $$MatrixEvaluationsTableAnnotationComposer,
    $$MatrixEvaluationsTableCreateCompanionBuilder,
    $$MatrixEvaluationsTableUpdateCompanionBuilder,
    (MatrixEvaluationRow, $$MatrixEvaluationsTableReferences),
    MatrixEvaluationRow,
    PrefetchHooks Function({bool animalId})> {
  $$MatrixEvaluationsTableTableManager(
      _$AppDriftDatabase db, $MatrixEvaluationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatrixEvaluationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatrixEvaluationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatrixEvaluationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> evaluationDate = const Value.absent(),
            Value<double> fertilityScore = const Value.absent(),
            Value<double> maternalScore = const Value.absent(),
            Value<double> healthScore = const Value.absent(),
            Value<double> temperamentScore = const Value.absent(),
            Value<double> growthScore = const Value.absent(),
            Value<String> hoofCondition = const Value.absent(),
            Value<String> verminosisLevel = const Value.absent(),
            Value<String> twinningHistory = const Value.absent(),
            Value<double?> lambingWeight = const Value.absent(),
            Value<double?> weaningWeight = const Value.absent(),
            Value<double> lactationScore = const Value.absent(),
            Value<double> bodyConditionScore = const Value.absent(),
            Value<double> dentitionScore = const Value.absent(),
            Value<int?> ageMonths = const Value.absent(),
            Value<double> finalScore = const Value.absent(),
            Value<String> recommendation = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatrixEvaluationsCompanion(
            id: id,
            farmId: farmId,
            animalId: animalId,
            evaluationDate: evaluationDate,
            fertilityScore: fertilityScore,
            maternalScore: maternalScore,
            healthScore: healthScore,
            temperamentScore: temperamentScore,
            growthScore: growthScore,
            hoofCondition: hoofCondition,
            verminosisLevel: verminosisLevel,
            twinningHistory: twinningHistory,
            lambingWeight: lambingWeight,
            weaningWeight: weaningWeight,
            lactationScore: lactationScore,
            bodyConditionScore: bodyConditionScore,
            dentitionScore: dentitionScore,
            ageMonths: ageMonths,
            finalScore: finalScore,
            recommendation: recommendation,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String animalId,
            required String evaluationDate,
            required double fertilityScore,
            required double maternalScore,
            required double healthScore,
            required double temperamentScore,
            required double growthScore,
            Value<String> hoofCondition = const Value.absent(),
            Value<String> verminosisLevel = const Value.absent(),
            Value<String> twinningHistory = const Value.absent(),
            Value<double?> lambingWeight = const Value.absent(),
            Value<double?> weaningWeight = const Value.absent(),
            Value<double> lactationScore = const Value.absent(),
            Value<double> bodyConditionScore = const Value.absent(),
            Value<double> dentitionScore = const Value.absent(),
            Value<int?> ageMonths = const Value.absent(),
            required double finalScore,
            Value<String> recommendation = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatrixEvaluationsCompanion.insert(
            id: id,
            farmId: farmId,
            animalId: animalId,
            evaluationDate: evaluationDate,
            fertilityScore: fertilityScore,
            maternalScore: maternalScore,
            healthScore: healthScore,
            temperamentScore: temperamentScore,
            growthScore: growthScore,
            hoofCondition: hoofCondition,
            verminosisLevel: verminosisLevel,
            twinningHistory: twinningHistory,
            lambingWeight: lambingWeight,
            weaningWeight: weaningWeight,
            lactationScore: lactationScore,
            bodyConditionScore: bodyConditionScore,
            dentitionScore: dentitionScore,
            ageMonths: ageMonths,
            finalScore: finalScore,
            recommendation: recommendation,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MatrixEvaluationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({animalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (animalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.animalId,
                    referencedTable:
                        $$MatrixEvaluationsTableReferences._animalIdTable(db),
                    referencedColumn: $$MatrixEvaluationsTableReferences
                        ._animalIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MatrixEvaluationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $MatrixEvaluationsTable,
    MatrixEvaluationRow,
    $$MatrixEvaluationsTableFilterComposer,
    $$MatrixEvaluationsTableOrderingComposer,
    $$MatrixEvaluationsTableAnnotationComposer,
    $$MatrixEvaluationsTableCreateCompanionBuilder,
    $$MatrixEvaluationsTableUpdateCompanionBuilder,
    (MatrixEvaluationRow, $$MatrixEvaluationsTableReferences),
    MatrixEvaluationRow,
    PrefetchHooks Function({bool animalId})>;
typedef $$FinancialAccountsTableCreateCompanionBuilder
    = FinancialAccountsCompanion Function({
  required String id,
  Value<String?> farmId,
  required String type,
  required String category,
  Value<String?> description,
  required double amount,
  required String dueDate,
  Value<String?> paymentDate,
  Value<String> status,
  Value<String?> paymentMethod,
  Value<int?> installments,
  Value<int?> installmentNumber,
  Value<String?> parentId,
  Value<String?> animalId,
  Value<String?> supplierCustomer,
  Value<String?> notes,
  Value<bool> isRecurring,
  Value<String?> recurrenceFrequency,
  Value<String?> recurrenceEndDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$FinancialAccountsTableUpdateCompanionBuilder
    = FinancialAccountsCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> type,
  Value<String> category,
  Value<String?> description,
  Value<double> amount,
  Value<String> dueDate,
  Value<String?> paymentDate,
  Value<String> status,
  Value<String?> paymentMethod,
  Value<int?> installments,
  Value<int?> installmentNumber,
  Value<String?> parentId,
  Value<String?> animalId,
  Value<String?> supplierCustomer,
  Value<String?> notes,
  Value<bool> isRecurring,
  Value<String?> recurrenceFrequency,
  Value<String?> recurrenceEndDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$FinancialAccountsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $FinancialAccountsTable, FinancialAccountRow> {
  $$FinancialAccountsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _animalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias(
          $_aliasNameGenerator(db.financialAccounts.animalId, db.animals.id));

  $$AnimalsTableProcessedTableManager? get animalId {
    final $_column = $_itemColumn<String>('animal_id');
    if ($_column == null) return null;
    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FinancialAccountsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $FinancialAccountsTable> {
  $$FinancialAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get installments => $composableBuilder(
      column: $table.installments, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get installmentNumber => $composableBuilder(
      column: $table.installmentNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplierCustomer => $composableBuilder(
      column: $table.supplierCustomer,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceFrequency => $composableBuilder(
      column: $table.recurrenceFrequency,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get animalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FinancialAccountsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $FinancialAccountsTable> {
  $$FinancialAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get installments => $composableBuilder(
      column: $table.installments,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
      column: $table.installmentNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplierCustomer => $composableBuilder(
      column: $table.supplierCustomer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceFrequency => $composableBuilder(
      column: $table.recurrenceFrequency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get animalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FinancialAccountsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $FinancialAccountsTable> {
  $$FinancialAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<int> get installments => $composableBuilder(
      column: $table.installments, builder: (column) => column);

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
      column: $table.installmentNumber, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get supplierCustomer => $composableBuilder(
      column: $table.supplierCustomer, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurrenceFrequency => $composableBuilder(
      column: $table.recurrenceFrequency, builder: (column) => column);

  GeneratedColumn<String> get recurrenceEndDate => $composableBuilder(
      column: $table.recurrenceEndDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get animalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FinancialAccountsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $FinancialAccountsTable,
    FinancialAccountRow,
    $$FinancialAccountsTableFilterComposer,
    $$FinancialAccountsTableOrderingComposer,
    $$FinancialAccountsTableAnnotationComposer,
    $$FinancialAccountsTableCreateCompanionBuilder,
    $$FinancialAccountsTableUpdateCompanionBuilder,
    (FinancialAccountRow, $$FinancialAccountsTableReferences),
    FinancialAccountRow,
    PrefetchHooks Function({bool animalId})> {
  $$FinancialAccountsTableTableManager(
      _$AppDriftDatabase db, $FinancialAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialAccountsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> dueDate = const Value.absent(),
            Value<String?> paymentDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> paymentMethod = const Value.absent(),
            Value<int?> installments = const Value.absent(),
            Value<int?> installmentNumber = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> animalId = const Value.absent(),
            Value<String?> supplierCustomer = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrenceFrequency = const Value.absent(),
            Value<String?> recurrenceEndDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialAccountsCompanion(
            id: id,
            farmId: farmId,
            type: type,
            category: category,
            description: description,
            amount: amount,
            dueDate: dueDate,
            paymentDate: paymentDate,
            status: status,
            paymentMethod: paymentMethod,
            installments: installments,
            installmentNumber: installmentNumber,
            parentId: parentId,
            animalId: animalId,
            supplierCustomer: supplierCustomer,
            notes: notes,
            isRecurring: isRecurring,
            recurrenceFrequency: recurrenceFrequency,
            recurrenceEndDate: recurrenceEndDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String type,
            required String category,
            Value<String?> description = const Value.absent(),
            required double amount,
            required String dueDate,
            Value<String?> paymentDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> paymentMethod = const Value.absent(),
            Value<int?> installments = const Value.absent(),
            Value<int?> installmentNumber = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String?> animalId = const Value.absent(),
            Value<String?> supplierCustomer = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurrenceFrequency = const Value.absent(),
            Value<String?> recurrenceEndDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialAccountsCompanion.insert(
            id: id,
            farmId: farmId,
            type: type,
            category: category,
            description: description,
            amount: amount,
            dueDate: dueDate,
            paymentDate: paymentDate,
            status: status,
            paymentMethod: paymentMethod,
            installments: installments,
            installmentNumber: installmentNumber,
            parentId: parentId,
            animalId: animalId,
            supplierCustomer: supplierCustomer,
            notes: notes,
            isRecurring: isRecurring,
            recurrenceFrequency: recurrenceFrequency,
            recurrenceEndDate: recurrenceEndDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FinancialAccountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({animalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (animalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.animalId,
                    referencedTable:
                        $$FinancialAccountsTableReferences._animalIdTable(db),
                    referencedColumn: $$FinancialAccountsTableReferences
                        ._animalIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FinancialAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $FinancialAccountsTable,
    FinancialAccountRow,
    $$FinancialAccountsTableFilterComposer,
    $$FinancialAccountsTableOrderingComposer,
    $$FinancialAccountsTableAnnotationComposer,
    $$FinancialAccountsTableCreateCompanionBuilder,
    $$FinancialAccountsTableUpdateCompanionBuilder,
    (FinancialAccountRow, $$FinancialAccountsTableReferences),
    FinancialAccountRow,
    PrefetchHooks Function({bool animalId})>;
typedef $$FinancialRecordsTableCreateCompanionBuilder
    = FinancialRecordsCompanion Function({
  required String id,
  Value<String?> farmId,
  required String type,
  required String category,
  Value<String?> description,
  required double amount,
  required String date,
  Value<String?> animalId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$FinancialRecordsTableUpdateCompanionBuilder
    = FinancialRecordsCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> type,
  Value<String> category,
  Value<String?> description,
  Value<double> amount,
  Value<String> date,
  Value<String?> animalId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$FinancialRecordsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $FinancialRecordsTable, FinancialRecordRow> {
  $$FinancialRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _animalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias(
          $_aliasNameGenerator(db.financialRecords.animalId, db.animals.id));

  $$AnimalsTableProcessedTableManager? get animalId {
    final $_column = $_itemColumn<String>('animal_id');
    if ($_column == null) return null;
    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FinancialRecordsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get animalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FinancialRecordsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get animalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FinancialRecordsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get animalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FinancialRecordsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $FinancialRecordsTable,
    FinancialRecordRow,
    $$FinancialRecordsTableFilterComposer,
    $$FinancialRecordsTableOrderingComposer,
    $$FinancialRecordsTableAnnotationComposer,
    $$FinancialRecordsTableCreateCompanionBuilder,
    $$FinancialRecordsTableUpdateCompanionBuilder,
    (FinancialRecordRow, $$FinancialRecordsTableReferences),
    FinancialRecordRow,
    PrefetchHooks Function({bool animalId})> {
  $$FinancialRecordsTableTableManager(
      _$AppDriftDatabase db, $FinancialRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String?> animalId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialRecordsCompanion(
            id: id,
            farmId: farmId,
            type: type,
            category: category,
            description: description,
            amount: amount,
            date: date,
            animalId: animalId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String type,
            required String category,
            Value<String?> description = const Value.absent(),
            required double amount,
            required String date,
            Value<String?> animalId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialRecordsCompanion.insert(
            id: id,
            farmId: farmId,
            type: type,
            category: category,
            description: description,
            amount: amount,
            date: date,
            animalId: animalId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FinancialRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({animalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (animalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.animalId,
                    referencedTable:
                        $$FinancialRecordsTableReferences._animalIdTable(db),
                    referencedColumn:
                        $$FinancialRecordsTableReferences._animalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FinancialRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $FinancialRecordsTable,
    FinancialRecordRow,
    $$FinancialRecordsTableFilterComposer,
    $$FinancialRecordsTableOrderingComposer,
    $$FinancialRecordsTableAnnotationComposer,
    $$FinancialRecordsTableCreateCompanionBuilder,
    $$FinancialRecordsTableUpdateCompanionBuilder,
    (FinancialRecordRow, $$FinancialRecordsTableReferences),
    FinancialRecordRow,
    PrefetchHooks Function({bool animalId})>;
typedef $$PharmacyStockTableCreateCompanionBuilder = PharmacyStockCompanion
    Function({
  required String id,
  Value<String?> farmId,
  required String medicationName,
  required String medicationType,
  required String unitOfMeasure,
  Value<double?> quantityPerUnit,
  Value<double> totalQuantity,
  Value<double?> minStockAlert,
  Value<String?> expirationDate,
  Value<bool> isOpened,
  Value<double> openedQuantity,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$PharmacyStockTableUpdateCompanionBuilder = PharmacyStockCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> medicationName,
  Value<String> medicationType,
  Value<String> unitOfMeasure,
  Value<double?> quantityPerUnit,
  Value<double> totalQuantity,
  Value<double?> minStockAlert,
  Value<String?> expirationDate,
  Value<bool> isOpened,
  Value<double> openedQuantity,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PharmacyStockTableReferences extends BaseReferences<
    _$AppDriftDatabase, $PharmacyStockTable, PharmacyStockRow> {
  $$PharmacyStockTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicationsTable, List<MedicationRow>>
      _medicationsRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.medications,
              aliasName: $_aliasNameGenerator(
                  db.pharmacyStock.id, db.medications.pharmacyStockId));

  $$MedicationsTableProcessedTableManager get medicationsRefs {
    final manager = $$MedicationsTableTableManager($_db, $_db.medications)
        .filter(
            (f) => f.pharmacyStockId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PharmacyStockMovementsTable,
      List<PharmacyMovementRow>> _pharmacyStockMovementsRefsTable(
          _$AppDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.pharmacyStockMovements,
          aliasName: $_aliasNameGenerator(
              db.pharmacyStock.id, db.pharmacyStockMovements.pharmacyStockId));

  $$PharmacyStockMovementsTableProcessedTableManager
      get pharmacyStockMovementsRefs {
    final manager = $$PharmacyStockMovementsTableTableManager(
            $_db, $_db.pharmacyStockMovements)
        .filter(
            (f) => f.pharmacyStockId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pharmacyStockMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PharmacyStockTableFilterComposer
    extends Composer<_$AppDriftDatabase, $PharmacyStockTable> {
  $$PharmacyStockTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicationName => $composableBuilder(
      column: $table.medicationName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicationType => $composableBuilder(
      column: $table.medicationType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitOfMeasure => $composableBuilder(
      column: $table.unitOfMeasure, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityPerUnit => $composableBuilder(
      column: $table.quantityPerUnit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minStockAlert => $composableBuilder(
      column: $table.minStockAlert, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expirationDate => $composableBuilder(
      column: $table.expirationDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOpened => $composableBuilder(
      column: $table.isOpened, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openedQuantity => $composableBuilder(
      column: $table.openedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> medicationsRefs(
      Expression<bool> Function($$MedicationsTableFilterComposer f) f) {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.pharmacyStockId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableFilterComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pharmacyStockMovementsRefs(
      Expression<bool> Function($$PharmacyStockMovementsTableFilterComposer f)
          f) {
    final $$PharmacyStockMovementsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pharmacyStockMovements,
            getReferencedColumn: (t) => t.pharmacyStockId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PharmacyStockMovementsTableFilterComposer(
                  $db: $db,
                  $table: $db.pharmacyStockMovements,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PharmacyStockTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $PharmacyStockTable> {
  $$PharmacyStockTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicationName => $composableBuilder(
      column: $table.medicationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicationType => $composableBuilder(
      column: $table.medicationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitOfMeasure => $composableBuilder(
      column: $table.unitOfMeasure,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityPerUnit => $composableBuilder(
      column: $table.quantityPerUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minStockAlert => $composableBuilder(
      column: $table.minStockAlert,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expirationDate => $composableBuilder(
      column: $table.expirationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOpened => $composableBuilder(
      column: $table.isOpened, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openedQuantity => $composableBuilder(
      column: $table.openedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PharmacyStockTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $PharmacyStockTable> {
  $$PharmacyStockTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
      column: $table.medicationName, builder: (column) => column);

  GeneratedColumn<String> get medicationType => $composableBuilder(
      column: $table.medicationType, builder: (column) => column);

  GeneratedColumn<String> get unitOfMeasure => $composableBuilder(
      column: $table.unitOfMeasure, builder: (column) => column);

  GeneratedColumn<double> get quantityPerUnit => $composableBuilder(
      column: $table.quantityPerUnit, builder: (column) => column);

  GeneratedColumn<double> get totalQuantity => $composableBuilder(
      column: $table.totalQuantity, builder: (column) => column);

  GeneratedColumn<double> get minStockAlert => $composableBuilder(
      column: $table.minStockAlert, builder: (column) => column);

  GeneratedColumn<String> get expirationDate => $composableBuilder(
      column: $table.expirationDate, builder: (column) => column);

  GeneratedColumn<bool> get isOpened =>
      $composableBuilder(column: $table.isOpened, builder: (column) => column);

  GeneratedColumn<double> get openedQuantity => $composableBuilder(
      column: $table.openedQuantity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> medicationsRefs<T extends Object>(
      Expression<T> Function($$MedicationsTableAnnotationComposer a) f) {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.pharmacyStockId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableAnnotationComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pharmacyStockMovementsRefs<T extends Object>(
      Expression<T> Function($$PharmacyStockMovementsTableAnnotationComposer a)
          f) {
    final $$PharmacyStockMovementsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pharmacyStockMovements,
            getReferencedColumn: (t) => t.pharmacyStockId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PharmacyStockMovementsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pharmacyStockMovements,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PharmacyStockTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $PharmacyStockTable,
    PharmacyStockRow,
    $$PharmacyStockTableFilterComposer,
    $$PharmacyStockTableOrderingComposer,
    $$PharmacyStockTableAnnotationComposer,
    $$PharmacyStockTableCreateCompanionBuilder,
    $$PharmacyStockTableUpdateCompanionBuilder,
    (PharmacyStockRow, $$PharmacyStockTableReferences),
    PharmacyStockRow,
    PrefetchHooks Function(
        {bool medicationsRefs, bool pharmacyStockMovementsRefs})> {
  $$PharmacyStockTableTableManager(
      _$AppDriftDatabase db, $PharmacyStockTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PharmacyStockTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PharmacyStockTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PharmacyStockTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> medicationName = const Value.absent(),
            Value<String> medicationType = const Value.absent(),
            Value<String> unitOfMeasure = const Value.absent(),
            Value<double?> quantityPerUnit = const Value.absent(),
            Value<double> totalQuantity = const Value.absent(),
            Value<double?> minStockAlert = const Value.absent(),
            Value<String?> expirationDate = const Value.absent(),
            Value<bool> isOpened = const Value.absent(),
            Value<double> openedQuantity = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PharmacyStockCompanion(
            id: id,
            farmId: farmId,
            medicationName: medicationName,
            medicationType: medicationType,
            unitOfMeasure: unitOfMeasure,
            quantityPerUnit: quantityPerUnit,
            totalQuantity: totalQuantity,
            minStockAlert: minStockAlert,
            expirationDate: expirationDate,
            isOpened: isOpened,
            openedQuantity: openedQuantity,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String medicationName,
            required String medicationType,
            required String unitOfMeasure,
            Value<double?> quantityPerUnit = const Value.absent(),
            Value<double> totalQuantity = const Value.absent(),
            Value<double?> minStockAlert = const Value.absent(),
            Value<String?> expirationDate = const Value.absent(),
            Value<bool> isOpened = const Value.absent(),
            Value<double> openedQuantity = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PharmacyStockCompanion.insert(
            id: id,
            farmId: farmId,
            medicationName: medicationName,
            medicationType: medicationType,
            unitOfMeasure: unitOfMeasure,
            quantityPerUnit: quantityPerUnit,
            totalQuantity: totalQuantity,
            minStockAlert: minStockAlert,
            expirationDate: expirationDate,
            isOpened: isOpened,
            openedQuantity: openedQuantity,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PharmacyStockTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {medicationsRefs = false, pharmacyStockMovementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicationsRefs) db.medications,
                if (pharmacyStockMovementsRefs) db.pharmacyStockMovements
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicationsRefs)
                    await $_getPrefetchedData<PharmacyStockRow,
                            $PharmacyStockTable, MedicationRow>(
                        currentTable: table,
                        referencedTable: $$PharmacyStockTableReferences
                            ._medicationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PharmacyStockTableReferences(db, table, p0)
                                .medicationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.pharmacyStockId == item.id),
                        typedResults: items),
                  if (pharmacyStockMovementsRefs)
                    await $_getPrefetchedData<PharmacyStockRow,
                            $PharmacyStockTable, PharmacyMovementRow>(
                        currentTable: table,
                        referencedTable: $$PharmacyStockTableReferences
                            ._pharmacyStockMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PharmacyStockTableReferences(db, table, p0)
                                .pharmacyStockMovementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.pharmacyStockId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PharmacyStockTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $PharmacyStockTable,
    PharmacyStockRow,
    $$PharmacyStockTableFilterComposer,
    $$PharmacyStockTableOrderingComposer,
    $$PharmacyStockTableAnnotationComposer,
    $$PharmacyStockTableCreateCompanionBuilder,
    $$PharmacyStockTableUpdateCompanionBuilder,
    (PharmacyStockRow, $$PharmacyStockTableReferences),
    PharmacyStockRow,
    PrefetchHooks Function(
        {bool medicationsRefs, bool pharmacyStockMovementsRefs})>;
typedef $$MedicationsTableCreateCompanionBuilder = MedicationsCompanion
    Function({
  required String id,
  Value<String?> farmId,
  required String animalId,
  required String medicationName,
  required String date,
  Value<String?> nextDate,
  Value<String?> dosage,
  Value<String?> veterinarian,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> status,
  Value<String?> appliedDate,
  Value<String?> pharmacyStockId,
  Value<double?> quantityUsed,
  Value<int> rowid,
});
typedef $$MedicationsTableUpdateCompanionBuilder = MedicationsCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> animalId,
  Value<String> medicationName,
  Value<String> date,
  Value<String?> nextDate,
  Value<String?> dosage,
  Value<String?> veterinarian,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> status,
  Value<String?> appliedDate,
  Value<String?> pharmacyStockId,
  Value<double?> quantityUsed,
  Value<int> rowid,
});

final class $$MedicationsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $MedicationsTable, MedicationRow> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _animalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias(
          $_aliasNameGenerator(db.medications.animalId, db.animals.id));

  $$AnimalsTableProcessedTableManager get animalId {
    final $_column = $_itemColumn<String>('animal_id')!;

    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PharmacyStockTable _pharmacyStockIdTable(_$AppDriftDatabase db) =>
      db.pharmacyStock.createAlias($_aliasNameGenerator(
          db.medications.pharmacyStockId, db.pharmacyStock.id));

  $$PharmacyStockTableProcessedTableManager? get pharmacyStockId {
    final $_column = $_itemColumn<String>('pharmacy_stock_id');
    if ($_column == null) return null;
    final manager = $$PharmacyStockTableTableManager($_db, $_db.pharmacyStock)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pharmacyStockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PharmacyStockMovementsTable,
      List<PharmacyMovementRow>> _pharmacyStockMovementsRefsTable(
          _$AppDriftDatabase db) =>
      MultiTypedResultKey.fromTable(db.pharmacyStockMovements,
          aliasName: $_aliasNameGenerator(
              db.medications.id, db.pharmacyStockMovements.medicationId));

  $$PharmacyStockMovementsTableProcessedTableManager
      get pharmacyStockMovementsRefs {
    final manager = $$PharmacyStockMovementsTableTableManager(
            $_db, $_db.pharmacyStockMovements)
        .filter(
            (f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pharmacyStockMovementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicationName => $composableBuilder(
      column: $table.medicationName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nextDate => $composableBuilder(
      column: $table.nextDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appliedDate => $composableBuilder(
      column: $table.appliedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityUsed => $composableBuilder(
      column: $table.quantityUsed, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get animalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PharmacyStockTableFilterComposer get pharmacyStockId {
    final $$PharmacyStockTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pharmacyStockId,
        referencedTable: $db.pharmacyStock,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PharmacyStockTableFilterComposer(
              $db: $db,
              $table: $db.pharmacyStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> pharmacyStockMovementsRefs(
      Expression<bool> Function($$PharmacyStockMovementsTableFilterComposer f)
          f) {
    final $$PharmacyStockMovementsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pharmacyStockMovements,
            getReferencedColumn: (t) => t.medicationId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PharmacyStockMovementsTableFilterComposer(
                  $db: $db,
                  $table: $db.pharmacyStockMovements,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicationName => $composableBuilder(
      column: $table.medicationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nextDate => $composableBuilder(
      column: $table.nextDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appliedDate => $composableBuilder(
      column: $table.appliedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityUsed => $composableBuilder(
      column: $table.quantityUsed,
      builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get animalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PharmacyStockTableOrderingComposer get pharmacyStockId {
    final $$PharmacyStockTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pharmacyStockId,
        referencedTable: $db.pharmacyStock,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PharmacyStockTableOrderingComposer(
              $db: $db,
              $table: $db.pharmacyStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
      column: $table.medicationName, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get nextDate =>
      $composableBuilder(column: $table.nextDate, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get appliedDate => $composableBuilder(
      column: $table.appliedDate, builder: (column) => column);

  GeneratedColumn<double> get quantityUsed => $composableBuilder(
      column: $table.quantityUsed, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get animalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PharmacyStockTableAnnotationComposer get pharmacyStockId {
    final $$PharmacyStockTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pharmacyStockId,
        referencedTable: $db.pharmacyStock,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PharmacyStockTableAnnotationComposer(
              $db: $db,
              $table: $db.pharmacyStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> pharmacyStockMovementsRefs<T extends Object>(
      Expression<T> Function($$PharmacyStockMovementsTableAnnotationComposer a)
          f) {
    final $$PharmacyStockMovementsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pharmacyStockMovements,
            getReferencedColumn: (t) => t.medicationId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PharmacyStockMovementsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pharmacyStockMovements,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MedicationsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $MedicationsTable,
    MedicationRow,
    $$MedicationsTableFilterComposer,
    $$MedicationsTableOrderingComposer,
    $$MedicationsTableAnnotationComposer,
    $$MedicationsTableCreateCompanionBuilder,
    $$MedicationsTableUpdateCompanionBuilder,
    (MedicationRow, $$MedicationsTableReferences),
    MedicationRow,
    PrefetchHooks Function(
        {bool animalId,
        bool pharmacyStockId,
        bool pharmacyStockMovementsRefs})> {
  $$MedicationsTableTableManager(_$AppDriftDatabase db, $MedicationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> medicationName = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String?> nextDate = const Value.absent(),
            Value<String?> dosage = const Value.absent(),
            Value<String?> veterinarian = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> appliedDate = const Value.absent(),
            Value<String?> pharmacyStockId = const Value.absent(),
            Value<double?> quantityUsed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationsCompanion(
            id: id,
            farmId: farmId,
            animalId: animalId,
            medicationName: medicationName,
            date: date,
            nextDate: nextDate,
            dosage: dosage,
            veterinarian: veterinarian,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            status: status,
            appliedDate: appliedDate,
            pharmacyStockId: pharmacyStockId,
            quantityUsed: quantityUsed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String animalId,
            required String medicationName,
            required String date,
            Value<String?> nextDate = const Value.absent(),
            Value<String?> dosage = const Value.absent(),
            Value<String?> veterinarian = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> appliedDate = const Value.absent(),
            Value<String?> pharmacyStockId = const Value.absent(),
            Value<double?> quantityUsed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationsCompanion.insert(
            id: id,
            farmId: farmId,
            animalId: animalId,
            medicationName: medicationName,
            date: date,
            nextDate: nextDate,
            dosage: dosage,
            veterinarian: veterinarian,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            status: status,
            appliedDate: appliedDate,
            pharmacyStockId: pharmacyStockId,
            quantityUsed: quantityUsed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MedicationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {animalId = false,
              pharmacyStockId = false,
              pharmacyStockMovementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pharmacyStockMovementsRefs) db.pharmacyStockMovements
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (animalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.animalId,
                    referencedTable:
                        $$MedicationsTableReferences._animalIdTable(db),
                    referencedColumn:
                        $$MedicationsTableReferences._animalIdTable(db).id,
                  ) as T;
                }
                if (pharmacyStockId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pharmacyStockId,
                    referencedTable:
                        $$MedicationsTableReferences._pharmacyStockIdTable(db),
                    referencedColumn: $$MedicationsTableReferences
                        ._pharmacyStockIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pharmacyStockMovementsRefs)
                    await $_getPrefetchedData<MedicationRow, $MedicationsTable,
                            PharmacyMovementRow>(
                        currentTable: table,
                        referencedTable: $$MedicationsTableReferences
                            ._pharmacyStockMovementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MedicationsTableReferences(db, table, p0)
                                .pharmacyStockMovementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.medicationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MedicationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $MedicationsTable,
    MedicationRow,
    $$MedicationsTableFilterComposer,
    $$MedicationsTableOrderingComposer,
    $$MedicationsTableAnnotationComposer,
    $$MedicationsTableCreateCompanionBuilder,
    $$MedicationsTableUpdateCompanionBuilder,
    (MedicationRow, $$MedicationsTableReferences),
    MedicationRow,
    PrefetchHooks Function(
        {bool animalId,
        bool pharmacyStockId,
        bool pharmacyStockMovementsRefs})>;
typedef $$PharmacyStockMovementsTableCreateCompanionBuilder
    = PharmacyStockMovementsCompanion Function({
  required String id,
  Value<String?> farmId,
  required String pharmacyStockId,
  Value<String?> medicationId,
  required String movementType,
  required double quantity,
  Value<String?> reason,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PharmacyStockMovementsTableUpdateCompanionBuilder
    = PharmacyStockMovementsCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> pharmacyStockId,
  Value<String?> medicationId,
  Value<String> movementType,
  Value<double> quantity,
  Value<String?> reason,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$PharmacyStockMovementsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $PharmacyStockMovementsTable, PharmacyMovementRow> {
  $$PharmacyStockMovementsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PharmacyStockTable _pharmacyStockIdTable(_$AppDriftDatabase db) =>
      db.pharmacyStock.createAlias($_aliasNameGenerator(
          db.pharmacyStockMovements.pharmacyStockId, db.pharmacyStock.id));

  $$PharmacyStockTableProcessedTableManager get pharmacyStockId {
    final $_column = $_itemColumn<String>('pharmacy_stock_id')!;

    final manager = $$PharmacyStockTableTableManager($_db, $_db.pharmacyStock)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pharmacyStockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MedicationsTable _medicationIdTable(_$AppDriftDatabase db) =>
      db.medications.createAlias($_aliasNameGenerator(
          db.pharmacyStockMovements.medicationId, db.medications.id));

  $$MedicationsTableProcessedTableManager? get medicationId {
    final $_column = $_itemColumn<String>('medication_id');
    if ($_column == null) return null;
    final manager = $$MedicationsTableTableManager($_db, $_db.medications)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PharmacyStockMovementsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $PharmacyStockMovementsTable> {
  $$PharmacyStockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get movementType => $composableBuilder(
      column: $table.movementType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PharmacyStockTableFilterComposer get pharmacyStockId {
    final $$PharmacyStockTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pharmacyStockId,
        referencedTable: $db.pharmacyStock,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PharmacyStockTableFilterComposer(
              $db: $db,
              $table: $db.pharmacyStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicationId,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableFilterComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PharmacyStockMovementsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $PharmacyStockMovementsTable> {
  $$PharmacyStockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get movementType => $composableBuilder(
      column: $table.movementType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PharmacyStockTableOrderingComposer get pharmacyStockId {
    final $$PharmacyStockTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pharmacyStockId,
        referencedTable: $db.pharmacyStock,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PharmacyStockTableOrderingComposer(
              $db: $db,
              $table: $db.pharmacyStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicationId,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableOrderingComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PharmacyStockMovementsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $PharmacyStockMovementsTable> {
  $$PharmacyStockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get movementType => $composableBuilder(
      column: $table.movementType, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PharmacyStockTableAnnotationComposer get pharmacyStockId {
    final $$PharmacyStockTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pharmacyStockId,
        referencedTable: $db.pharmacyStock,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PharmacyStockTableAnnotationComposer(
              $db: $db,
              $table: $db.pharmacyStock,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.medicationId,
        referencedTable: $db.medications,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MedicationsTableAnnotationComposer(
              $db: $db,
              $table: $db.medications,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PharmacyStockMovementsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $PharmacyStockMovementsTable,
    PharmacyMovementRow,
    $$PharmacyStockMovementsTableFilterComposer,
    $$PharmacyStockMovementsTableOrderingComposer,
    $$PharmacyStockMovementsTableAnnotationComposer,
    $$PharmacyStockMovementsTableCreateCompanionBuilder,
    $$PharmacyStockMovementsTableUpdateCompanionBuilder,
    (PharmacyMovementRow, $$PharmacyStockMovementsTableReferences),
    PharmacyMovementRow,
    PrefetchHooks Function({bool pharmacyStockId, bool medicationId})> {
  $$PharmacyStockMovementsTableTableManager(
      _$AppDriftDatabase db, $PharmacyStockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PharmacyStockMovementsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PharmacyStockMovementsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PharmacyStockMovementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> pharmacyStockId = const Value.absent(),
            Value<String?> medicationId = const Value.absent(),
            Value<String> movementType = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PharmacyStockMovementsCompanion(
            id: id,
            farmId: farmId,
            pharmacyStockId: pharmacyStockId,
            medicationId: medicationId,
            movementType: movementType,
            quantity: quantity,
            reason: reason,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String pharmacyStockId,
            Value<String?> medicationId = const Value.absent(),
            required String movementType,
            required double quantity,
            Value<String?> reason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PharmacyStockMovementsCompanion.insert(
            id: id,
            farmId: farmId,
            pharmacyStockId: pharmacyStockId,
            medicationId: medicationId,
            movementType: movementType,
            quantity: quantity,
            reason: reason,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PharmacyStockMovementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {pharmacyStockId = false, medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (pharmacyStockId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pharmacyStockId,
                    referencedTable: $$PharmacyStockMovementsTableReferences
                        ._pharmacyStockIdTable(db),
                    referencedColumn: $$PharmacyStockMovementsTableReferences
                        ._pharmacyStockIdTable(db)
                        .id,
                  ) as T;
                }
                if (medicationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.medicationId,
                    referencedTable: $$PharmacyStockMovementsTableReferences
                        ._medicationIdTable(db),
                    referencedColumn: $$PharmacyStockMovementsTableReferences
                        ._medicationIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PharmacyStockMovementsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDriftDatabase,
        $PharmacyStockMovementsTable,
        PharmacyMovementRow,
        $$PharmacyStockMovementsTableFilterComposer,
        $$PharmacyStockMovementsTableOrderingComposer,
        $$PharmacyStockMovementsTableAnnotationComposer,
        $$PharmacyStockMovementsTableCreateCompanionBuilder,
        $$PharmacyStockMovementsTableUpdateCompanionBuilder,
        (PharmacyMovementRow, $$PharmacyStockMovementsTableReferences),
        PharmacyMovementRow,
        PrefetchHooks Function({bool pharmacyStockId, bool medicationId})>;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  Value<String?> farmId,
  Value<String?> animalId,
  required String title,
  Value<String?> content,
  required String category,
  Value<String> priority,
  required String date,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isRead,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String?> animalId,
  Value<String> title,
  Value<String?> content,
  Value<String> category,
  Value<String> priority,
  Value<String> date,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isRead,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDriftDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _animalIdTable(_$AppDriftDatabase db) => db.animals
      .createAlias($_aliasNameGenerator(db.notes.animalId, db.animals.id));

  $$AnimalsTableProcessedTableManager? get animalId {
    final $_column = $_itemColumn<String>('animal_id');
    if ($_column == null) return null;
    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NotesTableFilterComposer
    extends Composer<_$AppDriftDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get animalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get animalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get animalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (NoteRow, $$NotesTableReferences),
    NoteRow,
    PrefetchHooks Function({bool animalId})> {
  $$NotesTableTableManager(_$AppDriftDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String?> animalId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            farmId: farmId,
            animalId: animalId,
            title: title,
            content: content,
            category: category,
            priority: priority,
            date: date,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isRead: isRead,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            Value<String?> animalId = const Value.absent(),
            required String title,
            Value<String?> content = const Value.absent(),
            required String category,
            Value<String> priority = const Value.absent(),
            required String date,
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            farmId: farmId,
            animalId: animalId,
            title: title,
            content: content,
            category: category,
            priority: priority,
            date: date,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isRead: isRead,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$NotesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({animalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (animalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.animalId,
                    referencedTable: $$NotesTableReferences._animalIdTable(db),
                    referencedColumn:
                        $$NotesTableReferences._animalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (NoteRow, $$NotesTableReferences),
    NoteRow,
    PrefetchHooks Function({bool animalId})>;
typedef $$ReportsTableCreateCompanionBuilder = ReportsCompanion Function({
  required String id,
  Value<String?> farmId,
  required String title,
  required String reportType,
  Value<String> parameters,
  Value<DateTime> generatedAt,
  Value<String?> generatedBy,
  Value<int> rowid,
});
typedef $$ReportsTableUpdateCompanionBuilder = ReportsCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> title,
  Value<String> reportType,
  Value<String> parameters,
  Value<DateTime> generatedAt,
  Value<String?> generatedBy,
  Value<int> rowid,
});

class $$ReportsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $ReportsTable> {
  $$ReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parameters => $composableBuilder(
      column: $table.parameters, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get generatedBy => $composableBuilder(
      column: $table.generatedBy, builder: (column) => ColumnFilters(column));
}

class $$ReportsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $ReportsTable> {
  $$ReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parameters => $composableBuilder(
      column: $table.parameters, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get generatedBy => $composableBuilder(
      column: $table.generatedBy, builder: (column) => ColumnOrderings(column));
}

class $$ReportsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $ReportsTable> {
  $$ReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get reportType => $composableBuilder(
      column: $table.reportType, builder: (column) => column);

  GeneratedColumn<String> get parameters => $composableBuilder(
      column: $table.parameters, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => column);

  GeneratedColumn<String> get generatedBy => $composableBuilder(
      column: $table.generatedBy, builder: (column) => column);
}

class $$ReportsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $ReportsTable,
    ReportRow,
    $$ReportsTableFilterComposer,
    $$ReportsTableOrderingComposer,
    $$ReportsTableAnnotationComposer,
    $$ReportsTableCreateCompanionBuilder,
    $$ReportsTableUpdateCompanionBuilder,
    (ReportRow, BaseReferences<_$AppDriftDatabase, $ReportsTable, ReportRow>),
    ReportRow,
    PrefetchHooks Function()> {
  $$ReportsTableTableManager(_$AppDriftDatabase db, $ReportsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> reportType = const Value.absent(),
            Value<String> parameters = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
            Value<String?> generatedBy = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReportsCompanion(
            id: id,
            farmId: farmId,
            title: title,
            reportType: reportType,
            parameters: parameters,
            generatedAt: generatedAt,
            generatedBy: generatedBy,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String title,
            required String reportType,
            Value<String> parameters = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
            Value<String?> generatedBy = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReportsCompanion.insert(
            id: id,
            farmId: farmId,
            title: title,
            reportType: reportType,
            parameters: parameters,
            generatedAt: generatedAt,
            generatedBy: generatedBy,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReportsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $ReportsTable,
    ReportRow,
    $$ReportsTableFilterComposer,
    $$ReportsTableOrderingComposer,
    $$ReportsTableAnnotationComposer,
    $$ReportsTableCreateCompanionBuilder,
    $$ReportsTableUpdateCompanionBuilder,
    (ReportRow, BaseReferences<_$AppDriftDatabase, $ReportsTable, ReportRow>),
    ReportRow,
    PrefetchHooks Function()>;
typedef $$PushTokensTableCreateCompanionBuilder = PushTokensCompanion Function({
  required String id,
  Value<String?> farmId,
  required String token,
  Value<String?> platform,
  Value<String> deviceInfo,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$PushTokensTableUpdateCompanionBuilder = PushTokensCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> token,
  Value<String?> platform,
  Value<String> deviceInfo,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PushTokensTableFilterComposer
    extends Composer<_$AppDriftDatabase, $PushTokensTable> {
  $$PushTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PushTokensTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $PushTokensTable> {
  $$PushTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PushTokensTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $PushTokensTable> {
  $$PushTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get deviceInfo => $composableBuilder(
      column: $table.deviceInfo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PushTokensTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $PushTokensTable,
    PushTokenRow,
    $$PushTokensTableFilterComposer,
    $$PushTokensTableOrderingComposer,
    $$PushTokensTableAnnotationComposer,
    $$PushTokensTableCreateCompanionBuilder,
    $$PushTokensTableUpdateCompanionBuilder,
    (
      PushTokenRow,
      BaseReferences<_$AppDriftDatabase, $PushTokensTable, PushTokenRow>
    ),
    PushTokenRow,
    PrefetchHooks Function()> {
  $$PushTokensTableTableManager(_$AppDriftDatabase db, $PushTokensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PushTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PushTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PushTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> token = const Value.absent(),
            Value<String?> platform = const Value.absent(),
            Value<String> deviceInfo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PushTokensCompanion(
            id: id,
            farmId: farmId,
            token: token,
            platform: platform,
            deviceInfo: deviceInfo,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String token,
            Value<String?> platform = const Value.absent(),
            Value<String> deviceInfo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PushTokensCompanion.insert(
            id: id,
            farmId: farmId,
            token: token,
            platform: platform,
            deviceInfo: deviceInfo,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PushTokensTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $PushTokensTable,
    PushTokenRow,
    $$PushTokensTableFilterComposer,
    $$PushTokensTableOrderingComposer,
    $$PushTokensTableAnnotationComposer,
    $$PushTokensTableCreateCompanionBuilder,
    $$PushTokensTableUpdateCompanionBuilder,
    (
      PushTokenRow,
      BaseReferences<_$AppDriftDatabase, $PushTokensTable, PushTokenRow>
    ),
    PushTokenRow,
    PrefetchHooks Function()>;
typedef $$FeedingPensTableCreateCompanionBuilder = FeedingPensCompanion
    Function({
  required String id,
  Value<String?> farmId,
  required String name,
  Value<String?> number,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$FeedingPensTableUpdateCompanionBuilder = FeedingPensCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> name,
  Value<String?> number,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$FeedingPensTableReferences extends BaseReferences<
    _$AppDriftDatabase, $FeedingPensTable, FeedingPenRow> {
  $$FeedingPensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FeedingSchedulesTable, List<FeedingScheduleRow>>
      _feedingSchedulesRefsTable(_$AppDriftDatabase db) =>
          MultiTypedResultKey.fromTable(db.feedingSchedules,
              aliasName: $_aliasNameGenerator(
                  db.feedingPens.id, db.feedingSchedules.penId));

  $$FeedingSchedulesTableProcessedTableManager get feedingSchedulesRefs {
    final manager =
        $$FeedingSchedulesTableTableManager($_db, $_db.feedingSchedules)
            .filter((f) => f.penId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_feedingSchedulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FeedingPensTableFilterComposer
    extends Composer<_$AppDriftDatabase, $FeedingPensTable> {
  $$FeedingPensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> feedingSchedulesRefs(
      Expression<bool> Function($$FeedingSchedulesTableFilterComposer f) f) {
    final $$FeedingSchedulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.feedingSchedules,
        getReferencedColumn: (t) => t.penId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FeedingSchedulesTableFilterComposer(
              $db: $db,
              $table: $db.feedingSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FeedingPensTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $FeedingPensTable> {
  $$FeedingPensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FeedingPensTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $FeedingPensTable> {
  $$FeedingPensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> feedingSchedulesRefs<T extends Object>(
      Expression<T> Function($$FeedingSchedulesTableAnnotationComposer a) f) {
    final $$FeedingSchedulesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.feedingSchedules,
        getReferencedColumn: (t) => t.penId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FeedingSchedulesTableAnnotationComposer(
              $db: $db,
              $table: $db.feedingSchedules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FeedingPensTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $FeedingPensTable,
    FeedingPenRow,
    $$FeedingPensTableFilterComposer,
    $$FeedingPensTableOrderingComposer,
    $$FeedingPensTableAnnotationComposer,
    $$FeedingPensTableCreateCompanionBuilder,
    $$FeedingPensTableUpdateCompanionBuilder,
    (FeedingPenRow, $$FeedingPensTableReferences),
    FeedingPenRow,
    PrefetchHooks Function({bool feedingSchedulesRefs})> {
  $$FeedingPensTableTableManager(_$AppDriftDatabase db, $FeedingPensTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedingPensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedingPensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedingPensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> number = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeedingPensCompanion(
            id: id,
            farmId: farmId,
            name: name,
            number: number,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String name,
            Value<String?> number = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeedingPensCompanion.insert(
            id: id,
            farmId: farmId,
            name: name,
            number: number,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FeedingPensTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({feedingSchedulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (feedingSchedulesRefs) db.feedingSchedules
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (feedingSchedulesRefs)
                    await $_getPrefetchedData<FeedingPenRow, $FeedingPensTable,
                            FeedingScheduleRow>(
                        currentTable: table,
                        referencedTable: $$FeedingPensTableReferences
                            ._feedingSchedulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FeedingPensTableReferences(db, table, p0)
                                .feedingSchedulesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.penId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FeedingPensTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $FeedingPensTable,
    FeedingPenRow,
    $$FeedingPensTableFilterComposer,
    $$FeedingPensTableOrderingComposer,
    $$FeedingPensTableAnnotationComposer,
    $$FeedingPensTableCreateCompanionBuilder,
    $$FeedingPensTableUpdateCompanionBuilder,
    (FeedingPenRow, $$FeedingPensTableReferences),
    FeedingPenRow,
    PrefetchHooks Function({bool feedingSchedulesRefs})>;
typedef $$FeedingSchedulesTableCreateCompanionBuilder
    = FeedingSchedulesCompanion Function({
  required String id,
  Value<String?> farmId,
  required String penId,
  required String feedType,
  required double quantity,
  Value<int> timesPerDay,
  required String feedingTimes,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$FeedingSchedulesTableUpdateCompanionBuilder
    = FeedingSchedulesCompanion Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> penId,
  Value<String> feedType,
  Value<double> quantity,
  Value<int> timesPerDay,
  Value<String> feedingTimes,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$FeedingSchedulesTableReferences extends BaseReferences<
    _$AppDriftDatabase, $FeedingSchedulesTable, FeedingScheduleRow> {
  $$FeedingSchedulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FeedingPensTable _penIdTable(_$AppDriftDatabase db) =>
      db.feedingPens.createAlias(
          $_aliasNameGenerator(db.feedingSchedules.penId, db.feedingPens.id));

  $$FeedingPensTableProcessedTableManager get penId {
    final $_column = $_itemColumn<String>('pen_id')!;

    final manager = $$FeedingPensTableTableManager($_db, $_db.feedingPens)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_penIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FeedingSchedulesTableFilterComposer
    extends Composer<_$AppDriftDatabase, $FeedingSchedulesTable> {
  $$FeedingSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedType => $composableBuilder(
      column: $table.feedType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesPerDay => $composableBuilder(
      column: $table.timesPerDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedingTimes => $composableBuilder(
      column: $table.feedingTimes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$FeedingPensTableFilterComposer get penId {
    final $$FeedingPensTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.penId,
        referencedTable: $db.feedingPens,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FeedingPensTableFilterComposer(
              $db: $db,
              $table: $db.feedingPens,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FeedingSchedulesTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $FeedingSchedulesTable> {
  $$FeedingSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedType => $composableBuilder(
      column: $table.feedType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timesPerDay => $composableBuilder(
      column: $table.timesPerDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedingTimes => $composableBuilder(
      column: $table.feedingTimes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$FeedingPensTableOrderingComposer get penId {
    final $$FeedingPensTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.penId,
        referencedTable: $db.feedingPens,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FeedingPensTableOrderingComposer(
              $db: $db,
              $table: $db.feedingPens,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FeedingSchedulesTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $FeedingSchedulesTable> {
  $$FeedingSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get feedType =>
      $composableBuilder(column: $table.feedType, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get timesPerDay => $composableBuilder(
      column: $table.timesPerDay, builder: (column) => column);

  GeneratedColumn<String> get feedingTimes => $composableBuilder(
      column: $table.feedingTimes, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FeedingPensTableAnnotationComposer get penId {
    final $$FeedingPensTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.penId,
        referencedTable: $db.feedingPens,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FeedingPensTableAnnotationComposer(
              $db: $db,
              $table: $db.feedingPens,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FeedingSchedulesTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $FeedingSchedulesTable,
    FeedingScheduleRow,
    $$FeedingSchedulesTableFilterComposer,
    $$FeedingSchedulesTableOrderingComposer,
    $$FeedingSchedulesTableAnnotationComposer,
    $$FeedingSchedulesTableCreateCompanionBuilder,
    $$FeedingSchedulesTableUpdateCompanionBuilder,
    (FeedingScheduleRow, $$FeedingSchedulesTableReferences),
    FeedingScheduleRow,
    PrefetchHooks Function({bool penId})> {
  $$FeedingSchedulesTableTableManager(
      _$AppDriftDatabase db, $FeedingSchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedingSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedingSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedingSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> penId = const Value.absent(),
            Value<String> feedType = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<int> timesPerDay = const Value.absent(),
            Value<String> feedingTimes = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeedingSchedulesCompanion(
            id: id,
            farmId: farmId,
            penId: penId,
            feedType: feedType,
            quantity: quantity,
            timesPerDay: timesPerDay,
            feedingTimes: feedingTimes,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String penId,
            required String feedType,
            required double quantity,
            Value<int> timesPerDay = const Value.absent(),
            required String feedingTimes,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeedingSchedulesCompanion.insert(
            id: id,
            farmId: farmId,
            penId: penId,
            feedType: feedType,
            quantity: quantity,
            timesPerDay: timesPerDay,
            feedingTimes: feedingTimes,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FeedingSchedulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({penId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (penId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.penId,
                    referencedTable:
                        $$FeedingSchedulesTableReferences._penIdTable(db),
                    referencedColumn:
                        $$FeedingSchedulesTableReferences._penIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FeedingSchedulesTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $FeedingSchedulesTable,
    FeedingScheduleRow,
    $$FeedingSchedulesTableFilterComposer,
    $$FeedingSchedulesTableOrderingComposer,
    $$FeedingSchedulesTableAnnotationComposer,
    $$FeedingSchedulesTableCreateCompanionBuilder,
    $$FeedingSchedulesTableUpdateCompanionBuilder,
    (FeedingScheduleRow, $$FeedingSchedulesTableReferences),
    FeedingScheduleRow,
    PrefetchHooks Function({bool penId})>;
typedef $$VaccinationsTableCreateCompanionBuilder = VaccinationsCompanion
    Function({
  required String id,
  Value<String?> farmId,
  required String animalId,
  required String vaccineName,
  required String vaccineType,
  required String scheduledDate,
  Value<String?> appliedDate,
  Value<String?> veterinarian,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$VaccinationsTableUpdateCompanionBuilder = VaccinationsCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> animalId,
  Value<String> vaccineName,
  Value<String> vaccineType,
  Value<String> scheduledDate,
  Value<String?> appliedDate,
  Value<String?> veterinarian,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$VaccinationsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $VaccinationsTable, VaccinationRow> {
  $$VaccinationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _animalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias(
          $_aliasNameGenerator(db.vaccinations.animalId, db.animals.id));

  $$AnimalsTableProcessedTableManager get animalId {
    final $_column = $_itemColumn<String>('animal_id')!;

    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$VaccinationsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $VaccinationsTable> {
  $$VaccinationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vaccineName => $composableBuilder(
      column: $table.vaccineName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vaccineType => $composableBuilder(
      column: $table.vaccineType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appliedDate => $composableBuilder(
      column: $table.appliedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get animalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaccinationsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $VaccinationsTable> {
  $$VaccinationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vaccineName => $composableBuilder(
      column: $table.vaccineName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vaccineType => $composableBuilder(
      column: $table.vaccineType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appliedDate => $composableBuilder(
      column: $table.appliedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get animalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaccinationsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $VaccinationsTable> {
  $$VaccinationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get vaccineName => $composableBuilder(
      column: $table.vaccineName, builder: (column) => column);

  GeneratedColumn<String> get vaccineType => $composableBuilder(
      column: $table.vaccineType, builder: (column) => column);

  GeneratedColumn<String> get scheduledDate => $composableBuilder(
      column: $table.scheduledDate, builder: (column) => column);

  GeneratedColumn<String> get appliedDate => $composableBuilder(
      column: $table.appliedDate, builder: (column) => column);

  GeneratedColumn<String> get veterinarian => $composableBuilder(
      column: $table.veterinarian, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get animalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$VaccinationsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $VaccinationsTable,
    VaccinationRow,
    $$VaccinationsTableFilterComposer,
    $$VaccinationsTableOrderingComposer,
    $$VaccinationsTableAnnotationComposer,
    $$VaccinationsTableCreateCompanionBuilder,
    $$VaccinationsTableUpdateCompanionBuilder,
    (VaccinationRow, $$VaccinationsTableReferences),
    VaccinationRow,
    PrefetchHooks Function({bool animalId})> {
  $$VaccinationsTableTableManager(
      _$AppDriftDatabase db, $VaccinationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaccinationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> vaccineName = const Value.absent(),
            Value<String> vaccineType = const Value.absent(),
            Value<String> scheduledDate = const Value.absent(),
            Value<String?> appliedDate = const Value.absent(),
            Value<String?> veterinarian = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VaccinationsCompanion(
            id: id,
            farmId: farmId,
            animalId: animalId,
            vaccineName: vaccineName,
            vaccineType: vaccineType,
            scheduledDate: scheduledDate,
            appliedDate: appliedDate,
            veterinarian: veterinarian,
            notes: notes,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String animalId,
            required String vaccineName,
            required String vaccineType,
            required String scheduledDate,
            Value<String?> appliedDate = const Value.absent(),
            Value<String?> veterinarian = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VaccinationsCompanion.insert(
            id: id,
            farmId: farmId,
            animalId: animalId,
            vaccineName: vaccineName,
            vaccineType: vaccineType,
            scheduledDate: scheduledDate,
            appliedDate: appliedDate,
            veterinarian: veterinarian,
            notes: notes,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VaccinationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({animalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (animalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.animalId,
                    referencedTable:
                        $$VaccinationsTableReferences._animalIdTable(db),
                    referencedColumn:
                        $$VaccinationsTableReferences._animalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$VaccinationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $VaccinationsTable,
    VaccinationRow,
    $$VaccinationsTableFilterComposer,
    $$VaccinationsTableOrderingComposer,
    $$VaccinationsTableAnnotationComposer,
    $$VaccinationsTableCreateCompanionBuilder,
    $$VaccinationsTableUpdateCompanionBuilder,
    (VaccinationRow, $$VaccinationsTableReferences),
    VaccinationRow,
    PrefetchHooks Function({bool animalId})>;
typedef $$SoldAnimalsTableCreateCompanionBuilder = SoldAnimalsCompanion
    Function({
  required String id,
  Value<String?> farmId,
  required String originalAnimalId,
  required String code,
  required String name,
  required String species,
  required String breed,
  required String gender,
  required String birthDate,
  required double weight,
  required String location,
  Value<String> reproductiveStatus,
  Value<String?> nameColor,
  Value<String?> category,
  Value<double?> birthWeight,
  Value<double?> weight30Days,
  Value<double?> weight60Days,
  Value<double?> weight90Days,
  Value<double?> weight120Days,
  Value<int?> year,
  Value<String?> lote,
  Value<String?> motherId,
  Value<String?> fatherId,
  Value<String?> registrationNote,
  required String saleDate,
  Value<double?> salePrice,
  Value<String?> buyer,
  Value<String?> saleNotes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SoldAnimalsTableUpdateCompanionBuilder = SoldAnimalsCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> originalAnimalId,
  Value<String> code,
  Value<String> name,
  Value<String> species,
  Value<String> breed,
  Value<String> gender,
  Value<String> birthDate,
  Value<double> weight,
  Value<String> location,
  Value<String> reproductiveStatus,
  Value<String?> nameColor,
  Value<String?> category,
  Value<double?> birthWeight,
  Value<double?> weight30Days,
  Value<double?> weight60Days,
  Value<double?> weight90Days,
  Value<double?> weight120Days,
  Value<int?> year,
  Value<String?> lote,
  Value<String?> motherId,
  Value<String?> fatherId,
  Value<String?> registrationNote,
  Value<String> saleDate,
  Value<double?> salePrice,
  Value<String?> buyer,
  Value<String?> saleNotes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SoldAnimalsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $SoldAnimalsTable> {
  $$SoldAnimalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalAnimalId => $composableBuilder(
      column: $table.originalAnimalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameColor => $composableBuilder(
      column: $table.nameColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motherId => $composableBuilder(
      column: $table.motherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fatherId => $composableBuilder(
      column: $table.fatherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buyer => $composableBuilder(
      column: $table.buyer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get saleNotes => $composableBuilder(
      column: $table.saleNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SoldAnimalsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $SoldAnimalsTable> {
  $$SoldAnimalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalAnimalId => $composableBuilder(
      column: $table.originalAnimalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameColor => $composableBuilder(
      column: $table.nameColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motherId => $composableBuilder(
      column: $table.motherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fatherId => $composableBuilder(
      column: $table.fatherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleDate => $composableBuilder(
      column: $table.saleDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salePrice => $composableBuilder(
      column: $table.salePrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buyer => $composableBuilder(
      column: $table.buyer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get saleNotes => $composableBuilder(
      column: $table.saleNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SoldAnimalsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $SoldAnimalsTable> {
  $$SoldAnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get originalAnimalId => $composableBuilder(
      column: $table.originalAnimalId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus, builder: (column) => column);

  GeneratedColumn<String> get nameColor =>
      $composableBuilder(column: $table.nameColor, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => column);

  GeneratedColumn<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days, builder: (column) => column);

  GeneratedColumn<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days, builder: (column) => column);

  GeneratedColumn<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days, builder: (column) => column);

  GeneratedColumn<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get lote =>
      $composableBuilder(column: $table.lote, builder: (column) => column);

  GeneratedColumn<String> get motherId =>
      $composableBuilder(column: $table.motherId, builder: (column) => column);

  GeneratedColumn<String> get fatherId =>
      $composableBuilder(column: $table.fatherId, builder: (column) => column);

  GeneratedColumn<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote, builder: (column) => column);

  GeneratedColumn<String> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<String> get buyer =>
      $composableBuilder(column: $table.buyer, builder: (column) => column);

  GeneratedColumn<String> get saleNotes =>
      $composableBuilder(column: $table.saleNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SoldAnimalsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $SoldAnimalsTable,
    SoldAnimalRow,
    $$SoldAnimalsTableFilterComposer,
    $$SoldAnimalsTableOrderingComposer,
    $$SoldAnimalsTableAnnotationComposer,
    $$SoldAnimalsTableCreateCompanionBuilder,
    $$SoldAnimalsTableUpdateCompanionBuilder,
    (
      SoldAnimalRow,
      BaseReferences<_$AppDriftDatabase, $SoldAnimalsTable, SoldAnimalRow>
    ),
    SoldAnimalRow,
    PrefetchHooks Function()> {
  $$SoldAnimalsTableTableManager(_$AppDriftDatabase db, $SoldAnimalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SoldAnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SoldAnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SoldAnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> originalAnimalId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<String> breed = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String> birthDate = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String> reproductiveStatus = const Value.absent(),
            Value<String?> nameColor = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<double?> birthWeight = const Value.absent(),
            Value<double?> weight30Days = const Value.absent(),
            Value<double?> weight60Days = const Value.absent(),
            Value<double?> weight90Days = const Value.absent(),
            Value<double?> weight120Days = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> lote = const Value.absent(),
            Value<String?> motherId = const Value.absent(),
            Value<String?> fatherId = const Value.absent(),
            Value<String?> registrationNote = const Value.absent(),
            Value<String> saleDate = const Value.absent(),
            Value<double?> salePrice = const Value.absent(),
            Value<String?> buyer = const Value.absent(),
            Value<String?> saleNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SoldAnimalsCompanion(
            id: id,
            farmId: farmId,
            originalAnimalId: originalAnimalId,
            code: code,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            weight: weight,
            location: location,
            reproductiveStatus: reproductiveStatus,
            nameColor: nameColor,
            category: category,
            birthWeight: birthWeight,
            weight30Days: weight30Days,
            weight60Days: weight60Days,
            weight90Days: weight90Days,
            weight120Days: weight120Days,
            year: year,
            lote: lote,
            motherId: motherId,
            fatherId: fatherId,
            registrationNote: registrationNote,
            saleDate: saleDate,
            salePrice: salePrice,
            buyer: buyer,
            saleNotes: saleNotes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String originalAnimalId,
            required String code,
            required String name,
            required String species,
            required String breed,
            required String gender,
            required String birthDate,
            required double weight,
            required String location,
            Value<String> reproductiveStatus = const Value.absent(),
            Value<String?> nameColor = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<double?> birthWeight = const Value.absent(),
            Value<double?> weight30Days = const Value.absent(),
            Value<double?> weight60Days = const Value.absent(),
            Value<double?> weight90Days = const Value.absent(),
            Value<double?> weight120Days = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> lote = const Value.absent(),
            Value<String?> motherId = const Value.absent(),
            Value<String?> fatherId = const Value.absent(),
            Value<String?> registrationNote = const Value.absent(),
            required String saleDate,
            Value<double?> salePrice = const Value.absent(),
            Value<String?> buyer = const Value.absent(),
            Value<String?> saleNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SoldAnimalsCompanion.insert(
            id: id,
            farmId: farmId,
            originalAnimalId: originalAnimalId,
            code: code,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            weight: weight,
            location: location,
            reproductiveStatus: reproductiveStatus,
            nameColor: nameColor,
            category: category,
            birthWeight: birthWeight,
            weight30Days: weight30Days,
            weight60Days: weight60Days,
            weight90Days: weight90Days,
            weight120Days: weight120Days,
            year: year,
            lote: lote,
            motherId: motherId,
            fatherId: fatherId,
            registrationNote: registrationNote,
            saleDate: saleDate,
            salePrice: salePrice,
            buyer: buyer,
            saleNotes: saleNotes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SoldAnimalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $SoldAnimalsTable,
    SoldAnimalRow,
    $$SoldAnimalsTableFilterComposer,
    $$SoldAnimalsTableOrderingComposer,
    $$SoldAnimalsTableAnnotationComposer,
    $$SoldAnimalsTableCreateCompanionBuilder,
    $$SoldAnimalsTableUpdateCompanionBuilder,
    (
      SoldAnimalRow,
      BaseReferences<_$AppDriftDatabase, $SoldAnimalsTable, SoldAnimalRow>
    ),
    SoldAnimalRow,
    PrefetchHooks Function()>;
typedef $$DeceasedAnimalsTableCreateCompanionBuilder = DeceasedAnimalsCompanion
    Function({
  required String id,
  Value<String?> farmId,
  required String originalAnimalId,
  required String code,
  required String name,
  required String species,
  required String breed,
  required String gender,
  required String birthDate,
  required double weight,
  required String location,
  Value<String> reproductiveStatus,
  Value<String?> nameColor,
  Value<String?> category,
  Value<double?> birthWeight,
  Value<double?> weight30Days,
  Value<double?> weight60Days,
  Value<double?> weight90Days,
  Value<double?> weight120Days,
  Value<int?> year,
  Value<String?> lote,
  Value<String?> motherId,
  Value<String?> fatherId,
  Value<String?> registrationNote,
  required String deathDate,
  Value<String?> causeOfDeath,
  Value<String?> deathNotes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$DeceasedAnimalsTableUpdateCompanionBuilder = DeceasedAnimalsCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> originalAnimalId,
  Value<String> code,
  Value<String> name,
  Value<String> species,
  Value<String> breed,
  Value<String> gender,
  Value<String> birthDate,
  Value<double> weight,
  Value<String> location,
  Value<String> reproductiveStatus,
  Value<String?> nameColor,
  Value<String?> category,
  Value<double?> birthWeight,
  Value<double?> weight30Days,
  Value<double?> weight60Days,
  Value<double?> weight90Days,
  Value<double?> weight120Days,
  Value<int?> year,
  Value<String?> lote,
  Value<String?> motherId,
  Value<String?> fatherId,
  Value<String?> registrationNote,
  Value<String> deathDate,
  Value<String?> causeOfDeath,
  Value<String?> deathNotes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DeceasedAnimalsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $DeceasedAnimalsTable> {
  $$DeceasedAnimalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalAnimalId => $composableBuilder(
      column: $table.originalAnimalId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameColor => $composableBuilder(
      column: $table.nameColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get motherId => $composableBuilder(
      column: $table.motherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fatherId => $composableBuilder(
      column: $table.fatherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deathDate => $composableBuilder(
      column: $table.deathDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get causeOfDeath => $composableBuilder(
      column: $table.causeOfDeath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deathNotes => $composableBuilder(
      column: $table.deathNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DeceasedAnimalsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $DeceasedAnimalsTable> {
  $$DeceasedAnimalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalAnimalId => $composableBuilder(
      column: $table.originalAnimalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameColor => $composableBuilder(
      column: $table.nameColor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lote => $composableBuilder(
      column: $table.lote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get motherId => $composableBuilder(
      column: $table.motherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fatherId => $composableBuilder(
      column: $table.fatherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deathDate => $composableBuilder(
      column: $table.deathDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get causeOfDeath => $composableBuilder(
      column: $table.causeOfDeath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deathNotes => $composableBuilder(
      column: $table.deathNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DeceasedAnimalsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $DeceasedAnimalsTable> {
  $$DeceasedAnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get originalAnimalId => $composableBuilder(
      column: $table.originalAnimalId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get reproductiveStatus => $composableBuilder(
      column: $table.reproductiveStatus, builder: (column) => column);

  GeneratedColumn<String> get nameColor =>
      $composableBuilder(column: $table.nameColor, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get birthWeight => $composableBuilder(
      column: $table.birthWeight, builder: (column) => column);

  GeneratedColumn<double> get weight30Days => $composableBuilder(
      column: $table.weight30Days, builder: (column) => column);

  GeneratedColumn<double> get weight60Days => $composableBuilder(
      column: $table.weight60Days, builder: (column) => column);

  GeneratedColumn<double> get weight90Days => $composableBuilder(
      column: $table.weight90Days, builder: (column) => column);

  GeneratedColumn<double> get weight120Days => $composableBuilder(
      column: $table.weight120Days, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get lote =>
      $composableBuilder(column: $table.lote, builder: (column) => column);

  GeneratedColumn<String> get motherId =>
      $composableBuilder(column: $table.motherId, builder: (column) => column);

  GeneratedColumn<String> get fatherId =>
      $composableBuilder(column: $table.fatherId, builder: (column) => column);

  GeneratedColumn<String> get registrationNote => $composableBuilder(
      column: $table.registrationNote, builder: (column) => column);

  GeneratedColumn<String> get deathDate =>
      $composableBuilder(column: $table.deathDate, builder: (column) => column);

  GeneratedColumn<String> get causeOfDeath => $composableBuilder(
      column: $table.causeOfDeath, builder: (column) => column);

  GeneratedColumn<String> get deathNotes => $composableBuilder(
      column: $table.deathNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DeceasedAnimalsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $DeceasedAnimalsTable,
    DeceasedAnimalRow,
    $$DeceasedAnimalsTableFilterComposer,
    $$DeceasedAnimalsTableOrderingComposer,
    $$DeceasedAnimalsTableAnnotationComposer,
    $$DeceasedAnimalsTableCreateCompanionBuilder,
    $$DeceasedAnimalsTableUpdateCompanionBuilder,
    (
      DeceasedAnimalRow,
      BaseReferences<_$AppDriftDatabase, $DeceasedAnimalsTable,
          DeceasedAnimalRow>
    ),
    DeceasedAnimalRow,
    PrefetchHooks Function()> {
  $$DeceasedAnimalsTableTableManager(
      _$AppDriftDatabase db, $DeceasedAnimalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeceasedAnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeceasedAnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeceasedAnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> originalAnimalId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<String> breed = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String> birthDate = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<String> reproductiveStatus = const Value.absent(),
            Value<String?> nameColor = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<double?> birthWeight = const Value.absent(),
            Value<double?> weight30Days = const Value.absent(),
            Value<double?> weight60Days = const Value.absent(),
            Value<double?> weight90Days = const Value.absent(),
            Value<double?> weight120Days = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> lote = const Value.absent(),
            Value<String?> motherId = const Value.absent(),
            Value<String?> fatherId = const Value.absent(),
            Value<String?> registrationNote = const Value.absent(),
            Value<String> deathDate = const Value.absent(),
            Value<String?> causeOfDeath = const Value.absent(),
            Value<String?> deathNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeceasedAnimalsCompanion(
            id: id,
            farmId: farmId,
            originalAnimalId: originalAnimalId,
            code: code,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            weight: weight,
            location: location,
            reproductiveStatus: reproductiveStatus,
            nameColor: nameColor,
            category: category,
            birthWeight: birthWeight,
            weight30Days: weight30Days,
            weight60Days: weight60Days,
            weight90Days: weight90Days,
            weight120Days: weight120Days,
            year: year,
            lote: lote,
            motherId: motherId,
            fatherId: fatherId,
            registrationNote: registrationNote,
            deathDate: deathDate,
            causeOfDeath: causeOfDeath,
            deathNotes: deathNotes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String originalAnimalId,
            required String code,
            required String name,
            required String species,
            required String breed,
            required String gender,
            required String birthDate,
            required double weight,
            required String location,
            Value<String> reproductiveStatus = const Value.absent(),
            Value<String?> nameColor = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<double?> birthWeight = const Value.absent(),
            Value<double?> weight30Days = const Value.absent(),
            Value<double?> weight60Days = const Value.absent(),
            Value<double?> weight90Days = const Value.absent(),
            Value<double?> weight120Days = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<String?> lote = const Value.absent(),
            Value<String?> motherId = const Value.absent(),
            Value<String?> fatherId = const Value.absent(),
            Value<String?> registrationNote = const Value.absent(),
            required String deathDate,
            Value<String?> causeOfDeath = const Value.absent(),
            Value<String?> deathNotes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeceasedAnimalsCompanion.insert(
            id: id,
            farmId: farmId,
            originalAnimalId: originalAnimalId,
            code: code,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            weight: weight,
            location: location,
            reproductiveStatus: reproductiveStatus,
            nameColor: nameColor,
            category: category,
            birthWeight: birthWeight,
            weight30Days: weight30Days,
            weight60Days: weight60Days,
            weight90Days: weight90Days,
            weight120Days: weight120Days,
            year: year,
            lote: lote,
            motherId: motherId,
            fatherId: fatherId,
            registrationNote: registrationNote,
            deathDate: deathDate,
            causeOfDeath: causeOfDeath,
            deathNotes: deathNotes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeceasedAnimalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $DeceasedAnimalsTable,
    DeceasedAnimalRow,
    $$DeceasedAnimalsTableFilterComposer,
    $$DeceasedAnimalsTableOrderingComposer,
    $$DeceasedAnimalsTableAnnotationComposer,
    $$DeceasedAnimalsTableCreateCompanionBuilder,
    $$DeceasedAnimalsTableUpdateCompanionBuilder,
    (
      DeceasedAnimalRow,
      BaseReferences<_$AppDriftDatabase, $DeceasedAnimalsTable,
          DeceasedAnimalRow>
    ),
    DeceasedAnimalRow,
    PrefetchHooks Function()>;
typedef $$WeightAlertsTableCreateCompanionBuilder = WeightAlertsCompanion
    Function({
  required String id,
  Value<String?> farmId,
  required String animalId,
  required String alertType,
  required String dueDate,
  Value<bool> completed,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$WeightAlertsTableUpdateCompanionBuilder = WeightAlertsCompanion
    Function({
  Value<String> id,
  Value<String?> farmId,
  Value<String> animalId,
  Value<String> alertType,
  Value<String> dueDate,
  Value<bool> completed,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$WeightAlertsTableReferences extends BaseReferences<
    _$AppDriftDatabase, $WeightAlertsTable, WeightAlertRow> {
  $$WeightAlertsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AnimalsTable _animalIdTable(_$AppDriftDatabase db) =>
      db.animals.createAlias(
          $_aliasNameGenerator(db.weightAlerts.animalId, db.animals.id));

  $$AnimalsTableProcessedTableManager get animalId {
    final $_column = $_itemColumn<String>('animal_id')!;

    final manager = $$AnimalsTableTableManager($_db, $_db.animals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_animalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WeightAlertsTableFilterComposer
    extends Composer<_$AppDriftDatabase, $WeightAlertsTable> {
  $$WeightAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get alertType => $composableBuilder(
      column: $table.alertType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AnimalsTableFilterComposer get animalId {
    final $$AnimalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableFilterComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WeightAlertsTableOrderingComposer
    extends Composer<_$AppDriftDatabase, $WeightAlertsTable> {
  $$WeightAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmId => $composableBuilder(
      column: $table.farmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alertType => $composableBuilder(
      column: $table.alertType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AnimalsTableOrderingComposer get animalId {
    final $$AnimalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableOrderingComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WeightAlertsTableAnnotationComposer
    extends Composer<_$AppDriftDatabase, $WeightAlertsTable> {
  $$WeightAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get farmId =>
      $composableBuilder(column: $table.farmId, builder: (column) => column);

  GeneratedColumn<String> get alertType =>
      $composableBuilder(column: $table.alertType, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AnimalsTableAnnotationComposer get animalId {
    final $$AnimalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.animalId,
        referencedTable: $db.animals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnimalsTableAnnotationComposer(
              $db: $db,
              $table: $db.animals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WeightAlertsTableTableManager extends RootTableManager<
    _$AppDriftDatabase,
    $WeightAlertsTable,
    WeightAlertRow,
    $$WeightAlertsTableFilterComposer,
    $$WeightAlertsTableOrderingComposer,
    $$WeightAlertsTableAnnotationComposer,
    $$WeightAlertsTableCreateCompanionBuilder,
    $$WeightAlertsTableUpdateCompanionBuilder,
    (WeightAlertRow, $$WeightAlertsTableReferences),
    WeightAlertRow,
    PrefetchHooks Function({bool animalId})> {
  $$WeightAlertsTableTableManager(
      _$AppDriftDatabase db, $WeightAlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> farmId = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> alertType = const Value.absent(),
            Value<String> dueDate = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeightAlertsCompanion(
            id: id,
            farmId: farmId,
            animalId: animalId,
            alertType: alertType,
            dueDate: dueDate,
            completed: completed,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> farmId = const Value.absent(),
            required String animalId,
            required String alertType,
            required String dueDate,
            Value<bool> completed = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeightAlertsCompanion.insert(
            id: id,
            farmId: farmId,
            animalId: animalId,
            alertType: alertType,
            dueDate: dueDate,
            completed: completed,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WeightAlertsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({animalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (animalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.animalId,
                    referencedTable:
                        $$WeightAlertsTableReferences._animalIdTable(db),
                    referencedColumn:
                        $$WeightAlertsTableReferences._animalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WeightAlertsTableProcessedTableManager = ProcessedTableManager<
    _$AppDriftDatabase,
    $WeightAlertsTable,
    WeightAlertRow,
    $$WeightAlertsTableFilterComposer,
    $$WeightAlertsTableOrderingComposer,
    $$WeightAlertsTableAnnotationComposer,
    $$WeightAlertsTableCreateCompanionBuilder,
    $$WeightAlertsTableUpdateCompanionBuilder,
    (WeightAlertRow, $$WeightAlertsTableReferences),
    WeightAlertRow,
    PrefetchHooks Function({bool animalId})>;

class $AppDriftDatabaseManager {
  final _$AppDriftDatabase _db;
  $AppDriftDatabaseManager(this._db);
  $$AnimalsTableTableManager get animals =>
      $$AnimalsTableTableManager(_db, _db.animals);
  $$AnimalWeightsTableTableManager get animalWeights =>
      $$AnimalWeightsTableTableManager(_db, _db.animalWeights);
  $$AnimalLineageTableTableManager get animalLineage =>
      $$AnimalLineageTableTableManager(_db, _db.animalLineage);
  $$AnimalLineageMetaTableTableManager get animalLineageMeta =>
      $$AnimalLineageMetaTableTableManager(_db, _db.animalLineageMeta);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$BreedingRecordsTableTableManager get breedingRecords =>
      $$BreedingRecordsTableTableManager(_db, _db.breedingRecords);
  $$MatrixEvaluationsTableTableManager get matrixEvaluations =>
      $$MatrixEvaluationsTableTableManager(_db, _db.matrixEvaluations);
  $$FinancialAccountsTableTableManager get financialAccounts =>
      $$FinancialAccountsTableTableManager(_db, _db.financialAccounts);
  $$FinancialRecordsTableTableManager get financialRecords =>
      $$FinancialRecordsTableTableManager(_db, _db.financialRecords);
  $$PharmacyStockTableTableManager get pharmacyStock =>
      $$PharmacyStockTableTableManager(_db, _db.pharmacyStock);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$PharmacyStockMovementsTableTableManager get pharmacyStockMovements =>
      $$PharmacyStockMovementsTableTableManager(
          _db, _db.pharmacyStockMovements);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$ReportsTableTableManager get reports =>
      $$ReportsTableTableManager(_db, _db.reports);
  $$PushTokensTableTableManager get pushTokens =>
      $$PushTokensTableTableManager(_db, _db.pushTokens);
  $$FeedingPensTableTableManager get feedingPens =>
      $$FeedingPensTableTableManager(_db, _db.feedingPens);
  $$FeedingSchedulesTableTableManager get feedingSchedules =>
      $$FeedingSchedulesTableTableManager(_db, _db.feedingSchedules);
  $$VaccinationsTableTableManager get vaccinations =>
      $$VaccinationsTableTableManager(_db, _db.vaccinations);
  $$SoldAnimalsTableTableManager get soldAnimals =>
      $$SoldAnimalsTableTableManager(_db, _db.soldAnimals);
  $$DeceasedAnimalsTableTableManager get deceasedAnimals =>
      $$DeceasedAnimalsTableTableManager(_db, _db.deceasedAnimals);
  $$WeightAlertsTableTableManager get weightAlerts =>
      $$WeightAlertsTableTableManager(_db, _db.weightAlerts);
}
