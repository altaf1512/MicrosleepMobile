import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'login_page.dart'; // ✅ untuk navigasi kembali ke halaman login

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  int _selectedTab = 0; // 0 = Profil, 1 = Statistik
  bool suara = true;
  bool getar = true;
  bool lokasi = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // === Header Tab Hitam ===
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _tabButton(icon: LucideIcons.user, text: 'Profil', index: 0),
                    _tabButton(icon: LucideIcons.barChart2, text: 'Statistik', index: 1),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _selectedTab == 0 ? _buildProfilTab() : _buildStatistikTab(),

              const SizedBox(height: 24),

              // === Tombol Logout di bawah ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showLogoutDialog, // ✅ fungsi konfirmasi logout
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================================
  // 🔸 KONFIRMASI LOGOUT
  // ================================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Anda yakin ingin logout dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog dulu
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================================
  // TAB BUTTON
  // ================================
  Widget _tabButton({required IconData icon, required String text, required int index}) {
    bool active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 100,
            color: active ? Colors.red : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ================================
  // TAB PROFIL
  // ================================
  Widget _buildProfilTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Profil Header ===
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.red,
                  child: Icon(LucideIcons.user, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Steven Hakim',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('ID: 11233445566', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Skor Keamanan: ',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                Container(
                                  height: 8,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('87.5/100',
                              style: TextStyle(fontSize: 12, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // === Informasi Pribadi ===
          _infoSection(
            title: 'Informasi Pribadi',
            children: [
              _infoItem('Nama Lengkap', 'Steven Hakim'),
              _infoItem('Umur', '40'),
              _infoItem('Kondisi Medis', 'Sleep apnea ringan'),
              _infoItem('Kontak Darurat', 'Stevani - +62 896 2832 1429'),
            ],
          ),

          const SizedBox(height: 16),

          // === Preferensi Peringatan ===
          _preferenceSection(),
        ],
      ),
    );
  }

  Widget _infoSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ]),
          const Text('Edit', style: TextStyle(color: Colors.red, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _preferenceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferensi Peringatan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),

          _switchItem('Suara Peringatan', 'Alarm Darurat', suara, (v) {
            setState(() => suara = v);
          }),
          _switchItem('Getaran', 'Pola getaran untuk peringatan', getar, (v) {
            setState(() => getar = v);
          }),
          _switchItem('Waktu Eskalasi', '30 detik', true, (_) {}),
          _switchItem('Pelacakan Lokasi', 'untuk pencarian rest area', lokasi, (v) {
            setState(() => lokasi = v);
          }),
        ],
      ),
    );
  }

  Widget _switchItem(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const Icon(LucideIcons.alertCircle, color: Colors.red),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ]),
          Switch(
            value: value,
            activeColor: Colors.red,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ================================
  // TAB STATISTIK
  // ================================
  Widget _buildStatistikTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Berkendara',
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
          const Text(
            'Pantau kemajuan keamanan berkendara Anda',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // === Grid Statistik ===
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _statCard(
                color: Colors.red[50],
                icon: LucideIcons.clock,
                value: '1247',
                unit: 'jam',
                label: 'Total Jam Monitoring',
              ),
              _statCard(
                color: Colors.green[50],
                icon: LucideIcons.trendingUp,
                value: '15',
                unit: 'hari',
                label: 'Streak Bebas Insiden',
              ),
              _statCard(
                color: Colors.orange[50],
                icon: LucideIcons.alertTriangle,
                value: '12',
                unit: 'Kali',
                label: 'Total Insiden',
              ),
              _statCard(
                color: Colors.teal[50],
                icon: LucideIcons.activity,
                value: '15%',
                unit: '',
                label: 'Peningkatan Bulan Ini',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required Color? color,
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(width: 4),
              Text(unit,
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}
