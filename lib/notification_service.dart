import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // initialize the plugin 'flutter_local_notifications' for both android and ios
  initialize() async {
    // initialize time zone
    tz.initializeTimeZones();
    // initialization settings for android
    AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("img_1");

    // initialization settings for ios
    DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );

    // combine both initialization settings
    InitializationSettings initializationSettings =
        InitializationSettings(iOS: iosInitializationSettings, android: androidInitializationSettings);

    // now pass both the combined initialization settings to initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) {
      log("121 pay${response.payload}");
    });
  }

  // To show the notification we need to create NotificationDetails
  displayNotification() {
    // notification details android
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("channelId", "channelName", priority: Priority.max, importance: Importance.max);

    // notification details ios
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: true, presentBadge: true);

    // combined notification details
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails, iOS: darwinNotificationDetails);

    // quickNotification(notificationDetails);
    scheduleNotificationForLatter(notificationDetails);
  }

  // quick notification
  quickNotification(NotificationDetails notificationDetails) {
    flutterLocalNotificationsPlugin.show(121, "title", "body", notificationDetails);
  }

  // schedule notification notification for latter
  scheduleNotificationForLatter(NotificationDetails notificationDetails) async {
    // 'schedule' is deprecated and shouldn't be used. Deprecated due to problems with time zones
    // flutterLocalNotificationsPlugin.schedule(121, "title", "body", DateTime.now().add(Duration(seconds: 5)), notificationDetails);

    // new way
    await flutterLocalNotificationsPlugin.zonedSchedule(
        121, "title", "body", tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)), notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: "data : Notification Payload");
  }

  // for payload in notification
  checkForNotification() async {
    NotificationAppLaunchDetails? details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null) {
      if (details.didNotificationLaunchApp) {
        String? payload = details.notificationResponse?.payload;
        log("Notification Data $payload");
      }
    }
  }
}
