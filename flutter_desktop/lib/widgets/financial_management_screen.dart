import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../services/supabase_service.dart';
import 'financial_form.dart';

class FinancialManagementScreen extends StatefulWidget {
  const FinancialManagementScreen({super.key});

  @override
  State<FinancialManagementScreen> createState() => _FinancialManagementScreenState();
}

class _FinancialManagementScreenState extends State<FinancialManagementScreen> {
  List<Map<String, dynamic>> _financialRecords = [];
  bool _isLoading = true;
  String _selectedType = 'Todos';
  String _selectedPeriod = 'Este Mês';

  final List<String> _types = ['Todos', 'receita', 'despesa'];
  final List<String> _periods = ['Esta Semana', 'Este Mês', 'Este Ano'];

  @override
  void initState() {
    super.initState();
    _loadFinancialRecords();
  }

  Future<void> _loadFinancialRecords() async {
    setState(() => _isLoading = true);
    try {
      _financialRecords = await SupabaseService.getFinancialRecords();
    } catch (e) {
      print('Error loading financial records: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredRecords {
    return _financialRecords.where((record) {
      final typeMatch = _selectedType == 'Todos' || 
                       record['type'] == _selectedType;
      
      // Period filter (simplified)
      final recordDate = DateTime.tryParse(record['date'] ?? '') ?? DateTime.now();
      final now = DateTime.now();
      bool periodMatch = true;
      
      switch (_selectedPeriod) {
        case 'Esta Semana':
          final weekAgo = now.subtract(const Duration(days: 7));
          periodMatch = recordDate.isAfter(weekAgo);
          break;
        case 'Este Mês':
          periodMatch = recordDate.month == now.month && recordDate.year == now.year;
          break;
        case 'Este Ano':
          periodMatch = recordDate.year == now.year;
          break;
      }
      
      return typeMatch && periodMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Controle Financeiro',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _showFinancialForm(),
                          icon: const Icon(Icons.add),
                          label: const Text('Nova Transação'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gerencie receitas e despesas, controle custos de produção e acompanhe '
                      'a rentabilidade do seu rebanho de ovinos e caprinos.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Financial Summary
            _buildFinancialSummary(theme),
            const SizedBox(height: 24),

            // Filters Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtros',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        // Type Filter
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tipo:',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _types.map((type) {
                                  return FilterChip(
                                    label: Text(type == 'receita' ? 'Receita' : 
                                               type == 'despesa' ? 'Despesa' : type),
                                    selected: type == _selectedType,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedType = type;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        
                        // Period Filter
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Período:',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _periods.map((period) {
                                  return FilterChip(
                                    label: Text(period),
                                    selected: period == _selectedPeriod,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedPeriod = period;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Financial Records List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Transações',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_filteredRecords.length} de ${_financialRecords.length} registros',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_filteredRecords.isEmpty)
                      _buildEmptyState(theme)
                    else
                      _buildFinancialList(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(ThemeData theme) {
    if (_financialRecords.isEmpty) return const SizedBox.shrink();
    
    final filteredRecords = _filteredRecords;
    final revenues = filteredRecords
        .where((r) => r['type'] == 'receita')
        .fold(0.0, (sum, r) => sum + (r['amount'] as num).toDouble());
        
    final expenses = filteredRecords
        .where((r) => r['type'] == 'despesa')
        .fold(0.0, (sum, r) => sum + (r['amount'] as num).toDouble());
        
    final balance = revenues - expenses;
    
    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo Financeiro - $_selectedPeriod',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    title: 'Receitas',
                    value: revenues,
                    icon: Icons.trending_up,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    title: 'Despesas',
                    value: expenses,
                    icon: Icons.trending_down,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    title: 'Saldo',
                    value: balance,
                    icon: balance >= 0 ? Icons.account_balance : Icons.warning,
                    color: balance >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, {
    required String title,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _financialRecords.isEmpty ? 'Nenhuma transação registrada' : 'Nenhuma transação encontrada',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _financialRecords.isEmpty 
                ? 'Registre receitas e despesas para controlar a rentabilidade'
                : 'Ajuste os filtros para encontrar transações',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showFinancialForm(),
              icon: const Icon(Icons.add),
              label: Text(_financialRecords.isEmpty ? 'Primeira Transação' : 'Nova Transação'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialList(ThemeData theme) {
    // Sort records by date (newest first)
    final sortedRecords = List<Map<String, dynamic>>.from(_filteredRecords);
    sortedRecords.sort((a, b) {
      final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedRecords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final isRevenue = record['type'] == 'receita';
        
        Color typeColor = isRevenue ? theme.colorScheme.tertiary : theme.colorScheme.error;
        IconData typeIcon = isRevenue ? Icons.trending_up : Icons.trending_down;
        
        Color categoryColor;
        IconData categoryIcon;
        switch (record['category']) {
          case 'Venda de Animais':
            categoryColor = theme.colorScheme.primary;
            categoryIcon = Icons.pets;
            break;
          case 'Produtos (Leite, Lã)':
            categoryColor = theme.colorScheme.tertiary;
            categoryIcon = Icons.production_quantity_limits;
            break;
          case 'Alimentação':
            categoryColor = theme.colorScheme.secondary;
            categoryIcon = Icons.restaurant;
            break;
          case 'Medicamentos':
            categoryColor = theme.colorScheme.error;
            categoryIcon = Icons.medical_services;
            break;
          case 'Equipamentos':
            categoryColor = theme.colorScheme.outline;
            categoryIcon = Icons.build;
            break;
          default:
            categoryColor = theme.colorScheme.outline;
            categoryIcon = Icons.category;
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(typeIcon, color: typeColor),
            ),
            title: Text(
              record['description'] ?? 'Sem descrição',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(categoryIcon, size: 14, color: categoryColor),
                    const SizedBox(width: 4),
                    Text(
                      record['category'] ?? '-',
                      style: TextStyle(color: categoryColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text('Data: ${record['date'] ?? '-'}'),
                if (record['animal_id'] != null)
                  Consumer<AnimalService>(
                    builder: (context, animalService, _) {
                      final animal = animalService.animals
                          .where((a) => a.id == record['animal_id'])
                          .firstOrNull;
                      return Text(
                        animal != null ? 'Animal: ${animal.name} (${animal.code})' : 'Animal: Não encontrado',
                      );
                    },
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isRevenue ? '+' : '-'} R\$ ${(record['amount'] as num).toStringAsFixed(2).replaceAll('.', ',')}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    isRevenue ? 'Receita' : 'Despesa',
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFinancialForm() {
    showDialog(
      context: context,
      builder: (context) => const FinancialFormDialog(),
    ).then((_) => _loadFinancialRecords());
  }
}