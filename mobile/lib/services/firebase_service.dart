import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/services/local_notification_service.dart';

abstract class FirebaseMessagingService {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request permission
    await _firebaseMessaging.requestPermission();

    // Get the token
    var token = await _firebaseMessaging.getToken();

    log('token: $token');

    // Set the foreground notification presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle messages
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
  }

  static void handleMessage(RemoteMessage? message) {
    if (message == null || message.notification == null) {
      return;
    }

    var notification = message.notification!;

    LocalNotificationService.showNotification(
      title: notification.title!,
      body: notification.body!,
      payload: jsonEncode(message.toMap()),
    );
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log(message.toString());
}
