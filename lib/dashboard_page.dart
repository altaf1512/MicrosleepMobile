import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

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

  Position? _currentPosition;
  String currentTime = "--:--:--";
  String currentDate = "Loading...";

  Timer? _timer;
  Timer? _microsleepTimer;

  @override
  void initState() {
    super.initState();
    _initSetup();

    // Timer untuk force rebuild durasi microsleep tiap 1 detik
    _microsleepTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _initSetup() async {
    await initializeDateFormatting('id_ID', null);

    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());

    await _checkPermissionAndGetLocation();
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
    } catch (_) {}
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
    _microsleepTimer?.cancel();
    super.dispose();
  }

  // =====================================================
  // MAIN UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 26),
          child: Column(
            children: [
              _heroHeader(),
              const SizedBox(height: 26),
              _iotStatus(),
              const SizedBox(height: 20),
              _travelStats(),
              const SizedBox(height: 28),
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

  // ======================================================
  // HEADER UI
  // ======================================================
  Widget _heroHeader() {
    final loc = S.of(context);

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Container(
            height: 195,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  mainColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              image: const DecorationImage(
                image: AssetImage("assets/gambar2.png"),
                fit: BoxFit.cover,
                opacity: 0.25,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 1.2,
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
                const SizedBox(height: 22),
                Text(
                  loc.welcomeDriver,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
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

  Widget _statusSummaryCard() {
    final loc = S.of(context);

    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref("status_user").onValue,
      builder: (context, snapshot) {
        String state = "normal";

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map;
          state = data["state"]?.toString() ?? "normal";
        }

        final isMicrosleep = state.toLowerCase() == "microsleep";
        final chipColor = isMicrosleep ? Colors.red : Colors.green;
        final chipText =
            isMicrosleep ? loc.microsleepDetected : loc.normalStatus;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isMicrosleep ? LucideIcons.alertTriangle : LucideIcons.shieldCheck,
                  color: mainColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.appTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: chipColor.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: chipColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                chipText,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: chipColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================================================
  // STATUS DEVICE
  // ======================================================
  Widget _iotStatus() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: StreamBuilder(
          stream: FirebaseDatabase.instance.ref("status").onValue,
          builder: (context, snapshot) {
            String gps = "OFF"; // tetap dibaca, meski tidak ditampilkan
            String iot = "off";
            int bat = 0;

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final data = snapshot.data!.snapshot.value as Map;
              gps = data["gps"]?.toString() ?? "OFF";
              iot = data["iot"]?.toString() ?? "off";
              bat = int.tryParse(data["baterai"]?.toString() ?? "0") ?? 0;
            }

            return _iotContainer(gps, iot, bat);
          },
        ),
      );

  // GPS DIHAPUS DARI UI, HANYA IOT + BATERAI
  Widget _iotContainer(String gps, String iot, int bat) {
    final loc = S.of(context);

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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statusItem(
            icon: LucideIcons.cpu,
            label: loc.iotDevice,
            value: iot.toUpperCase(),
            color: iotColor,
          ),
          _statusItem(
            icon: LucideIcons.battery,
            label: loc.battery,
            value: "$bat%",
            color: batColor,
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
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  // ======================================================
  // DURASI MICROSLEEP
  // ======================================================
  Widget _travelStats() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: StreamBuilder(
          stream: FirebaseDatabase.instance.ref("status_user").onValue,
          builder: (context, snapshot) {
            String state = "normal";
            int? startMillis;

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final data = snapshot.data!.snapshot.value as Map;

              final rawState = data["state"];
              if (rawState != null) {
                state = rawState.toString();
              }

              final ts = data["timestamp"];
              if (ts is int) {
                startMillis = ts;
              } else if (ts is double) {
                startMillis = ts.toInt();
              } else if (ts is String) {
                startMillis = int.tryParse(ts);
              }
            }

            return _travelStatsContainer(state, startMillis);
          },
        ),
      );

  Widget _travelStatsContainer(String state, int? startMillis) {
    final loc = S.of(context);

    int durasi = 0;
    final normalized = state.toLowerCase().trim();

    if (normalized == "microsleep" && startMillis != null && startMillis > 0) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs > startMillis) {
        durasi = ((nowMs - startMillis) / 1000).floor();
      }
    }

    final statusColor =
        normalized == "microsleep" ? Colors.red : Colors.green;

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
            icon: normalized == "microsleep"
                ? LucideIcons.alertTriangle
                : LucideIcons.checkCircle,
            label: loc.driverStatus,
            value: state.toUpperCase(),
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
      padding: const EdgeInsets.all(18),
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
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BUTTON STOP ALARM
  // ======================================================
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
          elevation: 10,
          shadowColor: mainColor.withOpacity(0.35),
        ),
      ),
    );
  }

  Future<void> _onAlarmPressed() async {
    final dbState = FirebaseDatabase.instance.ref("status_user/state");
    final dbTime = FirebaseDatabase.instance.ref("status_user/timestamp");
    final dbHistory = FirebaseDatabase.instance.ref("microsleep_history");

    final loc = S.of(context);

    final snap = await dbState.get();
    if (!snap.exists || snap.value.toString() != "microsleep") return;

    int? startMillis;
    final ts = (await dbTime.get()).value;
    if (ts is int) {
      startMillis = ts;
    } else if (ts is double) {
      startMillis = ts.toInt();
    } else if (ts is String) {
      startMillis = int.tryParse(ts);
    }

    await dbState.set("normal");

    double durasi = 0;
    if (startMillis != null && startMillis > 0) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs > startMillis) {
        durasi = (nowMs - startMillis) / 1000.0;
      }
    }

    await dbHistory.push().set({
      "tanggal": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "jam": DateFormat('HH:mm:ss').format(DateTime.now()),
      "durasi": durasi,
      "lokasi": (_currentPosition != null)
          ? "Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(5)}"
          : "Lokasi tidak tersedia",
      "status": "microsleep",
      "respons": durasi,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🟢 ${loc.alarmStopped} (${durasi.toStringAsFixed(1)} detik)"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ======================================================
  // LANGUAGE BUTTON
  // ======================================================
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
            children: [
              Container(
                width: 38,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
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
              const SizedBox(height: 12),

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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.red.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Image.asset(flag, width: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16)),
            ),
            Icon(
              active ? Icons.radio_button_checked : Icons.radio_button_off,
              color: active ? Colors.red : Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Widget _glassIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white30),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
