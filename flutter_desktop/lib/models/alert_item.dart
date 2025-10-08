import 'package:flutter/material.dart';

enum AlertType { vaccination, medication }

class AlertItem {
  final String id;
  final String animalId;
  final String animalName;
  final String animalCode;
  final AlertType type;   // vaccination | medication
  final String title;     // ex: 'Vacina: Raiva', 'Medicação: Vermífugo'
  final DateTime dueDate;

  AlertItem({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.animalCode,
    required this.type,
    required this.title,
    required this.dueDate,
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now());
  IconData get icon => type == AlertType.vaccination ? Icons.vaccines : Icons.medication;
  String get kindLabel => type == AlertType.vaccination ? 'Vacina' : 'Medicação';
}
