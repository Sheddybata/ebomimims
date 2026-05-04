import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'bootstrap/app_bootstrap.dart';
import 'config/supabase_config.dart';
import 'firebase_background.dart';
import 'firebase_options.dart';
import 'persistence/preference_keys.dart';
import 'providers/app_preferences_provider.dart';
import 'services/local_notification_service.dart';
import 'services/push_messaging_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
  await AppBootstrap.load();

  await LocalNotificationService.init();
  if (prefs.getBool(PreferenceKeys.notificationsEnabled) ?? false) {
    await LocalNotificationService.scheduleOrgWeekdayReminders();
  }

  if (DefaultFirebaseOptions.isConfigured) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  await PushMessagingService.initIfConfigured();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const ImsMobileApp(),
    ),
  );
}
