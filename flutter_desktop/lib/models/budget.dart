class Budget {
  final String id;
  final String category;
  final double amount;
  final String period;
  final int year;
  final int? month;
  final String? costCenterId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.period,
    required this.year,
    this.month,
    this.costCenterId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'period': period,
      'year': year,
      'month': month,
      'cost_center_id': costCenterId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      period: map['period'] ?? 'Mensal',
      year: map['year'] ?? DateTime.now().year,
      month: map['month'],
      costCenterId: map['cost_center_id'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    String? period,
    int? year,
    int? month,
    String? costCenterId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      year: year ?? this.year,
      month: month ?? this.month,
      costCenterId: costCenterId ?? this.costCenterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
