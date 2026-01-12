import 'package:cloud_firestore/cloud_firestore.dart';

class SensorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- CETTE FONCTION PERMET LA CONSULTATION DE L'HISTORIQUE ---
  // Elle récupère une LISTE de documents pour afficher les graphiques
  Stream<List<Map<String, dynamic>>> getFilteredSensorData(int days) {
    // 1. Calcul de la date limite selon le choix (Quotidien, Hebdomadaire, Mensuel)
    DateTime limitDate = DateTime.now().subtract(Duration(days: days));
    
    // 2. Formatage AAAA-MM-JJ pour correspondre à tes captures Firestore (ex: "2026-01-12")
    String dateThreshold = "${limitDate.year}-${limitDate.month.toString().padLeft(2, '0')}-${limitDate.day.toString().padLeft(2, '0')}";

    // 3. LA REQUÊTE : On demande tous les documents de Janvier depuis cette date
    // On trie par date descendante pour avoir la donnée la plus récente en premier
    return _db.collection('DHT22_data')
        .where('date_time', isGreaterThanOrEqualTo: dateThreshold)
        .orderBy('date_time', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Optionnel : Une fonction simple pour récupérer uniquement le dernier MQ135
  Stream<Map<String, dynamic>> getLatestMQ135() {
    return _db.collection('MQ135_data')
        .orderBy('date_time', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty ? snap.docs.first.data() : {});
  }
}