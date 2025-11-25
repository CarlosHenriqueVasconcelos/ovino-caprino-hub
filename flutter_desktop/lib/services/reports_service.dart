// Service layer glue for report generation.
import '../data/reports_repository.dart';
import '../models/report_filters.dart';

class ReportsService {
  final ReportsRepository _repository;

  ReportsService(this._repository);

  Future<Map<String, dynamic>> generateReport(
    String reportType,
    ReportFilters filters,
  ) {
    switch (reportType) {
      case 'Animais':
        return _repository.getAnimalsReport(filters);
      case 'Pesos':
        return _repository.getWeightsReport(filters);
      case 'Vacinações':
        return _repository.getVaccinationsReport(filters);
      case 'Medicações':
        return _repository.getMedicationsReport(filters);
      case 'Reprodução':
        return _repository.getBreedingReport(filters);
      case 'Financeiro':
        return _repository.getFinancialReport(filters);
      case 'Anotações':
        return _repository.getNotesReport(filters);
      default:
        return Future.value({
          'summary': <String, dynamic>{},
          'data': const [],
        });
    }
  }

  Future<void> saveReport({
    required String title,
    required String reportType,
    required Map<String, dynamic> parameters,
    String generatedBy = 'Dashboard',
  }) =>
      _repository.saveGeneratedReport(
        title: title,
        reportType: reportType,
        parameters: parameters,
        generatedBy: generatedBy,
      );
}
