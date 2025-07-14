import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'models/reminder.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:io';
import 'package:rrule/rrule.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidInit, iOS: iosInit, macOS: iosInit);
    await _plugin.initialize(settings);
  }

  static Future<void> scheduleReminder(Reminder reminder, {String? customSound}) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        importance: Importance.max,
        priority: Priority.high,
        sound: customSound != null ? RawResourceAndroidNotificationSound(customSound) : null,
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction('snooze_5', 'Snooze 5m'),
          const AndroidNotificationAction('snooze_10', 'Snooze 10m'),
          const AndroidNotificationAction('snooze_30', 'Snooze 30m'),
        ],
      ),
      iOS: DarwinNotificationDetails(
        sound: customSound,
        categoryIdentifier: 'reminderCategory',
      ),
      macOS: DarwinNotificationDetails(
        sound: customSound,
        categoryIdentifier: 'reminderCategory',
      ),
    );
    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);
    if (reminder.recurrenceType == RecurrenceType.none) {
      await _plugin.zonedSchedule(
        reminder.hashCode,
        reminder.title,
        reminder.description,
        scheduledDate,
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: reminder.hashCode.toString(),
      );
    } else if (reminder.recurrenceType == RecurrenceType.custom && reminder.recurrenceRule != null && reminder.recurrenceRule!.isNotEmpty) {
      // Parse RRULE and schedule next 10 occurrences
      final now = DateTime.now();
      final rule = RecurrenceRule.fromString(reminder.recurrenceRule!);
      final instances = rule.getInstances(start: now.toUtc()).take(10);
      int i = 0;
      for (final occ in instances) {
        final occLocal = occ.toLocal();
        if (occLocal.isAfter(now)) {
          final tzDate = tz.TZDateTime.from(occLocal, tz.local);
          await _plugin.zonedSchedule(
            reminder.hashCode + i,
            reminder.title,
            reminder.description,
            tzDate,
            details,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            payload: reminder.hashCode.toString(),
          );
        }
        i++;
      }
    } else {
      // For built-in recurring reminders, schedule the next N occurrences (e.g., next 10)
      final now = DateTime.now();
      DateTime next = reminder.dateTime;
      for (int i = 0; i < 10; i++) {
        if (next.isAfter(now)) {
          final tzDate = tz.TZDateTime.from(next, tz.local);
          await _plugin.zonedSchedule(
            reminder.hashCode + i,
            reminder.title,
            reminder.description,
            tzDate,
            details,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            payload: reminder.hashCode.toString(),
          );
        }
        switch (reminder.recurrenceType) {
          case RecurrenceType.daily:
            next = next.add(const Duration(days: 1));
            break;
          case RecurrenceType.weekly:
            next = next.add(const Duration(days: 7));
            break;
          case RecurrenceType.monthly:
            next = DateTime(next.year, next.month + 1, next.day, next.hour, next.minute);
            break;
          default:
            break;
        }
      }
    }
  }

  /// Call this from your notification tap handler to snooze a reminder
  static Future<void> snoozeReminder(Reminder reminder, Duration duration, {String? customSound}) async {
    final snoozeDate = tz.TZDateTime.from(DateTime.now().add(duration), tz.local);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        importance: Importance.max,
        priority: Priority.high,
        sound: customSound != null ? RawResourceAndroidNotificationSound(customSound) : null,
      ),
      iOS: DarwinNotificationDetails(sound: customSound),
      macOS: DarwinNotificationDetails(sound: customSound),
    );
    await _plugin.zonedSchedule(
      reminder.hashCode + DateTime.now().millisecondsSinceEpoch,
      reminder.title,
      '[Snoozed] ${reminder.description}',
      snoozeDate,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: reminder.hashCode.toString(),
    );
  }

  static Future<void> cancelReminder(Reminder reminder) async {
    await _plugin.cancel(reminder.hashCode);
  }
}
