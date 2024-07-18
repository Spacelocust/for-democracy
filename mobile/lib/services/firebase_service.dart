import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/enum/notification_type.dart';
import 'package:mobile/screens/group_screen.dart';
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
    String? notificationRoutePayload;
    NotificationType? notificationType =
        NotificationType.values.cast().firstWhere(
              (e) => e.type == message.data['type'],
              orElse: () => null,
            );

    switch (notificationType) {
      case NotificationType.groupJoined:
        final username = message.data['username'] as String?;
        final groupName = message.data['group_name'] as String?;
        final groupId = message.data['group_id'] as String?;

        if (username == null || groupName == null || groupId == null) {
          return;
        }

        notificationTitle = groupName;
        notificationBody =
            AppLocalizations.of(context)!.notificationGroupJoinedBody(username);
        notificationRoutePayload = context.namedLocation(
          GroupScreen.routeName,
          pathParameters: {
            'groupId': groupId,
          },
        );

        break;
      case NotificationType.groupUpdated:
        final groupName = message.data['group_name'] as String?;
        final groupId = message.data['group_id'] as String?;

        if (groupName == null || groupId == null) {
          return;
        }

        notificationTitle = groupName;
        notificationBody =
            AppLocalizations.of(context)!.notificationGroupUpdatedBody;
        notificationRoutePayload = context.namedLocation(
          GroupScreen.routeName,
          pathParameters: {
            'groupId': groupId,
          },
        );

        break;
      case NotificationType.groupLeft:
        final username = message.data['username'] as String?;
        final groupName = message.data['group_name'] as String?;
        final groupId = message.data['group_id'] as String?;

        if (username == null || groupName == null || groupId == null) {
          return;
        }

        notificationTitle = groupName;
        notificationBody =
            AppLocalizations.of(context)!.notificationGroupLeftBody(username);
        notificationRoutePayload = context.namedLocation(
          GroupScreen.routeName,
          pathParameters: {
            'groupId': groupId,
          },
        );

        break;
      case NotificationType.missionJoined:
        final username = message.data['username'] as String?;
        final missionName = message.data['mission_name'] as String?;
        final groupName = message.data['group_name'] as String?;
        final groupId = message.data['group_id'] as String?;

        if (username == null ||
            missionName == null ||
            groupName == null ||
            groupId == null) {
          return;
        }

        notificationTitle = groupName;
        notificationBody =
            AppLocalizations.of(context)!.notificationMissionJoinedBody(
          username,
          missionName,
        );
        notificationRoutePayload = context.namedLocation(
          GroupScreen.routeName,
          pathParameters: {
            'groupId': groupId,
          },
        );

        break;
      case NotificationType.missionLeft:
        final username = message.data['username'] as String?;
        final missionName = message.data['mission_name'] as String?;
        final groupName = message.data['group_name'] as String?;
        final groupId = message.data['group_id'] as String?;

        if (username == null ||
            missionName == null ||
            groupName == null ||
            groupId == null) {
          return;
        }

        notificationTitle = groupName;
        notificationBody =
            AppLocalizations.of(context)!.notificationMissionLeftBody(
          username,
          missionName,
        );
        notificationRoutePayload = context.namedLocation(
          GroupScreen.routeName,
          pathParameters: {
            'groupId': groupId,
          },
        );

        break;
      case NotificationType.missionUpdated:
        final missionName = message.data['mission_name'] as String?;
        final groupName = message.data['group_name'] as String?;
        final groupId = message.data['group_id'] as String?;

        if (missionName == null || groupName == null || groupId == null) {
          return;
        }

        notificationTitle = groupName;
        notificationBody = AppLocalizations.of(context)!
            .notificationMissionUpdatedBody(missionName);
        notificationRoutePayload = context.namedLocation(
          GroupScreen.routeName,
          pathParameters: {
            'groupId': groupId,
          },
        );

        break;
      case NotificationType.missionCreated:
        final missionName = message.data['mission_name'] as String?;
        final groupName = message.data['group_name'] as String?;
        final groupId = message.data['group_id'] as String?;

        if (missionName == null || groupName == null || groupId == null) {
          return;
        }

        notificationTitle = groupName;
        notificationBody = AppLocalizations.of(context)!
            .notificationMissionCreatedBody(missionName);
        notificationRoutePayload = context.namedLocation(
          GroupScreen.routeName,
          pathParameters: {
            'groupId': groupId,
          },
        );

        break;
      default:
        return;
    }

    LocalNotificationService.showNotification(
      title: notificationTitle,
      body: notificationBody,
      payload: jsonEncode({
        'route': notificationRoutePayload,
      }),
    );
  }
}
