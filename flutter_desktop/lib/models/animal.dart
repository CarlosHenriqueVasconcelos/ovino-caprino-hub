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

  // === NOVOS CAMPOS (opcionais) ===
  final double? birthWeight;
  final double? weight30Days;
  final double? weight60Days;
  final double? weight90Days;

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

    // novos parâmetros nomeados (mantêm compatibilidade com quem chama birthWeight:)
    this.birthWeight,
    this.weight30Days,
    this.weight60Days,
    this.weight90Days,
  });

  /// Construtor compatível com Supabase (fromMap)
  factory Animal.fromMap(Map<String, dynamic> map) {
    // Helpers de conversão robustos
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        // aceita "12,3" e "12.3"
        return double.tryParse(v.replaceAll(',', '.'));
      }
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

    // Tenta ler as chaves nas duas convenções
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
      status: map['status'] ?? 'Ativo',
      location: map['location'] ?? '',
      lastVaccination:
          _toDateOrNull(map['last_vaccination'] ?? map['lastVaccination']),
      pregnant: _toBool(map['pregnant']),
      expectedDelivery:
          _toDateOrNull(map['expected_delivery'] ?? map['expectedDelivery']),
      healthIssue: map['health_issue'] ?? map['healthIssue'],
      createdAt: _toDate(map['created_at'] ?? map['createdAt']),
      updatedAt: _toDate(map['updated_at'] ?? map['updatedAt']),

      // Novos campos lidos do mapa
      birthWeight: _readBirthWeight(),
      weight30Days: _read30d(),
      weight60Days: _read60d(),
      weight90Days: _read90d(),
    );
  }

  /// Construtor original fromJson (mantém compatibilidade)
  factory Animal.fromJson(Map<String, dynamic> json) => Animal.fromMap(json);

  /// Exporta para Map (compatível com Supabase)
  Map<String, dynamic> toMap() {
    String _dateOnly(DateTime? d) =>
        d == null ? '' : d.toIso8601String().split('T')[0];

    return {
      'id': id,
      'code': code,
      'name': name,
      'name_color': nameColor,
      'category': category,
      'species': species,
      'breed': breed,
      'gender': gender,
      'birth_date': _dateOnly(birthDate),
      'weight': weight,
      'status': status,
      'location': location,
      'last_vaccination': _dateOnly(lastVaccination),
      'pregnant': pregnant,
      'expected_delivery': _dateOnly(expectedDelivery),
      'health_issue': healthIssue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      // Novos campos em snake_case (padrão Supabase)
      'birth_weight': birthWeight,
      'weight_30_days': weight30Days,
      'weight_60_days': weight60Days,
      'weight_90_days': weight90Days,
    };
  }

  /// Alias para manter compatibilidade
  Map<String, dynamic> toJson() => toMap();

  /// Texto de idade formatado
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

  /// Emoji para espécie
  String get speciesIcon {
    return species == 'Ovino' ? '🐑' : '🐐';
  }
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

  /// Criação a partir de Map (usado pelo SupabaseService)
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
