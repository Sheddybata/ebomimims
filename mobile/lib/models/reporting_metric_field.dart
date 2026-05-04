/// Input style for unit-head structured metrics (Submit screen + web display).
enum ReportingMetricInput {
  wholeNumber,
  decimal,
  singleLine,
  multiline,
}

class ReportingMetricField {
  const ReportingMetricField({
    required this.id,
    required this.label,
    this.input = ReportingMetricInput.multiline,
    this.isRequired = true,
  });

  /// Stable key stored in [Report.metrics] and synced to web JSON.
  final String id;
  final String label;
  final ReportingMetricInput input;
  final bool isRequired;

  static List<ReportingMetricField> listFromBullets(List<String> bullets) {
    return [
      for (var i = 0; i < bullets.length; i++)
        ReportingMetricField(
          id: 'metric_line_$i',
          label: bullets[i],
          input: ReportingMetricInput.multiline,
        ),
    ];
  }
}
