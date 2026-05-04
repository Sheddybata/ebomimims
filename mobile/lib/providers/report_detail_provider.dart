import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report.dart';
import 'report_repository_provider.dart';

final reportByIdProvider =
    FutureProvider.autoDispose.family<Report?, String>((ref, id) {
  return ref.watch(reportRepositoryProvider).getReportById(id);
});
