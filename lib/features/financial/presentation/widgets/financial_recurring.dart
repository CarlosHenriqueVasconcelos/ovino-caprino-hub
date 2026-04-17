import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/financial_account.dart';
import '../../../../services/financial_service.dart';
import 'financial_form.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kBrand50 = Color(0xFFE8F5EE);
const _kSurface = Color(0xFFFBFBF8);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kErr = Color(0xFFC94A4A);
const _kErr50 = Color(0xFFFAEAEA);

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

  Color _typeColor(String type) => type == 'receita' ? _kBrand : _kErr;
  Color _typeBg(String type) => type == 'receita' ? _kBrand50 : _kErr50;
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
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder.withValues(alpha: 0.95)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lançamentos Recorrentes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Controle automático de contas periódicas',
                  style: TextStyle(
                    fontSize: 10,
                    color: _kText3,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _addRecurring,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Nova recorrente'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kBrand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_recurringAccounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder.withValues(alpha: 0.95)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.repeat, color: _kText3),
                  const SizedBox(height: 8),
                  const Text(
                    'Nenhuma recorrência cadastrada',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cadastre uma conta recorrente para automatizar lançamentos periódicos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: _kText3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _addRecurring,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Cadastrar recorrência'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _kBrand,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._recurringAccounts.map((account) {
              final color = _typeColor(account.type);
              final bg = _typeBg(account.type);
              final icon = _typeIcon(account.type);

              return Container(
                margin: const EdgeInsets.only(bottom: 7),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.description ?? account.category,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Frequência: ${account.recurrenceFrequency ?? '-'}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kText2,
                            ),
                          ),
                          Text(
                            'Base: ${_date(account.dueDate)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kText2,
                            ),
                          ),
                          if (account.recurrenceEndDate != null)
                            Text(
                              'Até: ${_date(account.recurrenceEndDate!)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: _kText2,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _money(account.amount),
                          style: TextStyle(
                            fontSize: 14,
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Excluir recorrência',
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: _kText3,
                          ),
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
