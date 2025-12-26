import 'package:flutter/material.dart';
import 'dart:ui';
// --- SECTION : IMPORTS LOGIQUE ---
// Firebase Auth gère la vérification des emails et mots de passe
import 'package:firebase_auth/firebase_auth.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> with SingleTickerProviderStateMixin {
  // --- SECTION : VARIABLES ET CONTRÔLEURS ---
  final _formKey = GlobalKey<FormState>(); // Identifiant unique du formulaire pour la validation
  final TextEditingController _emailController = TextEditingController(); // Récupère le texte de l'email
  final TextEditingController _passwordController = TextEditingController(); // Récupère le texte du mot de passe
  
  bool _obscurePassword = true; // Gère l'affichage (masqué ou non) du mot de passe
  bool _isLoading = false;      // État pour afficher le chargement sur le bouton
  
  // Animations pour l'entrée en scène des éléments
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Palette de couleurs Nora
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _lightPurple = Color(0xFF9D84F5);

  @override
  void initState() {
    super.initState();
    // --- SECTION : INITIALISATION DES ANIMATIONS ---
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward(); // Lance l'animation au démarrage
  }

  @override
  void dispose() {
    // Libération des ressources pour éviter les fuites de mémoire
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // --- SECTION : LOGIQUE DE CONNEXION FIREBASE ---
  Future<void> _connexion() async {
    // On vérifie si les champs respectent les validateurs (ex: @ présent dans l'email)
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Active l'indicateur de chargement

      try {
        // Envoi des identifiants à Firebase Authentication
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          _showSnackBar(
            message: 'Connexion réussie ! Ravie de vous revoir.',
            icon: Icons.check_circle_rounded,
            color: Colors.green.shade600,
          );
          // NAVIGATION : On remplace la page actuelle par la page 'Accueil'
          Navigator.pushReplacementNamed(context, '/accueil');
        }
      } on FirebaseAuthException catch (e) {
        // GESTION DES ERREURS : Firebase renvoie des codes spécifiques
        String errorMsg = "Email ou mot de passe incorrect";
        if (e.code == 'user-not-found') errorMsg = "Aucun compte trouvé pour cet email.";
        if (e.code == 'wrong-password') errorMsg = "Mot de passe erroné.";
        
        _showSnackBar(message: errorMsg, icon: Icons.error_outline_rounded, color: Colors.red.shade600);
      } catch (e) {
        _showSnackBar(message: "Erreur : $e", icon: Icons.error_outline_rounded, color: Colors.red.shade600);
      } finally {
        // On désactive le chargement, que ce soit réussi ou non
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- SECTION : INTERFACE UTILISATEUR (DESIGN) ---
  
  // Widget pour les messages d'alerte (SnackBar)
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
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Widget réutilisable pour les champs Email et Mot de passe
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
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            keyboardType: label.toLowerCase().contains('email') ? TextInputType.emailAddress : TextInputType.text,
            style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: _noraAccentBlue.withOpacity(0.6)),
              suffixIcon: toggleObscure != null
                  ? IconButton(
                      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: _noraAccentBlue.withOpacity(0.4), size: 20),
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
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: _buildLoginCard(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- SECTION : CARTE DE CONNEXION (GLASSMORPHISM) ---
  Widget _buildLoginCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_noraAccentBlue, _softBlue]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: _noraAccentBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800))),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Bon retour !', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _noraAccentBlue)),
                const SizedBox(height: 40),
                
                // CHAMPS DE SAISIE
                _buildInputField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'votre@email.com',
                  icon: Icons.email_outlined,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Votre mot de passe',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 30),
                
                // BOUTON VALIDER
                GestureDetector(
                  onTap: _isLoading ? null : _connexion,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [_noraAccentBlue, _softBlue]),
                      boxShadow: [BoxShadow(color: _softBlue.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // LIEN VERS INSCRIPTION
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/inscription'),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 15, color: _noraAccentBlue.withOpacity(0.8)),
                        children: [
                          const TextSpan(text: "Nouveau ici ? "),
                          TextSpan(text: "Créer un compte", style: TextStyle(color: _softBlue, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}