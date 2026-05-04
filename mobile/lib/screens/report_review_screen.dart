import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/metric_labels.dart';
import '../data/report_validation.dart';
import '../models/app_role.dart';
import '../models/report.dart';
import '../models/report_type.dart';
import '../models/report_stage.dart';
import '../models/session_user.dart';
import '../providers/auth_provider.dart';
import '../providers/report_detail_provider.dart';
import '../providers/report_repository_provider.dart';
import '../providers/reports_list_provider.dart';
import '../theme/app_theme.dart';

class ReportReviewScreen extends ConsumerWidget {
  const ReportReviewScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final asyncReport = ref.watch(reportByIdProvider(reportId));

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Report review')),
      body: asyncReport.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (report) {
          if (report == null) {
            return const Center(child: Text('Report not found'));
          }
          final ok = _canReview(user, report);
          if (!ok) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'You do not have an action on this report in its current stage.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return _ReviewBody(report: report, user: user);
        },
      ),
    );
  }

  bool _canReview(SessionUser user, Report report) {
    if (user.isManager &&
        report.stage == ReportStage.awaitingManager &&
        report.unitId != null &&
        user.unitIds.contains(report.unitId)) {
      return true;
    }
    if (user.isDirector &&
        report.stage == ReportStage.awaitingDirector &&
        report.directorateId == user.directorateId) {
      return true;
    }
    return false;
  }
}

class _ReviewBody extends ConsumerStatefulWidget {
  const _ReviewBody({required this.report, required this.user});

  final Report report;
  final SessionUser user;

  @override
  ConsumerState<_ReviewBody> createState() => _ReviewBodyState();
}

class _ReviewBodyState extends ConsumerState<_ReviewBody> {
  bool _busy = false;

  Future<void> _approve(BuildContext context) async {
    setState(() => _busy = true);
    final repo = ref.read(reportRepositoryProvider);
    try {
      if (widget.user.isManager) {
        await repo.forwardToDirector(widget.report.id, widget.user);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Forwarded to director')),
          );
        }
      } else {
        await repo.directorSubmitUpward(widget.report.id, widget.user);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Sent to National Director of Administration (web portal)',
              ),
            ),
          );
        }
      }
      invalidateReportCaches(ref);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openSendBack(BuildContext context) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final c = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Return for revision',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The author sees this note in full — nothing is truncated. '
                  'Minimum $kMinSendBackNoteLength characters.',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: c,
                  minLines: 4,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Note for the author (shown in full)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.length < kMinSendBackNoteLength) {
                      return 'Enter at least $kMinSendBackNoteLength characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(ctx, c.text.trim());
                    }
                  },
                  child: const Text('Return for revision'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (note == null || !context.mounted) return;

    setState(() => _busy = true);
    final repo = ref.read(reportRepositoryProvider);
    try {
      await repo.sendBackForRevision(
        reportId: widget.report.id,
        reviewer: widget.user,
        note: note,
      );
      invalidateReportCaches(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Returned to author for revision')),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final theme = Theme.of(context);
    final approveLabel = widget.user.isManager
        ? 'Forward to director'
        : 'Send to NDA';
    final approveHelper = widget.user.isManager
        ? 'Approves this report and moves it to the director.'
        : 'Approves this report and moves it to the NDA web queue.';

    final raw = r.metrics;
    final metricEntries = raw == null
        ? <MapEntry<String, String>>[]
        : raw.entries
            .where((e) => e.value.trim().isNotEmpty)
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          r.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _reviewMetaPill(context, r.type.label),
            _reviewMetaPill(context, r.stage.label),
            if (r.unitName != null) _reviewMetaPill(context, r.unitName!),
            _reviewMetaPill(context, r.directorateName),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${r.authorRole.label}: ${r.authorName}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        if (metricEntries.isNotEmpty) ...[
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.35),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
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
                        child: Text(
                          'Structured metrics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...metricEntries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              displayLabelForMetricKey(e.key),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: Text(
                              e.value.trim(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Summary',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              r.summary,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          approveHelper,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _busy ? null : () => _approve(context),
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              approveLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: AppTheme.brandRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _busy ? null : () => _openSendBack(context),
          icon: const Icon(Icons.edit_note_rounded, size: 20),
          label: const Text('Return for revision'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: AppTheme.brandRedDark,
            side: BorderSide(color: AppTheme.brandRed.withValues(alpha: 0.45)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _reviewMetaPill(BuildContext context, String text) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
