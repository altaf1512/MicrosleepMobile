import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'microsleep_channel',
      'Microsleep Alarm',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showMicrosleepAlert({required bool soundOn}) async {
    final android = AndroidNotificationDetails(
      'microsleep_channel',
      'Microsleep Alarm',
      channelDescription: 'Full screen alarm',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: soundOn,
      sound:
          soundOn ? RawResourceAndroidNotificationSound('alarm') : null,
      ongoing: true,
      autoCancel: false,
    );

    await _plugin.show(
      100,
      '⚠️ Microsleep Terdeteksi!',
      soundOn ? 'Alarm berbunyi!' : 'Microsleep (silent)',
      NotificationDetails(android: android),
    );
  }

  static Future<void> stop() async {
    await _plugin.cancelAll();
  }
}
