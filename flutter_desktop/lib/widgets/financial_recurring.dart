import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/financial_service.dart';
import '../models/financial_account.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRecurringAccounts();
  }

  Future<void> _loadRecurringAccounts() async {
    setState(() => _isLoading = true);
    try {
      // Garante status e próxima ocorrência
      await FinancialService.generateRecurringAccounts();
      await FinancialService.updateOverdueStatus();

      // Carrega SOMENTE as "mães" recorrentes (is_recurring = 1 e parent_id = null)
      final mothers = await FinancialService.getRecurringMothers();

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
    // Marca o tempo antes de abrir o form (para achar o que foi criado agora)
    final startedAt = DateTime.now();

    // Abre o formulário padrão (mantém o design)
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FinancialFormScreen(
          // Nesta tela você está cadastrando RECORRENTES de despesa.
          // Se quiser que seja receita, troque para 'receita'.
          type: 'despesa',
        ),
      ),
    );

    // Ao voltar, se a conta criada não veio marcada como recorrente,
    // promovemos a última criada para MÃE recorrente (is_recurring=1).
    final all = await FinancialService.getAllAccounts();

    FinancialAccount? candidate;
    for (final a in all) {
      // só candidatas que ainda NÃO são recorrentes e não são filhas
      final isMotherCandidate = (a.parentId == null) && !a.isRecurring;
      if (!isMotherCandidate) continue;

      // prioridade: quem tem createdAt mais recente pós startedAt
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
        // Se o form não gravou frequência, definimos um padrão seguro
        recurrenceFrequency: candidate.recurrenceFrequency ?? 'Mensal',
        parentId: null,
        updatedAt: DateTime.now(),
      );
      await FinancialService.updateAccount(mother);
      // Gera a próxima filha (idempotente)
      await FinancialService.generateRecurringAccounts();
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
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm != true) return;

    await FinancialService.deleteRecurringCascade(account.id);
    await _loadRecurringAccounts();
  }

  String _money(num v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
  String _date(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  Color _typeColor(String type) =>
      type == 'receita' ? Colors.green : Colors.red;
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
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(
                'Recorrentes',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addRecurring,
                icon: const Icon(Icons.add),
                label: const Text('Nova recorrente'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recurringAccounts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.loop, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma despesa recorrente cadastrada',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addRecurring,
                      icon: const Icon(Icons.add),
                      label: const Text('Cadastrar'),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._recurringAccounts.map((account) {
              final color = _typeColor(account.type);
              final icon = _typeIcon(account.type);

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(account.description ?? account.category),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Frequência: ${account.recurrenceFrequency ?? '-'}'),
                      Text('Base: ${_date(account.dueDate)}'),
                      if (account.recurrenceEndDate != null)
                        Text('Até: ${_date(account.recurrenceEndDate!)}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _money(account.amount),
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        tooltip: 'Excluir recorrência',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteRecurring(account),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
