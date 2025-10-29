import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'splash_screen.dart';
import 'dashboard_page.dart';
import 'history_page.dart';
import 'location_page.dart';
import 'setting_page.dart';

void main() {
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
      home: const SplashScreen(), // ✅ SplashScreen muncul pertama
    );
  }
}

// ==========================
// 🔻 Bottom Navigation Page
// ==========================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // ✅ Dashboard dikasih callback agar bisa ganti tab dari dalam
    _pages = [
      DashboardPage(onTabSelected: _onItemTapped),
      const LokasiPage(),
      const RiwayatPage(),
      const PengaturanPage(),
    ];
  }

  // Fungsi untuk ganti tab di BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.mapPin),
            label: 'Lokasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bell),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
