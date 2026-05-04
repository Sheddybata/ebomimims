import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_user.dart';
import '../persistence/preference_keys.dart';
import '../persistence/session_storage.dart';

/// Values loaded in [main] before [runApp] so routing and auth start in a consistent state.
abstract final class AppBootstrap {
  static bool onboardingDone = false;
  static SessionUser? preloadedUser;
  static String initialLocation = '/login';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    onboardingDone = prefs.getBool(PreferenceKeys.onboardingDone) ?? false;
    preloadedUser = await SessionStorage.load();

    if (!onboardingDone) {
      initialLocation = '/login';
    } else if (preloadedUser == null) {
      initialLocation = '/login';
    } else {
      initialLocation = '/home';
    }
  }

  static void setOnboardingDoneMemory() {
    onboardingDone = true;
    if (preloadedUser == null) {
      initialLocation = '/login';
    } else {
      initialLocation = '/home';
    }
  }
}
