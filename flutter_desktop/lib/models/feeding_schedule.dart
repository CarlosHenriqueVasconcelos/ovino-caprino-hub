class FeedingSchedule {
  final String id;
  final String penId;
  final String feedType;
  final double quantity;
  final int timesPerDay;
  final String feedingTimes; // Armazenado como string separada por vírgulas
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedingSchedule({
    required this.id,
    required this.penId,
    required this.feedType,
    required this.quantity,
    required this.timesPerDay,
    required this.feedingTimes,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedingSchedule.fromMap(Map<String, dynamic> map) {
    return FeedingSchedule(
      id: map['id'] as String,
      penId: map['pen_id'] as String,
      feedType: map['feed_type'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      timesPerDay: map['times_per_day'] as int,
      feedingTimes: map['feeding_times'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pen_id': penId,
      'feed_type': feedType,
      'quantity': quantity,
      'times_per_day': timesPerDay,
      'feeding_times': feedingTimes,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  List<String> get feedingTimesList {
    return feedingTimes.split(',').map((e) => e.trim()).toList();
  }
}
