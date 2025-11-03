// lib/widgets/animal_history_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/animal.dart';
import '../services/database_service.dart'; // usa o SQLite local diretamente

class AnimalHistoryDialog extends StatefulWidget {
  final Animal animal;
  const AnimalHistoryDialog({super.key, required this.animal});

  @override
  State<AnimalHistoryDialog> createState() => _AnimalHistoryDialogState();
}

class _AnimalHistoryDialogState extends State<AnimalHistoryDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  List<Map<String, Object?>> _vaccinations = [];
  List<Map<String, Object?>> _medications = [];
  List<Map<String, Object?>> _notes = [];
  List<Map<String, Object?>> _weights = [];
  List<Map<String, Object?>> _offspring = [];
  Animal? _mother;
  Animal? _father;

  String _fmtDate(dynamic iso) {
    if (iso == null) return '-';
    try {
      final s = iso.toString();
      final d = DateTime.tryParse(s) ??
          // datas salvas como "YYYY-MM-DD" no SQLite
          DateTime.tryParse('${s}T00:00:00');
      if (d == null) return s;
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return iso.toString();
    }
  }

  Future<void> _load() async {
    final db = await DatabaseService.database;
    final id = widget.animal.id;

    // Apenas vacinas aplicadas primeiro; depois agendadas
    _vaccinations = await db.rawQuery('''
      SELECT * FROM vaccinations
      WHERE animal_id = ?
      ORDER BY 
        CASE WHEN applied_date IS NOT NULL THEN 0 ELSE 1 END,
        COALESCE(applied_date, scheduled_date) DESC
    ''', [id]);

    _medications = await db.rawQuery('''
      SELECT * FROM medications
      WHERE animal_id = ?
      ORDER BY COALESCE(applied_date, date) DESC
    ''', [id]);

    _notes = await db.rawQuery('''
      SELECT * FROM notes
      WHERE animal_id = ?
      ORDER BY date DESC, created_at DESC
    ''', [id]);

    _weights = await db.rawQuery('''
      SELECT * FROM animal_weights
      WHERE animal_id = ?
      ORDER BY date DESC
    ''', [id]);

    // Buscar filhotes (todos, incluindo vendidos e falecidos)
    _offspring = await db.rawQuery('''
      SELECT id, name, code, category, name_color, lote, 'ativo' as status FROM animals WHERE mother_id = ? OR father_id = ?
      UNION ALL
      SELECT id, name, code, category, name_color, lote, 'vendido' as status FROM sold_animals WHERE mother_id = ? OR father_id = ?
      UNION ALL
      SELECT id, name, code, category, name_color, lote, 'falecido' as status FROM deceased_animals WHERE mother_id = ? OR father_id = ?
      ORDER BY name
    ''', [id, id, id, id, id, id]);

    // Buscar informações dos pais
    if (widget.animal.motherId != null) {
      final motherRows = await db.query('animals', where: 'id = ?', whereArgs: [widget.animal.motherId]);
      if (motherRows.isNotEmpty) {
        _mother = Animal.fromMap(motherRows.first);
      }
    }

    if (widget.animal.fatherId != null) {
      final fatherRows = await db.query('animals', where: 'id = ?', whereArgs: [widget.animal.fatherId]);
      if (fatherRows.isNotEmpty) {
        _father = Animal.fromMap(fatherRows.first);
      }
    }

    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this); // Dados, Vacinas, Medicações, Anotações, (Pesos opcional)
    // quer 5 abas incluindo "Pesos"? Troque length: 5 e inclua a Tab/conteúdo abaixo.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Widget _dadosCard(BuildContext context) {
    final a = widget.animal;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 12, runSpacing: 6, children: [
                    Text('Código: ${a.code}'),
                    Text('Espécie: ${a.species}'),
                    Text('Raça: ${a.breed}'),
                    Text('Sexo: ${a.gender}'),
                    Text('Peso: ${a.weight} kg'),
                    Text('Status: ${a.status}'),
                    if (a.location.isNotEmpty) Text('Local: ${a.location}'),
                  ]),
                  const SizedBox(height: 8),
                  Wrap(spacing: 12, runSpacing: 6, children: [
                    Text('Nascimento: ${_fmtDate(a.birthDate)}'),
                    if (a.lastVaccination != null) Text('Última Vacinação: ${DateFormat('dd/MM/yyyy').format(a.lastVaccination!)}'),
                    if (a.pregnant) Text('Gestante: Sim'),
                    if (a.expectedDelivery != null) Text('Parto previsto: ${DateFormat('dd/MM/yyyy').format(a.expectedDelivery!)}'),
                    if ((a.healthIssue ?? '').isNotEmpty) Text('Saúde: ${a.healthIssue!}'),
                  ]),
                ],
              ),
            ),
          ),
        ),
        // Pais (mãe e pai)
        if (_mother != null || _father != null) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Parentesco', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_mother != null)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.female),
                      title: Text('Mãe: ${_mother!.name}'),
                      subtitle: Text('Código: ${_mother!.code}${_mother!.nameColor != null ? ' • Cor: ${_mother!.nameColor}' : ''}${_mother!.lote != null ? ' • Lote: ${_mother!.lote}' : ''}'),
                    ),
                  if (_father != null)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.male),
                      title: Text('Pai: ${_father!.name}'),
                      subtitle: Text('Código: ${_father!.code}${_father!.nameColor != null ? ' • Cor: ${_father!.nameColor}' : ''}${_father!.lote != null ? ' • Lote: ${_father!.lote}' : ''}'),
                    ),
                ],
              ),
            ),
          ),
        ],
        // Filhotes (todos, com status)
        if (_offspring.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filhotes (${_offspring.length})', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._offspring.map((child) {
                    final status = child['status']?.toString() ?? 'ativo';
                    Color statusColor = Colors.green;
                    if (status == 'vendido') statusColor = Colors.blue;
                    if (status == 'falecido') statusColor = Colors.red;
                    
                    final color = child['name_color']?.toString();
                    final lote = child['lote']?.toString();
                    
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.child_care, color: statusColor),
                      title: Text('${child['name']} (${child['code']})'),
                      subtitle: Text('${child['category']} • Status: $status${color != null ? ' • Cor: $color' : ''}${lote != null ? ' • Lote: $lote' : ''}'),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
        // Pesos (resumo) — opcional
        if (_weights.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pesagens', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._weights.map((w) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.monitor_weight),
                        title: Text('${(w['weight'] ?? '').toString()} kg'),
                        subtitle: Text('Data: ${_fmtDate(w['date'])}'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _listCard({
    required BuildContext context,
    required String title,
    required List<Map<String, Object?>> items,
    required List<Widget> Function(Map<String, Object?> row) lines,
    IconData? icon,
    Widget? empty,
  }) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return empty ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Sem registros', style: theme.textTheme.bodyMedium),
            ),
          );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...items.map((r) => ListTile(
                      leading: icon != null ? Icon(icon) : null,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: lines(r),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SizedBox(
        width: 720,
        height: 520,
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Text('Histórico • ${widget.animal.name}', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),

            // Abas
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Dados'),
                Tab(text: 'Vacinas'),
                Tab(text: 'Medicações'),
                Tab(text: 'Anotações'),
                // Se quiser ativar Pesos como aba separada, remova o comentário:
                // Tab(text: 'Pesos'),
              ],
            ),
            const Divider(height: 1),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabs,
                      children: [
                        _dadosCard(context),
                        _listCard(
                          context: context,
                          title: 'Vacinas',
                          icon: Icons.vaccines,
                          items: _vaccinations,
                          lines: (r) => [
                            Text('${r['vaccine_name'] ?? ''} • ${r['vaccine_type'] ?? ''}'),
                            Text('Agendada: ${_fmtDate(r['scheduled_date'])}  •  Aplicada: ${_fmtDate(r['applied_date'])}'),
                            if ((r['veterinarian'] ?? '').toString().isNotEmpty)
                              Text('Veterinário: ${r['veterinarian']}'),
                            if ((r['notes'] ?? '').toString().isNotEmpty)
                              Text('Obs: ${r['notes']}'),
                          ],
                        ),
                        _listCard(
                          context: context,
                          title: 'Medicações',
                          icon: Icons.medication_liquid,
                          items: _medications,
                          lines: (r) => [
                            Text('${r['medication_name'] ?? ''}'),
                            Text('Data: ${_fmtDate(r['date'])}  •  Aplicada: ${_fmtDate(r['applied_date'])}'),
                            if ((r['dosage'] ?? '').toString().isNotEmpty)
                              Text('Dosagem: ${r['dosage']}'),
                            if ((r['veterinarian'] ?? '').toString().isNotEmpty)
                              Text('Veterinário: ${r['veterinarian']}'),
                            if ((r['notes'] ?? '').toString().isNotEmpty)
                              Text('Obs: ${r['notes']}'),
                          ],
                        ),
                        _listCard(
                          context: context,
                          title: 'Anotações',
                          icon: Icons.note,
                          items: _notes,
                          lines: (r) => [
                            Text('${r['title'] ?? ''} • ${_fmtDate(r['date'])}'),
                            if ((r['content'] ?? '').toString().isNotEmpty)
                              Text('${r['content']}'),
                            if ((r['category'] ?? '').toString().isNotEmpty ||
                                (r['priority'] ?? '').toString().isNotEmpty)
                              Text('Categoria: ${r['category'] ?? '-'}  •  Prioridade: ${r['priority'] ?? '-'}'),
                          ],
                        ),
                        // Se liberar a aba Pesos separada, adicione aqui:
                        // _listCard(
                        //   context: context,
                        //   title: 'Pesos',
                        //   icon: Icons.monitor_weight,
                        //   items: _weights,
                        //   lines: (r) => [
                        //     Text('${r['weight']} kg'),
                        //     Text('Data: ${_fmtDate(r['date'])}'),
                        //   ],
                        // ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
