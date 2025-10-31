// flutter_desktop/lib/models/animal.dart

class Animal {
  final String id;
  final String code;
  final String name;
  final String nameColor;
  final String category;
  final String species;
  final String breed;
  final String gender;
  final DateTime birthDate;
  final double weight;
  final String status;
  final String location;
  final DateTime? lastVaccination;
  final bool pregnant;
  final DateTime? expectedDelivery;
  final String? healthIssue;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Marcos de peso (opcionais)
  final double? birthWeight;
  final double? weight30Days;
  final double? weight60Days;
  final double? weight90Days;
  final double? weight120Days;

  // Novos campos
  final int? year;
  final String? lote;
  final String? motherId;
  final String? fatherId;

  Animal({
    required this.id,
    required this.code,
    required this.name,
    required this.nameColor,
    required this.category,
    required this.species,
    required this.breed,
    required this.gender,
    required this.birthDate,
    required this.weight,
    required this.status,
    required this.location,
    this.lastVaccination,
    this.pregnant = false,
    this.expectedDelivery,
    this.healthIssue,
    required this.createdAt,
    required this.updatedAt,
    this.birthWeight,
    this.weight30Days,
    this.weight60Days,
    this.weight90Days,
    this.weight120Days,
    this.year,
    this.lote,
    this.motherId,
    this.fatherId,
  });

  factory Animal.fromMap(Map<String, dynamic> map) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.'));
      return null;
    }

    DateTime _toDate(dynamic v, {DateTime? fallback}) {
      if (v == null) return fallback ?? DateTime.now();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? (fallback ?? DateTime.now());
    }

    DateTime? _toDateOrNull(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    bool _toBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase().trim();
        return s == 'true' || s == '1' || s == 'yes' || s == 'y';
      }
      return false;
    }

    double? _readBirthWeight() =>
        _toDouble(map['birthWeight'] ?? map['birth_weight']);

    double? _read30d() => _toDouble(
          map['weight30Days'] ??
              map['weight_30_days'] ??
              map['weight30'] ??
              map['weight_30d'],
        );

    double? _read60d() => _toDouble(
          map['weight60Days'] ??
              map['weight_60_days'] ??
              map['weight60'] ??
              map['weight_60d'],
        );

    double? _read90d() => _toDouble(
          map['weight90Days'] ??
              map['weight_90_days'] ??
              map['weight90'] ??
              map['weight_90d'],
        );

    double? _read120d() => _toDouble(
          map['weight120Days'] ??
              map['weight_120_days'] ??
              map['weight120'] ??
              map['weight_120d'],
        );

    return Animal(
      id: map['id']?.toString() ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      nameColor: map['name_color'] ?? map['nameColor'] ?? 'blue',
      category: map['category'] ?? 'Não especificado',
      species: map['species'] ?? '',
      breed: map['breed'] ?? '',
      gender: map['gender'] ?? '',
      birthDate: _toDate(map['birth_date'] ?? map['birthDate']),
      weight: (_toDouble(map['weight']) ?? 0.0),
      status: map['status'] ?? 'Saudável',
      location: map['location'] ?? '',
      lastVaccination:
          _toDateOrNull(map['last_vaccination'] ?? map['lastVaccination']),
      pregnant: _toBool(map['pregnant']),
      expectedDelivery:
          _toDateOrNull(map['expected_delivery'] ?? map['expectedDelivery']),
      healthIssue: map['health_issue'] ?? map['healthIssue'],
      createdAt: _toDate(map['created_at'] ?? map['createdAt']),
      updatedAt: _toDate(map['updated_at'] ?? map['updatedAt']),
      birthWeight: _readBirthWeight(),
      weight30Days: _read30d(),
      weight60Days: _read60d(),
      weight90Days: _read90d(),
      weight120Days: _read120d(),
      year: map['year'] is int ? map['year'] : (map['year'] != null ? int.tryParse(map['year'].toString()) : null),
      lote: map['lote']?.toString(),
      motherId: map['mother_id']?.toString() ?? map['motherId']?.toString(),
      fatherId: map['father_id']?.toString() ?? map['fatherId']?.toString(),
    );
  }

  factory Animal.fromJson(Map<String, dynamic> json) => Animal.fromMap(json);

  Map<String, dynamic> toMap() {
    String? _dateOnlyOrNull(DateTime? d) =>
        d == null ? null : d.toIso8601String().split('T')[0];

    // mapa base com obrigatórios e opcionais mais comuns
    final map = <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'name_color': nameColor,
      'category': category,
      'species': species,
      'breed': breed,
      'gender': gender,
      'birth_date': _dateOnlyOrNull(birthDate), // nunca null aqui
      'weight': weight,
      'status': status,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pregnant': pregnant ? 1 : 0, // INTEGER no SQLite
    };

    // adicionar somente se não for null/vazio
    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      map[key] = value;
    }

    put('last_vaccination', _dateOnlyOrNull(lastVaccination));
    put('expected_delivery', _dateOnlyOrNull(expectedDelivery));
    put('health_issue', healthIssue);
    put('birth_weight', birthWeight);
    put('weight_30_days', weight30Days);
    put('weight_60_days', weight60Days);
    put('weight_90_days', weight90Days);
    put('weight_120_days', weight120Days);
    put('year', year);
    put('lote', lote);
    put('mother_id', motherId);
    put('father_id', fatherId);

    return map;
  }

  Map<String, dynamic> toJson() => toMap();

  String get ageText {
    final now = DateTime.now();
    final ageInMonths =
        (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (ageInMonths < 12) {
      return '$ageInMonths meses';
    } else {
      final years = ageInMonths ~/ 12;
      final remainingMonths = ageInMonths % 12;
      return remainingMonths > 0 ? '${years}a ${remainingMonths}m' : '$years anos';
    }
  }

  String get speciesIcon => species == 'Ovino' ? '🐑' : '🐐';
}

class AnimalStats {
  final int totalAnimals;
  final int healthy;
  final int pregnant;
  final int underTreatment;
  final int vaccinesThisMonth;
  final int birthsThisMonth;
  final double avgWeight;
  final double revenue;
  final int maleReproducers;
  final int maleLambs;
  final int femaleLambs;
  final int femaleReproducers;

  AnimalStats({
    required this.totalAnimals,
    required this.healthy,
    required this.pregnant,
    required this.underTreatment,
    required this.vaccinesThisMonth,
    required this.birthsThisMonth,
    required this.avgWeight,
    required this.revenue,
    this.maleReproducers = 0,
    this.maleLambs = 0,
    this.femaleLambs = 0,
    this.femaleReproducers = 0,
  });

  factory AnimalStats.fromMap(Map<String, dynamic> map) {
    double _d(dynamic v) =>
        v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
    int _i(dynamic v) =>
        v == null ? 0 : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0);

    return AnimalStats(
      totalAnimals: _i(map['totalAnimals']),
      healthy: _i(map['healthy']),
      pregnant: _i(map['pregnant']),
      revenue: _d(map['revenue']),
      underTreatment: _i(map['underTreatment']),
      vaccinesThisMonth: _i(map['vaccinesThisMonth']),
      birthsThisMonth: _i(map['birthsThisMonth']),
      avgWeight: _d(map['avgWeight']),
      maleReproducers: _i(map['maleReproducers']),
      maleLambs: _i(map['maleLambs']),
      femaleLambs: _i(map['femaleLambs']),
      femaleReproducers: _i(map['femaleReproducers']),
    );
  }
}

// Facilita atualizações parciais
extension AnimalCopy on Animal {
  Animal copyWith({
    String? id,
    String? code,
    String? name,
    String? nameColor,
    String? category,
    String? species,
    String? breed,
    String? gender,
    DateTime? birthDate,
    double? weight,
    String? status,
    String? location,
    DateTime? lastVaccination,
    bool? pregnant,
    DateTime? expectedDelivery,
    String? healthIssue,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? birthWeight,
    double? weight30Days,
    double? weight60Days,
    double? weight90Days,
    double? weight120Days,
    int? year,
    String? lote,
    String? motherId,
    String? fatherId,
  }) {
    return Animal(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nameColor: nameColor ?? this.nameColor,
      category: category ?? this.category,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      location: location ?? this.location,
      lastVaccination: lastVaccination ?? this.lastVaccination,
      pregnant: pregnant ?? this.pregnant,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      healthIssue: healthIssue ?? this.healthIssue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      birthWeight: birthWeight ?? this.birthWeight,
      weight30Days: weight30Days ?? this.weight30Days,
      weight60Days: weight60Days ?? this.weight60Days,
      weight90Days: weight90Days ?? this.weight90Days,
      weight120Days: weight120Days ?? this.weight120Days,
      year: year ?? this.year,
      lote: lote ?? this.lote,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
    );
  }
}
