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
      final alarmSnap = await dbAlarm.get();

      bool soundOn = alarmSnap.child("suara").value == true;
      bool vibrateOn = alarmSnap.child("getar").value == true;

      if (state == "microsleep" && !_isAlarm) {
        _isAlarm = true;

        NotificationService.showMicrosleepAlert(soundOn: soundOn);
        MicrosleepCallOverlay.show(context: context);

        if (vibrateOn) Vibration.vibrate(duration: 300);
      }

      if (state != "microsleep" && _isAlarm) {
        _isAlarm = false;
        NotificationService.stop();
        MicrosleepCallOverlay.hide();
        Vibration.cancel();
      }
    });
  }
}
