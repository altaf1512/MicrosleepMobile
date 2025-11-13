import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// services
import 'services/language_service.dart';
import 'services/microsleep_listener.dart';

// localization (flutter_intl)
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/l10n.dart';

// pages
import 'splash_screen.dart';
import 'dashboard_page.dart';
import 'history_page.dart';
import 'location_page.dart';
import 'setting_page.dart';

final GlobalKey<_MainNavigationState> mainNavKey =
    GlobalKey<_MainNavigationState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final languageService = LanguageService();
  await languageService.loadLocale();

  runApp(
    ChangeNotifierProvider(
      create: (_) => languageService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Microsleep Guard',

      // 🌍 Localization
      locale: lang.currentLocale,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate, // <--- PENTING
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

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
// 🌊 Navigasi Bawah (Main Nav)
// ==========================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _pages = [
      DashboardPage(onTabSelected: _onTabSelected),
      const LokasiPage(),
      const RiwayatPage(),
      const PengaturanPage(),
    ];
  }

  // 👉 Dipanggil dari DashboardPage
  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    _navKey.currentState?.setPage(index);
  }

  void switchToDashboard() {
    setState(() => _selectedIndex = 0);
    _navKey.currentState?.setPage(0);
  }

  @override
  Widget build(BuildContext context) {
    MicrosleepListener.start(context);

    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _navKey,
        index: _selectedIndex,
        height: 65,
        backgroundColor: Colors.transparent,
        color: const Color(0xFFB00000),
        buttonBackgroundColor: const Color(0xFFB00000),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        items: const [
          Icon(LucideIcons.layoutDashboard, size: 28, color: Colors.white),
          Icon(LucideIcons.mapPin, size: 28, color: Colors.white),
          Icon(LucideIcons.history, size: 28, color: Colors.white),
          Icon(LucideIcons.settings, size: 28, color: Colors.white),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
