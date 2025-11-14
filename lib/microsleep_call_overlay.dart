import 'package:flutter/material.dart';
import 'main.dart';

class MicrosleepCallOverlay {
  static OverlayEntry? _entry;
  static bool _visible = false;

  static void show({required BuildContext context}) {
    if (_visible) return;
    _visible = true;

    _entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: GestureDetector(
          onTap: () {
            mainNavKey.currentState?.switchToDashboard();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_rounded, color: Colors.white, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "⚠️ Microsleep Terdeteksi!\nKetuk untuk kembali ke Dashboard.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white)
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true)?.insert(_entry!);
  }

  static void hide() {
    if (!_visible) return;
    _entry?.remove();
    _entry = null;
    _visible = false;
  }
}
