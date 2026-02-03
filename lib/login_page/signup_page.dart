import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  double _passwordStrength = 0;
  String _passwordLabel = 'Weak';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(_fade);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------- VALIDATION ----------------
  bool _validate() {
    bool valid = true;
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Name is required' : null;
      _emailError = !_emailController.text.contains('@') ? 'Enter a valid email' : null;
      _passwordError = _passwordStrength < 0.6 ? 'Password too weak' : null;
    });

    if (_nameError != null || _emailError != null || _passwordError != null) {
      valid = false;
    }
    return valid;
  }

  // ---------------- PASSWORD STRENGTH ----------------
  void _checkPassword(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(value)) strength += 0.25;

    String label = 'Weak';
    if (strength >= 0.75) label = 'Strong';
    else if (strength >= 0.5) label = 'Medium';

    setState(() {
      _passwordStrength = strength;
      _passwordLabel = label;
    });
  }

  // ---------------- SIGN UP + FIRESTORE + VERIFICATION ----------------
  Future<void> _signup() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Create User in Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Update Display Name
      await credential.user?.updateDisplayName(_nameController.text.trim());

      // 3. Save User Data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Send Verification Email
      await credential.user?.sendEmailVerification();

      // 5. Sign Out immediately (force them to verify first)
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        // 6. Show Success Dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Verify Your Email'),
            content: Text(
                'A verification link has been sent to ${_emailController.text.trim()}.\n\nPlease check your inbox (and spam folder) and verify your email before logging in.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close Dialog
                  Navigator.pop(context); // Go back to Login Page
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signup Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------- UI HELPERS ----------------
  InputDecoration _input(String label, String? error) {
    return InputDecoration(
      labelText: label,
      errorText: error,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black45),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.3),
      ),
    );
  }

  Widget _blur(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _glass(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: child,
        ),
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Positioned(
              top: -120,
              left: -80,
              child: _blur(260, const Color(0xFFE0E7FF))),
          Positioned(
              bottom: -140,
              right: -100,
              child: _blur(300, const Color(0xFFFDE2E4))),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView( // Added for safety on small screens
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _glass(
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Create Account',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: _nameController,
                            decoration: _input('Full Name', _nameError),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            decoration: _input('Email', _emailError),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            onChanged: _checkPassword,
                            decoration: _input('Password', _passwordError),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _passwordStrength,
                            minHeight: 4,
                            backgroundColor: Colors.black12,
                            color: _passwordStrength >= 0.75
                                ? Colors.green
                                : _passwordStrength >= 0.5
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _passwordLabel,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF111111),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Create Account'),
                            ),
                          ),
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
}