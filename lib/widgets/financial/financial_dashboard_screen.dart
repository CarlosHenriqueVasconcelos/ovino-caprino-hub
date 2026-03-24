import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/financial_service.dart';
import '../../models/financial_account.dart';
import 'package:intl/intl.dart';

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

  /// Exposto para ser chamado via GlobalKey<FinancialDashboardScreenState>()
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cards de Estatísticas
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isMobile ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 3.2 : 2.5,
                  children: [
                    _buildStatCard('Saldo do Mês', (stats['balance'] as num?)?.toDouble() ?? 0.0, Icons.account_balance_wallet, ((stats['balance'] as num?)?.toDouble() ?? 0.0) >= 0 ? Colors.green : Colors.red, isMobile),
                    _buildStatCard('A Vencer (7 dias)', (stats['totalUpcoming'] as num?)?.toDouble() ?? 0.0, Icons.schedule, Colors.orange, isMobile),
                    _buildStatCard('Vencidas', (stats['totalOverdue'] as num?)?.toDouble() ?? 0.0, Icons.warning, Colors.red, isMobile),
                    _buildStatCard('Total Pendente', (stats['totalPending'] as num?)?.toDouble() ?? 0.0, Icons.pending, Colors.blue, isMobile),
                    _buildStatCard('Receitas do Mês', (stats['totalRevenue'] as num?)?.toDouble() ?? 0.0, Icons.arrow_upward, Colors.green, isMobile),
                    _buildStatCard('Despesas do Mês', (stats['totalExpense'] as num?)?.toDouble() ?? 0.0, Icons.arrow_downward, Colors.red, isMobile),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Contas a Vencer
            Text(
              'Próximas Contas (7 dias)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            if (upcomingAccounts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Nenhuma conta a vencer nos próximos 7 dias',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ),
              )
            else
              ...upcomingAccounts.map(
                (account) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: account.type == 'receita'
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      child: Icon(
                        account.type == 'receita'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: account.type == 'receita'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(account.description ?? account.category),
                    subtitle: Text(
                      '${_formatDate(account.dueDate)} • ${account.category}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(account.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: account.type == 'receita'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, double value, IconData icon, Color color, bool isMobile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isMobile ? 20 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: isMobile ? 12 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _formatCurrency(value),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: isMobile ? 18 : 24,
                    ),
              ),
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
