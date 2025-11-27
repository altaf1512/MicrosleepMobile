import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'l10n/generated/l10n.dart';
import 'services/distance.dart';
import 'services/lokasi_data.dart';

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
      distanceFilter: 2, 
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
        _vehicleSpeed = p.speed * 3.6; 
        _lastUpdateTime = formatted;
      });

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
  // MAP VIEW (TIDAK DIUBAH SAMA SEKALI)
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
  // LIST VIEW (REST AREA / SPBU / MASJID TERDEKAT – OFFLINE)
  // ============================================================
  Widget _buildListView(S loc) {
    if (_vehiclePosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userLat = _vehiclePosition!.latitude;
    final userLng = _vehiclePosition!.longitude;

    // Hitung jarak semua lokasi offline
    final sorted = offlineLokasiList.map((item) {
      final jarak = hitungJarakKm(
        userLat,
        userLng,
        item.lat,
        item.lng,
      );
      return {"item": item, "jarak": jarak};
    }).toList();

    sorted.sort(
        (a, b) => (a["jarak"] as double).compareTo(b["jarak"] as double));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, i) {
        final item = sorted[i]["item"] as LokasiItem;
        final jarak = sorted[i]["jarak"] as double;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  item.image,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(item.category.toUpperCase(),
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Text("${jarak.toStringAsFixed(2)} km dari lokasi Anda"),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        final url =
                            "https://www.google.com/maps/dir/?api=1&destination=${item.lat},${item.lng}&travelmode=driving";
                        launchUrlString(url,
                            mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.navigation, color: Colors.white),
                      label: const Text("Arahkan ke lokasi ini",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    )
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
