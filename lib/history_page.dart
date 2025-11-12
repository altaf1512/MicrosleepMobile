import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final mainColor = const Color(0xFFBA0403);
  String _searchQuery = "";
  bool _sortDesc = true; // true = terbaru dulu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 Pencarian + Urutkan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Cari lokasi atau tanggal...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _sortDesc = !_sortDesc);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_sortDesc
                                ? "Diurutkan: Terbaru dulu"
                                : "Diurutkan: Terlama dulu"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          _sortDesc
                              ? LucideIcons.arrowDownWideNarrow
                              : LucideIcons.arrowUpWideNarrow,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),
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

                  // Ubah ke list
                  List<Map<String, dynamic>> historyList = data.entries.map((e) {
                    final item = Map<String, dynamic>.from(e.value);
                    return item;
                  }).toList();

                  // 🔍 Filter berdasarkan pencarian
                  if (_searchQuery.isNotEmpty) {
                    historyList = historyList.where((item) {
                      final lokasi = (item['lokasi'] ?? '').toString().toLowerCase();
                      final tanggal = (item['tanggal'] ?? '').toString().toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return lokasi.contains(query) || tanggal.contains(query);
                    }).toList();
                  }

                  // 🔃 Urutkan berdasarkan tanggal dan jam
                  historyList.sort((a, b) {
                    String dateA = "${a['tanggal'] ?? ''} ${a['jam'] ?? ''}";
                    String dateB = "${b['tanggal'] ?? ''} ${b['jam'] ?? ''}";
                    return _sortDesc
                        ? dateB.compareTo(dateA)
                        : dateA.compareTo(dateB);
                  });

                  // 🧾 Tampilkan list
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    const Icon(LucideIcons.mapPin,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lokasi,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.activity,
                        size: 14, color: Colors.grey),
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
