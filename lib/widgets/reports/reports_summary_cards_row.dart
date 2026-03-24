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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    if (isMobile) {
      // Mobile: GridView para evitar overflow
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: summary.length,
          itemBuilder: (context, index) {
            final entry = summary.entries.elementAt(index);
            return _buildSummaryCard(entry, theme, isMobile: true);
          },
        ),
      );
    }
    
    // Desktop: horizontal scroll
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: summary.entries.map((entry) {
          return _buildSummaryCard(entry, theme, isMobile: false);
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard(MapEntry<String, dynamic> entry, ThemeData theme, {required bool isMobile}) {
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
      margin: EdgeInsets.only(right: isMobile ? 0 : 12),
      child: SizedBox(
        width: isMobile ? null : 180,
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ptBrHeader(entry.key).toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: isMobile ? 10 : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 4 : 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  display,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : null,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
