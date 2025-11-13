import 'package:flutter/material.dart';
import '../models/animal.dart';

class AnimalDisplayUtils {
  // Tradução de cores
  static const Map<String, String> _colorNames = {
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
  };

  // Cores do Flutter para cada nome de cor
  static const Map<String, Color> _colorValues = {
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
  };

  /// Traduz a chave de cor para português
  static String getColorName(String? colorKey) {
    if (colorKey == null || colorKey.isEmpty) return 'Sem cor';
    return _colorNames[colorKey] ?? colorKey;
  }

  /// Obtém a cor Flutter da chave de cor
  static Color getColorValue(String? colorKey) {
    if (colorKey == null || colorKey.isEmpty) return Colors.grey;
    return _colorValues[colorKey] ?? Colors.grey;
  }

  /// Extrai o número do código do animal
  static int extractNumber(String code) {
    final match = RegExp(r'\d+').firstMatch(code);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  /// Ordena a lista de animais por cor e depois por código numérico
  static void sortAnimalsList(List<Animal> animals) {
    animals.sort((a, b) {
      // Primeiro ordenar por cor
      final colorA = a.nameColor ?? '';
      final colorB = b.nameColor ?? '';
      final colorCompare = colorA.compareTo(colorB);

      if (colorCompare != 0) return colorCompare;

      // Depois ordenar por código numérico
      final numA = extractNumber(a.code);
      final numB = extractNumber(b.code);
      return numA.compareTo(numB);
    });
  }

  /// Retorna o texto formatado para exibição: "Cor - Nome (Código)"
  static String getDisplayText(Animal animal) {
    final colorName = getColorName(animal.nameColor);
    return '$colorName - ${animal.name} (${animal.code})';
  }

  /// Constrói um widget para dropdown com círculo de cor e texto formatado
  static Iterable<MapEntry<String, Color>> get colorEntries =>
      _colorValues.entries;

  static Widget buildDropdownItem(Animal animal, {TextStyle? textStyle}) {
    final colorName = getColorName(animal.nameColor);
    final colorValue = getColorValue(animal.nameColor);

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
                  text: animal.name,
                  style:
                      TextStyle(color: colorValue, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' (${animal.code})'),
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

    return RichText(
      text: TextSpan(
        style: baseStyle ?? const TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(text: '$colorName - '),
          TextSpan(
            text: animal.name,
            style: TextStyle(color: colorValue, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: ' (${animal.code})'),
        ],
      ),
    );
  }
}
