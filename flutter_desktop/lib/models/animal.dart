class Animal {
  final String id;
  final String code;
  final String name;
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

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      gender: json['gender'],
      birthDate: DateTime.parse(json['birth_date']),
      weight: (json['weight'] as num).toDouble(),
      status: json['status'],
      location: json['location'],
      lastVaccination: json['last_vaccination'] != null 
          ? DateTime.parse(json['last_vaccination'])
          : null,
      pregnant: json['pregnant'] ?? false,
      expectedDelivery: json['expected_delivery'] != null 
          ? DateTime.parse(json['expected_delivery'])
          : null,
      healthIssue: json['health_issue'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
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
    };
  }

  String get ageText {
    final now = DateTime.now();
    final ageInMonths = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    
    if (ageInMonths < 12) {
      return '$ageInMonths meses';
    } else {
      final years = ageInMonths ~/ 12;
      final remainingMonths = ageInMonths % 12;
      return remainingMonths > 0 ? '${years}a ${remainingMonths}m' : '$years anos';
    }
  }

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

  AnimalStats({
    required this.totalAnimals,
    required this.healthy,
    required this.pregnant,
    required this.underTreatment,
    required this.vaccinesThisMonth,
    required this.birthsThisMonth,
    required this.avgWeight,
    required this.revenue,
  });
}