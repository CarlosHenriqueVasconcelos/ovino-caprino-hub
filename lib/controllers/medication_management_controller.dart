import 'package:flutter/foundation.dart';
import '../services/medication_service.dart';
import '../services/vaccination_service.dart';

class MedicationManagementController extends ChangeNotifier {
  MedicationManagementController(this._vaccinationService, this._medicationService);

  final VaccinationService _vaccinationService;
  final MedicationService _medicationService;

  static const int pageSize = 50;

  List<Map<String, dynamic>> _vaccinations = [];
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;
  bool _isLoadingMoreVacc = false;
  bool _isLoadingMoreMed = false;
  bool _hasMoreVacc = false;
  bool _hasMoreMed = false;
  int _vaccPage = 0;
  int _medPage = 0;
  String _vaccinationFilter = 'Atrasadas';
  String _medicationFilter = 'Atrasados';
  bool _initialized = false;

  List<Map<String, dynamic>> get vaccinations => _vaccinations;
  List<Map<String, dynamic>> get medications => _medications;
  bool get isLoading => _isLoading;
  bool get isLoadingMoreVacc => _isLoadingMoreVacc;
  bool get isLoadingMoreMed => _isLoadingMoreMed;
  bool get hasMoreVacc => _hasMoreVacc;
  bool get hasMoreMed => _hasMoreMed;
  String get vaccinationFilter => _vaccinationFilter;
  String get medicationFilter => _medicationFilter;

  Future<void> initLoad() async {
    if (_initialized) return;
    _initialized = true;
    await reload();
  }

  Future<void> reload() async {
    _isLoading = true;
    notifyListeners();
    try {
      final vaccinations = await _fetchVaccinationsPage(page: 0);
      final medications = await _fetchMedicationsPage(page: 0);
      _vaccinations = List<Map<String, dynamic>>.from(vaccinations);
      _medications = List<Map<String, dynamic>>.from(medications);
      _vaccPage = 0;
      _medPage = 0;
      _hasMoreVacc = vaccinations.length == pageSize;
      _hasMoreMed = medications.length == pageSize;
    } catch (_) {
      // mantém estado atual
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreVacc() async {
    if (_isLoadingMoreVacc || !_hasMoreVacc) return;
    _isLoadingMoreVacc = true;
    notifyListeners();
    try {
      final nextPage = _vaccPage + 1;
      final result = await _fetchVaccinationsPage(page: nextPage);
      _vaccinations = List<Map<String, dynamic>>.from(
        [..._vaccinations, ...result],
      );
      _vaccPage = nextPage;
      _hasMoreVacc = result.length == pageSize;
    } catch (_) {
      // mantém estado atual
    } finally {
      _isLoadingMoreVacc = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMed() async {
    if (_isLoadingMoreMed || !_hasMoreMed) return;
    _isLoadingMoreMed = true;
    notifyListeners();
    try {
      final nextPage = _medPage + 1;
      final result = await _fetchMedicationsPage(page: nextPage);
      _medications = List<Map<String, dynamic>>.from(
        [..._medications, ...result],
      );
      _medPage = nextPage;
      _hasMoreMed = result.length == pageSize;
    } catch (_) {
      // mantém estado atual
    } finally {
      _isLoadingMoreMed = false;
      notifyListeners();
    }
  }

  void setVaccFilter(String value) {
    if (_vaccinationFilter == value) return;
    _vaccinationFilter = value;
    notifyListeners();
    _reloadVaccinations();
  }

  void setMedFilter(String value) {
    if (_medicationFilter == value) return;
    _medicationFilter = value;
    notifyListeners();
    _reloadMedications();
  }

  Future<void> _reloadVaccinations() async {
    _vaccinations = [];
    _vaccPage = 0;
    _hasMoreVacc = false;
    _isLoadingMoreVacc = true;
    notifyListeners();
    try {
      final result = await _fetchVaccinationsPage(page: 0);
      _vaccinations = List<Map<String, dynamic>>.from(result);
      _vaccPage = 0;
      _hasMoreVacc = result.length == pageSize;
    } catch (_) {
      // mantém estado atual
    } finally {
      _isLoadingMoreVacc = false;
      notifyListeners();
    }
  }

  Future<void> _reloadMedications() async {
    _medications = [];
    _medPage = 0;
    _hasMoreMed = false;
    _isLoadingMoreMed = true;
    notifyListeners();
    try {
      final result = await _fetchMedicationsPage(page: 0);
      _medications = List<Map<String, dynamic>>.from(result);
      _medPage = 0;
      _hasMoreMed = result.length == pageSize;
    } catch (_) {
      // mantém estado atual
    } finally {
      _isLoadingMoreMed = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchVaccinationsPage({
    required int page,
  }) async {
    final options = VaccinationQueryOptions(
      limit: pageSize,
      offset: page * pageSize,
    );
    switch (_vaccinationFilter) {
      case 'Atrasadas':
        return _vaccinationService.getVaccinationsOverdueWithAnimalInfo(
          options: options,
        );
      case 'Agendadas':
        return _vaccinationService
            .getVaccinationsScheduledFutureWithAnimalInfo(
          options: options,
        );
      case 'Aplicadas':
        return _vaccinationService.getVaccinationsAppliedWithAnimalInfo(
          options: options,
        );
      case 'Canceladas':
        return _vaccinationService.getVaccinationsCanceledWithAnimalInfo(
          options: options,
        );
      default:
        return _vaccinationService.getVaccinationsOverdueWithAnimalInfo(
          options: options,
        );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMedicationsPage({
    required int page,
  }) async {
    final options = MedicationQueryOptions(
      limit: pageSize,
      offset: page * pageSize,
    );
    switch (_medicationFilter) {
      case 'Atrasados':
        return _medicationService.getMedicationsOverdueWithAnimalInfo(
          options: options,
        );
      case 'Agendados':
        return _medicationService.getMedicationsScheduledFutureWithAnimalInfo(
          options: options,
        );
      case 'Aplicados':
        return _medicationService.getMedicationsAppliedWithAnimalInfo(
          options: options,
        );
      case 'Cancelados':
        return _medicationService.getMedicationsCanceledWithAnimalInfo(
          options: options,
        );
      default:
        return _medicationService.getMedicationsOverdueWithAnimalInfo(
          options: options,
        );
    }
  }
}
