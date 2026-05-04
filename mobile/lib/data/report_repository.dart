import '../models/report.dart';
import '../models/report_type.dart';
import '../models/session_user.dart';

abstract class ReportRepository {
  Future<Report?> getReportById(String id);

  Future<List<Report>> inboxFor(SessionUser user);
  Future<List<Report>> historyFor(SessionUser user);
  Future<Report> createUnitHeadReport({
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
    required String unitId,
    required String unitName,
    Map<String, String>? metrics,
  });

  /// Manager-authored report goes to the director of this directorate.
  Future<Report> createManagerReport({
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  });

  /// Manager moves a report toward the director.
  Future<Report> forwardToDirector(String reportId, SessionUser user);

  /// Manager or director sends the report back to the author with feedback (note required).
  Future<Report> sendBackForRevision({
    required String reportId,
    required SessionUser reviewer,
    required String note,
  });

  /// Unit head updates a report after revision and resubmits to the manager queue.
  Future<Report> unitHeadResubmitRevision({
    required String reportId,
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
    Map<String, String>? metrics,
  });

  /// Manager updates their own report after director send-back.
  Future<Report> managerResubmitRevision({
    required String reportId,
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  });

  /// Director sends an approved line report to Administration / executive pipeline.
  Future<Report> directorSubmitUpward(String reportId, SessionUser user);

  /// Director creates a report that enters the Administration queue (and Next.js later).
  Future<Report> createDirectorReport({
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  });
}
