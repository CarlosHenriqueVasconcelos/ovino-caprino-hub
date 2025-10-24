class WeightAlert {
  final String id;
  final String animalId;
  final String alertType; // '30d', '60d', '90d', 'monthly'
  final DateTime dueDate;
  final bool completed;
  final DateTime createdAt;

  WeightAlert({
    required this.id,
    required this.animalId,
    required this.alertType,
    required this.dueDate,
    required this.completed,
    required this.createdAt,
  });

  factory WeightAlert.fromMap(Map<String, dynamic> map) {
    return WeightAlert(
      id: map['id']?.toString() ?? '',
      animalId: map['animal_id']?.toString() ?? '',
      alertType: map['alert_type']?.toString() ?? '',
      dueDate: DateTime.tryParse(map['due_date']?.toString() ?? '') ?? DateTime.now(),
      completed: (map['completed'] == 1 || map['completed'] == true),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'alert_type': alertType,
      'due_date': dueDate.toIso8601String().split('T').first,
      'completed': completed ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get typeLabel {
    switch (alertType) {
      case '30d':
        return 'Pesagem 30 dias';
      case '60d':
        return 'Pesagem 60 dias';
      case '90d':
        return 'Pesagem 90 dias';
      case 'monthly':
        return 'Pesagem mensal';
      default:
        return 'Pesagem';
    }
  }
}
