import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_user.dart';
import 'preference_keys.dart';

abstract final class SessionStorage {
  static Future<SessionUser?> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(PreferenceKeys.sessionUserJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      return SessionUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(SessionUser user) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      PreferenceKeys.sessionUserJson,
      jsonEncode(user.toJson()),
    );
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(PreferenceKeys.sessionUserJson);
  }
}
