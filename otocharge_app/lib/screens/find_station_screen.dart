import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'station_detail_screen.dart';

class FindStationScreen extends StatefulWidget {
  const FindStationScreen({super.key});

  @override
  State<FindStationScreen> createState() => _FindStationScreenState();
}

class _FindStationScreenState extends State<FindStationScreen> {
  String searchQuery = "";
  late TransformationController _transformationController;
  final double virtualMapSize = 3000.0; // Alanı biraz daha genişlettik

  @override
  void initState() {
    super.initState();
    // DÜZELTME: Haritayı tam merkeze odaklamak için başlangıç matrisini ayarlıyoruz
    _transformationController = TransformationController();
    
    // Haritayı merkeze kaydıran hesaplama
    final double initialScale = 0.5;
    final double xOffset = -(virtualMapSize * initialScale / 2) + 200;
    final double yOffset = -(virtualMapSize * initialScale / 2) + 400;

    _transformationController.value = Matrix4.identity()
      ..translate(xOffset, yOffset)
      ..scale(initialScale);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Find Station",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Stations').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF4D06F)));
          }

          final allDocs = snapshot.data!.docs;
          final filteredDocs = allDocs.where((d) {
            final name = d['name']?.toString().toLowerCase() ?? "";
            return name.contains(searchQuery);
          }).toList();

          return Stack(
            children: [
              // 1. DÜZELTİLMİŞ ETKİLEŞİMLİ HARİTA
              InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(double.infinity), // Her yöne sınırsız kaydırma
                minScale: 0.1,
                maxScale: 4.0,
                child: Container(
                  width: virtualMapSize,
                  height: virtualMapSize,
                  color: Colors.black, // Boşlukların siyah kalması için
                  child: Stack(
                    children: [
                      // Arka Plan Çizimi
                      Positioned.fill(child: const _MapPatternPainter()),
                      
                      // Markerlar
                      ...filteredDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        double lat = (data['latitude'] is num) ? data['latitude'].toDouble() : 0.5;
                        double lng = (data['longitude'] is num) ? data['longitude'].toDouble() : 0.5;

                        // Koordinatları 3000'lik devasa haritaya yayıyoruz
                        return Positioned(
                          key: ValueKey('marker_${doc.id}'),
                          top: virtualMapSize * lat,
                          left: virtualMapSize * lng,
                          child: _buildMapMarker(context, doc.id, data),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // 2. YÜZEN ARAMA PANELİ (Dokunmaları engellememesi için IgnorePointer kullanılmaz)
              Positioned(
                top: 110,
                left: 20,
                right: 20,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Search charging stations...",
                      hintStyle: TextStyle(color: Colors.white30),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapMarker(BuildContext context, String id, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StationDetailScreen(stationId: id, stationData: data),
          ),
        );
      },
      child: Container(
        width: 55, // Marker boyutu biraz büyütüldü
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF4D06F), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF4D06F).withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Icon(Icons.ev_station_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _MapPatternPainter extends StatelessWidget {
  const _MapPatternPainter();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Çizgi rengi daha belirgin yapıldı (Opacity 0.2)
    final paint = Paint()..color = Colors.white.withOpacity(0.2)..strokeWidth = 1.0;
    
    for (double i = 0; i < size.height; i += 80) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    for (double i = 0; i < size.width; i += 80) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Ana yol hatları
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.moveTo(0, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.6);
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.5, size.height);
    
    canvas.drawPath(path, roadPaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}