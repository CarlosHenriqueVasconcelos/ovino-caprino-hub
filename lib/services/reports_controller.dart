import '../models/report_filters.dart';
import '../services/reports_service.dart';

/// Camada intermediária para impedir que widgets acessem o banco diretamente
/// quando geram ou salvam relatórios.
class ReportsController {
  final ReportsService _service;

  ReportsController(this._service);

  /// Gera o relatório com base no tipo selecionado no dashboard.
  Future<Map<String, dynamic>> generateReport(
    String reportType,
    ReportFilters filters,
  ) =>
      _service.generateReport(reportType, filters);

  /// Persiste o histórico de geração de relatórios.
  Future<void> saveReport({
    required String title,
    required String reportType,
    required Map<String, dynamic> parameters,
    String generatedBy = 'Dashboard',
  }) =>
      _service.saveReport(
        title: title,
        reportType: reportType,
        parameters: parameters,
        generatedBy: generatedBy,
      );
}
