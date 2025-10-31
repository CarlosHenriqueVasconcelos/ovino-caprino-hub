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
  String _searchQuery = '';
  String _sortBy = 'name'; // name, quantity, expiration

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
    var filtered = _stock.where((s) => !s.isExpired).toList();
    
    // Aplicar busca
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) => 
        s.medicationName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Aplicar filtro
    switch (_filter) {
      case 'Estoque Baixo':
        filtered = filtered.where((s) => s.isLowStock).toList();
        break;
      case 'Vencendo':
        filtered = filtered.where((s) => s.isExpiringSoon).toList();
        break;
    }
    
    // Aplicar ordenação
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.medicationName.compareTo(b.medicationName));
        break;
      case 'quantity':
        filtered.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
        break;
      case 'expiration':
        filtered.sort((a, b) {
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          return a.expirationDate!.compareTo(b.expirationDate!);
        });
        break;
    }
    
    return filtered;
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Farmácia — Estoque de Medicamentos',
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadStock,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'novo',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text('Novo Medicamento'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'novo') _showAddDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa e ordenação
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: const InputDecoration(
                            hintText: 'Buscar por nome ou apresentação...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _sortBy,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Ordenar: Nome')),
                          DropdownMenuItem(value: 'quantity', child: Text('Ordenar: Quantidade')),
                          DropdownMenuItem(value: 'expiration', child: Text('Ordenar: Validade')),
                        ],
                        onChanged: (value) => setState(() => _sortBy = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Todos',
                        isSelected: _filter == 'Todos',
                        color: Colors.blue,
                        onTap: () => setState(() => _filter = 'Todos'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Estoque Baixo',
                        isSelected: _filter == 'Estoque Baixo',
                        color: Colors.orange,
                        onTap: () => setState(() => _filter = 'Estoque Baixo'),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Vencendo',
                        isSelected: _filter == 'Vencendo',
                        color: Colors.amber,
                        onTap: () => setState(() => _filter = 'Vencendo'),
                      ),
                    ],
                  ),
                ),
              ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, size: 28),
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
    String statusLabel = 'OK';

    if (stock.isExpired) {
      statusColor = Colors.red;
      statusLabel = 'Vencido';
    } else if (stock.isExpiringSoon) {
      statusColor = const Color(0xFFFFA726);
      statusLabel = 'Vencendo';
    } else if (stock.isLowStock) {
      statusColor = const Color(0xFFFFA726);
      statusLabel = 'Estoque abaixo';
    }

    // Cor do ícone baseado no tipo
    Color iconColor = Colors.orange;
    if (stock.medicationType.toLowerCase().contains('ampola')) {
      iconColor = Colors.orange;
    } else if (stock.medicationType.toLowerCase().contains('frasco')) {
      iconColor = Colors.red;
    }

    final typeName = stock.medicationType.toLowerCase();
    final isLiquid = (typeName == 'ampola' || typeName == 'frasco') && stock.quantityPerUnit != null;
    final totalVolume = isLiquid 
        ? (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity 
        : stock.totalQuantity;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: InkWell(
        onTap: () => _showDetailsDialog(stock),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.medication_liquid, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.medicationName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${stock.medicationType} • ${stock.quantityPerUnit?.toStringAsFixed(1) ?? ''} ml/un',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (statusLabel != 'OK')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Quantidade
              Text(
                isLiquid
                    ? '${stock.totalQuantity.toStringAsFixed(0)} ${typeName}${stock.totalQuantity > 1 ? 's' : ''} (${totalVolume.toStringAsFixed(0)} ml total)'
                    : '${stock.totalQuantity.toStringAsFixed(0)} ${stock.unitOfMeasure}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              // Frasco aberto
              if (stock.openedQuantity > 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Abertos: ${stock.openedQuantity.toStringAsFixed(1)} ml',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Barra de progresso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (stock.totalQuantity / ((stock.minStockAlert ?? 5) * 2)).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        stock.isLowStock ? statusColor : Colors.green,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estoque ${((stock.totalQuantity / ((stock.minStockAlert ?? 5) * 2)) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      if (stock.expirationDate != null)
                        Text(
                          'Validade: ${stock.expirationDate!.day.toString().padLeft(2, '0')}/${stock.expirationDate!.month.toString().padLeft(2, '0')}/${stock.expirationDate!.year}',
                          style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                ],
              ),
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
