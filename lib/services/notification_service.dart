import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ======================================================
  // INITIALIZE
  // ======================================================
  static Future<void> initialize() async {
    // --- MINTA IZIN ANDROID 13+ ---
    await requestPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    // Init plugin
    await _plugin.initialize(settings);

    // CHANNEL UNTUK ALARM
    const channel = AndroidNotificationChannel(
      'microsleep_channel',
      'Microsleep Alarm',
      description: 'Channel untuk alarm microsleep',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'), // alarm.mp3
    );

    // DAFTARKAN CHANNEL
    final androidPlatform =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlatform?.createNotificationChannel(channel);
  }

  // ======================================================
  // IZIN NOTIFIKASI (ANDROID 13+)
  // ======================================================
  static Future<void> requestPermission() async {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  // ======================================================
  // SHOW ALARM
  // ======================================================
  static Future<void> showMicrosleepAlert({required bool soundOn}) async {
    final android = AndroidNotificationDetails(
      'microsleep_channel',
      'Microsleep Alarm',
      channelDescription: 'Notifikasi alarm microsleep',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: soundOn,
      ongoing: true,
      autoCancel: false,
      sound: soundOn ? RawResourceAndroidNotificationSound('alarm') : null,
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
