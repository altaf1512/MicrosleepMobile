import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vibration/vibration.dart';

import 'notification_service.dart';
import '../microsleep_call_overlay.dart';

class MicrosleepListener {
  static bool _isListening = false;
  static bool _isAlarm = false;

  // Timer untuk looping alarm (sound + vibrate)
  static Timer? _alarmTimer;

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

      // Baca pengaturan alarm (suara & getar)
      final alarmSnap = await dbAlarm.get();
      final soundOn = toBool(alarmSnap.child("suara").value);
      final vibrateOn = toBool(alarmSnap.child("getar").value);

      print("🎧 Sound: $soundOn  |  📳 Vibrate: $vibrateOn  |  state: $state");

      // ============================================================
      // MASUK / BERADA DI MICROSLEEP
      // ============================================================
      if (state == "microsleep") {
        // Pertama kali masuk microsleep -> set flag + tampilkan overlay
        if (!_isAlarm) {
          _isAlarm = true;

          // Notifikasi (biasanya sudah ada sound di dalamnya)
          await NotificationService.showMicrosleepAlert(soundOn: soundOn);

          // Overlay panggilan / full screen merah
          MicrosleepCallOverlay.show(context: context);
        }

        // Mulai / jaga loop alarm (suara & getar) selama microsleep
        _startAlarmLoop(soundOn: soundOn, vibrateOn: vibrateOn);
      }

      // ============================================================
      // KELUAR DARI MICROSLEEP → MATIKAN SEMUA
      // (misal setelah tombol "Matikan Alarm" men-trigger clear_microsleep)
      // ============================================================
      if (state != "microsleep" && _isAlarm) {
        _isAlarm = false;

        // Stop loop alarm
        _alarmTimer?.cancel();
        _alarmTimer = null;

        // Hentikan notifikasi / suara
        NotificationService.stop();

        // Tutup overlay
        MicrosleepCallOverlay.hide();

        // Matikan getaran
        Vibration.cancel();
      }
    });
  }

  // ============================================================
  // LOOP ALARM SELAMA STATUS MASIH "MICROSLEEP"
  // ============================================================
  static void _startAlarmLoop({
    required bool soundOn,
    required bool vibrateOn,
  }) async {
    // Kalau sudah ada timer jalan, tidak usah buat lagi
    if (_alarmTimer != null) return;

    // Timer periodic tiap beberapa detik (bisa kamu ubah intervalnya)
    _alarmTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      // Kalau flag alarm sudah dimatikan, hentikan timer
      if (!_isAlarm) {
        timer.cancel();
        _alarmTimer = null;
        return;
      }

      // ================== SOUND / NOTIFICATION ==================
      if (soundOn) {
        // Panggil lagi notifikasi / sound.
        // Pastikan di NotificationService kamu sudah handle agar tidak bikin
        // notifikasi numpuk, misalnya pakai id tetap.
        await NotificationService.showMicrosleepAlert(soundOn: true);
      }

      // ================== VIBRASI BERULANG ==================
      if (vibrateOn) {
        final canVibrate = await Vibration.hasVibrator() ?? false;

        if (canVibrate) {
          // Pola getaran berulang supaya tetap kerasa
          Vibration.vibrate(
            pattern: [0, 600, 250, 600, 250],
            intensities: [255, 0, 255, 0],
          );
        } else {
          print("⚠️ Device tidak mendukung getaran");
        }
      }
    });
  }
}
