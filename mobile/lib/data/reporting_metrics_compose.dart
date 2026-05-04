import '../models/reporting_metric_field.dart';

/// Human-readable block embedded in [Report.summary] for managers/directors and web previews.
String formatMetricsForSummary(
  Map<String, String> values,
  List<ReportingMetricField> fields,
) {
  final b = StringBuffer();
  var any = false;
  for (final f in fields) {
    final v = values[f.id]?.trim() ?? '';
    if (v.isEmpty) continue;
    any = true;
    b.writeln('• ${f.label}: $v');
  }
  if (!any) return '';
  return '— Structured metrics —\n${b.toString().trimRight()}';
}

/// Validate [values] against [fields]; returns null if OK, else error message.
String? validateMetricValues(
  Map<String, String> values,
  List<ReportingMetricField> fields,
) {
  for (final f in fields) {
    final v = values[f.id]?.trim() ?? '';
    if (f.isRequired && v.isEmpty) {
      return 'Please fill: ${f.label}';
    }
    if (v.isEmpty) continue;
    switch (f.input) {
      case ReportingMetricInput.wholeNumber:
        if (int.tryParse(v) == null) {
          return '${f.label}: use a whole number (no decimals).';
        }
        break;
      case ReportingMetricInput.decimal:
        if (double.tryParse(v) == null) {
          return '${f.label}: use a valid number.';
        }
        break;
      case ReportingMetricInput.singleLine:
      case ReportingMetricInput.multiline:
        break;
    }
  }
  return null;
}

/// Inverse of [formatMetricsForSummary] + notes join (best-effort).
String extractNotesAfterStructuredBlock(String summary) {
  final parts = summary.split('\n\n');
  if (parts.isEmpty) return summary;
  if (parts.first.trim().startsWith('— Structured metrics —')) {
    return parts.skip(1).join('\n\n').trim();
  }
  return summary;
}
