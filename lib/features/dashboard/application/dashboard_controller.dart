import 'package:flutter/foundation.dart';

import '../../../models/animal.dart';
import '../data/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required DashboardRepository dashboardRepository,
  }) : _repository = dashboardRepository {
    _repository.addListener(_onRepositoryChanged);
  }

  final DashboardRepository _repository;

  bool get isLoading => _repository.isLoading;
  AnimalStats? get stats => _repository.stats;

  Future<void> refresh() {
    return _repository.refreshDashboardData();
  }

  void _onRepositoryChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}
