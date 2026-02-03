import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Current logged-in user ka data fetch karein
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9), // Light background consistent with Home
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black, // Dark text
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. User Info Section (Center mein)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Profile Picture with Border
                Container(
                  padding: const EdgeInsets.all(4), // White border effect
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade50,
                    // Agar photoURL hai (Google se) toh wo dikhao, nahi to icon
                    backgroundImage: user?.photoURL != null 
                        ? NetworkImage(user!.photoURL!) 
                        : null,
                    child: user?.photoURL == null
                        ? Text(
                            (user?.displayName ?? "U")[0].toUpperCase(), // Name ka first letter
                            style: const TextStyle(fontSize: 40, color: Colors.blue),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name
                Text(
                  user?.displayName ?? "OwnDeck User",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                
                // Email
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "No Email Linked",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Edit Profile Button (Optional styling)
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Edit Profile Logic
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Edit Profile"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          
          // 2. Settings Menu (Cards style)
          const Text("Settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          
          _buildProfileOption(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            trailing: Switch(value: false, onChanged: (val) {}), // Toggle switch look
            onTap: () {},
          ),
          
          _buildProfileOption(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            onTap: () {},
          ),

          _buildProfileOption(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {},
          ),

          const SizedBox(height: 20),
          
          // 3. Logout Button (Red Color for danger action)
          _buildProfileOption(
            icon: Icons.logout,
            title: "Logout",
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget for cleaner list items ---
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? Colors.blue),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}