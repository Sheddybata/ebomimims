import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../config/org_schedule.dart';

final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

bool _timeZonesLoaded = false;

/// Mon–Fri org reminders in Africa/Lagos + channels for FCM foreground.
abstract final class LocalNotificationService {
  static const String channelIdDefault = 'ims_default';
  static const String channelIdInbox = 'ims_inbox';
  static const String channelName = 'EBOMIM';

  static Future<void> init() async {
    if (!_timeZonesLoaded) {
      tz_data.initializeTimeZones();
      _timeZonesLoaded = true;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );
    await _plugin.initialize(initSettings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      channelIdDefault,
      channelName,
      description: 'Devotion, lunch, and report reminders (org time).',
      importance: Importance.defaultImportance,
    ));
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      channelIdInbox,
      'Inbox & approvals',
      description: 'New requests and approval notices.',
      importance: Importance.high,
    ));
  }

  static Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final grantedAndroid =
        await android?.requestNotificationsPermission() ?? true;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final grantedIos = await ios?.requestPermissions(alert: true, badge: true, sound: true);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return grantedIos ?? false;
    }
    return grantedAndroid;
  }

  /// Schedules Mon–Fri 7:30 / 12:00 / 15:00 in [OrgSchedule.timezoneName].
  static Future<void> scheduleOrgWeekdayReminders() async {
    await cancelOrgWeekdayReminders();
    final location = tz.getLocation(OrgSchedule.timezoneName);

    const weekdays = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
    ];

    for (final wd in weekdays) {
      await _scheduleWeekly(
        id: _id(1, wd),
        title: 'Morning devotion',
        body: 'Time for devotion (org time · WAT).',
        weekday: wd,
        hour: OrgSchedule.devotionHour,
        minute: OrgSchedule.devotionMinute,
        location: location,
      );
      await _scheduleWeekly(
        id: _id(2, wd),
        title: 'Lunch break',
        body: 'Lunch hour (org time · WAT).',
        weekday: wd,
        hour: OrgSchedule.lunchHour,
        minute: OrgSchedule.lunchMinute,
        location: location,
      );
      await _scheduleWeekly(
        id: _id(3, wd),
        title: 'Report reminder',
        body: 'Reminder to submit your report (org time · WAT).',
        weekday: wd,
        hour: OrgSchedule.reportReminderHour,
        minute: OrgSchedule.reportReminderMinute,
        location: location,
      );
    }
  }

  static int _id(int kind, int weekday) => kind * 10 + weekday;

  static Future<void> _scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
    required tz.Location location,
  }) async {
    final scheduled = _nextInstanceOfWeekday(
      location: location,
      weekday: weekday,
      hour: hour,
      minute: minute,
    );

    const android = AndroidNotificationDetails(
      channelIdDefault,
      channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  static tz.TZDateTime _nextInstanceOfWeekday({
    required tz.Location location,
    required int weekday,
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> cancelOrgWeekdayReminders() async {
    for (var kind = 1; kind <= 3; kind++) {
      for (var wd = DateTime.monday; wd <= DateTime.friday; wd++) {
        await _plugin.cancel(_id(kind, wd));
      }
    }
  }

  /// Foreground FCM or similar — inbox channel.
  static Future<void> showPushBanner({required String title, required String body}) async {
    const android = AndroidNotificationDetails(
      channelIdInbox,
      'Inbox & approvals',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());
    final id = 92000 + (DateTime.now().millisecondsSinceEpoch % 1000);
    await _plugin.show(id, title, body, details);
  }

  /// In-app / foreground notice when inbox gains items (no PII in body).
  static Future<void> showInboxPing() async {
    const android = AndroidNotificationDetails(
      channelIdInbox,
      'Inbox & approvals',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());
    await _plugin.show(
      91001,
      'EBOMIM',
      'You have new items in your inbox.',
      details,
    );
  }
}
