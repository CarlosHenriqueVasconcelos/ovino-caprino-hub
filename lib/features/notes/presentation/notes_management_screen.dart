import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/note_service.dart';
import '../../../utils/animal_record_display.dart';
import 'widgets/notes_dialogs.dart';
import 'widgets/notes_helpers.dart';

const _kBrand = Color(0xFF2F8F5B);
const _kBrand50 = Color(0xFFE8F5EE);
const _kBeige = Color(0xFFF6F5F1);
const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kGold = Color(0xFFD9B15F);
const _kGold50 = Color(0xFFFBF4E6);
const _kErr = Color(0xFFC94A4A);
const _kErr50 = Color(0xFFFAEAEA);
const _kBlue = Color(0xFF3A7EC4);
const _kBlue50 = Color(0xFFEBF3FB);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kBorder = Color(0xFFE6E4DC);

/// Tela de gerenciamento de anotações
class NotesManagementScreen extends StatefulWidget {
  const NotesManagementScreen({super.key});

  @override
  State<NotesManagementScreen> createState() => _NotesManagementScreenState();
}

class _NotesManagementScreenState extends State<NotesManagementScreen> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _page = 0;
  String _searchTerm = '';
  String _selectedCategory = 'Todas';
  String _selectedPriority = 'Todas';
  bool _showOnlyUnread = false;
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounce;
  static const int _pageSize = 50;

  final List<String> _categories = const [
    'Todas',
    'Geral',
    'Saúde',
    'Reprodução',
    'Vacinação',
    'Alimentação',
    'Manejo',
    'Financeiro',
    'Veterinário',
  ];

  final List<String> _priorities = const [
    'Todas',
    'Baixa',
    'Média',
    'Alta',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    _loadNotes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final noteService = context.read<NoteService>();
      final result = await noteService.getNotes(
        options: NoteQueryOptions(
          category: _selectedCategory == 'Todas' ? null : _selectedCategory,
          priority: _selectedPriority == 'Todas' ? null : _selectedPriority,
          unreadOnly: _showOnlyUnread ? true : null,
          searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
          limit: _pageSize,
          offset: 0,
        ),
      );
      _notes = result;
      _page = 0;
      _hasMore = result.length == _pageSize;
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() => _searchTerm = value.trim());
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _loadNotes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedNotes = [..._notes]
      ..sort((a, b) => _parseNoteDate(b).compareTo(_parseNoteDate(a)));
    final showLoaderRow = _isLoadingMore || _hasMore;
    final itemCount = sortedNotes.length + (showLoaderRow ? 1 : 0);
    final totalCount = _notes.length;
    final unreadCount = _notes.where((n) => !_noteIsRead(n)).length;
    final highPriorityCount =
        _notes.where((n) => (n['priority'] ?? '').toString() == 'Alta').length;

    return Scaffold(
      backgroundColor: _kBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 96),
          child: Column(
            children: [
              _buildModernHeader(unreadCount: unreadCount),
              const SizedBox(height: 10),
              _buildModernKpiRow(
                totalCount: totalCount,
                unreadCount: unreadCount,
                highPriorityCount: highPriorityCount,
              ),
              const SizedBox(height: 10),
              _buildModernFiltersPanel(),
              const SizedBox(height: 8),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _buildModernNotesList(
                  notes: sortedNotes,
                  itemCount: itemCount,
                  showLoaderRow: showLoaderRow,
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddNoteDialog(context),
        backgroundColor: _kBrand,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova anotação'),
      ),
    );
  }

  Widget _buildModernHeader({required int unreadCount}) {
    final isMobile = MediaQuery.of(context).size.width < 680;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anotações',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Propriedade · $unreadCount não lidas',
                  style: const TextStyle(fontSize: 10, color: _kText3),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            OutlinedButton.icon(
              onPressed: _loadNotes,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Recarregar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kText2,
                side: BorderSide(color: _kBorder.withValues(alpha: 0.95)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          FilledButton.icon(
            onPressed: () => _openAddNoteDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nova'),
            style: FilledButton.styleFrom(
              backgroundColor: _kBrand,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          if (isMobile) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: _loadNotes,
              icon: const Icon(Icons.refresh, size: 18),
              color: _kText2,
              tooltip: 'Recarregar',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernKpiRow({
    required int totalCount,
    required int unreadCount,
    required int highPriorityCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            icon: Icons.note_alt_outlined,
            iconBg: _kBrand50,
            iconColor: _kBrand,
            value: '$totalCount',
            valueColor: _kBrand,
            label: 'Total',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _buildKpiCard(
            icon: Icons.notifications_none,
            iconBg: _kGold50,
            iconColor: _kGold,
            value: '$unreadCount',
            valueColor: _kGold,
            label: 'Não lidas',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _buildKpiCard(
            icon: Icons.priority_high_rounded,
            iconBg: _kErr50,
            iconColor: _kErr,
            value: '$highPriorityCount',
            valueColor: _kErr,
            label: 'Alta prior.',
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 13, color: iconColor),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: _kText2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFiltersPanel() {
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide.none,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _handleSearchChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 18, color: _kText3),
              hintText: 'Buscar anotações…',
              hintStyle: const TextStyle(fontSize: 12, color: _kText3),
              filled: true,
              fillColor: _kSurface2,
              isDense: true,
              border: fieldBorder,
              enabledBorder: fieldBorder,
              focusedBorder: fieldBorder,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    labelStyle: const TextStyle(fontSize: 10, color: _kText3),
                    filled: true,
                    fillColor: _kSurface2,
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                    focusedBorder: fieldBorder,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                  ),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedCategory = value);
                    _loadNotes();
                  },
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedPriority,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Prioridade',
                    labelStyle: const TextStyle(fontSize: 10, color: _kText3),
                    filled: true,
                    fillColor: _kSurface2,
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                    focusedBorder: fieldBorder,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                  ),
                  items: _priorities
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedPriority = value);
                    _loadNotes();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Switch.adaptive(
                value: _showOnlyUnread,
                activeThumbColor: _kBrand,
                activeTrackColor: _kBrand.withValues(alpha: 0.35),
                onChanged: (value) {
                  setState(() => _showOnlyUnread = value);
                  _loadNotes();
                },
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Mostrar apenas não lidas',
                  style: TextStyle(
                    fontSize: 11,
                    color: _kText2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernNotesList({
    required List<Map<String, dynamic>> notes,
    required int itemCount,
    required bool showLoaderRow,
  }) {
    if (notes.isEmpty) {
      return _buildModernEmptyState();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
          child: Row(
            children: [
              Text(
                '${notes.length} anotações',
                style: const TextStyle(
                  fontSize: 11,
                  color: _kText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text(
                'mais recentes',
                style: TextStyle(
                  fontSize: 10,
                  color: _kBrand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (showLoaderRow && index >= notes.length) {
              if (_isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'Carregando mais ao rolar…',
                    style: TextStyle(fontSize: 11, color: _kText3),
                  ),
                ),
              );
            }
            final note = notes[index];
            return _buildModernNoteCard(note);
          },
        ),
      ],
    );
  }

  Widget _buildModernNoteCard(Map<String, dynamic> note) {
    final isRead = _noteIsRead(note);
    final title = (note['title'] ?? 'Sem título').toString();
    final content = formatNoteContentPreview((note['content'] ?? '').toString());
    final dateText = formatNoteDate((note['date'] ?? '').toString());
    final category = (note['category'] ?? 'Geral').toString();
    final priority = (note['priority'] ?? 'Média').toString();
    final hasLinkedAnimal = note['animal_id'] != null;
    final animalLabel =
        hasLinkedAnimal ? AnimalRecordDisplay.labelFromRecord(note) : '';
    final animalColor =
        hasLinkedAnimal ? AnimalRecordDisplay.colorFromRecord(note) : _kBrand;

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (!isRead)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: const BoxDecoration(
                  color: _kBrand,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                ),
              ),
            ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onNoteSelected(note),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isRead ? _kSurface2 : _kBrand50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.edit_note_rounded,
                            size: 15,
                            color: isRead ? _kText3 : _kBrand,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isRead ? _kText2 : _kText,
                                ),
                              ),
                              if (hasLinkedAnimal) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.pets, size: 11, color: animalColor),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        animalLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isRead ? _kText3 : animalColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!isRead) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _kBrand,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NOVO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          dateText,
                          style: const TextStyle(fontSize: 10, color: _kText3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 10,
                        color: isRead ? _kText3 : _kText2,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        _buildCategoryChip(category: category, isRead: isRead),
                        const SizedBox(width: 5),
                        _buildPriorityChip(priority: priority, isRead: isRead),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: isRead
                                ? null
                                : () => _markAsRead(note['id'].toString()),
                            icon: Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: isRead ? _kText3 : _kBrand,
                            ),
                            label: Text(isRead ? 'Lida' : 'Marcar como lida'),
                            style: TextButton.styleFrom(
                              foregroundColor: isRead ? _kText3 : _kBrand,
                              textStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _deleteNote(note),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 14,
                              color: _kErr,
                            ),
                            label: const Text('Excluir'),
                            style: TextButton.styleFrom(
                              foregroundColor: _kErr,
                              textStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String category,
    required bool isRead,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isRead ? _kSurface2 : _kBrand50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 9,
          color: isRead ? _kText3 : _kBrand,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip({
    required String priority,
    required bool isRead,
  }) {
    final (bg, fg, border) = _priorityChipTone(priority, isRead: isRead);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: border,
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 9,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color, Border?) _priorityChipTone(
    String priority, {
    required bool isRead,
  }) {
    if (isRead) {
      return (_kSurface2, _kText3, null);
    }
    switch (priority) {
      case 'Alta':
        return (_kErr50, _kErr, null);
      case 'Baixa':
        return (_kBlue50, _kBlue, null);
      default:
        return (
          _kGold50,
          const Color(0xFF7A5C00),
          Border.all(color: const Color(0xFFF0D898)),
        );
    }
  }

  Widget _buildModernEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: _kText3,
            ),
            SizedBox(height: 14),
            Text(
              'Nenhuma anotação encontrada',
              style: TextStyle(
                fontSize: 16,
                color: _kText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 7),
            Text(
              'Use o botão "+" para adicionar uma nova anotação, ou altere os filtros de busca.',
              style: TextStyle(
                fontSize: 13,
                color: _kText2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseNoteDate(Map<String, dynamic> note) {
    final dateRaw = (note['date'] ?? '').toString().trim();
    if (dateRaw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    final parsed = DateTime.tryParse(dateRaw);
    if (parsed != null) return parsed;
    final parts = dateRaw.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]) ?? 1;
      final month = int.tryParse(parts[1]) ?? 1;
      final year = int.tryParse(parts[2]) ?? 1970;
      return DateTime(year, month, day);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _noteIsRead(Map<String, dynamic> note) {
    final raw = note['is_read'];
    if (raw is bool) return raw;
    if (raw is num) return raw == 1;
    final asText = (raw ?? '').toString().toLowerCase().trim();
    return asText == '1' || asText == 'true';
  }

  Future<void> _markAsRead(String noteId) async {
    try {
      final noteService = context.read<NoteService>();
      await noteService.markAsRead(noteId);
      await _loadNotes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anotação marcada como lida!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao marcar como lida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openAddNoteDialog(BuildContext context) async {
    await showAddNoteDialog(
      context,
      onSaved: () {
        _loadNotes();
      },
    );
  }

  Future<void> _onNoteSelected(Map<String, dynamic> note) async {
    final shouldMark = await showNoteDetailsDialog(
      context,
      note: note,
    );
    if (shouldMark == true) {
      await _markAsRead(note['id'].toString());
    }
  }

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir anotação'),
        content: const Text(
            'Deseja realmente excluir esta anotação? A operação é irreversível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;
    try {
      final noteService = context.read<NoteService>();
      await noteService.deleteNote(note['id'].toString());
      await _loadNotes();
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Anotação excluída')),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir anotação: $e'),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final noteService = context.read<NoteService>();
      final result = await noteService.getNotes(
        options: NoteQueryOptions(
          category: _selectedCategory == 'Todas' ? null : _selectedCategory,
          priority: _selectedPriority == 'Todas' ? null : _selectedPriority,
          unreadOnly: _showOnlyUnread ? true : null,
          searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
          limit: _pageSize,
          offset: nextPage * _pageSize,
        ),
      );
      if (!mounted) return;
      setState(() {
        _notes.addAll(result);
        _page = nextPage;
        _hasMore = result.length == _pageSize;
      });
    } catch (e) {
      debugPrint('Error loading more notes: $e');
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }
}
