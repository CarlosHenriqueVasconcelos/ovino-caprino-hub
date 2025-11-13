import 'package:flutter/material.dart';
import 'financial_dashboard_screen.dart';
import 'financial_accounts_payable.dart';
import 'financial_accounts_receivable.dart';
import 'financial_recurring.dart';
import 'financial_cash_flow.dart';

class FinancialCompleteScreen extends StatefulWidget {
  const FinancialCompleteScreen({super.key});

  @override
  State<FinancialCompleteScreen> createState() =>
      _FinancialCompleteScreenState();
}

class _FinancialCompleteScreenState extends State<FinancialCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // PIN do módulo Financeiro (defina aqui)
  static const String _kFinancePin = 'Spetovino2025';
  bool _unlocked = false;
  bool _checkingLock = true;

  final GlobalKey<FinancialDashboardScreenState> _dashboardKey =
      GlobalKey<FinancialDashboardScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Recarrega ao chegar na aba 0 por swipe
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 0) {
        _refreshDashboard();
      }
    });

    // Pede senha e, se liberar, força o reload do Dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkFinanceLock();
      if (mounted && _unlocked) {
        _refreshDashboard();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshDashboard() {
    _dashboardKey.currentState?.reload();
  }

  Future<void> _checkFinanceLock() async {
    if (_kFinancePin.isEmpty) {
      if (!mounted) return;
      setState(() {
        _unlocked = true;
        _checkingLock = false;
      });
      return;
    }

    final ok = await _askForPin(_kFinancePin);
    if (!mounted) return;
    setState(() {
      _unlocked = ok == true;
      _checkingLock = false;
    });
    // NÃO dar pop() se cancelar — deixamos a tela com painel de bloqueio
  }

  Future<bool?> _askForPin(String expected) async {
    String input = '';
    String? error;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Área Financeira'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Digite a senha para acessar.'),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: true,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      errorText: error,
                    ),
                    onChanged: (v) => input = v,
                    onSubmitted: (_) {
                      if (input == expected) {
                        Navigator.pop(ctx, true);
                      } else {
                        setState(
                            () => error = 'Senha incorreta. Tente novamente.');
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(ctx, false), // apenas fecha o diálogo
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (input == expected) {
                      Navigator.pop(ctx, true);
                    } else {
                      setState(
                          () => error = 'Senha incorreta. Tente novamente.');
                    }
                  },
                  child: const Text('Entrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _promptUnlock() async {
    final ok = await _askForPin(_kFinancePin);
    if (!mounted) return;
    if (ok == true) {
      setState(() => _unlocked = true);
      _refreshDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLock) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Se não desbloqueou (cancelou/errou), mostra PAINEL DE BLOQUEIO (sem tela preta)
    if (!_unlocked) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Financeiro'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 72),
              const SizedBox(height: 12),
              const Text('Área financeira bloqueada'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _promptUnlock,
                icon: const Icon(Icons.lock_open),
                label: const Text('Desbloquear'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) {
            if (index == 0) _refreshDashboard(); // tocar no Dashboard recarrega
          },
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'A Pagar'),
            Tab(text: 'A Receber'),
            Tab(text: 'Recorrentes'),
            Tab(text: 'Fluxo de Caixa'),
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
        ],
      ),
    );
  }
}
