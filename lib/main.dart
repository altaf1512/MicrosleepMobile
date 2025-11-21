import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// services
import 'services/language_service.dart';
import 'services/microsleep_listener.dart';
import 'services/notification_service.dart';

// localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/l10n.dart';

// pages
import 'splash_screen.dart';
import 'dashboard_page.dart';
import 'history_page.dart';
import 'location_page.dart';
import 'setting_page.dart';

/// =======================================================
/// GLOBAL KEY — digunakan overlay dan alarm untuk pindah tab
/// =======================================================
final GlobalKey<MainNavigationState> mainNavKey =
    GlobalKey<MainNavigationState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init Notification
  await NotificationService.initialize();

  // Init Bahasa
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

      // **Fixed: hilangkan label Microsleep Guard**
      title: '',

      locale: lang.currentLocale,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
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

/// =======================================================
/// NAVIGASI BAWAH (Curved Navigation Bar)
/// =======================================================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final _navKey = GlobalKey<CurvedNavigationBarState>();

  late final List<Widget> _pages;

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

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
    _navKey.currentState?.setPage(index);
  }

  /// Dipanggil overlay alarm → kembali ke Dashboard
  void switchToDashboard() {
    setState(() => _selectedIndex = 0);
    _navKey.currentState?.setPage(0);
  }

  @override
  Widget build(BuildContext context) {
    // Listener Firebase microsleep (jalan di seluruh app)
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
        items: const [
          Icon(LucideIcons.layoutDashboard, size: 28, color: Colors.white),
          Icon(LucideIcons.mapPin, size: 28, color: Colors.white),
          Icon(LucideIcons.history, size: 28, color: Colors.white),
          Icon(LucideIcons.settings, size: 28, color: Colors.white),
        ],
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
