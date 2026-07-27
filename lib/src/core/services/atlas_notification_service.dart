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
    return await android?.requestNotificationsPermission() ?? true;
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
      await _plugin.zonedSchedule(
        notificationId++,
        'Atlas hydration',
        'Time for a calm water check-in.',
        _nextDailyOccurrence(hour: slot.hour, minute: slot.minute),
        _hydrationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> scheduleDailyReminders() async {
    await cancelDailyReminders();
    await _plugin.zonedSchedule(
      _dailyNotificationBaseId,
      'Atlas check-in',
      'Log today once so your trend stays accurate.',
      _nextDailyOccurrence(hour: 9),
      _generalDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWorkoutReminders() async {
    await cancelWorkoutReminders();
    await _plugin.zonedSchedule(
      _workoutNotificationBaseId,
      'Atlas workout',
      'Your training slot is ready when you are.',
      _nextDailyOccurrence(hour: 18),
      _generalDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleAtlasReminders({
    required int hydrationIntervalMinutes,
  }) async {
    await scheduleHydrationNudges(intervalMinutes: hydrationIntervalMinutes);
    await scheduleDailyReminders();
    await scheduleWorkoutReminders();
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

  static const _hydrationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'atlas_hydration_water',
      'Hydration reminders',
      channelDescription: 'Gentle hydration nudges from Atlas.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
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
