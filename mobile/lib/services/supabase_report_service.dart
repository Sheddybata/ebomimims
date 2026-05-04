import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/metric_labels.dart';
import '../models/app_role.dart';
import '../models/report.dart';
import '../models/report_stage.dart';
import '../models/report_type.dart';
import '../models/session_user.dart';

abstract final class SupabaseReportService {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<Report> createReport({
    required SessionUser user,
    required String title,
    required String body,
    required ReportType type,
    required String? unitCode,
    Map<String, String>? metrics,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw const AuthException('You must be signed in to submit a report.');
    }

    final directorateId = user.directorateId != null ? await _directorateUuid(user.directorateId!) : null;
    final unitId = (unitCode == null || unitCode == 'state_ministry') ? null : await _unitUuid(unitCode);
    final stage = _initialStage(user);
    final reviewerRole = _initialReviewerRole(user);

    final reportRow = await _client
        .from('reports')
        .insert({
          'title': title,
          'body': body,
          'report_type': type.label,
          'stage': stage,
          if (directorateId != null) 'directorate_id': directorateId,
          if (unitId != null) 'unit_id': unitId,
          if (user.stateId != null) 'state_id': user.stateId,
          'author_id': authUser.id,
          'author_role': _roleValue(user.role),
          'current_reviewer_role': reviewerRole,
          'submitted_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select('id')
        .single();

    final reportId = reportRow['id'] as String;

    final metricRows = (metrics ?? const <String, String>{}).entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map(
          (entry) => {
            'report_id': reportId,
            'metric_key': entry.key,
            'metric_label': displayLabelForMetricKey(entry.key),
            'metric_value': entry.value.trim(),
          },
        )
        .toList();
    if (metricRows.isNotEmpty) {
      await _client.from('report_metrics').insert(metricRows);
    }

    await _client.from('report_timeline').insert({
      'report_id': reportId,
      'action': _initialTimelineAction(user),
      'label': _initialTimelineLabel(user),
      'actor_id': authUser.id,
      'actor_role': _roleValue(user.role),
      'actor_name': user.displayName,
    });

    final created = await getReportById(reportId);
    if (created == null) throw StateError('Report not found after submit');
    return created;
  }

  static Future<List<Report>> inboxFor(SessionUser user) async {
    var query = _client.from('reports').select(_reportSelect);

    final authUser = _client.auth.currentUser;
    if (authUser == null) return [];

    if (user.isUnitHead || user.isStateCoordinator) {
      query = query
          .eq('author_id', authUser.id)
          .inFilter('stage', ['revision_requested', 'returned_for_revision']);
    } else if (user.isManager) {
      final queueRows = await query
          .eq('stage', 'awaiting_manager')
          .order('updated_at', ascending: false);
      final revisionRows = await _client
          .from('reports')
          .select(_reportSelect)
          .eq('author_id', authUser.id)
          .inFilter('stage', ['revision_requested', 'returned_for_revision'])
          .order('updated_at', ascending: false);
      return _dedupeReports(
        _dedupeRows([...queueRows, ...revisionRows]).map(_reportFromRow),
      );
    } else if (user.isDirector) {
      final queueRows = await query
          .eq('stage', 'awaiting_director')
          .order('updated_at', ascending: false);
      final revisionRows = await _client
          .from('reports')
          .select(_reportSelect)
          .eq('author_id', authUser.id)
          .inFilter('stage', ['revision_requested', 'returned_for_revision'])
          .order('updated_at', ascending: false);
      return _dedupeReports(
        _dedupeRows([...queueRows, ...revisionRows]).map(_reportFromRow),
      );
    } else {
      return [];
    }

    final rows = await query.order('updated_at', ascending: false);
    return _dedupeReports(rows.map(_reportFromRow));
  }

  static Future<Report> resubmitRevision({
    required String reportId,
    required String title,
    required String body,
    required ReportType type,
    Map<String, String>? metrics,
  }) async {
    await _client.rpc(
      'author_resubmit_report_for_revision',
      params: {
        'p_report_id': reportId,
        'p_title': title,
        'p_body': body,
        'p_report_type': type.label,
        'p_metrics': metrics ?? const <String, String>{},
      },
    );
    final updated = await getReportById(reportId);
    if (updated == null) throw StateError('Report not found after resubmit');
    return updated;
  }

  static Future<List<Report>> historyFor(SessionUser user) async {
    final rows = await _client
        .from('reports')
        .select(_reportSelect)
        .order('updated_at', ascending: false);
    return rows.map(_reportFromRow).toList();
  }

  static Future<Report?> getReportById(String id) async {
    final row = await _client
        .from('reports')
        .select(_reportSelect)
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _reportFromRow(row);
  }

  static Future<Report> forwardToDirector(
    String reportId,
    SessionUser user,
  ) async {
    await _client.rpc(
      'manager_forward_report_to_director',
      params: {'p_report_id': reportId},
    );
    final updated = await getReportById(reportId);
    if (updated == null) throw StateError('Report not found after update');
    return updated;
  }

  static Future<Report> returnForRevision({
    required String reportId,
    required SessionUser reviewer,
    required String note,
  }) async {
    final functionName = reviewer.isDirector
        ? 'director_return_report_for_revision'
        : 'manager_return_report_for_revision';
    await _client.rpc(
      functionName,
      params: {'p_report_id': reportId, 'p_note': note},
    );
    final updated = await getReportById(reportId);
    if (updated == null) throw StateError('Report not found after update');
    return updated;
  }

  static Future<Report> submitToNda(String reportId) async {
    final before = await getReportById(reportId);
    await _client.rpc(
      'director_submit_report_to_nda',
      params: {'p_report_id': reportId},
    );
    final updated = await getReportById(reportId);
    if (updated != null) return updated;
    if (before != null) {
      return before.copyWith(
        stage: ReportStage.awaitingAdministration,
        updatedAt: DateTime.now(),
        clearSendBack: true,
      );
    }
    throw StateError('Report not found after update');
  }

  static Future<String> _directorateUuid(String code) async {
    final row = await _client
        .from('directorates')
        .select('id')
        .eq('code', code)
        .single();
    return row['id'] as String;
  }

  static Future<String> _unitUuid(String code) async {
    final row = await _client
        .from('units')
        .select('id')
        .eq('code', code)
        .single();
    return row['id'] as String;
  }

  static String _roleValue(AppRole role) {
    return switch (role) {
      AppRole.unitHead => 'unit_head',
      AppRole.manager => 'manager',
      AppRole.director => 'director',
      AppRole.stateCoordinator => 'state_coordinator',
    };
  }

  static const _reportSelect = '''
    id,
    title,
    body,
    report_type,
    stage,
    author_id,
    author_role,
    returned_note,
    returned_at,
    created_at,
    updated_at,
    directorates(code, name),
    units(code, name),
    reference_states(id, name),
    report_metrics(metric_key, metric_value)
  ''';

  static Report _reportFromRow(Map<String, dynamic> row) {
    final directorate = row['directorates'] as Map<String, dynamic>?;
    final stateInfo = row['reference_states'] as Map<String, dynamic>?;
    final unit = row['units'] as Map<String, dynamic>?;
    final metricsRows = row['report_metrics'] as List<dynamic>? ?? const [];
    final metrics = <String, String>{
      for (final raw in metricsRows)
        if (raw is Map<String, dynamic>)
          raw['metric_key'] as String: raw['metric_value'] as String,
    };

    final isState = row['author_role'] == 'state_coordinator';

    return Report(
      id: row['id'] as String,
      title: row['title'] as String,
      summary: row['body'] as String,
      type: _reportTypeFromValue(row['report_type'] as String?),
      directorateId: isState ? (stateInfo?['id'] as String? ?? '') : (directorate?['code'] as String? ?? ''),
      directorateName: isState ? (stateInfo?['name'] as String? ?? 'State') : (directorate?['name'] as String? ?? 'Directorate'),
      unitId: isState ? 'state_ministry' : unit?['code'] as String?,
      unitName: isState ? 'State Ministry' : unit?['name'] as String?,
      authorId: row['author_id'] as String,
      authorName: 'Report author',
      authorRole: _appRoleFromValue(row['author_role'] as String?),
      stage: _stageFromValue(row['stage'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      sendBackNote: row['returned_note'] as String?,
      sendBackByName: row['returned_note'] == null ? null : 'Reviewer',
      sendBackByRole: null,
      sendBackAt: row['returned_at'] == null
          ? null
          : DateTime.parse(row['returned_at'] as String),
      metrics: metrics.isEmpty ? null : metrics,
    );
  }

  static List<Map<String, dynamic>> _dedupeRows(List<dynamic> rows) {
    final seen = <String>{};
    final out = <Map<String, dynamic>>[];
    for (final row in rows) {
      if (row is Map<String, dynamic> && seen.add(row['id'] as String)) {
        out.add(row);
      }
    }
    out.sort(
      (a, b) => DateTime.parse(
        b['updated_at'] as String,
      ).compareTo(DateTime.parse(a['updated_at'] as String)),
    );
    return out;
  }

  static List<Report> _dedupeReports(Iterable<Report> reports) {
    final byKey = <String, Report>{};
    for (final report in reports) {
      final key = [
        report.authorId,
        report.authorRole.name,
        report.stage.name,
        report.title.trim().toLowerCase(),
        report.summary.trim().toLowerCase(),
        report.unitId ?? '',
      ].join('|');
      final current = byKey[key];
      if (current == null || report.updatedAt.isAfter(current.updatedAt)) {
        byKey[key] = report;
      }
    }
    final out = byKey.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return out;
  }

  static ReportType _reportTypeFromValue(String? value) {
    for (final type in ReportType.values) {
      if (type.label == value) return type;
    }
    return ReportType.narrative;
  }

  static AppRole _appRoleFromValue(String? value) {
    return switch (value) {
      'manager' => AppRole.manager,
      'director' => AppRole.director,
      'state_coordinator' => AppRole.stateCoordinator,
      _ => AppRole.unitHead,
    };
  }

  static ReportStage _stageFromValue(String? value) {
    return switch (value) {
      'awaiting_director' => ReportStage.awaitingDirector,
      'awaiting_administration' => ReportStage.awaitingAdministration,
      'awaiting_ago' => ReportStage.awaitingExecutive,
      'awaiting_general_overseer' => ReportStage.awaitingGeneralOverseer,
      'approved' => ReportStage.approved,
      'revision_requested' ||
      'returned_for_revision' => ReportStage.revisionRequested,
      _ => ReportStage.awaitingManager,
    };
  }

  static String _initialStage(SessionUser user) {
    if (user.isUnitHead) return 'awaiting_manager';
    if (user.isManager) return 'awaiting_director';
    return 'awaiting_administration';
  }

  static String _initialReviewerRole(SessionUser user) {
    if (user.isUnitHead) return 'manager';
    if (user.isManager) return 'director';
    return 'nda';
  }

  static String _initialTimelineAction(SessionUser user) {
    if (user.isUnitHead) return 'forwarded_to_manager';
    if (user.isManager) return 'forwarded_to_director';
    return 'submitted_to_nda';
  }

  static String _initialTimelineLabel(SessionUser user) {
    if (user.isUnitHead) return 'Submitted to manager';
    if (user.isManager) return 'Submitted to director';
    return 'Submitted to NDA';
  }
}
