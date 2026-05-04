import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';
import 'local_notification_service.dart';

abstract final class PushMessagingService {
  static bool _handlersAttached = false;

  static Future<void> initIfConfigured() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint(
        'FCM skipped: replace placeholders in lib/firebase_options.dart (run flutterfire configure).',
      );
      return;
    }
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e, st) {
      debugPrint('Firebase init failed: $e\n$st');
      return;
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    try {
      final token = await messaging.getToken();
      debugPrint('FCM token (register on your server): $token');
    } catch (e) {
      debugPrint('FCM getToken failed: $e');
    }

    if (!_handlersAttached) {
      _handlersAttached = true;
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final n = message.notification;
        final title = n?.title ?? 'EBOMIM';
        final body = n?.body ?? 'You have an update.';
        await LocalNotificationService.showPushBanner(title: title, body: body);
      });
    }
  }
}
