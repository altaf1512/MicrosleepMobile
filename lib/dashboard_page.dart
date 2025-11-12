import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:audioplayers/audioplayers.dart' as ap;


class DashboardPage extends StatefulWidget {
  final void Function(int)? onTabSelected;

  const DashboardPage({super.key, this.onTabSelected});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final mainColor = const Color(0xFFBA0403);
  final ap.AudioPlayer _player = ap.AudioPlayer();

  bool _isAlarmPlaying = false;

  late String currentTime;
  late String currentDate;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 🔹 Update waktu real-time
    initializeDateFormatting('id_ID', null).then((_) {
      _updateDateTime();
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updateDateTime(),
      );
    });

    // 🔥 Pantau perubahan status user dari Firebase
    FirebaseDatabase.instance.ref('status/user').onValue.listen((event) async {
      if (!mounted) return;
      final value = event.snapshot.value?.toString() ?? 'normal';

      if (value.toLowerCase() == 'microsleep' && !_isAlarmPlaying) {
        _isAlarmPlaying = true;

        // 🔊 Mainkan alarm berulang
        await _player.setReleaseMode(ap.ReleaseMode.loop);
        await _player.play(ap.AssetSource('sound/alarm.wav'));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⚠️ Deteksi Microsleep! Alarm menyala."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (value.toLowerCase() != 'microsleep' && _isAlarmPlaying) {
        // 🔇 Hentikan alarm
        await _player.stop();
        _isAlarmPlaying = false;
      }
    });
  }

  void _updateDateTime({bool useFallback = false}) {
    final now = DateTime.now();
    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(now);
      currentDate = useFallback
          ? DateFormat('d MMMM yyyy').format(now)
          : DateFormat('d MMMM yyyy', 'id_ID').format(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

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
              // === 🌅 Header ===
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBA0403), Color(0xFFE34234)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Selamat Datang, Pengemudi!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Pantau kondisi berkendara Anda",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.onTabSelected != null) {
                          widget.onTabSelected!(3);
                        }
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(LucideIcons.user, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // === 🕒 Waktu & tanggal ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.clock,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(currentTime,
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                  Text(currentDate,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),

              const SizedBox(height: 20),

              // === ⚙️ Status IoT + GPS + Baterai ===
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance.ref().onValue,
                  builder: (context, snapshot) {
                    String gpsStatus = "OFF";
                    String iotStatus = "off";
                    int batteryLevel = 0;

                    if (snapshot.hasData &&
                        snapshot.data?.snapshot.value != null) {
                      final data = snapshot.data!.snapshot.value as Map;
                      if (data["vehicle"] != null) {
                        gpsStatus =
                            data["vehicle"]["gps_status"]?.toString() ?? "OFF";
                      }
                      if (data["status"] != null) {
                        iotStatus = data["status"]["iot"]?.toString() ?? "off";
                        batteryLevel = int.tryParse(
                                data["status"]["baterai"].toString()) ??
                            0;
                      }
                    }

                    Color gpsColor = gpsStatus.toUpperCase() == "ON"
                        ? Colors.green
                        : Colors.red;
                    String gpsLabel = gpsStatus.toUpperCase() == "ON"
                        ? "Terhubung"
                        : "Tidak Terhubung";

                    Color iotColor = iotStatus.toLowerCase() == "on"
                        ? Colors.green
                        : Colors.red;
                    String iotLabel = iotStatus.toLowerCase() == "on"
                        ? "Terhubung"
                        : "Tidak Terhubung";

                    Color batteryColor;
                    if (batteryLevel < 30) {
                      batteryColor = Colors.red;
                    } else if (batteryLevel < 70) {
                      batteryColor = Colors.amber;
                    } else {
                      batteryColor = Colors.green;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statusItem(
                          icon: LucideIcons.cpu,
                          label: "Perangkat IoT",
                          value: iotLabel,
                          color: iotColor,
                        ),
                        _statusItem(
                          icon: LucideIcons.mapPin,
                          label: "GPS",
                          value: gpsLabel,
                          color: gpsColor,
                        ),
                        _statusItem(
                          icon: LucideIcons.battery,
                          label: "Baterai",
                          value: "$batteryLevel%",
                          color: batteryColor,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // === 📊 Statistik Perjalanan (Realtime) ===
              StreamBuilder(
                stream: FirebaseDatabase.instance.ref("status").onValue,
                builder: (context, snapshot) {
                  String waktu = "00:00:00";
                  String userStatus = "normal";

                  if (snapshot.hasData &&
                      snapshot.data?.snapshot.value != null) {
                    final data = snapshot.data!.snapshot.value as Map;
                    waktu = data["waktu"]?.toString() ?? "00:00:00";
                    userStatus = data["user"]?.toString() ?? "normal";
                  }

                  Color statusColor;
                  String statusLabel;
                  IconData iconStatus;

                  switch (userStatus.toLowerCase()) {
                    case "microsleep":
                      statusColor = Colors.red;
                      statusLabel = "Deteksi Microsleep";
                      iconStatus = LucideIcons.alertOctagon;
                      break;
                    case "alert":
                      statusColor = Colors.orange;
                      statusLabel = "Peringatan";
                      iconStatus = LucideIcons.alertTriangle;
                      break;
                    default:
                      statusColor = Colors.green;
                      statusLabel = "Normal";
                      iconStatus = LucideIcons.checkCircle;
                  }

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Statistik Perjalanan",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _infoBox(
                              icon: LucideIcons.clock,
                              label: "Durasi Sesi",
                              value: waktu.replaceAll('.', ':'),
                              color: mainColor,
                            ),
                            _infoBox(
                              icon: iconStatus,
                              label: statusLabel,
                              value: userStatus.toUpperCase(),
                              color: statusColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Skor Keamanan",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: userStatus == "microsleep"
                                    ? 0.3
                                    : userStatus == "alert"
                                        ? 0.6
                                        : 1.0,
                                color: userStatus == "microsleep"
                                    ? Colors.red
                                    : userStatus == "alert"
                                        ? Colors.orange
                                        : Colors.green,
                                backgroundColor: Colors.grey[300],
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                userStatus == "microsleep"
                                    ? "Bahaya!"
                                    : userStatus == "alert"
                                        ? "Waspada"
                                        : "Sangat Aman (100%)",
                                style: TextStyle(
                                    fontSize: 13, color: statusColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // === 🚨 Tombol Matikan Alarm ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final userRef =
                        FirebaseDatabase.instance.ref("status/user");
                    final snapshot = await userRef.get();

                    if (snapshot.exists && snapshot.value == "microsleep") {
                      await userRef.set("normal");
                      await _player.stop();
                      _isAlarmPlaying = false;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Alarm dimatikan — status kembali normal."),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(LucideIcons.bellRing, color: Colors.white),
                  label: const Text(
                    "Matikan Alarm / Monitoring",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
                    shadowColor: mainColor.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Helper Widgets ===
  Widget _statusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style:
              TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
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
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
