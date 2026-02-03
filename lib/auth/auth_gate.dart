import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page/home_page.dart';
import '../login_page/login_page.dart';
import '../data/database.dart';

class AuthGate extends StatelessWidget {
  final AppDatabase database;

  const AuthGate({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If waiting for Firebase to check token...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If User is logged in -> Go to Home
        if (snapshot.hasData) {
          return HomePage(database: database);
        }

        // If User is NOT logged in -> Go to Login
        return const LoginPage();
      },
    );
  }
}