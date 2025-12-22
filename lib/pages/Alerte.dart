import 'package:flutter/material.dart';
import 'dart:ui';

class Alerte extends StatelessWidget {
  const Alerte({super.key});

  // Couleurs thématiques
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _warningRed = Color(0xFFE53935);
  static const Color _bgColor = Color(0xFFF8F9FA);

  // Liste fictive d'alertes
  static const List<Map<String, dynamic>> _alerts = [
    {
      'title': 'Pic de poussière détecté',
      'room': 'Salle Cisco',
      'time': 'Il y a 2 min',
      'level': 'Critique',
      'desc': 'Le taux de particules PM2.5 a dépassé 50 µg/m³. Port du masque conseillé.',
      'icon': Icons.warning_amber_rounded,
      'color': Color(0xFFE53935),
    },
    {
      'title': 'Maintenance requise',
      'room': 'Amphi Théâtre',
      'time': 'Il y a 1h',
      'level': 'Info',
      'desc': 'Le capteur de la salle nécessite un nettoyage pour rester précis.',
      'icon': Icons.settings_suggest_rounded,
      'color': Color(0xFF201293),
    },
    {
      'title': 'Qualité de l\'air moyenne',
      'room': 'Labo Réseaux',
      'time': 'Il y a 3h',
      'level': 'Avertissement',
      'desc': 'Légère hausse de l\'humidité. Risque de prolifération de moisissures.',
      'icon': Icons.info_outline_rounded,
      'color': Color(0xFFFF9800),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_warningRed.withOpacity(0.05), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAlertCard(_alerts[index]),
                    childCount: _alerts.length,
                  ),
                ),
              ),
              _buildPreventionTip(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _noraAccentBlue),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Alertes Santé",
        style: TextStyle(color: _noraAccentBlue, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.done_all_rounded, color: _noraAccentBlue),
          onPressed: () {},
        )
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final Color alertColor = alert['color'] as Color;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: alertColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: alertColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(alert['icon'] as IconData, color: alertColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    (alert['level'] as String).toUpperCase(),
                    style: TextStyle(
                      color: alertColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                alert['time'] as String,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            alert['title'] as String,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _noraAccentBlue,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Localisation : ${alert['room']}",
            style: TextStyle(
              color: _noraAccentBlue.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            alert['desc'] as String,
            style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alertColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Voir les détails"),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPreventionTip() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _noraAccentBlue,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.white, size: 40),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Conseil du jour",
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Aérez les salles pendant 10 min entre chaque séance pour évacuer les micro-particules.",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}