import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  // --- THÈME NORA : BLEU SIGNATURE & BLANC CRISTAL ---
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _lightPurple = Color(0xFF9D84F5);
  int _selectedIndex = 0;

  // --- LOGIQUE : RÉCUPÉRATION DU PROFIL ---
  Stream<DocumentSnapshot> _streamUserData() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _streamUserData(),
      builder: (context, userSnapshot) {
        // --- AFFICHAGE DYNAMIQUE DU NOM ET PRÉNOM ---
        String fullName = "Utilisateur Nora";
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          String prenom = data['prenom'] ?? "";
          String nom = data['nom'] ?? "";
          fullName = "$prenom $nom".trim();
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
                  _buildAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildWarmWelcome(fullName), // Affiche ton nom réel
                        const SizedBox(height: 25),
                        _buildConnectedGlobalCard(), // Carte Nuage avec données réelles
                        const SizedBox(height: 30),
                        const Text("Salles & Laboratoires", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
                        const SizedBox(height: 15),
                      ]),
                    ),
                  ),
                  _buildRoomsGrid(), // Exemples de salles conservés
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

  // --- CARTE GLOBALE CONNECTÉE (DESIGN NUAGE CONSERVÉ) ---
  Widget _buildConnectedGlobalCard() {
    return StreamBuilder<QuerySnapshot>(
      // Écoute de la température et humidité (DHT22)
      stream: FirebaseFirestore.instance.collection('DHT22_data').orderBy('date_time', descending: true).limit(1).snapshots(),
      builder: (context, dhtSnap) {
        return StreamBuilder<QuerySnapshot>(
          // Écoute de la qualité de l'air (MQ135)
          stream: FirebaseFirestore.instance.collection('MQ135_data').orderBy('date_time', descending: true).limit(1).snapshots(),
          builder: (context, mqSnap) {
            
            // Valeurs initialisées (Exemples pendant le chargement)
            String temp = "22.5"; 
            String humid = "50";  
            String aqi = "84";    

            if (dhtSnap.hasData && dhtSnap.data!.docs.isNotEmpty) {
              final dhtData = dhtSnap.data!.docs.first.data() as Map<String, dynamic>;
              temp = dhtData['temperature']?.toString() ?? "22.5";
              humid = dhtData['humidity']?.toString() ?? "50";
            }

            if (mqSnap.hasData && mqSnap.data!.docs.isNotEmpty) {
              final mqData = mqSnap.data!.docs.first.data() as Map<String, dynamic>;
              aqi = mqData['ppm']?.toString() ?? "84";
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(colors: [_noraAccentBlue, _softBlue]),
                boxShadow: [BoxShadow(color: _softBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20, top: -20,
                      child: Icon(Icons.wb_cloudy_rounded, size: 150, color: Colors.white.withOpacity(0.1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Qualité de l'air globale", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(aqi, style: const TextStyle(color: Colors.white, fontSize: 55, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 15),
                              const Text("PPM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatRow(Icons.thermostat, "$temp°C"),
                              _StatRow(Icons.water_drop, "$humid%"),
                              const _StatRow(Icons.info_outline, "1 Alerte"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- GRILLE DES SALLES (EXEMPLES CONSERVÉS) ---
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

  // --- WIDGETS UI (APPBAR, WELCOME & NAV) ---
  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true, backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: false,
      title: const Row(children: [
        Text("Nora", style: TextStyle(color: _noraAccentBlue, fontWeight: FontWeight.w900, fontSize: 24)),
        Text(" Air", style: TextStyle(color: _softBlue, fontWeight: FontWeight.w400, fontSize: 24)),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: _noraAccentBlue),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Alerte())),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Profil())),
          child: const Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(radius: 18, backgroundColor: _noraAccentBlue, child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 20)),
          ),
        ),
      ],
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

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, color: Colors.white, size: 18), Text(" $text", style: const TextStyle(color: Colors.white))]);
  }
}