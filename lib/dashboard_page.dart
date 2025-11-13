import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'microsleep_call_overlay.dart';

class DashboardPage extends StatefulWidget {
  final void Function(int)? onTabSelected;

  const DashboardPage({super.key, this.onTabSelected});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final mainColor = const Color(0xFFBA0403);

  bool _isMicrosleep = false;
  int? _startTimeMillis; // FIX: ambil dari Firebase
  Position? _currentPosition;

  String currentTime = "--:--:--";
  String currentDate = "Memuat...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initSetup();
  }

  // =========================================================
  // INIT AWAL
  // =========================================================
  Future<void> _initSetup() async {
    await initializeDateFormatting('id_ID', null);

    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());

    await _checkPermissionAndGetLocation();

    // Listener status microsleep
    FirebaseDatabase.instance.ref('status').onValue.listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value as Map?;

      String user = data?["user"]?.toString().toLowerCase() ?? "normal";
      int? startMillis = data?["start_time"];

      bool nowMicrosleep = user == "microsleep";

      if (nowMicrosleep && !_isMicrosleep) {
        // Microsleep baru mulai
        _startTimeMillis = startMillis; // FIX
        MicrosleepCallOverlay.show(context: context);
      } 
        
      else if (!nowMicrosleep && _isMicrosleep) {
        // Microsleep selesai
        _startTimeMillis = null;
        MicrosleepCallOverlay.hide();
      }

      setState(() {
        _isMicrosleep = nowMicrosleep;
        _startTimeMillis = startMillis;
      });
    });
  }

  // =========================================================
  // GPS
  // =========================================================
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
      debugPrint("❌ Lokasi gagal: $e");
    }
  }

  // =========================================================
  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(now);
      currentDate = DateFormat('d MMMM yyyy', 'id_ID').format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerSection(),
              const SizedBox(height: 20),
              _timeDisplay(),
              const SizedBox(height: 20),
              _iotStatus(),
              const SizedBox(height: 20),
              _travelStats(),
              const SizedBox(height: 24),
              _alarmButton(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================
  Widget _headerSection() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFBA0403), Color(0xFFE34234)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Selamat Datang, Pengemudi!",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 4),
                Text("Pantau kondisi berkendara Anda",
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white38,
              child: Icon(LucideIcons.user, color: Colors.white),
            ),
          ],
        ),
      );

  Widget _timeDisplay() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Text(currentTime, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          Text(currentDate, style: const TextStyle(color: Colors.black54)),
        ],
      );

  // =========================================================
  // IOT STATUS
  // =========================================================
  Widget _iotStatus() => StreamBuilder(
        stream: FirebaseDatabase.instance.ref().onValue,
        builder: (context, snapshot) {
          String gps = "OFF";
          String iot = "off";
          int bat = 0;

          if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map;

            gps = data["vehicle"]?["gps_status"] ?? "OFF";
            iot = data["status"]?["iot"] ?? "off";
            bat = int.tryParse(data["status"]?["baterai"].toString() ?? "0") ?? 0;
          }

          return _iotContainer(gps, iot, bat);
        },
      );

  Widget _iotContainer(String gps, String iot, int bat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statusItem(icon: LucideIcons.cpu, label: "IoT", value: iot.toUpperCase(), color: iot == "on" ? Colors.green : Colors.red),
          _statusItem(icon: LucideIcons.mapPin, label: "GPS", value: gps.toUpperCase(), color: gps == "ON" ? Colors.green : Colors.red),
          _statusItem(icon: LucideIcons.battery, label: "Baterai", value: "$bat%", color: bat < 30 ? Colors.red : bat < 60 ? Colors.orange : Colors.green),
        ],
      ),
    );
  }

  Widget _statusItem({required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        Text(label),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // =========================================================
  // STATISTIK PERJALANAN
  // =========================================================
  Widget _travelStats() => StreamBuilder(
        stream: FirebaseDatabase.instance.ref("status").onValue,
        builder: (context, snapshot) {
          String user = "normal";
          int? startMillis;

          if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
            final data = snapshot.data!.snapshot.value as Map;
            user = data["user"] ?? "normal";
            startMillis = data["start_time"];
          }

          return _travelStatsContainer(user, startMillis);
        },
      );

  Widget _travelStatsContainer(String user, int? startMillis) {
    int durasi = 0;

    if (user == "microsleep" && startMillis != null) {
      durasi = ((DateTime.now().millisecondsSinceEpoch - startMillis) / 1000).floor();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoBox(icon: LucideIcons.clock, label: "Durasi", value: "$durasi dtk", color: mainColor),
          _infoBox(
            icon: user == "microsleep" ? LucideIcons.alertTriangle : LucideIcons.checkCircle,
            label: "Status",
            value: user.toUpperCase(),
            color: user == "microsleep" ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _infoBox({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }

  // =========================================================
  // BUTTON "MATIKAN ALARM"
  // =========================================================
  Widget _alarmButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final dbStatus = FirebaseDatabase.instance.ref("status");
            final dbUser = FirebaseDatabase.instance.ref("status/user");
            final dbHistory = FirebaseDatabase.instance.ref("microsleep_history");

            final snap = await dbUser.get();
            if (!snap.exists || snap.value != "microsleep") return;

            // ambil waktu mulai dari firebase
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
                ? "Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(5)}"
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
                  content: Text("🟢 Alarm dimatikan (${durasi.toStringAsFixed(1)} detik)"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          icon: const Icon(LucideIcons.bellRing, color: Colors.white),
          label: const Text("Matikan Alarm / Simpan Riwayat",
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}
