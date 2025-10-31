import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/animal_service.dart';
import '../services/database_service.dart';
import '../services/pharmacy_service.dart';
import '../models/pharmacy_stock.dart';
import '../utils/animal_display_utils.dart';

class MedicationManagementScreen extends StatefulWidget {
  const MedicationManagementScreen({super.key});

  @override
  State<MedicationManagementScreen> createState() => _MedicationManagementScreenState();
}

class _MedicationManagementScreenState extends State<MedicationManagementScreen> {
  List<Map<String, dynamic>> _vaccinations = [];
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;
  
  // Filtros de status
  String _vaccinationFilter = 'Atrasadas';
  String _medicationFilter = 'Atrasados';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final vaccinations = await DatabaseService.getVaccinations();
      final medications = await DatabaseService.getMedications();
      setState(() {
        _vaccinations = List<Map<String, dynamic>>.from(vaccinations);
        _medications = List<Map<String, dynamic>>.from(medications);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _filterVaccinations() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_vaccinationFilter) {
      case 'Atrasadas':
        return _vaccinations.where((v) {
          if (v['status'] != 'Agendada') return false;
          final scheduledDate = DateTime.tryParse(v['scheduled_date'] ?? '');
          if (scheduledDate == null) return false;
          return scheduledDate.isBefore(today);
        }).toList();
      case 'Agendadas':
        return _vaccinations.where((v) {
          if (v['status'] != 'Agendada') return false;
          final scheduledDate = DateTime.tryParse(v['scheduled_date'] ?? '');
          if (scheduledDate == null) return false;
          return !scheduledDate.isBefore(today);
        }).toList();
      case 'Aplicadas':
        return _vaccinations.where((v) => v['status'] == 'Aplicada').toList();
      case 'Canceladas':
        return _vaccinations.where((v) => v['status'] == 'Cancelada').toList();
      default:
        return _vaccinations;
    }
  }

  List<Map<String, dynamic>> _filterMedications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_medicationFilter) {
      case 'Atrasados':
        return _medications.where((m) {
          if (m['status'] != 'Agendado') return false;
          final date = DateTime.tryParse(m['date'] ?? '');
          if (date == null) return false;
          return date.isBefore(today);
        }).toList();
      case 'Agendados':
        return _medications.where((m) {
          if (m['status'] != 'Agendado') return false;
          final date = DateTime.tryParse(m['date'] ?? '');
          if (date == null) return false;
          return !date.isBefore(today);
        }).toList();
      case 'Aplicados':
        return _medications.where((m) => m['status'] == 'Aplicado').toList();
      case 'Cancelados':
        return _medications.where((m) => m['status'] == 'Cancelado').toList();
      default:
        return _medications;
    }
  }

  int _countVaccinationsByStatus(String status) {
    return _filterVaccinationsForCount(status).length;
  }

  List<Map<String, dynamic>> _filterVaccinationsForCount(String status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (status) {
      case 'Atrasadas':
        return _vaccinations.where((v) {
          if (v['status'] != 'Agendada') return false;
          final scheduledDate = DateTime.tryParse(v['scheduled_date'] ?? '');
          if (scheduledDate == null) return false;
          return scheduledDate.isBefore(today);
        }).toList();
      case 'Agendadas':
        return _vaccinations.where((v) {
          if (v['status'] != 'Agendada') return false;
          final scheduledDate = DateTime.tryParse(v['scheduled_date'] ?? '');
          if (scheduledDate == null) return false;
          return !scheduledDate.isBefore(today);
        }).toList();
      case 'Aplicadas':
        return _vaccinations.where((v) => v['status'] == 'Aplicada').toList();
      case 'Canceladas':
        return _vaccinations.where((v) => v['status'] == 'Cancelada').toList();
      default:
        return _vaccinations;
    }
  }

  int _countMedicationsByStatus(String status) {
    return _filterMedicationsForCount(status).length;
  }

  List<Map<String, dynamic>> _filterMedicationsForCount(String status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (status) {
      case 'Atrasados':
        return _medications.where((m) {
          if (m['status'] != 'Agendado') return false;
          final date = DateTime.tryParse(m['date'] ?? '');
          if (date == null) return false;
          return date.isBefore(today);
        }).toList();
      case 'Agendados':
        return _medications.where((m) {
          if (m['status'] != 'Agendado') return false;
          final date = DateTime.tryParse(m['date'] ?? '');
          if (date == null) return false;
          return !date.isBefore(today);
        }).toList();
      case 'Aplicados':
        return _medications.where((m) => m['status'] == 'Aplicado').toList();
      case 'Cancelados':
        return _medications.where((m) => m['status'] == 'Cancelado').toList();
      default:
        return _medications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vacinações e Medicamentos'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.vaccines), text: 'Vacinações'),
              Tab(icon: Icon(Icons.medication), text: 'Medicamentos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVaccinationsList(),
            _buildMedicationsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Agendar'),
        ),
      ),
    );
  }

  Widget _buildVaccinationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredVaccinations = _filterVaccinations();

    return Column(
      children: [
        // Sub-tabs para filtros
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Atrasadas (${_countVaccinationsByStatus('Atrasadas')})',
                  isSelected: _vaccinationFilter == 'Atrasadas',
                  color: Colors.red,
                  onTap: () => setState(() => _vaccinationFilter = 'Atrasadas'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Agendadas (${_countVaccinationsByStatus('Agendadas')})',
                  isSelected: _vaccinationFilter == 'Agendadas',
                  color: Colors.orange,
                  onTap: () => setState(() => _vaccinationFilter = 'Agendadas'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Aplicadas (${_countVaccinationsByStatus('Aplicadas')})',
                  isSelected: _vaccinationFilter == 'Aplicadas',
                  color: Colors.green,
                  onTap: () => setState(() => _vaccinationFilter = 'Aplicadas'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Canceladas (${_countVaccinationsByStatus('Canceladas')})',
                  isSelected: _vaccinationFilter == 'Canceladas',
                  color: Colors.grey,
                  onTap: () => setState(() => _vaccinationFilter = 'Canceladas'),
                ),
              ],
            ),
          ),
        ),
        
        // Lista filtrada
        Expanded(
          child: filteredVaccinations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.vaccines_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma vacinação $_vaccinationFilter',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredVaccinations.length,
                  itemBuilder: (context, index) {
                    final vaccination = filteredVaccinations[index];
                    return _buildVaccinationCard(vaccination);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMedicationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredMedications = _filterMedications();

    return Column(
      children: [
        // Sub-tabs para filtros
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Atrasados (${_countMedicationsByStatus('Atrasados')})',
                  isSelected: _medicationFilter == 'Atrasados',
                  color: Colors.red,
                  onTap: () => setState(() => _medicationFilter = 'Atrasados'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Agendados (${_countMedicationsByStatus('Agendados')})',
                  isSelected: _medicationFilter == 'Agendados',
                  color: Colors.orange,
                  onTap: () => setState(() => _medicationFilter = 'Agendados'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Aplicados (${_countMedicationsByStatus('Aplicados')})',
                  isSelected: _medicationFilter == 'Aplicados',
                  color: Colors.green,
                  onTap: () => setState(() => _medicationFilter = 'Aplicados'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Cancelados (${_countMedicationsByStatus('Cancelados')})',
                  isSelected: _medicationFilter == 'Cancelados',
                  color: Colors.grey,
                  onTap: () => setState(() => _medicationFilter = 'Cancelados'),
                ),
              ],
            ),
          ),
        ),
        
        // Lista filtrada
        Expanded(
          child: filteredMedications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum medicamento $_medicationFilter',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredMedications.length,
                  itemBuilder: (context, index) {
                    final medication = filteredMedications[index];
                    return _buildMedicationCard(medication);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildVaccinationCard(Map<String, dynamic> vaccination) {
    final status = vaccination['status'] ?? 'Agendada';
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.schedule;
    if (status == 'Aplicada') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }
    if (status == 'Cancelada') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.vaccines, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination['vaccine_name'] ?? 'Sem nome',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showVaccinationOptions(vaccination),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Tipo: ${vaccination['vaccine_type'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Data: ${_formatDate(vaccination['scheduled_date'])}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Botões de ação
              if (status == 'Agendada') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsApplied(vaccination['id'], isVaccination: true),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Aplicar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _cancelItem(vaccination['id'], isVaccination: true),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDetails(vaccination, isVaccination: true),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Ver Detalhes'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final status = medication['status'] ?? 'Agendado';
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.schedule;
    if (status == 'Aplicado') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }
    if (status == 'Cancelado') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.medication, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication['medication_name'] ?? 'Sem nome',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showMedicationOptions(medication),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Data: ${_formatDate(medication['date'])}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              if (medication['next_date'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event_repeat, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Próxima: ${_formatDate(medication['next_date'])}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              
              // Botões de ação
              if (status == 'Agendado') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsApplied(medication['id'], isVaccination: false),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Aplicar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _cancelItem(medication['id'], isVaccination: false),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDetails(medication, isVaccination: false),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Ver Detalhes'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return date.toString();
    }
  }

  void _showDetails(Map<String, dynamic> data, {required bool isVaccination}) async {
    final animalService = Provider.of<AnimalService>(context, listen: false);
    final animalId = data['animal_id'];
    final animal = animalService.animals.firstWhere(
      (a) => a.id == animalId,
      orElse: () => animalService.animals.first,
    );

    showDialog(
      context: context,
      builder: (context) => _DetailsDialog(
        data: data,
        animal: animal,
        isVaccination: isVaccination,
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddMedicationDialog(
        onSaved: () {
          _loadData();
        },
      ),
    );
  }

  Future<void> _markAsApplied(String id, {required bool isVaccination}) async {
    try {
      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0];
      
      if (isVaccination) {
        await DatabaseService.updateVaccination(id, {
          'status': 'Aplicada',
          'applied_date': today,
        });
      } else {
        // MEDICAMENTO - DEDUZIR DO ESTOQUE DA FARMÁCIA
        final db = await DatabaseService.database;
        final medicationRows = await db.query(
          'medications',
          where: 'id = ?',
          whereArgs: [id],
        );
        
        if (medicationRows.isNotEmpty) {
          final medication = medicationRows.first;
          final pharmacyStockId = medication['pharmacy_stock_id'] as String?;
          final quantityUsed = medication['quantity_used'] as double?;

          // Atualizar status
          await DatabaseService.updateMedication(id, {
            'status': 'Aplicado',
            'applied_date': today,
          });

          // DEDUZIR DO ESTOQUE
          if (pharmacyStockId != null && quantityUsed != null && quantityUsed > 0) {
            final stock = await PharmacyService.getStockById(pharmacyStockId);
            if (stock != null) {
              final isAmpoule = stock.medicationType == 'Ampola' && stock.quantityPerUnit != null;
              await PharmacyService.deductFromStock(
                pharmacyStockId,
                quantityUsed,
                id,
                isAmpoule: isAmpoule,
              );
            }
          }
        }
      }
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isVaccination ? 'Vacinação aplicada com sucesso!' : 'Medicamento aplicado e estoque atualizado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar como aplicado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelItem(String id, {required bool isVaccination}) async {
    try {
      if (isVaccination) {
        await DatabaseService.updateVaccination(id, {
          'status': 'Cancelada',
        });
      } else {
        await DatabaseService.updateMedication(id, {
          'status': 'Cancelado',
        });
      }
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isVaccination ? 'Vacinação cancelada' : 'Medicamento cancelado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVaccinationOptions(Map<String, dynamic> vaccination) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Ver Detalhes'),
            onTap: () {
              Navigator.pop(context);
              _showDetails(vaccination, isVaccination: true);
            },
          ),
          if (vaccination['status'] == 'Agendada') ...[
            ListTile(
              leading: const Icon(Icons.check, color: Colors.green),
              title: const Text('Marcar como aplicada'),
              onTap: () {
                Navigator.pop(context);
                _markAsApplied(vaccination['id'], isVaccination: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancelar vacinação'),
              onTap: () {
                Navigator.pop(context);
                _cancelItem(vaccination['id'], isVaccination: true);
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showMedicationOptions(Map<String, dynamic> medication) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Ver Detalhes'),
            onTap: () {
              Navigator.pop(context);
              _showDetails(medication, isVaccination: false);
            },
          ),
          if (medication['status'] == 'Agendado') ...[
            ListTile(
              leading: const Icon(Icons.check, color: Colors.green),
              title: const Text('Marcar como aplicado'),
              onTap: () {
                Navigator.pop(context);
                _markAsApplied(medication['id'], isVaccination: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancelar medicamento'),
              onTap: () {
                Navigator.pop(context);
                _cancelItem(medication['id'], isVaccination: false);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _AddMedicationDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const _AddMedicationDialog({required this.onSaved});

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _notesController = TextEditingController();
  final _dosageController = TextEditingController();
  
  String _type = 'Vacinação';
  String _vaccineType = 'Obrigatória';
  DateTime _scheduledDate = DateTime.now();
  String? _selectedAnimalId;
  
  // INTEGRAÇÃO COM FARMÁCIA
  List<PharmacyStock> _pharmacyStock = [];
  PharmacyStock? _selectedMedication;
  bool _isLoadingStock = false;

  @override
  void initState() {
    super.initState();
    _loadPharmacyStock();
  }

  Future<void> _loadPharmacyStock() async {
    setState(() => _isLoadingStock = true);
    try {
      final stock = await PharmacyService.getPharmacyStock();
      setState(() {
        _pharmacyStock = stock.where((s) => !s.isExpired && s.totalQuantity > 0).toList();
        _isLoadingStock = false;
      });
    } catch (e) {
      setState(() => _isLoadingStock = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final animalService = Provider.of<AnimalService>(context);
    final sortedAnimals = [...animalService.animals];
    AnimalDisplayUtils.sortAnimalsList(sortedAnimals);
    
    return AlertDialog(
      title: const Text('Agendar Vacinação/Medicamento'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tipo
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Vacinação', 'Medicamento'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _type = value!);
                  },
                ),
                const SizedBox(height: 16),
                
                // Animal
                DropdownButtonFormField<String>(
                  value: _selectedAnimalId,
                  decoration: const InputDecoration(
                    labelText: 'Animal *',
                    border: OutlineInputBorder(),
                  ),
                  items: sortedAnimals.map((animal) {
                    return DropdownMenuItem(
                      value: animal.id,
                      child: AnimalDisplayUtils.buildDropdownItem(animal),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedAnimalId = value);
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Selecione um animal';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Nome (Vacinação) ou Dropdown de Medicamentos da Farmácia
                if (_type == 'Vacinação')
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Vacina *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Campo obrigatório';
                      return null;
                    },
                  )
                else ...[
                  // DROPDOWN DE MEDICAMENTOS DA FARMÁCIA
                  DropdownButtonFormField<PharmacyStock>(
                    value: _selectedMedication,
                    decoration: const InputDecoration(
                      labelText: 'Medicamento da Farmácia *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_pharmacy),
                    ),
                    hint: _isLoadingStock 
                        ? const Text('Carregando...') 
                        : Text('Selecione (${_pharmacyStock.length} disponíveis)'),
                    items: _pharmacyStock.map((stock) {
                      return DropdownMenuItem(
                        value: stock,
                        child: Text(
                          '${stock.medicationName} (${stock.totalQuantity.toStringAsFixed(1)} ${stock.unitOfMeasure})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMedication = value;
                        _nameController.text = value?.medicationName ?? '';
                        // Pré-preencher dosagem com unidade de medida
                        if (value != null) {
                          _dosageController.text = value.unitOfMeasure;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecione um medicamento';
                      return null;
                    },
                  ),
                  if (_selectedMedication != null && _selectedMedication!.isLowStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Estoque baixo! Apenas ${_selectedMedication!.totalQuantity.toStringAsFixed(1)} ${_selectedMedication!.unitOfMeasure} disponível(is)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                
                // Tipo de vacina ou dosagem
                if (_type == 'Vacinação')
                  DropdownButtonFormField<String>(
                    value: _vaccineType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Vacina',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Obrigatória', 'Preventiva', 'Tratamento', 'Emergencial']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _vaccineType = value!);
                    },
                  )
                else
                  TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosagem',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 5ml, 2 comprimidos',
                    ),
                  ),
                const SizedBox(height: 16),
                
                // Data
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _scheduledDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data Agendada *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_scheduledDate.day.toString().padLeft(2, '0')}/${_scheduledDate.month.toString().padLeft(2, '0')}/${_scheduledDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Veterinário
                TextFormField(
                  controller: _veterinarianController,
                  decoration: const InputDecoration(
                    labelText: 'Veterinário',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Observações
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Agendar'),
        ),
      ],
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate() || _selectedAnimalId == null) return;

    // VALIDAÇÃO DE ESTOQUE para medicamentos
    if (_type == 'Medicamento') {
      if (_selectedMedication == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um medicamento da farmácia'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Extrair quantidade da dosagem
      final dosageText = _dosageController.text.trim();
      final quantityMatch = RegExp(r'[\d.,]+').firstMatch(dosageText);
      if (quantityMatch != null) {
        final quantityUsed = double.tryParse(quantityMatch.group(0)!.replaceAll(',', '.')) ?? 0;
        if (quantityUsed > _selectedMedication!.totalQuantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Estoque insuficiente! Disponível: ${_selectedMedication!.totalQuantity.toStringAsFixed(1)} ${_selectedMedication!.unitOfMeasure}',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    try {
      final now = DateTime.now().toIso8601String();
      
      if (_type == 'Vacinação') {
        final vaccination = {
          'id': const Uuid().v4(),
          'animal_id': _selectedAnimalId!,
          'vaccine_name': _nameController.text,
          'vaccine_type': _vaccineType,
          'scheduled_date': _scheduledDate.toIso8601String().split('T')[0],
          'veterinarian': _veterinarianController.text.isEmpty ? null : _veterinarianController.text,
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
          'status': 'Agendada',
          'created_at': now,
          'updated_at': now,
        };
        await DatabaseService.createVaccination(vaccination);
      } else {
        // Medicamento - INCLUIR REFERÊNCIA DA FARMÁCIA
        final dosageText = _dosageController.text.trim();
        final quantityMatch = RegExp(r'[\d.,]+').firstMatch(dosageText);
        final quantityUsed = quantityMatch != null 
            ? double.tryParse(quantityMatch.group(0)!.replaceAll(',', '.')) 
            : null;

        final medication = {
          'id': const Uuid().v4(),
          'animal_id': _selectedAnimalId!,
          'medication_name': _nameController.text,
          'date': _scheduledDate.toIso8601String().split('T')[0],
          'next_date': _scheduledDate.add(const Duration(days: 30)).toIso8601String().split('T')[0],
          'dosage': _dosageController.text.isEmpty ? null : _dosageController.text,
          'veterinarian': _veterinarianController.text.isEmpty ? null : _veterinarianController.text,
          'notes': _notesController.text.isEmpty ? null : _notesController.text,
          'status': 'Agendado',
          'pharmacy_stock_id': _selectedMedication?.id,
          'quantity_used': quantityUsed,
          'created_at': now,
        };
        await DatabaseService.createMedication(medication);
      }
      
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_type} agendada com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _veterinarianController.dispose();
    _notesController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}

class _DetailsDialog extends StatelessWidget {
  final Map<String, dynamic> data;
  final dynamic animal;
  final bool isVaccination;

  const _DetailsDialog({
    required this.data,
    required this.animal,
    required this.isVaccination,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isVaccination
        ? (data['status'] == 'Aplicada'
            ? Colors.green
            : data['status'] == 'Cancelada'
                ? Colors.red
                : Colors.orange)
        : const Color(0xFF6366F1);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isVaccination ? Icons.vaccines : Icons.medication,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVaccination ? 'Detalhes da Vacinação' : 'Detalhes do Medicamento',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isVaccination
                              ? data['vaccine_name'] ?? 'Sem nome'
                              : data['medication_name'] ?? 'Sem nome',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animal
                    _buildDetailSection(
                      icon: Icons.pets,
                      title: 'Animal',
                      content: '${animal.name} (${animal.code})',
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),

                    // Nome
                    _buildDetailSection(
                      icon: isVaccination ? Icons.vaccines : Icons.medication,
                      title: isVaccination ? 'Nome da Vacina' : 'Nome do Medicamento',
                      content: isVaccination
                          ? data['vaccine_name'] ?? 'N/A'
                          : data['medication_name'] ?? 'N/A',
                      color: accentColor,
                    ),
                    const SizedBox(height: 16),

                    // Tipo ou Dosagem
                    if (isVaccination) ...[
                      _buildDetailSection(
                        icon: Icons.category,
                        title: 'Tipo de Vacina',
                        content: data['vaccine_type'] ?? 'N/A',
                        color: accentColor,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.info_outline,
                        title: 'Status',
                        content: data['status'] ?? 'N/A',
                        color: accentColor,
                      ),
                    ] else ...[
                      _buildDetailSection(
                        icon: Icons.medication_liquid,
                        title: 'Dosagem',
                        content: data['dosage'] ?? 'N/A',
                        color: accentColor,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Datas
                    _buildDetailSection(
                      icon: Icons.calendar_today,
                      title: isVaccination ? 'Data Agendada' : 'Data de Aplicação',
                      content: _formatDate(
                          isVaccination ? data['scheduled_date'] : data['date']),
                      color: accentColor,
                    ),
                    if (isVaccination && data['applied_date'] != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.event_available,
                        title: 'Data de Aplicação',
                        content: _formatDate(data['applied_date']),
                        color: accentColor,
                      ),
                    ],
                    if (!isVaccination && data['next_date'] != null) ...[
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        icon: Icons.event_repeat,
                        title: 'Próxima Aplicação',
                        content: _formatDate(data['next_date']),
                        color: accentColor,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Veterinário
                    if (data['veterinarian'] != null &&
                        data['veterinarian'].toString().isNotEmpty)
                      _buildDetailSection(
                        icon: Icons.person,
                        title: 'Veterinário',
                        content: data['veterinarian'],
                        color: accentColor,
                      ),
                    if (data['veterinarian'] != null &&
                        data['veterinarian'].toString().isNotEmpty)
                      const SizedBox(height: 16),

                    // Observações
                    if (data['notes'] != null && data['notes'].toString().isNotEmpty)
                      _buildDetailSection(
                        icon: Icons.notes,
                        title: 'Observações',
                        content: data['notes'],
                        color: accentColor,
                        isMultiline: true,
                      ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (e) {
      return date.toString();
    }
  }

  Widget _buildAnimalChip(Map<String, dynamic> animalData) {
    final colorKey = animalData['name_color'] ?? '';
    final colorName = _getColorName(colorKey);
    final colorValue = _getColorValue(colorKey);
    final name = animalData['name'] ?? 'Sem nome';
    final code = animalData['code'] ?? '';
    
    return Chip(
      avatar: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: colorValue,
          shape: BoxShape.circle,
          border: colorKey == 'white' 
              ? Border.all(color: Colors.grey, width: 1)
              : null,
        ),
      ),
      label: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black),
          children: [
            TextSpan(text: '$colorName - '),
            TextSpan(
              text: name,
              style: TextStyle(color: colorValue, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ($code)'),
          ],
        ),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }

  String _getColorName(String colorKey) {
    const colorNames = {
      'blue': 'Azul',
      'red': 'Vermelho',
      'green': 'Verde',
      'yellow': 'Amarelo',
      'orange': 'Laranja',
      'purple': 'Roxo',
      'pink': 'Rosa',
      'grey': 'Cinza',
      'white': 'Branca',
      'black': 'Preto',
    };
    return colorNames[colorKey] ?? 'Sem cor';
  }

  Color _getColorValue(String colorKey) {
    const colorValues = {
      'blue': Colors.blue,
      'red': Colors.red,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'grey': Colors.grey,
      'white': Colors.white,
      'black': Colors.black,
    };
    return colorValues[colorKey] ?? Colors.grey;
  }
}