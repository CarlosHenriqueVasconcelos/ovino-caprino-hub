import 'package:flutter/material.dart';

import '../../../shared/widgets/buttons/ghost_button.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/financial_accounts_payable.dart';
import 'widgets/financial_accounts_receivable.dart';
import 'widgets/financial_cash_flow.dart';
import 'widgets/financial_dashboard_screen.dart';
import 'widgets/financial_form.dart';
import 'widgets/financial_recurring.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kBeige = Color(0xFFF6F5F1);
const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kText = Color(0xFF22313A);
const _kText3 = Color(0xFF9AABB4);
const _kBorder = Color(0xFFE6E4DC);

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
                  leading:
                      const Icon(Icons.arrow_upward, color: AppColors.success),
                  title: const Text('Receita'),
                  subtitle: const Text('Entrada financeira'),
                  onTap: () => Navigator.pop(ctx, 'receita'),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.arrow_downward, color: AppColors.error),
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

  Widget _buildModernHeader({required bool enabledActions}) {
    final isCompact = MediaQuery.of(context).size.width < 680;

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder.withValues(alpha: 0.95)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestão Financeira',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentTabLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kText3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: enabledActions ? _refreshDashboard : null,
                child: Ink(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _kSurface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
                  ),
                  child: Icon(
                    Icons.refresh,
                    size: 18,
                    color: enabledActions ? _kText : _kText3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: enabledActions ? _openQuickCreate : null,
                icon: const Icon(Icons.add, size: 16),
                label: Text(isCompact ? 'Novo' : 'Novo lançamento'),
                style: FilledButton.styleFrom(
                  backgroundColor: _kBrand,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IgnorePointer(
            ignoring: !enabledActions,
            child: Opacity(
              opacity: enabledActions ? 1 : 0.7,
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  onTap: (index) {
                    if (index == 0) _refreshDashboard();
                  },
                  labelColor: _kBrand,
                  unselectedLabelColor: _kText3,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  indicatorColor: _kBrand,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: const [
                    Tab(text: 'Dashboard'),
                    Tab(text: 'A Pagar'),
                    Tab(text: 'A Receber'),
                    Tab(text: 'Recorrentes'),
                    Tab(text: 'Fluxo de Caixa'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 56,
                color: _kText3.withValues(alpha: 0.9),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Área financeira bloqueada',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Desbloqueie para visualizar contas, fluxo de caixa e relatórios do módulo.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _kText3,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBeige,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: _buildModernHeader(enabledActions: !_checkingLock && _unlocked),
            ),
            if (_checkingLock)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!_unlocked)
              Expanded(child: _buildLockedContent())
            else
              Expanded(
                child: Container(
                  color: _kBeige,
                  child: TabBarView(
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
              ),
          ],
        ),
      ),
    );
  }
}
