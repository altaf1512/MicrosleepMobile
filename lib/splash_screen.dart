import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Setelah 5 detik, otomatis ke halaman login
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFBA0403); // 🎨 warna utama kamu

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === 🚗 Animasi mobil merah dari Lottie ===
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Lottie.asset(
                  'assets/animation/Red Car Drive.json',
                  height: 220,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),

              const SizedBox(height: 30),

              // === Judul utama ===
              const Text(
                "Microsleep Guard",
                style: TextStyle(
                  color: mainColor,
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

              // === Progress bar halus ===
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(seconds: 5),
                builder: (context, value, _) => Column(
                  children: [
                    LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      color: mainColor, // 🎨 warna progress bar
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sistem siap digunakan",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "•••",
                style: TextStyle(
                  fontSize: 20,
                  color: mainColor,
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
