import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false; 
  bool _acceptTerms = false;
  double _buttonScale = 1.0;

  static const Color _noraBlue = Color(0xFF201293);
  static const Color _noraSky = Color(0xFF5B9EEA);
  static const Color _noraWhite = Colors.white;

  Future<void> _inscription() async {
    if (!_acceptTerms) {
      _showSnackBar("Veuillez accepter les conditions", Colors.orange);
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'nom': _nomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'email': _emailController.text.trim(),
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) Navigator.pushReplacementNamed(context, '/connexion');
      } catch (e) {
        _showSnackBar("Erreur lors de l'inscription", Colors.redAccent);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)), 
      backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _noraWhite,
      body: Stack(
        children: [
          // Arrière-plan décoratif
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
                          _buildLogo(),
                          const SizedBox(height: 25),
                          const Text("Créer un compte", style: TextStyle(color: _noraBlue, fontSize: 28, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text("Rejoignez la révolution de l'air pur", 
                            style: TextStyle(color: _noraBlue.withOpacity(0.4), fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 40),
                          _buildInputFields(),
                          const SizedBox(height: 20),
                          _buildTermsCheckbox(),
                          const SizedBox(height: 30),
                          _buildSubmitButton(),
                          const SizedBox(height: 25),
                          _buildFooter(),
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

  Widget _buildLogo() {
    return Container(
      height: 80, width: 80,
      decoration: BoxDecoration(
        color: _noraBlue,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: _noraBlue.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: const Center(child: Text("N", style: TextStyle(color: _noraWhite, fontSize: 38, fontWeight: FontWeight.w900))),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(_nomController, "Nom", Icons.person_outline, false)),
            const SizedBox(width: 15),
            Expanded(child: _buildTextField(_prenomController, "Prénom", Icons.badge_outlined, false)),
          ],
        ),
        const SizedBox(height: 15),
        _buildTextField(_emailController, "Adresse Email", Icons.alternate_email, false),
        const SizedBox(height: 15),
        _buildTextField(_passwordController, "Mot de passe", Icons.lock_outline, true),
        const SizedBox(height: 15),
        _buildTextField(_confirmPasswordController, "Confirmer le mot de passe", Icons.verified_user_outlined, true),
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

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (v) => setState(() => _acceptTerms = v!),
          activeColor: _noraBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const Expanded(child: Text("J'accepte les conditions d'utilisation", 
          style: TextStyle(color: _noraBlue, fontSize: 12, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _buttonScale = 0.95),
      onTapUp: (_) => setState(() => _buttonScale = 1.0),
      onTap: _isLoading ? null : _inscription,
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
              : const Text("S'inscrire", style: TextStyle(color: _noraWhite, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return TextButton(
      onPressed: () => Navigator.pushReplacementNamed(context, '/connexion'),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.grey, fontSize: 14),
          children: [
            TextSpan(text: "Déjà membre ? "),
            TextSpan(text: "Se connecter", style: TextStyle(color: _noraBlue, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}