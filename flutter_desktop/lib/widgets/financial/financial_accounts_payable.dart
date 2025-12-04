import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/financial_service.dart';
import '../../models/financial_account.dart';
import 'package:intl/intl.dart';
import 'financial_form.dart';

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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Todos', label: Text('Todos')),
                    ButtonSegment(value: 'Pendente', label: Text('Pendente')),
                    ButtonSegment(value: 'Pago', label: Text('Pago')),
                    ButtonSegment(value: 'Vencido', label: Text('Vencido')),
                  ],
                  selected: {filterStatus},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      filterStatus = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
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
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredAccounts.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma despesa encontrada',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            isThreeLine: true,
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.withValues(alpha: 0.2),
                              child: const Icon(Icons.arrow_downward,
                                  color: Colors.red),
                            ),
                            title:
                                Text(account.description ?? account.category),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Vencimento: ${_formatDate(account.dueDate)}'),
                                if (account.supplierCustomer != null)
                                  Text(
                                      'Fornecedor: ${account.supplierCustomer}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrency(account.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(account.status)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    account.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getStatusColor(account.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _showAccountActions(account),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAccountActions(FinancialAccount account) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pago':
        return Colors.green;
      case 'Vencido':
        return Colors.red;
      case 'Pendente':
        return Colors.orange;
      case 'Cancelado':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
