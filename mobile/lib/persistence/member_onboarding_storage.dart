import 'package:shared_preferences/shared_preferences.dart';

import 'preference_keys.dart';

class MemberOnboardingProfile {
  const MemberOnboardingProfile({
    required this.displayName,
    required this.phone,
    required this.email,
  });

  final String displayName;
  final String phone;
  final String email;
}

abstract final class MemberOnboardingStorage {
  static Future<void> save(MemberOnboardingProfile p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PreferenceKeys.memberDisplayName, p.displayName);
    await prefs.setString(PreferenceKeys.memberPhone, p.phone);
    await prefs.setString(PreferenceKeys.memberEmail, p.email);
  }

  static Future<MemberOnboardingProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(PreferenceKeys.memberDisplayName);
    final phone = prefs.getString(PreferenceKeys.memberPhone);
    final email = prefs.getString(PreferenceKeys.memberEmail);
    if (name == null || name.isEmpty) return null;
    return MemberOnboardingProfile(
      displayName: name,
      phone: phone ?? '',
      email: email ?? '',
    );
  }
}
