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
  Map<String, dynamic>? _reportData;
  
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
      body: SingleChildScrollView(
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
            
            if (_reportData == null) ...[
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
                            _buildDateField(
                              'Data Inicial',
                              _startDate,
                              (date) => setState(() => _startDate = date),
                            ),
                            const SizedBox(height: 16),
                            
                            // End Date
                            _buildDateField(
                              'Data Final',
                              _endDate,
                              (date) => setState(() => _endDate = date),
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
                            
                            SizedBox(
                              height: 400,
                              child: _buildReportPreview(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Generated Report View
              _buildGeneratedReport(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          locale: const Locale('pt', 'BR'),
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (selectedDate != null) {
          onChanged(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
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
        
        return ListView(
          children: [
            Text(
              'Relatório de Animais - Fazenda BEGO',
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
                  child: _buildSummaryCard(
                    'Total de Animais',
                    '${animals.length}',
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Ovinos',
                    '${animals.where((a) => a.species == 'Ovino').length}',
                    theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Caprinos',
                    '${animals.where((a) => a.species == 'Caprino').length}',
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Sample Data Table
            Text(
              'Amostra de Animais (${animals.take(5).length} de ${animals.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...animals.take(5).map((animal) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  animal.species == 'Ovino' ? Icons.pets : Icons.cruelty_free,
                  color: animal.species == 'Ovino' ? theme.colorScheme.primary : theme.colorScheme.secondary,
                ),
                title: Text('${animal.code} - ${animal.name}'),
                subtitle: Text('${animal.species} • ${animal.breed} • ${animal.weight}kg'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: animal.status == 'Saudável' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    animal.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )).toList(),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationsPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.vaccines,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Relatório de Vacinações',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Histórico completo de vacinações aplicadas\ne agendamentos pendentes',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedingPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Relatório de Reprodução',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Controle reprodutivo, gestações em andamento\ne previsões de partos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Relatório de Saúde',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Estado sanitário do rebanho, tratamentos\ne indicadores de saúde',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_money,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Relatório Financeiro',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Análise de custos, receitas\ne rentabilidade do rebanho',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedReport() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _reportData!['title'],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _exportReport,
                  icon: const Icon(Icons.download),
                  label: const Text('Exportar PDF'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() => _reportData = null),
                  child: const Text('Novo Relatório'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Report content would go here
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Conteúdo do relatório gerado'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    if (!mounted) return;
    
    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulate report generation
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _reportData = {
            'title': 'Relatório de $_selectedReportType - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            'type': _selectedReportType,
            'period': '${_startDate.day}/${_startDate.month}/${_startDate.year} - ${_endDate.day}/${_endDate.month}/${_endDate.year}',
          };
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório gerado com sucesso!'),
            backgroundColor: Colors.green,
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

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Relatório exportado como PDF!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}