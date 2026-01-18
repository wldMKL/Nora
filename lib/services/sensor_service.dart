import 'package:cloud_firestore/cloud_firestore.dart';

class SensorService {
  final CollectionReference _sensorCollection = 
      FirebaseFirestore.instance.collection('sensor_data');

  // On ajoute un paramètre optionnel pour forcer le refresh si besoin
  Stream<List<Map<String, dynamic>>> getFilteredSensorData(int days) {
    
    // Calcul de la date limite EXACTE au moment de l'appel
    DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
    print("DEMANDE DE DONNÉES DEPUIS : $cutoffDate"); // Log pour vérifier

    return _sensorCollection
        .orderBy('date_time', descending: true)
        .limit(100) // On prend large
        .snapshots()
        .map((snapshot) {
          List<Map<String, dynamic>> filteredList = [];

          for (var doc in snapshot.docs) {
            var data = doc.data() as Map<String, dynamic>;
            
            // Nettoyage et conversion de la date
            String dateStr = (data['date_time']?.toString() ?? '').replaceAll(' ', 'T');
            DateTime? docDate = DateTime.tryParse(dateStr);

            // FILTRE STRICT : On ne garde que ce qui est après la date limite
            if (docDate != null && docDate.isAfter(cutoffDate)) {
              filteredList.add(data);
            }
          }

          // Tri Chronologique (Ancien -> Récent) pour le graphique
          filteredList.sort((a, b) {
            String da = (a['date_time']?.toString() ?? '').replaceAll(' ', 'T');
            String db = (b['date_time']?.toString() ?? '').replaceAll(' ', 'T');
            return (DateTime.tryParse(da) ?? DateTime(1970))
                .compareTo(DateTime.tryParse(db) ?? DateTime(1970));
          });

          print("DONNÉES FILTRÉES TROUVÉES : ${filteredList.length}"); // Log debug
          return filteredList;
        });
  }
}