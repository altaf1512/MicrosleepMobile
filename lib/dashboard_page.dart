import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'microsleep_call_overlay.dart';
import 'services/language_service.dart';
import 'l10n/generated/l10n.dart';

class DashboardPage extends StatefulWidget {
  final void Function(int)? onTabSelected;

  const DashboardPage({super.key, this.onTabSelected});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final mainColor = const Color(0xFFBA0403);
  final secondaryColor = const Color(0xFF0051D4);

  bool _isMicrosleep = false;
  int? _startTimeMillis;
  Position? _currentPosition;

  String currentTime = "--:--:--";
  String currentDate = "Loading...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initSetup();
  }

  Future<void> _initSetup() async {
    await initializeDateFormatting('id_ID', null);

    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());

    await _checkPermissionAndGetLocation();

    FirebaseDatabase.instance.ref('status').onValue.listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value as Map?;

      String user = data?["user"]?.toString().toLowerCase() ?? "normal";
      int? startMillis = data?["start_time"];

      bool nowMicrosleep = user == "microsleep";

      if (nowMicrosleep && !_isMicrosleep) {
        _startTimeMillis = startMillis;
        MicrosleepCallOverlay.show(context: context);
      } else if (!nowMicrosleep && _isMicrosleep) {
        _startTimeMillis = null;
        MicrosleepCallOverlay.hide();
      }

      setState(() {
        _isMicrosleep = nowMicrosleep;
        _startTimeMillis = startMillis;
      });
    });
  }

  Future<void> _checkPermissionAndGetLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      debugPrint("Lokasi gagal: $e");
    }
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final locale =
        Provider.of<LanguageService>(context, listen: false).currentLocale.languageCode;

    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(now);
      currentDate = DateFormat('d MMMM yyyy', locale).format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================================================
  // MAIN UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _heroHeader(),
              const SizedBox(height: 22),
              _iotStatus(),
              const SizedBox(height: 20),
              _travelStats(),
              const SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _alarmButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER + LANGUAGE BUTTON
  // =========================================================
  Widget _heroHeader() {
    final loc = S.of(context);

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Container(
            height: 185,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF001F4D),
                  const Color(0xFF003A8C),
                  mainColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: const DecorationImage(
                image: AssetImage('assets/gambar.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black38,
                  BlendMode.darken,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP BAR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        _languageButton(),
                        const SizedBox(width: 10),
                        _glassIcon(
                          LucideIcons.user,
                          onTap: () => widget.onTabSelected?.call(3),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  loc.welcomeDriver,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.monitoringSubtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // FLOATING CARD
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _statusSummaryCard(),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // LANGUAGE BUTTON
  // =========================================================
  Widget _languageButton() {
    final lang = Provider.of<LanguageService>(context);
    String code = lang.currentLocale.languageCode;

    return GestureDetector(
      onTap: _showLanguageSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          children: [
            Image.asset(
              code == "id" ? "assets/flag_id.png" : "assets/flag_us.png",
              width: 22,
            ),
            const SizedBox(width: 6),
            Text(
              code.toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LANGUAGE BOTTOM SHEET
  // =========================================================
  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final lang = Provider.of<LanguageService>(context);
        String code = lang.currentLocale.languageCode;

        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  height: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Pilih Bahasa",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),

              _languageTile(
                flag: "assets/flag_id.png",
                title: "Bahasa Indonesia",
                code: "id",
                active: code == "id",
                onTap: () {
                  lang.changeLanguage("id");
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),

              _languageTile(
                flag: "assets/flag_us.png",
                title: "English",
                code: "en",
                active: code == "en",
                onTap: () {
                  lang.changeLanguage("en");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile({
    required String flag,
    required String title,
    required String code,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.red.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset(flag, width: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16)),
            ),
            Icon(
              active ? Icons.radio_button_checked : Icons.radio_button_off,
              color: active ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // GLASS ICON
  // =========================================================
  Widget _glassIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white30),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // =========================================================
  // STATUS SUMMARY CARD
  // =========================================================
  Widget _statusSummaryCard() {
    final loc = S.of(context);

    final chipColor = _isMicrosleep ? Colors.red : Colors.green;
    final chipText = _isMicrosleep ? loc.microsleepDetected : loc.normalStatus;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(
              _isMicrosleep ? LucideIcons.alertOctagon : LucideIcons.shieldCheck,
              color: mainColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.appTitle,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentDate,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: chipColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            chipText,
                            style: TextStyle(
                              color: chipColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      loc.monitoringActive,
                      style: const TextStyle(color: Colors.black38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS PERANGKAT
  // =========================================================
  Widget _iotStatus() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: StreamBuilder(
          stream: FirebaseDatabase.instance.ref().onValue,
          builder: (context, snapshot) {
            String gps = "OFF";
            String iot = "off";
            int bat = 0;

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final data = snapshot.data!.snapshot.value as Map;
              gps = data["vehicle"]?["gps_status"]?.toString() ?? "OFF";
              iot = data["status"]?["iot"]?.toString() ?? "off";
              bat =
                  int.tryParse(data["status"]?["baterai"].toString() ?? "0") ?? 0;
            }

            return _iotContainer(gps, iot, bat);
          },
        ),
      );

  Widget _iotContainer(String gps, String iot, int bat) {
    final loc = S.of(context);

    Color gpsColor = gps == "ON" ? Colors.green : Colors.red;
    Color iotColor = iot == "on" ? Colors.green : Colors.red;
    Color batColor =
        bat < 30 ? Colors.red : bat < 60 ? Colors.orange : Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.deviceStatus,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusItem(
                icon: LucideIcons.cpu,
                label: loc.iotDevice,
                value: iot.toUpperCase(),
                color: iotColor,
              ),
              _statusItem(
                icon: LucideIcons.mapPin,
                label: loc.gps,
                value: gps.toUpperCase(),
                color: gpsColor,
              ),
              _statusItem(
                icon: LucideIcons.battery,
                label: loc.battery,
                value: "$bat%",
                color: batColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  // =========================================================
  // TRAVEL STATS
  // =========================================================
  Widget _travelStats() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: StreamBuilder(
          stream: FirebaseDatabase.instance.ref("status").onValue,
          builder: (context, snapshot) {
            String user = "normal";
            int? startMillis;

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final data = snapshot.data!.snapshot.value as Map;
              user = data["user"]?.toString() ?? "normal";
              startMillis = data["start_time"] as int?;
            }

            return _travelStatsContainer(user, startMillis);
          },
        ),
      );

  Widget _travelStatsContainer(String user, int? startMillis) {
    final loc = S.of(context);

    int durasi = 0;
    if (user == "microsleep" && startMillis != null) {
      durasi =
          ((DateTime.now().millisecondsSinceEpoch - startMillis) / 1000).floor();
    }

    final statusColor =
        user.toLowerCase() == "microsleep" ? Colors.red : Colors.green;

    return Row(
      children: [
        Expanded(
          child: _infoBox(
            icon: LucideIcons.clock,
            label: loc.microsleepDuration,
            value: "$durasi dtk",
            color: mainColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _infoBox(
            icon: user == "microsleep"
                ? LucideIcons.alertTriangle
                : LucideIcons.checkCircle,
            label: loc.driverStatus,
            value: user.toUpperCase(),
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  // =========================================================
  // ALARM BUTTON
  // =========================================================
  Widget _alarmButton() {
    final loc = S.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onAlarmPressed,
        icon: const Icon(LucideIcons.bellRing, color: Colors.white),
        label: Text(
          loc.turnOffAlarm,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 8,
          shadowColor: mainColor.withOpacity(0.35),
        ),
      ),
    );
  }

  Future<void> _onAlarmPressed() async {
    final dbStatus = FirebaseDatabase.instance.ref("status");
    final dbUser = FirebaseDatabase.instance.ref("status/user");
    final dbHistory = FirebaseDatabase.instance.ref("microsleep_history");
    final loc = S.of(context);

    final snap = await dbUser.get();
    if (!snap.exists || snap.value != "microsleep") return;

    final statusSnap = await dbStatus.get();
    int? startMillis = statusSnap.child("start_time").value as int?;

    await dbUser.set("normal");

    double durasi = 0;
    if (startMillis != null) {
      durasi = (DateTime.now().millisecondsSinceEpoch - startMillis) / 1000;
    }

    String tgl = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String jam = DateFormat('HH:mm:ss').format(DateTime.now());

    String lokasi = (_currentPosition != null)
        ? "Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, "
            "Lon: ${_currentPosition!.longitude.toStringAsFixed(5)}"
        : "Lokasi tidak tersedia";

    await dbHistory.push().set({
      "tanggal": tgl,
      "jam": jam,
      "durasi": durasi,
      "lokasi": lokasi,
      "status": "microsleep",
      "respons": durasi,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("🟢 ${loc.alarmStopped} (${durasi.toStringAsFixed(1)} detik)"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
