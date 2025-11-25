class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });
}

enum ReportViewMode { summary, chart, table }

class ReportChartPoint {
  final String label;
  final double value;
  final DateTime? date;

  const ReportChartPoint({
    required this.label,
    required this.value,
    this.date,
  });

  double get normalizedValue {
    if (value <= 0) return 0;
    return (value / (value.abs() + 10)).clamp(0.0, 1.0);
  }

  String get formattedValue => value.toStringAsFixed(2);
}
