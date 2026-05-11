// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart';

class ChargingStatusScreen extends StatefulWidget {
  // Parametreleri opsiyonel yaptık ki Alt Menü'den (Home) çağrıldığında hata vermesin
  final String? stationId;
  final String? stationName;

  const ChargingStatusScreen({
    super.key,
    this.stationId,
    this.stationName,
  });

  @override
  State<ChargingStatusScreen> createState() => _ChargingStatusScreenState();
}

class _ChargingStatusScreenState extends State<ChargingStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Firestore'da 'ActiveSessions' koleksiyonunda aktif bir kayıt var mı bakıyoruz
      stream: FirebaseFirestore.instance
        .collection('Sessions')
        .where('userId', isEqualTo: 'user_123')
        .where('status', isEqualTo: 'active') // Sadece aktif olanı getir
        .limit(1)
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF101010),
            body: Center(child: CircularProgressIndicator(color: Color(0xFFF4D06F))),
          );
        }

        // AKTİF ŞARJ YOKSA: Bu ekranı göster
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoActiveChargeScreen();
        }

        // AKTİF ŞARJ VARSA: Senin orijinal tasarımını göster
        final sessionData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return _buildChargingDesign(sessionData);
      },
    );
  }

  // --- 1. DURUM: ŞARJ YOKKEN GÖZÜKECEK TASARIM ---
  Widget _buildNoActiveChargeScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bolt_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Active Session",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            const Text(
              "Start a charging session from the map\nto see real-time status here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. DURUM: ŞARJ VARKEN GÖZÜKECEK TASARIM (Senin Orijinal Tasarımın) ---
  Widget _buildChargingDesign(Map<String, dynamic> data) {
    // Verileri Firebase'den çekiyoruz, yoksa varsayılan (fallback) değerler kullanıyoruz
    double progress = (data['soc'] ?? 65) / 100;

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, data['stationName'] ?? widget.stationName ?? 'Station'),
              const SizedBox(height: 28),
              _buildProgressCard(progress),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      title: 'POWER',
                      value: '${data['power'] ?? "42.8"}',
                      unit: 'kW',
                      icon: Icons.bolt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricCard(
                      title: 'DELIVERED',
                      value: '${data['energy'] ?? "34.2"}',
                      unit: 'kWh',
                      icon: Icons.battery_charging_full,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _remainingCard(data['remainingTime'] ?? '24 Minutes'),
              const SizedBox(height: 14),
              _infoRow(icon: Icons.device_thermostat, title: 'Battery Temperature', value: '32°C'),
              const SizedBox(height: 10),
              _infoRow(icon: Icons.payments, title: 'Estimated Cost', value: '\$${data['cost'] ?? "12.45"}'),
              const SizedBox(height: 28),
              _buildStopButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- TASARIM WIDGETLARI (Arkadaşının Orijinal Kodları) ---

  Widget _buildHeader(BuildContext context, String sName) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Charging...', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1)),
              const SizedBox(height: 7),
              Text('Station • $sName', style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF1F1F1F),
          child: Icon(Icons.ev_station, color: Color(0xFFF4D06F), size: 20),
        ),
      ],
    );
  }

  Widget _buildProgressCard(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 210, height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 190, height: 190,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 14,
                    backgroundColor: const Color(0xFF2A2A2A),
                    color: const Color(0xFFF4D06F),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('SOC LEVEL', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({required String title, required String value, required String unit, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: const Color(0xFF1B1B1B), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF4D06F), size: 22),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(children: [
              TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
              TextSpan(text: ' $unit', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _remainingCard(String time) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF4D06F).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 21, backgroundColor: Color(0xFF2A2414), child: Icon(Icons.schedule, color: Color(0xFFF4D06F), size: 21)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ESTIMATED REMAINING', style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 5),
                Text(time, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF4D06F), size: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14))),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildStopButton(BuildContext context) {
  return SizedBox(
    width: double.infinity, height: 58,
    child: ElevatedButton(
      onPressed: () async {
        // Dökümanı silmek yerine statüsünü 'completed' yapıyoruz
        await FirebaseFirestore.instance
            .collection('Sessions')
            .doc('current_session')
            .update({
          'status': 'completed',
          'endTime': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF4D06F), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
      ),
      child: const Text('STOP CHARGING', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
    ),
  );
}
}
