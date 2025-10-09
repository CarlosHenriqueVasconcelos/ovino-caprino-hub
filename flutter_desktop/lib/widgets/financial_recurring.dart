import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/financial_service.dart';
import '../models/financial_account.dart';
import 'financial_form.dart';

class FinancialRecurringScreen extends StatefulWidget {
  const FinancialRecurringScreen({super.key});

  @override
  State<FinancialRecurringScreen> createState() => _FinancialRecurringScreenState();
}

class _FinancialRecurringScreenState extends State<FinancialRecurringScreen> {
  List<FinancialAccount> _recurringAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecurringAccounts();
  }

  Future<void> _loadRecurringAccounts() async {
    setState(() => _isLoading = true);
    try {
      final allAccounts = await FinancialService.getAllAccounts();
      setState(() {
        _recurringAccounts = allAccounts
            .where((a) => a.isRecurring && a.parentId == null)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar despesas recorrentes: $e')),
        );
      }
    }
  }

  Future<void> _deleteRecurring(FinancialAccount account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
          'Deseja realmente excluir esta despesa recorrente?\nIsso não afetará as contas já geradas.',
        ),
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
      try {
        await FinancialService.deleteAccount(account.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Despesa recorrente excluída')),
          );
        }
        _loadRecurringAccounts();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recurringAccounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.loop, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma despesa recorrente cadastrada',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinancialFormScreen(type: 'despesa'),
                  ),
                );
                _loadRecurringAccounts();
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Despesa Recorrente'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FinancialFormScreen(type: 'despesa'),
                    ),
                  );
                  _loadRecurringAccounts();
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova Recorrente'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Categoria')),
                  DataColumn(label: Text('Descrição')),
                  DataColumn(label: Text('Valor')),
                  DataColumn(label: Text('Frequência')),
                  DataColumn(label: Text('Início')),
                  DataColumn(label: Text('Fim')),
                  DataColumn(label: Text('Ações')),
                ],
                rows: _recurringAccounts.map((account) {
                  return DataRow(
                    cells: [
                      DataCell(Text(account.category)),
                      DataCell(Text(account.description ?? '')),
                      DataCell(Text(
                        'R\$ ${account.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(account.recurrenceFrequency ?? 'N/A')),
                      DataCell(Text(_formatDate(account.dueDate))),
                      DataCell(Text(
                        account.recurrenceEndDate != null
                            ? _formatDate(account.recurrenceEndDate!)
                            : 'Indefinido',
                      )),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRecurring(account),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
