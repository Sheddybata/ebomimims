import 'package:uuid/uuid.dart';

import '../models/app_role.dart';
import '../models/report.dart';
import '../models/report_stage.dart';
import '../models/report_type.dart';
import '../models/session_user.dart';
import 'directorates.dart';
import 'report_repository.dart';
import 'report_validation.dart';

/// In-memory store for UI development — swap for Firebase.
class MockReportRepository implements ReportRepository {
  MockReportRepository() {
    _seed();
  }

  final _uuid = const Uuid();
  final List<Report> _reports = [];

  /// Matches [LoginScreen] id pattern for Missions & Evangelism demo logins.
  static const _uhMe = 'uh_missions_evangelism_1';
  static const _mgrMe = 'mgr_missions_evangelism_1';
  static const _dirMe = 'dir_missions_evangelism_1';

  void _seed() {
    final now = DateTime.now();
    final dName = directorateName('missions_evangelism');
    _reports.addAll([
      Report(
        id: 'seed-uh-awaiting-mgr',
        title: 'Weekly field summary',
        summary: 'Prayer walks completed; 12 new contacts. Awaiting your manager.',
        type: ReportType.narrative,
        directorateId: 'missions_evangelism',
        directorateName: dName,
        unitId: 'me_u1',
        unitName: 'Street and Community Evangelism Unit',
        authorId: _uhMe,
        authorName: 'Unit head (sample)',
        authorRole: AppRole.unitHead,
        stage: ReportStage.awaitingManager,
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      Report(
        id: 'seed-mgr-forwarded',
        title: 'Consolidated Q1 outreach numbers',
        summary: 'Manager consolidated unit stats — needs director approval.',
        type: ReportType.financial,
        directorateId: 'missions_evangelism',
        directorateName: dName,
        unitId: 'me_u2',
        unitName: 'Missionary and rural outreach unit',
        authorId: _uhMe,
        authorName: 'Unit head (sample)',
        authorRole: AppRole.unitHead,
        stage: ReportStage.awaitingDirector,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      Report(
        id: 'seed-manager-authored',
        title: 'Manager memorandum — youth follow-up',
        summary: 'Cross-unit coordination request submitted by manager.',
        type: ReportType.narrative,
        directorateId: 'missions_evangelism',
        directorateName: dName,
        unitId: null,
        unitName: null,
        authorId: _mgrMe,
        authorName: 'Manager (sample)',
        authorRole: AppRole.manager,
        stage: ReportStage.awaitingDirector,
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
      Report(
        id: 'seed-revision-uh',
        title: 'Rural outreach expense draft',
        summary: 'Manager requested: add line items for transport and receipts.',
        type: ReportType.financial,
        directorateId: 'missions_evangelism',
        directorateName: dName,
        unitId: 'me_u1',
        unitName: 'Street and Community Evangelism Unit',
        authorId: _uhMe,
        authorName: 'Unit head (sample)',
        authorRole: AppRole.unitHead,
        stage: ReportStage.revisionRequested,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        sendBackNote:
            'Please attach scanned receipts for transport and list each expense line with date and amount. '
            'The directorate finance checklist requires at least three line items before this can move forward.',
        sendBackByName: 'Manager (sample)',
        sendBackByRole: AppRole.manager,
        sendBackAt: now.subtract(const Duration(hours: 1)),
      ),
      Report(
        id: 'seed-mgr-revision',
        title: 'Manager memorandum — needs expansion',
        summary: 'Draft after director asked for clearer KPIs and timeline.',
        type: ReportType.narrative,
        directorateId: 'missions_evangelism',
        directorateName: dName,
        unitId: null,
        unitName: null,
        authorId: _mgrMe,
        authorName: 'Manager (sample)',
        authorRole: AppRole.manager,
        stage: ReportStage.revisionRequested,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(minutes: 40)),
        sendBackNote:
            'Please add a concrete timeline for youth follow-up and list two measurable KPIs (e.g. headcount milestones). '
            'The directorate lead needs this before signing off.',
        sendBackByName: 'Director (sample)',
        sendBackByRole: AppRole.director,
        sendBackAt: now.subtract(const Duration(minutes: 40)),
      ),
      Report(
        id: 'seed-with-nat-admin',
        title: 'Directorate annual summary (director)',
        summary: 'Director submission now with National Director of Administration.',
        type: ReportType.narrative,
        directorateId: 'missions_evangelism',
        directorateName: dName,
        unitId: null,
        unitName: null,
        authorId: _dirMe,
        authorName: 'Director (sample)',
        authorRole: AppRole.director,
        stage: ReportStage.awaitingAdministration,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
    ]);
  }

  @override
  Future<Report?> getReportById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Report>> inboxFor(SessionUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (user.isUnitHead) {
      return _reports
          .where(
            (r) =>
                r.authorId == user.id && r.stage == ReportStage.revisionRequested,
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    if (user.isManager) {
      final line = _reports.where(
        (r) =>
            r.directorateId == user.directorateId &&
            r.stage == ReportStage.awaitingManager &&
            r.unitId != null &&
            user.unitIds.contains(r.unitId),
      );
      final ownRevision = _reports.where(
        (r) =>
            r.authorId == user.id &&
            r.stage == ReportStage.revisionRequested &&
            r.authorRole == AppRole.manager,
      );
      return [...ownRevision, ...line].toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    if (user.isDirector) {
      return _reports
          .where(
            (r) =>
                r.directorateId == user.directorateId &&
                r.stage == ReportStage.awaitingDirector,
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return [];
  }

  @override
  Future<List<Report>> historyFor(SessionUser user) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (user.isUnitHead) {
      return _reports
          .where((r) => r.authorId == user.id)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    if (user.isManager) {
      return _reports
          .where(
            (r) =>
                r.directorateId == user.directorateId &&
                (r.authorRole == AppRole.unitHead ||
                    r.authorRole == AppRole.manager),
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    if (user.isDirector) {
      return _reports
          .where((r) => r.directorateId == user.directorateId)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return [];
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
  }) async {
    final now = DateTime.now();
    final r = Report(
      id: _uuid.v4(),
      title: title,
      summary: summary,
      type: type,
      directorateId: user.directorateId ?? '',
      directorateName: user.directorateName ?? '',
      unitId: unitId,
      unitName: unitName,
      authorId: user.id,
      authorName: user.displayName,
      authorRole: AppRole.unitHead,
      stage: ReportStage.awaitingManager,
      createdAt: now,
      updatedAt: now,
      metrics: metrics,
    );
    _reports.add(r);
    return r;
  }

  @override
  Future<Report> createManagerReport({
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  }) async {
    if (!user.isManager) throw StateError('Only managers can create manager reports');
    final now = DateTime.now();
    final r = Report(
      id: _uuid.v4(),
      title: title,
      summary: summary,
      type: type,
      directorateId: user.directorateId ?? '',
      directorateName: user.directorateName ?? '',
      unitId: null,
      unitName: null,
      authorId: user.id,
      authorName: user.displayName,
      authorRole: AppRole.manager,
      stage: ReportStage.awaitingDirector,
      createdAt: now,
      updatedAt: now,
    );
    _reports.add(r);
    return r;
  }

  @override
  Future<Report> forwardToDirector(String reportId, SessionUser user) async {
    final i = _reports.indexWhere((r) => r.id == reportId);
    if (i < 0) throw StateError('Report not found');
    if (!user.isManager) throw StateError('Only managers can forward');
    final r = _reports[i];
    if (r.stage != ReportStage.awaitingManager) {
      throw StateError('Invalid stage');
    }
    final updated = r.copyWith(
      stage: ReportStage.awaitingDirector,
      clearSendBack: true,
      updatedAt: DateTime.now(),
    );
    _reports[i] = updated;
    return updated;
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
    final i = _reports.indexWhere((r) => r.id == reportId);
    if (i < 0) throw StateError('Report not found');
    final r = _reports[i];
    final now = DateTime.now();
    if (reviewer.isManager && r.stage == ReportStage.awaitingManager) {
      final updated = r.copyWith(
        stage: ReportStage.revisionRequested,
        sendBackNote: trimmed,
        sendBackByName: reviewer.displayName,
        sendBackByRole: AppRole.manager,
        sendBackAt: now,
        updatedAt: now,
      );
      _reports[i] = updated;
      return updated;
    }
    if (reviewer.isDirector && r.stage == ReportStage.awaitingDirector) {
      final updated = r.copyWith(
        stage: ReportStage.revisionRequested,
        sendBackNote: trimmed,
        sendBackByName: reviewer.displayName,
        sendBackByRole: AppRole.director,
        sendBackAt: now,
        updatedAt: now,
      );
      _reports[i] = updated;
      return updated;
    }
    throw StateError('Invalid reviewer or stage for send-back');
  }

  @override
  Future<Report> unitHeadResubmitRevision({
    required String reportId,
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
    Map<String, String>? metrics,
  }) async {
    if (!user.isUnitHead) throw StateError('Only unit heads use this resubmit path');
    final i = _reports.indexWhere((r) => r.id == reportId);
    if (i < 0) throw StateError('Report not found');
    final r = _reports[i];
    if (r.authorId != user.id) throw StateError('Not your report');
    if (r.stage != ReportStage.revisionRequested) throw StateError('Not in revision');
    final now = DateTime.now();
    final updated = r.copyWith(
      title: title,
      summary: summary,
      type: type,
      stage: ReportStage.awaitingManager,
      clearSendBack: true,
      updatedAt: now,
      metrics: metrics,
    );
    _reports[i] = updated;
    return updated;
  }

  @override
  Future<Report> managerResubmitRevision({
    required String reportId,
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  }) async {
    if (!user.isManager) throw StateError('Only managers use this resubmit path');
    final i = _reports.indexWhere((r) => r.id == reportId);
    if (i < 0) throw StateError('Report not found');
    final r = _reports[i];
    if (r.authorId != user.id) throw StateError('Not your report');
    if (r.stage != ReportStage.revisionRequested) throw StateError('Not in revision');
    if (r.authorRole != AppRole.manager) throw StateError('Not a manager-authored report');
    final now = DateTime.now();
    final updated = r.copyWith(
      title: title,
      summary: summary,
      type: type,
      stage: ReportStage.awaitingDirector,
      clearSendBack: true,
      updatedAt: now,
    );
    _reports[i] = updated;
    return updated;
  }

  @override
  Future<Report> directorSubmitUpward(String reportId, SessionUser user) async {
    final i = _reports.indexWhere((r) => r.id == reportId);
    if (i < 0) throw StateError('Report not found');
    if (!user.isDirector) throw StateError('Only directors can submit up');
    final r = _reports[i];
    if (r.stage != ReportStage.awaitingDirector) {
      throw StateError('Invalid stage');
    }
    final updated = r.copyWith(
      stage: ReportStage.awaitingAdministration,
      clearSendBack: true,
      updatedAt: DateTime.now(),
    );
    _reports[i] = updated;
    return updated;
  }

  @override
  Future<Report> createDirectorReport({
    required SessionUser user,
    required String title,
    required String summary,
    required ReportType type,
  }) async {
    if (!user.isDirector) throw StateError('Only directors can create');
    final now = DateTime.now();
    final r = Report(
      id: _uuid.v4(),
      title: title,
      summary: summary,
      type: type,
      directorateId: user.directorateId ?? '',
      directorateName: user.directorateName ?? '',
      unitId: null,
      unitName: null,
      authorId: user.id,
      authorName: user.displayName,
      authorRole: AppRole.director,
      stage: ReportStage.awaitingAdministration,
      createdAt: now,
      updatedAt: now,
    );
    _reports.add(r);
    return r;
  }
}
