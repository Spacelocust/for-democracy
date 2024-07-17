import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mobile/enum/notification_type.dart';
import 'package:mobile/services/local_notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class FirebaseMessagingService {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  static FirebaseMessaging get firebaseMessaging => _firebaseMessaging;

  static Future<void> init(GlobalKey<NavigatorState> rootNavigatorKey) async {
    // Request permission
    await _firebaseMessaging.requestPermission();

    // Set the foreground notification presentation options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(
          (remoteMessage) => handleMessage(
            rootNavigatorKey.currentContext,
            remoteMessage,
          ),
        );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (remoteMessage) => handleMessage(
        rootNavigatorKey.currentContext,
        remoteMessage,
      ),
    );
    FirebaseMessaging.onMessage.listen(
      (remoteMessage) => handleMessage(
        rootNavigatorKey.currentContext,
        remoteMessage,
      ),
    );
  }

  static void handleMessage(BuildContext? context, RemoteMessage? message) {
    if (message == null || message.data.isEmpty || context == null) {
      return;
    }

    String? notificationTitle;
    String? notificationBody;
    NotificationType? notificationType =
        NotificationType.values.cast().firstWhere(
              (e) => e.type == message.data['type'],
              orElse: () => null,
            );

    switch (notificationType) {
      case NotificationType.groupJoined:
        notificationTitle = AppLocalizations.of(context)!.attack;
        notificationBody = 'You have joined a group';

        break;
      default:
        return;
    }

    LocalNotificationService.showNotification(
      title: notificationTitle,
      body: notificationBody,
      payload: jsonEncode(message.toMap()),
    );
  }
}
