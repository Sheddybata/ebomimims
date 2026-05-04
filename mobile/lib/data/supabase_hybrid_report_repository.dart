import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/report.dart';
import '../models/report_type.dart';
import '../models/session_user.dart';
import '../services/supabase_report_service.dart';
import 'mock_report_repository.dart';
import 'report_repository.dart';
import 'report_validation.dart';

class SupabaseHybridReportRepository implements ReportRepository {
  SupabaseHybridReportRepository(this._local);

  final MockReportRepository _local;

  bool get _hasSupabaseSession =>
      Supabase.instance.client.auth.currentUser != null;

  @override
  Future<Report?> getReportById(String id) async {
    if (_hasSupabaseSession) {
      final remote = await SupabaseReportService.getReportById(id);
      if (remote != null) return remote;
    }
    return _local.getReportById(id);
  }

  @override
  Future<List<Report>> inboxFor(SessionUser user) async {
    if (_hasSupabaseSession) {
      return SupabaseReportService.inboxFor(user);
    }
    return _local.inboxFor(user);
  }

  @override
  Future<List<Report>> historyFor(SessionUser user) async {
    if (_hasSupabaseSession) {
      return SupabaseReportService.historyFor(user);
    }
    return _local.historyFor(user);
  }

  @override
  Future<Report> createUnitHeadReport({
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
    required String unitId,
    required String unitName,
    Map<String, String>? metrics,
  }) {
    if (_hasSupabaseSession) {
      return SupabaseReportService.createReport(
        user: user,
        title: title,
        body: summary,
        type: type,
        unitCode: unitId,
        metrics: metrics,
      );
    }
    return _local.createUnitHeadReport(
      user: user,
      title: title,
      summary: summary,
      type: type,
      unitId: unitId,
      unitName: unitName,
      metrics: metrics,
    );
  }

  @override
  Future<Report> createManagerReport({
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  }) {
    if (_hasSupabaseSession) {
      return SupabaseReportService.createReport(
        user: user,
        title: title,
        body: summary,
        type: type,
        unitCode: null,
      );
    }
    return _local.createManagerReport(
      user: user,
      title: title,
      summary: summary,
      type: type,
    );
  }

  @override
  Future<Report> createDirectorReport({
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  }) {
    if (_hasSupabaseSession) {
      return SupabaseReportService.createReport(
        user: user,
        title: title,
        body: summary,
        type: type,
        unitCode: null,
      );
    }
    return _local.createDirectorReport(
      user: user,
      title: title,
      summary: summary,
      type: type,
    );
  }

  @override
  Future<Report> forwardToDirector(String reportId, SessionUser user) async {
    if (_hasSupabaseSession) {
      final remote = await SupabaseReportService.getReportById(reportId);
      if (remote != null) {
        return SupabaseReportService.forwardToDirector(reportId, user);
      }
    }
    return _local.forwardToDirector(reportId, user);
  }

  @override
  Future<Report> sendBackForRevision({
    required String reportId,
    required SessionUser reviewer,
    required String note,
  }) async {
    final trimmed = note.trim();
    if (trimmed.length < kMinSendBackNoteLength) {
      throw ArgumentError(
        'Your message must be at least $kMinSendBackNoteLength characters so the author has clear guidance.',
      );
    }
    if (_hasSupabaseSession) {
      final remote = await SupabaseReportService.getReportById(reportId);
      if (remote != null) {
        return SupabaseReportService.returnForRevision(
          reportId: reportId,
          reviewer: reviewer,
          note: trimmed,
        );
      }
    }
    return _local.sendBackForRevision(
      reportId: reportId,
      reviewer: reviewer,
      note: trimmed,
    );
  }

  @override
  Future<Report> directorSubmitUpward(String reportId, SessionUser user) async {
    if (_hasSupabaseSession) {
      final remote = await SupabaseReportService.getReportById(reportId);
      if (remote != null) {
        return SupabaseReportService.submitToNda(reportId);
      }
    }
    return _local.directorSubmitUpward(reportId, user);
  }

  @override
  Future<Report> managerResubmitRevision({
    required String reportId,
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  }) {
    if (_hasSupabaseSession) {
      return SupabaseReportService.resubmitRevision(
        reportId: reportId,
        title: title,
        body: summary,
        type: type,
      );
    }
    return _local.managerResubmitRevision(
      reportId: reportId,
      user: user,
      title: title,
      summary: summary,
      type: type,
    );
  }

  @override
  Future<Report> unitHeadResubmitRevision({
    required String reportId,
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
    Map<String, String>? metrics,
  }) {
    if (_hasSupabaseSession) {
      return SupabaseReportService.resubmitRevision(
        reportId: reportId,
        title: title,
        body: summary,
        type: type,
        metrics: metrics,
      );
    }
    return _local.unitHeadResubmitRevision(
      reportId: reportId,
      user: user,
      title: title,
      summary: summary,
      type: type,
      metrics: metrics,
    );
  }

}
