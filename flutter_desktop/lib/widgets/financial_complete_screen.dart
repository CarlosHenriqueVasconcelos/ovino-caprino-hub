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
  bool _isUnlocked = false;

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

  Widget _buildPasswordScreen(ThemeData theme) {
    final passwordController = TextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Área Protegida',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Digite a senha para acessar o controle financeiro',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge,
                    decoration: InputDecoration(
                      labelText: 'Senha (1-5)',
                      hintText: 'Digite um número de 1 a 5',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) => _checkPassword(value, theme),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _checkPassword(passwordController.text, theme),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Desbloquear'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkPassword(String password, ThemeData theme) {
    if (password.isEmpty) {
      _showError('Digite a senha');
      return;
    }
    
    final int? pass = int.tryParse(password);
    if (pass == null || pass < 1 || pass > 5) {
      _showError('Senha deve ser um número de 1 a 5');
      return;
    }
    
    // Qualquer número de 1 a 5 desbloqueia
    setState(() {
      _isUnlocked = true;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isUnlocked) {
      return _buildPasswordScreen(theme);
    }

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
