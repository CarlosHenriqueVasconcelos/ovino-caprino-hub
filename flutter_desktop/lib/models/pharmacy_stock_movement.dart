class PharmacyStockMovement {
  final String id;
  final String pharmacyStockId;
  final String? medicationId;
  final String movementType;
  final double quantity;
  final String? reason;
  final DateTime createdAt;

  PharmacyStockMovement({
    required this.id,
    required this.pharmacyStockId,
    this.medicationId,
    required this.movementType,
    required this.quantity,
    this.reason,
    required this.createdAt,
  });

  factory PharmacyStockMovement.fromMap(Map<String, dynamic> map) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
      return 0.0;
    }

    DateTime _toDate(dynamic v, {DateTime? fallback}) {
      if (v == null) return fallback ?? DateTime.now();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? (fallback ?? DateTime.now());
    }

    return PharmacyStockMovement(
      id: map['id']?.toString() ?? '',
      pharmacyStockId: map['pharmacy_stock_id'] ?? map['pharmacyStockId'] ?? '',
      medicationId:
          map['medication_id']?.toString() ?? map['medicationId']?.toString(),
      movementType: map['movement_type'] ?? map['movementType'] ?? '',
      quantity: _toDouble(map['quantity']),
      reason: map['reason']?.toString(),
      createdAt: _toDate(map['created_at'] ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'pharmacy_stock_id': pharmacyStockId,
      'movement_type': movementType,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };

    if (medicationId != null) {
      map['medication_id'] = medicationId;
    }
    if (reason != null && reason!.isNotEmpty) {
      map['reason'] = reason;
    }

    return map;
  }
}
