import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_report_repository.dart';
import '../data/report_repository.dart';
import '../data/supabase_hybrid_report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return SupabaseHybridReportRepository(MockReportRepository());
});
