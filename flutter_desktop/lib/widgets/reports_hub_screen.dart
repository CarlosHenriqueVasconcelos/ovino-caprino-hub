// lib/widgets/reports_hub_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../services/reports_service.dart';
import '../utils/animal_record_display.dart';
import '../utils/labels_ptbr.dart';

class ReportsHubScreen extends StatefulWidget {
  const ReportsHubScreen({super.key});

  @override
  State<ReportsHubScreen> createState() => _ReportsHubScreenState();
}

class _ReportsHubScreenState extends State<ReportsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ----------------- PIN SOMENTE NA ABA FINANCEIRO -----------------
  static const String _kReportsFinancePin = 'Spetovino2025';
  late final int _financeTabIndex;
  bool _financialUnlocked = false;
  int _lastTabIndex = 0;
  // -----------------------------------------------------------------

  // Period filters
  String _periodPreset = 'last30';
  DateTime _customStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _customEnd = DateTime.now();

  // Contextual filters
  String _speciesFilter = 'Todos';
  String _genderFilter = 'Todos';
  String _statusFilter = 'Todos';
  final String _categoryFilter = 'Todos';
  final String _vaccineTypeFilter = 'Todos';
  String _medicationStatusFilter = 'Todos';

  /// Valores iguais aos salvos no DB
  String _breedingStageFilter = 'Todos';

  String _financialTypeFilter = 'Todos';
  final String _financialCategoryFilter = 'Todos';
  String _notesPriorityFilter = 'Todos';
  String _notesIsReadFilter = 'Todos';

  // Report data
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  // Sorting & Pagination
  String _sortKey = '';
  bool _sortAsc = true;
  int _currentPage = 0;
  static const int _pageSize = 25;

  final List<String> _reportTypes = const [
    'Animais',
    'Pesos',
    'Vacinações',
    'Medicações',
    'Reprodução',
    'Financeiro',
    'Anotações',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _reportTypes.length, vsync: this);
    _financeTabIndex = _reportTypes.indexOf('Financeiro');
    _lastTabIndex = _tabController.index;

    // Bloqueia swipe para Financeiro se não desbloqueado
    _tabController.addListener(() async {
      if (_tabController.indexIsChanging) return;
      final idx = _tabController.index;

      if (idx == _financeTabIndex && !_financialUnlocked) {
        _tabController.index = _lastTabIndex;
        final ok = await _showFinancePinDialog();
        if (ok == true) {
          setState(() => _financialUnlocked = true);
          _tabController.index = _financeTabIndex;
          setState(() {
            _currentPage = 0;
            _sortKey = '';
          });
          await _loadReport();
        }
        return;
      }

      _lastTabIndex = idx;
      setState(() {
        _currentPage = 0;
        _sortKey = '';
      });
      await _loadReport();
    });

    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateRange _getPeriodRange() {
    if (_periodPreset == 'custom') {
      return DateRange(startDate: _customStart, endDate: _customEnd);
    }

    final now = DateTime.now();
    switch (_periodPreset) {
      case 'last7':
        return DateRange(
          startDate: now.subtract(const Duration(days: 7)),
          endDate: now,
        );
      case 'last30':
        return DateRange(
          startDate: now.subtract(const Duration(days: 30)),
          endDate: now,
        );
      case 'last90':
        return DateRange(
          startDate: now.subtract(const Duration(days: 90)),
          endDate: now,
        );
      case 'currentMonth':
        return DateRange(
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case 'currentYear':
        return DateRange(
          startDate: DateTime(now.year, 1, 1),
          endDate: DateTime(now.year, 12, 31, 23, 59, 59),
        );
      default:
        return DateRange(
          startDate: now.subtract(const Duration(days: 30)),
          endDate: now,
        );
    }
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _reportData = null;
    });

    try {
      final period = _getPeriodRange();
      final filters = ReportFilters(
        startDate: period.startDate,
        endDate: period.endDate,
        species: _speciesFilter,
        gender: _genderFilter,
        status: _statusFilter,
        category: _categoryFilter,
        vaccineType: _vaccineTypeFilter,
        medicationStatus: _medicationStatusFilter,
        breedingStage: _breedingStageFilter,
        financialType: _financialTypeFilter,
        financialCategory: _financialCategoryFilter,
        notesPriority: _notesPriorityFilter,
        notesIsRead: _notesIsReadFilter == 'Lidas'
            ? true
            : _notesIsReadFilter == 'Não lidas'
                ? false
                : null,
      );

      Map<String, dynamic> data;
      switch (_reportTypes[_tabController.index]) {
        case 'Animais':
          data = await ReportsService.getAnimalsReport(filters);
          break;
        case 'Pesos':
          data = await ReportsService.getWeightsReport(filters);
          break;
        case 'Vacinações':
          data = await ReportsService.getVaccinationsReport(filters);
          break;
        case 'Medicações':
          data = await ReportsService.getMedicationsReport(filters);
          break;
        case 'Reprodução':
          data = await ReportsService.getBreedingReport(filters);
          break;
        case 'Financeiro':
          data = await ReportsService.getFinancialReport(filters);
          break;
        case 'Anotações':
          data = await ReportsService.getNotesReport(filters);
          break;
        default:
          data = {'summary': {}, 'data': []};
      }

      if (!mounted) return;
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar relatório: $e')),
      );
    }
  }

  Future<bool?> _showFinancePinDialog() async {
    String input = '';
    String? error;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Acesso Protegido'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Digite a senha para acessar os relatórios financeiros:',
                  ),
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
                      if (input == _kReportsFinancePin) {
                        Navigator.pop(ctx, true);
                      } else {
                        setState(
                          () => error = 'Senha incorreta. Tente novamente.',
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (input == _kReportsFinancePin) {
                      Navigator.pop(ctx, true);
                    } else {
                      setState(
                        () => error = 'Senha incorreta. Tente novamente.',
                      );
                    }
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _exportCSV() async {
    if (_reportTypes[_tabController.index] == 'Financeiro' &&
        !_financialUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acesso aos relatórios financeiros bloqueado'),
        ),
      );
      return;
    }

    if (_reportData == null || _reportData!['data'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum dado para exportar')),
      );
      return;
    }

    try {
      final data = _getSortedData();
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum dado para exportar')),
        );
        return;
      }

      final keys = (data.first as Map<String, dynamic>).keys.toList();
      final headers = keys
          .map(ptBrHeader)
          .map((h) => h.contains(',') ? '"$h"' : h)
          .join(',');

      final rows = data.map((row) {
        final r = row as Map<String, dynamic>;
        return keys.map((k) {
          final v = r[k];
          final str = _csvCell(v, key: k);
          return str.contains(',') ? '"$str"' : str;
        }).join(',');
      }).join('\n');

      final csv = '$headers\n$rows';
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final reportType = _reportTypes[_tabController.index].toLowerCase();
      final filename = '${reportType}_$timestamp.csv';

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(csv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV exportado: ${file.path}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar CSV: $e')),
      );
    }
  }

  Future<void> _saveReport() async {
    if (_reportTypes[_tabController.index] == 'Financeiro' &&
        !_financialUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acesso aos relatórios financeiros bloqueado'),
        ),
      );
      return;
    }

    try {
      final period = _getPeriodRange();
      final reportType = _reportTypes[_tabController.index];
      final title =
          '$reportType – ${DateFormat('dd/MM/yyyy').format(period.startDate)} a ${DateFormat('dd/MM/yyyy').format(period.endDate)}';

      final parameters = {
        'report_type': reportType,
        'period_preset': _periodPreset,
        'custom_start': _customStart.toIso8601String(),
        'custom_end': _customEnd.toIso8601String(),
        'filters': {
          'species': _speciesFilter,
          'gender': _genderFilter,
          'status': _statusFilter,
          'category': _categoryFilter,
          'vaccine_type': _vaccineTypeFilter,
          'medication_status': _medicationStatusFilter,
          'breeding_stage': _breedingStageFilter,
          'financial_type': _financialTypeFilter,
          'financial_category': _financialCategoryFilter,
          'notes_priority': _notesPriorityFilter,
          'notes_is_read': _notesIsReadFilter,
        },
      };

      // ✅ Agora usa o ReportsService para registrar o relatório
      await ReportsService.saveGeneratedReport(
        title: title,
        reportType: reportType,
        parameters: parameters,
        generatedBy: 'Dashboard',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relatório salvo com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar relatório: $e')),
      );
    }
  }

  List<dynamic> _getSortedData() {
    if (_reportData == null || _reportData!['data'] == null) {
      return [];
    }
    final data = List<Map<String, dynamic>>.from(_reportData!['data']);

    if (_sortKey.isNotEmpty) {
      data.sort((a, b) {
        final aVal = a[_sortKey];
        final bVal = b[_sortKey];

        if (aVal == null) return _sortAsc ? 1 : -1;
        if (bVal == null) return _sortAsc ? -1 : 1;

        if (aVal is num && bVal is num) {
          return _sortAsc ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
        }

        final aStr = aVal.toString();
        final bStr = bVal.toString();
        return _sortAsc ? aStr.compareTo(bStr) : bStr.compareTo(aStr);
      });
    }

    return data;
  }

  List<dynamic> _getPaginatedData() {
    final sorted = _getSortedData();
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, sorted.length);
    return sorted.sublist(start.clamp(0, sorted.length), end);
  }

  void _handleSort(String key) {
    setState(() {
      if (_sortKey == key) {
        _sortAsc = !_sortAsc;
      } else {
        _sortKey = key;
        _sortAsc = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hub de Relatórios e Análises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar CSV',
            onPressed: _exportCSV,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Salvar Relatório',
            onPressed: _saveReport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            onTap: (index) async {
              if (index == _financeTabIndex && !_financialUnlocked) {
                _tabController.index = _lastTabIndex;
                final ok = await _showFinancePinDialog();
                if (ok == true) {
                  setState(() => _financialUnlocked = true);
                  _tabController.index = _financeTabIndex;
                  setState(() {
                    _currentPage = 0;
                    _sortKey = '';
                  });
                  await _loadReport();
                }
              } else {
                _lastTabIndex = index;
              }
            },
            tabs: _reportTypes.map((type) => Tab(text: type)).toList(),
          ),

          // Filters
          _buildFiltersSection(theme),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: _reportTypes
                        .map((_) => _buildReportContent(theme))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtros', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          // Period filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _periodPreset,
                  decoration: const InputDecoration(
                    labelText: 'Período',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'last7',
                      child: Text('Últimos 7 dias'),
                    ),
                    DropdownMenuItem(
                      value: 'last30',
                      child: Text('Últimos 30 dias'),
                    ),
                    DropdownMenuItem(
                      value: 'last90',
                      child: Text('Últimos 90 dias'),
                    ),
                    DropdownMenuItem(
                      value: 'currentMonth',
                      child: Text('Mês atual'),
                    ),
                    DropdownMenuItem(
                      value: 'currentYear',
                      child: Text('Ano atual'),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text('Customizado'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _periodPreset = value!;
                      _currentPage = 0;
                    });
                    _loadReport();
                  },
                ),
              ),
              if (_periodPreset == 'custom') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        locale: const Locale('pt', 'BR'),
                        initialDate: _customStart,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _customStart = date);
                        _loadReport();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data Inicial',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_customStart),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        locale: const Locale('pt', 'BR'),
                        initialDate: _customEnd,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _customEnd = date);
                        _loadReport();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data Final',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_customEnd),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Contextual filters
          _buildContextualFilters(theme),
        ],
      ),
    );
  }

  Widget _buildContextualFilters(ThemeData theme) {
    final currentReport = _reportTypes[_tabController.index];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (currentReport == 'Animais') ...[
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _speciesFilter,
              decoration: const InputDecoration(
                labelText: 'Espécie',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Ovino', child: Text('Ovino')),
                DropdownMenuItem(value: 'Caprino', child: Text('Caprino')),
              ],
              onChanged: (v) {
                setState(() => _speciesFilter = v!);
                _loadReport();
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _genderFilter,
              decoration: const InputDecoration(
                labelText: 'Gênero',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
              ],
              onChanged: (v) {
                setState(() => _genderFilter = v!);
                _loadReport();
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(
                  value: 'Saudável',
                  child: Text('Saudável'),
                ),
                DropdownMenuItem(
                  value: 'Em tratamento',
                  child: Text('Em tratamento'),
                ),
                DropdownMenuItem(
                  value: 'Reprodutor',
                  child: Text('Reprodutor'),
                ),
              ],
              onChanged: (v) {
                setState(() => _statusFilter = v!);
                _loadReport();
              },
            ),
          ),
        ],
        if (currentReport == 'Vacinações') ...[
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Agendada', child: Text('Agendada')),
                DropdownMenuItem(value: 'Aplicada', child: Text('Aplicada')),
                DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
              ],
              onChanged: (v) {
                setState(() => _statusFilter = v!);
                _loadReport();
              },
            ),
          ),
        ],
        if (currentReport == 'Medicações') ...[
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _medicationStatusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Agendado', child: Text('Agendado')),
                DropdownMenuItem(value: 'Aplicado', child: Text('Aplicado')),
                DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
              ],
              onChanged: (v) {
                setState(() => _medicationStatusFilter = v!);
                _loadReport();
              },
            ),
          ),
        ],
        if (currentReport == 'Reprodução') ...[
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              value: _breedingStageFilter,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Estágio',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(
                  value: 'encabritamento',
                  child: Text('Encabritamento'),
                ),
                DropdownMenuItem(
                  value: 'separacao',
                  child: Text('Separação'),
                ),
                DropdownMenuItem(
                  value: 'aguardando_ultrassom',
                  child: Text('Aguardando Ultrassom'),
                ),
                DropdownMenuItem(
                  value: 'gestacao_confirmada',
                  child: Text('Gestação Confirmada'),
                ),
                DropdownMenuItem(
                  value: 'parto_realizado',
                  child: Text('Parto Realizado'),
                ),
                DropdownMenuItem(value: 'falhou', child: Text('Falhou')),
              ],
              onChanged: (v) {
                setState(() => _breedingStageFilter = v!);
                _loadReport();
              },
            ),
          ),
        ],
        if (currentReport == 'Financeiro') ...[
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _financialTypeFilter,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'receita', child: Text('Receita')),
                DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
              ],
              onChanged: (v) {
                setState(() => _financialTypeFilter = v!);
                _loadReport();
              },
            ),
          ),
        ],
        if (currentReport == 'Anotações') ...[
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _notesIsReadFilter,
              decoration: const InputDecoration(
                labelText: 'Leitura',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Lidas', child: Text('Lidas')),
                DropdownMenuItem(
                  value: 'Não lidas',
                  child: Text('Não lidas'),
                ),
              ],
              onChanged: (v) {
                setState(() => _notesIsReadFilter = v!);
                _loadReport();
              },
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _notesPriorityFilter,
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                DropdownMenuItem(value: 'Média', child: Text('Média')),
                DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
              ],
              onChanged: (v) {
                setState(() => _notesPriorityFilter = v!);
                _loadReport();
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReportContent(ThemeData theme) {
    if (_reportTypes[_tabController.index] == 'Financeiro' &&
        !_financialUnlocked) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Relatórios Financeiros Bloqueados',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Clique na aba novamente para inserir a senha'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showFinancePinDialog,
              icon: const Icon(Icons.lock_open),
              label: const Text('Desbloquear'),
            ),
          ],
        ),
      );
    }

    if (_reportData == null) {
      return const Center(child: Text('Nenhum dado disponível'));
    }

    return Column(
      children: [
        _buildKPIs(theme),
        const Divider(),
        Expanded(child: _buildTable(theme)),
        _buildPagination(theme),
      ],
    );
  }

  Widget _buildKPIs(ThemeData theme) {
    if (_reportData == null || _reportData!['summary'] == null) {
      return const SizedBox.shrink();
    }

    final summary = Map<String, dynamic>.from(_reportData!['summary'] as Map);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: summary.entries.map((entry) {
          final value = entry.value;
          String displayValue;

          if (value is num &&
              (entry.key.contains('revenue') ||
                  entry.key.contains('expense') ||
                  entry.key.contains('balance') ||
                  entry.key.contains('amount'))) {
            displayValue = 'R\$ ${value.toStringAsFixed(2)}';
          } else if (value is double) {
            displayValue = value.toStringAsFixed(2);
          } else {
            displayValue = value.toString();
          }

          return Card(
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    ptBrHeader(entry.key).toUpperCase(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayValue,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable(ThemeData theme) {
    final paginatedData = _getPaginatedData();

    if (paginatedData.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum dado encontrado para o período selecionado',
        ),
      );
    }

    final columns = (paginatedData.first as Map<String, dynamic>)
        .keys
        .where((k) => k != 'animal_color')
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          sortColumnIndex: _sortKey.isEmpty ? null : columns.indexOf(_sortKey),
          sortAscending: _sortAsc,
          columns: columns
              .map(
                (col) => DataColumn(
                  label: Text(ptBrHeader(col)),
                  onSort: (_, __) => _handleSort(col),
                ),
              )
              .toList(),
          rows: paginatedData.map((row) {
            final r = row as Map<String, dynamic>;
            return DataRow(
              cells:
                  columns.map((col) => _buildDataCell(r, col, theme)).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  DataCell _buildDataCell(
    Map<String, dynamic> row,
    String key,
    ThemeData theme,
  ) {
    if (key == 'animal_name') {
      final label = AnimalRecordDisplay.labelFromRecord(row);
      final color = AnimalRecordDisplay.colorFromRecord(row);
      return DataCell(
        Text(
          label,
          style: color != null
              ? TextStyle(color: color, fontWeight: FontWeight.w600)
              : null,
        ),
      );
    }

    final display = _cellValue(row[key], key: key);
    return DataCell(Text(display));
  }

  String _cellValue(dynamic value, {required String key}) {
    if (value == null) return '';
    if (value is bool) return value ? 'Sim' : 'Não';

    // Datas
    if (key.contains('date') || key.endsWith('_at') || key == 'birth_date') {
      final s = value.toString();
      if (s.isEmpty) return '';
      try {
        final d = DateTime.parse(s);
        return DateFormat('dd/MM/yyyy').format(d);
      } catch (_) {
        return s;
      }
    }

    // Valores monetários
    if (key.contains('amount') ||
        key.contains('revenue') ||
        key.contains('expense') ||
        key.contains('balance')) {
      if (value is num) {
        return 'R\$ ${value.toStringAsFixed(2)}';
      }
    }

    return value.toString();
  }

  String _csvCell(dynamic value, {required String key}) {
    if (value == null) return '';
    if (value is bool) return value ? 'Sim' : 'Não';

    // Datas no CSV como dd/MM/yyyy
    if (key.contains('date') || key.endsWith('_at') || key == 'birth_date') {
      final s = value.toString();
      if (s.isEmpty) return '';
      try {
        final d = DateTime.parse(s);
        return DateFormat('dd/MM/yyyy').format(d);
      } catch (_) {
        return s;
      }
    }

    if (key.contains('amount') ||
        key.contains('revenue') ||
        key.contains('expense') ||
        key.contains('balance')) {
      if (value is num) {
        return value.toStringAsFixed(2);
      }
    }

    return value.toString();
  }

  Widget _buildPagination(ThemeData theme) {
    final totalItems = _getSortedData().length;
    final totalPages = (totalItems / _pageSize).ceil();

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando ${_currentPage * _pageSize + 1} '
            'a ${((_currentPage + 1) * _pageSize).clamp(0, totalItems)} '
            'de $totalItems resultados',
            style: theme.textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text('Página ${_currentPage + 1} de $totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Tipo já usado no seu ReportsService
class DateRange {
  final DateTime startDate;
  final DateTime endDate;
  DateRange({required this.startDate, required this.endDate});
}
