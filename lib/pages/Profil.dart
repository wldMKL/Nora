import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/monitoring_service.dart';

// Navigation
import 'Accueil.dart';
import 'Statistique.dart';
import 'Alerte.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> with SingleTickerProviderStateMixin {
  // --- DESIGN SYSTEM ---
  static const Color _noraPrimary = Color(0xFF201293);
  static const Color _noraSky = Color(0xFF5B9EEA);
  static const Color _noraPurple = Color(0xFF9D84F5);
  static const Color _noraSuccess = Color(0xFF4CAF50);
  static const Color _noraWhite = Colors.white;

  int _selectedIndex = 4; // Index 4 pour le Profil
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Animation Avatar
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final Map<String, IconData> _availableAvatars = {
    'default': Icons.person_rounded,
    'cool': Icons.sentiment_very_satisfied_rounded,
    'tech': Icons.memory_rounded,
    'eco': Icons.eco_rounded,
    'gamer': Icons.sports_esports_rounded,
    'sport': Icons.directions_run_rounded,
    'music': Icons.headphones_rounded,
    'travel': Icons.flight_takeoff_rounded,
    'idea': Icons.lightbulb_rounded,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = _darkModeEnabled ? Colors.white : _noraPrimary;
    final Color cardBg = _darkModeEnabled ? const Color(0xFF252540) : Colors.white;
    final Color scaffoldBg = _darkModeEnabled ? const Color(0xFF0F0F1E) : const Color(0xFFF5F7FA);

    return Scaffold(
      extendBody: true,
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Fond flou
          Positioned(
            top: -100, right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  color: _noraSky.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(textColor),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildDynamicProfileHeader(),
                      const SizedBox(height: 25),
                      _buildQuickStats(cardBg, textColor),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Préférences", textColor),
                      const SizedBox(height: 15),
                      _buildSettingsCard(cardBg, textColor),
                      const SizedBox(height: 30),
                      _buildSectionTitle("Compte", textColor),
                      const SizedBox(height: 15),
                      _buildAccountCard(cardBg, textColor),
                      const SizedBox(height: 40),
                      _buildLogoutButton(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGETS ---
  
  Widget _buildDynamicProfileHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
      builder: (context, snapshot) {
        String nom = "...";
        String prenom = "...";
        String email = currentUser?.email ?? "";
        String avatarKey = 'default';

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          nom = data['nom'] ?? "";
          prenom = data['prenom'] ?? "";
          avatarKey = data['avatarKey'] ?? 'default';
        }
        return _buildHeaderUI(nom, prenom, email, avatarKey);
      },
    );
  }

  Widget _buildHeaderUI(String nom, String prenom, String email, String avatarKey) {
    IconData iconToShow = _availableAvatars[avatarKey] ?? Icons.person_rounded;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showAvatarSelectionModal(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _noraPrimary.withOpacity(0.1), width: 1),
                    color: _noraPrimary.withOpacity(0.05),
                  ),
                ),
              ),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_noraPrimary, _noraSky], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: _noraPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Icon(iconToShow, size: 50, color: Colors.white),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _noraWhite,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                  ),
                  child: const Icon(Icons.edit, color: _noraPrimary, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text("$prenom $nom", style: TextStyle(color: _darkModeEnabled ? Colors.white : _noraPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(email, style: TextStyle(color: (_darkModeEnabled ? Colors.white : Colors.black).withOpacity(0.5), fontSize: 14)),
        const SizedBox(height: 15),
        Container(
          width: 150, height: 6,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Container(
                width: 100, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [_noraSky, _noraPrimary]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text("Niveau Expert", style: TextStyle(color: _noraSky, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickStats(Color cardBg, Color textColor) {
    String alertCount = MonitoringService.activeAlerts.length.toString();
    return Row(
      children: [
        _buildInteractiveStatCard("7", "Appareils", Icons.hub_rounded, Colors.purpleAccent, cardBg, textColor),
        const SizedBox(width: 15),
        _buildInteractiveStatCard(alertCount, "Alertes", Icons.notifications_active_rounded, Colors.orange, cardBg, textColor),
        const SizedBox(width: 15),
        _buildInteractiveStatCard("98%", "Santé Air", Icons.favorite_rounded, _noraSuccess, cardBg, textColor),
      ],
    );
  }

  Widget _buildInteractiveStatCard(String val, String label, IconData icon, Color iconColor, Color bg, Color text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: text)),
            Text(label, style: TextStyle(fontSize: 12, color: text.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(Color bg, Color text) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        children: [
          _buildInteractiveToggle(Icons.notifications_outlined, "Notifications", _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v), text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 1, color: text.withOpacity(0.05))),
          _buildInteractiveToggle(Icons.dark_mode_outlined, "Mode Sombre", _darkModeEnabled, (v) => setState(() => _darkModeEnabled = v), text),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Color bg, Color text) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        children: [
          _buildInteractiveTile(Icons.person_outline_rounded, "Profil & Données", text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 1, color: text.withOpacity(0.05))),
          _buildInteractiveTile(Icons.lock_outline_rounded, "Confidentialité", text),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(height: 1, color: text.withOpacity(0.05))),
          _buildInteractiveTile(Icons.help_outline_rounded, "Aide & Support", text),
        ],
      ),
    );
  }

  Widget _buildInteractiveToggle(IconData icon, String title, bool value, Function(bool) onChanged, Color text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _noraPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: _noraPrimary, size: 20)),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: text))),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: _noraPrimary),
        ],
      ),
    );
  }

  Widget _buildInteractiveTile(IconData icon, String title, Color text) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _noraPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: _noraPrimary, size: 20)),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: text))),
            Icon(Icons.chevron_right_rounded, color: text.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(context, '/connexion', (route) => false);
        },
        borderRadius: BorderRadius.circular(20),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("Déconnexion", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(35))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Choisir un avatar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _noraPrimary)),
            const SizedBox(height: 25),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 15, mainAxisSpacing: 15),
              itemCount: _availableAvatars.length,
              itemBuilder: (context, index) {
                String key = _availableAvatars.keys.elementAt(index);
                IconData icon = _availableAvatars.values.elementAt(index);
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    if (currentUser != null) {
                      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({'avatarKey': key});
                      setState(() {});
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(color: _noraPrimary.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                    child: Icon(icon, color: _noraPrimary, size: 30),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Color textColor) {
    return SliverAppBar(
      backgroundColor: Colors.transparent, elevation: 0, centerTitle: true, automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('lib/images/Fichier 2.png', height: 30),
          const SizedBox(width: 10),
          Text("Mon Espace", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(padding: const EdgeInsets.only(left: 10), child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)));
  }

  // --- NAVIGATION (VERSION CLASSIQUE DEMANDÉE) ---
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
            if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Accueil()));
            if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Statistique()));
            if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Alerte()));
            // Index 4 est la page actuelle
          }
        },
      ),
    );
  }
}