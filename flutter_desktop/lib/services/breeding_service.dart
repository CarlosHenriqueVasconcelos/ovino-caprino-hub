import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/breeding_record.dart';
import '../models/animal.dart';

class BreedingEvent {
  final String label;     // ex: "Ultrassom", "Parto previsto"
  final DateTime date;
  final String stage;     // estágio salvo no DB (snake_case)
  final String femaleCode;
  final String femaleName;
  final bool overdue;

  BreedingEvent({
    required this.label,
    required this.date,
    required this.stage,
    required this.femaleCode,
    required this.femaleName,
    required this.overdue,
  });
}

class BreedingService {
  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString();
    // dd/MM/yyyy
    if (s.contains('/')) {
      final p = s.split('/');
      if (p.length == 3) {
        final d = int.tryParse(p[0]);
        final m = int.tryParse(p[1]);
        final y = int.tryParse(p[2]);
        if (d != null && m != null && y != null) {
          return DateTime(y, m, d);
        }
      }
    }
    return DateTime.tryParse(s);
  }

  /// Eventos dos próximos [days] dias (e atrasados).
  static Future<List<BreedingEvent>> getUpcomingEvents(int days) async {
    final records = await DatabaseService.getBreedingRecords();
    final animals = await DatabaseService.getAnimals();
    final animalMap = {for (var a in animals) a.id: a};

    final now = DateTime.now();
    final limit = now.add(Duration(days: days));
    final events = <BreedingEvent>[];

    for (final r in records) {
      final st = BreedingStage.fromString(r['stage'] as String?);
      final stage = (r['stage'] ?? '').toString();

      DateTime? eventDate;
      String? label;

      switch (st) {
        case BreedingStage.encabritamento:
          eventDate = _toDate(r['mating_end_date']);
          label = 'Fim do encabritamento';
          break;

        case BreedingStage.separacao:
          {
            final sep = _toDate(r['separation_date']);
            final ult = _toDate(r['ultrasound_date']) ??
                (sep != null ? sep.add(const Duration(days: 30)) : null);
            eventDate = ult;
            label = 'Ultrassom';
          }
          break;

        case BreedingStage.aguardandoUltrassom:
          {
            final sep = _toDate(r['separation_date']);
            final ult = _toDate(r['ultrasound_date']) ??
                (sep != null ? sep.add(const Duration(days: 30)) : null);
            eventDate = ult;
            label = 'Ultrassom';
          }
          break;

        case BreedingStage.gestacaoConfirmada:
          eventDate = _toDate(r['expected_birth']);
          label = 'Parto previsto';
          break;

        case BreedingStage.partoRealizado:
        case BreedingStage.falhou:
          break;
      }

      if (eventDate == null) continue;

      final isOverdue = eventDate.isBefore(DateTime(now.year, now.month, now.day));
      final isSoon = !eventDate.isAfter(limit);

      if (isOverdue || isSoon) {
        final female = animalMap[r['female_animal_id']];
        events.add(
          BreedingEvent(
            label: label ?? 'Evento',
            date: eventDate,
            stage: stage,
            femaleCode: female?.code ?? 'N/A',
            femaleName: female?.name ?? 'N/A',
            overdue: isOverdue,
          ),
        );
      }
    }

    events.sort((a, b) {
      if (a.overdue != b.overdue) return a.overdue ? -1 : 1;
      return a.date.compareTo(b.date);
    });
    return events;
  }

  /// Contadores para o dashboard.
  static Future<Map<String, int>> getCounters(int days) async {
    final list = await getUpcomingEvents(days);
    final overdue = list.where((e) => e.overdue).length;
    final upcoming = list.length - overdue;
    return {'upcoming': upcoming, 'overdue': overdue};
  }
}

String _toUiStageLabel(String? raw) => BreedingStage.fromString(raw).uiTabLabel;
