import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/reporting_framework_resolve.dart';
import '../data/reporting_metrics_compose.dart';
import '../models/app_role.dart';
import '../models/report.dart';
import '../models/report_stage.dart';
import '../models/report_type.dart';
import '../models/reporting_metric_field.dart';
import '../models/session_user.dart';
import '../providers/auth_provider.dart';
import '../providers/report_detail_provider.dart';
import '../providers/report_repository_provider.dart';
import '../providers/reports_list_provider.dart';
import '../theme/app_theme.dart';

class ReportResubmitScreen extends ConsumerStatefulWidget {
  const ReportResubmitScreen({super.key, required this.reportId});

  final String reportId;

  @override
  ConsumerState<ReportResubmitScreen> createState() => _ReportResubmitScreenState();
}

class _ReportResubmitScreenState extends ConsumerState<ReportResubmitScreen> {
  final _title = TextEditingController();
  final _summary = TextEditingController();
  ReportType _type = ReportType.narrative;
  bool _saving = false;
  String? _filledForReportId;

  Map<String, TextEditingController> _metricCtrls = {};
  String? _metricSig;

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    for (final c in _metricCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureMetricControllers(List<ReportingMetricField> fields, Report report) {
    final sig = '${report.id}|${fields.map((f) => f.id).join('|')}';
    if (_metricSig == sig) return;
    for (final c in _metricCtrls.values) {
      c.dispose();
    }
    _metricCtrls = {
      for (final f in fields)
        f.id: TextEditingController(
          text: report.metrics?[f.id] ?? '',
        ),
    };
    _metricSig = sig;
  }

  TextInputType _keyboardFor(ReportingMetricInput k) => switch (k) {
        ReportingMetricInput.wholeNumber => TextInputType.number,
        ReportingMetricInput.decimal => const TextInputType.numberWithOptions(decimal: true),
        ReportingMetricInput.singleLine => TextInputType.text,
        ReportingMetricInput.multiline => TextInputType.multiline,
      };

  List<TextInputFormatter> _formattersFor(ReportingMetricInput k) {
    if (k == ReportingMetricInput.wholeNumber) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return const [];
  }

  String? _metricHelper(ReportingMetricInput k) => switch (k) {
        ReportingMetricInput.wholeNumber => 'Whole number only',
        ReportingMetricInput.decimal => 'Numbers allowed (e.g. 12.5)',
        ReportingMetricInput.singleLine => null,
        ReportingMetricInput.multiline => null,
      };

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final asyncReport = ref.watch(reportByIdProvider(widget.reportId));

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Update and resubmit')),
      body: asyncReport.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (report) {
          if (report == null) {
            return const Center(child: Text('Report not found'));
          }
          if (report.stage != ReportStage.revisionRequested) {
            return const Center(child: Text('This report is not awaiting your revision.'));
          }
          if (report.authorId != user.id) {
            return const Center(child: Text('This is not your report to edit.'));
          }

          if (_filledForReportId != report.id) {
            _filledForReportId = report.id;
            _title.text = report.title;
            _type = report.type;
            if (user.isUnitHead &&
                report.unitId != null &&
                resolvedFrameworkForDirectorate(report.directorateId)
                        .resolvedFieldsForUnit(report.unitId!)
                    .isNotEmpty) {
              final fw = resolvedFrameworkForDirectorate(report.directorateId);
              final fields = fw.resolvedFieldsForUnit(report.unitId!);
              _ensureMetricControllers(fields, report);
              _summary.text = extractNotesAfterStructuredBlock(report.summary);
            } else {
              _summary.text = report.summary;
              for (final c in _metricCtrls.values) {
                c.dispose();
              }
              _metricCtrls = {};
              _metricSig = null;
            }
          } else if (user.isUnitHead && report.unitId != null) {
            final fields =
                resolvedFrameworkForDirectorate(report.directorateId).resolvedFieldsForUnit(report.unitId!);
            if (fields.isNotEmpty) {
              _ensureMetricControllers(fields, report);
            }
          }

          final unitHeadFields = user.isUnitHead && report.unitId != null
              ? resolvedFrameworkForDirectorate(report.directorateId).resolvedFieldsForUnit(report.unitId!)
              : const <ReportingMetricField>[];
          final hasStructured = user.isUnitHead && unitHeadFields.isNotEmpty;

          final theme = Theme.of(context);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            children: [
              if (report.sendBackNote != null) ...[
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppTheme.brandRed.withValues(alpha: 0.35),
                    ),
                  ),
                  color: AppTheme.brandRed.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.mark_unread_chat_alt_outlined,
                              color: AppTheme.brandRed,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Feedback you received',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          report.sendBackNote!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.45,
                          ),
                        ),
                        if (report.sendBackByName != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '— ${report.sendBackByName}'
                            '${report.sendBackByRole != null ? ' (${report.sendBackByRole!.label})' : ''}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (hasStructured) ...[
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.brandRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.analytics_outlined,
                                color: AppTheme.brandRed,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weekly metrics',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Update the numbers your reviewer will see on the web dashboard.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ...unitHeadFields.map((f) {
                          final c = _metricCtrls[f.id];
                          if (c == null) return const SizedBox.shrink();
                          final helper = _metricHelper(f.input);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextField(
                              controller: c,
                              keyboardType: _keyboardFor(f.input),
                              inputFormatters: _formattersFor(f.input),
                              minLines: f.input == ReportingMetricInput.multiline ? 2 : 1,
                              maxLines: f.input == ReportingMetricInput.multiline ? 5 : 1,
                              decoration: InputDecoration(
                                labelText: f.label,
                                alignLabelWithHint:
                                    f.input == ReportingMetricInput.multiline,
                                helperText: helper,
                                helperMaxLines: 2,
                                suffixIcon: f.isRequired
                                    ? null
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          'Opt.',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.outline,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                'Report details',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Report title',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _summary,
                decoration: InputDecoration(
                  labelText:
                      hasStructured ? 'Additional notes (optional)' : 'Summary / details',
                  alignLabelWithHint: true,
                ),
                minLines: hasStructured ? 2 : 4,
                maxLines: 12,
              ),
              const SizedBox(height: 12),
              _ReportTypePicker(
                value: _type,
                onChanged: (v) => setState(() => _type = v),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _saving ? null : () => _save(context, user, report, unitHeadFields),
                  icon: _saving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _saving ? 'Saving…' : 'Resubmit report',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    SessionUser user,
    Report report,
    List<ReportingMetricField> unitHeadFields,
  ) async {
    final title = _title.text.trim();
    final notes = _summary.text.trim();

    Map<String, String>? metricsMap;
    String summary;

    if (user.isUnitHead && unitHeadFields.isNotEmpty) {
      metricsMap = {
        for (final f in unitHeadFields) f.id: _metricCtrls[f.id]?.text ?? '',
      };
      final err = validateMetricValues(metricsMap, unitHeadFields);
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        return;
      }
      final block = formatMetricsForSummary(metricsMap, unitHeadFields);
      if (block.isEmpty && notes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add metric values and/or additional notes')),
        );
        return;
      }
      summary = [
        if (block.isNotEmpty) block,
        if (notes.isNotEmpty) notes,
      ].join('\n\n');
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a title')),
        );
        return;
      }
    } else {
      if (title.isEmpty || notes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter title and summary')),
        );
        return;
      }
      summary = notes;
      metricsMap = null;
    }

    setState(() => _saving = true);
    final repo = ref.read(reportRepositoryProvider);
    try {
      if (user.isUnitHead) {
        await repo.unitHeadResubmitRevision(
          reportId: report.id,
          user: user,
          title: title,
          summary: summary,
          type: _type,
          metrics: metricsMap,
        );
      } else if (user.isManager) {
        await repo.managerResubmitRevision(
          reportId: report.id,
          user: user,
          title: title,
          summary: summary,
          type: _type,
        );
      } else {
        throw StateError('Only unit heads and managers resubmit from this screen');
      }
      invalidateReportCaches(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resubmitted')),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ReportTypePicker extends StatelessWidget {
  const _ReportTypePicker({
    required this.value,
    required this.onChanged,
  });

  final ReportType value;
  final ValueChanged<ReportType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<ReportType>(
      initialValue: value,
      isExpanded: true,
      hint: const Text('Select report type'),
      iconEnabledColor: Colors.white,
      dropdownColor: theme.colorScheme.surface,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.brandRed,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.brandRedDark, width: 1.5),
        ),
      ),
      selectedItemBuilder: (context) => ReportType.values
          .map(
            (type) => Text(
              type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          )
          .toList(),
      items: ReportType.values
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(
                type.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
