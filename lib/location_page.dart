import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import 'l10n/generated/l10n.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  GoogleMapController? mapController;
  final LatLng _defaultCenter = const LatLng(-8.1726, 113.6995);

  // Posisi kendaraan = posisi HP
  LatLng? _vehiclePosition;
  double _vehicleSpeed = 0.0;
  String? _lastUpdateTime;

  // Streaming lokasi HP
  StreamSubscription<Position>? _positionStream;

  // UI
  bool _isMapView = true;
  final mainColor = const Color(0xFFBA0403);

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
    _initMyLocation();
  }

  // ============================================================
  // 1. IZIN DAN AMBIL LOKASI AWAL HP
  // ============================================================
  Future<void> _initMyLocation() async {
    await Geolocator.requestPermission();
    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      _vehiclePosition = LatLng(pos.latitude, pos.longitude);
    });

    _trackMyLocation();
  }

  // Update lokasi HP terus menerus
  void _trackMyLocation() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2, // update jika bergerak 2 meter
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: settings)
            .listen((Position p) {
      final now = DateTime.now();
      final formatted =
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";

      setState(() {
        _vehiclePosition = LatLng(p.latitude, p.longitude);
        _vehicleSpeed = p.speed * 3.6; // m/s → km/h
        _lastUpdateTime = formatted;
      });

      // Gerakkan kamera mengikuti HP
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(p.latitude, p.longitude),
              zoom: 16,
            ),
          ),
        );
      }
    });
  }

  // ============================================================
  // 2. NOTIFICATION INIT
  // ============================================================
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
    const notif = NotificationDetails(android: androidDetails);
    await _notifications.show(0, title, body, notif);
  }

  // ============================================================
  // 3. GOOGLE MAP CREATED
  // ============================================================
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // ============================================================
  //                UI BUILD STARTS HERE
  // ============================================================
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
                child:
                    _isMapView ? _buildMapView(loc) : _buildListView(loc),
              ),
            ),

            // TEST ALARM BUTTON
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () => _triggerAlarm(
                  loc.location_alarm_title,
                  loc.location_alarm_body,
                ),
                icon: const Icon(Icons.alarm, color: Colors.white),
                label: Text(loc.location_alarm_test,
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================
  Widget _buildSearchBar(S loc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        child: Row(
          children: [
            const Icon(LucideIcons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: loc.location_search_hint,
                  border: InputBorder.none,
                ),
              ),
            ),
            const Icon(LucideIcons.slidersHorizontal, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOGGLE BUTTONS
  // ============================================================
  Widget _buildToggleButtons(S loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isMapView = true),
              icon: Icon(LucideIcons.map,
                  color: _isMapView ? Colors.white : mainColor),
              label: Text(loc.location_tab_map,
                  style: TextStyle(
                      color: _isMapView ? Colors.white : mainColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMapView ? mainColor : Colors.white,
                side: BorderSide(color: mainColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isMapView = false),
              icon: Icon(LucideIcons.list,
                  color: !_isMapView ? Colors.white : mainColor),
              label: Text(loc.location_tab_list,
                  style: TextStyle(
                      color: !_isMapView ? Colors.white : mainColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isMapView ? mainColor : Colors.white,
                side: BorderSide(color: mainColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAP VIEW
  // ============================================================
  Widget _buildMapView(S loc) {
    return Stack(
      children: [
        kIsWeb
            ? const Center(child: Text("Web not supported"))
            : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition:
                    CameraPosition(target: _defaultCenter, zoom: 14),

                myLocationEnabled: true,
                myLocationButtonEnabled: true,

                zoomControlsEnabled: true,
                markers: {
                  if (_vehiclePosition != null)
                    Marker(
                      markerId: const MarkerId('vehicle'),
                      position: _vehiclePosition!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                    ),
                },
              ),

        // PANEL INFO
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _vehiclePosition == null
                ? Text(loc.location_waiting_data)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🌍 ${loc.location_panel_title}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                          "${loc.location_latitude}: ${_vehiclePosition!.latitude.toStringAsFixed(6)}"),
                      Text(
                          "${loc.location_longitude}: ${_vehiclePosition!.longitude.toStringAsFixed(6)}"),
                      Text(
                          "${loc.location_speed}: ${_vehicleSpeed.toStringAsFixed(1)} km/h"),
                      Text(
                          "${loc.location_last_update} ${_lastUpdateTime ?? '--:--:--'}",
                          style: const TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LIST VIEW (REST AREA)
  // ============================================================
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
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(area['image']!,
                    height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(area['name'] == "restarea_1"
                        ? loc.restarea_1
                        : loc.restarea_2),
                    Text(loc.restarea_type),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(loc.restarea_24hours,
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      children: [
                        Text(loc.facility_toilet),
                        Text(loc.facility_food),
                        Text(loc.facility_parking),
                        Text(loc.facility_fuel),
                        Text(loc.facility_atm),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
