// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'station_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = "";
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    // Klavye açık mı kontrolü (Sarı çizgileri engellemek için)
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Klavye açıldığında ekranın büzülmesini engeller
      backgroundColor: const Color(0xFF000000),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Stations').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF4D06F)));
          }

          final allDocs = snapshot.data!.docs;
          
          // Arama Filtresi: İsme göre filtreleme yapıyoruz
          final filteredDocs = allDocs.where((d) {
            final name = d['name']?.toString().toLowerCase() ?? "";
            return name.contains(searchQuery);
          }).toList();

          return Stack(
            children: [
              // 1. ARKA PLAN: Sabit Izgara ve Yol Çizimi
              const Positioned.fill(
                child: _MapPatternPainter(key: ValueKey('static_map')),
              ),

              // 2. DİNAMİK MARKERLAR (Harita üzerinde sabit dururlar)
              ...filteredDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                // Koordinatları ekrana oranlıyoruz
                double lat = (data['latitude'] is num) ? data['latitude'].toDouble() : 0.5;
                double lng = (data['longitude'] is num) ? data['longitude'].toDouble() : 0.5;

                // Değerler 0-1 arası değilse normalize et
                if (lat > 1) lat = (lat % 100) / 100;
                if (lng > 1) lng = (lng % 100) / 100;

                return Positioned(
                  key: ValueKey('marker_${doc.id}'),
                  top: MediaQuery.of(context).size.height * lat,
                  left: MediaQuery.of(context).size.width * lng,
                  child: _buildMapMarker(),
                );
              }),

              // 3. SABİT ÜST PANEL (Logo ve Arama)
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(),
                    _buildSearchAndFilter(),
                  ],
                ),
              ),

              // 4. ALT PANEL (İstasyon Kartları)
              // Klavye açıkken gizlenir, böylece sarı-siyah overflow hatası oluşmaz.
              if (!isKeyboardOpen && filteredDocs.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 360,
                    padding: const EdgeInsets.only(bottom: 25),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data = filteredDocs[index].data() as Map<String, dynamic>;
                        final id = filteredDocs[index].id;
                        return _buildStationCardUI(id, data);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- TASARIM ELEMENTLERİ ---

  Widget _buildMapMarker() {
    return Container(
      width: 45, height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF4D06F), width: 3),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF4D06F).withOpacity(0.4), blurRadius: 15, spreadRadius: 2)
        ],
      ),
      child: const Icon(Icons.ev_station, color: Colors.white, size: 20),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.star, color: Color(0xFFF4D06F), size: 28),
              SizedBox(width: 8),
              Text("SPARKY", style: TextStyle(color: Color(0xFFF4D06F), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ],
          ),
          const CircleAvatar(radius: 22, backgroundColor: Color(0xFF1C1C1E), child: Icon(Icons.person, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(color: const Color(0xFF1C1C1E).withOpacity(0.9), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Find a station",
                  hintStyle: TextStyle(color: Colors.white30),
                  prefixIcon: Icon(Icons.search, color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 56, width: 56,
            decoration: BoxDecoration(color: const Color(0xFF1C1C1E).withOpacity(0.9), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
            child: const Icon(Icons.tune_rounded, color: Color(0xFFF4D06F)),
          ),
        ],
      ),
    );
  }

  Widget _buildStationCardUI(String id, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _badge("NEAREST STATION", const Color(0xFFF4D06F).withOpacity(0.12), const Color(0xFFF4D06F)),
              _badge(data['isAvailable'] == true ? "AVAILABLE" : "OCCUPIED", const Color(0xFF323A45), data['isAvailable'] == true ? const Color(0xFF8BA2B5) : Colors.redAccent),
            ],
          ),
          const SizedBox(height: 20),
          Text(data['name'] ?? 'Station', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(data['address'] ?? 'No address found', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 24),
          Row(
            children: [
              _infoBox("SPEED", "${data['speed'] ?? 0} kW"),
              const SizedBox(width: 12),
              _infoBox("PRICE", "${data['price'] ?? 0} €/kWh"),
            ],
          ),
          const Spacer(),
          _buildStartButton(id, data),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _infoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Color(0xFFF4D06F), fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(String id, Map<String, dynamic> data) {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StationDetailScreen(stationId: id, stationData: data))),
        icon: const Icon(Icons.navigation_rounded, color: Colors.black),
        label: const Text("START NAVIGATION", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4D06F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
      ),
    );
  }
}

// --- HARİTA DOKUSU ÇİZİCİ ---
class _MapPatternPainter extends StatelessWidget {
  const _MapPatternPainter({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 1.0;
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    final roadPaint = Paint()..color = Colors.white.withOpacity(0.25)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    var path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.7);
    path.moveTo(size.width * 0.7, 0);
    path.lineTo(size.width * 0.2, size.height);
    canvas.drawPath(path, roadPaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}