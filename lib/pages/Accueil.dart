import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Statistique.dart';
import 'Alerte.dart';
import 'Profil.dart';
import 'dart:ui';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  // --- SECTION 1 : CONFIGURATION VISUELLE & COULEURS ---
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _lightPurple = Color(0xFF9D84F5);
  int _selectedIndex = 0;

  // --- SECTION 2 : FLUX DE DONNÉES TEMPS RÉEL (FIRESTORE) ---
  Stream<DocumentSnapshot> _streamUserData() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _streamUserData(),
      builder: (context, snapshot) {
        // RÉCUPÉRATION DU PRÉNOM ET DU NOM
        String fullName = "Utilisateur"; 
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          String prenom = data['prenom'] ?? "";
          String nom = data['nom'] ?? "";
          fullName = "$prenom $nom".trim();
          if (fullName.isEmpty) fullName = "Utilisateur Nora";
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
                  // --- SECTION 3 : APPBAR (LOGO + CLOCHE + PROFIL) ---
                  _buildAppBar(),
                  
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // --- SECTION 4 : MESSAGE CHALEUREUX ---
                        _buildWarmWelcome(fullName),
                        const SizedBox(height: 25),
                        
                        // --- SECTION 5 : PREMIER DESIGN DE LA CARTE GLOBALE (NUAGE) ---
                        _buildFirstGlobalCard(),
                        
                        const SizedBox(height: 30),
                        const Text("Salles & Laboratoires", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
                        const SizedBox(height: 15),
                      ]),
                    ),
                  ),
                  
                  // --- SECTION 6 : GRILLE DES 4 SALLES ---
                  _buildRoomsGrid(),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ),
          // --- SECTION 7 : BOTTOMNAV AMÉLIORÉ AVEC BOUTON "PLUS" ---
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // --- DÉTAILS DES COMPOSANTS ---

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, 
      title: const Row(
        children: [
          Text("Nora", style: TextStyle(color: _noraAccentBlue, fontWeight: FontWeight.w900, fontSize: 24)),
          Text(" Air", style: TextStyle(color: _softBlue, fontWeight: FontWeight.w400, fontSize: 24)),
        ],
      ),
      actions: [
        // Ta cloche originale
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Badge(
            backgroundColor: Colors.red,
            label: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10)),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: _noraAccentBlue, size: 20),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Alerte())),
              ),
            ),
          ),
        ),
        // Ton icône profil déplacée et améliorée
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Profil())),
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: _noraAccentBlue.withOpacity(0.1), blurRadius: 10)],
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: _noraAccentBlue,
              child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarmWelcome(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ravi de vous revoir,", style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
        Text("$name 👋", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
      ],
    );
  }

  Widget _buildFirstGlobalCard() {
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
                  const Row(
                    children: [
                      Text("84", style: TextStyle(color: Colors.white, fontSize: 55, fontWeight: FontWeight.w900)),
                      SizedBox(width: 15),
                      Text("BON", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [Icon(Icons.thermostat, color: Colors.white, size: 18), Text(" 22°C", style: TextStyle(color: Colors.white))]),
                      Row(children: [Icon(Icons.water_drop, color: Colors.white, size: 18), Text(" 50%", style: TextStyle(color: Colors.white))]),
                      Row(children: [Icon(Icons.info_outline, color: Colors.white, size: 18), Text(" 1 Alerte", style: TextStyle(color: Colors.white))]),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      height: 75,
      decoration: BoxDecoration(
        color: _noraAccentBlue,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: _noraAccentBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.4),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavItem(Icons.grid_view_rounded, 0),
            _buildNavItem(Icons.bar_chart_rounded, 1),
            _buildNavItem(Icons.add_circle_outline_rounded, 4), // Bouton PLUS
            _buildNavItem(Icons.notifications_active_rounded, 2),
            _buildNavItem(Icons.person_rounded, 3),
          ],
          onTap: (i) {
            if (i == 4) {
              _showMoreOptions(context);
            } else {
              setState(() => _selectedIndex = i);
              if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const Alerte()));
              if (i == 3) Navigator.push(context, MaterialPageRoute(builder: (context) => const Profil()));
            }
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    bool isPlus = index == 4;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isPlus ? 32 : (isSelected ? 28 : 24), color: isPlus ? _softBlue : (isSelected ? Colors.white : Colors.white.withOpacity(0.4))),
          if (isSelected && !isPlus) ...[
            const SizedBox(height: 4),
            Container(height: 4, width: 12, decoration: BoxDecoration(color: _softBlue, borderRadius: BorderRadius.circular(10))),
          ]
        ],
      ),
      label: "",
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Plus de fonctionnalités", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
            const SizedBox(height: 10),
            ListTile(leading: const Icon(Icons.add_location_alt, color: _noraAccentBlue), title: const Text("Ajouter une salle")),
            ListTile(leading: const Icon(Icons.settings_suggest_rounded, color: _noraAccentBlue), title: const Text("Préférences")),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}