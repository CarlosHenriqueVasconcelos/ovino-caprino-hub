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

const dashboardTabs = <TabData>[
  TabData(title: 'Dashboard', icon: Icons.home, label: 'Dashboard'),
  TabData(title: 'Rebanho', icon: Icons.groups, label: 'Rebanho'),
  TabData(title: 'Alimentação', icon: Icons.agriculture, label: 'Alimentação'),
  TabData(
      title: 'Peso & Crescimento', icon: Icons.monitor_weight, label: 'Peso'),
  TabData(title: 'Reprodução', icon: Icons.favorite, label: 'Reprodução'),
  TabData(
      title: 'Vacinações e Medicamentos',
      icon: Icons.medication,
      label: 'Vacinas'),
  TabData(title: 'Anotações', icon: Icons.note_alt, label: 'Anotações'),
  TabData(title: 'Farmácia', icon: Icons.local_pharmacy, label: 'Farmácia'),
  TabData(title: 'Relatórios', icon: Icons.analytics, label: 'Relatórios'),
  TabData(title: 'Financeiro', icon: Icons.attach_money, label: 'Financeiro'),
  TabData(title: 'Sistema', icon: Icons.settings, label: 'Sistema'),
];
