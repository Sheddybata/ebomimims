import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report.dart';
import 'auth_provider.dart';
import 'report_repository_provider.dart';

final inboxProvider = FutureProvider<List<Report>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  final repo = ref.watch(reportRepositoryProvider);
  return repo.inboxFor(user);
});

final historyProvider = FutureProvider<List<Report>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  final repo = ref.watch(reportRepositoryProvider);
  return repo.historyFor(user);
});

void invalidateReportCaches(WidgetRef ref) {
  ref.invalidate(inboxProvider);
  ref.invalidate(historyProvider);
}
