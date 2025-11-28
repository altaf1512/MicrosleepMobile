class LokasiItem {
  final String name;
  final String category; // rest-area / spbu / masjid
  final String image;
  final double lat;
  final double lng;

  LokasiItem({
    required this.name,
    required this.category,
    required this.image,
    required this.lat,
    required this.lng,
  });
}

final offlineLokasiList = [
  LokasiItem(
    name: "Rest Area Jubung",
    category: "REST-AREA",
    image: "assets/restarea.png",
    lat: -8.1935009,
    lng: 113.6429949,
  ),
  LokasiItem(
    name: "MASJID AN-NUUR JEMBER",
    category: "Masjid",
    image: "assets/an_nur.png",
    lat: -8.1603567,
    lng: 113.7084103,
  ),
  LokasiItem(
    name: "SPBU CENDRAWASIH",
    category: "Pom Bensin/SPBU",
    image: "assets/spbu_patrang.png",
    lat: -8.1558341,
    lng: 113.7007241,
  ),
  LokasiItem(
    name: "Indomaret Pandora Mastrip",
    category: "REST-AREA",
    image: "assets/indomart.png",
    lat: -8.1598290,
    lng: 113.7201550,
  ),
  LokasiItem(
    name: "SPBU 54.681.25",
    category: "Pom Bensin/SPBU",
    image: "assets/spbu_kota.png",
    lat: -8.1733377,
    lng: 113.7038783,
  ),
  LokasiItem(
    name: "HOTEL SITI",
    category: "Penginapan",
    image: "assets/hotel_siti.png",
    lat: -8.1553777,
    lng: 113.7128061,
  ),

];
