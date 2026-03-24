import 'package:flutter/material.dart';
import '../models/animal.dart';

class AnimalDisplayUtils {
  // Tradução de cores
  static const Map<String, String> _colorNames = {
    // Inglês -> Português
    'blue': 'Azul',
    'red': 'Vermelho',
    'green': 'Verde',
    'yellow': 'Amarelo',
    'orange': 'Laranja',
    'purple': 'Roxo',
    'pink': 'Rosa',
    'grey': 'Cinza',
    'white': 'Branco',
    'black': 'Preto',
    'cyan': 'Ciano',
    'teal': 'Verde-azulado',
    'indigo': 'Índigo',
    'lime': 'Lima',
    'amber': 'Âmbar',
    // Português (normaliza para exibição consistente)
    'azul': 'Azul',
    'vermelho': 'Vermelho',
    'verde': 'Verde',
    'amarelo': 'Amarelo',
    'laranja': 'Laranja',
    'roxo': 'Roxo',
    'rosa': 'Rosa',
    'cinza': 'Cinza',
    'branco': 'Branco',
    'preto': 'Preto',
    'ciano': 'Ciano',
    'anil': 'Índigo',
    'lima': 'Lima',
    'ambar': 'Âmbar',
    'âmbar': 'Âmbar',
  };

  // Cores do Flutter para cada nome de cor
  static const Map<String, Color> _colorValues = {
    // Inglês
    'blue': Colors.blue,
    'red': Colors.red,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'grey': Colors.grey,
    'white': Colors.white,
    'black': Colors.black,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'indigo': Colors.indigo,
    'lime': Colors.lime,
    'amber': Colors.amber,
    // Português
    'azul': Colors.blue,
    'vermelho': Colors.red,
    'verde': Colors.green,
    'amarelo': Colors.yellow,
    'laranja': Colors.orange,
    'roxo': Colors.purple,
    'rosa': Colors.pink,
    'cinza': Colors.grey,
    'branco': Colors.white,
    'preto': Colors.black,
    'ciano': Colors.cyan,
    'anil': Colors.indigo,
    'lima': Colors.lime,
    'ambar': Colors.amber,
    'âmbar': Colors.amber,
  };

  // Paleta canônica usada nos dropdowns de cadastro.
  static const Map<String, Color> _pickerColorValues = {
    'blue': Colors.blue,
    'red': Colors.red,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'grey': Colors.grey,
    'white': Colors.white,
    'black': Colors.black,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'indigo': Colors.indigo,
    'lime': Colors.lime,
    'amber': Colors.amber,
  };

  static String _normalizeColor(String? colorKey) =>
      (colorKey ?? '').trim().toLowerCase();

  static String _titleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  /// Traduz a chave de cor para português
  static String getColorName(String? colorKey) {
    final normalized = _normalizeColor(colorKey);
    if (normalized.isEmpty) return 'Sem cor';
    return _colorNames[normalized] ?? _titleCase(normalized);
  }

  /// Obtém a cor Flutter da chave de cor
  static Color getColorValue(String? colorKey) {
    final normalized = _normalizeColor(colorKey);
    if (normalized.isEmpty) return Colors.grey;
    return _colorValues[normalized] ?? Colors.grey;
  }

  /// Extrai o número de uma string (nome ou código)
  static int extractNumber(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  /// Ordena a lista de animais por cor e depois pelo nome numérico (crescente)
  static void sortAnimalsList(List<Animal> animals) {
    animals.sort((a, b) {
      // Primeiro ordenar por cor alfabeticamente
      final colorA = a.nameColor.toLowerCase();
      final colorB = b.nameColor.toLowerCase();
      final colorCompare = colorA.compareTo(colorB);

      if (colorCompare != 0) return colorCompare;

      // Depois ordenar pelo nome numérico (crescente)
      final numA = extractNumber(a.name);
      final numB = extractNumber(b.name);
      if (numA != numB) return numA.compareTo(numB);

      // Se números iguais, ordenar alfabeticamente pelo nome completo
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  /// Retorna o texto formatado para exibição: "Cor - Nome - Código (Sexo)"
  static String getDisplayText(Animal animal) {
    final colorName = getColorName(animal.nameColor);
    final name = animal.name.isNotEmpty ? animal.name : 'Sem nome';
    final code = animal.code.isNotEmpty ? animal.code : 'Sem código';
    final genderSuffix = _genderSuffix(animal.gender, name: name, code: code);
    return '$colorName - $name - $code$genderSuffix';
  }

  /// Constrói um widget para dropdown com círculo de cor e texto formatado
  static Iterable<MapEntry<String, Color>> get colorEntries =>
      _pickerColorValues.entries;

  static Widget buildDropdownItem(Animal animal, {TextStyle? textStyle}) {
    final colorName = getColorName(animal.nameColor);
    final colorValue = getColorValue(animal.nameColor);
    final name = animal.name.isNotEmpty ? animal.name : 'Sem nome';
    final code = animal.code.isNotEmpty ? animal.code : 'Sem código';
    final genderSuffix = _genderSuffix(animal.gender, name: name, code: code);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Círculo de cor
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: colorValue,
            shape: BoxShape.circle,
            border: animal.nameColor == 'white'
                ? Border.all(color: Colors.grey, width: 1)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        // Texto formatado
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: textStyle ??
                  const TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(text: '$colorName - '),
                TextSpan(
                  text: name,
                  style:
                      TextStyle(color: colorValue, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' - $code$genderSuffix'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Constrói um widget de texto com o nome colorido
  static Widget buildColoredNameText(Animal animal, {TextStyle? baseStyle}) {
    final colorName = getColorName(animal.nameColor);
    final colorValue = getColorValue(animal.nameColor);
    final name = animal.name.isNotEmpty ? animal.name : 'Sem nome';
    final code = animal.code.isNotEmpty ? animal.code : 'Sem código';
    final genderSuffix = _genderSuffix(animal.gender, name: name, code: code);

    return RichText(
      text: TextSpan(
        style: baseStyle ?? const TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(text: '$colorName - '),
          TextSpan(
            text: name,
            style: TextStyle(color: colorValue, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' - $code$genderSuffix'),
        ],
      ),
    );
  }

  static String _genderSuffix(
    String? gender, {
    required String name,
    required String code,
  }) {
    final normalizedGender = (gender ?? '').trim();
    if (normalizedGender.isEmpty) return '';
    final lowerGender = normalizedGender.toLowerCase();
    final haystack = '$name $code'.toLowerCase();
    if (haystack.contains(lowerGender)) return '';
    return ' ($normalizedGender)';
  }
}
