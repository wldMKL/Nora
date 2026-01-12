import 'package:flutter/material.dart';

// Modèle simple pour l'alerte
class HealthAlert {
  final String title, room, level, desc;
  final Color color;
  final IconData icon;
  final DateTime time;

  HealthAlert({required this.title, required this.room, required this.level, 
               required this.desc, required this.color, required this.icon, required this.time});
}

class MonitoringService {
  // Liste partagée entre les pages Statistique et Alerte
  static final List<HealthAlert> activeAlerts = [];

  static void checkThresholds(double temp, double humid, int mq135, String room) {
    // SEUIL BACTÉRIES : Basé sur vos données (30.8°C et 76% humidité)
    if (temp > 30 && humid > 70) {
      _addAlert(HealthAlert(
        title: "Risque Bactérien",
        room: room,
        level: "CRITIQUE",
        desc: "Conditions idéales pour les bactéries. Aérez la salle.",
        color: Colors.red,
        icon: Icons.bug_report_rounded,
        time: DateTime.now(),
      ));
    }
    // SEUIL GRIPPE : Air trop sec
    if (humid < 40) {
      _addAlert(HealthAlert(
        title: "Risque Grippal",
        room: room,
        level: "AVERTISSEMENT",
        desc: "Air trop sec, favorise la survie des virus.",
        color: Colors.orange,
        icon: Icons.coronavirus_rounded,
        time: DateTime.now(),
      ));
    }
  }
  static void cleanOldAlerts() {
  final DateTime sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  activeAlerts.removeWhere((alert) => alert.time.isBefore(sevenDaysAgo));
}
  static void _addAlert(HealthAlert alert) {
    if (!activeAlerts.any((a) => a.title == alert.title)) {
      activeAlerts.insert(0, alert);
    }
  }
}