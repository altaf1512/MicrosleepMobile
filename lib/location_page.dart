import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  GoogleMapController? mapController;
  final LatLng _defaultCenter = const LatLng(-8.1726, 113.6995);

  // Firebase reference
  final DatabaseReference _vehicleRef =
      FirebaseDatabase.instance.ref('vehicle');

  LatLng? _firebaseVehiclePosition;
  double _firebaseSpeed = 0.0;

  // Waktu update terakhir
  String? _lastUpdateTime;

  // Warna utama
  final mainColor = const Color(0xFFBA0403);
  final secondaryColor = const Color(0xFFE34234);

  bool _isMapView = true;

  // Data Rest Area
  final List<Map<String, String>> _restAreas = [
    {
      "name": "Rest Area Jember 1",
      "type": "Rest Area Tol",
      "distance": "2.5 km",
      "image": "https://images.unsplash.com/photo-1689181482780-a6fe3c7b137f",
    },
    {
      "name": "Rest Area Jember 2",
      "type": "Rest Area Tol",
      "distance": "5 km",
      "image": "https://images.unsplash.com/photo-1638270387990-32897e903002",
    },
  ];

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _listenToFirebaseVehicle();
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings);
  }

  // 🔔 Tes Alarm
  Future<void> _triggerAlarm(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Microsleep Alarm',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(0, title, body, details);
  }

  // 🛰️ Ambil data lokasi dari Firebase
  void _listenToFirebaseVehicle() {
    _vehicleRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null && mounted) {
        final lat = (data['latitude'] ?? 0.0) as double;
        final lon = (data['longitude'] ?? 0.0) as double;
        final spd = (data['speed'] ?? 0.0) as double;
        final newPos = LatLng(lat, lon);

        final now = DateTime.now();
        final formattedTime =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

        setState(() {
          _firebaseVehiclePosition = newPos;
          _firebaseSpeed = spd;
          _lastUpdateTime = formattedTime;
        });

        // Auto center kamera
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: newPos, zoom: 16),
            ),
          );
        }
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildToggleButtons(),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isMapView ? _buildMapView() : _buildListView(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () =>
                    _triggerAlarm("🔔 Tes Alarm", "Alarm manual berhasil dijalankan."),
                icon: const Icon(Icons.alarm, color: Colors.white),
                label: const Text("Tes Alarm"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔍 Search bar
  Widget _buildSearchBar() {
    return Padding(
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            const Icon(LucideIcons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari rest area...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ),
            const Icon(LucideIcons.slidersHorizontal, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 🔁 Tombol Toggle (Peta / Daftar)
  Widget _buildToggleButtons() {
    return Padding(
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
                style: TextStyle(color: _isMapView ? Colors.white : mainColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMapView ? mainColor : Colors.white,
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
                style: TextStyle(color: !_isMapView ? Colors.white : mainColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isMapView ? mainColor : Colors.white,
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
    );
  }

  // 🗺️ Map View + Panel Informasi
  Widget _buildMapView() {
    return Stack(
      children: [
        kIsWeb
            ? const Center(child: Text("🌍 Peta hanya tampil di Android/iOS"))
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition:
                    CameraPosition(target: _defaultCenter, zoom: 14),
                zoomControlsEnabled: true,
                myLocationEnabled: false,
                markers: {
                  if (_firebaseVehiclePosition != null)
                    Marker(
                      markerId: const MarkerId('lokasiAnda'),
                      position: _firebaseVehiclePosition!,
                      infoWindow: const InfoWindow(title: 'Lokasi Anda'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                    ),
                  const Marker(
                    markerId: MarkerId('rest1'),
                    position: LatLng(-8.1726, 113.6995),
                    infoWindow: InfoWindow(title: 'Rest Area Jember 1'),
                  ),
                  const Marker(
                    markerId: MarkerId('rest2'),
                    position: LatLng(-8.1689, 113.7150),
                    infoWindow: InfoWindow(title: 'Rest Area Jember 2'),
                  ),
                },
              ),

        // 📊 Overlay Info Panel
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _firebaseVehiclePosition == null
                ? const Center(
                    child: Text(
                      "Menunggu data lokasi dari Firebase...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🌍 Lokasi Anda",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Latitude  : ${_firebaseVehiclePosition!.latitude.toStringAsFixed(6)}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "Longitude : ${_firebaseVehiclePosition!.longitude.toStringAsFixed(6)}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      Text(
                        "Kecepatan : ${_firebaseSpeed.toStringAsFixed(1)} km/h",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "⏱️ Terakhir update: ${_lastUpdateTime ?? '--:--:--'}",
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // 📋 List View (Rest Area)
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
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  area['image']!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
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
                    Row(
                      children: const [
                        Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text('24 Jam', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: const [
                        Text('Toilet', style: TextStyle(color: Colors.black54)),
                        Text('Makanan', style: TextStyle(color: Colors.black54)),
                        Text('Parkir', style: TextStyle(color: Colors.black54)),
                        Text('Bahan Bakar',
                            style: TextStyle(color: Colors.black54)),
                        Text('ATM', style: TextStyle(color: Colors.black54)),
                      ],
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
