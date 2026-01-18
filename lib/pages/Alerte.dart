import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // IMPORT NÉCESSAIRE POUR LES VIBRATIONS
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; 
import 'package:intl/intl.dart';
import '../services/monitoring_service.dart';

// Navigation
import 'Accueil.dart';
import 'Statistique.dart';
import 'Profil.dart';

class Alerte extends StatefulWidget {
  const Alerte({super.key});

  @override
  State<Alerte> createState() => _AlerteState();
}

class _AlerteState extends State<Alerte> {
  static const Color _noraBlue = Color(0xFF201293);
  static const Color _noraSky = Color(0xFF5B9EEA);
  static const Color _noraSoftBlue = Color(0xFFE3F2FD);

  int _selectedIndex = 3; // Index pour la page Alerte
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["Aujourd'hui", "7 derniers jours"];

  @override
  void initState() {
    super.initState();
    MonitoringService.cleanOldAlerts();
    
    // SIMULATION : Ajout d'alertes + VIBRATION
    if (MonitoringService.activeAlerts.isEmpty) {
      // 1. On fait vibrer le téléphone pour signaler l'urgence
      HapticFeedback.heavyImpact(); 

      MonitoringService.activeAlerts.addAll([
        HealthAlert(
          title: "Risque de Grippe Élevé",
          desc: "L'humidité est tombée à 32%. Le virus survit plus longtemps dans l'air sec.",
          room: "Salle Cisco",
          level: "Critique",
          color: Colors.redAccent,
          icon: Icons.coronavirus_rounded,
          time: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        HealthAlert(
          title: "Prolifération Bactérienne",
          desc: "Température de 31.5°C détectée. Idéal pour le développement des germes.",
          room: "Labo Réseaux",
          level: "Avertissement",
          color: Colors.orangeAccent,
          icon: Icons.bug_report_rounded,
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final List<HealthAlert> displayedAlerts = MonitoringService.activeAlerts.where((alert) {
      if (_selectedFilterIndex == 0) {
        return alert.time.day == now.day && alert.time.month == now.month;
      }
      return true;
    }).toList();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_noraSoftBlue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimationLimiter(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    child: _buildFilterSelector(),
                  ),
                ),
                _buildStatusHeader(displayedAlerts.length),
                displayedAlerts.isEmpty
                    ? _buildEmptyState()
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final alert = displayedAlerts[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: _buildInteractiveDismissible(alert),
                                  ),
                                ),
                              );
                            },
                            childCount: displayedAlerts.length,
                          ),
                        ),
                      ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- WIDGETS LOGIQUE MÉTIER ---

  Widget _buildInteractiveDismissible(HealthAlert alert) {
    return Dismissible(
      key: Key(alert.time.toString() + alert.title),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      onDismissed: (direction) {
        setState(() => MonitoringService.activeAlerts.remove(alert));
        HapticFeedback.mediumImpact(); // Vibration légère à la suppression
      },
      child: _buildAlertCard(alert),
    );
  }

  Widget _buildAlertCard(HealthAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: alert.color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: alert.color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => _showDetailsDialog(alert),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: alert.time.toString(),
                  child: Icon(alert.icon, color: alert.color, size: 30),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alert.title, 
                        style: const TextStyle(color: _noraBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(alert.room, 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(HealthAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Icon(alert.icon, color: alert.color),
            const SizedBox(width: 10),
            const Text("Détails du risque"),
          ],
        ),
        content: Text(alert.desc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Compris", style: TextStyle(color: _noraBlue)),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS UI ---

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 25),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
    );
  }

  Widget _buildFilterSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: _noraBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: List.generate(_filters.length, (index) {
          bool isSelected = _selectedFilterIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilterIndex = index);
                HapticFeedback.lightImpact(); // Petite vibration au changement de filtre
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
                ),
                child: Center(
                  child: Text(_filters[index],
                    style: TextStyle(color: isSelected ? _noraBlue : _noraBlue.withOpacity(0.4), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatusHeader(int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$count Notifications", style: const TextStyle(color: _noraBlue, fontWeight: FontWeight.w800, fontSize: 18)),
            if (count > 0)
              TextButton(
                onPressed: () {
                   setState(() => MonitoringService.activeAlerts.clear());
                   HapticFeedback.mediumImpact();
                },
                child: const Text("Tout effacer", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: Text("Aucun historique.", style: TextStyle(color: Colors.grey))),
      ),
    );
  }

  // --- MODIFICATION ICI : AJOUT DU LOGO ---
  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent, 
      elevation: 0, 
      centerTitle: true,
      automaticallyImplyLeading: false, // Empêche le bouton retour par défaut
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('lib/images/Fichier 2.png', height: 30),
          const SizedBox(width: 10),
          const Text("Notifications", style: TextStyle(color: _noraBlue, fontWeight: FontWeight.w900, fontSize: 22)),
        ],
      ),
    );
  }

  // --- NAVIGATION (VERSION CLASSIQUE) ---
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 30),
      height: 75,
      decoration: BoxDecoration(
        color: _noraBlue,
        borderRadius: BorderRadius.circular(35)
      ),
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
            if (index == 4) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Profil()));
          }
        },
      ),
    );
  }
}