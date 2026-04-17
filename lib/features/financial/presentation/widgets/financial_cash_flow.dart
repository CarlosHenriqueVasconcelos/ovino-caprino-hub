import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../services/financial_service.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kBrand50 = Color(0xFFE8F5EE);
const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kErr = Color(0xFFC94A4A);
const _kErr50 = Color(0xFFFAEAEA);

class FinancialCashFlowScreen extends StatefulWidget {
  const FinancialCashFlowScreen({super.key});

  @override
  State<FinancialCashFlowScreen> createState() =>
      _FinancialCashFlowScreenState();
}

class _FinancialCashFlowScreenState extends State<FinancialCashFlowScreen> {
  List<Map<String, dynamic>> _projection = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjection();
  }

  Future<void> _loadProjection() async {
    setState(() => _isLoading = true);
    try {
      final projection =
          await context.read<FinancialService>().getCashFlowProjection(6);
      if (!mounted) return;
      setState(() {
        _projection = projection;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar projeção: $e')),
        );
      }
    }
  }

  String _formatMonth(DateTime date) {
    return DateFormat('MMM yyyy', 'pt_BR').format(date);
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatShort(double value) {
    final intValue = value == value.roundToDouble() ? value.toInt() : null;
    if (intValue != null) {
      return 'R\$ ${intValue.toString()}';
    }
    return _formatCurrency(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_projection.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder.withValues(alpha: 0.95)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up, color: _kText3),
              SizedBox(height: 8),
              Text(
                'Sem dados para projeção',
                style: TextStyle(fontWeight: FontWeight.w600, color: _kText),
              ),
              SizedBox(height: 4),
              Text(
                'Cadastre contas e recorrências para visualizar a tendência de caixa.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: _kText3),
              ),
            ],
          ),
        ),
      );
    }

    final totalRevenue = _projection.fold<double>(
      0,
      (sum, item) => sum + (item['revenue'] as num).toDouble(),
    );
    final totalExpense = _projection.fold<double>(
      0,
      (sum, item) => sum + (item['expense'] as num).toDouble(),
    );
    final totalBalance = _projection.fold<double>(
      0,
      (sum, item) => sum + (item['balance'] as num).toDouble(),
    );

    return RefreshIndicator(
      onRefresh: _loadProjection,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Fluxo de Caixa · 6 meses',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loadProjection,
                style: TextButton.styleFrom(
                  foregroundColor: _kBrand,
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                child: const Text('atualizar'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 540;
              if (!twoColumns) {
                return Column(
                  children: [
                    _buildKpiCard(
                      icon: Icons.arrow_upward,
                      iconBg: _kBrand50,
                      iconColor: _kBrand,
                      value: _formatShort(totalRevenue),
                      label: 'Receitas previstas',
                      valueColor: _kBrand,
                    ),
                    const SizedBox(height: 7),
                    _buildKpiCard(
                      icon: Icons.arrow_downward,
                      iconBg: _kErr50,
                      iconColor: _kErr,
                      value: _formatShort(totalExpense),
                      label: 'Despesas previstas',
                      valueColor: _kErr,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      icon: Icons.arrow_upward,
                      iconBg: _kBrand50,
                      iconColor: _kBrand,
                      value: _formatShort(totalRevenue),
                      label: 'Receitas previstas',
                      valueColor: _kBrand,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _buildKpiCard(
                      icon: Icons.arrow_downward,
                      iconBg: _kErr50,
                      iconColor: _kErr,
                      value: _formatShort(totalExpense),
                      label: 'Despesas previstas',
                      valueColor: _kErr,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:
                  totalBalance >= 0 ? _kBrand50.withValues(alpha: 0.8) : _kErr50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: totalBalance >= 0
                    ? _kBrand.withValues(alpha: 0.2)
                    : _kErr.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo projetado',
                        style: TextStyle(
                          fontSize: 10,
                          color: totalBalance >= 0 ? _kBrand : _kErr,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatCurrency(totalBalance),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: totalBalance >= 0 ? _kBrand : _kErr,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: (totalBalance >= 0 ? _kBrand : _kErr)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    totalBalance >= 0 ? Icons.trending_up : Icons.warning_amber,
                    size: 16,
                    color: totalBalance >= 0 ? _kBrand : _kErr,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder.withValues(alpha: 0.95)),
              boxShadow: [
                BoxShadow(
                  color: _kText.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: const BoxDecoration(
                    color: _kSurface2,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 12,
                        child: Text(
                          'Mês',
                          style: TextStyle(
                            color: _kText3,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Receitas',
                            style: TextStyle(
                              color: _kText3,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Despesas',
                            style: TextStyle(
                              color: _kText3,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Saldo',
                            style: TextStyle(
                              color: _kText3,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ..._projection.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final month = item['month'] as DateTime;
                  final revenue = (item['revenue'] as num).toDouble();
                  final expense = (item['expense'] as num).toDouble();
                  final balance = (item['balance'] as num).toDouble();
                  final isAlert = balance < 0;
                  final isLast = index == _projection.length - 1;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAlert ? _kErr50.withValues(alpha: 0.45) : null,
                      border: Border(
                        top: BorderSide(
                          color: _kBorder.withValues(alpha: 0.65),
                        ),
                        bottom: isLast
                            ? BorderSide.none
                            : BorderSide(
                                color: _kBorder.withValues(alpha: 0.35),
                              ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 12,
                          child: Text(
                            _formatMonth(month),
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatShort(revenue),
                              style: TextStyle(
                                fontSize: 11,
                                color: revenue == 0 ? _kText3 : _kBrand,
                                fontWeight:
                                    revenue == 0 ? FontWeight.w500 : FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatShort(expense),
                              style: TextStyle(
                                fontSize: 11,
                                color: expense == 0 ? _kText3 : _kErr,
                                fontWeight:
                                    expense == 0 ? FontWeight.w500 : FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatShort(balance),
                              style: TextStyle(
                                fontSize: 11,
                                color: balance > 0
                                    ? _kBrand
                                    : (balance < 0 ? _kErr : _kText3),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(
            color: _kText.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _kText2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
