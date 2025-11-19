// lib/widgets/reports_hub_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../services/reports_service.dart';
import '../services/reports_controller.dart';
import '../utils/animal_record_display.dart';
import '../utils/labels_ptbr.dart';

import 'reports/reports_chart_area.dart';
import 'reports/reports_empty_state.dart';
import 'reports/reports_export_bar.dart';
import 'reports/reports_filter_panel.dart';
import 'reports/reports_models.dart';
import 'reports/reports_summary_cards_row.dart';
import 'reports/reports_table_area.dart';
import 'reports/reports_view_switcher.dart';

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
  ReportViewMode _viewMode = ReportViewMode.table;

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

      final reportType = _reportTypes[_tabController.index];
      final reportsController = context.read<ReportsController>();
      final data = await reportsController.generateReport(
        reportType,
        filters,
      );

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

  Future<void> _selectCustomStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _customStart = picked);
    }
  }

  Future<void> _selectCustomEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customEnd,
      firstDate: _customStart,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _customEnd = picked);
    }
  }

  void _applyCustomRange() {
    setState(() => _periodPreset = 'custom');
    _loadReport();
  }

  String get _currentReportType => _reportTypes[_tabController.index];

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

      final keys = data.first.keys.toList();
      final headers = keys
          .map(ptBrHeader)
          .map((h) => h.contains(',') ? '"$h"' : h)
          .join(',');

      final rows = data.map((row) {
        return keys.map((k) {
          final v = row[k];
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

      final reportsController = context.read<ReportsController>();
      await reportsController.saveReport(
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

  List<Map<String, dynamic>> _getSortedData() {
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

  List<Map<String, dynamic>> _getPaginatedData() {
    final sorted = _getSortedData();
    if (sorted.isEmpty) return const [];
    final start = (_currentPage * _pageSize).clamp(0, sorted.length);
    final end = (start + _pageSize).clamp(0, sorted.length);
    final safeStart = start.toInt();
    final safeEnd = end.toInt();
    return sorted.sublist(safeStart, safeEnd);
  }

  List<ReportChartPoint> _buildChartPoints() {
    final chartData = _reportData?['chart'];
    if (chartData is List) {
      return chartData.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return ReportChartPoint(
          label: map['label']?.toString() ?? '',
          value: (map['value'] is num)
              ? (map['value'] as num).toDouble()
              : double.tryParse(map['value']?.toString() ?? '0') ?? 0,
          date: map['date'] != null
              ? DateTime.tryParse(map['date'].toString())
              : null,
        );
      }).toList();
    }

    final summary = _reportData?['summary'];
    if (summary is Map) {
      return summary.entries.map((entry) {
        final value = entry.value;
        final doubleValue = value is num
            ? value.toDouble()
            : double.tryParse(value?.toString() ?? '0') ?? 0;
        return ReportChartPoint(
          label: ptBrHeader(entry.key),
          value: doubleValue,
        );
      }).toList();
    }

    return const [];
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

  void _changeViewMode(ReportViewMode mode) {
    if (_viewMode == mode) return;
    setState(() => _viewMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hub de Relatórios e Análises'),
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

          ReportsFilterPanel(
            theme: theme,
            currentReport: _currentReportType,
            periodPreset: _periodPreset,
            customStart: _customStart,
            customEnd: _customEnd,
            onPeriodPresetChanged: (value) {
              setState(() => _periodPreset = value);
              if (value != 'custom') _loadReport();
            },
            onSelectCustomStart: _selectCustomStartDate,
            onSelectCustomEnd: _selectCustomEndDate,
            onApplyCustomRange: _applyCustomRange,
            speciesFilter: _speciesFilter,
            onSpeciesChanged: (value) {
              setState(() => _speciesFilter = value);
              _loadReport();
            },
            genderFilter: _genderFilter,
            onGenderChanged: (value) {
              setState(() => _genderFilter = value);
              _loadReport();
            },
            statusFilter: _statusFilter,
            onStatusChanged: (value) {
              setState(() => _statusFilter = value);
              _loadReport();
            },
            medicationStatusFilter: _medicationStatusFilter,
            onMedicationStatusChanged: (value) {
              setState(() => _medicationStatusFilter = value);
              _loadReport();
            },
            breedingStageFilter: _breedingStageFilter,
            onBreedingStageChanged: (value) {
              setState(() => _breedingStageFilter = value);
              _loadReport();
            },
            financialTypeFilter: _financialTypeFilter,
            onFinancialTypeChanged: (value) {
              setState(() => _financialTypeFilter = value);
              _loadReport();
            },
            notesIsReadFilter: _notesIsReadFilter,
            onNotesReadChanged: (value) {
              setState(() => _notesIsReadFilter = value);
              _loadReport();
            },
            notesPriorityFilter: _notesPriorityFilter,
            onNotesPriorityChanged: (value) {
              setState(() => _notesPriorityFilter = value);
              _loadReport();
            },
          ),

          ReportsExportBar(
            onExportCsv: _exportCSV,
            onSaveReport: _saveReport,
          ),

          ReportsViewSwitcher(
            mode: _viewMode,
            onChanged: _changeViewMode,
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: _reportTypes
                        .map((_) => _buildCurrentView(theme))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(ThemeData theme) {
    if (_currentReportType == 'Financeiro' && !_financialUnlocked) {
      return ReportsEmptyState.locked(onUnlock: _showFinancePinDialog);
    }

    if (_reportData == null) {
      return const ReportsEmptyState(
        message: 'Selecione um período para visualizar os relatórios.',
      );
    }

    final summary =
        Map<String, dynamic>.from(_reportData?['summary'] ?? const {});
    final rows = _getPaginatedData();

    switch (_viewMode) {
      case ReportViewMode.summary:
        if (summary.isEmpty) {
          return const ReportsEmptyState(
            message: 'Sem dados para exibir o resumo.',
          );
        }
        return ReportsSummaryCardsRow(summary: summary, theme: theme);
      case ReportViewMode.chart:
        final points = _buildChartPoints();
        if (points.isEmpty) {
          return const ReportsEmptyState(
            message: 'Sem dados suficientes para gerar gráficos.',
          );
        }
        return ReportsChartArea(points: points);
      case ReportViewMode.table:
      default:
        return _buildTableView(theme, rows);
    }
  }

  Widget _buildTableView(
    ThemeData theme,
    List<Map<String, dynamic>> rows,
  ) {
    if (rows.isEmpty) {
      return const ReportsEmptyState(
        message: 'Nenhum dado encontrado para os filtros selecionados.',
      );
    }

    final columns =
        rows.first.keys.where((k) => k != 'animal_color').toList();

    return Column(
      children: [
        Expanded(
          child: ReportsTableArea(
            theme: theme,
            columns: columns,
            rows: rows,
            sortKey: _sortKey,
            sortAscending: _sortAsc,
            onSort: _handleSort,
            cellBuilder: (row, key) => _buildDataCell(row, key, theme),
          ),
        ),
        _buildPagination(theme),
      ],
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
