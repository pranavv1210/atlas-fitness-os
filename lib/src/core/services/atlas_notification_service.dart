import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AtlasNotificationService {
  AtlasNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    tz.initializeTimeZones();
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
  static const _hydrationNotificationMaxId = 1500;
  static const _hydrationScheduleDays = 7;
  static const _hydrationStartHour = 8;
  static const _hydrationEndHour = 22;

  Future<void> scheduleHydrationNudges({required int intervalMinutes}) async {
    await cancelHydrationNudge();
    const details = NotificationDetails(
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
    final now = tz.TZDateTime.now(tz.local);
    var notificationId = _hydrationNotificationBaseId;
    for (var dayOffset = 0; dayOffset < _hydrationScheduleDays; dayOffset++) {
      var scheduledAt = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + dayOffset,
        _hydrationStartHour,
      );
      final endOfWindow = tz.TZDateTime(
        tz.local,
        scheduledAt.year,
        scheduledAt.month,
        scheduledAt.day,
        _hydrationEndHour,
      );

      while (!scheduledAt.isAfter(endOfWindow)) {
        if (scheduledAt.isAfter(now)) {
          await _plugin.zonedSchedule(
            notificationId++,
            'Atlas hydration',
            'Time for a calm water check-in.',
            scheduledAt,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        }
        scheduledAt = scheduledAt.add(Duration(minutes: intervalMinutes));
      }
    }
  }

  Future<void> cancelHydrationNudge() async {
    final pending = await _plugin.pendingNotificationRequests();
    final hydrationIds = pending
        .map((notification) => notification.id)
        .where(
          (id) =>
              id >= _hydrationNotificationBaseId &&
              id < _hydrationNotificationMaxId,
        );
    for (final id in hydrationIds) {
      await _plugin.cancel(id);
    }
  }
}
