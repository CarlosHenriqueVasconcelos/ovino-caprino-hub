// lib/widgets/report_table.dart
import 'package:flutter/material.dart';
import '../utils/labels_ptbr.dart';

class ReportTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final List<String>? columnsOrder;
  final double dataRowHeight;
  final double headingRowHeight;
  final EdgeInsets padding;

  const ReportTable({
    super.key,
    required this.rows,
    this.columnsOrder,
    this.dataRowHeight = 44,
    this.headingRowHeight = 48,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _emptyState(context);
    }

    final keys = columnsOrder ??
        rows.first.keys.toList(growable: false);

    final columns = keys
        .map((k) => DataColumn(label: Text(ptBrHeader(k), style: const TextStyle(fontWeight: FontWeight.bold))))
        .toList();

    final dataRows = rows.map((row) {
      return DataRow(
        cells: keys.map((k) {
          final v = row[k];
          return DataCell(Text(_fmt(v)));
        }).toList(),
      );
    }).toList();

    return Padding(
      padding: padding,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 800),
            child: DataTable(
              headingRowHeight: headingRowHeight,
              dataRowMinHeight: dataRowHeight,
              dataRowMaxHeight: dataRowHeight,
              columns: columns,
              rows: dataRows,
              dividerThickness: 0.6,
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '-';
    if (v is bool) return v ? 'Sim' : 'Não';
    return v.toString();
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 8),
          Text('Sem dados para exibir', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
