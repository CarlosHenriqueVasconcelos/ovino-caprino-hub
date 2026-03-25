import 'package:flutter/material.dart';

import 'reports_models.dart';

class ReportsViewSwitcher extends StatelessWidget {
  final ReportViewMode mode;
  final ValueChanged<ReportViewMode> onChanged;

  const ReportsViewSwitcher({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    const options = ReportViewMode.values;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16, 
        vertical: 4,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ToggleButtons(
          isSelected: options.map((m) => m == mode).toList(),
          onPressed: (index) => onChanged(options[index]),
          borderRadius: BorderRadius.circular(8),
          constraints: BoxConstraints(
            minHeight: isMobile ? 36 : 40,
            minWidth: isMobile ? 70 : 80,
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              child: Text('Resumo', style: TextStyle(fontSize: isMobile ? 12 : 14)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              child: Text('Gráfico', style: TextStyle(fontSize: isMobile ? 12 : 14)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              child: Text('Tabela', style: TextStyle(fontSize: isMobile ? 12 : 14)),
            ),
          ],
        ),
      ),
    );
  }
}
