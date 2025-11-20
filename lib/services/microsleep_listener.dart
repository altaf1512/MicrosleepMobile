import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vibration/vibration.dart';

import 'notification_service.dart';
import '../microsleep_call_overlay.dart';

class MicrosleepListener {
  static bool _isListening = false;
  static bool _isAlarm = false;

  static void start(BuildContext context) {
    if (_isListening) return;
    _isListening = true;

    final dbState = FirebaseDatabase.instance.ref("status_user/state");
    final dbAlarm = FirebaseDatabase.instance.ref("settings/alarm");

    dbState.onValue.listen((event) async {
      final state = event.snapshot.value?.toString().toLowerCase() ?? "normal";

      // Ambil pengaturan alarm
      final alarmSnap = await dbAlarm.get();
      final soundOn = alarmSnap.child("suara").value == true;
      final vibrateOn = alarmSnap.child("getar").value == true;

      // ====================================================
      // MASUK MICROSLEEP → NYALAKAN ALARM
      // ====================================================
      if (state == "microsleep" && !_isAlarm) {
        _isAlarm = true;

        // Notifikasi (bunyi + fullscreen)
        await NotificationService.showMicrosleepAlert(soundOn: soundOn);

        // Overlay
        MicrosleepCallOverlay.show(context: context);

        // Getar
        if (vibrateOn) {
          Vibration.vibrate(duration: 400);
        }
      }

      // ====================================================
      // KELUAR NORMAL → MATIKAN SEMUA
      // ====================================================
      if (state != "microsleep" && _isAlarm) {
        _isAlarm = false;

        NotificationService.stop();
        MicrosleepCallOverlay.hide();
        Vibration.cancel();
      }
    });
  }
}
