import 'package:flutter/material.dart';

import '../../utils/labels_ptbr.dart';

class ReportsTableArea extends StatelessWidget {
  final ThemeData theme;
  final List<String> columns;
  final List<Map<String, dynamic>> rows;
  final String sortKey;
  final bool sortAscending;
  final ValueChanged<String> onSort;
  final DataCell Function(Map<String, dynamic> row, String key) cellBuilder;

  const ReportsTableArea({
    super.key,
    required this.theme,
    required this.columns,
    required this.rows,
    required this.sortKey,
    required this.sortAscending,
    required this.onSort,
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: sortKey.isEmpty ? null : columns.indexOf(sortKey),
          sortAscending: sortAscending,
          columns: columns
              .map(
                (col) => DataColumn(
                  label: Text(ptBrHeader(col)),
                  onSort: (_, __) => onSort(col),
                ),
              )
              .toList(),
          rows: rows
              .map(
                (row) => DataRow(
                  cells: columns.map((col) => cellBuilder(row, col)).toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
