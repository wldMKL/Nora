import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Navigation
import 'Accueil.dart';
import 'Statistique.dart';
import 'Alerte.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  // --- DESIGN SYSTEM ---
  static const Color _noraPrimary = Color(0xFF201293);
  static const Color _noraSky = Color(0xFF5B9EEA);
  static const Color _noraPurple = Color(0xFF9D84F5);
  static const Color _noraSuccess = Color(0xFF4CAF50);

  int _selectedIndex = 4;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // Dynamisation des couleurs selon le mode
    final Color textColor = _darkModeEnabled ? Colors.white : _noraPrimary;
    final Color cardBg = _darkModeEnabled ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8);
    final Color dividerColor = _darkModeEnabled ? Colors.white10 : Colors.black12;

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _darkModeEnabled 
                ? [const Color(0xFF0F0F1E), const Color(0xFF1A1A2E)]
                : [_noraPurple.withOpacity(0.1), _noraSky.withOpacity(0.05), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
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
                    const SizedBox(height: 30),
                    _buildQuickStats(cardBg, textColor),
                    const SizedBox(height: 35),
                    _buildSectionTitle("Préférences App", textColor),
                    const SizedBox(height: 15),
                    _buildSettingsGroup(cardBg, textColor, dividerColor),
                    const SizedBox(height: 30),
                    _buildSectionTitle("Sécurité & Compte", textColor),
                    const SizedBox(height: 15),
                    _buildAccountGroup(cardBg, textColor, dividerColor),
                    const SizedBox(height: 40),
                    _buildLogoutAction(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGETS DE DATA ---
  Widget _buildDynamicProfileHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
      builder: (context, snapshot) {
        String nom = "...";
        String prenom = "...";
        String email = currentUser?.email ?? "Email non disponible";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          nom = data['nom'] ?? "";
          prenom = data['prenom'] ?? "";
        }

        return _buildHeaderUI(nom, prenom, email);
      },
    );
  }

  // --- UI COMPONENTS ---
  Widget _buildAppBar(Color textColor) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text("Mon Espace", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 22)),
    );
  }

  Widget _buildHeaderUI(String nom, String prenom, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [_noraPrimary, _noraSky],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: _noraPrimary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                child: const CircleAvatar(radius: 45, backgroundColor: Colors.white24, child: Icon(Icons.person_rounded, size: 55, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: _noraSuccess, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text("$prenom $nom", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 5),
          Text(email, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Color cardBg, Color textColor) {
    return Row(
      children: [
        _buildStatCard("7", "Activité", Icons.bolt_rounded, Colors.amber, cardBg, textColor),
        const SizedBox(width: 15),
        _buildStatCard("12", "Alertes", Icons.notifications_none_rounded, Colors.orange, cardBg, textColor),
        const SizedBox(width: 15),
        _buildStatCard("Pro", "Niveau", Icons.workspace_premium_rounded, _noraSuccess, cardBg, textColor),
      ],
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color, Color cardBg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.5))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            Text(label, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.5), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 0.5)),
    );
  }

  Widget _buildSettingsGroup(Color cardBg, Color textColor, Color dividerColor) {
    return Container(
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white)),
      child: Column(
        children: [
          _buildSwitchTile(Icons.notifications_active_rounded, "Alertes Intelligentes", _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v), textColor),
          Divider(height: 1, indent: 60, color: dividerColor),
          _buildSwitchTile(Icons.dark_mode_rounded, "Thème Sombre", _darkModeEnabled, (v) => setState(() => _darkModeEnabled = v), textColor),
        ],
      ),
    );
  }

  Widget _buildAccountGroup(Color cardBg, Color textColor, Color dividerColor) {
    return Container(
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white)),
      child: Column(
        children: [
          _buildMenuTile(Icons.manage_accounts_rounded, "Éditer mes informations", textColor),
          Divider(height: 1, indent: 60, color: dividerColor),
          _buildMenuTile(Icons.shield_moon_rounded, "Sécurité du compte", textColor),
          Divider(height: 1, indent: 60, color: dividerColor),
          _buildMenuTile(Icons.info_outline_rounded, "À propos de Nora Air", textColor),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool val, ValueChanged<bool> onChanged, Color textColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _noraSky.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: _noraSky, size: 22)),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Switch.adaptive(value: val, onChanged: onChanged, activeColor: _noraSuccess),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, Color textColor) {
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _noraSky.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: _noraSky, size: 22)),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.2), size: 16),
    );
  }

  Widget _buildLogoutAction() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.redAccent.withOpacity(0.08),
        border: Border.all(color: Colors.redAccent.withOpacity(0.1))
      ),
      child: TextButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(context, '/connexion', (route) => false);
        },
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 22),
        label: const Text("Déconnexion du compte", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }

  // --- NAVIGATION (Fidèle à l'Accueil) ---
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      height: 75,
      decoration: BoxDecoration(
        color: _noraPrimary,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: _noraPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.4),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            _buildNavItem(Icons.grid_view_rounded, 0),
            _buildNavItem(Icons.bar_chart_rounded, 1),
            _buildNavItem(Icons.add_circle_outline_rounded, 2, isPlus: true),
            _buildNavItem(Icons.notifications_active_rounded, 3),
            _buildNavItem(Icons.person_rounded, 4),
          ],
          onTap: (index) {
            if (index == 2) {
              _showMoreOptions(context);
            } else if (index != _selectedIndex) {
              if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Accueil()));
              if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Statistique()));
              if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Alerte()));
            }
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index, {bool isPlus = false}) {
    bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isPlus ? 32 : (isSelected ? 28 : 24), color: isPlus ? _noraSky : (isSelected ? Colors.white : Colors.white.withOpacity(0.4))),
          if (isSelected && !isPlus) ...[
            const SizedBox(height: 4),
            Container(height: 4, width: 12, decoration: BoxDecoration(color: _noraSky, borderRadius: BorderRadius.circular(10))),
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
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("Actions Rapides", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _noraPrimary)),
            const SizedBox(height: 15),
            ListTile(leading: const Icon(Icons.add_location_alt_rounded, color: _noraPrimary), title: const Text("Ajouter un nouvel espace", style: TextStyle(fontWeight: FontWeight.w600)), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.share_rounded, color: _noraPrimary), title: const Text("Partager mes analyses", style: TextStyle(fontWeight: FontWeight.w600)), onTap: () => Navigator.pop(context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}