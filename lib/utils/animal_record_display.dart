import 'package:flutter/material.dart';

/// Helper para formatar dados de animais vindos de consultas SQL
/// que já retornam `animal_name`, `animal_code` e `animal_color`.
class AnimalRecordDisplay {
  static String labelFromRecord(
    Map<String, dynamic> record, {
    String fallbackName = 'Animal',
  }) {
    final color = (record['animal_color'] ?? '').toString().trim();
    final name = (record['animal_name'] ?? '').toString().trim();
    final code = (record['animal_code'] ?? '').toString().trim();
    final gender = (record['animal_gender'] ??
            record['gender'] ??
            record['animal_sex'] ??
            '')
        .toString()
        .trim();

    final buffer = StringBuffer();
    final colorName = translateColor(color);
    final resolvedName = name.isNotEmpty ? name : fallbackName;
    buffer.write(colorName);
    buffer.write(' - ');
    buffer.write(resolvedName);

    if (code.isNotEmpty) {
      buffer.write(' - $code');
    }

    final genderSuffix = _genderSuffix(
      gender,
      name: resolvedName,
      code: code,
    );
    if (genderSuffix.isNotEmpty) {
      buffer.write(genderSuffix);
    }

    return buffer.toString();
  }

  static Color? colorFromRecord(Map<String, dynamic> record) {
    return colorFromDescriptor(record['animal_color']);
  }

  static Map<String, String> get colorTranslations => const {
        'blue': 'Azul',
        'red': 'Vermelho',
        'green': 'Verde',
        'yellow': 'Amarelo',
        'orange': 'Laranja',
        'purple': 'Roxo',
        'pink': 'Rosa',
        'grey': 'Cinza',
        'white': 'Branca',
        'black': 'Preto',
        'brown': 'Marrom',
      };

  static String translateColor(dynamic descriptor) {
    if (descriptor == null) return 'Sem cor';
    final value = descriptor.toString().trim();
    if (value.isEmpty) return 'Sem cor';
    final lower = value.toLowerCase();
    if (colorTranslations.containsKey(lower)) {
      return colorTranslations[lower]!;
    }
    return _mapDescriptors(lower) ?? value;
  }

  static Color? colorFromDescriptor(dynamic descriptor) {
    final lower = _mapDescriptors(descriptor?.toString().toLowerCase());
    switch (lower) {
      case 'blue':
        return Colors.blue[700];
      case 'red':
        return Colors.red[700];
      case 'green':
        return Colors.green[700];
      case 'yellow':
        return Colors.amber[800];
      case 'orange':
        return Colors.orange[700];
      case 'purple':
        return Colors.purple[400];
      case 'pink':
        return Colors.pink[400];
      case 'grey':
        return Colors.grey[600];
      case 'white':
        return Colors.grey[700];
      case 'black':
        return Colors.black;
      case 'brown':
        return Colors.brown;
      default:
        return null;
    }
  }

  static String? _mapDescriptors(String? descriptor) {
    if (descriptor == null || descriptor.isEmpty) return null;
    final lower = descriptor.toLowerCase();
    if (lower.contains('branco') || lower == 'white') return 'white';
    if (lower.contains('preto') || lower == 'black') return 'black';
    if (lower.contains('marrom') || lower == 'brown') return 'brown';
    if (lower.contains('vermelh') || lower == 'red') return 'red';
    if (lower.contains('amarelo') || lower == 'yellow') return 'yellow';
    if (lower.contains('cinza') || lower == 'grey' || lower == 'gray') {
      return 'grey';
    }
    if (lower.contains('azul') || lower == 'blue') return 'blue';
    if (lower.contains('verde') || lower == 'green') return 'green';
    if (lower.contains('rosa') || lower == 'pink') return 'pink';
    if (lower.contains('roxo') || lower == 'purple') return 'purple';
    if (lower.contains('laranja') || lower == 'orange') return 'orange';
    return lower;
  }

  static String _genderSuffix(
    String gender, {
    required String name,
    required String code,
  }) {
    final normalizedGender = gender.trim();
    if (normalizedGender.isEmpty) return '';
    final lowerGender = normalizedGender.toLowerCase();
    final haystack = '$name $code'.toLowerCase();
    if (haystack.contains(lowerGender)) return '';
    return ' ($normalizedGender)';
  }
}
