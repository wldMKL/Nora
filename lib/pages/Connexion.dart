import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  // COULEURS NORA AIR
  static const Color _noraPrimary = Color(0xFF201293);
  static const Color _noraSky = Color(0xFF5B9EEA);
  static const Color _noraWhite = Colors.white;

  Future<void> _connexion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/accueil');
      } on FirebaseAuthException catch (e) {
        _showSnackBar(message: "Identifiants incorrects", color: Colors.redAccent);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar({required String message, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _noraWhite,
      body: Stack(
        children: [
          // Arrière-plan épuré
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
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 50),
                    _buildLoginForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 80, width: 80,
          decoration: BoxDecoration(
            color: _noraPrimary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: _noraPrimary.withOpacity(0.2), blurRadius: 20)],
          ),
          child: const Center(child: Text("N", style: TextStyle(color: _noraWhite, fontSize: 40, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(height: 25),
        const Text("Ravie de vous revoir", style: TextStyle(color: _noraPrimary, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text("Connectez-vous pour suivre votre air", style: TextStyle(color: _noraPrimary.withOpacity(0.4), fontSize: 14)),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_emailController, "Adresse Email", Icons.alternate_email, false),
          const SizedBox(height: 20),
          _buildTextField(_passwordController, "Mot de passe", Icons.lock_outline_rounded, true),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text("Mot de passe oublié ?", style: TextStyle(color: _noraSky, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 35),
          _buildSubmitButton(),
          const SizedBox(height: 25),
          _buildSignupLink(),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPass) {
    return Container(
      decoration: BoxDecoration(
        color: _noraWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _noraPrimary.withOpacity(0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPass ? _obscurePassword : false,
        style: const TextStyle(color: _noraPrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _noraPrimary.withOpacity(0.2), fontSize: 14),
          prefixIcon: Icon(icon, color: _noraPrimary, size: 20),
          suffixIcon: isPass ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: _noraPrimary.withOpacity(0.2)),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _connexion,
        style: ElevatedButton.styleFrom(
          backgroundColor: _noraPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          shadowColor: _noraPrimary.withOpacity(0.4),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: _noraWhite)
          : const Text("Se connecter", style: TextStyle(color: _noraWhite, fontWeight: FontWeight.w800, fontSize: 16)),
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
            TextSpan(text: "Créer un compte", style: TextStyle(color: _noraPrimary, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}