import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/financial_account.dart';
import '../../../../services/financial_service.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/app_empty_state.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../shared/widgets/common/status_chip.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'financial_form.dart';

class FinancialAccountsPayable extends StatefulWidget {
  final VoidCallback? onUpdate;

  const FinancialAccountsPayable({super.key, this.onUpdate});

  @override
  State<FinancialAccountsPayable> createState() =>
      _FinancialAccountsPayableState();
}

class _FinancialAccountsPayableState extends State<FinancialAccountsPayable> {
  List<FinancialAccount> accounts = [];
  String filterStatus = 'Todos';
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = false;
  int page = 0;
  static const int _pageSize = 50;
  late final ScrollController _scrollController;

  FinancialService get _service => context.read<FinancialService>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _loadAccounts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => isLoading = true);

    final pageData = await _service.getAccountsPage(
      type: 'despesa',
      status: filterStatus == 'Todos' ? null : filterStatus,
      limit: _pageSize,
      offset: 0,
      ascending: true,
    );

    setState(() {
      accounts = pageData;
      page = 0;
      hasMore = pageData.length == _pageSize;
      isLoading = false;
    });
  }

  List<FinancialAccount> get filteredAccounts {
    if (filterStatus == 'Todos') return accounts;
    return accounts.where((a) => a.status == filterStatus).toList();
  }

  Future<void> _markAsPaid(FinancialAccount account) async {
    await _service.markAsPaid(account.id, DateTime.now());
    await _loadAccounts();
    widget.onUpdate?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta marcada como paga')),
      );
    }
  }

  Future<void> _deleteAccount(FinancialAccount account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteAccount(account.id);
      await _loadAccounts();
      widget.onUpdate?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta excluída com sucesso')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || isLoadingMore || !hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;
    setState(() => isLoadingMore = true);
    try {
      final nextPage = page + 1;
      final pageData = await _service.getAccountsPage(
        type: 'despesa',
        status: filterStatus == 'Todos' ? null : filterStatus,
        limit: _pageSize,
        offset: nextPage * _pageSize,
        ascending: true,
      );
      if (!mounted) return;
      setState(() {
        accounts.addAll(pageData);
        page = nextPage;
        hasMore = pageData.length == _pageSize;
      });
    } catch (_) {
      // mantém estado atual em caso de erro
    } finally {
      if (mounted) setState(() => isLoadingMore = false);
    }
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
    final loaderExtra = (isLoadingMore || hasMore) ? 1 : 0;
    final itemCount = filteredAccounts.length + loaderExtra;

    return Column(
      children: [
        Padding(
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
                const SectionHeader(
                  title: 'Contas a Pagar',
                  subtitle: 'Despesas pendentes, vencidas e quitadas',
                  action: Icon(Icons.arrow_downward, color: AppColors.error),
                ),
                const SizedBox(height: AppSpacing.xs),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 760;
                    final segments = SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Todos', label: Text('Todos')),
                          ButtonSegment(value: 'Pendente', label: Text('Pendente')),
                          ButtonSegment(value: 'Pago', label: Text('Pago')),
                          ButtonSegment(value: 'Vencido', label: Text('Vencido')),
                        ],
                        selected: {filterStatus},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            filterStatus = newSelection.first;
                          });
                          _loadAccounts();
                        },
                      ),
                    );

                    final addButton = PrimaryButton(
                      label: 'Adicionar',
                      icon: Icons.add,
                      fullWidth: isCompact,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FinancialFormScreen(type: 'despesa'),
                          ),
                        );
                        _loadAccounts();
                        widget.onUpdate?.call();
                      },
                    );

                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          segments,
                          const SizedBox(height: AppSpacing.sm),
                          addButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: segments),
                        const SizedBox(width: AppSpacing.sm),
                        addButton,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredAccounts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: AppEmptyState(
                        title: 'Nenhuma despesa encontrada',
                        description: 'Cadastre uma conta para começar o controle financeiro.',
                        icon: Icons.receipt_long_outlined,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if ((isLoadingMore || hasMore) &&
                            index >= filteredAccounts.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final account = filteredAccounts[index];
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          variant: AppCardVariant.elevated,
                          onTap: () => _showAccountActions(account),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_downward,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.description ?? account.category,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Vencimento: ${_formatDate(account.dueDate)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppColors.textSecondary),
                                    ),
                                    if (account.supplierCustomer != null &&
                                        account.supplierCustomer!.trim().isNotEmpty)
                                      Text(
                                        'Fornecedor: ${account.supplierCustomer}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: AppColors.textSecondary),
                                      ),
                                    const SizedBox(height: AppSpacing.xxs),
                                    StatusChip(
                                      label: account.status,
                                      variant: _statusVariant(account.status),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  const Icon(
                                    Icons.more_horiz,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAccountActions(FinancialAccount account) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (account.status != 'Pago')
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Marcar como Pago'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsPaid(account);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinancialFormScreen(
                      type: 'despesa',
                      account: account,
                    ),
                  ),
                );
                _loadAccounts();
                widget.onUpdate?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(context);
                _deleteAccount(account);
              },
            ),
          ],
        ),
      ),
    );
  }
}
