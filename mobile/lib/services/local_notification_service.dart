import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/services/firebase_service.dart';

abstract class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static Future<void> init() async {
    // Specify the initialization settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_helldivers');

    // Specify the initialization settings of the plugin
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    final platform =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }

  static showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Specify the details of the notification
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      icon: '@drawable/ic_helldivers',
      channelDescription: _androidChannel.description,
      importance: _androidChannel.importance,
      priority: Priority.high,
      ticker: 'ticker',
      color: const Color(0xfffae74f),
    );

    // Specify the notification details
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  if (notificationResponse.payload != null) {
    final message =
        RemoteMessage.fromMap(jsonDecode(notificationResponse.payload!));
    FirebaseMessagingService.handleMessage(message);
  }
}
