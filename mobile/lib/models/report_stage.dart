/// Submission pipeline (mock → later Firebase).
/// Flow: Unit Head → Manager → Director → Administration queue → Executive (web).
enum ReportStage {
  /// Awaiting manager review (from unit head).
  awaitingManager,

  /// Awaiting director review (from manager).
  awaitingDirector,

  /// Director submitted; National Director of Administration (web) receives.
  awaitingAdministration,

  /// Forwarded by Nat. Admin to Assistant General Overseer (web).
  awaitingExecutive,

  /// AGO forwarded to General Overseer for final approval (web).
  awaitingGeneralOverseer,

  /// Final approval (GO).
  approved,

  /// Manager/director returned the report for edits (full note shown to author).
  revisionRequested,
}

extension ReportStageLabel on ReportStage {
  String get label => switch (this) {
        ReportStage.awaitingManager => 'Awaiting manager',
        ReportStage.awaitingDirector => 'Awaiting director',
        ReportStage.awaitingAdministration => 'With National Director (Admin)',
        ReportStage.awaitingExecutive => 'With Assistant General Overseer',
        ReportStage.awaitingGeneralOverseer => 'Awaiting General Overseer',
        ReportStage.approved => 'Approved',
        ReportStage.revisionRequested => 'Returned for revision',
      };
}
