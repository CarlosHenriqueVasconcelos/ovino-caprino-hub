import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../services/financial_service.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/app_empty_state.dart';
import '../../../../shared/widgets/common/metric_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

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
      final projection =
          await context.read<FinancialService>().getCashFlowProjection(6);
      if (!mounted) return;
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
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_projection.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: AppEmptyState(
          icon: Icons.trending_up,
          title: 'Sem dados para projeção',
          description: 'Cadastre contas e recorrências para visualizar a tendência de caixa.',
        ),
      );
    }

    final totalRevenue = _projection.fold<double>(
      0,
      (sum, item) => sum + (item['revenue'] as num).toDouble(),
    );
    final totalExpense = _projection.fold<double>(
      0,
      (sum, item) => sum + (item['expense'] as num).toDouble(),
    );
    final totalBalance = _projection.fold<double>(
      0,
      (sum, item) => sum + (item['balance'] as num).toDouble(),
    );

    return RefreshIndicator(
      onRefresh: _loadProjection,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            variant: AppCardVariant.soft,
            child: SectionHeader(
              title: 'Fluxo de Caixa',
              subtitle: 'Projeção dos próximos 6 meses',
              action: TextButton.icon(
                onPressed: _loadProjection,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Atualizar'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 960 ? 3 : (width >= 620 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: columns == 1 ? 2.2 : 2.0,
                children: [
                  MetricCard(
                    title: 'Receitas previstas',
                    value: _formatCurrency(totalRevenue),
                    icon: Icons.arrow_upward,
                    accentColor: AppColors.success,
                  ),
                  MetricCard(
                    title: 'Despesas previstas',
                    value: _formatCurrency(totalExpense),
                    icon: Icons.arrow_downward,
                    accentColor: AppColors.error,
                  ),
                  MetricCard(
                    title: 'Saldo projetado',
                    value: _formatCurrency(totalBalance),
                    icon: Icons.balance_outlined,
                    accentColor:
                        totalBalance >= 0 ? AppColors.success : AppColors.error,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            variant: AppCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Detalhamento Mensal',
                  subtitle: 'Receitas, despesas e saldo por mês',
                ),
                const SizedBox(height: AppSpacing.xs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 28,
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Mês',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Receitas',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Despesas',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Saldo',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Text(
                            _formatCurrency(revenue),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                          DataCell(Text(
                            _formatCurrency(expense),
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                          DataCell(Text(
                            _formatCurrency(balance),
                            style: TextStyle(
                              color: balance >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
