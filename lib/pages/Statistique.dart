import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

class Statistique extends StatefulWidget {
  const Statistique({super.key});

  @override
  State<Statistique> createState() => _StatistiqueState();
}

class _StatistiqueState extends State<Statistique> {
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _dustOrange = Color(0xFFFF9800);

  // Gestion de la période sélectionnée
  int _selectedPeriodIndex = 0; // 0: Jour, 1: Semaine, 2: Mois
  final List<String> _periods = ["Jour", "Semaine", "Mois"];

  // Données simulées pour chaque période
  List<double> _points = [];
  double _currentDustLevel = 12.48;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateData(); // Génération initiale
    
    // Simulation temps réel uniquement si "Jour" est sélectionné
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_selectedPeriodIndex == 0) {
        setState(() {
          _currentDustLevel = 11.0 + Random().nextDouble() * 3.0;
          _points.add(Random().nextDouble());
          if (_points.length > 20) _points.removeAt(0);
        });
      }
    });
  }

  // Fonction pour changer les données selon la période
  void _generateData() {
    setState(() {
      if (_selectedPeriodIndex == 0) {
        _points = List.generate(20, (index) => 0.3 + Random().nextDouble() * 0.4);
      } else if (_selectedPeriodIndex == 1) {
        _points = List.generate(7, (index) => 0.2 + Random().nextDouble() * 0.6);
      } else {
        _points = List.generate(30, (index) => 0.1 + Random().nextDouble() * 0.8);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_softBlue.withOpacity(0.15), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildPeriodSelector(), // Nouveau sélecteur
                    const SizedBox(height: 20),
                    _buildRealTimeMainCard(),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Analyse de la période"),
                    const SizedBox(height: 15),
                    _buildLiveChart(),
                    const SizedBox(height: 30),
                    _buildMetricsGrid(),
                    const SizedBox(height: 20),
                    _buildHealthCard(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NOUVEAU : SÉLECTEUR DE PÉRIODE ---
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          bool isSelected = _selectedPeriodIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriodIndex = index;
                  _generateData();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _noraAccentBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _noraAccentBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _noraAccentBlue),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text("Suivi Historique", 
        style: TextStyle(color: _noraAccentBlue, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRealTimeMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [_dustOrange, Color(0xFFFFB74D)]),
        boxShadow: [
          BoxShadow(color: _dustOrange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Text("Moyenne (${_periods[_selectedPeriodIndex]})", 
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 5),
          Text(_currentDustLevel.toStringAsFixed(2), 
            style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w900)),
          const Text("µg / m³", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLiveChart() {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white),
      ),
      child: CustomPaint(
        painter: LiveCurvePainter(_points, _selectedPeriodIndex),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _smallStatTile("Pic Max", "18.5", Icons.trending_up_rounded),
        _smallStatTile("Exposition", "Basse", Icons.health_and_safety_rounded),
      ],
    );
  }

  Widget _smallStatTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _dustOrange, size: 24),
          const Spacer(),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: _noraAccentBlue, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHealthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _noraAccentBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Text(
        "L'historique permet de détecter les allergies saisonnières ou les pics de pollution récurrents.",
        style: TextStyle(color: _noraAccentBlue, fontSize: 13, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _noraAccentBlue));
  }
}

class LiveCurvePainter extends CustomPainter {
  final List<double> points;
  final int periodIndex;
  LiveCurvePainter(this.points, this.periodIndex);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    var paint = Paint()
      ..color = const Color(0xFF201293)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    var path = Path();
    double stepX = size.width / (points.length - 1);

    path.moveTo(0, size.height - (points[0] * size.height));

    for (int i = 1; i < points.length; i++) {
      // Utilisation de courbes pour le jour, lignes pour les mois
      if (periodIndex == 0) {
        path.quadraticBezierTo(
          (i - 0.5) * stepX, size.height - (points[i-1] * size.height),
          i * stepX, size.height - (points[i] * size.height)
        );
      } else {
        path.lineTo(i * stepX, size.height - (points[i] * size.height));
      }
    }

    var fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    var fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF201293).withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiveCurvePainter oldDelegate) => true;
}