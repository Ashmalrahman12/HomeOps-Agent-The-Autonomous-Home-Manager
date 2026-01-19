import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import this
import 'package:home_ops_agent/firebase_options.dart';
import 'package:home_ops_agent/config/secrets.dart';
import 'package:home_ops_agent/screens/auth_screen.dart';
import 'package:home_ops_agent/screens/navigation_bar_page.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
    await Firebase.initializeApp(); 
  } catch (e) {
    print('Camera Error: $e');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await loadSecrets();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      // This listener is the ONLY way to ensure the app resets for new users
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // If snapshot has data, a user is logged in
          if (snapshot.hasData && snapshot.data != null) {
            return  NavigationBarPage();
          }
          // If no data, show Login Screen
          return const AuthenticationScreen();
        },
      ),
    );
  }
}