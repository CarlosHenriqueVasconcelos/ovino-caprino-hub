import '../../../models/report_filters.dart';
import '../data/reports_repository.dart';

/// Camada intermediária para impedir que widgets acessem o banco diretamente
/// quando geram ou salvam relatórios.
class ReportsController {
  final ReportsFeatureRepository _repository;

  ReportsController(this._repository);

  /// Gera o relatório com base no tipo selecionado no dashboard.
  Future<Map<String, dynamic>> generateReport(
    String reportType,
    ReportFilters filters,
  ) =>
      _repository.generateReport(reportType, filters);

  /// Persiste o histórico de geração de relatórios.
  Future<void> saveReport({
    required String title,
    required String reportType,
    required Map<String, dynamic> parameters,
    String generatedBy = 'Dashboard',
  }) =>
      _repository.saveReport(
        title: title,
        reportType: reportType,
        parameters: parameters,
        generatedBy: generatedBy,
      );
}
