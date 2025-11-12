import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFBA0403);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 Pencarian
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari berdasarkan lokasi...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        LucideIcons.slidersHorizontal,
                        color: Colors.black87,
                        size: 20,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔥 StreamBuilder Firebase
              StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref('microsleep_history')
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return const Center(
                      child: Text(
                        "Belum ada riwayat microsleep.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final data = Map<String, dynamic>.from(
                      snapshot.data!.snapshot.value as Map);

                  // Ubah ke list & urutkan berdasarkan tanggal/jam (terbaru di atas)
                  final historyList = data.entries.map((e) {
                    final item = Map<String, dynamic>.from(e.value);
                    return item;
                  }).toList()
                    ..sort((a, b) => b['tanggal']
                        .toString()
                        .compareTo(a['tanggal'].toString()));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: historyList.map((item) {
                      return _microsleepCard(
                        mainColor: mainColor,
                        waktu: item['jam'] ?? '-',
                        tanggal: item['tanggal'] ?? '-',
                        lokasi: item['lokasi'] ?? '-',
                        durasi: "${item['durasi']}s",
                        respons: "${item['respons']}s",
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Kartu Riwayat Microsleep ===
  Widget _microsleepCard({
    required String waktu,
    required String tanggal,
    required String lokasi,
    required String durasi,
    required String respons,
    required Color mainColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: mainColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔔 Ikon kiri
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.alertTriangle, color: mainColor, size: 26),
          ),
          const SizedBox(width: 14),

          // 📄 Detail teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deteksi Microsleep',
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Mata tertutup selama 3 detik berturut-turut',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      tanggal,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    const Icon(LucideIcons.mapPin,
                        size: 14, color: Colors.grey),
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(LucideIcons.clock,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Durasi: $durasi',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.activity,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Respons: $respons',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🕓 Waktu kanan atas
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
