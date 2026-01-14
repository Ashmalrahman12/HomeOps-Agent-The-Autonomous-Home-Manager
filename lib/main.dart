import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <--- 1. ADD THIS IMPORT
import 'package:home_ops_agent/config/secrets.dart';
import 'package:home_ops_agent/screens/navigation_bar_page.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    cameras = await availableCameras();
    
    // <--- 2. ADD THIS LINE TO START FIREBASE
    await Firebase.initializeApp(); 
    print("Firebase Initialized Successfully");
    
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  } catch (e) {
    print("Firebase Error: $e");
  }

  // You can keep this if you fixed the secrets file, 
  // otherwise remember we hardcoded the key in ai_service.dart to avoid crashes.
  await loadSecrets(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: NavigationBarPage(),
    );
  }
}