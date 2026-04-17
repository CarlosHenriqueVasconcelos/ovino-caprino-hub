import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/pharmacy_stock.dart';
import '../../../services/pharmacy_service.dart';
import 'widgets/pharmacy_stock_details.dart';
import 'widgets/pharmacy_stock_form.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kBrand50 = Color(0xFFE8F5EE);
const _kBeige = Color(0xFFF6F5F1);
const _kSurface = Color(0xFFFBFBF8);
const _kGold = Color(0xFFD9B15F);
const _kGold50 = Color(0xFFFBF4E6);
const _kErr = Color(0xFFC94A4A);
const _kErr50 = Color(0xFFFAEAEA);
const _kBlue = Color(0xFF3A7EC4);
const _kBlue50 = Color(0xFFEBF3FB);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kBorder = Color(0xFFE6E4DC);

class PharmacyManagementScreen extends StatefulWidget {
  const PharmacyManagementScreen({super.key});

  @override
  State<PharmacyManagementScreen> createState() =>
      _PharmacyManagementScreenState();
}

class _PharmacyManagementScreenState extends State<PharmacyManagementScreen> {
  List<PharmacyStock> _stock = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String _filter = 'Todos';
  String _searchQuery = '';
  String _sortBy = 'name'; // name, quantity, expiration
  bool _sortAscending = true;

  // Paginação
  int _currentPage = 0;
  final int _itemsPerPage = 50;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _loadStock();
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
      final nextPage = _currentPage + 1;
      final pharmacyService =
          Provider.of<PharmacyService>(context, listen: false);
      final pageData = await pharmacyService.getPharmacyStock(
        limit: _itemsPerPage,
        offset: nextPage * _itemsPerPage,
      );
      if (!mounted) return;
      setState(() {
        _stock.addAll(pageData);
        _currentPage = nextPage;
        _hasMore = pageData.length == _itemsPerPage;
      });
    } catch (_) {
      // mantém estado atual em caso de erro
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStock() async {
    setState(() => _isLoading = true);
    try {
      final pharmacyService =
          Provider.of<PharmacyService>(context, listen: false);
      final stock = await pharmacyService.getPharmacyStock(
        limit: _itemsPerPage,
        offset: 0,
      );
      setState(() {
        _stock = stock;
        _currentPage = 0;
        _hasMore = stock.length == _itemsPerPage;
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
      filtered = filtered
          .where((s) => s.medicationName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Aplicar filtro
    switch (_filter) {
      case 'Estoque Baixo':
        filtered = filtered.where((s) => s.isLowStock && !s.isExpired).toList();
        break;
      case 'Vencendo':
        filtered =
            filtered.where((s) => s.isExpiringSoon && !s.isExpired).toList();
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

  @override
  Widget build(BuildContext context) {
    final filteredStock = _filterStock();
    return Scaffold(
      backgroundColor: _kBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 96),
          child: Column(
            children: [
              _buildModernHeader(),
              const SizedBox(height: 10),
              _buildModernKpiRow(),
              const SizedBox(height: 10),
              _buildModernSearchBar(),
              const SizedBox(height: 8),
              _buildModernFilterChips(),
              const SizedBox(height: 8),
              _buildModernSortRow(filteredStock.length),
              const SizedBox(height: 8),
              _buildModernStockCollection(filteredStock),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
        backgroundColor: _kBrand,
      ),
    );
  }

  Widget _buildModernHeader() {
    final isMobile = MediaQuery.of(context).size.width < 680;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _kBrand50,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: _kBrand,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farmácia',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _kText,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Estoque de Medicamentos',
                        style: TextStyle(
                          fontSize: 10,
                          color: _kText3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            OutlinedButton.icon(
              onPressed: _loadStock,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Recarregar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kText2,
                side: BorderSide(color: _kBorder.withValues(alpha: 0.95)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          FilledButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Novo'),
            style: FilledButton.styleFrom(
              backgroundColor: _kBrand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          if (isMobile) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: _loadStock,
              icon: const Icon(Icons.refresh, size: 18),
              color: _kText2,
              tooltip: 'Recarregar',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernKpiRow() {
    final total = _stock.length;
    final lowStock = _stock.where((s) => s.isLowStock && !s.isExpired).length;
    final expiring =
        _stock.where((s) => s.isExpiringSoon && !s.isExpired).length;

    return Row(
      children: [
        Expanded(
          child: _buildModernKpiCard(
            icon: Icons.inventory_2_outlined,
            iconBg: _kBlue50,
            iconColor: _kBlue,
            value: '$total',
            valueColor: _kBlue,
            label: 'Produtos',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _buildModernKpiCard(
            icon: Icons.warning_amber_rounded,
            iconBg: _kGold50,
            iconColor: _kGold,
            value: '$lowStock',
            valueColor: _kGold,
            label: 'Est. baixo',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _buildModernKpiCard(
            icon: Icons.event_busy_outlined,
            iconBg: _kErr50,
            iconColor: _kErr,
            value: '$expiring',
            valueColor: _kErr,
            label: 'Vencendo',
          ),
        ),
      ],
    );
  }

  Widget _buildModernKpiCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 13, color: iconColor),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: _kText2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() {
          _searchQuery = value;
          _currentPage = 0;
        }),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, size: 18, color: _kText3),
          hintText: 'Buscar por nome ou apresentação…',
          hintStyle: const TextStyle(fontSize: 12, color: _kText3),
          isDense: true,
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilterChips() {
    final filters = ['Todos', 'Estoque Baixo', 'Vencendo', 'Vencidos'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final label = filters[index];
          final active = _filter == label;
          final tone = label == 'Estoque Baixo'
              ? _kGold
              : (label == 'Vencendo' || label == 'Vencidos')
                  ? _kErr
                  : _kBrand;
          return ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: active ? Colors.white : _kText2,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            selected: active,
            onSelected: (_) => setState(() {
              _filter = label;
              _currentPage = 0;
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: active ? tone : _kBorder.withValues(alpha: 0.85),
              ),
            ),
            backgroundColor: _kSurface,
            selectedColor: tone,
            showCheckmark: false,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }

  Widget _buildModernSortRow(int filteredCount) {
    final sortLabel = switch (_sortBy) {
      'quantity' => 'Estoque',
      'expiration' => 'Validade',
      _ => 'Nome',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Text(
            '$filteredCount produto${filteredCount == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 11,
              color: _kText3,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'name', child: Text('Ordenar por nome')),
              PopupMenuItem(value: 'quantity', child: Text('Ordenar por estoque')),
              PopupMenuItem(value: 'expiration', child: Text('Ordenar por validade')),
            ],
            child: Row(
              children: [
                const Icon(Icons.sort, size: 14, color: _kBrand),
                const SizedBox(width: 4),
                Text(
                  '$sortLabel ${_sortAscending ? '↑' : '↓'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kBrand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: _sortAscending ? 'Crescente' : 'Decrescente',
            onPressed: () => setState(() => _sortAscending = !_sortAscending),
            iconSize: 16,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: _kBrand,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStockCollection(List<PharmacyStock> filteredStock) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredStock.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_pharmacy_outlined, size: 52, color: _kText3),
            SizedBox(height: 10),
            Text(
              'Nenhum medicamento encontrado',
              style: TextStyle(fontSize: 14, color: _kText2),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isList = width < 780;
        final itemCount = filteredStock.length + (_isLoadingMore ? 1 : 0);

        if (isList) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= filteredStock.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _buildModernStockCard(filteredStock[index]);
            },
          );
        }

        final columns = width >= 1240 ? 3 : 2;
        final aspect = width >= 1240 ? 1.58 : 1.43;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: aspect,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            if (index >= filteredStock.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildModernStockCard(filteredStock[index]);
          },
        );
      },
    );
  }

  Widget _buildModernStockCard(PharmacyStock stock) {
    final tone = _toneForStock(stock);
    final unit = stock.unitOfMeasure.toLowerCase();
    final useVolumeLogic = (unit == 'ml' || unit == 'mg' || unit == 'g') &&
        stock.quantityPerUnit != null &&
        stock.quantityPerUnit! > 0;
    final totalVolume = useVolumeLogic
        ? (stock.totalQuantity * stock.quantityPerUnit!) + stock.openedQuantity
        : stock.totalQuantity;
    final percent = (stock.totalQuantity / ((stock.minStockAlert ?? 5) * 2))
        .clamp(0.0, 1.0);
    final percentLabel = '${(percent * 100).round()}%';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => _showDetailsDialog(stock),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 10, 11, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: tone.iconBackground,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _stockTypeIcon(stock),
                              size: 16,
                              color: tone.iconColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stock.medicationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _kText,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${stock.medicationType} · '
                                  '${stock.quantityPerUnit != null ? '${stock.quantityPerUnit!.toStringAsFixed(1).replaceAll('.', ',')} ${stock.unitOfMeasure}/un' : stock.unitOfMeasure}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: _kText2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: tone.badgeBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tone.label,
                              style: TextStyle(
                                fontSize: 8,
                                color: tone.badgeTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Estoque',
                            style: TextStyle(
                              fontSize: 9,
                              color: _kText3,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            percentLabel,
                            style: TextStyle(
                              fontSize: 9,
                              color: tone.barColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 4,
                          backgroundColor: Colors.black.withValues(alpha: 0.06),
                          valueColor: AlwaysStoppedAnimation<Color>(tone.barColor),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 12,
                                  color: _kText3,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Validade',
                                  style: TextStyle(fontSize: 9, color: _kText3),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    stock.expirationDate != null
                                        ? _formatDateShort(stock.expirationDate!)
                                        : 'Sem validade',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: tone.expirationColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.category_outlined,
                                  size: 12,
                                  color: _kText3,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Tipo',
                                  style: TextStyle(fontSize: 9, color: _kText3),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    stock.medicationType,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: _kText2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (useVolumeLogic) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${stock.totalQuantity.toStringAsFixed(0)} unidade${stock.totalQuantity != 1 ? 's' : ''}'
                          ' (${totalVolume.toStringAsFixed(1).replaceAll('.', ',')} ${stock.unitOfMeasure} total)',
                          style: const TextStyle(fontSize: 9, color: _kText2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showRemoveQuantityDialog(stock),
                    icon: const Icon(Icons.remove, size: 14),
                    label: const Text('Remover'),
                    style: TextButton.styleFrom(
                      foregroundColor: _kErr,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: Colors.black.withValues(alpha: 0.06),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showAddQuantityDialog(stock),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Adicionar'),
                    style: TextButton.styleFrom(
                      foregroundColor: _kBrand,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  IconData _stockTypeIcon(PharmacyStock stock) {
    final type = stock.medicationType.toLowerCase();
    if (type.contains('ampola')) return Icons.vaccines_outlined;
    if (type.contains('frasco')) return Icons.medication_liquid_outlined;
    return Icons.medication_outlined;
  }

  _ModernStockTone _toneForStock(PharmacyStock stock) {
    if (stock.isExpired) {
      return const _ModernStockTone(
        label: 'Vencido',
        iconBackground: _kErr50,
        iconColor: _kErr,
        badgeBackground: _kErr50,
        badgeTextColor: _kErr,
        borderColor: Color(0x44C94A4A),
        barColor: _kErr,
        expirationColor: _kErr,
      );
    }
    if (stock.isExpiringSoon) {
      return const _ModernStockTone(
        label: 'Vencendo',
        iconBackground: _kErr50,
        iconColor: _kErr,
        badgeBackground: _kErr50,
        badgeTextColor: _kErr,
        borderColor: Color(0x44C94A4A),
        barColor: _kGold,
        expirationColor: _kErr,
      );
    }
    if (stock.isLowStock) {
      return const _ModernStockTone(
        label: 'Est. baixo',
        iconBackground: _kGold50,
        iconColor: _kGold,
        badgeBackground: _kGold50,
        badgeTextColor: Color(0xFF7A5C00),
        borderColor: Color(0x55D9B15F),
        barColor: _kGold,
        expirationColor: _kText2,
      );
    }
    return const _ModernStockTone(
      label: 'OK',
      iconBackground: _kBrand50,
      iconColor: _kBrand,
      badgeBackground: _kBrand50,
      badgeTextColor: _kBrand,
      borderColor: _kBorder,
      barColor: _kBrand,
      expirationColor: _kBrand,
    );
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _showAddDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => PharmacyStockForm(onSaved: _loadStock),
    );
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
    final isLiquid = (typeName == 'ampola' || typeName == 'frasco') &&
        stock.quantityPerUnit != null;
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
                helperText: isLiquid
                    ? '${stock.quantityPerUnit!.toStringAsFixed(1)} ml por $unitLabel'
                    : null,
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

              try {
                // Enviar apenas o número de unidades, não multiplicar por ML
                final pharmacyService =
                    Provider.of<PharmacyService>(context, listen: false);
                await pharmacyService.addToStock(
                  stock.id,
                  units.toDouble(),
                  reason: reasonController.text.isEmpty
                      ? null
                      : reasonController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                  if (isLiquid) {
                    final totalMl =
                        (units * stock.quantityPerUnit!).toStringAsFixed(0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Adicionado: $units $unitLabel${units != 1 ? 's' : ''} ($totalMl ml)')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Adicionado: $units ${stock.unitOfMeasure}')),
                    );
                  }
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
    final isLiquid = (typeName == 'ampola' || typeName == 'frasco') &&
        stock.quantityPerUnit != null;
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
                helperText: isLiquid
                    ? '${stock.quantityPerUnit!.toStringAsFixed(1)} ml por $unitLabel'
                    : null,
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
                  SnackBar(
                      content: Text(
                          'Quantidade maior que o estoque disponível (${stock.totalQuantity.toInt()} $unitLabel${stock.totalQuantity != 1 ? 's' : ''})')),
                );
                return;
              }

              try {
                // Enviar apenas o número de unidades, não multiplicar por ML
                // medication_id deve ser null quando não está associado a uma aplicação
                final pharmacyService =
                    Provider.of<PharmacyService>(context, listen: false);
                await pharmacyService.deductFromStock(
                  stock.id,
                  units.toDouble(),
                  null, // Passar null como medicationId pois não é uma aplicação em animal
                );
                if (context.mounted) {
                  Navigator.pop(context, true);
                  if (isLiquid) {
                    final totalMl =
                        (units * stock.quantityPerUnit!).toStringAsFixed(0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Removido: $units $unitLabel${units != 1 ? 's' : ''} ($totalMl ml)')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Removido: $units ${stock.unitOfMeasure}')),
                    );
                  }
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

class _ModernStockTone {
  final String label;
  final Color iconBackground;
  final Color iconColor;
  final Color badgeBackground;
  final Color badgeTextColor;
  final Color borderColor;
  final Color barColor;
  final Color expirationColor;

  const _ModernStockTone({
    required this.label,
    required this.iconBackground,
    required this.iconColor,
    required this.badgeBackground,
    required this.badgeTextColor,
    required this.borderColor,
    required this.barColor,
    required this.expirationColor,
  });
}
