import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../services/monitoring_service.dart';
import 'package:intl/intl.dart';

// Imports
import 'Accueil.dart';
import 'Alerte.dart';
import 'Profil.dart';

class Statistique extends StatefulWidget {
  const Statistique({super.key});

  @override
  State<Statistique> createState() => _StatistiqueState();
}

class _StatistiqueState extends State<Statistique> {
  // Config
  static const Color _noraPrimary = Color(0xFF201293);
  static const Color _noraLightBlue = Color(0xFFE3F2FD);
  static const Color _noraWhite = Colors.white;

  int _selectedIndex = 1; // Index 1 pour la page Statistique
  int _selectedPeriodIndex = 0;   
  int _selectedMetricIndex = 0;   

  final List<String> _periods = ["Jour", "Semaine", "Mois"];

  DateTime get _cutoffDate {
    final now = DateTime.now();
    if (_selectedPeriodIndex == 0) return DateTime(now.year, now.month, now.day); 
    if (_selectedPeriodIndex == 1) return now.subtract(const Duration(days: 7));
    return now.subtract(const Duration(days: 30));                                 
  }

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
          child: StreamBuilder<QuerySnapshot>(
            key: ValueKey(_selectedPeriodIndex),
            stream: FirebaseFirestore.instance
                .collection('sensor_data')
                .orderBy('date_time', descending: true) 
                .limit(100) 
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _noraPrimary));
              }

              final allDocs = snapshot.data?.docs ?? [];

              // Note : La surveillance des alertes se fait maintenant dans main.dart (MonitoringService.startMonitoring)
              // Donc on ne met plus de logique d'alerte ici pour éviter les doublons.

              List<Map<String, dynamic>> filteredHistory = [];
              DateTime cutoff = _cutoffDate;

              for (var doc in allDocs) {
                var data = doc.data() as Map<String, dynamic>;
                String dateStr = (data['date_time']?.toString() ?? '').replaceAll(' ', 'T');
                DateTime? date = DateTime.tryParse(dateStr);
                if (date != null && date.isAfter(cutoff)) filteredHistory.add(data);
              }

              filteredHistory.sort((a, b) {
                String da = (a['date_time']?.toString() ?? '').replaceAll(' ', 'T');
                String db = (b['date_time']?.toString() ?? '').replaceAll(' ', 'T');
                return (DateTime.tryParse(da) ?? DateTime(1970)).compareTo(DateTime.tryParse(db) ?? DateTime(1970));
              });

              double avgTemp = 0.0;
              double avgHumid = 0.0;
              double avgMq135 = 0.0;

              if (filteredHistory.isNotEmpty) {
                double sumTemp = 0.0;
                double sumHumid = 0.0;
                double sumMq = 0.0;
                for (var item in filteredHistory) {
                  sumTemp += double.tryParse(item['temperature']?.toString() ?? '0') ?? 0.0;
                  sumHumid += double.tryParse(item['humidity']?.toString() ?? '0') ?? 0.0;
                  var mq = item['mq135'];
                  double mqVal = (mq is int) ? mq.toDouble() : double.tryParse(mq?.toString() ?? '0') ?? 0.0;
                  sumMq += mqVal;
                }
                avgTemp = sumTemp / filteredHistory.length;
                avgHumid = sumHumid / filteredHistory.length;
                avgMq135 = sumMq / filteredHistory.length;
              }

              List<double> chartPoints = filteredHistory.map((e) {
                double val = 0.0;
                double maxScale = 1.0;
                if (_selectedMetricIndex == 0) {
                  val = double.tryParse(e['temperature']?.toString() ?? '0') ?? 0.0; maxScale = 50.0; 
                } else if (_selectedMetricIndex == 1) {
                  val = double.tryParse(e['humidity']?.toString() ?? '0') ?? 0.0; maxScale = 100.0; 
                } else {
                  var mq = e['mq135'];
                  val = (mq is int) ? mq.toDouble() : double.tryParse(mq?.toString() ?? '0') ?? 0.0; maxScale = 2000.0; 
                }
                return (val / maxScale).clamp(0.0, 1.0);
              }).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildPeriodSelector(),
                        const SizedBox(height: 25),
                        _buildMetricTabs(avgTemp, avgHumid, avgMq135.toInt()),
                        const SizedBox(height: 25),
                        _buildSectionHeader(_selectedMetricIndex == 0 ? "Courbe de Température" : (_selectedMetricIndex == 1 ? "Variation d'Humidité" : "Niveau de Pollution")),
                        const SizedBox(height: 15),
                        filteredHistory.isEmpty ? _buildEmptyState("Pas de données pour cette période") : _buildChartCard(chartPoints),
                        const SizedBox(height: 30),
                        _buildUtilityCard(),
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

  // --- WIDGETS ---
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('lib/images/Fichier 2.png', height: 30),
          const SizedBox(width: 10),
          const Text("Statistiques", style: TextStyle(color: _noraPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50, padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: _noraPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(children: List.generate(_periods.length, (index) {
        bool isSelected = _selectedPeriodIndex == index;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _selectedPeriodIndex = index),
          child: AnimatedContainer(duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(color: isSelected ? _noraWhite : Colors.transparent, borderRadius: BorderRadius.circular(12), boxShadow: isSelected ? [BoxShadow(color: _noraPrimary.withOpacity(0.1), blurRadius: 10)] : []),
            child: Center(child: Text(_periods[index], style: TextStyle(color: isSelected ? _noraPrimary : _noraPrimary.withOpacity(0.4), fontWeight: FontWeight.bold))),
          ),
        ));
      })),
    );
  }

  Widget _buildMetricTabs(double temp, double humid, int mq) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: _noraWhite, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildTabItem(0, "Moy. Temp.", "${temp.toStringAsFixed(1)}°C", Icons.thermostat_rounded, Colors.orange), _buildTabItem(1, "Moy. Humid.", "${humid.toStringAsFixed(0)}%", Icons.water_drop_rounded, _noraPrimary), _buildTabItem(2, "Moy. Air", "$mq PPM", Icons.cloud_done_rounded, Colors.teal)]),
    );
  }

  Widget _buildTabItem(int index, String label, String value, IconData icon, Color color) {
    bool isSelected = _selectedMetricIndex == index;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _selectedMetricIndex = index), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: isSelected ? color.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(15), border: isSelected ? Border.all(color: color, width: 2) : null), child: Column(children: [Icon(icon, color: isSelected ? color : Colors.grey.withOpacity(0.5), size: 28), const SizedBox(height: 5), Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 2), Text(value, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w900))]))));
  }

  Widget _buildChartCard(List<double> points) {
    Color graphColor = _selectedMetricIndex == 0 ? Colors.orange : (_selectedMetricIndex == 1 ? _noraPrimary : Colors.teal);
    return Container(height: 250, width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _noraWhite, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]), child: CustomPaint(painter: NoraCurvePainter(points, color: graphColor)));
  }

  Widget _buildEmptyState(String message) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: _noraWhite, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: _noraPrimary.withOpacity(0.1), blurRadius: 10)]), child: Column(children: [Icon(Icons.history_toggle_off_rounded, size: 40, color: _noraPrimary.withOpacity(0.3)), const SizedBox(height: 10), Text(message, style: TextStyle(color: _noraPrimary.withOpacity(0.5), fontWeight: FontWeight.bold))]));
  }

  Widget _buildSectionHeader(String title) { return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _noraPrimary)); }

  Widget _buildUtilityCard() {
    String title = ""; String desc = ""; IconData icon = Icons.info; Color color = _noraPrimary;
    if (_selectedMetricIndex == 0) { title = "Pourquoi suivre la Température ?"; desc = "Une température stable entre 19°C et 24°C favorise la concentration."; icon = Icons.thermostat; color = Colors.orange; } else if (_selectedMetricIndex == 1) { title = "L'impact de l'Humidité"; desc = "Entre 40% et 60%, l'air est sain. Trop sec, virus. Trop humide, moisissures."; icon = Icons.water_drop; color = _noraPrimary; } else { title = "Comprendre le MQ-135 (CO2)"; desc = "Ce capteur détecte l'air vicié. Ouvrez les fenêtres si > 1000 PPM."; icon = Icons.air; color = Colors.teal; }
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: color), const SizedBox(width: 10), Expanded(child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)))]), const SizedBox(height: 10), Text(desc, style: TextStyle(color: Colors.black87, height: 1.4, fontSize: 13))]));
  }

  // --- NAVIGATION (VERSION CLASSIQUE) ---
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      height: 75,
      decoration: BoxDecoration(color: _noraPrimary, borderRadius: BorderRadius.circular(35)),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active_rounded), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: ""),
        ],
        onTap: (index) {
          if (index != _selectedIndex) {
            // Navigation vers les autres pages
            if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Accueil()));
            if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Alerte()));
            if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Profil()));
            // Index 1 est la page actuelle (Statistique)
          }
        },
      ),
    );
  }
}

class NoraCurvePainter extends CustomPainter {
  final List<double> points; final Color color; NoraCurvePainter(this.points, {this.color = const Color(0xFF201293)});
  @override void paint(Canvas canvas, Size size) { if (points.isEmpty) return; final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3.5..strokeCap = StrokeCap.round; final path = Path(); if (points.length == 1) { double y = size.height - (points[0] * size.height); path.moveTo(0, y); path.lineTo(size.width, y); } else { double stepX = size.width / (points.length - 1); path.moveTo(0, size.height - (points[0] * size.height)); for (int i = 1; i < points.length; i++) { path.quadraticBezierTo((i - 0.5) * stepX, size.height - (points[i - 1] * size.height), i * stepX, size.height - (points[i] * size.height)); } } final fillPath = Path.from(path)..lineTo(size.width, size.height)..lineTo(0, size.height)..close(); final fillPaint = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withOpacity(0.2), Colors.transparent]).createShader(Rect.fromLTWH(0, 0, size.width, size.height)); canvas.drawPath(fillPath, fillPaint); canvas.drawPath(path, paint); }
  @override bool shouldRepaint(NoraCurvePainter oldDelegate) => true;
}