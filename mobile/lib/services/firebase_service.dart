import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/enum/notification_type.dart';
import 'package:mobile/services/local_notification_service.dart';

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
        var username = message.data['username'] as String?;
        if (username == null) {
          return;
        }

        notificationTitle = AppLocalizations.of(context)!.groupJoinedTitle;
        notificationBody =
            AppLocalizations.of(context)!.groupJoinedBody(username);

        break;
      case NotificationType.groupUpdated:
        if (message.data['data'] == null) {
          return;
        }

        var groupName = jsonDecode(message.data['data'])['Name'] as String?;
        if (groupName == null) {
          return;
        }

        notificationTitle = AppLocalizations.of(context)!.groupUpdatedTitle;
        notificationBody =
            AppLocalizations.of(context)!.groupUpdatedBody(groupName);

        break;
      case NotificationType.groupLeft:
        var username = message.data['username'] as String?;
        if (username == null) {
          return;
        }

        notificationTitle = AppLocalizations.of(context)!.groupLeftTitle;
        notificationBody =
            AppLocalizations.of(context)!.groupLeftBody(username);

        break;
      case NotificationType.missionJoined:
        var username = message.data['username'] as String?;
        if (username == null) {
          return;
        }

        notificationTitle = AppLocalizations.of(context)!.missionJoinedTitle;
        notificationBody =
            AppLocalizations.of(context)!.missionJoinedBody(username);
      case NotificationType.missionLeft:
        var username = message.data['username'] as String?;
        if (username == null) {
          return;
        }

        notificationTitle = AppLocalizations.of(context)!.missionLeftTitle;
        notificationBody =
            AppLocalizations.of(context)!.missionLeftBody(username);

        break;
      case NotificationType.missionUpdated:
        var missionName = message.data['mission_name'] as String?;
        if (missionName == null) {
          return;
        }

        notificationTitle = AppLocalizations.of(context)!.missionUpdatedTitle;
        notificationBody =
            AppLocalizations.of(context)!.missionUpdatedBody(missionName);

        break;
      case NotificationType.missionCreated:
        if (message.data['data'] == null) {
          return;
        }

        var groupName = jsonDecode(message.data['data'])['Name'] as String?;
        if (groupName == null) {
          return;
        }

        notificationTitle = AppLocalizations.of(context)!.missionCreatedTitle;
        notificationBody =
            AppLocalizations.of(context)!.missionCreatedBody(groupName);

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
