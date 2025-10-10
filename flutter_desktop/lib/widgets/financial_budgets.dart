import 'package:flutter/material.dart';
import '../services/financial_service.dart';
import '../models/financial_account.dart';

class FinancialBudgetsScreen extends StatefulWidget {
  final VoidCallback? onUpdate;

  const FinancialBudgetsScreen({super.key, this.onUpdate});

  @override
  State<FinancialBudgetsScreen> createState() => _FinancialBudgetsScreenState();
}

class _FinancialBudgetsScreenState extends State<FinancialBudgetsScreen> {
  List<Budget> _budgets = [];
  List<CostCenter> _costCenters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final budgets = await FinancialService.getAllBudgets();
      final costCenters = await FinancialService.getAllCostCenters();
      setState(() {
        _budgets = budgets;
        _costCenters = costCenters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar orçamentos: $e')),
        );
      }
    }
  }

  Future<void> _showBudgetForm({Budget? budget}) async {
    final categoryController = TextEditingController(text: budget?.category ?? '');
    final amountController = TextEditingController(text: budget?.amount.toString() ?? '');
    String period = budget?.period ?? 'Mensal';
    String? costCenter = budget?.costCenter;
    int year = budget?.year ?? DateTime.now().year;
    int? month = budget?.month;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(budget == null ? 'Novo Orçamento' : 'Editar Orçamento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Valor *',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: period,
                  decoration: const InputDecoration(
                    labelText: 'Período *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Mensal', 'Trimestral', 'Anual']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => period = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Ano *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: year.toString()),
                  onChanged: (value) {
                    year = int.tryParse(value) ?? DateTime.now().year;
                  },
                ),
                if (period == 'Mensal') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: month,
                    decoration: const InputDecoration(
                      labelText: 'Mês *',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(value: m, child: Text(m.toString())))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => month = value);
                    },
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: costCenter,
                  decoration: const InputDecoration(
                    labelText: 'Centro de Custo',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Nenhum')),
                    ..._costCenters.map((cc) => DropdownMenuItem(
                          value: cc.id,
                          child: Text(cc.name),
                        )),
                  ],
                  onChanged: (value) {
                    setDialogState(() => costCenter = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoryController.text.isEmpty || amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha os campos obrigatórios')),
                  );
                  return;
                }

                final budgetData = Budget(
                  id: budget?.id ?? '',
                  category: categoryController.text,
                  amount: double.tryParse(amountController.text) ?? 0,
                  period: period,
                  year: year,
                  month: period == 'Mensal' ? month : null,
                  costCenter: costCenter,
                  createdAt: budget?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  if (budget == null) {
                    await FinancialService.createBudget(budgetData);
                  } else {
                    await FinancialService.updateBudget(budgetData);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          budget == null ? 'Orçamento criado' : 'Orçamento atualizado',
                        ),
                      ),
                    );
                    _loadData();
                    widget.onUpdate?.call();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: $e')),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBudget(Budget budget) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este orçamento?'),
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
        await FinancialService.deleteBudget(budget.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Orçamento excluído')),
          );
        }
        _loadData();
        widget.onUpdate?.call();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  Future<Map<String, double>> _getBudgetProgress(Budget budget) async {
    final analysis = await FinancialService.getBudgetAnalysis(
      budget.category,
      budget.year,
      budget.month,
    );
    final percentage = (analysis['spent'] / budget.amount) * 100;
    return {
      'spent': analysis['spent'],
      'percentage': percentage > 100 ? 100 : percentage,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Orçamentos e Metas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBudgetForm(),
                icon: const Icon(Icons.add),
                label: const Text('Novo Orçamento'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _budgets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pie_chart, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum orçamento cadastrado',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _budgets.length,
                  itemBuilder: (context, index) {
                    final budget = _budgets[index];
                    return FutureBuilder<Map<String, double>>(
                      future: _getBudgetProgress(budget),
                      builder: (context, snapshot) {
                        final spent = snapshot.data?['spent'] ?? 0;
                        final percentage = snapshot.data?['percentage'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            budget.category,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${budget.period} - ${budget.month != null ? '${budget.month}/' : ''}${budget.year}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showBudgetForm(budget: budget),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteBudget(budget),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Gasto: R\$ ${spent.toStringAsFixed(2)}'),
                                    Text('Orçado: R\$ ${budget.amount.toStringAsFixed(2)}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[300],
                                  color: percentage > 100 ? Colors.red : Colors.green,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  percentage > 100
                                      ? 'Excedeu em ${(percentage - 100).toStringAsFixed(1)}%'
                                      : '${percentage.toStringAsFixed(1)}% utilizado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
