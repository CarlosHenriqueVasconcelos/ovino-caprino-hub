import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/financial_account.dart';
import '../../../../services/financial_service.dart';
import 'financial_form.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kSurface = Color(0xFFFBFBF8);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kErr = Color(0xFFC94A4A);
const _kErr50 = Color(0xFFFAEAEA);
const _kGold50 = Color(0xFFFBF4E6);

class FinancialAccountsPayable extends StatefulWidget {
  final VoidCallback? onUpdate;

  const FinancialAccountsPayable({super.key, this.onUpdate});

  @override
  State<FinancialAccountsPayable> createState() =>
      _FinancialAccountsPayableState();
}

class _FinancialAccountsPayableState extends State<FinancialAccountsPayable> {
  List<FinancialAccount> accounts = [];
  String filterStatus = 'Todos';
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = false;
  int page = 0;
  static const int _pageSize = 50;
  late final ScrollController _scrollController;

  FinancialService get _service => context.read<FinancialService>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _loadAccounts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => isLoading = true);

    final pageData = await _service.getAccountsPage(
      type: 'despesa',
      status: filterStatus == 'Todos' ? null : filterStatus,
      limit: _pageSize,
      offset: 0,
      ascending: true,
    );

    setState(() {
      accounts = pageData;
      page = 0;
      hasMore = pageData.length == _pageSize;
      isLoading = false;
    });
  }

  List<FinancialAccount> get filteredAccounts {
    if (filterStatus == 'Todos') return accounts;
    return accounts.where((a) => a.status == filterStatus).toList();
  }

  Future<void> _markAsPaid(FinancialAccount account) async {
    await _service.markAsPaid(account.id, DateTime.now());
    await _loadAccounts();
    widget.onUpdate?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta marcada como paga')),
      );
    }
  }

  Future<void> _deleteAccount(FinancialAccount account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteAccount(account.id);
      await _loadAccounts();
      widget.onUpdate?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta excluída com sucesso')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || isLoadingMore || !hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;
    setState(() => isLoadingMore = true);
    try {
      final nextPage = page + 1;
      final pageData = await _service.getAccountsPage(
        type: 'despesa',
        status: filterStatus == 'Todos' ? null : filterStatus,
        limit: _pageSize,
        offset: nextPage * _pageSize,
        ascending: true,
      );
      if (!mounted) return;
      setState(() {
        accounts.addAll(pageData);
        page = nextPage;
        hasMore = pageData.length == _pageSize;
      });
    } catch (_) {
      // mantém estado atual em caso de erro
    } finally {
      if (mounted) setState(() => isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaderExtra = (isLoadingMore || hasMore) ? 1 : 0;
    final itemCount = filteredAccounts.length + loaderExtra;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder.withValues(alpha: 0.95)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Contas a Pagar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.arrow_downward, size: 14, color: _kErr),
                        SizedBox(width: 4),
                        Text(
                          'Despesas',
                          style: TextStyle(
                            color: _kErr,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos'),
                      _buildFilterChip('Pendente'),
                      _buildFilterChip('Pago'),
                      _buildFilterChip('Vencido'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FinancialFormScreen(type: 'despesa'),
                        ),
                      );
                      _loadAccounts();
                      widget.onUpdate?.call();
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nova despesa'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kBrand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredAccounts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if ((isLoadingMore || hasMore) &&
                            index >= filteredAccounts.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final account = filteredAccounts[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showAccountActions(account),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 7),
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: _kSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _kBorder.withValues(alpha: 0.9),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _kText.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: _kErr50,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.arrow_downward,
                                    color: _kErr,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.description ?? account.category,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _kText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Vencimento: ${_formatDate(account.dueDate)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: _kText2,
                                        ),
                                      ),
                                      Text(
                                        'Fornecedor: ${account.supplierCustomer?.trim().isNotEmpty == true ? account.supplierCustomer : 'não informado'}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: _kText2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _buildStatusBadge(account.status),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatCurrency(account.amount),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: _kErr,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Icon(
                                      Icons.more_horiz,
                                      size: 18,
                                      color: _kText3,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final selected = filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          if (filterStatus == label) return;
          setState(() {
            filterStatus = label;
          });
          _loadAccounts();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected ? _kBrand : _kSurface,
            border: Border.all(
              color: selected ? _kBrand : _kBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : _kText2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF2F1ED);
    Color fg = _kText2;

    if (status == 'Pendente') {
      bg = _kGold50;
      fg = const Color(0xFF7A5C00);
    } else if (status == 'Pago') {
      bg = const Color(0xFFE8F5EE);
      fg = _kBrand;
    } else if (status == 'Vencido') {
      bg = _kErr50;
      fg = _kErr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder.withValues(alpha: 0.95)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, color: _kText3),
            SizedBox(height: 8),
            Text(
              'Nenhuma despesa encontrada',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _kText,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Cadastre uma conta para começar o controle financeiro.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: _kText3),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountActions(FinancialAccount account) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (account.status != 'Pago')
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Marcar como Pago'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsPaid(account);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinancialFormScreen(
                      type: 'despesa',
                      account: account,
                    ),
                  ),
                );
                _loadAccounts();
                widget.onUpdate?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(context);
                _deleteAccount(account);
              },
            ),
          ],
        ),
      ),
    );
  }
}
