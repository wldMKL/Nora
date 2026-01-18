import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class HealthAlert {
  final String title;
  final String room;
  final String level;
  final String desc;
  final Color color;
  final IconData icon;
  final DateTime time;

  HealthAlert({
    required this.title,
    required this.room,
    required this.level,
    required this.desc,
    required this.color,
    required this.icon,
    required this.time,
  });
}

class MonitoringService {
  static final List<HealthAlert> activeAlerts = [];
  
  // --- NOUVEAU : LE VIGILE PERMANENT ---
  static void startMonitoring() {
    print("🔴 SURVEILLANCE ACTIVÉE : Le vigile est en poste.");
    
    // On écoute la collection en temps réel
    FirebaseFirestore.instance
        .collection('sensor_data')
        .orderBy('date_time', descending: true)
        .limit(1) // On ne regarde que le TOUT DERNIER enregistrement
        .snapshots()
        .listen((snapshot) {
      
      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        
        // Conversion sécurisée des données
        double temp = double.tryParse(data['temperature']?.toString() ?? '0') ?? 0.0;
        double humid = double.tryParse(data['humidity']?.toString() ?? '0') ?? 0.0;
        var mqRaw = data['mq135'];
        int mq = (mqRaw is int) ? mqRaw : (double.tryParse(mqRaw?.toString() ?? '0') ?? 0.0).toInt();

        // On lance la vérification
        checkThresholds(temp, humid, mq, "Salle Cisco");
      }
    });
  }

  static void checkThresholds(double temp, double humid, int mq135, String room) {
    cleanOldAlerts();

    // 1. BACTÉRIES
    if (temp > 26 && humid > 65) {
      _addAlert(HealthAlert(
        title: "Risque Bactérien",
        room: room,
        level: "CRITIQUE",
        desc: "Température ($temp°C) et humidité élevées.",
        color: Colors.red,
        icon: Icons.bug_report_rounded,
        time: DateTime.now(),
      ));
    }
    // 2. MOISISSURES
    else if (humid > 70) {
       _addAlert(HealthAlert(
        title: "Risque Moisissure",
        room: room,
        level: "ATTENTION",
        desc: "Humidité trop élevée ($humid%).",
        color: Colors.purple,
        icon: Icons.water_drop_rounded,
        time: DateTime.now(),
      ));
    }
    // 3. VIRUS (AIR SEC)
    if (humid < 35) {
      _addAlert(HealthAlert(
        title: "Air Trop Sec",
        room: room,
        level: "AVERTISSEMENT",
        desc: "Humidité faible ($humid%). Risque viral.",
        color: Colors.orange,
        icon: Icons.sick_rounded,
        time: DateTime.now(),
      ));
    }
    // 4. CO2 / AIR VICIÉ
    if (mq135 > 1000) {
      _addAlert(HealthAlert(
        title: "Ouvrez les fenêtres",
        room: room,
        level: "CONFINEMENT",
        desc: "Air vicié détecté ($mq135 PPM).",
        color: Colors.blueGrey,
        icon: Icons.window_rounded,
        time: DateTime.now(),
      ));
    }
  }

  static void _addAlert(HealthAlert alert) {
    // ANTI-SPAM : On empêche la MÊME alerte de sonner toutes les secondes.
    // On vérifie si on a déjà envoyé cette alerte il y a moins de 5 MINUTES (pour le test).
    bool exists = activeAlerts.any((a) => 
      a.title == alert.title && 
      a.time.difference(DateTime.now()).inMinutes.abs() < 5 
    );
    
    if (!exists) {
      activeAlerts.insert(0, alert);
      
      // Envoi de la notification
      NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "⚠️ ${alert.title}",
        body: alert.desc,
      );
      
      print("🔔 NOTIFICATION ENVOYÉE : ${alert.title}");

      if (activeAlerts.length > 50) activeAlerts.removeLast();
    }
  }

  static void cleanOldAlerts() {
    final DateTime limitDate = DateTime.now().subtract(const Duration(hours: 48));
    activeAlerts.removeWhere((alert) => alert.time.isBefore(limitDate));
  }
}