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
      case 'Ampolas':
        return _stock.where((s) => s.medicationType == 'Ampola' && !s.isExpired).toList();
      case 'Comprimidos':
        return _stock.where((s) => s.medicationType == 'Comprimido' && !s.isExpired).toList();
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
      case 'Ampolas':
        return _stock.where((s) => s.medicationType == 'Ampola' && !s.isExpired).length;
      case 'Comprimidos':
        return _stock.where((s) => s.medicationType == 'Comprimido' && !s.isExpired).length;
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
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Ampolas (${_countByFilter('Ampolas')})',
                    isSelected: _filter == 'Ampolas',
                    color: Colors.purple,
                    onTap: () => setState(() => _filter = 'Ampolas'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Comprimidos (${_countByFilter('Comprimidos')})',
                    isSelected: _filter == 'Comprimidos',
                    color: Colors.teal,
                    onTap: () => setState(() => _filter = 'Comprimidos'),
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
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailsDialog(stock),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.local_pharmacy, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.medicationName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(statusIcon, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                stock.statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (stock.isOpened)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ABERTA',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tipo',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          stock.medicationType,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantidade',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          '${stock.totalQuantity.toStringAsFixed(1)} ${stock.unitOfMeasure}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: stock.isLowStock ? Colors.orange : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    if (stock.expirationDate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Validade',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          Text(
                            '${stock.expirationDate!.day.toString().padLeft(2, '0')}/${stock.expirationDate!.month.toString().padLeft(2, '0')}/${stock.expirationDate!.year}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: stock.isExpiringSoon || stock.isExpired ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
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
}
