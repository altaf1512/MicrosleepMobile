import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 🔧 Inisialisasi notifikasi (panggil di main)
  static Future<void> initialize(BuildContext context) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Ketika notifikasi ditekan → buka Dashboard
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
          (route) => false,
        );
      },
    );
  }

  // 🔔 Tampilkan notifikasi kayak telepon
  static Future<void> showMicrosleepAlert() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'microsleep_channel',
      'Microsleep Alert',
      channelDescription: 'Notifikasi deteksi microsleep',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // 👈 Biar tampil kayak panggilan
      sound: RawResourceAndroidNotificationSound('alarm'), // gunakan assets/sound/alarm.wav
      playSound: true,
      category: AndroidNotificationCategory.call,
      ongoing: true,
      autoCancel: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      1,
      '⚠️ Microsleep Terdeteksi!',
      'Segera hentikan kendaraan dengan aman',
      platformChannelSpecifics,
    );
  }

  // 🚫 Matikan notifikasi
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
