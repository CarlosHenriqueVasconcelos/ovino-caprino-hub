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
    const options = ReportViewMode.values;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ToggleButtons(
        isSelected: options.map((m) => m == mode).toList(),
        onPressed: (index) => onChanged(options[index]),
        borderRadius: BorderRadius.circular(8),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Resumo'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Gráfico'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Tabela'),
          ),
        ],
      ),
    );
  }
}

