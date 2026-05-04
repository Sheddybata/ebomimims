import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_preferences_provider.dart';
import '../providers/reports_list_provider.dart';
import '../services/local_notification_service.dart';

/// Shows a local notification when inbox count increases (mock repo / future sync).
class InboxNotificationBridge extends ConsumerStatefulWidget {
  const InboxNotificationBridge({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InboxNotificationBridge> createState() =>
      _InboxNotificationBridgeState();
}

class _InboxNotificationBridgeState extends ConsumerState<InboxNotificationBridge> {
  @override
  Widget build(BuildContext context) {
    ref.listen(inboxProvider, (prev, next) {
      if (!ref.read(notificationsEnabledProvider)) return;
      final prevLen = prev?.asData?.value.length ?? -1;
      final nextLen = next.asData?.value.length ?? -1;
      if (prevLen >= 0 && nextLen > prevLen) {
        LocalNotificationService.showInboxPing();
      }
    });
    return widget.child;
  }
}
