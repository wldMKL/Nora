import 'package:flutter/material.dart';
import 'dart:ui';
// --- LOGIQUE FIREBASE ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; 
  bool _acceptTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _lightPurple = Color(0xFF9D84F5);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- LOGIQUE D'INSCRIPTION ---
  Future<void> _inscription() async {
    if (!_acceptTerms) {
      _showSnackBar(
        message: 'Veuillez accepter les conditions d\'utilisation',
        icon: Icons.warning_amber_rounded,
        color: Colors.orange.shade600,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Création de l'utilisateur dans Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2. Stockage des données supplémentaires dans Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'nom': _nomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'uid': userCredential.user!.uid,
        });

        if (mounted) {
          _showSnackBar(
            message: 'Inscription réussie ! Veuillez vous connecter.',
            icon: Icons.check_circle_rounded,
            color: Colors.green.shade600,
          );
          
          // --- CORRECTION REDIRECTION ---
          // On redirige vers la page de connexion
          Navigator.pushReplacementNamed(context, '/connexion');
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = "Erreur lors de l'inscription";
        if (e.code == 'email-already-in-use') errorMsg = "Cet email est déjà utilisé.";
        if (e.code == 'weak-password') errorMsg = "Mot de passe trop faible.";
        
        _showSnackBar(message: errorMsg, icon: Icons.error_outline, color: Colors.redAccent);
      } catch (e) {
        _showSnackBar(message: "Erreur : $e", icon: Icons.error_outline, color: Colors.redAccent);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Barre de message (SnackBar)
  void _showSnackBar({required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // Design des champs de saisie (Ton style original)
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(label, style: TextStyle(color: _noraAccentBlue.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: _noraAccentBlue.withOpacity(0.6)),
              suffixIcon: toggleObscure != null
                  ? IconButton(
                      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _noraAccentBlue.withOpacity(0.4)),
                      onPressed: toggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFF5F7FA), const Color(0xFFE4EBF5), _lightPurple.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: _buildSignupCard(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo "N"
          Center(
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_noraAccentBlue, _softBlue]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Créer un compte', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
          const SizedBox(height: 30),
          
          // Nom & Prénom
          Row(
            children: [
              Expanded(child: _buildInputField(controller: _nomController, label: 'Nom', hint: 'Nom', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Requis' : null)),
              const SizedBox(width: 12),
              Expanded(child: _buildInputField(controller: _prenomController, label: 'Prénom', hint: 'Prénom', icon: Icons.badge_outlined, validator: (v) => v!.isEmpty ? 'Requis' : null)),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildInputField(controller: _emailController, label: 'Email', hint: 'exemple@mail.com', icon: Icons.email_outlined, validator: (v) => !v!.contains('@') ? 'Invalide' : null),
          const SizedBox(height: 20),
          
          _buildInputField(controller: _passwordController, label: 'Mot de passe', hint: 'Min. 8 caractères', icon: Icons.lock_outline, obscure: _obscurePassword, toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword), validator: (v) => v!.length < 8 ? 'Trop court' : null),
          const SizedBox(height: 20),
          
          _buildInputField(controller: _confirmPasswordController, label: 'Confirmation', hint: 'Répétez le MDP', icon: Icons.verified_user_outlined, obscure: _obscureConfirmPassword, toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), validator: (v) => v != _passwordController.text ? 'Différent' : null),
          
          const SizedBox(height: 25),
          
          // Case à cocher
          Row(
            children: [
              Checkbox(value: _acceptTerms, onChanged: (v) => setState(() => _acceptTerms = v!), activeColor: _softBlue),
              const Expanded(child: Text("J'accepte les conditions d'utilisation", style: TextStyle(fontSize: 12))),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Bouton S'inscrire (Ton design original)
          GestureDetector(
            onTap: _isLoading ? null : _inscription,
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_noraAccentBlue, _softBlue]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: _softBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Center(
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Commencer l\'aventure', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/connexion'),
            child: const Text("Déjà membre ? Se connecter", style: TextStyle(color: _noraAccentBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}