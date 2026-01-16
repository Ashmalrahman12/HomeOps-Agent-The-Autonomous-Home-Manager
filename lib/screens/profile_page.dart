import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_ops_agent/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(context).pop();

                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (context.mounted) {
                  // inside _showLogoutConfirmation...
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                       backgroundColor: Colors.black.withValues(alpha: 0.8),
                       behavior: SnackBarBehavior.floating,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(15),
                         side: const BorderSide(color: Colors.white10),
                       ),
                       content: const Text(
                         "Successfully signed out",
                         style: TextStyle(color: Colors.white),
                       ),
                     ),
                   );

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthenticationScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white10,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : ClipOval(
                          child: Image.network(
                            user!.photoURL!,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 60, color: Colors.white),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user?.displayName ?? "User Name",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? "User Email",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Divider(color: Colors.white10),
                  // PASSING CONTEXT HERE
                  _buildProfileOption(context, Icons.person, 'Account Settings'),
                  _buildProfileOption(context, Icons.notifications, 'Notifications'),
                  _buildProfileOption(context, Icons.security, 'Privacy & Security'),
                  _buildProfileOption(context, Icons.help_outline, 'Help Support'),
                  const Divider(color: Colors.white10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: Added BuildContext parameter and updated opacity method
  Widget _buildProfileOption(BuildContext context, IconData icon, String title) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.blue),
    ),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white30),
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // 1. Black background with slight transparency for glass effect
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          // 2. Add a thin white border to simulate glass edges
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.white10, width: 1),
          ),
          duration: const Duration(seconds: 1),
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text(
                "$title feature coming soon!",
                style: const TextStyle(
                  color: Colors.white, // 3. White text
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}