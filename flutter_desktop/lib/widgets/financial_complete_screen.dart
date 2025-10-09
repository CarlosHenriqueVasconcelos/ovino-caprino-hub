import 'package:flutter/material.dart';
import 'financial_dashboard_screen.dart';
import 'financial_accounts_payable.dart';
import 'financial_accounts_receivable.dart';
import 'financial_cost_centers.dart';
import 'financial_budgets.dart';
import 'financial_recurring.dart';
import 'financial_cash_flow.dart';

class FinancialCompleteScreen extends StatefulWidget {
  const FinancialCompleteScreen({super.key});

  @override
  State<FinancialCompleteScreen> createState() => _FinancialCompleteScreenState();
}

class _FinancialCompleteScreenState extends State<FinancialCompleteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_FinancialCompleteScreenState> _dashboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshDashboard() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'A Pagar'),
            Tab(text: 'A Receber'),
            Tab(text: 'Recorrentes'),
            Tab(text: 'Fluxo de Caixa'),
            Tab(text: 'Centros de Custo'),
            Tab(text: 'Orçamentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FinancialDashboardScreen(key: _dashboardKey),
          FinancialAccountsPayable(onUpdate: _refreshDashboard),
          FinancialAccountsReceivable(onUpdate: _refreshDashboard),
          const FinancialRecurringScreen(),
          const FinancialCashFlowScreen(),
          FinancialCostCentersScreen(onUpdate: _refreshDashboard),
          FinancialBudgetsScreen(onUpdate: _refreshDashboard),
        ],
      ),
    );
  }
}
