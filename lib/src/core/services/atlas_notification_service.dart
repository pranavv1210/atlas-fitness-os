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

  Future<void> scheduleHydrationNudge() async {
    await _plugin.cancel(1001);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'atlas_hydration',
        'Hydration reminders',
        channelDescription: 'Gentle hydration nudges from Atlas.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (first.isBefore(now)) {
      first = first.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      1001,
      'Atlas hydration',
      'A calm water check-in for today.',
      first,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelHydrationNudge() => _plugin.cancel(1001);
}
