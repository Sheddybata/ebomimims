import 'reporting_metric_field.dart';

/// Reporting & metrics checklist per directorate (aligned with seed unit IDs).
class DirectorateReportingFramework {
  const DirectorateReportingFramework({
    required this.unitHeadByUnitId,
    required this.managerTactical,
    required this.directorStrategic,
    this.unitHeadPhotoEvidenceRecommended = false,
    this.unitHeadFieldsByUnitId,
  });

  /// Primary data bullets per unit (Home checklist + fallback labels).
  final Map<String, List<String>> unitHeadByUnitId;

  /// Structured Submit fields per unit; when null, use [ReportingMetricField.listFromBullets].
  final Map<String, List<ReportingMetricField>>? unitHeadFieldsByUnitId;

  /// Tactical summary areas (managers: narrative / summary text areas).
  final List<String> managerTactical;

  /// Strategic impact areas (directors).
  final List<String> directorStrategic;

  /// Security & infrastructure: photo evidence as part of unit head reporting (app support TBD).
  final bool unitHeadPhotoEvidenceRecommended;

  /// Resolved fields for [unitId] (explicit or derived from bullets).
  List<ReportingMetricField> resolvedFieldsForUnit(String unitId) {
    final explicit = unitHeadFieldsByUnitId?[unitId];
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final bullets = unitHeadByUnitId[unitId];
    if (bullets == null) return const [];
    return ReportingMetricField.listFromBullets(bullets);
  }
}
