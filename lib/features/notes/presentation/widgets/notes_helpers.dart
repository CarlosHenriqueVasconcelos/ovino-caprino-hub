import 'package:intl/intl.dart';

String formatNoteDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (_) {
    return dateStr;
  }
}

String formatNoteContentPreview(String? content) {
  if (content == null || content.isEmpty) return 'Sem descrição';
  const maxLength = 60;
  if (content.length <= maxLength) return content;
  return '${content.substring(0, maxLength)}...';
}
