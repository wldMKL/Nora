import 'package:flutter/material.dart';
import 'dart:ui';

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
  late Animation<Offset> _slideAnimation;

  // Palette de couleurs conservée mais utilisée plus subtilement
  static const Color _noraAccentBlue = Color(0xFF201293);
  static const Color _softBlue = Color(0xFF5B9EEA);
  static const Color _lightPurple = Color(0xFF9D84F5);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Animation légèrement plus rapide
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15), // Mouvement plus subtil
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
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
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);

      if (mounted) {
        _showSnackBar(
          message: 'Inscription réussie ! Bienvenue sur Nora AI',
          icon: Icons.check_circle_rounded,
          color: Colors.green.shade600,
        );
        Navigator.pushReplacementNamed(context, '/accueil');
      }
    }
  }

  void _showSnackBar({required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    // Design épuré : pas d'ombres lourdes, focus sur l'espace interne
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optionnel : Afficher le label au-dessus du champ pour plus de clarté
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: _noraAccentBlue.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(18), // Arrondi plus prononcé
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            keyboardType: label.toLowerCase().contains('email')
                ? TextInputType.emailAddress
                : TextInputType.text,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(icon, color: _noraAccentBlue.withOpacity(0.6), size: 24),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 50),
              suffixIcon: toggleObscure != null
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: _noraAccentBlue.withOpacity(0.4),
                        size: 20,
                      ),
                      onPressed: toggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              // Padding interne augmenté pour "aérer" le texte
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              errorStyle: const TextStyle(height: 0.8, color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_noraAccentBlue, _softBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _noraAccentBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildSignupCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40), // Bordures plus douces
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          // Marge interne considérablement augmentée (40px)
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- HEADER ---
                Center(child: _buildLogo()),
                const SizedBox(height: 24), // Espace
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [_noraAccentBlue, _softBlue],
                  ).createShader(bounds),
                  child: const Text(
                    'Créer un compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenue dans le futur avec Nora AI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _noraAccentBlue.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 40), // Grande respiration avant le formulaire

                // --- FORMULAIRE ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _nomController,
                        label: 'Nom',
                        hint: 'Dupont',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16), // Espace horizontal augmenté
                    Expanded(
                      child: _buildInputField(
                        controller: _prenomController,
                        label: 'Prénom',
                        hint: 'Jean',
                        icon: Icons.badge_outlined,
                        validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Espace vertical standard augmenté (16 -> 24)
                
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
                  hint: 'Min. 8 caractères',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscurePassword,
                  toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) => (v != null && v.length < 8) ? 'Trop court' : null,
                ),
                const SizedBox(height: 24),
                
                _buildInputField(
                  controller: _confirmPasswordController,
                  label: 'Confirmation',
               hint: 'Répétez le mot de passe',
  // REMPLACEMENT DE L'ICÔNE ERRONÉE ICI :
  icon: Icons.verified_user_outlined, 
  obscure: _obscureConfirmPassword,
  toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
  validator: (v) => v != _passwordController.text ? 'Non identique' : null,
                ),
                
                const SizedBox(height: 32),

                // --- TERMS ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alignement haut pour le texte long
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                        activeColor: _softBlue,
                        side: BorderSide(color: _noraAccentBlue.withOpacity(0.3), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2.0), // Petit ajustement d'alignement
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: _noraAccentBlue.withOpacity(0.7),
                              height: 1.4, // Interligne pour la lisibilité
                            ),
                            children: [
                              const TextSpan(text: "J'ai lu et j'accepte les "),
                              TextSpan(
                                text: "conditions d'utilisation",
                                style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              ),
                              const TextSpan(text: " et la "),
                              TextSpan(
                                text: "politique de confidentialité",
                                style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              ),
                              const TextSpan(text: "."),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- ACTION ---
                Container(
                  height: 56, // Bouton plus haut
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [_noraAccentBlue, _softBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _softBlue.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _inscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Commencer l\'aventure',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- FOOTER ---
                Row(
                  children: [
                    Expanded(child: Divider(color: _noraAccentBlue.withOpacity(0.2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: TextStyle(
                          color: _noraAccentBlue.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: _noraAccentBlue.withOpacity(0.2))),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/connexion'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: _noraAccentBlue.withOpacity(0.8),
                        ),
                        children: [
                          const TextSpan(text: "Déjà membre ? "),
                          TextSpan(
                            text: "Se connecter",
                            style: TextStyle(
                              color: _softBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Permet au gradient de passer derrière la status bar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF5F7FA), // Très clair (presque blanc)
              const Color(0xFFE4EBF5), // Bleu gris très pâle
              _lightPurple.withOpacity(0.2),
            ],
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
                    constraints: const BoxConstraints(maxWidth: 500), // Carte légèrement plus large
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
}