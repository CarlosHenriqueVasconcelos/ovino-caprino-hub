import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsFilterPanel extends StatelessWidget {
  final ThemeData theme;
  final String currentReport;
  final String periodPreset;
  final DateTime customStart;
  final DateTime customEnd;
  final ValueChanged<String> onPeriodPresetChanged;
  final VoidCallback onSelectCustomStart;
  final VoidCallback onSelectCustomEnd;
  final VoidCallback onApplyCustomRange;
  final String speciesFilter;
  final ValueChanged<String> onSpeciesChanged;
  final String genderFilter;
  final ValueChanged<String> onGenderChanged;
  final String statusFilter;
  final ValueChanged<String> onStatusChanged;
  final String medicationStatusFilter;
  final ValueChanged<String> onMedicationStatusChanged;
  final String breedingStageFilter;
  final ValueChanged<String> onBreedingStageChanged;
  final String financialTypeFilter;
  final ValueChanged<String> onFinancialTypeChanged;
  final String notesIsReadFilter;
  final ValueChanged<String> onNotesReadChanged;
  final String notesPriorityFilter;
  final ValueChanged<String> onNotesPriorityChanged;

  const ReportsFilterPanel({
    super.key,
    required this.theme,
    required this.currentReport,
    required this.periodPreset,
    required this.customStart,
    required this.customEnd,
    required this.onPeriodPresetChanged,
    required this.onSelectCustomStart,
    required this.onSelectCustomEnd,
    required this.onApplyCustomRange,
    required this.speciesFilter,
    required this.onSpeciesChanged,
    required this.genderFilter,
    required this.onGenderChanged,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.medicationStatusFilter,
    required this.onMedicationStatusChanged,
    required this.breedingStageFilter,
    required this.onBreedingStageChanged,
    required this.financialTypeFilter,
    required this.onFinancialTypeChanged,
    required this.notesIsReadFilter,
    required this.onNotesReadChanged,
    required this.notesPriorityFilter,
    required this.onNotesPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filtros', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: periodPreset,
                  decoration: const InputDecoration(
                    labelText: 'Período',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'last7',
                      child: Text('Últimos 7 dias'),
                    ),
                    DropdownMenuItem(
                      value: 'last30',
                      child: Text('Últimos 30 dias'),
                    ),
                    DropdownMenuItem(
                      value: 'last90',
                      child: Text('Últimos 90 dias'),
                    ),
                    DropdownMenuItem(
                      value: 'currentMonth',
                      child: Text('Mês atual'),
                    ),
                    DropdownMenuItem(
                      value: 'currentYear',
                      child: Text('Ano atual'),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text('Personalizado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) onPeriodPresetChanged(value);
                  },
                ),
              ),
              if (periodPreset == 'custom') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: onSelectCustomStart,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data inicial',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(customStart)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: onSelectCustomEnd,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data final',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(customEnd)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onApplyCustomRange,
                  icon: const Icon(Icons.check),
                  label: const Text('Aplicar'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              if (currentReport == 'Animais' ||
                  currentReport == 'Pesos' ||
                  currentReport == 'Reprodução')
                _dropdown(
                  label: 'Espécie',
                  value: speciesFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'Ovino', child: Text('Ovino')),
                    DropdownMenuItem(value: 'Caprino', child: Text('Caprino')),
                  ],
                  onChanged: onSpeciesChanged,
                ),
              if (currentReport == 'Animais' ||
                  currentReport == 'Pesos' ||
                  currentReport == 'Reprodução')
                _dropdown(
                  label: 'Gênero',
                  value: genderFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                    DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                  ],
                  onChanged: onGenderChanged,
                ),
              if (currentReport == 'Animais' ||
                  currentReport == 'Pesos' ||
                  currentReport == 'Reprodução')
                _dropdown(
                  label: 'Status',
                  value: statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(
                        value: 'Saudável', child: Text('Saudável')),
                    DropdownMenuItem(
                      value: 'Em tratamento',
                      child: Text('Em tratamento'),
                    ),
                    DropdownMenuItem(
                      value: 'Reprodutor',
                      child: Text('Reprodutor'),
                    ),
                  ],
                  onChanged: onStatusChanged,
                ),
              if (currentReport == 'Vacinações')
                _dropdown(
                  label: 'Status',
                  value: statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(
                        value: 'Agendada', child: Text('Agendada')),
                    DropdownMenuItem(
                        value: 'Aplicada', child: Text('Aplicada')),
                    DropdownMenuItem(
                        value: 'Cancelada', child: Text('Cancelada')),
                  ],
                  onChanged: onStatusChanged,
                ),
              if (currentReport == 'Medicações')
                _dropdown(
                  label: 'Status',
                  value: medicationStatusFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(
                        value: 'Agendado', child: Text('Agendado')),
                    DropdownMenuItem(
                        value: 'Aplicado', child: Text('Aplicado')),
                    DropdownMenuItem(
                        value: 'Cancelado', child: Text('Cancelado')),
                  ],
                  onChanged: onMedicationStatusChanged,
                ),
              if (currentReport == 'Reprodução')
                _dropdown(
                  label: 'Estágio',
                  value: breedingStageFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(
                      value: 'encabritamento',
                      child: Text('Encabritamento'),
                    ),
                    DropdownMenuItem(
                        value: 'cobertura', child: Text('Cobertura')),
                    DropdownMenuItem(
                      value: 'aguardando_ultrassom',
                      child: Text('Aguardando Ultrassom'),
                    ),
                    DropdownMenuItem(
                      value: 'gestacao_confirmada',
                      child: Text('Gestação confirmada'),
                    ),
                    DropdownMenuItem(
                      value: 'parto_realizado',
                      child: Text('Parto realizado'),
                    ),
                    DropdownMenuItem(value: 'falhou', child: Text('Falhou')),
                  ],
                  onChanged: onBreedingStageChanged,
                ),
              if (currentReport == 'Financeiro')
                _dropdown(
                  label: 'Tipo financeiro',
                  value: financialTypeFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'receita', child: Text('Receita')),
                    DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
                  ],
                  onChanged: onFinancialTypeChanged,
                ),
              if (currentReport == 'Anotações') ...[
                _dropdown(
                  label: 'Leitura',
                  value: notesIsReadFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'Lidas', child: Text('Lidas')),
                    DropdownMenuItem(
                        value: 'Não lidas', child: Text('Não lidas')),
                  ],
                  onChanged: onNotesReadChanged,
                ),
                _dropdown(
                  label: 'Prioridade',
                  value: notesPriorityFilter,
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                    DropdownMenuItem(value: 'Média', child: Text('Média')),
                    DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                  ],
                  onChanged: onNotesPriorityChanged,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
