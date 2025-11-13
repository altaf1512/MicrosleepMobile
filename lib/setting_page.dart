import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'l10n/generated/l10n.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  int _selectedTab = 0;

  final userRef = FirebaseDatabase.instance.ref("users");
  final alarmRef = FirebaseDatabase.instance.ref("settings/alarm");

  String? nama;
  String? email;
  String? alamat;
  int? umur;

  bool suara = true;
  bool getar = true;
  bool lokasi = true;

  final mainColor = const Color(0xFFBA0403);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAlarmSettings();
  }

  Future<void> _loadUserData() async {
    final snapshot = await userRef.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    setState(() {
      nama = data["name"]?.toString();
      email = data["email"]?.toString();
      alamat = data["alamat"]?.toString();
      umur = int.tryParse(data["umur"].toString());
    });
  }

  Future<void> _loadAlarmSettings() async {
    final snapshot = await alarmRef.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    setState(() {
      suara = data["suara"] ?? true;
      getar = data["getar"] ?? true;
      lokasi = data["lokasi"] ?? true;
    });
  }

  Future<void> _updateAlarmSettings() async {
    await alarmRef.update({
      "suara": suara,
      "getar": getar,
      "lokasi": lokasi,
    });
  }

  Future<void> _updateUserData() async {
    await userRef.update({
      "name": nama ?? "-",
      "email": email ?? "-",
      "alamat": alamat ?? "-",
      "umur": umur ?? 0,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).profile_edit_success)),
      );
    }
  }

  void _showEditDialog(String label, String currentValue, Function(String) onSave) {
    final loc = S.of(context);
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${loc.edit_title} $label"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.edit_cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              _updateUserData();
            },
            child: Text(loc.edit_save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _tabHeader(loc),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTab == 0
                    ? _buildProfilTab(loc)
                    : _selectedTab == 1
                        ? _buildAlarmTab(loc)
                        : _buildStatistikTab(loc),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tabHeader(S loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _tabButton(LucideIcons.user, loc.settings_tab_profile, 0),
          _tabButton(LucideIcons.bell, loc.settings_tab_alarm, 1),
          _tabButton(LucideIcons.barChart2, loc.settings_tab_stats, 2),
        ],
      ),
    );
  }

  Widget _tabButton(IconData icon, String text, int index) {
    final active = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: active ? mainColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : mainColor),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== PROFIL ==========
  Widget _buildProfilTab(S loc) {
    if (nama == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      key: const ValueKey("profil"),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _profileCard(),
          const SizedBox(height: 20),
          _profileInfoCard(loc),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: mainColor,
            child: const Icon(LucideIcons.user, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama ?? "-", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(email ?? "-", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileInfoCard(S loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _editableInfoItem(loc.profile_name, nama ?? "-", (v) => nama = v),
          _editableInfoItem(loc.profile_email, email ?? "-", (v) => email = v),
          _editableInfoItem(loc.profile_address, alamat ?? "-", (v) => alamat = v),
          _editableInfoItem(loc.profile_age, umur?.toString() ?? "-", (v) => umur = int.tryParse(v) ?? 0),
        ],
      ),
    );
  }

  Widget _editableInfoItem(String label, String value, Function(String) onEdit) {
    return InkWell(
      onTap: () => _showEditDialog(label, value, onEdit),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Row(
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ========== ALARM ==========
  Widget _buildAlarmTab(S loc) {
    return SingleChildScrollView(
      key: const ValueKey("alarm"),
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            _switchItem(loc.alarm_sound, loc.alarm_sound_desc, suara, (v) {
              suara = v;
              setState(() {});
              _updateAlarmSettings();
            }),
            _switchItem(loc.alarm_vibration, loc.alarm_vibration_desc, getar, (v) {
              getar = v;
              setState(() {});
              _updateAlarmSettings();
            }),
            _switchItem(loc.alarm_tracking, loc.alarm_tracking_desc, lokasi, (v) {
              lokasi = v;
              setState(() {});
              _updateAlarmSettings();
            }),
          ],
        ),
      ),
    );
  }

  Widget _switchItem(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(LucideIcons.bell, color: mainColor),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ]),
          Switch(
            value: value,
            activeColor: mainColor,
            onChanged: onChanged,
          )
        ],
      ),
    );
  }

  // ========== STATISTIK ==========
  Widget _buildStatistikTab(S loc) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref().onValue,
      builder: (context, snapshot) {
        int totalInsiden = 0;
        int streakBebasInsiden = 0;
        double peningkatanBulanIni = 0;
        String totalJamMonitoring = "0";

        if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
          final data = snapshot.data!.snapshot.value as Map;

          totalJamMonitoring = data["status"]?["waktu"]?.toString() ?? "0";

          if (data["microsleep_history"] != null) {
            final history = Map<String, dynamic>.from(data["microsleep_history"] as Map);

            totalInsiden = history.length;
            streakBebasInsiden = _hitungStreak(history);
            peningkatanBulanIni = _hitungPeningkatan(history);
          }
        }

        return SingleChildScrollView(
          key: const ValueKey("statistik"),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.stats_title,
                  style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(loc.stats_subtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _statCard(
                    icon: LucideIcons.clock,
                    value: totalJamMonitoring,
                    label: loc.stats_total_hours,
                    color: Colors.red[50],
                  ),
                  _statCard(
                    icon: LucideIcons.trendingUp,
                    value: "$streakBebasInsiden",
                    label: loc.stats_safe_days,
                    color: Colors.green[50],
                  ),
                  _statCard(
                    icon: LucideIcons.alertTriangle,
                    value: "$totalInsiden",
                    label: loc.stats_total_incidents,
                    color: Colors.orange[50],
                  ),
                  _statCard(
                    icon: LucideIcons.activity,
                    value: "${peningkatanBulanIni.toStringAsFixed(0)}%",
                    label: loc.stats_monthly_improvement,
                    color: Colors.teal[50],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  int _hitungStreak(Map history) {
    final today = DateTime.now();
    int streak = 0;

    final tanggalList = history.values.map((e) {
      try {
        return DateFormat("dd/MM/yyyy").parse(e["tanggal"]);
      } catch (_) {
        return null;
      }
    }).whereType<DateTime>().toList();

    tanggalList.sort((a, b) => b.compareTo(a));

    for (int i = 0; i < tanggalList.length; i++) {
      final h = tanggalList[i];
      final diff = today.difference(h).inDays;

      if (diff == streak + 1) {
        streak++;
      } else if (diff > streak + 1) {
        break;
      }
    }

    return streak;
  }

  double _hitungPeningkatan(Map history) {
    int bulanIni = 0;
    int bulanLalu = 0;
    final now = DateTime.now();

    for (var item in history.values) {
      if (item["tanggal"] == null) continue;

      try {
        final tgl = DateFormat("dd/MM/yyyy").parse(item["tanggal"]);
        if (tgl.month == now.month && tgl.year == now.year) {
          bulanIni++;
        } else if (tgl.month == now.month - 1 && tgl.year == now.year) {
          bulanLalu++;
        }
      } catch (_) {}
    }

    if (bulanLalu == 0) {
      return bulanIni > 0 ? 100 : 0;
    }
    return ((bulanIni - bulanLalu) / bulanLalu) * 100;
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: mainColor, size: 24),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}
