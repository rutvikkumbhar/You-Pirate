import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final _notifications  = FlutterLocalNotificationsPlugin();
  static const int downloadNotificationId = 1001;

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(
      android: androidSettings,
    );
    await _notifications.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) async {
          final path = response.payload;
          if(path != null && path.isNotEmpty) {
            await OpenFilex.open(path);
          }
      }
    );
    final androidPlugin =
    _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> showDownloadStarted({required String title}) async {
    const androidDetails = AndroidNotificationDetails(
      'downloads',
      'Downloads',
      channelDescription: 'Download progress notifications',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: 0,
    );
    await _notifications.show(
        id: downloadNotificationId,
        title: title,
        body: "Fetching stream",
        notificationDetails: NotificationDetails(
            android: androidDetails
        )
    );
  }

  static Future<void> updateDownload({
    required String title,
    required int progress,
    required String received,
    required String total
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'downloads',
      'Downloads',
      channelDescription: 'Download progress notifications',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      colorized: true,
    );
    await _notifications.show(
      id: downloadNotificationId,
      title:title,
      body: '$progress%  •  $received/$total',
      notificationDetails: NotificationDetails(
        android: androidDetails,
      ),
    );
  }

  static Future<void> showDownloadCompleted({
    required String title,
    required String filePath,
}) async {
    const androidDetails = AndroidNotificationDetails(
      'downloads',
      'Downloads',
      channelDescription: 'Download notifications',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      onlyAlertOnce: false,
    );

    await _notifications.show(
      id: downloadNotificationId,
      title: title,
      body: 'Download completed',
      notificationDetails: NotificationDetails(
        android: androidDetails,
      ),
      payload: filePath,
    );
  }

  static Future<void> cancelDownload() async {
    await _notifications.cancel(id: downloadNotificationId);
  }
}