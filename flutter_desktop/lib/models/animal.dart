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
  });

  /// Construtor compatível com Supabase (fromMap)
  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id']?.toString() ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      nameColor: map['name_color'] ?? 'blue',
      category: map['category'] ?? 'Não especificado',
      species: map['species'] ?? '',
      breed: map['breed'] ?? '',
      gender: map['gender'] ?? '',
      birthDate: map['birth_date'] != null
          ? DateTime.tryParse(map['birth_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      weight: (map['weight'] is num) ? (map['weight'] as num).toDouble() : 0.0,
      status: map['status'] ?? 'Ativo',
      location: map['location'] ?? '',
      lastVaccination: map['last_vaccination'] != null
          ? DateTime.tryParse(map['last_vaccination'].toString())
          : null,
      pregnant: map['pregnant'] == true,
      expectedDelivery: map['expected_delivery'] != null
          ? DateTime.tryParse(map['expected_delivery'].toString())
          : null,
      healthIssue: map['health_issue'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Construtor original fromJson (mantém compatibilidade)
  factory Animal.fromJson(Map<String, dynamic> json) => Animal.fromMap(json);

  /// Exporta para Map (compatível com Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'name_color': nameColor,
      'category': category,
      'species': species,
      'breed': breed,
      'gender': gender,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'weight': weight,
      'status': status,
      'location': location,
      'last_vaccination': lastVaccination?.toIso8601String().split('T')[0],
      'pregnant': pregnant,
      'expected_delivery': expectedDelivery?.toIso8601String().split('T')[0],
      'health_issue': healthIssue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
      return remainingMonths > 0
          ? '${years}a ${remainingMonths}m'
          : '$years anos';
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
    return AnimalStats(
      totalAnimals: map['totalAnimals'] ?? 0,
      healthy: map['healthy'] ?? 0,
      pregnant: map['pregnant'] ?? 0,
      revenue: (map['revenue'] as num?)?.toDouble() ?? 0.0,
      underTreatment: map['underTreatment'] ?? 0,
      vaccinesThisMonth: map['vaccinesThisMonth'] ?? 0,
      birthsThisMonth: map['birthsThisMonth'] ?? 0,
      avgWeight: (map['avgWeight'] as num?)?.toDouble() ?? 0.0,
      maleReproducers: map['maleReproducers'] ?? 0,
      maleLambs: map['maleLambs'] ?? 0,
      femaleLambs: map['femaleLambs'] ?? 0,
      femaleReproducers: map['femaleReproducers'] ?? 0,
    );
  }
}
