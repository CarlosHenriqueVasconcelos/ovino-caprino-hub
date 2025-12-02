import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/pharmacy_stock.dart';
import '../models/pharmacy_stock_movement.dart';
import '../services/pharmacy_service.dart';
import 'pharmacy_stock_form.dart';

class PharmacyStockDetails extends StatefulWidget {
  const PharmacyStockDetails({super.key, required this.stock});

  final PharmacyStock stock;

  @override
  State<PharmacyStockDetails> createState() => _PharmacyStockDetailsState();
}

class _PharmacyStockDetailsState extends State<PharmacyStockDetails> {
  late PharmacyStock _stock;
  List<PharmacyStockMovement> _movements = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _page = 0;
  static const int _pageSize = 50;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _stock = widget.stock;
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _loadMovements();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMovements() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<PharmacyService>();
      final data = await service.getMovements(
        _stock.id,
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _movements = data;
        _page = 0;
        _hasMore = data.length == _pageSize;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openMovementDialog() async {
    final result = await _MovementDialog.show(context, _stock);
    if (!mounted) return;
    if (result == true) {
      await _loadMovements();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _editStock() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PharmacyStockForm(stock: _stock),
    );
    if (!mounted) return;
    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _discardOpened() async {
    if (!_stock.isOpened || _stock.openedQuantity <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não há recipiente aberto.')),
        );
      }
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar recipiente aberto'),
        content: Text(
          'Confirma o descarte de '
          '${_stock.openedQuantity.toStringAsFixed(1)} ${_stock.unitOfMeasure}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (!mounted) return;
    final service = context.read<PharmacyService>();
    try {
      final updated = _stock.copyWith(
        isOpened: false,
        openedQuantity: 0,
        updatedAt: DateTime.now(),
      );
      await service.updateMedication(_stock.id, updated);
      await service.recordMovement(
        PharmacyStockMovement(
          id: const Uuid().v4(),
          pharmacyStockId: _stock.id,
          movementType: 'vencimento',
          quantity: _stock.openedQuantity,
          reason: 'Descarte de recipiente aberto',
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao descartar: $e')),
        );
      }
    }
  }

  Future<void> _deleteStock() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir medicamento'),
        content: Text('Confirma excluir ${_stock.medicationName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    if (!mounted) return;

    try {
      final service = context.read<PharmacyService>();
      await service.deleteMedication(_stock.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final service = context.read<PharmacyService>();
      final data = await service.getMovements(
        _stock.id,
        limit: _pageSize,
        offset: nextPage * _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _movements.addAll(data);
        _page = nextPage;
        _hasMore = data.length == _pageSize;
      });
    } catch (_) {
      // mantém estado atual
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 860),
        child: Column(
          children: [
            StockDetailsHeader(
              stock: _stock,
              onClose: () => Navigator.of(context).pop(),
              onEdit: _editStock,
              onDelete: _deleteStock,
              onDiscardOpened: _stock.isOpened ? _discardOpened : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StockQuantitySection(stock: _stock),
                    const SizedBox(height: 16),
                    StockQuickActions(
                      onRegisterMovement: _openMovementDialog,
                      onDiscardOpened: _stock.isOpened ? _discardOpened : null,
                      onDelete: _deleteStock,
                    ),
                    const SizedBox(height: 16),
                    StockHistorySection(
                      isLoading: _isLoading,
                      movements: _movements,
                      unit: _stock.unitOfMeasure,
                      controller: _scrollController,
                      showLoadingMore: _isLoadingMore || _hasMore,
                    ),
                    const SizedBox(height: 16),
                    if (_stock.notes != null && _stock.notes!.isNotEmpty)
                      StockNotesSection(notes: _stock.notes!),
                    if (_stock.notes == null || _stock.notes!.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Nenhuma observação registrada para este medicamento.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StockDetailsHeader extends StatelessWidget {
  const StockDetailsHeader({
    super.key,
    required this.stock,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
    this.onDiscardOpened,
  });

  final PharmacyStock stock;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDiscardOpened;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[
      _StatusChip(
        label: stock.isExpired
            ? 'Vencido'
            : stock.isExpiringSoon
                ? 'Vencendo'
                : 'Validade ok',
        color: stock.isExpired
            ? Colors.red
            : stock.isExpiringSoon
                ? Colors.orange
                : Colors.green,
      ),
      if (stock.isLowStock)
        const _StatusChip(label: 'Estoque baixo', color: Colors.amber),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.medicationName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    stock.medicationType,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Wrap(spacing: 8, runSpacing: 4, children: badges),
                ],
              ),
            ),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
            if (onDiscardOpened != null)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Descartar recipiente aberto',
                onPressed: onDiscardOpened,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class StockQuantitySection extends StatelessWidget {
  const StockQuantitySection({super.key, required this.stock});

  final PharmacyStock stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = stock.unitOfMeasure.toLowerCase();
    final useVolumeLogic = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        stock.quantityPerUnit != null &&
        stock.quantityPerUnit! > 0;
    final totalVolume = useVolumeLogic
        ? (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity
        : stock.totalQuantity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estoque atual', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (useVolumeLogic) ...[
              _InfoRow(
                label: 'Recipientes fechados',
                value: '${stock.totalQuantity.toStringAsFixed(0)} unidades',
              ),
              if (stock.isOpened && stock.openedQuantity > 0)
                _InfoRow(
                  label: 'Recipiente aberto',
                  value:
                      '${stock.openedQuantity.toStringAsFixed(1)} ${stock.unitOfMeasure}',
                ),
              _InfoRow(
                label: 'Volume disponível',
                value:
                    '${totalVolume.toStringAsFixed(1)} ${stock.unitOfMeasure}',
              ),
            ] else
              _InfoRow(
                label: 'Quantidade',
                value:
                    '${stock.totalQuantity.toStringAsFixed(0)} ${stock.unitOfMeasure}',
              ),
            if (stock.minStockAlert != null)
              _InfoRow(
                label: 'Estoque mínimo',
                value: '${stock.minStockAlert} ${stock.unitOfMeasure}',
              ),
            if (stock.expirationDate != null)
              _InfoRow(
                label: 'Validade',
                value:
                    '${stock.expirationDate!.day.toString().padLeft(2, '0')}/${stock.expirationDate!.month.toString().padLeft(2, '0')}/${stock.expirationDate!.year}',
              ),
          ],
        ),
      ),
    );
  }
}

class StockQuickActions extends StatelessWidget {
  const StockQuickActions({
    super.key,
    required this.onRegisterMovement,
    this.onDiscardOpened,
    required this.onDelete,
  });

  final VoidCallback onRegisterMovement;
  final VoidCallback? onDiscardOpened;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: onRegisterMovement,
          icon: const Icon(Icons.playlist_add),
          label: const Text('Registrar movimentação'),
        ),
        if (onDiscardOpened != null)
          OutlinedButton.icon(
            onPressed: onDiscardOpened,
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Descartar recipiente aberto'),
          ),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Excluir medicamento'),
        ),
      ],
    );
  }
}

class StockHistorySection extends StatelessWidget {
  const StockHistorySection({
    super.key,
    required this.isLoading,
    required this.movements,
    required this.unit,
    this.controller,
    this.showLoadingMore = false,
  });

  final bool isLoading;
  final List<PharmacyStockMovement> movements;
  final String unit;
  final ScrollController? controller;
  final bool showLoadingMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (movements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Nenhuma movimentação registrada.')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico de movimentações',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListView.builder(
              controller: controller,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movements.length + (showLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (showLoadingMore && index >= movements.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final movement = movements[index];
                return _MovementTile(movement: movement, unit: unit);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StockNotesSection extends StatelessWidget {
  const StockNotesSection({super.key, required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observações',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(notes),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement, required this.unit});

  final PharmacyStockMovement movement;
  final String unit;

  @override
  Widget build(BuildContext context) {
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
      default:
        icon = Icons.info_outline;
        color = Colors.orange;
    }

    final date = movement.createdAt;
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(
        movement.movementType.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantidade: ${movement.quantity.toStringAsFixed(1)} $unit'),
          if (movement.reason != null && movement.reason!.isNotEmpty)
            Text('Motivo: ${movement.reason}'),
          Text(dateLabel, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _MovementDialog extends StatefulWidget {
  const _MovementDialog({required this.stock});

  final PharmacyStock stock;

  static Future<bool?> show(BuildContext context, PharmacyStock stock) {
    return showDialog<bool>(
      context: context,
      builder: (context) => _MovementDialog(stock: stock),
    );
  }

  @override
  State<_MovementDialog> createState() => _MovementDialogState();
}

class _MovementDialogState extends State<_MovementDialog> {
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedType = 'entrada';
  bool _saving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final quantity =
        double.tryParse(_quantityController.text.replaceAll(',', '.'));
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade inválida')),
      );
      return;
    }

    setState(() => _saving = true);
    final service = context.read<PharmacyService>();
    try {
      if (_selectedType == 'entrada') {
        await service.addToStock(
          widget.stock.id,
          quantity,
          reason:
              _reasonController.text.isEmpty ? null : _reasonController.text,
        );
      } else {
        await service.deductFromStock(
          widget.stock.id,
          quantity,
          null,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar movimentação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
              DropdownMenuItem(value: 'saida', child: Text('Saída')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedType = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Quantidade (${widget.stock.unitOfMeasure})',
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^[0-9]*[.,]?[0-9]{0,2}')),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Motivo/observação',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _handleSubmit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
