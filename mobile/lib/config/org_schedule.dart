/// Fixed org-wide notification times in [timezoneName] (WAT, no DST).
abstract final class OrgSchedule {
  static const String timezoneName = 'Africa/Lagos';

  static const int devotionHour = 7;
  static const int devotionMinute = 30;

  static const int lunchHour = 12;
  static const int lunchMinute = 0;

  static const int reportReminderHour = 15;
  static const int reportReminderMinute = 0;
}
