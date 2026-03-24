import 'dart:math';

import '../data/local_db.dart';
import 'diagnostic_runner.dart';

class SeedFactory {
  static Future<void> seedSmall({
    required AppDatabase db,
    required DiagnosticLog log,
  }) async {
    await _seed(db: db, log: log, count: 24, stress: false);
  }

  static Future<void> seedStress({
    required AppDatabase db,
    required DiagnosticLog log,
  }) async {
    await _seed(db: db, log: log, count: 300, stress: true);
  }

  static Future<void> _seed({
    required AppDatabase db,
    required DiagnosticLog log,
    required int count,
    required bool stress,
  }) async {
    final rng = Random(42);
    final now = DateTime.now();
    final animals = <Map<String, dynamic>>[];

    final baseNames = <String>[
      'Luna',
      'Brisa',
      'Sol',
      'Duna',
      'Nina',
      'Bela',
      'Zeca',
      'Tico',
      'Rita',
      'Roxo',
      'Azulão',
      'Caramelo',
      'Mel',
      'Pingo',
      'Pérola',
      'Estrela',
    ];

    final colors = <String>[
      'azul',
      'vermelho',
      'verde',
      'amarelo',
      'preto',
      'branco',
      'cinza',
      'laranja',
    ];

    final categories = <String>[
      'Matriz',
      'Reprodutor',
      'Borrego',
      'Lactante',
      'Engorda',
    ];

    void addAnimal({
      required String id,
      required String code,
      required String name,
      required String species,
      required String gender,
      required DateTime birthDate,
      required double weight,
      String status = 'Saudável',
      String? nameColor,
      String? category,
      String? motherId,
      String? fatherId,
      bool pregnant = false,
      DateTime? expectedDelivery,
      String? healthIssue,
      int? year,
      String? lote,
    }) {
      animals.add({
        'id': id,
        'code': code,
        'name': name,
        'species': species,
        'breed': species == 'Ovino' ? 'Santa Ines' : 'Boer',
        'gender': gender,
        'birth_date': _dateOnly(birthDate),
        'weight': weight,
        'status': status,
        'location': 'Pasto ${rng.nextInt(4) + 1}',
        'name_color': nameColor,
        'category': category,
        'last_vaccination': _dateOnly(now.subtract(Duration(days: rng.nextInt(200)))),
        'pregnant': pregnant ? 1 : 0,
        'expected_delivery': expectedDelivery == null ? null : _dateOnly(expectedDelivery),
        'health_issue': healthIssue,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'year': year ?? birthDate.year,
        'lote': lote,
        'mother_id': motherId,
        'father_id': fatherId,
      });
    }

    addAnimal(
      id: 'seed_m1',
      code: 'M001',
      name: 'Mãe Base',
      species: 'Ovino',
      gender: 'Fêmea',
      birthDate: now.subtract(const Duration(days: 1500)),
      weight: 65,
      category: 'Matriz',
      nameColor: 'azul',
    );
    addAnimal(
      id: 'seed_f1',
      code: 'P001',
      name: 'Pai Base',
      species: 'Ovino',
      gender: 'Macho',
      birthDate: now.subtract(const Duration(days: 1800)),
      weight: 75,
      category: 'Reprodutor',
      nameColor: 'preto',
    );

    for (var i = 0; i < count; i++) {
      final id = 'seed_$i';
      final nameBase = baseNames[i % baseNames.length];
      final longName = i == 2
          ? 'Maria 🌟 Nome Muito Muito Longo Para Teste de Layout'
          : nameBase;
      final species = i % 3 == 0 ? 'Caprino' : 'Ovino';
      final gender = i % 2 == 0 ? 'Fêmea' : 'Macho';
      final birthDate = now.subtract(Duration(days: 200 + rng.nextInt(2000)));
      final weight = i == 5 ? 0 : (i == 7 ? 1200 : 20 + rng.nextInt(60));
      final category = i == 6 ? '' : (i == 8 ? null : categories[i % categories.length]);
      final nameColor = colors[i % colors.length];
      final motherId = i % 5 == 0 ? 'seed_m1' : (i == 9 ? 'missing_parent' : null);
      final fatherId = i % 6 == 0 ? 'seed_f1' : null;
      final pregnant = gender == 'Fêmea' && i % 7 == 0;
      final expectedDelivery = pregnant ? now.add(const Duration(days: 60)) : null;
      final healthIssue = i % 11 == 0 ? 'Problema respiratório' : null;
      final lote = i % 4 == 0 ? 'L${i % 3 + 1}' : null;

      addAnimal(
        id: id,
        code: 'C${i.toString().padLeft(3, '0')}',
        name: longName,
        species: species,
        gender: gender,
        birthDate: birthDate,
        weight: weight.toDouble(),
        category: category,
        nameColor: nameColor,
        motherId: motherId,
        fatherId: fatherId,
        pregnant: pregnant,
        expectedDelivery: expectedDelivery,
        healthIssue: healthIssue,
        lote: lote,
      );
    }

    final weights = <Map<String, dynamic>>[];
    final vaccinations = <Map<String, dynamic>>[];
    final medications = <Map<String, dynamic>>[];
    final notes = <Map<String, dynamic>>[];
    final pharmacyStock = <Map<String, dynamic>>[];
    final stockMovements = <Map<String, dynamic>>[];

    pharmacyStock.add({
      'id': 'stock_1',
      'medication_name': 'Vermífugo A',
      'medication_type': 'Oral',
      'unit_of_measure': 'ml',
      'quantity_per_unit': 100.0,
      'total_quantity': 1000.0,
      'min_stock_alert': 200.0,
      'expiration_date': _dateOnly(now.add(const Duration(days: 365))),
      'is_opened': 1,
      'opened_quantity': 250.0,
      'notes': 'Lote inicial',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    for (var i = 0; i < animals.length; i++) {
      final animalId = animals[i]['id'] as String;
      if (i % 4 == 0) {
        weights.add({
          'id': 'wt_${animalId}_1',
          'animal_id': animalId,
          'date': _dateOnly(now.subtract(const Duration(days: 30))),
          'weight': 25 + rng.nextInt(40),
          'milestone': i % 8 == 0 ? '30d' : null,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
        weights.add({
          'id': 'wt_${animalId}_2',
          'animal_id': animalId,
          'date': _dateOnly(now.subtract(const Duration(days: 5))),
          'weight': 30 + rng.nextInt(40),
          'milestone': null,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }

      if (i % 6 == 0) {
        vaccinations.add({
          'id': 'vac_${animalId}_1',
          'animal_id': animalId,
          'vaccine_name': 'Clostridiose',
          'vaccine_type': 'Reforço',
          'scheduled_date': _dateOnly(now.add(const Duration(days: 10))),
          'applied_date': null,
          'veterinarian': 'Dr. Silva',
          'notes': 'Dose única',
          'status': 'Agendada',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }

      if (i % 7 == 0) {
        final medId = 'med_${animalId}_1';
        medications.add({
          'id': medId,
          'animal_id': animalId,
          'medication_name': 'Antibiótico X',
          'date': _dateOnly(now.subtract(const Duration(days: 2))),
          'next_date': _dateOnly(now.add(const Duration(days: 15))),
          'dosage': '10ml',
          'veterinarian': 'Dra. Ana',
          'notes': 'Aplicação preventiva',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'status': 'Agendado',
          'applied_date': null,
          'pharmacy_stock_id': 'stock_1',
          'quantity_used': 10.0,
        });
        stockMovements.add({
          'id': 'mov_${animalId}_1',
          'pharmacy_stock_id': 'stock_1',
          'medication_id': medId,
          'movement_type': 'saida',
          'quantity': 10.0,
          'reason': 'Aplicação preventiva',
          'created_at': now.toIso8601String(),
        });
      }

      if (i % 5 == 0) {
        notes.add({
          'id': 'note_${animalId}_1',
          'animal_id': animalId,
          'title': 'Observação ${i + 1}',
          'content': 'Nota de teste para animal ${animals[i]['name']}',
          'category': 'Geral',
          'priority': 'Média',
          'date': _dateOnly(now.subtract(Duration(days: rng.nextInt(60)))),
          'created_by': 'diagnostic',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'is_read': i % 2 == 0 ? 1 : 0,
        });
      }
    }

    await db.db.transaction((txn) async {
      final batch = txn.batch();
      for (final row in animals) {
        batch.insert('animals', row);
      }
      for (final row in pharmacyStock) {
        batch.insert('pharmacy_stock', row);
      }
      for (final row in weights) {
        batch.insert('animal_weights', row);
      }
      for (final row in vaccinations) {
        batch.insert('vaccinations', row);
      }
      for (final row in medications) {
        batch.insert('medications', row);
      }
      for (final row in stockMovements) {
        batch.insert('pharmacy_stock_movements', row);
      }
      for (final row in notes) {
        batch.insert('notes', row);
      }
      await batch.commit(noResult: true);
    });

    log.info(
      'Seed complete: animals=${animals.length} weights=${weights.length} '
      'vaccinations=${vaccinations.length} medications=${medications.length}',
    );

    if (!stress) {
      log.info('Seeded small dataset with edge cases and relations.');
    }
  }

  static String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;
}
