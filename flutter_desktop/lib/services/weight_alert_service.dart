import 'package:flutter/foundation.dart';
import '../data/local_db.dart';
import '../models/animal.dart';
import '../models/weight_alert.dart';

class WeightAlertService {
  final AppDatabase db;

  WeightAlertService(this.db);

  /// Cria alertas de pesagem para borregos (30, 60, 90 dias após nascimento)
  Future<void> createLambWeightAlerts(Animal animal) async {
    if (!animal.category.toLowerCase().contains('borrego')) return;

    final birthDate = animal.birthDate;
    final animalId = animal.id;

    // Remove alertas antigos do animal
    await db.db.delete('weight_alerts', where: 'animal_id = ?', whereArgs: [animalId]);

    // Cria alertas para 30, 60 e 90 dias
    final alerts = [
      WeightAlert(
        id: 'wa_${animalId}_30d',
        animalId: animalId,
        alertType: '30d',
        dueDate: birthDate.add(const Duration(days: 30)),
        completed: false,
        createdAt: DateTime.now(),
      ),
      WeightAlert(
        id: 'wa_${animalId}_60d',
        animalId: animalId,
        alertType: '60d',
        dueDate: birthDate.add(const Duration(days: 60)),
        completed: false,
        createdAt: DateTime.now(),
      ),
      WeightAlert(
        id: 'wa_${animalId}_90d',
        animalId: animalId,
        alertType: '90d',
        dueDate: birthDate.add(const Duration(days: 90)),
        completed: false,
        createdAt: DateTime.now(),
      ),
    ];

    for (final alert in alerts) {
      await db.db.insert('weight_alerts', alert.toMap());
    }

    debugPrint('Criados alertas de pesagem para borrego ${animal.name}');
  }

  /// Cria próximo alerta mensal para animais adultos
  Future<void> createNextMonthlyAlert(String animalId) async {
    // Verifica quantos alertas mensais já existem
    final existing = await db.db.query(
      'weight_alerts',
      where: "animal_id = ? AND alert_type = 'monthly'",
      whereArgs: [animalId],
    );

    if (existing.length >= 5) {
      debugPrint('Limite de 5 alertas mensais atingido para $animalId');
      return;
    }

    // Cria próximo alerta mensal (30 dias a partir de hoje)
    final nextAlert = WeightAlert(
      id: 'wa_${animalId}_monthly_${existing.length + 1}',
      animalId: animalId,
      alertType: 'monthly',
      dueDate: DateTime.now().add(const Duration(days: 30)),
      completed: false,
      createdAt: DateTime.now(),
    );

    await db.db.insert('weight_alerts', nextAlert.toMap());
    debugPrint('Criado alerta mensal para $animalId');
  }

  /// Marca alerta como completo
  Future<void> completeAlert(String alertId) async {
    await db.db.update(
      'weight_alerts',
      {'completed': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  /// Busca alertas pendentes (não completados e dentro do horizonte)
  Future<List<WeightAlert>> getPendingAlerts({int horizonDays = 30}) async {
    final horizon = DateTime.now().add(Duration(days: horizonDays));
    final rows = await db.db.query(
      'weight_alerts',
      where: 'completed = 0 AND date(due_date) <= date(?)',
      whereArgs: [horizon.toIso8601String().split('T').first],
      orderBy: 'due_date ASC',
    );

    return rows.map((row) => WeightAlert.fromMap(row)).toList();
  }

  /// Busca alertas de um animal específico
  Future<List<WeightAlert>> getAnimalAlerts(String animalId) async {
    final rows = await db.db.query(
      'weight_alerts',
      where: 'animal_id = ?',
      whereArgs: [animalId],
      orderBy: 'due_date ASC',
    );

    return rows.map((row) => WeightAlert.fromMap(row)).toList();
  }

  /// Remove todos os alertas de um animal
  Future<void> deleteAnimalAlerts(String animalId) async {
    await db.db.delete('weight_alerts', where: 'animal_id = ?', whereArgs: [animalId]);
  }
}
