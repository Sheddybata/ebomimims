import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reporting_framework_common.dart';
import '../data/reporting_framework_resolve.dart';
import '../data/seed_units.dart';
import '../models/app_role.dart';
import 'auth_provider.dart';

/// Role-scoped view of the Reporting & Metrics Framework for Home.
class ReportingMetricsView {
  const ReportingMetricsView({
    required this.roleTitle,
    required this.bullets,
    this.unitLabel,
    this.footerNote,
  });

  final String roleTitle;
  final String? unitLabel;
  final List<String> bullets;
  final String? footerNote;
}

const String kReportingFlowBlurb =
    'Weekly flow (target): unit heads submit primary data → manager draft (tactical + common admin metrics) '
    'aggregates unit input → director reviews and submits upward to the National Director of Administration. '
    'Smart forms: unit heads use numeric/structured fields where possible; managers use summary text for tactical sections.';

final reportingMetricsViewProvider = Provider<ReportingMetricsView?>((ref) {
  final user = ref.watch(authProvider);
  if (user == null) return null;
  final fw = resolvedFrameworkForDirectorate(user.directorateId);

  switch (user.role) {
    case AppRole.director:
      return ReportingMetricsView(
        roleTitle: 'Director report (strategic impact)',
        bullets: fw.directorStrategic,
        footerNote: kReportingFlowBlurb,
      );
    case AppRole.manager:
      final tactical = [...fw.managerTactical, ...kCommonManagerAdministrativeMetrics];
      return ReportingMetricsView(
        roleTitle: 'Manager report (tactical + common admin)',
        bullets: tactical,
        footerNote:
            '$kReportingFlowBlurb\n\nCommon administrative metrics apply to all managers in every directorate.',
      );
    case AppRole.stateCoordinator:
      final items = fw.unitHeadByUnitId['state_ministry'] ?? [];
      return ReportingMetricsView(
        roleTitle: 'State Ministry Report',
        unitLabel: user.stateName ?? 'State',
        bullets: items,
        footerNote: 'State coordinators submit reports directly to the National Director of Administration.',
      );
    case AppRole.unitHead:
      final uid = user.primaryUnitId;
      if (uid == null) {
        return ReportingMetricsView(
          roleTitle: 'Unit head report (primary data)',
          bullets: const [
            'Select your unit on the login screen to see unit-specific metrics to collect each week.',
          ],
          footerNote: kReportingFlowBlurb,
        );
      }
      String? unitName;
      final dId = user.directorateId;
      if (dId != null) {
        for (final u in unitsForDirectorate(dId)) {
          if (u.id == uid) {
            unitName = u.name;
            break;
          }
        }
      }
      final items = fw.unitHeadByUnitId[uid] ??
          [
            'Unit-specific metrics are not yet mapped for this unit id: $uid',
          ];
      final photo = fw.unitHeadPhotoEvidenceRecommended
          ? 'Photo uploads: for this directorate, attach photos where helpful (e.g. incidents, repairs). '
              'Full capture in the app is planned; use Submit details field for file links or references meanwhile.'
          : null;
      return ReportingMetricsView(
        roleTitle: 'Unit head report (primary data)',
        unitLabel: unitName ?? uid,
        bullets: items,
        footerNote: photo != null ? '$photo\n\n$kReportingFlowBlurb' : kReportingFlowBlurb,
      );
  }
});
