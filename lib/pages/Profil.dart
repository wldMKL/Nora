import 'package:flutter/material.dart';
import 'dart:ui';
// --- SECTION : IMPORTS FIREBASE ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  // --- SECTION : CONSTANTES ET ÉTATS ---
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _lightPurple = Color(0xFF9D84F5);
  static const Color _accentGreen = Color(0xFF4CAF50);

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _alertesEmail = true;

  // Récupération de l'utilisateur Firebase actuel
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // --- SECTION : LOGIQUE DE COULEURS DYNAMIQUE ---
    final Color bgColor = _darkModeEnabled ? const Color(0xFF0F0F1E) : const Color(0xFFF8F9FA);
    final Color cardColor = _darkModeEnabled ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6);
    final Color textColor = _darkModeEnabled ? Colors.white : _noraAccentBlue;
    final Color subTextColor = _darkModeEnabled ? Colors.white70 : _noraAccentBlue.withOpacity(0.6);
    final Color borderColor = _darkModeEnabled ? Colors.white10 : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _darkModeEnabled 
              ? [const Color(0xFF1A1A2E), const Color(0xFF0F0F1E)]
              : [_lightPurple.withOpacity(0.15), _softBlue.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(textColor),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- APPEL DE LA LOGIQUE DE RÉCUPÉRATION DES DONNÉES ---
                      _buildDynamicProfileHeader(), 
                      const SizedBox(height: 30),
                      _buildStatsCards(cardColor, borderColor, textColor, subTextColor),
                      const SizedBox(height: 30),
                      _buildSettingsSection(cardColor, borderColor, textColor, subTextColor),
                      const SizedBox(height: 20),
                      _buildAccountSection(cardColor, borderColor, textColor, subTextColor),
                      const SizedBox(height: 40),
                      
                      // Bouton de déconnexion
                      TextButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/connexion');
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                        label: const Text("Se déconnecter", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SECTION : RÉCUPÉRATION DES DONNÉES FIRESTORE ---
  Widget _buildDynamicProfileHeader() {
    return FutureBuilder<DocumentSnapshot>(
      // On va chercher le document qui a l'ID de l'utilisateur actuel dans la collection 'users'
      future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Valeurs par défaut si les données ne sont pas encore chargées
        String nom = "Utilisateur";
        String prenom = "Nora";
        String email = currentUser?.email ?? "email@inconnu.com";

        if (snapshot.hasData && snapshot.data!.exists) {
          // Extraction des données de Firestore
          var data = snapshot.data!.data() as Map<String, dynamic>;
          nom = data['nom'] ?? "";
          prenom = data['prenom'] ?? "";
        }

        // Retourne le design du Header avec les vraies données
        return _buildProfileHeaderUI(nom, prenom, email);
      },
    );
  }

  // --- SECTION : DESIGN DU HEADER (TON DESIGN ORIGINAL) ---
  Widget _buildProfileHeaderUI(String nom, String prenom, String email) {
    return Container(
      padding: const EdgeInsets.all(25),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_noraAccentBlue, _softBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _softBlue.withOpacity(_darkModeEnabled ? 0.1 : 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(Icons.person, size: 50, color: _noraAccentBlue),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: _accentGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Affichage dynamique du Nom et Prénom
          Text(
            "$prenom $nom",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          // Affichage de l'email
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text("Membre Actif", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION : AUTRES WIDGETS DE DESIGN ---

  Widget _buildAppBar(Color textColor) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text("Mon Profil", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
    );
  }

  Widget _buildStatsCards(Color cardColor, Color borderColor, Color textColor, Color subTextColor) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.calendar_today_rounded, "1", "Jours actifs", _accentGreen, cardColor, borderColor, subTextColor)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard(Icons.favorite_rounded, "0", "Favoris", Colors.pink, cardColor, borderColor, subTextColor)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard(Icons.notifications_active_rounded, "0", "Alertes", Colors.orange, cardColor, borderColor, subTextColor)),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color iconColor, Color cardColor, Color borderColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: iconColor)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(Color cardColor, Color borderColor, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Paramètres", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 15),
          _buildSwitchTile(Icons.notifications_rounded, "Notifications Push", "Alertes en temps réel", _notificationsEnabled, textColor, subTextColor, (val) => setState(() => _notificationsEnabled = val)),
          Divider(height: 30, color: borderColor),
          _buildSwitchTile(Icons.dark_mode_rounded, "Mode Sombre", "Activer le thème sombre", _darkModeEnabled, textColor, subTextColor, (val) => setState(() => _darkModeEnabled = val)),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Color textColor, Color subTextColor, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _softBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _softBlue, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: subTextColor)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: _accentGreen),
      ],
    );
  }

  Widget _buildAccountSection(Color cardColor, Color borderColor, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Compte", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 15),
          _buildMenuTile(Icons.person_outline_rounded, "Informations personnelles", textColor, null, () {}),
          Divider(height: 25, color: borderColor),
          _buildMenuTile(Icons.lock_outline_rounded, "Changer le mot de passe", textColor, null, () {}),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, Color textColor, Widget? trailing, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _softBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: _softBlue, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor))),
            trailing ?? Icon(Icons.chevron_right_rounded, color: textColor),
          ],
        ),
      ),
    );
  }
}