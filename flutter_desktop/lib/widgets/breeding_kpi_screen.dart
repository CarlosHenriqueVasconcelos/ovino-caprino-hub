import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/breeding_record.dart';
import '../models/animal.dart';

class BreedingKpiScreen extends StatefulWidget {
  const BreedingKpiScreen({super.key});

  @override
  State<BreedingKpiScreen> createState() => _BreedingKpiScreenState();
}

class _BreedingKpiScreenState extends State<BreedingKpiScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _kpis = {};

  @override
  void initState() {
    super.initState();
    _loadKpis();
  }

  Future<void> _loadKpis() async {
    setState(() => _isLoading = true);
    
    try {
      final breedingRecordsData = await DatabaseService.getBreedingRecords();
      final records = breedingRecordsData.map((m) => BreedingRecord.fromMap(m)).toList();
      final animals = await DatabaseService.getAnimals();
      
      // Taxa de concepção: (gestações confirmadas / coberturas) × 100
      final totalBreedings = records.length;
      final confirmedPregnancies = records.where((r) => 
        r.stage == BreedingStage.gestacaoConfirmada || 
        r.stage == BreedingStage.partoRealizado
      ).length;
      final conceptionRate = totalBreedings > 0 
        ? (confirmedPregnancies / totalBreedings * 100) 
        : 0.0;

      // Taxa de natalidade: (nascimentos / fêmeas cobertas) × 100
      final births = records.where((r) => r.stage == BreedingStage.partoRealizado).length;
      final femalesCovered = records.map((r) => r.femaleAnimalId).toSet().length;
      final birthRate = femalesCovered > 0 
        ? (births / femalesCovered * 100) 
        : 0.0;

      // Taxa de prolificidade: (filhotes nascidos / partos) × 100
      final totalLambs = records
        .where((r) => r.lambsCount != null)
        .fold<int>(0, (sum, r) => sum + (r.lambsCount ?? 0));
      final totalBirths = records.where((r) => r.lambsCount != null).length;
      final prolificacy = totalBirths > 0 
        ? (totalLambs / totalBirths) 
        : 0.0;

      // Intervalo médio entre partos
      final femalesWithMultipleBirths = <String, List<DateTime>>{};
      for (final record in records.where((r) => r.birthDate != null)) {
        if (record.femaleAnimalId != null) {
          femalesWithMultipleBirths.putIfAbsent(
            record.femaleAnimalId!, 
            () => []
          ).add(record.birthDate!);
        }
      }
      
      double avgIntervalDays = 0.0;
      int intervalCount = 0;
      for (final dates in femalesWithMultipleBirths.values) {
        if (dates.length >= 2) {
          dates.sort();
          for (int i = 1; i < dates.length; i++) {
            avgIntervalDays += dates[i].difference(dates[i - 1]).inDays;
            intervalCount++;
          }
        }
      }
      final avgBirthInterval = intervalCount > 0 
        ? (avgIntervalDays / intervalCount) 
        : 0.0;

      // Fêmeas em anestro (sem cio detectado há mais de 60 dias)
      final now = DateTime.now();
      final reproductiveFemales = animals.where((a) => 
        a.gender == 'Fêmea' && 
        a.category == 'Reprodutor'
      ).toList();
      
      int anestroCount = 0;
      for (final female in reproductiveFemales) {
        final lastHeat = records
          .where((r) => r.femaleAnimalId == female.id && r.heatDetectedDate != null)
          .fold<DateTime?>(null, (latest, r) {
            if (latest == null) return r.heatDetectedDate;
            return r.heatDetectedDate!.isAfter(latest) ? r.heatDetectedDate : latest;
          });
        
        if (lastHeat == null || now.difference(lastHeat).inDays > 60) {
          anestroCount++;
        }
      }

      // Gestações ativas
      final activePregnancies = records.where((r) => 
        r.stage == BreedingStage.gestacaoConfirmada
      ).length;

      // Partos esperados próximos (30 dias)
      final upcomingBirths = records.where((r) => 
        r.stage == BreedingStage.gestacaoConfirmada && 
        r.expectedBirth != null &&
        r.expectedBirth!.difference(now).inDays <= 30 &&
        r.expectedBirth!.isAfter(now)
      ).length;

      setState(() {
        _kpis = {
          'conceptionRate': conceptionRate,
          'birthRate': birthRate,
          'prolificacy': prolificacy,
          'avgBirthInterval': avgBirthInterval,
          'anestroCount': anestroCount,
          'activePregnancies': activePregnancies,
          'upcomingBirths': upcomingBirths,
          'totalBreedings': totalBreedings,
          'totalBirths': births,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar KPIs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indicadores Reprodutivos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKpis,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadKpis,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Reprodutiva',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Cards de KPIs principais
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildKpiCard(
                        'Taxa de Concepção',
                        '${_kpis['conceptionRate']?.toStringAsFixed(1) ?? '0.0'}%',
                        Icons.trending_up,
                        _getColorForRate(_kpis['conceptionRate'] ?? 0),
                        'Gestações confirmadas / Total de coberturas',
                      ),
                      _buildKpiCard(
                        'Taxa de Natalidade',
                        '${_kpis['birthRate']?.toStringAsFixed(1) ?? '0.0'}%',
                        Icons.child_care,
                        _getColorForRate(_kpis['birthRate'] ?? 0),
                        'Partos / Fêmeas cobertas',
                      ),
                      _buildKpiCard(
                        'Prolificidade',
                        _kpis['prolificacy']?.toStringAsFixed(2) ?? '0.00',
                        Icons.people,
                        theme.colorScheme.secondary,
                        'Média de filhotes por parto',
                      ),
                      _buildKpiCard(
                        'Intervalo entre Partos',
                        '${_kpis['avgBirthInterval']?.toStringAsFixed(0) ?? '0'} dias',
                        Icons.calendar_today,
                        theme.colorScheme.tertiary,
                        'Média de dias entre partos',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Status Atual',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Cards de status
                  _buildStatusCard(
                    'Gestações Ativas',
                    _kpis['activePregnancies']?.toString() ?? '0',
                    Icons.pregnant_woman,
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusCard(
                    'Partos Esperados (30 dias)',
                    _kpis['upcomingBirths']?.toString() ?? '0',
                    Icons.event_available,
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusCard(
                    'Fêmeas em Anestro',
                    _kpis['anestroCount']?.toString() ?? '0',
                    Icons.warning_amber,
                    _kpis['anestroCount'] > 0 ? Colors.red : Colors.green,
                    subtitle: 'Sem cio há mais de 60 dias',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Resumo Geral',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryRow('Total de Coberturas', _kpis['totalBreedings']?.toString() ?? '0'),
                          const Divider(),
                          _buildSummaryRow('Total de Partos', _kpis['totalBirths']?.toString() ?? '0'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForRate(double rate) {
    if (rate >= 70) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }
}
