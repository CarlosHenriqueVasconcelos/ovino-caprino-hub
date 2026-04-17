import 'package:flutter/material.dart';

class TabData {
  final String title;
  final IconData icon;
  final String label;

  const TabData({
    required this.title,
    required this.icon,
    required this.label,
  });
}

/// Abas da barra de navegação inferior do app.
/// label deve bater exatamente com o texto visível no AppBottomNav.
const dashboardTabs = <TabData>[
  TabData(title: 'Início', icon: Icons.home, label: 'Início'),
  TabData(title: 'Rebanho', icon: Icons.pets, label: 'Rebanho'),
  TabData(title: 'Manejo', icon: Icons.agriculture, label: 'Manejo'),
  TabData(title: 'Financeiro', icon: Icons.attach_money, label: 'Financeiro'),
  TabData(title: 'Mais', icon: Icons.grid_view, label: 'Mais'),
];
