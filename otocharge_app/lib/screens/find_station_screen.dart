import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'station_detail_screen.dart'; 

class FindStationScreen extends StatefulWidget {
  const FindStationScreen({super.key});

  @override
  State<FindStationScreen> createState() => _FindStationScreenState();
}

class _FindStationScreenState extends State<FindStationScreen> {
  late GoogleMapController mapController;

  // Başlangıç konumu (Örn: İstanbul / Beşiktaş)
  final LatLng _initialPosition = const LatLng(41.0422, 29.0075);

  // Firestore'daki istasyonları haritadaki işaretçilere (Marker) çevirecek küme
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchStationsFromFirestore();
  }

  // FIRESTORE'DAN İSTASYONLARI ÇEKME VE MARKER OLUŞTURMA
  void _fetchStationsFromFirestore() {
    FirebaseFirestore.instance.collection('Stations').snapshots().listen((snapshot) {
      final Set<Marker> tempMarkers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final GeoPoint geoPoint = data['location']; // Firestore GeoPoint tipi
        
        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(geoPoint.latitude, geoPoint.longitude),
          infoWindow: InfoWindow(
            title: data['name'],
            snippet: '${data['power_kW']} kW • \$${data['price_per_kWh']}/kWh',
            onTap: () {
              // İşaretçinin bilgi penceresine tıklandığında Detay Sayfasına git
              _navigateToDetail(doc.id, data);
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        );
        tempMarkers.add(marker);
      }

      setState(() {
        _markers = tempMarkers;
      });
    });
  }

  void _navigateToDetail(String stationId, Map<String, dynamic> stationData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDetailScreen(
          stationId: stationId,
          stationData: stationData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Station', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF101010),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // GOOGLE MAPS KATMANI
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            // Haritayı gece moduna sokmak için (Opsiyonel Stil)
            style: _mapDarkStyle, 
          ),

          // ÜSTTEKİ ARAMA ÇUBUĞU (TASARIM AMAÇLI)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFFF4D06F)),
                  SizedBox(width: 10),
                  Text("Search charging stations...", style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Haritayı projenin koyu temasına uyduran stil (JSON formatında)
  final String _mapDarkStyle = '''
  [
    { "elementType": "geometry", "stylers": [ { "color": "#212121" } ] },
    { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] },
    { "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] },
    { "path": "road", "elementType": "geometry", "stylers": [ { "color": "#2c2c2c" } ] }
  ]
  ''';
}