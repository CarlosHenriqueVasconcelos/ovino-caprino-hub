import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../models/breeding_record.dart';
import '../services/database_service.dart';
import 'breeding_wizard_dialog.dart';
import 'breeding_stage_actions.dart';
import 'breeding_import_dialog.dart';

class BreedingManagementScreen extends StatefulWidget {
  const BreedingManagementScreen({super.key});

  @override
  State<BreedingManagementScreen> createState() => _BreedingManagementScreenState();
}

class _BreedingManagementScreenState extends State<BreedingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BreedingRecord> _breedingRecords = [];
  Map<String, Animal> _animalsMap = {};
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final [breedingData, animalsData] = await Future.wait([
        DatabaseService.getBreedingRecords(),
        DatabaseService.getAnimals(),
      ]);

      final animals = (animalsData as List<Animal>);
      final animalsMap = {for (var a in animals) a.id: a};

      final records = (breedingData as List<Map<String, dynamic>>)
          .map((e) => BreedingRecord.fromMap(e))
          .toList();

      setState(() {
        _breedingRecords = records;
        _animalsMap = animalsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  List<BreedingRecord> _filterByStage(BreedingStage stage) {
    var records = _breedingRecords.where((r) => r.stage == stage).toList();
    
    if (_searchQuery.isNotEmpty) {
      records = records.where((r) {
        final female = _animalsMap[r.femaleAnimalId];
        if (female == null) return false;
        final searchLower = _searchQuery.toLowerCase();
        return female.code.toLowerCase().contains(searchLower) ||
               female.name.toLowerCase().contains(searchLower);
      }).toList();
    }
    
    return records;
  }

  void _showBreedingWizard() {
    showDialog(
      context: context,
      builder: (context) => BreedingWizardDialog(
        onComplete: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.pets, color: Colors.green.shade700, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestão de Reprodução',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Controle completo do ciclo reprodutivo',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showBreedingWizard,
                    icon: const Icon(Icons.add),
                    label: const Text('Nova Cobertura'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    tooltip: 'Adicionar registro existente',
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => const BreedingImportDialog(),
                      );
                      if (ok == true) {
                        _loadData(); // seu método que recarrega os cards
                      }
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por número ou nome da mãe...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green,
                tabs: [
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.favorite),
                        const SizedBox(width: 8),
                        Text('Encabritamento (${_filterByStage(BreedingStage.encabritamento).length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services),
                        const SizedBox(width: 8),
                        Text('Aguardando Ultrassom (${_filterByStage(BreedingStage.aguardandoUltrassom).length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.pregnant_woman),
                        const SizedBox(width: 8),
                        Text('Gestantes (${_filterByStage(BreedingStage.gestacaoConfirmada).length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle),
                        const SizedBox(width: 8),
                        Text('Concluídos (${_filterByStage(BreedingStage.partoRealizado).length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      children: [
                        const Icon(Icons.cancel),
                        const SizedBox(width: 8),
                        Text('Falhados (${_filterByStage(BreedingStage.falhou).length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildStageList(BreedingStage.encabritamento),
                        _buildStageList(BreedingStage.aguardandoUltrassom),
                        _buildStageList(BreedingStage.gestacaoConfirmada),
                        _buildStageList(BreedingStage.partoRealizado),
                        _buildStageList(BreedingStage.falhou),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageList(BreedingStage stage) {
    final records = _filterByStage(stage);

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro nesta etapa',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return _buildBreedingCard(records[index]);
      },
    );
  }

  Widget _buildBreedingCard(BreedingRecord record) {
    final female = _animalsMap[record.femaleAnimalId];
    final male = _animalsMap[record.maleAnimalId];
    final progress = record.progressPercentage();
    final daysLeft = record.daysRemaining();

    Color stageColor;
    IconData stageIcon;

    switch (record.stage) {
      case BreedingStage.encabritamento:
        stageColor = Colors.orange;
        stageIcon = Icons.favorite;
        break;
      case BreedingStage.aguardandoUltrassom:
        stageColor = Colors.blue;
        stageIcon = Icons.medical_services;
        break;
      case BreedingStage.gestacaoConfirmada:
        stageColor = Colors.purple;
        stageIcon = Icons.pregnant_woman;
        break;
      case BreedingStage.partoRealizado:
        stageColor = Colors.green;
        stageIcon = Icons.check_circle;
        break;
      case BreedingStage.falhou:
        stageColor = Colors.red;
        stageIcon = Icons.cancel;
        break;
      default:
        stageColor = Colors.grey;
        stageIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stageColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(stageIcon, color: stageColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.stage.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: stageColor,
                        ),
                      ),
                      Text(
                        'Iniciado em ${_formatDate(record.matingStartDate ?? record.breedingDate)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Animals Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fêmea',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        female != null ? '${female.code} - ${female.name}' : 'N/A',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Macho',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        male != null ? '${male.code} - ${male.name}' : 'N/A',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Progress and Days
            if (progress != null && daysLeft != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progresso',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              daysLeft >= 0 ? '$daysLeft dias restantes' : '${-daysLeft} dias atrasado',
                              style: TextStyle(
                                color: daysLeft >= 0 ? Colors.green : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Expected/Actual Dates
            if (record.stage == BreedingStage.encabritamento && record.matingEndDate != null) ...[
              const SizedBox(height: 12),
              _buildDateInfo('Data de Separação', record.matingEndDate!),
            ],
            if (record.stage == BreedingStage.gestacaoConfirmada && record.expectedBirth != null) ...[
              const SizedBox(height: 12),
              _buildDateInfo('Previsão de Parto', record.expectedBirth!),
            ],
            if (record.stage == BreedingStage.partoRealizado && record.birthDate != null) ...[
              const SizedBox(height: 12),
              _buildDateInfo('Data do Parto', record.birthDate!),
            ],

            // Notes
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.notes!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Button
            if (record.stage != BreedingStage.partoRealizado &&
                record.stage != BreedingStage.falhou) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: BreedingStageActions(
                  record: record,
                  onUpdate: _loadData,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            _formatDate(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
