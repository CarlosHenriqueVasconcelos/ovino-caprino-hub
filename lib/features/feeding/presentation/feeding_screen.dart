import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/feeding_pen.dart';
import '../../../models/feeding_schedule.dart';
import '../../../services/feeding_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/pen_details_screen.dart';

const _kBeige = Color(0xFFF6F5F1);
const _kSurface = Color(0xFFFBFBF8);
const _kSurface2 = Color(0xFFF2F1ED);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kBrand50 = Color(0xFFE8F5EE);
const _kBrand100 = Color(0xFFC5E8D4);
const _kGold = Color(0xFFD9B15F);
const _kGold50 = Color(0xFFFBF4E6);
const _kTeal = Color(0xFF1E8080);
const _kTeal50 = Color(0xFFE3F4F4);

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FeedingService>().loadPens();
    });
  }

  Future<void> _showAddPenDialog() async {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar Nova Baia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Baia *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }

              final feedingService = context.read<FeedingService>();
              final now = DateTime.now();
              final pen = FeedingPen(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                number: numberController.text.trim().isEmpty
                    ? null
                    : numberController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                createdAt: now,
                updatedAt: now,
              );

              await feedingService.addPen(pen);

              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPenDialog(FeedingPen pen) async {
    final nameController = TextEditingController(text: pen.name);
    final numberController = TextEditingController(text: pen.number ?? '');
    final notesController = TextEditingController(text: pen.notes ?? '');

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Baia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Baia *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nome é obrigatório')),
                );
                return;
              }

              final updatedPen = FeedingPen(
                id: pen.id,
                name: nameController.text.trim(),
                number: numberController.text.trim().isEmpty
                    ? null
                    : numberController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
                createdAt: pen.createdAt,
                updatedAt: DateTime.now(),
              );

              await context.read<FeedingService>().updatePen(updatedPen);

              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePen(FeedingPen pen) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Baia'),
        content: Text(
          'Deseja realmente excluir a baia "${pen.name}"? Todos os tratos associados também serão excluídos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await context.read<FeedingService>().deletePen(pen.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Baia "${pen.name}" excluída com sucesso')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedingService>(
      builder: (context, feedingService, _) {
        if (feedingService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final pens = feedingService.pens;
        final totalSchedules = pens.fold<int>(
          0,
          (sum, pen) => sum + feedingService.getSchedulesForPen(pen.id).length,
        );
        final totalKgPerDay = pens.fold<double>(
          0,
          (sum, pen) =>
              sum + _totalPenKg(feedingService.getSchedulesForPen(pen.id)),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width >= 920 ? AppSpacing.lg : 12.0;
            final crossAxisCount = width >= 1180
                ? 4
                : width >= 900
                    ? 3
                    : width >= 560
                        ? 2
                        : 1;
            final childAspectRatio = width >= 900
                ? 1.05
                : width >= 560
                    ? 0.95
                    : 1.25;

            return Container(
              color: _kBeige,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 96),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        10,
                        horizontalPadding,
                        8,
                      ),
                      child: _FeedingHeader(onAdd: _showAddPenDialog),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: _KpiTile(
                              icon: Icons.home_work_outlined,
                              iconBg: _kTeal50,
                              iconColor: _kTeal,
                              value: '${pens.length}',
                              label: 'Baias',
                              valueColor: _kTeal,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: _KpiTile(
                              icon: Icons.table_rows_outlined,
                              iconBg: _kBrand50,
                              iconColor: AppColors.primary,
                              value: '$totalSchedules',
                              label: 'Rações',
                              valueColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: _KpiTile(
                              icon: Icons.scale_outlined,
                              iconBg: _kGold50,
                              iconColor: _kGold,
                              value: _fmtKg(totalKgPerDay),
                              label: 'kg/dia',
                              valueColor: _kGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: const Row(
                        children: [
                          Text(
                            'Baias cadastradas',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _kText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        12,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 7,
                        mainAxisSpacing: 7,
                      ),
                      itemCount: pens.length + 1,
                      itemBuilder: (context, index) {
                        if (index == pens.length) {
                          return _NewPenCard(onTap: _showAddPenDialog);
                        }

                        final pen = pens[index];
                        final schedules = feedingService.getSchedulesForPen(pen.id);
                        return _PenCard(
                          pen: pen,
                          schedules: schedules,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PenDetailsScreen(pen: pen),
                              ),
                            );
                          },
                          onEdit: () => _showEditPenDialog(pen),
                          onDelete: () => _confirmDeletePen(pen),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _totalPenKg(List<FeedingSchedule> schedules) {
    return schedules.fold<double>(0, (sum, schedule) => sum + schedule.quantity);
  }

  String _fmtKg(double value) {
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }
}

class _FeedingHeader extends StatelessWidget {
  final VoidCallback onAdd;

  const _FeedingHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.chevron_left, size: 14, color: AppColors.primary),
              SizedBox(width: 2),
              Text(
                'Manejo',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alimentação',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Planos por baia',
                      style: TextStyle(
                        fontSize: 10,
                        color: _kText3,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _kBrand50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color valueColor;

  const _KpiTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: _kText.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
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
            child: Icon(icon, size: 12, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: _kText2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PenCard extends StatelessWidget {
  final FeedingPen pen;
  final List<FeedingSchedule> schedules;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PenCard({
    required this.pen,
    required this.schedules,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalKg = schedules.fold<double>(0, (sum, s) => sum + s.quantity);
    final isActive = schedules.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: _kText.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                    decoration: BoxDecoration(
                      color: isActive ? _kBrand50 : _kSurface2,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : _kText3,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.home_work_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pen.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Nº ${(pen.number ?? '').trim().isEmpty ? 'N/I' : pen.number!.trim()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: _kText2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: '${schedules.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kText,
                              fontWeight: FontWeight.w700,
                            ),
                            children: const [
                              TextSpan(
                                text: ' rações',
                                style: TextStyle(
                                  color: _kText2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            text:
                                '${totalKg.toStringAsFixed(1).replaceAll('.', ',')} kg',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kText,
                              fontWeight: FontWeight.w700,
                            ),
                            children: const [
                              TextSpan(
                                text: '/dia',
                                style: TextStyle(
                                  color: _kText2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? _kBrand50 : _kSurface2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? _kBrand100
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            isActive ? 'Ativo' : 'Inativo',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: isActive ? AppColors.primary : _kText3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: _kText3),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewPenCard extends StatelessWidget {
  final VoidCallback onTap;

  const _NewPenCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.12),
              width: 1.4,
            ),
            color: Colors.transparent,
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: _kText3, size: 28),
                SizedBox(height: 6),
                Text(
                  'Nova baia',
                  style: TextStyle(
                    fontSize: 10,
                    color: _kText3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
