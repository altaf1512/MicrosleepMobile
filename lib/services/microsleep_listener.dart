import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import '../microsleep_call_overlay.dart';

class MicrosleepListener {
  static final ap.AudioPlayer _player = ap.AudioPlayer();
  static bool _isListening = false;
  static bool _isAlarmPlaying = false;

  static late BuildContext _rootContext;

  static void start(BuildContext context) {
    if (_isListening) return;
    _isListening = true;

    // Simpan context global untuk overlay
    _rootContext = context;

    final dbRef = FirebaseDatabase.instance.ref('status/user');

    dbRef.onValue.listen((event) async {
      final value = event.snapshot.value?.toString().toLowerCase() ?? 'normal';

      if (value == 'microsleep' && !_isAlarmPlaying) {
        _isAlarmPlaying = true;

        // 🔊 Bunyi alarm loop
        await _player.stop();
        await _player.setReleaseMode(ap.ReleaseMode.loop);
        await _player.play(ap.AssetSource('sound/alarm.wav'));

        debugPrint("✅ Alarm global diputar");

        // 🔔 Tampilkan notifikasi overlay di semua halaman
        MicrosleepCallOverlay.show(context: _rootContext);
      } else if (value != 'microsleep' && _isAlarmPlaying) {
        await stopAlarm();
      }
    });
  }

  static Future<void> stopAlarm() async {
    try {
      await _player.stop();
      _isAlarmPlaying = false;
      MicrosleepCallOverlay.hide();
      debugPrint("🟢 Alarm berhenti");
    } catch (e) {
      debugPrint("❌ Gagal stop alarm: $e");
    }
  }
}
