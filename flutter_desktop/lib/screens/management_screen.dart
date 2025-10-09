import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/animal_service.dart';
import '../services/database_service.dart';
import '../widgets/vaccination_form.dart';
import '../widgets/breeding_form.dart';
import '../widgets/notes_form.dart';
import '../widgets/financial_form.dart';

/// Formata uma data do formato yyyy-MM-dd para dd/MM/yyyy
String _formatDateFromDb(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    return dateStr;
  }
}

class ManagementScreen extends StatefulWidget {
  /// 0: Vacinações, 1: Reprodução, 2: Anotações, 3: Financeiro
  final int initialTab;
  const ManagementScreen({super.key, this.initialTab = 0});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final idx = widget.initialTab.clamp(0, 3);
    _tabController = TabController(length: 4, vsync: this, initialIndex: idx);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão da Fazenda'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.vaccines), text: 'Vacinações'),
            Tab(icon: Icon(Icons.favorite), text: 'Reprodução'),
            Tab(icon: Icon(Icons.notes), text: 'Anotações'),
            Tab(icon: Icon(Icons.attach_money), text: 'Financeiro'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _VaccinationsTab(),
          _BreedingTab(),
          _NotesTab(),
          _FinancialTab(),
        ],
      ),
    );
  }
}

class _VaccinationsTab extends StatefulWidget {
  const _VaccinationsTab();

  @override
  State<_VaccinationsTab> createState() => _VaccinationsTabState();
}

class _VaccinationsTabState extends State<_VaccinationsTab> {
  List<Map<String, dynamic>> _vaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    setState(() => _isLoading = true);
    try {
      _vaccinations = await DatabaseService.getVaccinations();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading vaccinations: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Controle de Vacinações',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const VaccinationFormDialog(),
                  ).then((_) => _loadVaccinations());
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova Vacinação'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vaccinations.isEmpty
                    ? _emptyState(
                        icon: Icons.vaccines_outlined,
                        text: 'Nenhuma vacinação registrada',
                        theme: theme,
                      )
                    : ListView.builder(
                        itemCount: _vaccinations.length,
                        itemBuilder: (context, index) {
                          final vaccination = _vaccinations[index];
                          final animalService =
                              Provider.of<AnimalService>(context, listen: false);

                          // Buscar animal por id
                          final animalMatches = animalService.animals.where(
                            (a) => a.id == vaccination['animal_id'],
                          );
                          final animalFound =
                              animalMatches.isNotEmpty ? animalMatches.first : null;

                          Color statusColor;
                          switch (vaccination['status']) {
                            case 'Aplicada':
                              statusColor = theme.colorScheme.primary;
                              break;
                            case 'Agendada':
                              statusColor = theme.colorScheme.tertiary;
                              break;
                            case 'Cancelada':
                              statusColor = theme.colorScheme.error;
                              break;
                            default:
                              statusColor = theme.colorScheme.secondary;
                          }

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withOpacity(0.1),
                                child: Icon(Icons.vaccines, color: statusColor),
                              ),
                              title: Text(vaccination['vaccine_name'] ?? '-'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (animalFound != null)
                                    Text('Animal: ${animalFound.name} (${animalFound.code})'),
                                  Text('Tipo: ${vaccination['vaccine_type'] ?? '-'}'),
                                  Text('Agendada: ${_formatDateFromDb(vaccination['scheduled_date'])}'),
                                  if (vaccination['applied_date'] != null)
                                    Text('Aplicada: ${_formatDateFromDb(vaccination['applied_date'])}'),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(vaccination['status'] ?? '-'),
                                backgroundColor: statusColor.withOpacity(0.1),
                                side: BorderSide(color: statusColor),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _BreedingTab extends StatefulWidget {
  const _BreedingTab();

  @override
  State<_BreedingTab> createState() => _BreedingTabState();
}

class _BreedingTabState extends State<_BreedingTab> {
  List<Map<String, dynamic>> _breedingRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBreedingRecords();
  }

  Future<void> _loadBreedingRecords() async {
    setState(() => _isLoading = true);
    try {
      _breedingRecords = await DatabaseService.getBreedingRecords();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading breeding records: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Controle Reprodutivo',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const BreedingFormDialog(),
                  ).then((_) => _loadBreedingRecords());
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova Cobertura'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _breedingRecords.isEmpty
                    ? _emptyState(
                        icon: Icons.favorite_outline,
                        text: 'Nenhum registro reprodutivo',
                        theme: theme,
                      )
                    : ListView.builder(
                        itemCount: _breedingRecords.length,
                        itemBuilder: (context, index) {
                          final breeding = _breedingRecords[index];
                          final animalService =
                              Provider.of<AnimalService>(context, listen: false);

                          // Fêmea
                          final femaleMatches = animalService.animals.where(
                            (a) => a.id == breeding['female_animal_id'],
                          );
                          final female =
                              femaleMatches.isNotEmpty ? femaleMatches.first : null;

                          // Macho (só busca se tiver id)
                          final maleId = breeding['male_animal_id'];
                          var male;
                          if (maleId != null) {
                            final maleMatches = animalService.animals.where(
                              (a) => a.id == maleId,
                            );
                            male = maleMatches.isNotEmpty ? maleMatches.first : null;
                          }

                          Color statusColor;
                          switch (breeding['status']) {
                            case 'Nasceu':
                              statusColor = theme.colorScheme.primary;
                              break;
                            case 'Confirmada':
                              statusColor = theme.colorScheme.tertiary;
                              break;
                            case 'Perdida':
                              statusColor = theme.colorScheme.error;
                              break;
                            default:
                              statusColor = theme.colorScheme.secondary;
                          }

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withOpacity(0.1),
                                child: Icon(Icons.favorite, color: statusColor),
                              ),
                              title: Text(female?.name ?? 'Animal não encontrado'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (male != null)
                                    Text('Macho: ${male.name} (${male.code})'),
                                  Text('Data: ${_formatDateFromDb(breeding['breeding_date'])}'),
                                  if (breeding['expected_birth'] != null)
                                    Text('Previsão: ${_formatDateFromDb(breeding['expected_birth'])}'),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(breeding['status'] ?? '-'),
                                backgroundColor: statusColor.withOpacity(0.1),
                                side: BorderSide(color: statusColor),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _NotesTab extends StatefulWidget {
  const _NotesTab();

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      _notes = await DatabaseService.getNotes();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading notes: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Anotações',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const NotesFormDialog(),
                  ).then((_) => _loadNotes());
                },
                icon: const Icon(Icons.add),
                label: const Text('Nova Anotação'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? _emptyState(
                        icon: Icons.notes_outlined,
                        text: 'Nenhuma anotação registrada',
                        theme: theme,
                      )
                    : ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          final animalService =
                              Provider.of<AnimalService>(context, listen: false);

                          // Animal da anotação (se houver)
                          final noteAnimalId = note['animal_id'];
                          var animal;
                          if (noteAnimalId != null) {
                            final matches = animalService.animals.where(
                              (a) => a.id == noteAnimalId,
                            );
                            animal = matches.isNotEmpty ? matches.first : null;
                          }

                          Color priorityColor;
                          IconData priorityIcon;
                          switch (note['priority']) {
                            case 'Alta':
                              priorityColor = theme.colorScheme.error;
                              priorityIcon = Icons.priority_high;
                              break;
                            case 'Média':
                              priorityColor = theme.colorScheme.tertiary;
                              priorityIcon = Icons.remove;
                              break;
                            default:
                              priorityColor = theme.colorScheme.primary;
                              priorityIcon = Icons.low_priority;
                          }

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: priorityColor.withOpacity(0.1),
                                child: Icon(priorityIcon, color: priorityColor),
                              ),
                              title: Text(note['title'] ?? '-'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Categoria: ${note['category'] ?? '-'}'),
                                  if (animal != null)
                                    Text('Animal: ${animal.name} (${animal.code})'),
                                  if ((note['content'] ?? '').toString().isNotEmpty)
                                    Text(
                                      note['content'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Text('Data: ${_formatDateFromDb(note['date'])}'),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(note['priority'] ?? '-'),
                                backgroundColor: priorityColor.withOpacity(0.1),
                                side: BorderSide(color: priorityColor),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FinancialTab extends StatefulWidget {
  const _FinancialTab();

  @override
  State<_FinancialTab> createState() => _FinancialTabState();
}

class _FinancialTabState extends State<_FinancialTab> {
  List<Map<String, dynamic>> _financialRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialRecords();
  }

  Future<void> _loadFinancialRecords() async {
    setState(() => _isLoading = true);
    try {
      _financialRecords = await DatabaseService.getFinancialRecords();
    } catch (e) {
      // ignore: avoid_print
      print('Error loading financial records: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double totalReceitas = 0;
    double totalDespesas = 0;
    for (final record in _financialRecords) {
      final amount = (record['amount'] as num?)?.toDouble() ?? 0.0;
      if (record['type'] == 'receita') {
        totalReceitas += amount;
      } else {
        totalDespesas += amount;
      }
    }
    final saldo = totalReceitas - totalDespesas;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Controle Financeiro',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const FinancialFormDialog(),
                  ).then((_) => _loadFinancialRecords());
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo Lançamento'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text('Receitas', style: theme.textTheme.titleMedium),
                        Text(
                          'R\$ ${totalReceitas.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
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
                  color: theme.colorScheme.error.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.trending_down, color: theme.colorScheme.error),
                        const SizedBox(height: 8),
                        Text('Despesas', style: theme.textTheme.titleMedium),
                        Text(
                          'R\$ ${totalDespesas.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.error,
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
                  color: (saldo >= 0
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.error)
                      .withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          saldo >= 0 ? Icons.account_balance_wallet : Icons.warning,
                          color: saldo >= 0
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text('Saldo', style: theme.textTheme.titleMedium),
                        Text(
                          'R\$ ${saldo.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: saldo >= 0
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.error,
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
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _financialRecords.isEmpty
                    ? _emptyState(
                        icon: Icons.attach_money_outlined,
                        text: 'Nenhum registro financeiro',
                        theme: theme,
                      )
                    : ListView.builder(
                        itemCount: _financialRecords.length,
                        itemBuilder: (context, index) {
                          final record = _financialRecords[index];
                          final isReceita = record['type'] == 'receita';
                          final color = isReceita
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.1),
                                child: Icon(
                                  isReceita
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: color,
                                ),
                              ),
                              title: Text(record['category'] ?? '-'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((record['description'] ?? '').toString().isNotEmpty)
                                    Text(record['description']),
                                  Text('Data: ${_formatDateFromDb(record['date'])}'),
                                ],
                              ),
                              trailing: Text(
                                'R\$ ${(record['amount'] as num?)?.toStringAsFixed(2) ?? '0,00'}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

Widget _emptyState({
  required IconData icon,
  required String text,
  required ThemeData theme,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}
