import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/reporting_framework_resolve.dart';
import '../data/reporting_metrics_compose.dart';
import '../data/seed_units.dart';
import '../models/reporting_metric_field.dart';
import '../models/report_type.dart';
import '../models/unit.dart';
import '../models/session_user.dart';
import '../providers/auth_provider.dart';
import '../providers/report_repository_provider.dart';
import '../providers/reporting_framework_provider.dart';
import '../providers/reports_list_provider.dart';
import '../theme/app_theme.dart';

class SubmitReportScreen extends ConsumerStatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  final _title = TextEditingController();
  final _summary = TextEditingController();
  ReportType? _type;
  bool _saving = false;

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

  void _ensureMetricControllers(List<ReportingMetricField> fields) {
    final sig = fields.map((f) => f.id).join('|');
    if (_metricSig == sig) return;
    for (final c in _metricCtrls.values) {
      c.dispose();
    }
    _metricCtrls = {for (final f in fields) f.id: TextEditingController()};
    _metricSig = sig;
  }

  String _flowBlurb(SessionUser user) {
    if (user.isUnitHead) {
      return 'Your report is filed under your assigned unit and goes to your manager first. '
          'No unit selection needed.';
    }
    if (user.isManager) {
      return 'Manager reports go to the director of your directorate. They can forward them '
          'to the National Director of Administration (web portal).';
    }
    if (user.isDirector) {
      return 'Director reports go straight to the National Director of Administration and '
          'the executive chain on the web portal.';
    }
    return '';
  }

  String _screenTitle(SessionUser user) {
    if (user.isUnitHead) return 'Submit unit report';
    if (user.isManager) return 'Submit manager report';
    if (user.isDirector) return 'Submit directorate report';
    return 'Submit report';
  }

  TextInputType _keyboardFor(ReportingMetricInput k) => switch (k) {
    ReportingMetricInput.wholeNumber => TextInputType.number,
    ReportingMetricInput.decimal => const TextInputType.numberWithOptions(
      decimal: true,
    ),
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
    final metricsView = ref.watch(reportingMetricsViewProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final units = user.directorateId != null ? unitsForDirectorate(user.directorateId!) : <Unit>[];
    final primaryId = user.primaryUnitId;
    Unit? assignedUnit;
    if (primaryId != null) {
      try {
        assignedUnit = units.firstWhere((u) => u.id == primaryId);
      } catch (_) {
        assignedUnit = null;
      }
    }

    List<ReportingMetricField> unitHeadFields = const [];
    if (user.isUnitHead && primaryId != null) {
      final fw = resolvedFrameworkForDirectorate(user.directorateId);
      unitHeadFields = fw.resolvedFieldsForUnit(primaryId);
      _ensureMetricControllers(unitHeadFields);
    }

    final hasStructuredUnitHead = user.isUnitHead && unitHeadFields.isNotEmpty;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_screenTitle(user))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.35),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.brandRed,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _flowBlurb(user),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        if (metricsView != null && !hasStructuredUnitHead) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Tip: On Home, open Reporting & metrics framework for your checklist.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (user.isUnitHead && assignedUnit != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.brandRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.brandRed.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: AppTheme.brandRed,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      assignedUnit.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    'Your unit',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.brandRedDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasStructuredUnitHead) ...[
            const SizedBox(height: 20),
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
                                'Typed fields sync to the web dashboard. Everything you enter is included in your report.',
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
                          minLines: f.input == ReportingMetricInput.multiline
                              ? 2
                              : 1,
                          maxLines: f.input == ReportingMetricInput.multiline
                              ? 5
                              : 1,
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
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
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
          ],
          const SizedBox(height: 20),
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
            decoration: const InputDecoration(labelText: 'Report title'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summary,
            decoration: InputDecoration(
              labelText: hasStructuredUnitHead
                  ? 'Additional notes (optional)'
                  : 'Summary / details',
              alignLabelWithHint: true,
            ),
            minLines: hasStructuredUnitHead ? 2 : 4,
            maxLines: 10,
          ),
          const SizedBox(height: 12),
          _ReportTypePicker(
            value: _type,
            onChanged: (v) => setState(() => _type = v),
          ),
          if (user.isUnitHead && units.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This directorate has no units defined. Contact administration.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving
                  ? null
                  : () => _submit(
                      context,
                      user,
                      units,
                      assignedUnit,
                      unitHeadFields,
                    ),
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
                  _saving ? 'Submitting…' : 'Submit report',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    SessionUser user,
    List<Unit> units,
    Unit? assignedUnit,
    List<ReportingMetricField> unitHeadFields,
  ) async {
    if (_saving) return;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
        return;
      }
      final block = formatMetricsForSummary(metricsMap, unitHeadFields);
      if (block.isEmpty && notes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add metric values and/or additional notes'),
          ),
        );
        return;
      }
      summary = [
        if (block.isNotEmpty) block,
        if (notes.isNotEmpty) notes,
      ].join('\n\n');
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a report title')),
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
      final selectedType = _type;
      if (selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select report type')),
        );
        return;
      }
      if (user.isDirector) {
        await repo.createDirectorReport(
          user: user,
          title: title,
          summary: summary,
          type: selectedType,
        );
      } else if (user.isUnitHead) {
        if (units.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No units are defined for this directorate.'),
              ),
            );
          }
          return;
        }
        final uid = user.primaryUnitId;
        if (uid == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No primary unit on your profile. Re-sign in after picking a unit.',
                ),
              ),
            );
          }
          return;
        }
        Unit? unit;
        for (final u in units) {
          if (u.id == uid) {
            unit = u;
            break;
          }
        }
        if (unit == null) {
          throw StateError('Unit not found');
        }
        await repo.createUnitHeadReport(
          user: user,
          title: title,
          summary: summary,
          type: selectedType,
          unitId: unit.id,
          unitName: unit.name,
          metrics: metricsMap,
        );
      } else if (user.isManager) {
        await repo.createManagerReport(
          user: user,
          title: title,
          summary: summary,
          type: selectedType,
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Report submitted')));
        _title.clear();
        _summary.clear();
        for (final c in _metricCtrls.values) {
          c.clear();
        }
      }
      invalidateReportCaches(ref);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  final ReportType? value;
  final ValueChanged<ReportType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = value != null;
    return DropdownButtonFormField<ReportType>(
      initialValue: value,
      isExpanded: true,
      hint: const Text('Select report type'),
      iconEnabledColor: hasSelection ? Colors.white : theme.colorScheme.onSurfaceVariant,
      dropdownColor: theme.colorScheme.surface,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: hasSelection ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: hasSelection ? AppTheme.brandRed : theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: hasSelection
              ? BorderSide.none
              : BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.45),
                ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: hasSelection ? AppTheme.brandRedDark : AppTheme.brandRed,
            width: 1.5,
          ),
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
