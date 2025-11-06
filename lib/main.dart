import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <-- hasil dari flutterfire configure

// Halaman kamu
import 'splash_screen.dart';
import 'dashboard_page.dart';
import 'history_page.dart';
import 'location_page.dart';
import 'setting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Microsleep Guard',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================
// 🌊 Curved Navigation Bar (Merah Solid)
// ==========================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    LokasiPage(),
    RiwayatPage(),
    PengaturanPage(),
  ];

  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _navKey,
        index: _selectedIndex,
        height: 65,
        backgroundColor: Colors.transparent,
        color: const Color(0xFFB00000), // 🔴 warna merah solid
        buttonBackgroundColor: const Color(0xFFB00000), // merah juga
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        items: const [
          Icon(LucideIcons.layoutDashboard, size: 28, color: Colors.white),
          Icon(LucideIcons.mapPin, size: 28, color: Colors.white),
          Icon(LucideIcons.history, size: 28, color: Colors.white),
          Icon(LucideIcons.settings, size: 28, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
