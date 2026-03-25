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

  static String _normalizeSearchText(String? input) {
    return (input ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  static bool matchesSearchQuery(Animal animal, String query) {
    final q = _normalizeSearchText(query);
    if (q.isEmpty) return true;

    final colorPt = getColorName(animal.nameColor);
    final haystack = _normalizeSearchText(
      '${animal.name} ${animal.code} ${animal.nameColor} $colorPt '
      '${animal.category} ${animal.lote}',
    );
    return haystack.contains(q);
  }

  static int _defaultAnimalCompare(Animal a, Animal b) {
    final colorA = a.nameColor.toLowerCase();
    final colorB = b.nameColor.toLowerCase();
    final colorCompare = colorA.compareTo(colorB);
    if (colorCompare != 0) return colorCompare;

    final numA = extractNumber(a.name);
    final numB = extractNumber(b.name);
    if (numA != numB) return numA.compareTo(numB);

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  static double _matchScore(Animal animal, String query) {
    final q = _normalizeSearchText(query);
    if (q.isEmpty) return 1000;

    final code = _normalizeSearchText(animal.code);
    final name = _normalizeSearchText(animal.name);
    final colorKey = _normalizeSearchText(animal.nameColor);
    final colorPt = _normalizeSearchText(getColorName(animal.nameColor));
    final lote = _normalizeSearchText(animal.lote);
    final category = _normalizeSearchText(animal.category);

    if (code == q) return 0;
    if (name == q) return 1;
    if (code.startsWith(q)) return 2;
    if (name.startsWith(q)) return 3;
    if (colorKey == q || colorPt == q) return 4;
    if (lote == q) return 5;
    if (category == q) return 6;

    final codeIdx = code.indexOf(q);
    if (codeIdx >= 0) return 10 + (codeIdx / 100);

    final nameIdx = name.indexOf(q);
    if (nameIdx >= 0) return 20 + (nameIdx / 100);

    final colorKeyIdx = colorKey.indexOf(q);
    if (colorKeyIdx >= 0) return 30 + (colorKeyIdx / 100);

    final colorPtIdx = colorPt.indexOf(q);
    if (colorPtIdx >= 0) return 31 + (colorPtIdx / 100);

    final loteIdx = lote.indexOf(q);
    if (loteIdx >= 0) return 40 + (loteIdx / 100);

    final catIdx = category.indexOf(q);
    if (catIdx >= 0) return 50 + (catIdx / 100);

    return 99999;
  }

  static List<Animal> filterAndRankAnimals(
    Iterable<Animal> animals,
    String query,
  ) {
    final q = _normalizeSearchText(query);
    final list = animals.toList(growable: true);

    if (q.isEmpty) {
      list.sort(_defaultAnimalCompare);
      return list;
    }

    final filtered = list.where((a) => matchesSearchQuery(a, q)).toList();
    filtered.sort((a, b) {
      final scoreA = _matchScore(a, q);
      final scoreB = _matchScore(b, q);
      final scoreCompare = scoreA.compareTo(scoreB);
      if (scoreCompare != 0) return scoreCompare;
      return _defaultAnimalCompare(a, b);
    });
    return filtered;
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
