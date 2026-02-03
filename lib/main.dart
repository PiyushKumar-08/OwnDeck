import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// --- USE THESE EXACT IMPORTS ---
// This works regardless of folder depth because it uses the full path
import 'data/database.dart'; 
import 'auth/auth_gate.dart'; 
import 'firebase_options.dart'; 
// -------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final database = AppDatabase();

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Owndeck',
      theme: ThemeData(useMaterial3: true),
      home: AuthGate(database: database),
    );
  }
}