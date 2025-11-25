import '../../models/animal.dart';

/// Helper utilitário para centralizar qualquer conversão de dados
/// relacionada a importação/exportação de animais.
class AnimalImportExportHelper {
  static const List<String> _csvHeaders = [
    'id',
    'code',
    'name',
    'species',
    'breed',
    'gender',
    'birth_date',
    'weight',
    'status',
    'location',
    'name_color',
    'category',
  ];

  static String exportToCsv(Iterable<Animal> animals) {
    final buffer = StringBuffer()..writeln(_csvHeaders.join(','));
    for (final animal in animals) {
      final row = [
        animal.id,
        animal.code,
        animal.name,
        animal.species,
        animal.breed,
        animal.gender,
        animal.birthDate.toIso8601String(),
        animal.weight.toString(),
        animal.status,
        animal.location,
        animal.nameColor,
        animal.category,
      ].map(_escapeCsv).join(',');
      buffer.writeln(row);
    }
    return buffer.toString();
  }

  static String _escapeCsv(String? value) {
    final sanitized = value ?? '';
    if (sanitized.contains(',') || sanitized.contains('"')) {
      return '"${sanitized.replaceAll('"', '""')}"';
    }
    return sanitized;
  }
}
