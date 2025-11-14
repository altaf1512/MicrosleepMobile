import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vibration/vibration.dart';
import 'notification_service.dart';

class BackgroundMicrosleepService {
  static bool _isAlarm = false;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        isForegroundMode: true,
        autoStart: true,
        // foregroundServiceNotificationTitle: "Microsleep Guard",
        // foregroundServiceNotificationContent: "Monitoring aktif",
      ),
      iosConfiguration: IosConfiguration(),
    );

    service.startService();
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    final dbState = FirebaseDatabase.instance.ref("status_user/state");
    final dbAlarm = FirebaseDatabase.instance.ref("settings/alarm");

    dbState.onValue.listen((event) async {
      final state = event.snapshot.value?.toString().toLowerCase() ?? "normal";

      final alarmSnap = await dbAlarm.get();
      bool soundOn = alarmSnap.child("suara").value == true;
      bool vibrateOn = alarmSnap.child("getar").value == true;

      if (state == "microsleep" && !_isAlarm) {
        _isAlarm = true;

        NotificationService.showMicrosleepAlert(soundOn: soundOn);

        if (vibrateOn && (await Vibration.hasVibrator() ?? false)) {
          Vibration.vibrate(pattern: [0, 300, 500], repeat: 0);
        }
      }

      if (state != "microsleep" && _isAlarm) {
        _isAlarm = false;

        NotificationService.stop();
        Vibration.cancel();
      }
    });
  }
}
