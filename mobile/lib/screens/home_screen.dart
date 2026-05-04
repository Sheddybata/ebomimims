import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_role.dart';
import '../models/session_user.dart';
import '../providers/auth_provider.dart';
import '../providers/reporting_framework_provider.dart';
import '../providers/responsibilities_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/session_user_hero_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final respView = ref.watch(responsibilityViewProvider);
    final metricsView = ref.watch(reportingMetricsViewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SessionUserHeroCard(
            user: user,
            showAvatar: false,
            footer: user == null
                ? null
                : Text(
                    _roleSubtitle(user.role),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                  ),
          ),
          if (user == null) ...[
            const SizedBox(height: 8),
            Text(
              'Loading your workspace…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            ..._homeLoadingPlaceholders(context),
          ] else ...[
            const SizedBox(height: 8),
            ..._responsibilitiesSection(context, user, respView),
            ..._reportingMetricsSection(context, metricsView),
            const SizedBox(height: 16),
            _analyticsHint(context),
          ],
        ],
      ),
    );
  }

  List<Widget> _homeLoadingPlaceholders(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget bar(double w) => Container(
          width: w,
          height: 12,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
        );
    return [
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(180),
              const SizedBox(height: 12),
              bar(double.infinity),
              const SizedBox(height: 8),
              bar(double.infinity),
              const SizedBox(height: 8),
              bar(220),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(140),
              const SizedBox(height: 12),
              bar(double.infinity),
              const SizedBox(height: 8),
              bar(double.infinity),
            ],
          ),
        ),
      ),
    ];
  }

  String _roleSubtitle(AppRole role) => switch (role) {
        AppRole.unitHead =>
          'This screen is your charter reference. Use Inbox and Submit in the bottom bar for workflow.',
        AppRole.manager =>
          'Charter and responsibilities below. Inbox, Submit, and History are on the bottom bar.',
        AppRole.director =>
          'Charter and responsibilities below. Inbox and Submit are on the bottom bar.',
        AppRole.stateCoordinator =>
          'State coordination dashboard. Submit your reports directly to the National Director.',
      };

  List<Widget> _responsibilitiesSection(
    BuildContext context,
    SessionUser? user,
    ResponsibilityView? respView,
  ) {
    if (user == null) return [];
    if (respView != null) {
      return [
        Card(
          child: ExpansionTile(
            leading: Icon(Icons.menu_book_outlined, color: AppTheme.brandRed),
            title: const Text('Spiritual & governance foundation'),
            subtitle: const Text('Key Bible verses for this directorate'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: respView.spiritualFoundation
                      .map<Widget>(
                        (v) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            v,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.45,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: Icon(Icons.assignment_outlined, color: AppTheme.brandRed),
            title: Text('Your responsibilities · ${respView.roleTitle}'),
            subtitle: respView.unitLabel != null
                ? Text(respView.unitLabel!)
                : const Text('Charter aligned to your role'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: respView.items
                      .map<Widget>(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  color: AppTheme.brandRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  line,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        height: 1.45,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.link_off_outlined, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Charter not linked',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Responsibilities for this directorate will appear here once the charter is linked to your account.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _reportingMetricsSection(
    BuildContext context,
    ReportingMetricsView? metricsView,
  ) {
    if (metricsView == null) return [];
    return [
      const SizedBox(height: 8),
      Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.25)),
        ),
        child: ExpansionTile(
          collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          leading: CircleAvatar(
            backgroundColor: AppTheme.brandRed.withValues(alpha: 0.12),
            child: Icon(Icons.analytics_outlined, color: AppTheme.brandRed, size: 22),
          ),
          title: const Text('Reporting & metrics framework'),
          subtitle: Text(metricsView.roleTitle),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  metricsView.unitLabel != null ? 'Unit: ${metricsView.unitLabel}' : 'Checklist for your role',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: metricsView.bullets
                    .map<Widget>(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                color: AppTheme.brandRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                line,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      height: 1.45,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            if (metricsView.footerNote != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  metricsView.footerNote!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.45,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  Widget _analyticsHint(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, size: 20, color: AppTheme.brandRedDark),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tip: Inbox and Submit are on the bottom bar. '
                'Analytics and executive dashboards stay on the web portal.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
