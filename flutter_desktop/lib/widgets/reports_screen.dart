import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/animal_service.dart';
import '../services/supabase_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'Animais';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;
  
  final List<String> _reportTypes = [
    'Animais',
    'Vacinações',
    'Reprodução',
    'Saúde',
    'Financeiro',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Gerador de Relatórios Profissionais',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gere relatórios detalhados sobre a gestão da sua fazenda',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            // Report Configuration
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Configuration Panel
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuração do Relatório',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Report Type
                          DropdownButtonFormField<String>(
                            value: _selectedReportType,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Relatório',
                              border: OutlineInputBorder(),
                            ),
                            items: _reportTypes.map((type) {
                              IconData icon;
                              switch (type) {
                                case 'Animais':
                                  icon = Icons.pets;
                                  break;
                                case 'Vacinações':
                                  icon = Icons.vaccines;
                                  break;
                                case 'Reprodução':
                                  icon = Icons.favorite;
                                  break;
                                case 'Saúde':
                                  icon = Icons.health_and_safety;
                                  break;
                                case 'Financeiro':
                                  icon = Icons.attach_money;
                                  break;
                                default:
                                  icon = Icons.description;
                              }
                              
                              return DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(icon, size: 20),
                                    const SizedBox(width: 8),
                                    Text(type),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedReportType = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Date Range
                          Text(
                            'Período',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Start Date
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _startDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data Inicial',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // End Date
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: _startDate,
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (date != null) {
                                setState(() {
                                  _endDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data Final',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_endDate.day.toString().padLeft(2, '0')}/${_endDate.month.toString().padLeft(2, '0')}/${_endDate.year}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Generate Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isGenerating ? null : _generateReport,
                              icon: _isGenerating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.picture_as_pdf),
                              label: Text(_isGenerating ? 'Gerando...' : 'Gerar Relatório'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                
                // Preview Panel
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Prévia do Relatório: $_selectedReportType',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          Expanded(
                            child: _buildReportPreview(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    final theme = Theme.of(context);
    
    switch (_selectedReportType) {
      case 'Animais':
        return _buildAnimalsPreview();
      case 'Vacinações':
        return _buildVaccinationsPreview();
      case 'Reprodução':
        return _buildBreedingPreview();
      case 'Saúde':
        return _buildHealthPreview();
      case 'Financeiro':
        return _buildFinancialPreview();
      default:
        return Center(
          child: Text(
            'Selecione um tipo de relatório',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        );
    }
  }

  Widget _buildAnimalsPreview() {
    return Consumer<AnimalService>(
      builder: (context, animalService, child) {
        final animals = animalService.animals;
        final theme = Theme.of(context);
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Relatório de Animais - Fazenda São Petrônio',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Período: ${_startDate.day}/${_startDate.month}/${_startDate.year} até ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Summary Stats
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Total de Animais',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '${animals.length}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: theme.colorScheme.tertiary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Ovinos',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '${animals.where((a) => a.species == 'Ovino').length}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Caprinos',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '${animals.where((a) => a.species == 'Caprino').length}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Animals Table
              Text(
                'Lista de Animais',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1),
                  },
                  children: [
                    // Header
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                      children: [
                        'Código',
                        'Nome',
                        'Espécie',
                        'Raça',
                        'Peso',
                        'Status',
                      ].map((text) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )).toList(),
                    ),
                    
                    // Data Rows
                    ...animals.take(10).map((animal) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(animal.code),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(animal.name),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(animal.species),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(animal.breed),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('${animal.weight}kg'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(animal.status),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              
              if (animals.length > 10) ...[
                const SizedBox(height: 8),
                Text(
                  'E mais ${animals.length - 10} animais...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildVaccinationsPreview() {
    // Similar structure for vaccinations report
    return const Center(
      child: Text('Prévia do Relatório de Vacinações'),
    );
  }

  Widget _buildBreedingPreview() {
    // Similar structure for breeding report
    return const Center(
      child: Text('Prévia do Relatório de Reprodução'),
    );
  }

  Widget _buildHealthPreview() {
    // Similar structure for health report
    return const Center(
      child: Text('Prévia do Relatório de Saúde'),
    );
  }

  Widget _buildFinancialPreview() {
    // Similar structure for financial report
    return const Center(
      child: Text('Prévia do Relatório Financeiro'),
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulate report generation
      await Future.delayed(const Duration(seconds: 2));
      
      // Save report to Supabase
      final report = {
        'title': 'Relatório de $_selectedReportType',
        'report_type': _selectedReportType,
        'parameters': {
          'start_date': _startDate.toIso8601String().split('T')[0],
          'end_date': _endDate.toIso8601String().split('T')[0],
        },
        'generated_by': 'Sistema Desktop',
      };

      await SupabaseService.createReport(report);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Relatório gerado com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'Visualizar',
              onPressed: () {
                // Open generated report
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar relatório: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}