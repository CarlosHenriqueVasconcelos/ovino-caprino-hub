import '../data/local_db.dart';
import 'reports_service.dart';

/// Camada intermediária para impedir que widgets acessem o banco diretamente
/// quando geram ou salvam relatórios.
class ReportsController {
  final AppDatabase _appDatabase;

  ReportsController(this._appDatabase);

  /// Gera o relatório com base no tipo selecionado no dashboard.
  Future<Map<String, dynamic>> generateReport(
    String reportType,
    ReportFilters filters,
  ) async {
    final db = _appDatabase.db;
    switch (reportType) {
      case 'Animais':
        return ReportsService.getAnimalsReport(filters, db: db);
      case 'Pesos':
        return ReportsService.getWeightsReport(filters, db: db);
      case 'Vacinações':
        return ReportsService.getVaccinationsReport(filters, db: db);
      case 'Medicações':
        return ReportsService.getMedicationsReport(filters, db: db);
      case 'Reprodução':
        return ReportsService.getBreedingReport(filters, db: db);
      case 'Financeiro':
        return ReportsService.getFinancialReport(filters, db: db);
      case 'Anotações':
        return ReportsService.getNotesReport(filters, db: db);
      default:
        return {'summary': <String, dynamic>{}, 'data': const []};
    }
  }

  /// Persiste o histórico de geração de relatórios.
  Future<void> saveReport({
    required String title,
    required String reportType,
    required Map<String, dynamic> parameters,
    String generatedBy = 'Dashboard',
  }) async {
    await ReportsService.saveGeneratedReport(
      title: title,
      reportType: reportType,
      parameters: parameters,
      generatedBy: generatedBy,
      db: _appDatabase.db,
    );
  }
}
