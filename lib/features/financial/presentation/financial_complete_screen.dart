import 'package:flutter/material.dart';

import '../../../shared/widgets/buttons/ghost_button.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/app_brand_header.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/financial_accounts_payable.dart';
import 'widgets/financial_accounts_receivable.dart';
import 'widgets/financial_cash_flow.dart';
import 'widgets/financial_dashboard_screen.dart';
import 'widgets/financial_form.dart';
import 'widgets/financial_recurring.dart';

class FinancialCompleteScreen extends StatefulWidget {
  const FinancialCompleteScreen({super.key});

  @override
  State<FinancialCompleteScreen> createState() =>
      _FinancialCompleteScreenState();
}

class _FinancialCompleteScreenState extends State<FinancialCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const String _kFinancePin = 'Spetovino2025';
  bool _unlocked = false;
  bool _checkingLock = true;

  final GlobalKey<FinancialDashboardScreenState> _dashboardKey =
      GlobalKey<FinancialDashboardScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 0) {
        _refreshDashboard();
      }
      if (mounted) {
        setState(() {});
      }
    });

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

  Future<void> _openQuickCreate() async {
    final type = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo lançamento',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Escolha o tipo de conta para abrir o formulário.',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  leading: const Icon(Icons.arrow_upward, color: AppColors.success),
                  title: const Text('Receita'),
                  subtitle: const Text('Entrada financeira'),
                  onTap: () => Navigator.pop(ctx, 'receita'),
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_downward, color: AppColors.error),
                  title: const Text('Despesa'),
                  subtitle: const Text('Saída financeira'),
                  onTap: () => Navigator.pop(ctx, 'despesa'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || type == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinancialFormScreen(type: type),
      ),
    );

    if (!mounted) return;
    _refreshDashboard();
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
  }

  Future<bool?> _askForPin(String expected) async {
    String input = '';
    String? error;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isMobile = MediaQuery.of(ctx).size.width < 600;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? AppSpacing.md : 40,
                vertical: AppSpacing.xl,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                        size: 34,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Área Financeira',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isMobile
                            ? 'Digite a senha para continuar.'
                            : 'Digite a senha para acessar os dados financeiros.',
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        autofocus: true,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          errorText: error,
                          isDense: isMobile,
                        ),
                        onChanged: (v) => input = v,
                        onSubmitted: (_) {
                          if (input == expected) {
                            Navigator.pop(ctx, true);
                          } else {
                            setState(() {
                              error = 'Senha incorreta. Tente novamente.';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: GhostButton(
                              label: 'Cancelar',
                              onPressed: () => Navigator.pop(ctx, false),
                              fullWidth: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Entrar',
                              onPressed: () {
                                if (input == expected) {
                                  Navigator.pop(ctx, true);
                                } else {
                                  setState(() {
                                    error = 'Senha incorreta. Tente novamente.';
                                  });
                                }
                              },
                              fullWidth: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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

  String get _currentTabLabel {
    switch (_tabController.index) {
      case 0:
        return 'Visão geral do caixa e pendências';
      case 1:
        return 'Despesas e compromissos financeiros';
      case 2:
        return 'Receitas previstas e recebimentos';
      case 3:
        return 'Lançamentos recorrentes ativos';
      case 4:
        return 'Projeção e tendência de fluxo';
      default:
        return 'Módulo financeiro';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLock) {
      return const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const AppBrandHeader(
                title: 'Fazenda São Petrônio',
                subtitle: 'Gestão de Ovinos e Caprinos',
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      );
    }

    if (!_unlocked) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const AppBrandHeader(
                title: 'Fazenda São Petrônio',
                subtitle: 'Gestão de Ovinos e Caprinos',
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppCard(
                      variant: AppCardVariant.elevated,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 56,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Área financeira bloqueada',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Desbloqueie para visualizar contas, fluxo de caixa e relatórios do módulo.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PrimaryButton(
                            label: 'Desbloquear',
                            icon: Icons.lock_open,
                            fullWidth: true,
                            onPressed: _promptUnlock,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const SliverToBoxAdapter(
              child: AppBrandHeader(
                title: 'Fazenda São Petrônio',
                subtitle: 'Gestão de Ovinos e Caprinos',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: AppCard(
                  variant: AppCardVariant.soft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Gestão Financeira',
                        subtitle: _currentTabLabel,
                        action: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GhostButton(
                              label: 'Atualizar visão',
                              icon: Icons.refresh,
                              onPressed: _refreshDashboard,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            PrimaryButton(
                              label: 'Novo',
                              icon: Icons.add,
                              onPressed: _openQuickCreate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        onTap: (index) {
                          if (index == 0) _refreshDashboard();
                        },
                        tabs: const [
                          Tab(text: 'Dashboard'),
                          Tab(text: 'A Pagar'),
                          Tab(text: 'A Receber'),
                          Tab(text: 'Recorrentes'),
                          Tab(text: 'Fluxo de Caixa'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
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
      ),
    );
  }
}
