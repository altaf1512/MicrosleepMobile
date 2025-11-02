import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(-8.1726, 113.6995);
  final mainColor = const Color(0xFFBA0403);
  final secondaryColor = const Color(0xFFE34234);

  bool _isMapView = true; // 🔁 toggle antara peta dan daftar

  final List<Map<String, String>> _restAreas = [
    {
      "name": "Rest Area Terdekat",
      "type": "Rest Area Tol",
      "distance": "2.5 km",
      "image":
          "https://images.unsplash.com/photo-1689181482780-a6fe3c7b137f",
    },
    {
      "name": "Rest Area Tol Jember 2",
      "type": "Rest Area Tol",
      "distance": "5 km",
      "image":
          "https://images.unsplash.com/photo-1638270387990-32897e903002",
    },
  ];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // === 🔍 Search bar ===
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(LucideIcons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari rest area...',
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ),
                    ),
                    const Icon(LucideIcons.slidersHorizontal,
                        color: Colors.grey),
                  ],
                ),
              ),
            ),

            // === Toggle buttons (Peta / Daftar) ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _isMapView = true),
                      icon: Icon(
                        LucideIcons.map,
                        color: _isMapView ? Colors.white : mainColor,
                      ),
                      label: Text(
                        'Peta',
                        style: TextStyle(
                          color: _isMapView ? Colors.white : mainColor,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isMapView ? mainColor : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: mainColor),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _isMapView = false),
                      icon: Icon(
                        LucideIcons.list,
                        color: !_isMapView ? Colors.white : mainColor,
                      ),
                      label: Text(
                        'Daftar',
                        style: TextStyle(
                          color: !_isMapView ? Colors.white : mainColor,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !_isMapView ? mainColor : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: mainColor),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // === Konten Utama ===
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isMapView ? _buildMapView() : _buildListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === PETA ===
  Widget _buildMapView() {
    return kIsWeb
        ? Center(
            child: Text(
              "🌍 Peta hanya tampil di Android/iOS",
              style: TextStyle(color: Colors.grey[700]),
            ),
          )
        : GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 13.8),
            markers: {
              Marker(
                markerId: const MarkerId('rest1'),
                position: const LatLng(-8.1726, 113.6995),
                infoWindow: const InfoWindow(title: 'Rest Area Jember 1'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
              Marker(
                markerId: const MarkerId('rest2'),
                position: const LatLng(-8.1689, 113.7150),
                infoWindow: const InfoWindow(title: 'Rest Area Jember 2'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRose),
              ),
            },
          );
  }

  // === DAFTAR REST AREA ===
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _restAreas.length,
      itemBuilder: (context, index) {
        final area = _restAreas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar rest area
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    Image.network(
                      area['image']!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.heart, color: mainColor, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Informasi rest area
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(area['name']!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: mainColor)),
                    const SizedBox(height: 4),
                    Text(area['type']!,
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),

                    // Icon waktu
                    Row(
                      children: const [
                        Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('24 Jam', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Fasilitas
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: const [
                        Text('Toilet',
                            style: TextStyle(color: Colors.black54)),
                        Text('Makanan',
                            style: TextStyle(color: Colors.black54)),
                        Text('Parkir',
                            style: TextStyle(color: Colors.black54)),
                        Text('Bahan Bakar',
                            style: TextStyle(color: Colors.black54)),
                        Text('ATM', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Tombol navigasi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.navigation,
                            color: Colors.white, size: 18),
                        label: const Text(
                          "Navigasi",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
