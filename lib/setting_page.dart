import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  int _selectedTab = 0;

  // Firebase data
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
  }

  // =====================================================
  // 🔥 Ambil data dari Firebase Realtime Database
  // =====================================================
  Future<void> _loadUserData() async {
    final ref = FirebaseDatabase.instance.ref("users");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        nama = data["name"]?.toString();
        email = data["email"]?.toString();
        alamat = data["alamat"]?.toString();
        umur = data["umur"] is int
            ? data["umur"]
            : int.tryParse(data["umur"].toString());
      });
    } else {
      debugPrint("❌ Data tidak ditemukan di Firebase");
    }
  }

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

            // === Logout Button ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: ElevatedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // 🔹 Tab Button UI
  // =====================================================
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
  // 👤 TAB PROFIL — ambil dari Firebase
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
                      _infoItem("Nama", nama ?? "-"),
                      _infoItem("Email", email ?? "-"),
                      _infoItem("Alamat", alamat ?? "-"),
                      _infoItem("Umur", umur?.toString() ?? "-"),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  // =====================================================
  // 🔔 TAB ALARM SETTING
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
            _switchItem("Suara Peringatan", "Alarm darurat aktif", suara,
                (v) => setState(() => suara = v)),
            _switchItem("Getaran", "Aktif saat mengantuk", getar,
                (v) => setState(() => getar = v)),
            _switchItem("Pelacakan Lokasi", "Untuk rekomendasi rest area", lokasi,
                (v) => setState(() => lokasi = v)),
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
  // 📊 TAB STATISTIK
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

  // =====================================================
  // 🔒 Dialog Logout
  // =====================================================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Konfirmasi Logout",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: mainColor),
            child:
                const Text("Ya, Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
