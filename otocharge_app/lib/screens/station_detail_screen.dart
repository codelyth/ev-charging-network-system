// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'charging_status_screen.dart';

class StationDetailScreen extends StatelessWidget {
  // HARİTADAN GELEN VERİLERİ BURADA KARŞILIYORUZ
  final String stationId;
  final Map<String, dynamic> stationData;

  const StationDetailScreen({
    super.key,
    required this.stationId,
    required this.stationData,
  });

  @override
  Widget build(BuildContext context) {
    // Firebase'den gelen verileri modele döküyoruz
    final station = _StationDetailModel(
      name: stationData['name'] ?? 'Unknown Station',
      distance: '0.8 miles away', // Şimdilik statik kalabilir veya hesaplanabilir
      rating: '4.9',
      reviewCount: 124,
      status: (stationData['isAvailable'] ?? true) ? 'AVAILABLE' : 'BUSY',
      power: '${stationData['power_kW'] ?? 0} kW',
      price: '\$${stationData['price_per_kWh'] ?? 0} / kWh',
      estimatedFullCharge: '\$12.50 approx.',
      address: 'Grand Central Parking, Level 2',
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
                    _startChargingButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET METOTLARI AYNI KALIYOR (Değişiklik yok) ---

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

  Widget _startChargingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          // Şarj ekranına istasyon verilerini gönderiyoruz
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChargingStatusScreen(
                stationId: stationId,
                stationName: stationData['name'] ?? 'Station',
              ),
            ),
          );
        },
        icon: const Icon(Icons.bolt_rounded, color: Colors.black),
        label: const Text(
          'START CHARGING',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF4D06F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2F8F5B),
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

// --- MODEL SINIFLARI AYNI KALIYOR ---
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