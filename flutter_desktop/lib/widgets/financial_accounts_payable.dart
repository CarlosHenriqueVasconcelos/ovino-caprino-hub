import 'package:flutter/material.dart';
import '../services/financial_service.dart';
import '../models/financial_account.dart';
import 'package:intl/intl.dart';
import 'financial_form.dart';

class FinancialAccountsPayable extends StatefulWidget {
  final VoidCallback? onUpdate;

  const FinancialAccountsPayable({super.key, this.onUpdate});

  @override
  State<FinancialAccountsPayable> createState() => _FinancialAccountsPayableState();
}

class _FinancialAccountsPayableState extends State<FinancialAccountsPayable> {
  final FinancialService _financialService = FinancialService();
  List<FinancialAccount> accounts = [];
  String filterStatus = 'Todos';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => isLoading = true);
    
    final allAccounts = await _financialService.getAllAccounts();
    final filtered = allAccounts
        .where((a) => a.type == 'despesa')
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    
    setState(() {
      accounts = filtered;
      isLoading = false;
    });
  }

  List<FinancialAccount> get filteredAccounts {
    if (filterStatus == 'Todos') return accounts;
    return accounts.where((a) => a.status == filterStatus).toList();
  }

  Future<void> _markAsPaid(FinancialAccount account) async {
    await _financialService.markAsPaid(account.id, DateTime.now());
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
      await _financialService.deleteAccount(account.id);
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

  @override
  Widget build(BuildContext context) {
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
                      builder: (context) => const FinancialFormScreen(type: 'despesa'),
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
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = filteredAccounts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.withOpacity(0.2),
                              child: const Icon(Icons.arrow_downward, color: Colors.red),
                            ),
                            title: Text(account.description ?? account.category),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vencimento: ${_formatDate(account.dueDate)}'),
                                if (account.supplierCustomer != null)
                                  Text('Fornecedor: ${account.supplierCustomer}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrency(account.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(account.status).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    account.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getStatusColor(account.status),
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
