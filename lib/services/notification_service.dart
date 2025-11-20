import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ======================================================
  // INITIALIZE
  // ======================================================
  static Future<void> initialize() async {
    await requestPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);

    final androidPlatform =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // ========== CHANNEL BERSUARA ==========
    const channelSound = AndroidNotificationChannel(
      'microsleep_sound',
      'Microsleep Alarm (Suara)',
      description: 'Alarm dengan bunyi',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );

    // ========== CHANNEL TANPA SUARA ==========
    const channelSilent = AndroidNotificationChannel(
      'microsleep_silent',
      'Microsleep Alarm (Silent)',
      description: 'Alarm tanpa suara',
      importance: Importance.max,
      playSound: false,
    );

    await androidPlatform?.createNotificationChannel(channelSound);
    await androidPlatform?.createNotificationChannel(channelSilent);
  }

  // ======================================================
  // IZIN NOTIFIKASI ANDROID 13+
  // ======================================================
  static Future<void> requestPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  // ======================================================
  // SHOW MICROSLEEP ALERT
  // ======================================================
  static Future<void> showMicrosleepAlert({required bool soundOn}) async {
    final channelId = soundOn ? 'microsleep_sound' : 'microsleep_silent';

    final android = AndroidNotificationDetails(
      channelId,
      soundOn ? 'Microsleep Alarm (Suara)' : 'Microsleep Alarm (Silent)',
      channelDescription:
          soundOn ? 'Alarm berbunyi' : 'Alarm tanpa suara',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: soundOn,
      ongoing: true,
      autoCancel: false,
    );

    await _plugin.show(
      100,
      '⚠️ Microsleep Terdeteksi!',
      soundOn ? 'Alarm berbunyi!' : 'Microsleep (sunyi)',
      NotificationDetails(android: android),
    );
  }

  // ======================================================
  // STOP ALARM
  // ======================================================
  static Future<void> stop() async {
    await _plugin.cancelAll();
  }
}
