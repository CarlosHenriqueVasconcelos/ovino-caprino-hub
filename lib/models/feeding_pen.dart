class FeedingPen {
  final String id;
  final String name;
  final String? number;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedingPen({
    required this.id,
    required this.name,
    this.number,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedingPen.fromMap(Map<String, dynamic> map) {
    return FeedingPen(
      id: map['id'] as String,
      name: map['name'] as String,
      number: map['number'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
