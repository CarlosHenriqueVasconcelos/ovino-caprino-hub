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
  final String? costCenter;
  final bool isRecurring;
  final String? recurrenceFrequency; // 'Mensal', 'Semanal', 'Anual'
  final DateTime? recurrenceEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialAccount({
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
    this.costCenter,
    this.isRecurring = false,
    this.recurrenceFrequency,
    this.recurrenceEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'description': description,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'payment_date': paymentDate?.toIso8601String().split('T')[0],
      'status': status,
      'payment_method': paymentMethod,
      'installments': installments,
      'installment_number': installmentNumber,
      'parent_id': parentId,
      'animal_id': animalId,
      'supplier_customer': supplierCustomer,
      'notes': notes,
      'cost_center': costCenter,
      'is_recurring': isRecurring ? 1 : 0,
      'recurrence_frequency': recurrenceFrequency,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FinancialAccount.fromMap(Map<String, dynamic> map) {
    return FinancialAccount(
      id: map['id'],
      type: map['type'],
      category: map['category'],
      description: map['description'],
      amount: map['amount'],
      dueDate: DateTime.parse(map['due_date']),
      paymentDate: map['payment_date'] != null ? DateTime.parse(map['payment_date']) : null,
      status: map['status'],
      paymentMethod: map['payment_method'],
      installments: map['installments'],
      installmentNumber: map['installment_number'],
      parentId: map['parent_id'],
      animalId: map['animal_id'],
      supplierCustomer: map['supplier_customer'],
      notes: map['notes'],
      costCenter: map['cost_center'],
      isRecurring: map['is_recurring'] == 1,
      recurrenceFrequency: map['recurrence_frequency'],
      recurrenceEndDate: map['recurrence_end_date'] != null ? DateTime.parse(map['recurrence_end_date']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
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
    String? costCenter,
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
      costCenter: costCenter ?? this.costCenter,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CostCenter {
  final String id;
  final String name;
  final String? description;
  final bool active;
  final DateTime createdAt;

  CostCenter({
    required this.id,
    required this.name,
    this.description,
    this.active = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CostCenter.fromMap(Map<String, dynamic> map) {
    return CostCenter(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      active: map['active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class Budget {
  final String id;
  final String category;
  final String? costCenter;
  final double amount;
  final String period; // 'Mensal', 'Trimestral', 'Anual'
  final int year;
  final int? month;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.category,
    this.costCenter,
    required this.amount,
    required this.period,
    required this.year,
    this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'cost_center': costCenter,
      'amount': amount,
      'period': period,
      'year': year,
      'month': month,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      category: map['category'],
      costCenter: map['cost_center'],
      amount: map['amount'],
      period: map['period'],
      year: map['year'],
      month: map['month'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
