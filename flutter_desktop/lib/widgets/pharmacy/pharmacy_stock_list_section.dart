import 'package:flutter/material.dart';

import '../../models/pharmacy_stock.dart';

class PharmacyStockListSection extends StatelessWidget {
  final List<PharmacyStockRow> rows;
  final ValueChanged<PharmacyStock> onView;
  final void Function({PharmacyStock? stock}) onEdit;

  const PharmacyStockListSection({
    super.key,
    required this.rows,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(child: Text('Nenhum medicamento encontrado.'));
    }

    return SingleChildScrollView(
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
        rows: rows.map((row) {
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
                  avatar: Icon(row.status.icon, size: 16, color: row.status.color),
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
        }).toList(),
      ),
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
