import 'package:flutter/material.dart';

import '../../models/pharmacy_stock.dart';

class PharmacyMovementResult {
  final double quantity;
  final String reason;

  PharmacyMovementResult({
    required this.quantity,
    required this.reason,
  });
}

Future<PharmacyStock?> showPharmacyStockPickerDialog(
  BuildContext context,
  List<PharmacyStock> stock,
) {
  return showDialog<PharmacyStock?>(
    context: context,
    builder: (context) => PharmacyStockPickerDialog(stock: stock),
  );
}

Future<PharmacyMovementResult?> showPharmacyMovementDialog(
  BuildContext context, {
  required PharmacyStock stock,
  required String movementType,
}) {
  return showDialog<PharmacyMovementResult?>(
    context: context,
    builder: (context) => PharmacyMovementDialog(
      stock: stock,
      movementType: movementType,
    ),
  );
}

class PharmacyStockPickerDialog extends StatelessWidget {
  final List<PharmacyStock> stock;

  const PharmacyStockPickerDialog({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione o medicamento'),
      content: SizedBox(
        width: 400,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: stock.length,
          itemBuilder: (context, index) {
            final item = stock[index];
            return ListTile(
              title: Text(item.medicationName),
              subtitle: Text(
                '${item.totalQuantity.toStringAsFixed(1)} ${item.unitOfMeasure}',
              ),
              onTap: () => Navigator.pop(context, item),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class PharmacyMovementDialog extends StatefulWidget {
  final PharmacyStock stock;
  final String movementType;

  const PharmacyMovementDialog({
    super.key,
    required this.stock,
    required this.movementType,
  });

  @override
  State<PharmacyMovementDialog> createState() => _PharmacyMovementDialogState();
}

class _PharmacyMovementDialogState extends State<PharmacyMovementDialog> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.movementType == 'entrada'
        ? 'Registrar entrada'
        : 'Registrar saída';

    return AlertDialog(
      title: Text(label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Quantidade (${widget.stock.unitOfMeasure})',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Motivo/Observação',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Registrar'),
        ),
      ],
    );
  }

  void _submit() {
    final quantity =
        double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Informe uma quantidade válida');
      return;
    }

    Navigator.pop(
      context,
      PharmacyMovementResult(
        quantity: quantity,
        reason: _reasonController.text,
      ),
    );
  }
}
