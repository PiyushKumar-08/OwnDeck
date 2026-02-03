import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fade);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------- EMAIL LOGIN (WITH VERIFICATION CHECK) ----------------
  Future<void> _loginWithEmail() async {
    setState(() => _isLoading = true);
    try {
      // 1. Attempt Sign In
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Check if Email is Verified
      if (credential.user != null && !credential.user!.emailVerified) {
        // IF NOT VERIFIED:
        
        // A. Log them out immediately so AuthGate doesn't let them in
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          // B. Show Alert Dialog
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Email Not Verified'),
              content: const Text(
                  'Please check your inbox and verify your email before logging in.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // C. Allow Resending Verification Email
                    await credential.user?.sendEmailVerification();
                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Verification email sent again!')),
                      );
                    }
                  },
                  child: const Text('Resend Email'),
                ),
              ],
            ),
          );
        }
      } 
      // 3. If Verified, do nothing. AuthGate detects the login and moves to Home.
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- GOOGLE LOGIN ----------------
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final user = await googleSignIn.signIn();

      if (user == null) return;

      final auth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      // Google accounts are usually auto-verified, so we don't strictly need the check here.
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
        title: const Text('Login Failed'),
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
  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _glassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
              ),
            ],
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
      body: Stack(
        children: [
          // Abstract background
          Positioned(
            top: -120,
            left: -80,
            child: _blurCircle(260, const Color(0xFFE0E7FF)),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _blurCircle(300, const Color(0xFFFDE2E4)),
          ),

          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView( // Added scroll view for safety
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _glassCard(
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/full_logo.png',
                            height: 150, // Adjust this number to make the logo bigger/smaller
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 28),

                          TextField(
                            controller: _emailController,
                            style: GoogleFonts.inter(fontSize: 15),
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: GoogleFonts.inter(fontSize: 15),
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                          const SizedBox(height: 28),

                          SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _loginWithEmail,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                    const Color(0xFF111111),
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
                                  : const Text('Login'),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color:
                                      Colors.black.withOpacity(0.1),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color:
                                      Colors.black.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google icon only
                          GestureDetector(
                            onTap: _isLoading ? null : _loginWithGoogle,
                            child: Container(
                              width: 64, 
                              height: 64, 
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/google.png',
                                  height: 28, 
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupPage(),
                                ),
                              );
                            },
                            child: const Text('Need an account? Sign Up'),
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