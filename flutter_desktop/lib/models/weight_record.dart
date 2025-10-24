class WeightRecord {
  final String id;
  final String animalId;
  final DateTime date;
  final double weight;
  final String? milestone; // 'birth', '30d', '60d', '90d', 'monthly_1' a 'monthly_5', 'manual'
  final DateTime createdAt;

  WeightRecord({
    required this.id,
    required this.animalId,
    required this.date,
    required this.weight,
    this.milestone,
    required this.createdAt,
  });

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id']?.toString() ?? '',
      animalId: map['animal_id']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      weight: (map['weight'] is num) ? (map['weight'] as num).toDouble() : 0.0,
      milestone: map['milestone']?.toString(),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'date': date.toIso8601String().split('T').first,
      'weight': weight,
      'milestone': milestone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get milestoneLabel {
    if (milestone == null) return 'Manual';
    switch (milestone) {
      case 'birth':
        return 'Nascimento';
      case '30d':
        return '30 dias';
      case '60d':
        return '60 dias';
      case '90d':
        return '90 dias';
      case 'monthly_1':
        return 'Mês 1';
      case 'monthly_2':
        return 'Mês 2';
      case 'monthly_3':
        return 'Mês 3';
      case 'monthly_4':
        return 'Mês 4';
      case 'monthly_5':
        return 'Mês 5';
      default:
        return milestone ?? 'Manual';
    }
  }
}
