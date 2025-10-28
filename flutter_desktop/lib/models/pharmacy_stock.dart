class PharmacyStock {
  final String id;
  final String medicationName;
  final String medicationType;
  final String unitOfMeasure;
  final double? quantityPerUnit;
  final double totalQuantity;
  final double? minStockAlert;
  final DateTime? expirationDate;
  final String? manufacturer;
  final String? batchNumber;
  final double? purchasePrice;
  final bool isOpened;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PharmacyStock({
    required this.id,
    required this.medicationName,
    required this.medicationType,
    required this.unitOfMeasure,
    this.quantityPerUnit,
    required this.totalQuantity,
    this.minStockAlert,
    this.expirationDate,
    this.manufacturer,
    this.batchNumber,
    this.purchasePrice,
    this.isOpened = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PharmacyStock.fromMap(Map<String, dynamic> map) {
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

    return PharmacyStock(
      id: map['id']?.toString() ?? '',
      medicationName: map['medication_name'] ?? map['medicationName'] ?? '',
      medicationType: map['medication_type'] ?? map['medicationType'] ?? '',
      unitOfMeasure: map['unit_of_measure'] ?? map['unitOfMeasure'] ?? '',
      quantityPerUnit: _toDouble(map['quantity_per_unit'] ?? map['quantityPerUnit']),
      totalQuantity: _toDouble(map['total_quantity'] ?? map['totalQuantity']) ?? 0.0,
      minStockAlert: _toDouble(map['min_stock_alert'] ?? map['minStockAlert']),
      expirationDate: _toDateOrNull(map['expiration_date'] ?? map['expirationDate']),
      manufacturer: map['manufacturer']?.toString(),
      batchNumber: map['batch_number'] ?? map['batchNumber'],
      purchasePrice: _toDouble(map['purchase_price'] ?? map['purchasePrice']),
      isOpened: _toBool(map['is_opened'] ?? map['isOpened'] ?? false),
      notes: map['notes']?.toString(),
      createdAt: _toDate(map['created_at'] ?? map['createdAt']),
      updatedAt: _toDate(map['updated_at'] ?? map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    String? _dateOnlyOrNull(DateTime? d) =>
        d == null ? null : d.toIso8601String().split('T')[0];

    final map = <String, dynamic>{
      'id': id,
      'medication_name': medicationName,
      'medication_type': medicationType,
      'unit_of_measure': unitOfMeasure,
      'total_quantity': totalQuantity,
      'is_opened': isOpened ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    void put(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.isEmpty) return;
      map[key] = value;
    }

    put('quantity_per_unit', quantityPerUnit);
    put('min_stock_alert', minStockAlert);
    put('expiration_date', _dateOnlyOrNull(expirationDate));
    put('manufacturer', manufacturer);
    put('batch_number', batchNumber);
    put('purchase_price', purchasePrice);
    put('notes', notes);

    return map;
  }

  PharmacyStock copyWith({
    String? id,
    String? medicationName,
    String? medicationType,
    String? unitOfMeasure,
    double? quantityPerUnit,
    double? totalQuantity,
    double? minStockAlert,
    DateTime? expirationDate,
    String? manufacturer,
    String? batchNumber,
    double? purchasePrice,
    bool? isOpened,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PharmacyStock(
      id: id ?? this.id,
      medicationName: medicationName ?? this.medicationName,
      medicationType: medicationType ?? this.medicationType,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      quantityPerUnit: quantityPerUnit ?? this.quantityPerUnit,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      expirationDate: expirationDate ?? this.expirationDate,
      manufacturer: manufacturer ?? this.manufacturer,
      batchNumber: batchNumber ?? this.batchNumber,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      isOpened: isOpened ?? this.isOpened,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock {
    if (minStockAlert == null) return false;
    return totalQuantity <= minStockAlert!;
  }

  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final daysUntilExpiration = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiration >= 0 && daysUntilExpiration <= 30;
  }

  bool get isExpired {
    if (expirationDate == null) return false;
    return expirationDate!.isBefore(DateTime.now());
  }

  String get statusText {
    if (isExpired) return 'Vencido';
    if (isLowStock) return 'Estoque Baixo';
    if (isExpiringSoon) return 'Vencendo';
    return 'OK';
  }
}
