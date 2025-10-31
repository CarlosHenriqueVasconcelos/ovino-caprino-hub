import 'package:flutter/material.dart';
import '../models/pharmacy_stock.dart';
import '../services/pharmacy_service.dart';
import 'pharmacy_stock_form.dart';
import 'pharmacy_stock_details.dart';

class PharmacyManagementScreen extends StatefulWidget {
  const PharmacyManagementScreen({super.key});

  @override
  State<PharmacyManagementScreen> createState() => _PharmacyManagementScreenState();
}

class _PharmacyManagementScreenState extends State<PharmacyManagementScreen> {
  List<PharmacyStock> _stock = [];
  bool _isLoading = true;
  String _filter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadStock();
  }

  Future<void> _loadStock() async {
    setState(() => _isLoading = true);
    try {
      final stock = await PharmacyService.getPharmacyStock();
      setState(() {
        _stock = stock;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estoque: $e')),
        );
      }
    }
  }

  List<PharmacyStock> _filterStock() {
    switch (_filter) {
      case 'Estoque Baixo':
        return _stock.where((s) => s.isLowStock && !s.isExpired).toList();
      case 'Vencendo':
        return _stock.where((s) => s.isExpiringSoon && !s.isExpired).toList();
      case 'Vencidos':
        return _stock.where((s) => s.isExpired).toList();
      default:
        return _stock.where((s) => !s.isExpired).toList();
    }
  }

  int _countByFilter(String filter) {
    switch (filter) {
      case 'Estoque Baixo':
        return _stock.where((s) => s.isLowStock && !s.isExpired).length;
      case 'Vencendo':
        return _stock.where((s) => s.isExpiringSoon && !s.isExpired).length;
      case 'Vencidos':
        return _stock.where((s) => s.isExpired).length;
      default:
        return _stock.where((s) => !s.isExpired).length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStock = _filterStock();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmácia - Estoque de Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStock,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Todos (${_countByFilter('Todos')})',
                    isSelected: _filter == 'Todos',
                    color: Colors.blue,
                    onTap: () => setState(() => _filter = 'Todos'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Estoque Baixo (${_countByFilter('Estoque Baixo')})',
                    isSelected: _filter == 'Estoque Baixo',
                    color: Colors.orange,
                    onTap: () => setState(() => _filter = 'Estoque Baixo'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Vencendo (${_countByFilter('Vencendo')})',
                    isSelected: _filter == 'Vencendo',
                    color: Colors.amber,
                    onTap: () => setState(() => _filter = 'Vencendo'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Vencidos (${_countByFilter('Vencidos')})',
                    isSelected: _filter == 'Vencidos',
                    color: Colors.red,
                    onTap: () => setState(() => _filter = 'Vencidos'),
                  ),
                ],
              ),
            ),
          ),

          // Lista de medicamentos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStock.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_pharmacy_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum medicamento encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                         padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredStock.length,
                        itemBuilder: (context, index) {
                          final stock = filteredStock[index];
                          return _buildStockCard(stock);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Medicamento'),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard(PharmacyStock stock) {
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;

    if (stock.isExpired) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else if (stock.isLowStock) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else if (stock.isExpiringSoon) {
      statusColor = Colors.amber;
      statusIcon = Icons.access_time;
    }

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black, width: 1),
      ),
      child: InkWell(
        onTap: () => _showDetailsDialog(stock),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.local_pharmacy, color: Colors.green, size: 18),
                  ),
                  Icon(statusIcon, size: 18, color: statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stock.medicationName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              if (stock.quantityPerUnit != null) ...[
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 3),
                    Text(
                      '${stock.quantityPerUnit!.toStringAsFixed(1)} ml/un',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
              ],
              Row(
                children: [
                  Icon(Icons.inventory_2, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      _buildStockQuantityText(stock),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: stock.isLowStock ? Colors.orange : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (stock.openedQuantity > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '1 aberto (${stock.openedQuantity.toStringAsFixed(1)}ml)',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const PharmacyStockForm(),
    );

    if (result == true) {
      _loadStock();
    }
  }

  Future<void> _showDetailsDialog(PharmacyStock stock) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PharmacyStockDetails(stock: stock),
    );

    if (result == true) {
      _loadStock();
    }
  }

  String _buildStockQuantityText(PharmacyStock stock) {
    final typeName = stock.medicationType.toLowerCase();
    final isLiquid = (typeName == 'ampola' || typeName == 'frasco') && stock.quantityPerUnit != null;
    
    if (isLiquid) {
      final totalVolume = (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity;
      return '${stock.totalQuantity.toStringAsFixed(0)} ${typeName}${stock.totalQuantity != 1 ? 's' : ''}\n(${totalVolume.toStringAsFixed(0)}ml total)';
    }
    
    return '${stock.totalQuantity.toStringAsFixed(0)} ${typeName}${stock.totalQuantity != 1 ? 's' : ''}';
  }
}
