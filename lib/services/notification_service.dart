import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Wraps [FlutterLocalNotificationsPlugin] so the rest of the app doesn't
/// depend on the plugin directly.
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialised = false;

  /// Call once, early in [main], before [runApp].
  Future<void> init() async {
    if (_initialised) return;
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );
      await _plugin.initialize(settings);
      _initialised = true;

      // Request notification permission on Android 13+
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      // Notifications are optional — fail silently so the app still starts.
      debugPrint('NotificationService.init failed: $e');
      _initialised = false;
    }
  }

  /// Shows an immediate local notification (focus session / break finished).
  Future<void> showFocusComplete({required String title, required String body}) async {
    if (!_initialised) return;
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'focus_complete',
          'Focus Sessions',
          channelDescription: 'Notifications for completed focus and break sessions.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Schedules a one-shot reminder [minutes] from now.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    if (!_initialised) return;
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Reminders',
          channelDescription: 'Scheduled reminders for tasks and focus sessions.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancels a scheduled reminder by [id].
  Future<void> cancel(int id) async {
    if (!_initialised) return;
    await _plugin.cancel(id);
  }
}