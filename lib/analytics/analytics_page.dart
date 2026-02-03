import 'package:flutter/material.dart';
import '../data/database.dart';

class AnalyticsPage extends StatelessWidget {
  final AppDatabase database;

  const AnalyticsPage({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: const Center(
        child: Text("Warranty charts coming next"),
      ),
    );
  }
}
