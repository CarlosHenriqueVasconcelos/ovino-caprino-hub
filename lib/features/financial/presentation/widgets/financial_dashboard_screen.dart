import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/financial_account.dart';
import '../../../../services/financial_service.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/app_empty_state.dart';
import '../../../../shared/widgets/common/metric_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';

class FinancialDashboardScreen extends StatefulWidget {
  const FinancialDashboardScreen({super.key});

  @override
  FinancialDashboardScreenState createState() =>
      FinancialDashboardScreenState();
}

class FinancialDashboardScreenState extends State<FinancialDashboardScreen> {
  Map<String, dynamic> stats = {};
  List<FinancialAccount> upcomingAccounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> reload() => _loadData();

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final service = context.read<FinancialService>();
    await service.generateRecurringAccounts();
    await service.updateOverdueStatus();

    final dashboardStats = await service.getDashboardStats();
    final upcoming = await service.getUpcomingAccounts(7);

    if (!mounted) return;
    setState(() {
      stats = dashboardStats;
      upcomingAccounts = upcoming;
      isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  StatusChipVariant _statusVariant(String status) {
    switch (status) {
      case 'Pago':
        return StatusChipVariant.success;
      case 'Vencido':
        return StatusChipVariant.danger;
      case 'Pendente':
        return StatusChipVariant.warning;
      case 'Cancelado':
        return StatusChipVariant.neutral;
      default:
        return StatusChipVariant.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final balance = (stats['balance'] as num?)?.toDouble() ?? 0.0;
    final totalUpcoming = (stats['totalUpcoming'] as num?)?.toDouble() ?? 0.0;
    final totalOverdue = (stats['totalOverdue'] as num?)?.toDouble() ?? 0.0;
    final totalPending = (stats['totalPending'] as num?)?.toDouble() ?? 0.0;
    final totalRevenue = (stats['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final totalExpense = (stats['totalExpense'] as num?)?.toDouble() ?? 0.0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SectionHeader(
            title: 'Resumo Financeiro',
            subtitle: 'Indicadores consolidados do período atual',
            action: TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Atualizar'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int columns = 1;
              if (width >= 1024) {
                columns = 3;
              } else if (width >= 640) {
                columns = 2;
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: columns == 1 ? 2.3 : 2.0,
                children: [
                  MetricCard(
                    title: 'Saldo do mês',
                    value: _formatCurrency(balance),
                    subtitle: balance >= 0 ? 'Positivo' : 'Negativo',
                    icon: Icons.account_balance_wallet_outlined,
                    accentColor: balance >= 0 ? AppColors.success : AppColors.error,
                  ),
                  MetricCard(
                    title: 'A vencer (7 dias)',
                    value: _formatCurrency(totalUpcoming),
                    icon: Icons.event_available_outlined,
                    accentColor: AppColors.warning,
                  ),
                  MetricCard(
                    title: 'Contas vencidas',
                    value: _formatCurrency(totalOverdue),
                    icon: Icons.warning_amber_rounded,
                    accentColor: AppColors.error,
                  ),
                  MetricCard(
                    title: 'Total pendente',
                    value: _formatCurrency(totalPending),
                    icon: Icons.pending_actions_outlined,
                    accentColor: AppColors.primarySupport,
                  ),
                  MetricCard(
                    title: 'Receitas do mês',
                    value: _formatCurrency(totalRevenue),
                    icon: Icons.arrow_upward,
                    accentColor: AppColors.success,
                  ),
                  MetricCard(
                    title: 'Despesas do mês',
                    value: _formatCurrency(totalExpense),
                    icon: Icons.arrow_downward,
                    accentColor: AppColors.error,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            variant: AppCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Próximas Contas',
                  subtitle: 'Compromissos previstos para os próximos 7 dias',
                  action: Icon(Icons.schedule_outlined, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (upcomingAccounts.isEmpty)
                  const AppEmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: 'Sem contas para os próximos 7 dias',
                    description: 'Quando houver vencimentos próximos, eles aparecerão aqui.',
                  )
                else
                  ...upcomingAccounts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final account = entry.value;
                    final isRevenue = account.type == 'receita';
                    final amountColor = isRevenue ? AppColors.success : AppColors.error;

                    return Container(
                      margin: EdgeInsets.only(
                        top: AppSpacing.xs,
                        bottom: index == upcomingAccounts.length - 1 ? 0 : AppSpacing.xs,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.borderNeutral.withValues(alpha: 0.75),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: amountColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isRevenue
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 18,
                              color: amountColor,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.description ?? account.category,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_formatDate(account.dueDate)} • ${account.category}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatCurrency(account.amount),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: amountColor,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              StatusChip(
                                label: account.status,
                                variant: _statusVariant(account.status),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
