import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

import 'l10n/generated/l10n.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  GoogleMapController? mapController;
  final LatLng _defaultCenter = const LatLng(-8.1726, 113.6995);

  final DatabaseReference _vehicleRef =
      FirebaseDatabase.instance.ref('vehicle');

  LatLng? _firebaseVehiclePosition;
  double _firebaseSpeed = 0.0;
  String? _lastUpdateTime;

  final mainColor = const Color(0xFFBA0403);
  bool _isMapView = true;

  // Rest Area (tanpa translate dinamis)
  final List<Map<String, String>> _restAreas = [
    {
      "name": "restarea_1",
      "type": "restarea_type",
      "image":
          "https://images.unsplash.com/photo-1689181482780-a6fe3c7b137f",
    },
    {
      "name": "restarea_2",
      "type": "restarea_type",
      "image":
          "https://images.unsplash.com/photo-1638270387990-32897e903002",
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

  void _listenToFirebaseVehicle() {
    _vehicleRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null && mounted) {
        final lat = (data['latitude'] ?? 0.0) as double;
        final lon = (data['longitude'] ?? 0.0) as double;
        final spd = (data['speed'] ?? 0.0) as double;

        final now = DateTime.now();
        final formatted =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

        setState(() {
          _firebaseVehiclePosition = LatLng(lat, lon);
          _firebaseSpeed = spd;
          _lastUpdateTime = formatted;
        });

        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(lat, lon), zoom: 16),
            ),
          );
        }
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(loc),
            _buildToggleButtons(loc),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isMapView ? _buildMapView(loc) : _buildListView(loc),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () => _triggerAlarm(
                  loc.location_alarm_title,
                  loc.location_alarm_body,
                ),
                icon: const Icon(Icons.alarm, color: Colors.white),
                label: Text(
                  loc.location_alarm_test,
                  style: const TextStyle(color: Colors.white),
                ),
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

  // 🔍 Search Bar
  Widget _buildSearchBar(S loc) {
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
                  hintText: loc.location_search_hint,
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

  Widget _buildToggleButtons(S loc) {
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
                loc.location_tab_map,
                style: TextStyle(color: _isMapView ? Colors.white : mainColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMapView ? mainColor : Colors.white,
                side: BorderSide(color: mainColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                loc.location_tab_list,
                style: TextStyle(color: !_isMapView ? Colors.white : mainColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isMapView ? mainColor : Colors.white,
                side: BorderSide(color: mainColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🗺️ Map View
  Widget _buildMapView(S loc) {
    return Stack(
      children: [
        kIsWeb
            ? Center(child: Text("Web not supported"))
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition:
                    CameraPosition(target: _defaultCenter, zoom: 14),
                zoomControlsEnabled: true,
                markers: {
                  if (_firebaseVehiclePosition != null)
                    Marker(
                      markerId: const MarkerId('lokasiAnda'),
                      position: _firebaseVehiclePosition!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                    ),
                },
              ),

        // Info Panel
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
                ? Text(
                    loc.location_waiting_data,
                    style: const TextStyle(color: Colors.grey),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🌍 ${loc.location_panel_title}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                          "${loc.location_latitude}: ${_firebaseVehiclePosition!.latitude.toStringAsFixed(6)}"),
                      Text(
                          "${loc.location_longitude}: ${_firebaseVehiclePosition!.longitude.toStringAsFixed(6)}"),
                      Text("${loc.location_speed}: ${_firebaseSpeed.toStringAsFixed(1)} km/h"),
                      const SizedBox(height: 6),
                      Text(
                        "${loc.location_last_update} ${_lastUpdateTime ?? '--:--:--'}",
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

  // 📋 List View
  Widget _buildListView(S loc) {
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
                    Text(
                      area['name'] == "restarea_1"
                          ? loc.restarea_1
                          : loc.restarea_2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: mainColor),
                    ),

                    const SizedBox(height: 4),
                    Text(
                      loc.restarea_type,
                      style: const TextStyle(color: Colors.black54),
                    ),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          loc.restarea_24hours,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Text(loc.facility_toilet,
                            style: const TextStyle(color: Colors.black54)),
                        Text(loc.facility_food,
                            style: const TextStyle(color: Colors.black54)),
                        Text(loc.facility_parking,
                            style: const TextStyle(color: Colors.black54)),
                        Text(loc.facility_fuel,
                            style: const TextStyle(color: Colors.black54)),
                        Text(loc.facility_atm,
                            style: const TextStyle(color: Colors.black54)),
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
