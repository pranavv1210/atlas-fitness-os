import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AtlasNotificationService {
  AtlasNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      // Keep tz.local as the package default if Android cannot report a zone.
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermission() async {
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final notificationsGranted =
        await android?.requestNotificationsPermission() ?? true;
    if (notificationsGranted) {
      await android?.requestExactAlarmsPermission();
    }
    final exactAllowed = await android?.canScheduleExactNotifications() ?? true;
    debugPrint(
      'Atlas notifications: permission=$notificationsGranted exactAllowed=$exactAllowed',
    );
    return notificationsGranted;
  }

  Future<bool> notificationsEnabled() async {
    final android =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    return await android?.areNotificationsEnabled() ?? true;
  }

  static const _hydrationNotificationBaseId = 1000;
  static const _hydrationNotificationMaxId = 1400;
  static const _dailyNotificationBaseId = 2000;
  static const _dailyNotificationMaxId = 2100;
  static const _workoutNotificationBaseId = 2200;
  static const _workoutNotificationMaxId = 2300;
  static const _hydrationStartHour = 8;
  static const _hydrationEndHour = 22;
  static const _minHydrationIntervalMinutes = 10;
  static const _maxHydrationIntervalMinutes = 360;

  Future<void> scheduleHydrationNudges({required int intervalMinutes}) async {
    await cancelHydrationNudge();
    await _plugin.cancel(991);
    final safeInterval = intervalMinutes.clamp(
      _minHydrationIntervalMinutes,
      _maxHydrationIntervalMinutes,
    );
    var notificationId = _hydrationNotificationBaseId;
    final start = DateTime(2000, 1, 1, _hydrationStartHour);
    final end = DateTime(2000, 1, 1, _hydrationEndHour);
    for (
      var slot = start;
      !slot.isAfter(end);
      slot = slot.add(Duration(minutes: safeInterval))
    ) {
      await _scheduleDailyNotification(
        'Atlas hydration',
        'Time for a calm water check-in.',
        _nextDailyOccurrence(hour: slot.hour, minute: slot.minute),
        id: notificationId++,
        details: _hydrationDetails,
      );
    }
    debugPrint(
      'Atlas notifications: scheduled ${notificationId - _hydrationNotificationBaseId} hydration reminders every $safeInterval minutes.',
    );
    await _scheduleOneShotNotification(
      'Atlas hydration check',
      'This confirms scheduled hydration reminders are working.',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 15)),
      id: 991,
      details: _hydrationDetails,
    );
  }

  Future<void> scheduleDailyReminders() async {
    await cancelDailyReminders();
    await _scheduleDailyNotification(
      'Atlas check-in',
      'Log today once so your trend stays accurate.',
      _nextDailyOccurrence(hour: 9),
      id: _dailyNotificationBaseId,
      details: _generalDetails,
    );
  }

  Future<void> scheduleWorkoutReminders() async {
    await cancelWorkoutReminders();
    await _scheduleDailyNotification(
      'Atlas workout',
      'Your training slot is ready when you are.',
      _nextDailyOccurrence(hour: 18),
      id: _workoutNotificationBaseId,
      details: _generalDetails,
    );
  }

  Future<void> scheduleAtlasReminders({
    required int hydrationIntervalMinutes,
  }) async {
    await scheduleHydrationNudges(intervalMinutes: hydrationIntervalMinutes);
    await scheduleDailyReminders();
    await scheduleWorkoutReminders();
    await scheduleMissedWorkoutCheck();
  }

  Future<void> cancelAtlasReminders() async {
    await cancelHydrationNudge();
    await cancelDailyReminders();
    await cancelWorkoutReminders();
  }

  Future<void> cancelHydrationNudge() async {
    await _cancelRange(
      _hydrationNotificationBaseId,
      _hydrationNotificationMaxId,
    );
  }

  Future<void> cancelDailyReminders() async {
    await _cancelRange(_dailyNotificationBaseId, _dailyNotificationMaxId);
  }

  Future<void> cancelWorkoutReminders() async {
    await _cancelRange(_workoutNotificationBaseId, _workoutNotificationMaxId);
  }

  Future<int> pendingHydrationReminderCount() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending
        .where(
          (notification) =>
              notification.id >= _hydrationNotificationBaseId &&
              notification.id < _hydrationNotificationMaxId,
        )
        .length;
  }

  Future<void> showHydrationTestNotification() async {
    await _plugin.show(
      990,
      'Atlas hydration test',
      'Water reminders are able to appear on this phone.',
      _hydrationDetails,
    );
  }

  Future<void> scheduleMissedWorkoutCheck() async {
    await _scheduleDailyNotification(
      'Atlas workout check',
      'If you skipped today, open Atlas and decide whether to train or rest.',
      _nextDailyOccurrence(hour: 20),
      id: _workoutNotificationBaseId + 1,
      details: _generalDetails,
    );
  }

  Future<void> _cancelRange(int startInclusive, int endExclusive) async {
    final pending = await _plugin.pendingNotificationRequests();
    final ids = pending
        .map((notification) => notification.id)
        .where((id) => id >= startInclusive && id < endExclusive);
    for (final id in ids) {
      await _plugin.cancel(id);
    }
  }

  tz.TZDateTime _nextDailyOccurrence({required int hour, int minute = 0}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _scheduleDailyNotification(
    String title,
    String body,
    tz.TZDateTime scheduledAt, {
    required int id,
    required NotificationDetails details,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> _scheduleOneShotNotification(
    String title,
    String body,
    tz.TZDateTime scheduledAt, {
    required int id,
    required NotificationDetails details,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static const _hydrationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'atlas_hydration_water_v2',
      'Hydration reminders',
      channelDescription: 'Gentle hydration nudges from Atlas.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('atlas_water_drop'),
    ),
  );

  static const _generalDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'atlas_daily_reminders',
      'Atlas reminders',
      channelDescription: 'Workout and daily Atlas reminders.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
  );
}
