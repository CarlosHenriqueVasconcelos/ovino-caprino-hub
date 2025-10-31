import 'package:flutter/material.dart';
import '../models/pharmacy_stock.dart';
import '../models/pharmacy_stock_movement.dart';
import '../services/pharmacy_service.dart';
import 'pharmacy_stock_form.dart';

class PharmacyStockDetails extends StatefulWidget {
  final PharmacyStock stock;

  const PharmacyStockDetails({super.key, required this.stock});

  @override
  State<PharmacyStockDetails> createState() => _PharmacyStockDetailsState();
}

class _PharmacyStockDetailsState extends State<PharmacyStockDetails> {
  List<PharmacyStockMovement> _movements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    setState(() => _isLoading = true);
    try {
      final movements = await PharmacyService.getMovements(widget.stock.id);
      setState(() {
        _movements = movements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddMovementDialog() async {
    final typeController = TextEditingController();
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    String selectedType = 'entrada';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Movimentação'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Movimentação',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
                  DropdownMenuItem(value: 'saida', child: Text('Saída')),
                  DropdownMenuItem(value: 'ajuste', child: Text('Ajuste')),
                  DropdownMenuItem(value: 'vencimento', child: Text('Vencimento/Descarte')),
                ],
                onChanged: (value) {
                  selectedType = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantidade',
                  suffixText: widget.stock.unitOfMeasure,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo/Observação',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text.replaceAll(',', '.'));
              if (quantity == null || quantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quantidade inválida')),
                );
                return;
              }

              try {
                if (selectedType == 'entrada') {
                  await PharmacyService.addToStock(
                    widget.stock.id,
                    quantity,
                    reason: reasonController.text.isEmpty ? null : reasonController.text,
                  );
                } else if (selectedType == 'saida' || selectedType == 'vencimento' || selectedType == 'ajuste') {
                  await PharmacyService.deductFromStock(
                    widget.stock.id,
                    quantity,
                    null, // Passar null pois não está associado a uma aplicação em animal
                  );
                }
                Navigator.of(context).pop(true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadMovements();
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _showEditDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PharmacyStockForm(stock: widget.stock),
    );

    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteStock() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir "${widget.stock.medicationName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PharmacyService.deleteMedication(widget.stock.id);
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medicamento excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Medicamento'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showEditDialog,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteStock,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_pharmacy, size: 32, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.stock.medicationName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Tipo:', widget.stock.medicationType),
                      _buildInfoRow('Unidade:', widget.stock.unitOfMeasure),
                      if (widget.stock.quantityPerUnit != null)
                        _buildInfoRow('Quantidade por unidade:', '${widget.stock.quantityPerUnit} ${widget.stock.unitOfMeasure}'),
                      _buildInfoRow(
                        'Quantidade Total:',
                        '${widget.stock.totalQuantity.toStringAsFixed(1)} ${widget.stock.unitOfMeasure}',
                        valueColor: widget.stock.isLowStock ? Colors.orange : null,
                      ),
                      if (widget.stock.minStockAlert != null)
                        _buildInfoRow('Estoque Mínimo:', '${widget.stock.minStockAlert} ${widget.stock.unitOfMeasure}'),
                      if (widget.stock.expirationDate != null)
                        _buildInfoRow(
                          'Validade:',
                          '${widget.stock.expirationDate!.day.toString().padLeft(2, '0')}/${widget.stock.expirationDate!.month.toString().padLeft(2, '0')}/${widget.stock.expirationDate!.year}',
                          valueColor: widget.stock.isExpiringSoon || widget.stock.isExpired ? Colors.red : null,
                        ),
                      if (widget.stock.notes != null && widget.stock.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Observações:', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(widget.stock.notes!),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Histórico de Movimentações',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddMovementDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _movements.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('Nenhuma movimentação registrada'),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _movements.length,
                          itemBuilder: (context, index) {
                            final movement = _movements[index];
                            return _buildMovementCard(movement);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementCard(PharmacyStockMovement movement) {
    IconData icon;
    Color color;

    switch (movement.movementType) {
      case 'entrada':
        icon = Icons.arrow_downward;
        color = Colors.green;
        break;
      case 'saida':
        icon = Icons.arrow_upward;
        color = Colors.red;
        break;
      case 'ajuste':
        icon = Icons.build;
        color = Colors.blue;
        break;
      case 'vencimento':
        icon = Icons.delete;
        color = Colors.orange;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          movement.movementType.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantidade: ${movement.quantity.toStringAsFixed(1)} ${widget.stock.unitOfMeasure}'),
            if (movement.reason != null && movement.reason!.isNotEmpty)
              Text('Motivo: ${movement.reason}'),
            Text(
              'Data: ${movement.createdAt.day.toString().padLeft(2, '0')}/${movement.createdAt.month.toString().padLeft(2, '0')}/${movement.createdAt.year} ${movement.createdAt.hour.toString().padLeft(2, '0')}:${movement.createdAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
