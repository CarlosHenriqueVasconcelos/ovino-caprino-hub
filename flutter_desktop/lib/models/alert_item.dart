import 'package:flutter/material.dart';

enum AlertType { vaccination, medication, weighing }

class AlertItem {
  final String id;
  final String animalId;
  final String animalName;
  final String animalCode;
  final AlertType type; // vaccination | medication
  final String title; // ex: 'Vacina: Raiva', 'Medicação: Vermífugo'
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

  IconData get icon {
    switch (type) {
      case AlertType.vaccination:
        return Icons.vaccines;
      case AlertType.medication:
        return Icons.medication;
      case AlertType.weighing:
        return Icons.monitor_weight;
    }
  }

  String get kindLabel {
    switch (type) {
      case AlertType.vaccination:
        return 'Vacina';
      case AlertType.medication:
        return 'Medicação';
      case AlertType.weighing:
        return 'Pesagem';
    }
  }
}
