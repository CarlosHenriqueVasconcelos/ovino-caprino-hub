import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/feeding_service.dart';
import '../models/feeding_pen.dart';
import '../models/feeding_schedule.dart';
import 'feeding_form_dialog.dart';

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
      Provider.of<FeedingService>(context, listen: false).loadPens();
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
      Provider.of<FeedingService>(context, listen: false).loadPens();
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
      final feedingService =
          Provider.of<FeedingService>(context, listen: false);
      await feedingService.deleteSchedule(schedule.id, widget.pen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pen.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Informar Trato',
            onPressed: () => _showFeedingDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Informações da Baia
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.agriculture,
                        size: 40, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pen.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.pen.number != null &&
                              widget.pen.number!.isNotEmpty)
                            Text(
                              'Número: ${widget.pen.number}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.pen.notes != null &&
                    widget.pen.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Observações:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.pen.notes!),
                ],
              ],
            ),
          ),
          // Lista de Tratos
          Expanded(
            child: Consumer<FeedingService>(
              builder: (context, feedingService, _) {
                if (feedingService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final schedules =
                    feedingService.getSchedulesForPen(widget.pen.id);

                if (schedules.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fastfood_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum trato cadastrado',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _showFeedingDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Informar Primeiro Trato'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return _buildScheduleCard(schedule);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(FeedingSchedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule.feedType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showFeedingDialog(schedule),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSchedule(schedule),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Quantidade', '${schedule.quantity} kg'),
            _buildInfoRow('Vezes por dia', '${schedule.timesPerDay}x'),
            _buildInfoRow('Horários', schedule.feedingTimesList.join(', ')),
            if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Observações:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(schedule.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
