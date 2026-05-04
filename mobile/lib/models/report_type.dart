enum ReportType {
  narrative,
  financial,
  attendance,
  ministryActivity,
}

extension ReportTypeLabel on ReportType {
  String get label => switch (this) {
        ReportType.narrative => 'Narrative / summary',
        ReportType.financial => 'Financial',
        ReportType.attendance => 'Attendance',
        ReportType.ministryActivity => 'Ministry activity',
      };
}
