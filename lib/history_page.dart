import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

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
              _searchAndSortBar(),
              const SizedBox(height: 24),
              _historyStream(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // 🔍 Pencarian + Sorting
  // ===========================================================
  Widget _searchAndSortBar() {
    return Container(
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
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _sortDesc
                    ? LucideIcons.arrowDownWideNarrow
                    : LucideIcons.arrowUpWideNarrow,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // 🔥 Ambil Data History
  // ===========================================================
  Widget _historyStream() {
    return StreamBuilder(
      stream:
          FirebaseDatabase.instance.ref('microsleep_history').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(
            child: Text(
              "Belum ada riwayat microsleep.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final data =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

        // Convert to list
        List<Map<String, dynamic>> historyList = data.values.map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();

        // Filter pencarian
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          historyList = historyList.where((item) {
            final lokasi = (item['lokasi'] ?? "").toLowerCase();
            final tanggal = (item['tanggal'] ?? "").toLowerCase();
            return lokasi.contains(query) || tanggal.contains(query);
          }).toList();
        }

        // Sort tanggal
        historyList.sort((a, b) {
          final dateA = "${a['tanggal']} ${a['jam']}";
          final dateB = "${b['tanggal']} ${b['jam']}";
          return _sortDesc
              ? dateB.compareTo(dateA)
              : dateA.compareTo(dateB);
        });

        // ===========================================================
        // 🧩 GROUPING BERDASARKAN BULAN & TAHUN
        // ===========================================================
        Map<String, List<Map<String, dynamic>>> grouped = {};

        for (var item in historyList) {
          String tanggal = item["tanggal"] ?? "";
          try {
            DateTime tgl = DateFormat("dd/MM/yyyy").parse(tanggal);
            String key = DateFormat("MMMM yyyy").format(tgl); // ex: November 2025

            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add(item);
          } catch (_) {}
        }

        // ===========================================================
        // 🎨 TAMPILKAN GROUP DALAM URUTAN
        // ===========================================================
        List<String> sortedKeys = grouped.keys.toList();

        sortedKeys.sort((a, b) {
          DateTime da = DateFormat("MMMM yyyy").parse(a);
          DateTime db = DateFormat("MMMM yyyy").parse(b);
          return _sortDesc ? db.compareTo(da) : da.compareTo(db);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedKeys.map((bulanKey) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Judul Bulan ===
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 8),
                  child: Text(
                    bulanKey,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // === List Card ===
                ...grouped[bulanKey]!.map((item) {
                  return _microsleepCard(
                    mainColor: mainColor,
                    waktu: item['jam'] ?? '-',
                    tanggal: item['tanggal'] ?? '-',
                    lokasi: item['lokasi'] ?? '-',
                    durasi: "${item['durasi']}s",
                    respons: "${item['respons']}s",
                  );
                }).toList(),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  // ===========================================================
  // 🔺 CARD ITEM
  // ===========================================================
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
          // 🔔 Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.alertTriangle, color: mainColor, size: 26),
          ),
          const SizedBox(width: 14),

          // 📄 Detail card
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Deteksi Microsleep",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: mainColor)),
                const SizedBox(height: 3),
                const Text("Mata tertutup selama 3 detik berturut turut",
                    style: TextStyle(color: Colors.black87, fontSize: 13)),
                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(LucideIcons.calendar,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(tanggal,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),

                    const SizedBox(width: 12),
                    const Icon(LucideIcons.mapPin,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        lokasi,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(LucideIcons.clock,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("Durasi: $durasi",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 12),

                    const Icon(LucideIcons.activity,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("Respons: $respons",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),

          // Jam kanan
          Text(
            waktu,
            style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
