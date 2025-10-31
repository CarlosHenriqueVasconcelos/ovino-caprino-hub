import 'package:flutter/material.dart';
import '../models/animal.dart';

class AnimalDisplayUtils {
  static final Map<String, String> _colorNames = {
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

  static final Map<String, Color> _colorOptions = {
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

  /// Ordena lista de animais por cor e depois por número do código
  static void sortAnimalsList(List<Animal> animals) {
    animals.sort((a, b) {
      // Primeiro ordenar por cor
      final colorA = a.nameColor;
      final colorB = b.nameColor;
      final colorCompare = colorA.compareTo(colorB);
      
      if (colorCompare != 0) return colorCompare;
      
      // Depois ordenar por código numérico
      final numA = _extractNumber(a.code);
      final numB = _extractNumber(b.code);
      return numA.compareTo(numB);
    });
  }

  static int _extractNumber(String code) {
    final match = RegExp(r'\d+').firstMatch(code);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  /// Retorna o nome traduzido da cor
  static String getColorName(String colorKey) {
    return _colorNames[colorKey] ?? colorKey;
  }

  /// Retorna a cor Flutter a partir da chave
  static Color getColorFromKey(String colorKey) {
    return _colorOptions[colorKey] ?? Colors.grey;
  }

  /// Retorna o texto formatado: "Cor - Nome (Código)"
  static String getAnimalDisplayText(Animal animal) {
    final colorName = getColorName(animal.nameColor);
    return '$colorName - ${animal.name} (${animal.code})';
  }

  /// Constrói um widget para exibir animal em dropdown com cor
  static Widget buildAnimalDropdownItem(Animal animal) {
    final colorName = getColorName(animal.nameColor);
    final color = getColorFromKey(animal.nameColor);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: animal.nameColor == 'white' 
                ? Border.all(color: Colors.grey, width: 1)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$colorName - ${animal.name} (${animal.code})',
            style: TextStyle(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
