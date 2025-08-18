import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationPlugin.initialize(initializationSettings);
  }

  Future<void> showMotivationalNotification(int habitId, String habitName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'habit_motivational_channel',
      'Motivational Notifications',
      channelDescription: 'Notifications for achieving habit streaks',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationPlugin.show(
      habitId,
      'Great Job!',
      'You\'ve completed "$habitName" for 5 days in a row! Keep it up! 🎉',
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleReminderNotification(int habitId, String habitName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'habit_reminder_channel',
      'Reminder Notifications',
      channelDescription: 'Notifications to remind you to mark your habits',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationPlugin.zonedSchedule(
      habitId + 1000, // Unique ID for reminders
      'Don\'t Forget!',
      'You haven\'t marked "$habitName" for today. Complete it now! ⏰',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 19)), // Schedule at 7 PM
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Required parameter
    );
  }
}