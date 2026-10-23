import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter ko bolte hain ke pehle Firebase start karein
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase ko start karna (yeh zaroori hai, warna login check nahi hoga)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ServiceHubApp());
}

class ServiceHubApp extends StatelessWidget {
  const ServiceHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E6FD9),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}