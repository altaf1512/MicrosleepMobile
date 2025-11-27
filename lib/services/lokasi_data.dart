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
    name: "Rest Area Utama",
    category: "rest-area",
    image: "https://images.unsplash.com/photo-1689181482780-a6fe3c7b137f",
    lat: -8.1700,
    lng: 113.7020,
  ),
  LokasiItem(
    name: "SPBU Pertamina 54-123",
    category: "spbu",
    image: "https://images.unsplash.com/photo-1638270387990-32897e903002",
    lat: -8.1750,
    lng: 113.6970,
  ),
  LokasiItem(
    name: "Masjid AN-NUUR",
    category: "masjid",
    image: "https://images.unsplash.com/photo-1524492412937-b28074a5d7da",
    lat: -8.1730,
    lng: 113.6900,
  ),
  LokasiItem(
    name: "Rest Area Rambipuji",
    category: "rest-area",
    image: "https://images.unsplash.com/photo-1600460043921-092dd2b31c1d",
    lat: -8.1995,
    lng: 113.6890,
  ),
  LokasiItem(
    name: "SPBU Mangli",
    category: "spbu",
    image: "https://images.unsplash.com/photo-1581091870622-df7aa1a4d7c1",
    lat: -8.1880,
    lng: 113.7200,
  ),
  LokasiItem(
    name: "SPBU Kaliwates",
    category: "spbu",
    image: "https://images.unsplash.com/photo-1509391366360-2e959784a276",
    lat: -8.1655,
    lng: 113.6880,
  ),
  LokasiItem(
    name: "Masjid Baiturrahman",
    category: "masjid",
    image: "https://images.unsplash.com/photo-1585562133447-1c1e1e42937e",
    lat: -8.1810,
    lng: 113.7080,
  ),
  LokasiItem(
    name: "Masjid At-Taqwa",
    category: "masjid",
    image: "https://images.unsplash.com/photo-1563299796-17596ed6b017",
    lat: -8.1755,
    lng: 113.7155,
  ),
];
