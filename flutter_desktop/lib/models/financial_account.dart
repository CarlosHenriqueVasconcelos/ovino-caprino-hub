class FinancialAccount {
  final String id;
  final String type; // 'receita' or 'despesa'
  final String category;
  final String? description;
  final double amount;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final String status; // 'Pendente', 'Pago', 'Vencido', 'Cancelado'
  final String? paymentMethod;
  final int? installments;
  final int? installmentNumber;
  final String? parentId;
  final String? animalId;
  final String? supplierCustomer;
  final String? notes;
  final bool isRecurring;
  final String? recurrenceFrequency; // 'Diária','Semanal','Mensal','Anual'
  final DateTime? recurrenceEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialAccount({
    required this.id,
    required this.type,
    required this.category,
    this.description,
    required this.amount,
    required this.dueDate,
    this.paymentDate,
    required this.status,
    this.paymentMethod,
    this.installments,
    this.installmentNumber,
    this.parentId,
    this.animalId,
    this.supplierCustomer,
    this.notes,
    this.isRecurring = false,
    this.recurrenceFrequency,
    this.recurrenceEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'description': description,
      'amount': amount,
      'due_date': _date(dueDate),
      'payment_date': _date(paymentDate),
      'status': status,
      'payment_method': paymentMethod,
      'installments': installments,
      'installment_number': installmentNumber,
      'parent_id': parentId,
      'animal_id': animalId,
      'supplier_customer': supplierCustomer,
      'notes': notes,
      'is_recurring': isRecurring ? 1 : 0, // bool -> INTEGER
      'recurrence_frequency': recurrenceFrequency,
      'recurrence_end_date': _date(recurrenceEndDate),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FinancialAccount.fromMap(Map<String, dynamic> map) {
    String? _str(dynamic v) => v == null ? null : v as String;
    double _toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.parse(v.toString());
    int? _toInt(dynamic v) =>
        v == null ? null : (v is num ? v.toInt() : int.parse(v.toString()));
    bool _toBool(dynamic v) =>
        (v is int ? v == 1 : (v is bool ? v : v.toString() == '1'));

    return FinancialAccount(
      id: map['id'] as String,
      type: map['type'] as String,
      category: map['category'] as String,
      description: _str(map['description']),
      amount: _toDouble(map['amount']),
      dueDate: _parseDate(map['due_date'])!,
      paymentDate: _parseDate(map['payment_date']),
      status: map['status'] as String,
      paymentMethod: _str(map['payment_method']),
      installments: _toInt(map['installments']),
      installmentNumber: _toInt(map['installment_number']),
      parentId: _str(map['parent_id']),
      animalId: _str(map['animal_id']),
      supplierCustomer: _str(map['supplier_customer']),
      notes: _str(map['notes']),
      isRecurring: _toBool(map['is_recurring'] ?? 0),
      recurrenceFrequency: _str(map['recurrence_frequency']),
      recurrenceEndDate: _parseDate(map['recurrence_end_date']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  FinancialAccount copyWith({
    String? id,
    String? type,
    String? category,
    String? description,
    double? amount,
    DateTime? dueDate,
    DateTime? paymentDate,
    String? status,
    String? paymentMethod,
    int? installments,
    int? installmentNumber,
    String? parentId,
    String? animalId,
    String? supplierCustomer,
    String? notes,
    bool? isRecurring,
    String? recurrenceFrequency,
    DateTime? recurrenceEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialAccount(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      installments: installments ?? this.installments,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      parentId: parentId ?? this.parentId,
      animalId: animalId ?? this.animalId,
      supplierCustomer: supplierCustomer ?? this.supplierCustomer,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String? _date(DateTime? d) =>
      d == null ? null : d.toIso8601String().split('T')[0];

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    final s = v is String ? v : v.toString();
    if (s.length == 10 && s[4] == '-' && s[7] == '-') return DateTime.parse(s);
    return DateTime.parse(s);
  }
}
