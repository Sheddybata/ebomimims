import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report_stage.dart';
import '../models/report_type.dart';
import '../providers/reports_list_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No submissions yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = items[i];
              final note = r.sendBackNote;
              return Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text(
                    '${r.stage.label} · ${r.type.label}\n${r.summary}'
                    '${note != null && note.isNotEmpty ? '\n\nLast return-for-revision note (full text):\n$note' : ''}',
                    maxLines: note != null ? 8 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
