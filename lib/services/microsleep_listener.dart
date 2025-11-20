import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vibration/vibration.dart';

import 'notification_service.dart';
import '../microsleep_call_overlay.dart';

class MicrosleepListener {
  static bool _isListening = false;
  static bool _isAlarm = false;

  // ============================================================
  // SAFE BOOLEAN CONVERTER
  // ============================================================
  static bool toBool(dynamic v) {
    if (v == true) return true;
    if (v == "true") return true;
    if (v == 1) return true;
    return false;
  }

  // ============================================================
  // START LISTENER
  // ============================================================
  static void start(BuildContext context) {
    if (_isListening) return; // Hindari listener dobel
    _isListening = true;

    final dbState = FirebaseDatabase.instance.ref("status_user/state");
    final dbAlarm = FirebaseDatabase.instance.ref("settings/alarm");

    dbState.onValue.listen((event) async {
      final state = event.snapshot.value?.toString().toLowerCase() ?? "normal";

      // Baca pengaturan alarm
      final alarmSnap = await dbAlarm.get();
      final soundOn = toBool(alarmSnap.child("suara").value);
      final vibrateOn = toBool(alarmSnap.child("getar").value);

      print("🎧 Sound: $soundOn  |  📳 Vibrate: $vibrateOn");

      // ============================================================
      // MASUK MICROSLEEP
      // ============================================================
      if (state == "microsleep" && !_isAlarm) {
        _isAlarm = true;

        // Notifikasi (bunyi jika soundOn)
        await NotificationService.showMicrosleepAlert(soundOn: soundOn);

        // Overlay
        MicrosleepCallOverlay.show(context: context);

        // ============================================================
        // VIBRATE FIX: aman + support semua device
        // ============================================================
        if (vibrateOn) {
          final canVibrate = await Vibration.hasVibrator() ?? false;

          if (canVibrate) {
            // Pola getaran supaya terasa
            Vibration.vibrate(
              pattern: [0, 350, 200, 350],
              intensities: [128, 0, 255],
            );
          } else {
            print("⚠️ Device tidak mendukung getaran");
          }
        }
      }

      // ============================================================
      // KELUAR DARI MICROSLEEP → MATIKAN SEMUA
      // ============================================================
      if (state != "microsleep" && _isAlarm) {
        _isAlarm = false;

        NotificationService.stop();
        MicrosleepCallOverlay.hide();

        // Matikan getaran
        Vibration.cancel();
      }
    });
  }
}
