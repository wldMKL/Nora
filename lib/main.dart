import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';
import 'package:nora/pages/Accueil.dart';
import 'package:nora/pages/Connexion.dart';
import 'package:nora/pages/Inscription.dart';
import 'package:nora/pages/Statistique.dart';
import 'package:nora/pages/Alerte.dart';
import 'package:nora/pages/Profil.dart';  
import 'package:nora/pages/Splash.dart'; // L'import est bien là

void main() async {
  // 1. Initialise les liens avec le système
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Tente d'allumer Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase est bien initialisé !");
  } catch (e) {
    print("Erreur d'initialisation : $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nora',
      theme: ThemeData(
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
      
      // --- MODIFICATION ICI ---
      // On remplace Connexion() par SplashScreen() pour avoir l'animation au lancement
      home: const SplashScreen(), 
      
      routes: {
        '/connexion': (context) => const Connexion(),
        '/inscription': (context) => const Inscription(),
        '/accueil': (context) => const Accueil(),
        '/statistique': (context) => const Statistique(),
        '/alert': (context) => const Alerte(),
        '/profil': (context) => const Profil(),
      },
    );
  }
}