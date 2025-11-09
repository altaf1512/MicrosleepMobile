import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'login_page.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Animasi titik berkedip tiap 400ms
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _dotCount = (_dotCount + 1) % 4; // 0,1,2,3 → ulang
      });
    });

    // Setelah 5 detik ke halaman login
    Future.delayed(const Duration(seconds: 5), () {
      _timer?.cancel(); // hentikan animasi titik
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFBA0403);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === 🚗 Animasi mobil merah ===
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

              const Text(
                "Microsleep Guard",
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),

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
                      color: mainColor,
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

              // === 🔄 Titik tiga animasi ===
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '.' * _dotCount,
                  style: const TextStyle(
                    fontSize: 26,
                    color: mainColor,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
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
