import '../../../models/report_filters.dart';
import '../application/reports_service.dart';

class ReportsFeatureRepository {
  ReportsFeatureRepository({
    required ReportsService reportsService,
  }) : _reportsService = reportsService;

  final ReportsService _reportsService;

  Future<Map<String, dynamic>> generateReport(
    String reportType,
    ReportFilters filters,
  ) {
    return _reportsService.generateReport(reportType, filters);
  }

  Future<void> saveReport({
    required String title,
    required String reportType,
    required Map<String, dynamic> parameters,
    String generatedBy = 'Dashboard',
  }) {
    return _reportsService.saveReport(
      title: title,
      reportType: reportType,
      parameters: parameters,
      generatedBy: generatedBy,
    );
  }
}
