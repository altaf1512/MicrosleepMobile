import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../microsleep_call_overlay.dart';

class MicrosleepListener {
  static final ap.AudioPlayer _player = ap.AudioPlayer();

  static bool _isListening = false;
  static bool _isAlarmPlaying = false;
  static bool _vibrationActive = false;

  static late BuildContext _rootContext;

  static void start(BuildContext context) {
    if (_isListening) return;
    _isListening = true;

    _rootContext = context;

    // 🔥🔥 PATH BENAR SESUAI DATABASE-MU
    final dbState  = FirebaseDatabase.instance.ref('status_user/state');
    final dbTime   = FirebaseDatabase.instance.ref('status_user/timestamp');
    final dbAlarm  = FirebaseDatabase.instance.ref('settings/alarm');

    dbState.onValue.listen((event) async {
      final state = event.snapshot.value?.toString().toLowerCase() ?? 'normal';

      // Ambil setting
      final alarmSnap = await dbAlarm.get();
      bool suaraOn = true;
      bool getarOn = true;

      if (alarmSnap.exists) {
        final data = Map<String, dynamic>.from(alarmSnap.value as Map);
        suaraOn = data["suara"] ?? true;
        getarOn = data["getar"] ?? true;
      }

      // =====================================================
      // 🔥 JIKA MICROSLEEP
      // =====================================================
      if (state == "microsleep" && !_isAlarmPlaying) {
        _isAlarmPlaying = true;

        // Simpan timestamp microsleep
        await dbTime.set(DateTime.now().millisecondsSinceEpoch);

        // 🎵 Suara alarm
        if (suaraOn) {
          await _player.stop();
          await _player.setReleaseMode(ap.ReleaseMode.loop);
          await _player.play(ap.AssetSource('sound/alarm.wav'));
        }

        // 📳 Getar
        if (getarOn) _startVibrationLoop();

        // 🟥 Overlay visual
        MicrosleepCallOverlay.show(context: _rootContext);
      }

      // =====================================================
      // 🟢 BALIK NORMAL → STOP ALARM
      // =====================================================
      else if (state != "microsleep" && _isAlarmPlaying) {
        await stopAlarm();
      }
    });
  }

  static void _startVibrationLoop() async {
    _vibrationActive = true;

    if (!(await Vibration.hasVibrator() ?? false)) return;

    Future.doWhile(() async {
      if (!_vibrationActive) return false;

      Vibration.vibrate(duration: 150);
      await Future.delayed(const Duration(milliseconds: 700));

      return _vibrationActive;
    });
  }

  static Future<void> stopAlarm() async {
    try {
      _vibrationActive = false;
      await _player.stop();
      _isAlarmPlaying = false;
      MicrosleepCallOverlay.hide();
    } catch (e) {
      debugPrint("❌ Error stop alarm: $e");
    }
  }
}
