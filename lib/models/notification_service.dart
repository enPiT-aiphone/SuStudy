import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (!kIsWeb) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _localNotificationsPlugin.initialize(
        initializationSettings,
      );
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
    });

    // メッセージのリスナー設定（モバイル）
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.notification?.title}");
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.notification?.title}");
    });
  }

  static Future<void> showTestNotification({required String title, required String body}) async {
    if (kIsWeb) {
      // Webでの通知の表示（実際の通知はサポートが限定的）
      print("Web Notification: $title - $body");
    } else {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel_id',
        'Test Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      await _localNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }
}
