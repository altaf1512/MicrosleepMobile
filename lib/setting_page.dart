import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  int _selectedTab = 0;

  // Firebase references
  final DatabaseReference userRef = FirebaseDatabase.instance.ref("users");
  final DatabaseReference alarmRef = FirebaseDatabase.instance.ref("settings/alarm");

  // User data
  String? nama;
  String? email;
  String? alamat;
  int? umur;

  // Alarm settings
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

  // =====================================================
  // 🔥 Ambil data USER dari Firebase
  // =====================================================
  Future<void> _loadUserData() async {
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        nama = data["name"]?.toString();
        email = data["email"]?.toString();
        alamat = data["alamat"]?.toString();
        umur = int.tryParse(data["umur"].toString());
      });
    } else {
      debugPrint("❌ Data user tidak ditemukan di Firebase");
    }
  }

  // =====================================================
  // 🔔 Ambil dan Simpan Setting Alarm
  // =====================================================
  Future<void> _loadAlarmSettings() async {
    final snapshot = await alarmRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        suara = data["suara"] ?? true;
        getar = data["getar"] ?? true;
        lokasi = data["lokasi"] ?? true;
      });
    }
  }

  Future<void> _updateAlarmSettings() async {
    await alarmRef.set({
      "suara": suara,
      "getar": getar,
      "lokasi": lokasi,
    });
    debugPrint("✅ Pengaturan alarm diperbarui ke Firebase");
  }

  // =====================================================
  // ✏️ Simpan perubahan profil ke Firebase
  // =====================================================
  Future<void> _updateUserData() async {
    await userRef.update({
      "name": nama ?? "-",
      "email": email ?? "-",
      "alamat": alamat ?? "-",
      "umur": umur ?? 0,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Data pengguna berhasil diperbarui")),
      );
    }
  }

  // =====================================================
  // ✏️ Dialog Edit Data
  // =====================================================
  void _showEditDialog(String label, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: "Masukkan $label baru",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              _updateUserData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 🔹 UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // === Header Tab ===
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _tabButton(icon: LucideIcons.user, text: "Profil", index: 0),
                  _tabButton(icon: LucideIcons.bell, text: "Alarm", index: 1),
                  _tabButton(icon: LucideIcons.barChart2, text: "Statistik", index: 2),
                ],
              ),
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTab == 0
                    ? _buildProfilTab()
                    : _selectedTab == 1
                        ? _buildAlarmTab()
                        : _buildStatistikTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required IconData icon,
    required String text,
    required int index,
  }) {
    bool active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon,
                  color: active ? mainColor : Colors.grey[600], size: 20),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                    color: active ? mainColor : Colors.grey[700],
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            width: 100,
            color: active ? mainColor : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 👤 TAB PROFIL
  // =====================================================
  Widget _buildProfilTab() {
    return nama == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            key: const ValueKey('profil'),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: mainColor,
                        child: const Icon(LucideIcons.user,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nama ?? "-",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(email ?? "-",
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Informasi Pengguna",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      _editableInfoItem("Nama", nama ?? "-", (v) {
                        setState(() => nama = v);
                      }),
                      _editableInfoItem("Email", email ?? "-", (v) {
                        setState(() => email = v);
                      }),
                      _editableInfoItem("Alamat", alamat ?? "-", (v) {
                        setState(() => alamat = v);
                      }),
                      _editableInfoItem("Umur", umur?.toString() ?? "-", (v) {
                        setState(() => umur = int.tryParse(v) ?? 0);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _editableInfoItem(String label, String value, Function(String) onEdit) {
    return InkWell(
      onTap: () => _showEditDialog(label, value, onEdit),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 6),
                const Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // 🔔 TAB ALARM
  // =====================================================
  Widget _buildAlarmTab() {
    return SingleChildScrollView(
      key: const ValueKey('alarm'),
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pengaturan Alarm",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            _switchItem("Suara Peringatan", "Alarm darurat aktif", suara, (v) {
              setState(() => suara = v);
              _updateAlarmSettings();
            }),
            _switchItem("Getaran", "Aktif saat mengantuk", getar, (v) {
              setState(() => getar = v);
              _updateAlarmSettings();
            }),
            _switchItem("Pelacakan Lokasi", "Untuk rekomendasi rest area", lokasi, (v) {
              setState(() => lokasi = v);
              _updateAlarmSettings();
            }),
          ],
        ),
      ),
    );
  }

  Widget _switchItem(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(LucideIcons.bell, color: mainColor),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ]),
          Switch(
            value: value,
            activeColor: mainColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 📊 TAB STATISTIK (dummy)
  // =====================================================
  Widget _buildStatistikTab() {
    return SingleChildScrollView(
      key: const ValueKey('statistik'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Statistik Berkendara",
              style: TextStyle(
                  color: Color(0xFFBA0403),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const Text("Pantau kemajuan keamanan Anda",
              style: TextStyle(color: Colors.grey)),
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
                  value: "1247",
                  label: "Jam Monitoring",
                  color: Colors.red[50]),
              _statCard(
                  icon: LucideIcons.trendingUp,
                  value: "15",
                  label: "Hari Aman",
                  color: Colors.green[50]),
              _statCard(
                  icon: LucideIcons.alertTriangle,
                  value: "12",
                  label: "Insiden",
                  color: Colors.orange[50]),
              _statCard(
                  icon: LucideIcons.activity,
                  value: "15%",
                  label: "Peningkatan Bulan Ini",
                  color: Colors.teal[50]),
            ],
          ),
        ],
      ),
    );
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
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}
