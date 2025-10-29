import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart'; // ✅ arahkan ke halaman login, bukan main.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();

    // Jalankan animasi progress dan navigasi otomatis
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        _progressValue += 0.1;
        if (_progressValue >= 1) {
          _progressValue = 1;
          timer.cancel();

          // ✅ Arahkan ke halaman login, bukan MainNavigation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === Gambar ilustrasi ===
              Image.network(
                "https://i.ibb.co/3MkXk4N/driver-illustration.png",
                height: 180,
              ),
              const SizedBox(height: 20),

              // === Judul utama ===
              const Text(
                "Microsleep Guard",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),

              // === Deskripsi singkat ===
              const Text(
                "Sistem Keamanan Berkendara Anda yang\nSelalu Siaga Menjaga Keselamatan di Jalan",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // === Progress bar ===
              LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: Colors.grey[300],
                color: Colors.red,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sistem siap digunakan",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 30),
              const Text(
                "•••",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 40),

              // === Footer ===
              Column(
                children: const [
                  Text(
                    "versi 1.0.0",
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "© 2025 MicroSleep Ulala Project",
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
