import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Nécessaire pour gérer les dates

// Navigation
import 'Statistique.dart';
import 'Alerte.dart';
import 'Profil.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  // --- THÈME NORA ---
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _lightPurple = Color(0xFF9D84F5);
  int _selectedIndex = 0;

  // --- LOGIQUE PROFIL ---
  Stream<DocumentSnapshot> _streamUserData() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _streamUserData(),
      builder: (context, userSnapshot) {
        String fullName = "Utilisateur Nora";
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          fullName = "${data['prenom'] ?? ''} ${data['nom'] ?? ''}".trim();
          if (fullName.isEmpty) fullName = "Utilisateur";
        }

        return Scaffold(
          extendBody: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_lightPurple.withOpacity(0.15), _softBlue.withOpacity(0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildFixedAppBar(), // APPBAR RÉDUITE ET FIXE
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildWarmWelcome(fullName),
                        const SizedBox(height: 25),
                        _buildDailyAverageCard(), // MOYENNE DU JOUR
                        const SizedBox(height: 30),
                        const Text("Salles & Laboratoires", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
                        const SizedBox(height: 15),
                      ]),
                    ),
                  ),
                  _buildRoomsGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // --- APPBAR FIXE ET COMPACTE (70px) ---
  Widget _buildFixedAppBar() {
    return SliverAppBar(
      pinned: true,      // Reste collé en haut
      floating: false,
      backgroundColor: Colors.white.withOpacity(0.95), // Fond semi-transparent
      elevation: 0, 
      automaticallyImplyLeading: false,
      
      toolbarHeight: 70, // Hauteur réduite
      
      title: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            // Logo Graphique
            Image.asset(
              'lib/images/Fichier 2.png', 
              height: 45, 
              fit: BoxFit.contain
            ),
            const SizedBox(width: 8), 
            // Logo Texte
            Image.asset(
              'lib/images/Fichier 4.png', 
              height: 28, 
              fit: BoxFit.contain
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: _noraAccentBlue),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Alerte())),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Profil())),
          child: const Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(radius: 16, backgroundColor: _noraAccentBlue, child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 18)),
          ),
        ),
      ],
    );
  }

  // --- CARTE DASHBOARD (MOYENNE JOURNALIÈRE) ---
  Widget _buildDailyAverageCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sensor_data')
          .orderBy('date_time', descending: true)
          .limit(100) // Analyse les 100 dernières entrées pour la moyenne
          .snapshots(),
      builder: (context, snapshot) {
        
        String tempDisplay = "--"; 
        String humidDisplay = "--";  
        String aqiDisplay = "--";    
        String status = "En attente";
        Color statusColor = Colors.grey;
        
        // Date d'aujourd'hui (ex: "2026-01-18")
        String todayDate = DateTime.now().toString().substring(0, 10);
        bool hasDataToday = false;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          double sumTemp = 0.0;
          double sumHumid = 0.0;
          double sumMq = 0.0;
          int count = 0;

          // Calcul de la moyenne sur les données d'aujourd'hui uniquement
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            String dataDate = data['date_time']?.toString() ?? "";

            if (dataDate.startsWith(todayDate)) {
              double t = double.tryParse(data['temperature']?.toString() ?? '0') ?? 0.0;
              double h = double.tryParse(data['humidity']?.toString() ?? '0') ?? 0.0;
              
              var mqRaw = data['mq135'];
              double m = (mqRaw is int) ? mqRaw.toDouble() : double.tryParse(mqRaw?.toString() ?? '0') ?? 0.0;

              sumTemp += t;
              sumHumid += h;
              sumMq += m;
              count++;
            }
          }

          if (count > 0) {
            hasDataToday = true;
            double avgMq = sumMq / count;

            tempDisplay = (sumTemp / count).toStringAsFixed(1);
            humidDisplay = (sumHumid / count).toStringAsFixed(0);
            aqiDisplay = avgMq.toInt().toString();

            if (avgMq < 600) {
              status = "Excellent";
              statusColor = const Color(0xFF4CAF50);
            } else if (avgMq < 1000) {
              status = "Moyen";
              statusColor = Colors.orange;
            } else {
              status = "Mauvais";
              statusColor = Colors.redAccent;
            }
          } else {
            status = "Pas de données";
          }
        }

        return Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [_noraAccentBlue, _softBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: _noraAccentBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EN-TÊTE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Moyenne Journalière", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasDataToday ? "Aujourd'hui" : "Déconnecté", 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // SECTION AQI (PPM)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(aqiDisplay, style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900, height: 1.0)),
                  const SizedBox(width: 10),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text("PPM (Moy)", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(status, style: TextStyle(color: statusColor == Colors.grey ? Colors.white : statusColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: hasDataToday ? 1.0 : 0.0,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(hasDataToday ? statusColor : Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                          minHeight: 6,
                        ),
                      )
                    ],
                  )
                ],
              ),

              const SizedBox(height: 30),
              
              // STATS TEMP & HUMIDITÉ
              Row(
                children: [
                  _buildGlassStatItem(Icons.thermostat_rounded, "$tempDisplay°C", "Temp. Moy."),
                  const SizedBox(width: 15),
                  _buildGlassStatItem(Icons.water_drop_rounded, "$humidDisplay%", "Hum. Moy."),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- RESTE DES WIDGETS ---

  Widget _buildRoomsGrid() {
    final List<Map<String, dynamic>> rooms = const [
      {'name': 'Amphi Théâtre', 'aqi': 95, 'color': Colors.green, 'icon': Icons.meeting_room_rounded},
      {'name': 'Salle Cisco', 'aqi': 82, 'color': Colors.lightGreen, 'icon': Icons.computer_rounded},
      {'name': 'Sigl 3', 'aqi': 68, 'color': Colors.orange, 'icon': Icons.class_rounded},
      {'name': 'Labo Réseaux', 'aqi': 45, 'color': Colors.red, 'icon': Icons.settings_input_component},
    ];
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final room = rooms[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(room['icon'], color: _noraAccentBlue, size: 30),
                  const Spacer(),
                  Text(room['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: _noraAccentBlue)),
                  Text("${room['aqi']} AQI", style: TextStyle(color: room['color'], fontWeight: FontWeight.w900)),
                ],
              ),
            );
          },
          childCount: rooms.length,
        ),
      ),
    );
  }

  Widget _buildWarmWelcome(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bonjour,", style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
        Text("$name 👋", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      height: 75,
      decoration: BoxDecoration(color: _noraAccentBlue, borderRadius: BorderRadius.circular(35)),
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
            if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Statistique()));
            if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Alerte()));
            if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Profil()));
          }
        },
      ),
    );
  }
}