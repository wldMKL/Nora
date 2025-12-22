import 'package:flutter/material.dart';
import 'package:nora/pages/Accueil.dart';
import 'package:nora/pages/Connexion.dart';
import 'package:nora/pages/Inscription.dart';
import 'package:nora/pages/Statistique.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home:  Accueil(),
      routes: {
        '/accueil': (context) => Accueil(),
        '/connexion': (context) => const Connexion(),
        '/inscription': (context) => const Inscription(),
        '/statistique':(context) =>  const Statistique(),
        },
    );
  }
}