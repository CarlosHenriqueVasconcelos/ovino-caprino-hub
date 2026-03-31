import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/financial_account.dart';
import '../../../../services/financial_service.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/app_empty_state.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'financial_form.dart';

class FinancialRecurringScreen extends StatefulWidget {
  const FinancialRecurringScreen({super.key});

  @override
  State<FinancialRecurringScreen> createState() =>
      _FinancialRecurringScreenState();
}

class _FinancialRecurringScreenState extends State<FinancialRecurringScreen> {
  List<FinancialAccount> _recurringAccounts = [];
  bool _isLoading = true;

  FinancialService get _service => context.read<FinancialService>();

  @override
  void initState() {
    super.initState();
    _loadRecurringAccounts();
  }

  Future<void> _loadRecurringAccounts() async {
    setState(() => _isLoading = true);
    try {
      await _service.generateRecurringAccounts();
      await _service.updateOverdueStatus();
      final mothers = await _service.getRecurringMothers();

      if (!mounted) return;
      setState(() {
        _recurringAccounts = mothers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addRecurring() async {
    final startedAt = DateTime.now();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FinancialFormScreen(type: 'despesa'),
      ),
    );

    final all = await _service.getAllAccounts();

    FinancialAccount? candidate;
    for (final a in all) {
      final isMotherCandidate = (a.parentId == null) && !a.isRecurring;
      if (!isMotherCandidate) continue;

      final created = a.createdAt;
      final afterStart =
          created.isAfter(startedAt.subtract(const Duration(seconds: 1)));

      if (candidate == null) {
        if (afterStart) candidate = a;
      } else {
        final candCreated = candidate.createdAt;
        if (created.isAfter(candCreated)) {
          candidate = a;
        }
      }
    }

    if (candidate != null) {
      final mother = candidate.copyWith(
        isRecurring: true,
        recurrenceFrequency: candidate.recurrenceFrequency ?? 'Mensal',
        parentId: null,
        updatedAt: DateTime.now(),
      );
      await _service.updateAccount(mother);
      await _service.generateRecurringAccounts();
    }

    await _loadRecurringAccounts();
  }

  Future<void> _deleteRecurring(FinancialAccount account) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir recorrente'),
        content: Text(
          'Tem certeza que deseja excluir a recorrência '
          '"${account.description ?? account.category}"?\n\n'
          'Todas as ocorrências geradas (filhas) também serão removidas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _service.deleteRecurringCascade(account.id);
    await _loadRecurringAccounts();
  }

  String _money(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
  String _date(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Color _typeColor(String type) =>
      type == 'receita' ? AppColors.success : AppColors.error;
  IconData _typeIcon(String type) =>
      type == 'receita' ? Icons.arrow_upward : Icons.arrow_downward;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadRecurringAccounts,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            variant: AppCardVariant.soft,
            child: SectionHeader(
              title: 'Lançamentos Recorrentes',
              subtitle: 'Controle automático de contas periódicas',
              action: PrimaryButton(
                label: 'Nova recorrente',
                icon: Icons.add,
                onPressed: _addRecurring,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_recurringAccounts.isEmpty)
            AppEmptyState(
              icon: Icons.repeat,
              title: 'Nenhuma recorrência cadastrada',
              description:
                  'Cadastre uma conta recorrente para automatizar lançamentos periódicos.',
              action: PrimaryButton(
                label: 'Cadastrar recorrência',
                icon: Icons.add,
                onPressed: _addRecurring,
              ),
            )
          else
            ..._recurringAccounts.map((account) {
              final color = _typeColor(account.type);
              final icon = _typeIcon(account.type);

              return AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                variant: AppCardVariant.elevated,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 18),
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
                            'Frequência: ${account.recurrenceFrequency ?? '-'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          Text(
                            'Base: ${_date(account.dueDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          if (account.recurrenceEndDate != null)
                            Text(
                              'Até: ${_date(account.recurrenceEndDate!)}',
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
                          _money(account.amount),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        IconButton(
                          tooltip: 'Excluir recorrência',
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _deleteRecurring(account),
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
}
