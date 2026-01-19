import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'Accueil.dart';
import 'Connexion.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoBlur;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _masterOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 1. Logo : Zoom
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    // 2. Logo : Rotation
    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic)),
    );

    // 3. Logo : Mise au point
    _logoBlur = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    // 4. Texte : Opacité
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
    );

    // 5. Texte : Glissement latéral
    _textSlide = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller, 
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack),
      ),
    );

    // 6. Global : Fondu
    _masterOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.2, curve: Curves.easeIn)),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3200), () => _checkLoginStatus());
  }

  void _checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    Widget nextStep = (user != null) ? const Accueil() : const Connexion();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondaryAnim) => nextStep,
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          // Effet zoom Netflix pour la page Connexion
          if (user == null) {
            final zoomAnimation = Tween<double>(
              begin: 3.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: anim,
                curve: Curves.easeInOut,
              ),
            );

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: anim,
                curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: Transform.scale(
                scale: zoomAnimation.value,
                child: child,
              ),
            );
          }
          // Transition simple pour Accueil
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FOND BLEU BLANCHÂTRE AVEC DÉGRADÉ RENFORCÉ
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8D4FF), // Bleu clair plus visible en haut
              Color(0xFFD6E8FF), // Bleu pâle
              Color(0xFFF0F5FF), // Bleu très pâle
              Color(0xFFFFFFFF), // Blanc pur en bas
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Halo lumineux derrière le logo
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 200 * _logoScale.value,
                    height: 200 * _logoScale.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.15 * _textOpacity.value),
                          blurRadius: 150,
                          spreadRadius: 80,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            // Logo et texte
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _masterOpacity.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: _logoScale.value,
                          child: Transform.rotate(
                            angle: _logoRotation.value,
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: _logoBlur.value, sigmaY: _logoBlur.value),
                              child: Image.asset(
                                'lib/images/Fichier 2.png',
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SlideTransition(
                          position: _textSlide,
                          child: Opacity(
                            opacity: _textOpacity.value,
                            child: Image.asset(
                              'lib/images/Fichier 4.png',
                              height: 55,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}