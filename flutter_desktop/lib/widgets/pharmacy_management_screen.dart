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
  bool _sortAscending = true;

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
    var filtered = _stock.toList();
    
    // Aplicar busca
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) => 
        s.medicationName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Aplicar filtro
    switch (_filter) {
      case 'Estoque Baixo':
        filtered = filtered.where((s) => s.isLowStock && !s.isExpired).toList();
        break;
      case 'Vencendo':
        filtered = filtered.where((s) => s.isExpiringSoon && !s.isExpired).toList();
        break;
      case 'Vencidos':
        filtered = filtered.where((s) => s.isExpired).toList();
        break;
      case 'Todos':
        filtered = filtered.where((s) => !s.isExpired).toList();
        break;
    }
    
    // Aplicar ordenação
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) {
          final cmp = a.medicationName.compareTo(b.medicationName);
          return _sortAscending ? cmp : -cmp;
        });
        break;
      case 'quantity':
        filtered.sort((a, b) {
          final cmp = b.totalQuantity.compareTo(a.totalQuantity);
          return _sortAscending ? cmp : -cmp;
        });
        break;
      case 'expiration':
        filtered.sort((a, b) {
          if (a.expirationDate == null) return 1;
          if (b.expirationDate == null) return -1;
          final cmp = a.expirationDate!.compareTo(b.expirationDate!);
          return _sortAscending ? cmp : -cmp;
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              _buildHeader(theme),
              const SizedBox(height: 16),
              // Barra de pesquisa e filtros
              _buildFiltersBar(theme),
              const SizedBox(height: 16),

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
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              int crossAxisCount = 2;
                              if (width >= 1500) crossAxisCount = 4;
                              else if (width >= 1100) crossAxisCount = 3;
                              else if (width <= 700) crossAxisCount = 1;

                              final aspect = crossAxisCount == 1 ? 3.0 : 1.9;

                              return GridView.builder(
                                padding: const EdgeInsets.only(bottom: 96),
                                itemCount: filteredStock.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: aspect,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final stock = filteredStock[index];
                                  return _buildStockCard(stock, theme);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.medical_services_outlined, color: Colors.teal),
        ),
        const SizedBox(width: 10),
        Text(
          'Farmácia — Estoque de Medicamentos',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: _loadStock,
          icon: const Icon(Icons.refresh),
          label: const Text('Recarregar'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add),
          label: const Text('Novo'),
          style: FilledButton.styleFrom(backgroundColor: Colors.teal),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildFiltersBar(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 360,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar por nome ou apresentação…',
              isDense: true,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        ChoiceChip(
          label: const Text('Todos'),
          selected: _filter == 'Todos',
          onSelected: (_) => setState(() => _filter = 'Todos'),
        ),
        ChoiceChip(
          label: const Text('Estoque Baixo'),
          selected: _filter == 'Estoque Baixo',
          onSelected: (_) => setState(() => _filter = 'Estoque Baixo'),
        ),
        ChoiceChip(
          label: const Text('Vencendo'),
          selected: _filter == 'Vencendo',
          onSelected: (_) => setState(() => _filter = 'Vencendo'),
        ),
        ChoiceChip(
          label: const Text('Vencidos'),
          selected: _filter == 'Vencidos',
          onSelected: (_) => setState(() => _filter = 'Vencidos'),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey[400]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ordenar:'),
              const SizedBox(width: 6),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Nome')),
                    DropdownMenuItem(value: 'quantity', child: Text('Estoque')),
                    DropdownMenuItem(value: 'expiration', child: Text('Validade')),
                  ],
                  onChanged: (v) => v == null ? null : setState(() => _sortBy = v),
                ),
              ),
              IconButton(
                tooltip: _sortAscending ? 'Crescente' : 'Decrescente',
                onPressed: () => setState(() => _sortAscending = !_sortAscending),
                icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard(PharmacyStock stock, ThemeData theme) {
    final tags = <Widget>[];
    
    if (stock.isExpired) {
      tags.add(_buildBadge('Vencido', Colors.red));
    }
    if (stock.isExpiringSoon) {
      tags.add(_buildBadge('Vencendo', Colors.orange));
    }
    if (stock.isLowStock) {
      tags.add(_buildBadge('Estoque baixo', Colors.amber));
    }
    if (!stock.isExpired && !stock.isExpiringSoon && !stock.isLowStock) {
      tags.add(_buildBadge('OK', Colors.teal));
    }

    // Ícone baseado no tipo
    IconData icon = Icons.medication_outlined;
    if (stock.medicationType.toLowerCase().contains('ampola')) {
      icon = Icons.vaccines_outlined;
    } else if (stock.medicationType.toLowerCase().contains('frasco')) {
      icon = Icons.medication_liquid_outlined;
    }

    final typeName = stock.medicationType.toLowerCase();
    final isLiquid = (typeName == 'ampola' || typeName == 'frasco') && stock.quantityPerUnit != null;
    final totalVolume = isLiquid 
        ? (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity 
        : stock.totalQuantity;
    
    final percent = (stock.totalQuantity / ((stock.minStockAlert ?? 5) * 2)).clamp(0.0, 1.0);
    final percentLabel = '${(percent * 100).round()}%';

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetailsDialog(stock),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título + tags
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: Icon(icon, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.medicationName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${stock.medicationType}${stock.quantityPerUnit != null ? ' • ${stock.quantityPerUnit!.toStringAsFixed(1).replaceAll('.', ',')} ml/un' : ''}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(spacing: 6, runSpacing: 6, children: tags),
                ],
              ),
              const SizedBox(height: 8),
              // Qtd total
              Flexible(
                child: Text(
                  isLiquid
                      ? '${stock.totalQuantity.toStringAsFixed(0)} ${typeName}${stock.totalQuantity != 1 ? 's' : ''} (${totalVolume.toStringAsFixed(0).replaceAll('.', ',')} ml total)'
                      : '${stock.totalQuantity.toStringAsFixed(0)} ${stock.unitOfMeasure}',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              // Barra de estoque
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(Colors.teal),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Rodapé do card
              Row(
                children: [
                  if (stock.openedQuantity > 0)
                    Flexible(
                      child: Text(
                        'Abertos: ${stock.openedQuantity.toStringAsFixed(1).replaceAll('.', ',')} ml',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    'Estoque $percentLabel',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              if (stock.expirationDate != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Validade: ${stock.expirationDate!.day.toString().padLeft(2, '0')}/${stock.expirationDate!.month.toString().padLeft(2, '0')}/${stock.expirationDate!.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRemoveQuantityDialog(stock),
                      icon: const Icon(Icons.remove, size: 16),
                      label: const Text('Remover', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        minimumSize: const Size(0, 34),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showAddQuantityDialog(stock),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Adicionar', style: TextStyle(fontSize: 13)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        minimumSize: const Size(0, 34),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color tone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w700,
          fontSize: 12,
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

  Future<void> _showAddQuantityDialog(PharmacyStock stock) async {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    final typeName = stock.medicationType.toLowerCase();
    final isLiquid = (typeName == 'ampola' || typeName == 'frasco') && stock.quantityPerUnit != null;
    final unitLabel = isLiquid ? typeName : stock.unitOfMeasure;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar ao Estoque'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.medicationName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (isLiquid) ...[
              const SizedBox(height: 8),
              Text(
                'Estoque atual: ${stock.totalQuantity.toInt()} $unitLabel${stock.totalQuantity != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade de ${unitLabel}s',
                hintText: 'Digite a quantidade',
                border: const OutlineInputBorder(),
                suffixText: unitLabel,
                helperText: isLiquid ? '${stock.quantityPerUnit!.toStringAsFixed(1)} ml por $unitLabel' : null,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ex: Compra, Devolução...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final units = int.tryParse(quantityController.text);
              if (units == null || units <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quantidade inválida')),
                );
                return;
              }

              // Calcular a quantidade em ml se for líquido
              final quantityToAdd = isLiquid ? (units * stock.quantityPerUnit!) : units.toDouble();

              try {
                await PharmacyService.addToStock(
                  stock.id,
                  quantityToAdd,
                  reason: reasonController.text.isEmpty ? null : reasonController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                  final totalMl = isLiquid ? quantityToAdd.toStringAsFixed(0) : '';
                  final msg = isLiquid 
                      ? 'Adicionado: $units $unitLabel${units != 1 ? 's' : ''} ($totalMl ml)'
                      : 'Adicionado: $units ${stock.unitOfMeasure}';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao adicionar: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadStock();
    }
  }

  Future<void> _showRemoveQuantityDialog(PharmacyStock stock) async {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    final typeName = stock.medicationType.toLowerCase();
    final isLiquid = (typeName == 'ampola' || typeName == 'frasco') && stock.quantityPerUnit != null;
    final unitLabel = isLiquid ? typeName : stock.unitOfMeasure;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover do Estoque'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.medicationName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Estoque atual: ${stock.totalQuantity.toInt()} $unitLabel${stock.totalQuantity != 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade de ${unitLabel}s',
                hintText: 'Digite a quantidade',
                border: const OutlineInputBorder(),
                suffixText: unitLabel,
                helperText: isLiquid ? '${stock.quantityPerUnit!.toStringAsFixed(1)} ml por $unitLabel' : null,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ex: Descarte, Vencimento...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final units = int.tryParse(quantityController.text);
              if (units == null || units <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quantidade inválida')),
                );
                return;
              }

              // Verificar se tem unidades suficientes
              if (units > stock.totalQuantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Quantidade maior que o estoque disponível (${stock.totalQuantity.toInt()} $unitLabel${stock.totalQuantity != 1 ? 's' : ''})')),
                );
                return;
              }

              // Calcular a quantidade em ml se for líquido
              final quantityToRemove = isLiquid ? (units * stock.quantityPerUnit!) : units.toDouble();

              try {
                await PharmacyService.deductFromStock(
                  stock.id,
                  quantityToRemove,
                  stock.id,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                  final totalMl = isLiquid ? quantityToRemove.toStringAsFixed(0) : '';
                  final msg = isLiquid 
                      ? 'Removido: $units $unitLabel${units != 1 ? 's' : ''} ($totalMl ml)'
                      : 'Removido: $units ${stock.unitOfMeasure}';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao remover: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadStock();
    }
  }

}
