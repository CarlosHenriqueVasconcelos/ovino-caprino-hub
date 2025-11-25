import 'package:flutter/material.dart';

import 'reports_models.dart';

class ReportsChartArea extends StatelessWidget {
  final List<ReportChartPoint> points;

  const ReportsChartArea({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: points.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final point = points[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.label,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: point.normalizedValue,
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Text(
                  point.formattedValue,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
