import 'package:flutter/material.dart';

enum WeightTrackingTableMode { data, list }

class WeightTrackingTable<T> extends StatelessWidget {
  final List<T> items;
  final WeightTrackingTableMode mode;
  final List<DataColumn>? columns;
  final DataRow Function(T item)? dataRowBuilder;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final Widget? emptyState;
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  const WeightTrackingTable({
    super.key,
    required this.items,
    required this.mode,
    this.columns,
    this.dataRowBuilder,
    this.itemBuilder,
    this.emptyState,
    this.separatorBuilder,
  }) : assert(
          mode == WeightTrackingTableMode.data
              ? columns != null && dataRowBuilder != null
              : itemBuilder != null,
          'Provide the correct builders for the selected table mode.',
        );

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyState ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nenhum registro encontrado.'),
            ),
          );
    }

    switch (mode) {
      case WeightTrackingTableMode.data:
        final rows = dataRowBuilder != null
            ? items.map((item) => dataRowBuilder!(item)).toList()
            : <DataRow>[];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns ?? const [],
            rows: rows,
          ),
        );
      case WeightTrackingTableMode.list:
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: separatorBuilder ??
              (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final builder = itemBuilder;
            if (builder == null) return const SizedBox.shrink();
            return builder(context, items[index]);
          },
        );
    }
  }
}
