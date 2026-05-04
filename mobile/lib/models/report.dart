import 'app_role.dart';
import 'report_stage.dart';
import 'report_type.dart';

class Report {
  const Report({
    required this.id,
    required this.title,
    required this.summary,
    required this.type,
    required this.directorateId,
    required this.directorateName,
    this.unitId,
    this.unitName,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.stage,
    required this.createdAt,
    required this.updatedAt,
    this.sendBackNote,
    this.sendBackByName,
    this.sendBackByRole,
    this.sendBackAt,
    this.metrics,
  });

  final String id;
  final String title;
  final String summary;
  final ReportType type;
  final String directorateId;
  final String directorateName;
  final String? unitId;
  final String? unitName;
  final String authorId;
  final String authorName;
  final AppRole authorRole;
  final ReportStage stage;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Filled when a manager or director sends the report back for revision.
  final String? sendBackNote;
  final String? sendBackByName;
  final AppRole? sendBackByRole;
  final DateTime? sendBackAt;

  /// Structured unit-head metric ids → values (for web / dashboards).
  final Map<String, String>? metrics;

  Report copyWith({
    String? title,
    String? summary,
    ReportType? type,
    ReportStage? stage,
    DateTime? updatedAt,
    String? sendBackNote,
    String? sendBackByName,
    AppRole? sendBackByRole,
    DateTime? sendBackAt,
    bool clearSendBack = false,
    Map<String, String>? metrics,
    bool clearMetrics = false,
  }) {
    return Report(
      id: id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      type: type ?? this.type,
      directorateId: directorateId,
      directorateName: directorateName,
      unitId: unitId,
      unitName: unitName,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      stage: stage ?? this.stage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sendBackNote: clearSendBack ? null : (sendBackNote ?? this.sendBackNote),
      sendBackByName: clearSendBack ? null : (sendBackByName ?? this.sendBackByName),
      sendBackByRole: clearSendBack ? null : (sendBackByRole ?? this.sendBackByRole),
      sendBackAt: clearSendBack ? null : (sendBackAt ?? this.sendBackAt),
      metrics: clearMetrics ? null : (metrics ?? this.metrics),
    );
  }
}
