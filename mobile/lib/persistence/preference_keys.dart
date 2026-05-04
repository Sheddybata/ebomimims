abstract final class PreferenceKeys {
  static const onboardingDone = 'onboarding_done';
  /// Master switch: inbox FCM + org-time devotion, lunch, report reminders (single bundle).
  static const notificationsEnabled = 'notifications_enabled';
  static const sessionUserJson = 'session_user_json';

  /// Collected during onboarding; used for display name until server auth exists.
  static const memberDisplayName = 'member_display_name';
  static const memberPhone = 'member_phone';
  static const memberEmail = 'member_email';
}
