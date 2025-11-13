import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';     // ✅ DITAMBAHKAN
import '../microsleep_call_overlay.dart';

class MicrosleepListener {
  static final ap.AudioPlayer _player = ap.AudioPlayer();
  static bool _isListening = false;
  static bool _isAlarmPlaying = false;

  static late BuildContext _rootContext;

  // Untuk loop getaran
  static bool _vibrationActive = false;

  static void start(BuildContext context) {
    if (_isListening) return;
    _isListening = true;

    _rootContext = context;

    final dbUser = FirebaseDatabase.instance.ref('status/user');
    final dbStatus = FirebaseDatabase.instance.ref('status');
    final dbAlarm = FirebaseDatabase.instance.ref('settings/alarm');

    dbUser.onValue.listen((event) async {
      final value = event.snapshot.value?.toString().toLowerCase() ?? 'normal';

      // Ambil setting alarm terbaru
      final alarmSnap = await dbAlarm.get();
      bool suaraOn = true;
      bool getarOn = true;

      if (alarmSnap.exists) {
        final data = Map<String, dynamic>.from(alarmSnap.value as Map);
        suaraOn = data["suara"] ?? true;
        getarOn = data["getar"] ?? true;
      }

      // =====================================================
      // 🔥 MICROSLEEP DIMULAI
      // =====================================================
      if (value == 'microsleep' && !_isAlarmPlaying) {
        _isAlarmPlaying = true;

        // Simpan timestamp
        await dbStatus.update({
          "start_time": DateTime.now().millisecondsSinceEpoch,
        });

        // 🔊 Suara
        if (suaraOn) {
          await _player.stop();
          await _player.setReleaseMode(ap.ReleaseMode.loop);
          await _player.play(ap.AssetSource('sound/alarm.wav'));
        }

        // 📳 Getaran loop
        if (getarOn) {
          _startVibrationLoop();
        }

        // 🟥 Overlay merah
        MicrosleepCallOverlay.show(context: _rootContext);
      }

      // =====================================================
      // 🟢 NORMAL (hentikan alarm)
      // =====================================================
      else if (value != 'microsleep' && _isAlarmPlaying) {
        await stopAlarm();
      }
    });
  }

  // ============================================================
  // 📳 GETARAN LOOP — tiap 700ms seperti alarm HP
  // ============================================================
  static void _startVibrationLoop() async {
    _vibrationActive = true;

    // Pastikan device punya motor getar
    if (!(await Vibration.hasVibrator() ?? false)) {
      debugPrint("⚠️ Device tidak mendukung getaran");
      return;
    }

    Future.doWhile(() async {
      if (!_vibrationActive) return false;

      // Getar 100ms → delay 600ms → ulang
      Vibration.vibrate(duration: 100);

      await Future.delayed(const Duration(milliseconds: 700));
      return _vibrationActive;
    });
  }

  // ============================================================
  // 🛑 MATIKAN SEMUA ALARM
  // ============================================================
  static Future<void> stopAlarm() async {
    try {
      _vibrationActive = false;

      await _player.stop();
      _isAlarmPlaying = false;

      MicrosleepCallOverlay.hide();
    } catch (e) {
      debugPrint("❌ Gagal stop alarm: $e");
    }
  }
}
