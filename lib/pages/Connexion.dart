import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Variables d'état
  bool _obscurePassword = true;
  bool _isLoading = false;
  double _buttonScale = 1.0;

  // Couleurs
  static const Color _noraBlue = Color(0xFF201293);
  static const Color _noraSky = Color(0xFF5B9EEA);
  static const Color _noraWhite = Colors.white;

  // --- FONCTION DE CONNEXION ---
  Future<void> _connexion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          _showSnackBar("Connexion réussie ! Ravie de vous revoir.", Colors.green);
          await Future.delayed(const Duration(seconds: 1)); // Petite pause esthétique
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/accueil');
          }
        }

      } on FirebaseAuthException catch (e) {
        String errorMessage = "Identifiants incorrects.";
        
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          errorMessage = "Aucun utilisateur trouvé avec cet email.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Le mot de passe est incorrect.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Format d'email invalide.";
        } else if (e.code == 'user-disabled') {
          errorMessage = "Ce compte a été désactivé.";
        } else if (e.code == 'network-request-failed') {
          errorMessage = "Vérifiez votre connexion internet.";
        }
        
        _showSnackBar(errorMessage, Colors.redAccent);
      } catch (e) {
        _showSnackBar("Erreur technique : ${e.toString()}", Colors.redAccent);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _noraWhite,
      body: Stack(
        children: [
          // Arrière-plan décoratif (Même que Inscription)
          Positioned(top: -100, right: -50, child: _buildCircle(250, _noraBlue.withOpacity(0.05))),
          Positioned(bottom: -50, left: -50, child: _buildCircle(200, _noraSky.withOpacity(0.1))),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_noraSky.withOpacity(0.05), _noraWhite],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: AnimationLimiter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 600),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 40.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          // LOGO HORIZONTAL (Images)
                          _buildLogo(),

                          const SizedBox(height: 35),
                          const Text("Bon retour !", style: TextStyle(color: _noraBlue, fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text("Connectez-vous pour suivre votre air", 
                            style: TextStyle(color: _noraBlue.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w500)),
                          
                          const SizedBox(height: 50),
                          
                          // CHAMPS DE SAISIE
                          _buildTextField(_emailController, "Adresse Email", Icons.alternate_email, false),
                          const SizedBox(height: 20),
                          _buildTextField(_passwordController, "Mot de passe", Icons.lock_outline, true),
                          
                          const SizedBox(height: 10),
                          // Mot de passe oublié
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Ajouter la navigation vers mot de passe oublié ici si besoin
                              },
                              child: const Text("Mot de passe oublié ?", 
                                style: TextStyle(color: _noraSky, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),

                          const SizedBox(height: 30),
                          _buildSubmitButton(),
                          const SizedBox(height: 25),
                          _buildSignupLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  // --- LOGO HORIZONTAL (Identique à Inscription) ---
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'lib/images/Fichier 2.png',
          height: 70,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 15),
        Image.asset(
          'lib/images/Fichier 3.png',
          height: 35,
          fit: BoxFit.contain,
          color: _noraBlue, 
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPass) {
    return Container(
      decoration: BoxDecoration(
        color: _noraWhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _noraBlue.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPass ? _obscurePassword : false,
        style: const TextStyle(color: _noraBlue, fontWeight: FontWeight.w600),
        validator: (value) {
           if (value == null || value.isEmpty) return "Ce champ est requis";
           return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _noraBlue.withOpacity(0.3), fontSize: 13),
          prefixIcon: Icon(icon, color: _noraBlue, size: 18),
          suffixIcon: isPass ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: _noraBlue.withOpacity(0.2), size: 18),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _buttonScale = 0.95),
      onTapUp: (_) => setState(() => _buttonScale = 1.0),
      onTap: _isLoading ? null : _connexion,
      child: AnimatedScale(
        scale: _buttonScale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: _noraBlue,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: _noraBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Center(
            child: _isLoading 
              ? const CircularProgressIndicator(color: _noraWhite)
              : const Text("Se connecter", style: TextStyle(color: _noraWhite, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return TextButton(
      onPressed: () => Navigator.pushReplacementNamed(context, '/inscription'),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.grey, fontSize: 14),
          children: [
            TextSpan(text: "Pas encore membre ? "),
            TextSpan(text: "Créer un compte", style: TextStyle(color: _noraBlue, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}