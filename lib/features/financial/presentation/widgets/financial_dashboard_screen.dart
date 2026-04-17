import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/financial_account.dart';
import '../../../../services/financial_service.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kBrand50 = Color(0xFFE8F5EE);
const _kGold = Color(0xFFD9B15F);
const _kGold50 = Color(0xFFFBF4E6);
const _kErr = Color(0xFFC94A4A);
const _kErr50 = Color(0xFFFAEAEA);
const _kBlue = Color(0xFF3A7EC4);
const _kBlue50 = Color(0xFFEBF3FB);
const _kSurface = Color(0xFFFBFBF8);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kBorder = Color(0xFFE6E4DC);

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

    // Writes devem ser sequenciais (updateOverdue depende de generateRecurring)
    await service.generateRecurringAccounts();
    await service.updateOverdueStatus();

    // Reads independentes — rodam em paralelo
    final fStats    = service.getDashboardStats();
    final fUpcoming = service.getUpcomingAccounts(7);
    final dashboardStats = await fStats;
    final upcoming       = await fUpcoming;

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

  String _statusLabel(String status) {
    switch (status) {
      case 'Pago':
        return 'Pago';
      case 'Vencido':
        return 'Vencido';
      case 'Pendente':
        return 'Pendente';
      case 'Cancelado':
        return 'Cancelado';
      default:
        return status;
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
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kBrand,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo do mês',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(balance),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      balance >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      balance >= 0
                          ? 'Positivo · visão consolidada'
                          : 'Negativo · revisar despesas',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Resumo do período',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loadData,
                style: TextButton.styleFrom(
                  foregroundColor: _kBrand,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text('atualizar'),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final isTablet = constraints.maxWidth >= 640;
              final columns = isWide ? 3 : (isTablet ? 2 : 2);

              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 7,
                mainAxisSpacing: 7,
                childAspectRatio: isWide ? 1.9 : 1.65,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildKpiCard(
                    icon: Icons.calendar_month,
                    iconBg: _kGold50,
                    iconColor: _kGold,
                    label: 'A vencer (7 dias)',
                    value: _formatCurrency(totalUpcoming),
                    valueColor: _kGold,
                  ),
                  _buildKpiCard(
                    icon: Icons.error_outline,
                    iconBg: _kErr50,
                    iconColor: _kErr,
                    label: 'Contas vencidas',
                    value: _formatCurrency(totalOverdue),
                    valueColor: _kErr,
                  ),
                  _buildKpiCard(
                    icon: Icons.pending_actions,
                    iconBg: _kBlue50,
                    iconColor: _kBlue,
                    label: 'Total pendente',
                    value: _formatCurrency(totalPending),
                    valueColor: _kBlue,
                  ),
                  _buildKpiCard(
                    icon: Icons.trending_up,
                    iconBg: _kBrand50,
                    iconColor: _kBrand,
                    label: 'Receitas do mês',
                    value: _formatCurrency(totalRevenue),
                    valueColor: _kBrand,
                  ),
                  _buildKpiCard(
                    icon: Icons.trending_down,
                    iconBg: _kErr50,
                    iconColor: _kErr,
                    label: 'Despesas do mês',
                    value: _formatCurrency(totalExpense),
                    valueColor: _kErr,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Próximas contas · 7 dias',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (upcomingAccounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.calendar_month_outlined, color: _kText3),
                  SizedBox(height: 8),
                  Text(
                    'Sem contas para os próximos 7 dias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _kText,
                    ),
                  ),
                ],
              ),
            )
          else
            ...upcomingAccounts.asMap().entries.map((entry) {
              final index = entry.key;
              final account = entry.value;
              final isRevenue = account.type == 'receita';
              final amountColor = isRevenue ? _kBrand : _kErr;

              return Container(
                margin: EdgeInsets.only(bottom: index == upcomingAccounts.length - 1 ? 0 : 7),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
                  boxShadow: [
                    BoxShadow(
                      color: _kText.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isRevenue ? _kBrand50 : _kErr50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isRevenue ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.description ?? account.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kText,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isRevenue
                                ? 'Cliente: ${account.supplierCustomer?.trim().isNotEmpty == true ? account.supplierCustomer : 'não informado'}'
                                : 'Fornecedor: ${account.supplierCustomer?.trim().isNotEmpty == true ? account.supplierCustomer : 'não informado'}',
                            style: const TextStyle(fontSize: 10, color: _kText2),
                          ),
                          const SizedBox(height: 3),
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: amountColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(account.dueDate),
                          style: const TextStyle(fontSize: 10, color: _kText3),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: _kText.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _kText3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: valueColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    late final Color bg;
    late final Color fg;

    switch (status) {
      case 'Pago':
        bg = _kBrand50;
        fg = _kBrand;
        break;
      case 'Vencido':
        bg = _kErr50;
        fg = _kErr;
        break;
      case 'Pendente':
        bg = _kGold50;
        fg = const Color(0xFF7A5C00);
        break;
      default:
        bg = const Color(0xFFF2F1ED);
        fg = _kText2;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
