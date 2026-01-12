import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/sensor_service.dart';
import '../services/monitoring_service.dart';

// Imports pour la navigation
import 'Accueil.dart';
import 'Alerte.dart';
import 'Profil.dart';

class Statistique extends StatefulWidget {
  const Statistique({super.key});

  @override
  State<Statistique> createState() => _StatistiqueState();
}

class _StatistiqueState extends State<Statistique> {
  // --- NOUVELLE PALETTE DE COULEURS ÉPURÉE ---
  static const Color _noraPrimary = Color(0xFF201293); // Bleu profond
  static const Color _noraLightBlue = Color(0xFFE3F2FD); // Bleu très clair
  static const Color _noraSky = Color(0xFF5B9EEA); // Bleu ciel
  static const Color _noraWhite = Colors.white;

  int _selectedIndex = 1;
  int _selectedPeriodIndex = 0;
  final List<String> _periods = ["Jour", "Semaine", "Mois"];

  int get _daysToFetch => (_selectedPeriodIndex == 0) ? 1 : (_selectedPeriodIndex == 1 ? 7 : 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: _noraWhite,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_noraLightBlue, _noraWhite],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: SensorService().getFilteredSensorData(_daysToFetch),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _noraPrimary));
              }

              final history = snapshot.data ?? [];

              double temp = 0.0;
              double humid = 0.0;
              if (history.isNotEmpty) {
                temp = double.tryParse(history.first['temperature']?.toString() ?? '0') ?? 0.0;
                humid = double.tryParse(history.first['humidity']?.toString() ?? '0') ?? 0.0;
              }

              // Analyse automatique pour les alertes
              MonitoringService.checkThresholds(temp, humid, 77, "Salle Cisco");

              // Préparation des points (normalisés)
              List<double> chartPoints = history.reversed
                  .map((e) => (double.tryParse(e['temperature']?.toString() ?? '0') ?? 0.0) / 50)
                  .toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildPeriodSelector(),
                        const SizedBox(height: 30),
                        _buildMainValueCard(temp), 
                        const SizedBox(height: 35),
                        _buildSectionHeader("Tendance Respiratoire"),
                        const SizedBox(height: 15),
                        _buildChartCard(chartPoints),
                        const SizedBox(height: 35),
                        _buildSectionHeader("Indicateurs Clés"),
                        const SizedBox(height: 15),
                        _buildMetricsGrid(humid),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGETS DE DESIGN ---

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text("Analyses Nora", 
        style: TextStyle(color: _noraPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _noraPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          bool isSelected = _selectedPeriodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriodIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isSelected ? _noraWhite : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [BoxShadow(color: _noraPrimary.withOpacity(0.1), blurRadius: 10)] : [],
                ),
                child: Center(
                  child: Text(_periods[index],
                    style: TextStyle(color: isSelected ? _noraPrimary : _noraPrimary.withOpacity(0.4), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainValueCard(double value) {
    bool critical = value > 30;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: critical ? [Colors.redAccent, Colors.red] : [_noraPrimary, _noraSky],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: (critical ? Colors.red : _noraPrimary).withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Text("Température moyenne", style: TextStyle(color: _noraWhite.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 5),
          Text("${value.toStringAsFixed(1)}°C", 
            style: const TextStyle(color: _noraWhite, fontSize: 55, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _noraWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Text(critical ? "RISQUE BACTÉRIEN ÉLEVÉ" : "ENVIRONNEMENT SAIN", 
              style: const TextStyle(color: _noraWhite, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          )
        ],
      ),
    );
  }

  Widget _buildChartCard(List<double> points) {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _noraWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: points.isEmpty 
        ? const Center(child: Text("Collecte de données en cours..."))
        : CustomPaint(painter: NoraCurvePainter(points)),
    );
  }

  Widget _buildMetricsGrid(double humid) {
    return Row(
      children: [
        _buildMetricTile("Humidité", "${humid.toStringAsFixed(0)}%", Icons.water_drop_rounded, _noraSky),
        const SizedBox(width: 20),
        _buildMetricTile("Qualité Air", "77", Icons.cloud_done_rounded, Colors.teal),
      ],
    );
  }

  Widget _buildMetricTile(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _noraWhite,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _noraPrimary.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 15),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
            Text(val, style: const TextStyle(color: _noraPrimary, fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _noraPrimary));
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      height: 70,
      decoration: BoxDecoration(
        color: _noraPrimary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: _noraPrimary.withOpacity(0.3), blurRadius: 20)],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _selectedIndex,
        selectedItemColor: _noraWhite,
        unselectedItemColor: _noraWhite.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: ""),
        ],
        onTap: (index) {
          if (index != _selectedIndex) {
            if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Accueil()));
            if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Alerte()));
            if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Profil()));
          }
        },
      ),
    );
  }
}

// --- PAINTER PROFESSIONNEL AVEC DÉGRADÉ ---
class NoraCurvePainter extends CustomPainter {
  final List<double> points;
  NoraCurvePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    
    final paint = Paint()
      ..color = const Color(0xFF201293)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double stepX = size.width / (points.length - 1);

    path.moveTo(0, size.height - (points[0] * size.height));

    for (int i = 1; i < points.length; i++) {
      // Courbe lissée (Bézier)
      path.quadraticBezierTo(
        (i - 0.5) * stepX, size.height - (points[i-1] * size.height),
        i * stepX, size.height - (points[i] * size.height)
      );
    }

    // Création du dégradé sous la courbe
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF201293).withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NoraCurvePainter oldDelegate) => true;
}