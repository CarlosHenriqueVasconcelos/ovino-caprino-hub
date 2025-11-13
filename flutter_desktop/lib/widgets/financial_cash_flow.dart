import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/financial_service.dart';

class FinancialCashFlowScreen extends StatefulWidget {
  const FinancialCashFlowScreen({super.key});

  @override
  State<FinancialCashFlowScreen> createState() =>
      _FinancialCashFlowScreenState();
}

class _FinancialCashFlowScreenState extends State<FinancialCashFlowScreen> {
  List<Map<String, dynamic>> _projection = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjection();
  }

  Future<void> _loadProjection() async {
    setState(() => _isLoading = true);
    try {
      final projection = await FinancialService.getCashFlowProjection(6);
      setState(() {
        _projection = projection;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar projeção: $e')),
        );
      }
    }
  }

  String _formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy', 'pt_BR').format(date);
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_projection.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sem dados para projeção',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Projeção de Fluxo de Caixa (6 meses)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 40,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Mês',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Receitas Previstas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Despesas Previstas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Saldo Projetado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: _projection.map((item) {
                  final month = item['month'] as DateTime;
                  final revenue = (item['revenue'] as num).toDouble();
                  final expense = (item['expense'] as num).toDouble();
                  final balance = (item['balance'] as num).toDouble();

                  return DataRow(
                    cells: [
                      DataCell(Text(
                        _formatMonth(month),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      )),
                      DataCell(Text(
                        _formatCurrency(revenue),
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                        _formatCurrency(expense),
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                        _formatCurrency(balance),
                        style: TextStyle(
                          color: balance >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo da Projeção',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Total Receitas Previstas',
                      _projection.fold<double>(
                        0,
                        (sum, item) =>
                            sum + (item['revenue'] as num).toDouble(),
                      ),
                      Colors.green,
                    ),
                    _buildSummaryRow(
                      'Total Despesas Previstas',
                      _projection.fold<double>(
                        0,
                        (sum, item) =>
                            sum + (item['expense'] as num).toDouble(),
                      ),
                      Colors.red,
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Saldo Projetado Total',
                      _projection.fold<double>(
                        0,
                        (sum, item) =>
                            sum + (item['balance'] as num).toDouble(),
                      ),
                      null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? (value >= 0 ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
