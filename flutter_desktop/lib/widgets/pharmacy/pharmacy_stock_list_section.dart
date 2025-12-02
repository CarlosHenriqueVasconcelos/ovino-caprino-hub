import 'package:flutter/material.dart';

import '../../models/pharmacy_stock.dart';

class PharmacyStockListSection extends StatelessWidget {
  final ScrollController? controller;
  final bool showLoadingMore;
  final List<PharmacyStockRow> rows;
  final ValueChanged<PharmacyStock> onView;
  final void Function({PharmacyStock? stock}) onEdit;

  const PharmacyStockListSection({
    super.key,
    this.controller,
    this.showLoadingMore = false,
    required this.rows,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(child: Text('Nenhum medicamento encontrado.'));
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      // Mobile: Card list view
      return ListView.builder(
        controller: controller,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length + (showLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == rows.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final row = rows[index];
          return _buildMobileCard(context, row);
        },
      );
    }

    // Desktop: DataTable
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nome')),
          DataColumn(label: Text('Categoria')),
          DataColumn(label: Text('Unidade')),
          DataColumn(label: Text('Estoque')),
          DataColumn(label: Text('Validade')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Ações')),
        ],
        rows: [
          ...rows.map((row) {
            return DataRow(
              cells: [
                DataCell(Text(row.stock.medicationName)),
                DataCell(Text(row.stock.medicationType)),
                DataCell(Text(row.stock.unitOfMeasure)),
                DataCell(Text(row.stock.totalQuantity.toStringAsFixed(1))),
                DataCell(Text(row.expirationLabel)),
                DataCell(
                  Chip(
                    label: Text(row.status.label),
                    avatar:
                        Icon(row.status.icon, size: 16, color: row.status.color),
                    backgroundColor: row.status.color.withOpacity(0.1),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        tooltip: 'Ver detalhes',
                        onPressed: () => onView(row.stock),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar',
                        onPressed: () => onEdit(stock: row.stock),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          if (showLoadingMore)
            const DataRow(
              cells: [
                DataCell(SizedBox()),
                DataCell(SizedBox()),
                DataCell(SizedBox()),
                DataCell(SizedBox()),
                DataCell(SizedBox()),
                DataCell(SizedBox()),
                DataCell(
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, PharmacyStockRow row) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nome + Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.stock.medicationName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(
                    row.status.label,
                    style: const TextStyle(fontSize: 11),
                  ),
                  avatar: Icon(row.status.icon, size: 14, color: row.status.color),
                  backgroundColor: row.status.color.withOpacity(0.1),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Info rows - Column layout to avoid overflow
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _infoChip(Icons.category, row.stock.medicationType, theme)),
                    const SizedBox(width: 8),
                    Expanded(child: _infoChip(Icons.straighten, row.stock.unitOfMeasure, theme)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _infoChip(Icons.inventory, '${row.stock.totalQuantity.toStringAsFixed(1)}', theme)),
                    const SizedBox(width: 8),
                    Expanded(child: _infoChip(Icons.event, row.expirationLabel, theme)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onView(row.stock),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onEdit(stock: row.stock),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class PharmacyStockRow {
  PharmacyStockRow({
    required this.stock,
    required this.status,
    required this.expirationLabel,
  });

  final PharmacyStock stock;
  final PharmacyStockStatus status;
  final String expirationLabel;

  factory PharmacyStockRow.fromStock(PharmacyStock stock) {
    String label = '—';
    if (stock.expirationDate != null) {
      final date = stock.expirationDate!;
      label =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return PharmacyStockRow(
      stock: stock,
      status: PharmacyStockStatus.fromStock(stock),
      expirationLabel: label,
    );
  }
}

class PharmacyStockStatus {
  PharmacyStockStatus({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  factory PharmacyStockStatus.fromStock(PharmacyStock stock) {
    if (stock.isExpired) {
      return PharmacyStockStatus(
        label: 'Vencido',
        color: Colors.red,
        icon: Icons.report,
      );
    }
    if (stock.isLowStock) {
      return PharmacyStockStatus(
        label: 'Estoque baixo',
        color: Colors.amber,
        icon: Icons.warning,
      );
    }
    if (stock.isExpiringSoon) {
      return PharmacyStockStatus(
        label: 'Vencendo',
        color: Colors.orange,
        icon: Icons.schedule,
      );
    }
    return PharmacyStockStatus(
      label: 'OK',
      color: Colors.green,
      icon: Icons.check_circle,
    );
  }
}
