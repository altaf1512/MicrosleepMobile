import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import 'l10n/generated/l10n.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final mainColor = const Color(0xFFBA0403);

  String _searchQuery = "";
  bool _sortDesc = true;

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchBar(loc),
              const SizedBox(height: 20),
              _historyStream(loc),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // SEARCH BAR POLISHED
  // ===========================================================
  Widget _searchBar(S loc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search, color: Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: loc.history_search_hint,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _sortDesc = !_sortDesc),
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
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // FIREBASE STREAM — POLISHED LAYOUT
  // ===========================================================
  Widget _historyStream(S loc) {
    final locale = Localizations.localeOf(context).languageCode;

    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref("microsleep_history").onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                loc.history_no_data,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final raw =
            Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

        List<Map<String, dynamic>> items = raw.values.map((value) {
          return Map<String, dynamic>.from(value);
        }).toList();

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          items = items.where((e) {
            return e['lokasi'].toString().toLowerCase().contains(q) ||
                e['tanggal'].toString().toLowerCase().contains(q);
          }).toList();
        }

        // Sorting
        items.sort((a, b) {
          final tA = "${a['tanggal']} ${a['jam']}";
          final tB = "${b['tanggal']} ${b['jam']}";
          return _sortDesc ? tB.compareTo(tA) : tA.compareTo(tB);
        });

        // Group By Month
        Map<String, List<Map<String, dynamic>>> monthGroups = {};

        for (var x in items) {
          try {
            DateTime d = DateFormat("dd/MM/yyyy").parse(x["tanggal"]);
            final monthTitle = DateFormat("MMMM yyyy", locale).format(d);

            monthGroups.putIfAbsent(monthTitle, () => []);
            monthGroups[monthTitle]!.add(x);
          } catch (_) {}
        }

        // Sorted keys
        final monthKeys = monthGroups.keys.toList()
          ..sort((a, b) {
            DateTime da = DateFormat("MMMM yyyy", locale).parse(a);
            DateTime db = DateFormat("MMMM yyyy", locale).parse(b);
            return _sortDesc ? db.compareTo(da) : da.compareTo(db);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: monthKeys.map((month) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month title
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 10),
                  child: Text(
                    month,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Each item
                ...monthGroups[month]!.map((item) {
                  return _historyCard(
                    loc: loc,
                    waktu: item["jam"],
                    tanggal: item["tanggal"],
                    lokasi: item["lokasi"],
                    durasi: "${item['durasi']}s",
                    respons: "${item['respons']}s",
                  );
                }),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  // ===========================================================
  // HISTORY CARD — POLISHED MATERIAL DESIGN 3
  // ===========================================================
  Widget _historyCard({
    required S loc,
    required String waktu,
    required String tanggal,
    required String lokasi,
    required String durasi,
    required String respons,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mainColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.alertTriangle,
              color: mainColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.microsleepDetected,
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  loc.alarmInstruction,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.75),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(tanggal, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        lokasi,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text("${loc.history_duration}: $durasi",
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),

                    const SizedBox(width: 14),

                    Icon(LucideIcons.activity, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text("${loc.history_response}: $respons",
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),

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
