// lib/services/system_maintenance_service.dart
import '../data/maintenance_repository.dart';

/// Serviço de manutenção do sistema (limpar banco, rotinas administrativas, etc.)
class SystemMaintenanceService {
  final MaintenanceRepository _repository;

  SystemMaintenanceService(this._repository);

  Future<void> clearAllData() {
    return _repository.clearAllData();
  }
}
