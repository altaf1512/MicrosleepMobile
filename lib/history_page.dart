import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

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
              // === Kolom Pencarian ===
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari berdasarkan lokasi...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon:
                              const Icon(LucideIcons.search, color: Colors.white),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        LucideIcons.slidersHorizontal,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // === Bagian November 2025 ===
              const Text(
                'November 2025',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              _microsleepCard(
                waktu: '14:30',
                tanggal: '23/10/2024',
                lokasi: 'Jl. Tol Jakarta–Cikampek',
                durasi: '3.2s',
                respons: '1.8s',
              ),
              _microsleepCard(
                waktu: '14:05',
                tanggal: '23/10/2024',
                lokasi: 'Jl. Tol Jakarta–Cikampek',
                durasi: '3.2s',
                respons: '1.8s',
              ),

              const SizedBox(height: 16),

              // === Bagian Oktober 2025 ===
              const Text(
                'Oktober 2025',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              _microsleepCard(
                waktu: '05:25',
                tanggal: '23/10/2024',
                lokasi: 'Jl. Tol Jakarta–Cikampek',
                durasi: '3.2s',
                respons: '1.8s',
              ),
              _microsleepCard(
                waktu: '05:25',
                tanggal: '23/10/2024',
                lokasi: 'Jl. Tol Jakarta–Cikampek',
                durasi: '3.2s',
                respons: '1.8s',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Widget Kartu Riwayat Microsleep ===
  Widget _microsleepCard({
    required String waktu,
    required String tanggal,
    required String lokasi,
    required String durasi,
    required String respons,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon kiri
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(LucideIcons.alertOctagon,
                color: Colors.red, size: 28),
          ),
          const SizedBox(width: 12),

          // Teks tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deteksi Microsleep',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Text(
                  'Mata tertutup selama 3 detik berturut-turut',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      tanggal,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    const Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lokasi,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Durasi: $durasi',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.activity, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Respons: $respons',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Waktu kanan
          Text(
            waktu,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
