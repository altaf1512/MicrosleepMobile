import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardPage extends StatelessWidget {
  final void Function(int)? onTabSelected; // ✅ callback untuk ganti tab navbar

  const DashboardPage({super.key, this.onTabSelected});

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
              // === Header ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selamat datang!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  // ✅ Klik profil untuk pindah ke tab Pengaturan
                  GestureDetector(
                    onTap: () {
                      if (onTabSelected != null) {
                        onTabSelected!(3); // Tab index ke-3 = Pengaturan
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.red[100],
                      child: const Icon(LucideIcons.user, color: Colors.red),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 16),
                      SizedBox(width: 6),
                      Text('14:16:09'),
                    ],
                  ),
                  Text('3 November 2025'),
                ],
              ),

              const SizedBox(height: 16),

              // === Status Card ===
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusItem(
                        icon: LucideIcons.cpu,
                        label: 'Perangkat IoT',
                        value: 'Terhubung',
                        color: Colors.green),
                    _statusItem(
                        icon: LucideIcons.mapPin,
                        label: 'GPS',
                        value: 'Tidak Terhubung',
                        color: Colors.red),
                    _statusItem(
                        icon: LucideIcons.battery,
                        label: 'Baterai',
                        value: '85%',
                        color: Colors.black87),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // === Statistik Perjalanan ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistik Perjalanan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoBox(
                            icon: LucideIcons.clock,
                            label: 'Durasi Sesi',
                            value: '00:01:17'),
                        _infoBox(
                            icon: LucideIcons.alertTriangle,
                            label: 'Peringatan',
                            value: '0'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Skor Keamanan'),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: 1.0,
                            color: Colors.green,
                            backgroundColor: Colors.grey[300],
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sangat Aman (100%)',
                            style: TextStyle(
                                fontSize: 13, color: Colors.green),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // === Tombol Alarm ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 😂 Saat ditekan, tampilkan gambar monyet 1 layar
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FullscreenMonkeyPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Matikan Alarm/Monitoring',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // === Ringkasan Peringatan ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Ringkasan Peringatan Terbaru',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        Text(
                          'Lihat Detail',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(LucideIcons.alertOctagon, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deteksi Microsleep',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Mata tertutup selama 3 detik berturut-turut',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '17m lalu',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Helper ---
  Widget _statusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class FullscreenMonkeyPage extends StatelessWidget {
  const FullscreenMonkeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // Klik di mana saja untuk keluar
        onTap: () => Navigator.pop(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/monyet.jpeg",
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: const Text(
                "....",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 8, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

