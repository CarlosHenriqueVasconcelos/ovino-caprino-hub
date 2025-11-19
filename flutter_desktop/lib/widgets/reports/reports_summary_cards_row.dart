import 'package:flutter/material.dart';
import '../../utils/labels_ptbr.dart';

class ReportsSummaryCardsRow extends StatelessWidget {
  final Map<String, dynamic> summary;
  final ThemeData theme;

  const ReportsSummaryCardsRow({
    super.key,
    required this.summary,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: summary.entries.map((entry) {
          final value = entry.value;
          String display;
          if (value is num &&
              (entry.key.contains('amount') ||
                  entry.key.contains('revenue') ||
                  entry.key.contains('expense') ||
                  entry.key.contains('balance'))) {
            display = 'R\$ ${value.toStringAsFixed(2)}';
          } else if (value is double) {
            display = value.toStringAsFixed(2);
          } else {
            display = value.toString();
          }

          return Card(
            margin: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 180,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ptBrHeader(entry.key).toUpperCase(),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      display,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

