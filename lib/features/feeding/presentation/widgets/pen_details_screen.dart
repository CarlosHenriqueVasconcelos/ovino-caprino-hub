import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/feeding_pen.dart';
import '../../../../models/feeding_schedule.dart';
import '../../../../services/feeding_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import 'feeding_form_dialog.dart';

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
const _kBlue = Color(0xFF3A7EC4);
const _kBlue50 = Color(0xFFEBF3FB);
const _kErr50 = Color(0xFFFAEAEA);
const _kPurple = Color(0xFF7B5EA7);
const _kPurple50 = Color(0xFFF0EBFA);

class PenDetailsScreen extends StatefulWidget {
  final FeedingPen pen;

  const PenDetailsScreen({super.key, required this.pen});

  @override
  State<PenDetailsScreen> createState() => _PenDetailsScreenState();
}

class _PenDetailsScreenState extends State<PenDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FeedingService>().loadPens();
    });
  }

  Future<void> _showFeedingDialog([FeedingSchedule? schedule]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => FeedingFormDialog(
        penId: widget.pen.id,
        schedule: schedule,
      ),
    );

    if (result == true && mounted) {
      context.read<FeedingService>().loadPens();
    }
  }

  Future<void> _deleteSchedule(FeedingSchedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este trato?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context
          .read<FeedingService>()
          .deleteSchedule(schedule.id, widget.pen.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trato excluído com sucesso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedingService>(
      builder: (context, feedingService, _) {
        final currentPen = feedingService.getPenById(widget.pen.id) ?? widget.pen;
        final schedules = feedingService.getSchedulesForPen(currentPen.id);
        final totalKg = schedules.fold<double>(0, (sum, s) => sum + s.quantity);
        final maxTimesPerDay = schedules.isEmpty
            ? 0
            : schedules
                .map((s) => s.timesPerDay)
                .reduce((a, b) => a > b ? a : b);

        return Scaffold(
          backgroundColor: _kBeige,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showFeedingDialog(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Adicionar ração',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: _kSurface,
                    border: Border(
                      bottom: BorderSide(
                        color: _kBorder.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 2,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chevron_left,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'Alimentação',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPen.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _kText,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Nº ${(currentPen.number ?? '').trim().isEmpty ? 'N/I' : currentPen.number!.trim()} · ${schedules.length} rações cadastradas',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: _kText3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _showFeedingDialog(),
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
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final horizontalPadding = width >= 920 ? AppSpacing.lg : 12.0;

                      if (feedingService.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          10,
                          horizontalPadding,
                          88,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 920),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _PenHeroCard(
                                  pen: currentPen,
                                  totalKg: totalKg,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DetailKpiTile(
                                        icon: Icons.table_rows_outlined,
                                        iconBg: _kBrand50,
                                        iconColor: AppColors.primary,
                                        value: '${schedules.length}',
                                        label: 'Rações',
                                        valueColor: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: _DetailKpiTile(
                                        icon: Icons.scale_outlined,
                                        iconBg: _kGold50,
                                        iconColor: _kGold,
                                        value: _fmtKg(totalKg),
                                        label: 'kg/dia',
                                        valueColor: _kGold,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: _DetailKpiTile(
                                        icon: Icons.schedule_outlined,
                                        iconBg: _kPurple50,
                                        iconColor: _kPurple,
                                        value: '${maxTimesPerDay}x',
                                        label: 'por dia',
                                        valueColor: _kPurple,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Rações',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _kText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (schedules.isEmpty)
                                  _EmptyRationState(onAdd: () => _showFeedingDialog())
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: schedules.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 7),
                                    itemBuilder: (context, index) {
                                      final schedule = schedules[index];
                                      return _ScheduleCard(
                                        schedule: schedule,
                                        onEdit: () => _showFeedingDialog(schedule),
                                        onDelete: () => _deleteSchedule(schedule),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmtKg(double value) => value.toStringAsFixed(1).replaceAll('.', ',');
}

class _PenHeroCard extends StatelessWidget {
  final FeedingPen pen;
  final double totalKg;

  const _PenHeroCard({
    required this.pen,
    required this.totalKg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kBrand50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBrand100),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.home_work_outlined, size: 17, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pen.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Número: ${(pen.number ?? '').trim().isEmpty ? 'N/I' : pen.number!.trim()}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: _kText2,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${totalKg.toStringAsFixed(1).replaceAll('.', ',')} kg',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                  letterSpacing: -0.2,
                ),
              ),
              const Text(
                'total/dia',
                style: TextStyle(
                  fontSize: 8,
                  color: _kText3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailKpiTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final Color valueColor;

  const _DetailKpiTile({
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

class _ScheduleCard extends StatelessWidget {
  final FeedingSchedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _kGold50,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.grain, size: 16, color: _kGold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  schedule.feedType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
              ),
              _ActionIcon(
                icon: Icons.edit_outlined,
                iconColor: _kBlue,
                bgColor: _kBlue50,
                onTap: onEdit,
              ),
              const SizedBox(width: 6),
              _ActionIcon(
                icon: Icons.delete_outline,
                iconColor: AppColors.error,
                bgColor: _kErr50,
                onTap: onDelete,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Color(0x12000000)),
          ),
          _InfoRow(label: 'Quantidade', value: '${_fmtKg(schedule.quantity)} kg'),
          const SizedBox(height: 5),
          _InfoRow(label: 'Vezes por dia', value: '${schedule.timesPerDay}x'),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Horários',
                style: TextStyle(
                  fontSize: 10,
                  color: _kText3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: schedule.feedingTimesList
                      .where((time) => time.trim().isNotEmpty)
                      .map(
                        (time) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _kBrand50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          if ((schedule.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kSurface2,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Observações',
                    style: TextStyle(
                      fontSize: 9,
                      color: _kText3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    schedule.notes!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _kText2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _fmtKg(double value) => value.toStringAsFixed(1).replaceAll('.', ',');
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: _kText3,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: _kText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Ink(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }
}

class _EmptyRationState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyRationState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.9)),
      ),
      child: Column(
        children: [
          const Icon(Icons.fastfood_outlined, size: 42, color: _kText3),
          const SizedBox(height: 8),
          const Text(
            'Nenhuma ração cadastrada',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cadastre o primeiro trato desta baia.',
            style: TextStyle(fontSize: 10, color: _kText3),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar ração'),
          ),
        ],
      ),
    );
  }
}
