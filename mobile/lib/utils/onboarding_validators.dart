abstract final class OnboardingValidators {
  static String? nameError(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return 'Enter your full name.';
    if (s.length < 2) return 'Name looks too short.';
    return null;
  }

  static String? phoneError(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number (at least 10 digits).';
    return null;
  }

  static String? emailError(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return 'Enter your email address.';
    final at = s.indexOf('@');
    if (at <= 0) return 'Enter a valid email address.';
    final domain = s.substring(at + 1);
    if (!domain.contains('.')) return 'Enter a valid email address.';
    return null;
  }
}
