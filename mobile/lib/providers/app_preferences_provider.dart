import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bootstrap/app_bootstrap.dart';
import '../persistence/preference_keys.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Overridden in main()');
});

class OnboardingPrefs extends Notifier<bool> {
  @override
  bool build() => AppBootstrap.onboardingDone;

  Future<void> complete() async {
    final p = ref.read(sharedPreferencesProvider);
    await p.setBool(PreferenceKeys.onboardingDone, true);
    AppBootstrap.setOnboardingDoneMemory();
    state = true;
  }
}

final onboardingProvider = NotifierProvider<OnboardingPrefs, bool>(
  OnboardingPrefs.new,
);

class NotificationsPrefs extends Notifier<bool> {
  @override
  bool build() {
    final p = ref.watch(sharedPreferencesProvider);
    return p.getBool(PreferenceKeys.notificationsEnabled) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final p = ref.read(sharedPreferencesProvider);
    await p.setBool(PreferenceKeys.notificationsEnabled, value);
    state = value;
  }
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsPrefs, bool>(NotificationsPrefs.new);
