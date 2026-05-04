import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/report_validation.dart';
import '../models/app_role.dart';
import '../models/report.dart';
import '../models/report_stage.dart';
import '../models/report_type.dart';
import '../models/session_user.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_list_provider.dart';
import '../theme/app_theme.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final inboxAsync = ref.watch(inboxProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: inboxAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (user == null) {
            return const Center(child: Text('Not signed in'));
          }
          if (items.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.brandRed.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.inbox_outlined,
                        size: 30,
                        color: AppTheme.brandRed,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.isUnitHead ? 'All clear' : 'Nothing pending',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.isUnitHead
                          ? 'When your manager or director returns a report for revision, it will show up here with their full note.'
                          : 'New items will appear when something needs your attention.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = items[i];
              if (user.isUnitHead) {
                return _UnitHeadInboxCard(report: r);
              }
              if (user.isManager &&
                  r.stage == ReportStage.revisionRequested &&
                  r.authorRole == AppRole.manager &&
                  r.authorId == user.id) {
                return _ManagerRevisionInboxCard(report: r);
              }
              return _ManagerDirectorTile(report: r, user: user);
            },
          );
        },
      ),
    );
  }
}

class _UnitHeadInboxCard extends StatelessWidget {
  const _UnitHeadInboxCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final note = report.sendBackNote ?? '';

    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.brandRed.withValues(alpha: 0.12),
                  child: Icon(Icons.edit_note_rounded, color: AppTheme.brandRed, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _inboxMetaChip(
                  context,
                  '${report.type.label} · ${ReportStage.revisionRequested.label}',
                ),
                if (report.unitName != null) _inboxMetaChip(context, report.unitName!),
                if (report.metrics != null && report.metrics!.isNotEmpty)
                  _inboxMetricsBadge(context, report.metrics!.length),
              ],
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Return-for-revision note (full text)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                note,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              if (report.sendBackByName != null) ...[
                const SizedBox(height: 8),
                Text(
                  '— ${report.sendBackByName}'
                  '${report.sendBackByRole != null ? ' (${report.sendBackByRole!.label})' : ''}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/inbox/resubmit/${report.id}'),
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text('Update report'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerRevisionInboxCard extends StatelessWidget {
  const _ManagerRevisionInboxCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final note = report.sendBackNote ?? '';

    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.brandRed.withValues(alpha: 0.12),
                  child: Icon(Icons.reply_rounded, color: AppTheme.brandRed, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _inboxMetaChip(context, '${report.type.label} · Director revision'),
                if (report.metrics != null && report.metrics!.isNotEmpty)
                  _inboxMetricsBadge(context, report.metrics!.length),
              ],
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Return-for-revision note (full text)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                note,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/inbox/resubmit/${report.id}'),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Update and resubmit'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagerDirectorTile extends StatelessWidget {
  const _ManagerDirectorTile({required this.report, required this.user});

  final Report report;
  final SessionUser user;

  String get _ctaLabel {
    if (user.isManager) return 'Open full review';
    if (user.isDirector) return 'Open full review';
    return 'Open';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: () {
          if (user.role == AppRole.manager || user.role == AppRole.director) {
            context.push('/inbox/review/${report.id}');
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                report.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _inboxMetaChip(
                    context,
                    '${report.type.label} · ${report.stage.label}',
                  ),
                  if (report.unitName != null) _inboxMetaChip(context, report.unitName!),
                  if (report.metrics != null && report.metrics!.isNotEmpty)
                    _inboxMetricsBadge(context, report.metrics!.length),
                ],
              ),
              if (user.role == AppRole.manager || user.role == AppRole.director) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push('/inbox/review/${report.id}'),
                    icon: const Icon(Icons.open_in_new_rounded, size: 20),
                    label: Text(_ctaLabel),
                    style: FilledButton.styleFrom(
                      foregroundColor: AppTheme.brandRedDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Approve to move forward, or Return for revision with at least '
                    '$kMinSendBackNoteLength characters. The author sees your full note.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget _inboxMetaChip(BuildContext context, String text) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

Widget _inboxMetricsBadge(BuildContext context, int count) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppTheme.brandRed.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppTheme.brandRed.withValues(alpha: 0.28),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.analytics_outlined, size: 14, color: AppTheme.brandRed),
        const SizedBox(width: 6),
        Text(
          '$count metrics',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.brandRedDark,
          ),
        ),
      ],
    ),
  );
}
