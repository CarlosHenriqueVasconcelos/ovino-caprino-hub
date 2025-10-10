// lib/widgets/vaccination_alerts.dart
import 'package:flutter/material.dart';
import '../data/local_db.dart';
import 'vaccination_form.dart';

class VaccinationAlerts extends StatefulWidget {
  final VoidCallback onGoToVaccinations;
  const VaccinationAlerts({super.key, required this.onGoToVaccinations});

  @override
  State<VaccinationAlerts> createState() => _VaccinationAlertsState();
}

class _VaccinationAlertsState extends State<VaccinationAlerts> {
  bool _loading = true;
  String? _error;

  // Dados
  List<Map<String, dynamic>> _vaccines = [];
  List<Map<String, dynamic>> _meds = [];

  // Paginação
  static const int _pageSize = 4;
  int _vacPage = 0;
  int _medPage = 0;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final adb = await AppDatabase.open();
      final db = adb.db;

      // Vacinas agendadas (status = 'Agendada')
      final vacs = await db.rawQuery('''
        SELECT v.*, a.name AS animal_name, a.code AS animal_code
        FROM vaccinations v
        LEFT JOIN animals a ON a.id = v.animal_id
        WHERE v.status = 'Agendada'
        ORDER BY date(v.scheduled_date) ASC
        LIMIT 200
      ''');

      // Medicações com next_date próximo (≤ 30 dias) e status 'Agendado'
      // Tentamos com filtro de status (bancos já migrados); se falhar (coluna não existe),
      // fazemos fallback sem o filtro de status.
      List<Map<String, dynamic>> meds;
      try {
        meds = await db.rawQuery('''
          SELECT m.*, a.name AS animal_name, a.code AS animal_code
          FROM medications m
          LEFT JOIN animals a ON a.id = m.animal_id
          WHERE m.next_date IS NOT NULL
            AND (m.status IS NULL OR m.status = 'Agendado')
            AND date(m.next_date) <= date('now', '+30 day')
          ORDER BY date(m.next_date) ASC
          LIMIT 200
        ''');
      } catch (_) {
        // Fallback para bancos sem a coluna "status"
        meds = await db.rawQuery('''
          SELECT m.*, a.name AS animal_name, a.code AS animal_code
          FROM medications m
          LEFT JOIN animals a ON a.id = m.animal_id
          WHERE m.next_date IS NOT NULL
            AND date(m.next_date) <= date('now', '+30 day')
          ORDER BY date(m.next_date) ASC
          LIMIT 200
        ''');
      }

      setState(() {
        _vaccines = vacs;
        _meds = meds;

        // Resetar páginas caso listas tenham mudado
        _vacPage = 0;
        _medPage = 0;

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 12),
              Text('Carregando alertas...', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(Icons.error, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Erro ao carregar alertas: $_error',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
              TextButton.icon(
                onPressed: _loadAlerts,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Sempre mostrar o quadro, mesmo sem alertas
    final total = _vaccines.length + _meds.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Icon(Icons.notifications_active,
                    color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Alertas de Vacinação e Medicação',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _counterChip(
                  theme,
                  label: 'Total',
                  value: total,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _counterChip(
                  theme,
                  label: 'Vacinas',
                  value: _vaccines.length,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _counterChip(
                  theme,
                  label: 'Medicações',
                  value: _meds.length,
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vacinas (paginado 4 por vez)
            if (_vaccines.isNotEmpty) ...[
              _sectionHeaderWithPager(
                theme: theme,
                title: 'Vacinas Agendadas',
                total: _vaccines.length,
                page: _vacPage,
                onPrev: _vacPage > 0 ? () => setState(() => _vacPage--) : null,
                onNext: (_vacPage + 1) * _pageSize < _vaccines.length
                    ? () => setState(() => _vacPage++)
                    : null,
              ),
              const SizedBox(height: 8),
              ..._pagedSlice(_vaccines, _vacPage).map(
                (row) => _vaccineTile(context, theme, row),
              ),
              const SizedBox(height: 16),
            ],

            // Medicações (paginado 4 por vez)
            if (_meds.isNotEmpty) ...[
              _sectionHeaderWithPager(
                theme: theme,
                title: 'Medicações (próximas)',
                total: _meds.length,
                page: _medPage,
                onPrev: _medPage > 0 ? () => setState(() => _medPage--) : null,
                onNext: (_medPage + 1) * _pageSize < _meds.length
                    ? () => setState(() => _medPage++)
                    : null,
              ),
              const SizedBox(height: 8),
              ..._pagedSlice(_meds, _medPage).map(
                (row) => _medTile(context, theme, row),
              ),
            ],
            
            // Mensagem quando não há alertas
            if (_vaccines.isEmpty && _meds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum alerta no momento',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Todas as vacinações e medicações estão em dia',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- Paginação helpers ----------

  List<Map<String, dynamic>> _pagedSlice(
      List<Map<String, dynamic>> list, int page) {
    final start = page * _pageSize;
    if (start >= list.length) return const [];
    final end = ((page + 1) * _pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  Widget _sectionHeaderWithPager({
    required ThemeData theme,
    required String title,
    required int total,
    required int page,
    VoidCallback? onPrev,
    VoidCallback? onNext,
  }) {
    final start = total == 0 ? 0 : (page * _pageSize) + 1;
    final end = ((page + 1) * _pageSize).clamp(0, total);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withOpacity(0.3),
            thickness: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$start–$end de $total',
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Anterior',
          onPressed: onPrev,
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
        IconButton(
          tooltip: 'Próximo',
          onPressed: onNext,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
      ],
    );
  }

  // ---------- Chips / UI pequenos ----------

  Widget _counterChip(ThemeData theme,
      {required String label, required int value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Renders das linhas ----------

  Widget _vaccineTile(
      BuildContext context, ThemeData theme, Map<String, dynamic> row) {
    final animalName = (row['animal_name'] ?? '').toString();
    final animalCode = (row['animal_code'] ?? '').toString();
    final vaccineName = (row['vaccine_name'] ?? '').toString();

    final scheduledStr = (row['scheduled_date'] ?? '').toString();
    final scheduled = _parseDate(scheduledStr);
    final days = _daysFromNow(scheduled);

    final overdue = scheduled != null && days < 0;
    final color = overdue ? theme.colorScheme.error : Colors.orange;
    final labelDate = scheduled != null ? _formatDate(scheduled) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.vaccines, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$animalCode - $animalName',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'Vacina: $vaccineName',
                  style: theme.textTheme.bodyMedium,
                ),
                if (labelDate != null)
                  Text(
                    overdue
                        ? 'ATRASADA há ${days.abs()} dia(s)'
                        : 'Agendada para $labelDate (em $days dia(s))',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ✅ Sem botão "Aplicar" aqui — apenas atalho para a aba de vacinas
          OutlinedButton.icon(
            onPressed: widget.onGoToVaccinations,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Ver vacinas'),
          ),
        ],
      ),
    );
  }

  Widget _medTile(
      BuildContext context, ThemeData theme, Map<String, dynamic> row) {
    final animalName = (row['animal_name'] ?? '').toString();
    final animalCode = (row['animal_code'] ?? '').toString();
    final medName = (row['medication_name'] ?? '').toString();

    final nextStr = (row['next_date'] ?? '').toString();
    final nextDate = _parseDate(nextStr);
    final days = _daysFromNow(nextDate);

    // Se existir 'status', respeitamos (Agendado, Aplicado, Cancelado)
    final status = (row['status'] ?? 'Agendado').toString();

    final overdue = nextDate != null && days < 0;
    final color = overdue ? theme.colorScheme.error : Colors.teal;
    final labelDate = nextDate != null ? _formatDate(nextDate) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.medical_services, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$animalCode - $animalName',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  'Medicação: $medName',
                  style: theme.textTheme.bodyMedium,
                ),
                if (labelDate != null)
                  Text(
                    overdue
                        ? 'ATRASADA há ${days.abs()} dia(s)'
                        : 'Agendada para $labelDate (em $days dia(s))',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (status != 'Agendado')
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Status: $status',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: widget.onGoToVaccinations,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Ver medicações'),
          ),
        ],
      ),
    );
  }

  // ---------- Ações ----------

  void _openVaccineForm(BuildContext context, Map<String, dynamic> row) {
    final animalId = row['animal_id']?.toString();
    showDialog(
      context: context,
      builder: (context) => VaccinationFormDialog(animalId: animalId),
    ).then((_) => _loadAlerts());
  }

  // ---------- Helpers de data ----------

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }

  int _daysFromNow(DateTime? d) {
    if (d == null) return 0;
    final now = DateTime.now();
    return d.difference(DateTime(now.year, now.month, now.day)).inDays;
    // negativo = atrasado; positivo = faltam dias.
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}
