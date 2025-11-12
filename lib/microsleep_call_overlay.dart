import 'package:flutter/material.dart';
import 'main.dart'; // supaya bisa akses mainNavKey

class MicrosleepCallOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void show({required BuildContext context}) {
    if (_isVisible) return;
    _isVisible = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: GestureDetector(
          onTap: () {
            if (mainNavKey.currentState != null) {
              mainNavKey.currentState!.switchToDashboard();
            }
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "⚠️ Microsleep Terdeteksi!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Ketuk untuk kembali ke Dashboard.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // tampilkan global di semua halaman
    Overlay.of(context, rootOverlay: true)?.insert(_overlayEntry!);
  }

  static void hide() {
    if (_isVisible) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        debugPrint("⚠️ Overlay sudah dihapus sebelumnya: $e");
      }
      _overlayEntry = null;
      _isVisible = false;
    }
  }
}
