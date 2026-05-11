// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase eklendi
import 'charging_status_screen.dart';

class StationDetailScreen extends StatelessWidget {
  final String stationId;
  final Map<String, dynamic> stationData; // İlk açılışta hızlı yükleme için yedek veri

  const StationDetailScreen({
    super.key,
    required this.stationId,
    required this.stationData,
  });

  @override
  Widget build(BuildContext context) {
    // StreamBuilder ile anlık veriyi dinliyoruz
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Stations').doc(stationId).snapshots(),
      builder: (context, snapshot) {
        // Veri yüklenene kadar yedek veriyi (stationData) kullanıyoruz ki ekran boş kalmasın
        final Map<String, dynamic> currentData = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!.data() as Map<String, dynamic>
            : stationData;

        // Modeli Firebase'den gelen verilerle dolduruyoruz
        final station = _StationDetailModel(
          name: currentData['name'] ?? 'Unknown Station',
          distance: '0.8 miles away', 
          rating: '4.9',
          reviewCount: 124,
          status: (currentData['isAvailable'] ?? true) ? 'AVAILABLE' : 'BUSY',
          power: '${currentData['speed'] ?? currentData['power_kW'] ?? 0} kW', // Değişken adını her iki ihtimale karşı kontrol ediyoruz
          price: '\$${currentData['price'] ?? currentData['price_per_kWh'] ?? 0} / kWh',
          estimatedFullCharge: '\$12.50 approx.',
          address: currentData['address'] ?? 'Address not specified',
          accessInfo: 'Access 24/7 • Security on site',
          sockets: const [
            _SocketModel(type: 'CCS2', description: 'Fast'),
            _SocketModel(type: 'Type 2', description: 'AC'),
          ],
        );

        return Scaffold(
          backgroundColor: const Color(0xFF101010),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(context, station),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStationHeader(station),
                        const SizedBox(height: 14),
                        _buildCompactInfo(station),
                        const SizedBox(height: 14),
                        _buildSocketRow(station.sockets),
                        const SizedBox(height: 14),
                        _buildLocationCard(station),
                        const SizedBox(height: 18),
                        _startChargingButton(context, station.status == 'AVAILABLE', currentData['name'] ?? 'Station'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- TASARIM WIDGETLARI (Milimetrik Korundu) ---

  Widget _buildHero(BuildContext context, _StationDetailModel station) {
    return Container(
      height: 185,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF242424),
            Color(0xFF171717),
            Color(0xFFE9401A),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: _circleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _circleButton(
              icon: Icons.favorite_border_rounded,
              onTap: () {},
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.ev_station_rounded,
                    color: Color(0xFFE9401A),
                    size: 38,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statusBadge(station.status),
                      const SizedBox(height: 8),
                      Text(
                        station.power,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Fast charging station',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationHeader(_StationDetailModel station) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          station.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '${station.distance} • ${station.rating} ★ (${station.reviewCount})',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInfo(_StationDetailModel station) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _miniInfo(
              icon: Icons.payments_rounded,
              label: 'Price',
              value: station.price,
            ),
          ),
          _divider(),
          Expanded(
            child: _miniInfo(
              icon: Icons.timer_rounded,
              label: 'Full Charge',
              value: station.estimatedFullCharge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocketRow(List<_SocketModel> sockets) {
    return Row(
      children: sockets.map((socket) {
        final isLast = socket == sockets.last;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.electrical_services_rounded,
                    color: Color(0xFFF4D06F),
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          socket.type,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          socket.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationCard(_StationDetailModel station) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: const Color(0xFFF4D06F).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFFF4D06F),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  station.accessInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF4D06F), size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white10,
    );
  }

  Widget _startChargingButton(BuildContext context, bool isAvailable, String sName) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton.icon(
      onPressed: isAvailable 
        ? () async {
            // Sessions koleksiyonuna "active" statüsünde yeni bir döküman ekliyoruz
            await FirebaseFirestore.instance.collection('Sessions').doc('current_session').set({
              'userId': 'user_123',
              'stationId': stationId,
              'stationName': sName,
              'status': 'active', // Bu alan kritik!
              'soc': 15,
              'power': stationData['speed'] ?? 150,
              'startTime': FieldValue.serverTimestamp(),
            });

            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChargingStatusScreen(
                    stationId: stationId,
                    stationName: sName,
                  ),
                ),
              );
            }
          }
        : null,
      icon: const Icon(Icons.bolt_rounded, color: Colors.black),
      label: Text(
        isAvailable ? 'START CHARGING' : 'STATION BUSY',
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF4D06F),
        disabledBackgroundColor: Colors.white10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}

  Widget _statusBadge(String text) {
    final isAvailable = text == 'AVAILABLE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isAvailable ? const Color(0xFF2F8F5B) : Colors.redAccent,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.28),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

// --- MODEL SINIFLARI ---
class _StationDetailModel {
  final String name;
  final String distance;
  final String rating;
  final int reviewCount;
  final String status;
  final String power;
  final String price;
  final String estimatedFullCharge;
  final String address;
  final String accessInfo;
  final List<_SocketModel> sockets;

  const _StationDetailModel({
    required this.name,
    required this.distance,
    required this.rating,
    required this.reviewCount,
    required this.status,
    required this.power,
    required this.price,
    required this.estimatedFullCharge,
    required this.address,
    required this.accessInfo,
    required this.sockets,
  });
}

class _SocketModel {
  final String type;
  final String description;

  const _SocketModel({
    required this.type,
    required this.description,
  });
}