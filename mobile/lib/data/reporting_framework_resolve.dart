import '../models/directorate_reporting_framework.dart';
import '../models/reporting_metric_field.dart';
import 'directorates.dart';
import 'reporting_framework_catalog.dart';
import 'seed_units.dart';

/// Detailed charter entries — remaining directorates get a tailored three-field template per unit.
DirectorateReportingFramework resolvedFrameworkForDirectorate(String? directorateId) {
  if (directorateId == null) {
    return kReportingFrameworkCatalog['state_ministry']!;
  }
  return kReportingFrameworkCatalog[directorateId] ??
      buildFallbackReportingFramework(directorateId);
}

/// One framework row per real unit: numeric emphasis + narrative (aligned with dashboard-style web display).
DirectorateReportingFramework buildFallbackReportingFramework(String directorateId) {
  final units = unitsForDirectorate(directorateId);
  final mgr = [
    'Weekly tactical roll-up: summarize unit line outputs, blockers, and decisions needed.',
  ];
  final dir = [
    'Strategic impact: trends, risks, and alignment with national priorities this reporting period.',
  ];
  if (units.isEmpty) {
    return DirectorateReportingFramework(
      unitHeadByUnitId: {},
      unitHeadFieldsByUnitId: {},
      managerTactical: mgr,
      directorStrategic: dir,
    );
  }

  final dname = directorateName(directorateId);
  final bullets = <String, List<String>>{};
  final fields = <String, List<ReportingMetricField>>{};

  for (final u in units) {
    bullets[u.id] = [
      'Weekly primary data — ${u.name}: record measurable outputs for $dname.',
    ];
    fields[u.id] = [
      ReportingMetricField(
        id: '${u.id}_primary_count',
        label: 'Primary count / volume — ${u.name}',
        input: ReportingMetricInput.wholeNumber,
      ),
      ReportingMetricField(
        id: '${u.id}_secondary_metric',
        label: 'Secondary metric or % (optional) — ${u.name}',
        input: ReportingMetricInput.decimal,
        isRequired: false,
      ),
      ReportingMetricField(
        id: '${u.id}_narrative',
        label: 'Narrative, quality, risks, follow-up — ${u.name}',
        input: ReportingMetricInput.multiline,
      ),
    ];
  }

  return DirectorateReportingFramework(
    unitHeadByUnitId: bullets,
    unitHeadFieldsByUnitId: fields,
    managerTactical: mgr,
    directorStrategic: dir,
  );
}
